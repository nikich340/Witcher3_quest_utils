// ----------------------------------------------------------------------------
class CGenericListSettingList extends CRadishUiFilteredList {
    // ------------------------------------------------------------------------
    protected var data: C2dArray;
    protected var customData: C2dArray;
    // ------------------------------------------------------------------------
    public function loadCsv(path: String) {
        var i: int;

        data = LoadCSV(path);

        // csv: col0;CAT1;CAT2;CAT3;id;caption
        for (i = 0; i < data.GetNumRows(); i += 1) {
            items.PushBack(SModUiCategorizedListItem(
                data.GetValueAt(4, i),
                data.GetValueAt(5, i),
                data.GetValueAt(1, i),
                data.GetValueAt(2, i),
                data.GetValueAt(3, i)
            ));
        }
    }
    // ------------------------------------------------------------------------
    public function addCustomCsv(path: String) {
        var topCat: String;
        var i: int;

        if (path == "") return;

        topCat = GetLocStringByKeyExt("RADUI_ExtraCat");

        customData = LoadCSV(path);

        // csv: col0;<reserved>;CAT2;CAT3;id;caption
        for (i = 0; i < customData.GetNumRows(); i += 1) {
            items.PushBack(SModUiCategorizedListItem(
                customData.GetValueAt(4, i),
                customData.GetValueAt(5, i),
                topCat,
                customData.GetValueAt(2, i),
                customData.GetValueAt(3, i)
            ));
        }
    }
    // ------------------------------------------------------------------------
    public function addCustomEntries(entries: array<SRadUiCustomSettingEntry>) {
        var topCat: String;
        var i: int;

        topCat = GetLocStringByKeyExt("RADUI_ExtraCat");

        for (i = 0; i < entries.Size(); i += 1) {
            items.PushBack(SModUiCategorizedListItem(
                entries[i].id,
                entries[i].caption,
                topCat,
                entries[i].subCategory1,
                entries[i].subCategory2));
        }
    }
    // ------------------------------------------------------------------------
    public function addEntries(entries: array<SRadUiSettingEntry>) {
        var topCat: String;
        var i: int;

        for (i = 0; i < entries.Size(); i += 1) {
            items.PushBack(SModUiCategorizedListItem(
                entries[i].id,
                entries[i].caption,
                entries[i].topCat,
                entries[i].subCategory1,
                entries[i].subCategory2));
        }
    }
    // ------------------------------------------------------------------------
    // provide access to extra columns in the data csv
    public function getExtraData(id: String, col: int) : String {
        var result: String;
        var i, s: int;

        // starting with the smallest (custom)
        s = customData.GetNumRows();
        for (i = 0; i < s; i += 1) {
            if (customData.GetValueAt(4, i) == id) {
                return customData.GetValueAt(col, i);
            }
        }

        // this should be made more efficient (caching the last used position?)
        s = data.GetNumRows();
        for (i = 0; i < s; i += 1) {
            if (data.GetValueAt(4, i) == id) {
                return data.GetValueAt(col, i);
            }
        }
        LogChannel('DEBUG', "no extra data found for " + id);

        return "-";
    }
    // ------------------------------------------------------------------------
    public function clear() {
        items.Clear();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
struct SRadUiSettingEntry {
    var id: String;
    var caption: String;
    var topCat: String;
    var subCategory1: String;
    var subCategory2: String;
}
// ----------------------------------------------------------------------------
class CGenericSettingListProvider {
    // ------------------------------------------------------------------------
    private var loadedLists: array<String>;
    private var providerList: array<CGenericListSettingList>;
    // ------------------------------------------------------------------------
    public function getListProvider(listId: String) : CGenericListSettingList {
        var list: CGenericListSettingList;

        if (!loadedLists.Contains(listId)) {
            list = new CGenericListSettingList in this;

            list.clear();
            list.addCustomCsv(RADUI_getCustomSettingListCsv(listId));
            list.addCustomEntries(RADUI_getCustomSettingListEntries(listId));
            list.addEntries(getSettingListEntries(listId));
            list.loadCsv("dlc\dlcradishquestui\data\settinglist_" + listId + ".csv");

            providerList.PushBack(list);
            loadedLists.PushBack(listId);
        }

        return providerList[loadedLists.FindFirst(listId)];
    }
    // ------------------------------------------------------------------------
    protected function getSettingListEntries(listId: String)
        : array<SRadUiSettingEntry>
    {
        var entries: array<SRadUiSettingEntry>;

        // makes only sense for short static lists (no csv)
        /*
        switch (listId) {
            case someid:
                entries.PushBack(SRadUiSettingEntry("", "default"));
                entries.PushBack(SRadUiSettingEntry(id, caption, cat1));
                break;
        }
        */

        return entries;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
