// ----------------------------------------------------------------------------
struct SRadishAnimSequenceInfo {
    var template: String;
    var animSequence: array<CName>;
    var appearance: CName;
}
// ----------------------------------------------------------------------------
class CRadishUiJobTreeList extends CRadishUiFilteredList {
    // ------------------------------------------------------------------------
    public function loadCsv(path: String) {
        var data: C2dArray;
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
    public function addExtraJobTreeCsv(path: String) {
        var topCat: String;
        var data: C2dArray;
        var i: int;

        topCat = GetLocStringByKeyExt("RADUI_ExtraJobTreeCat");

        data = LoadCSV(path);

        // csv: col0;CAT1;CAT2;id;caption
        for (i = 0; i < data.GetNumRows(); i += 1) {
            items.PushBack(SModUiCategorizedListItem(
                data.GetValueAt(3, i),
                data.GetValueAt(4, i),
                topCat,
                data.GetValueAt(1, i),
                data.GetValueAt(2, i)
            ));
        }
    }
    // ------------------------------------------------------------------------
    public function addExtraJobTrees(jobtrees: array<SRadUiExtraJobTree>) {
        var topCat: String;
        var i: int;

        topCat = GetLocStringByKeyExt("RADUI_ExtraJobTreeCat");

        for (i = 0; i < jobtrees.Size(); i += 1) {
            items.PushBack(SModUiCategorizedListItem(
                jobtrees[i].actionId,
                jobtrees[i].caption,
                topCat,
                jobtrees[i].subCategory1,
                jobtrees[i].subCategory2));
        }
    }
    // ------------------------------------------------------------------------
    public function clear() {
        items.Clear();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CRadishJobTreeManager {
    // jobtree lists
    private var jobtreeList: CRadishUiJobTreeList;
    private var dataLoaded: bool;
    // ------------------------------------------------------------------------
    private function lazyLoad() {
        var csv: array<String>;
        var i: int;
        jobtreeList = new CRadishUiJobTreeList in this;

        jobtreeList.clear();
        // prepend extra templates as those will probably be used more often
        csv = RADUI_getExtraJobTreeCsvs();
        for (i = 0; i < csv.Size(); i += 1) {
            jobtreeList.addExtraJobTreeCsv(csv[i]);
        }
        jobtreeList.addExtraJobTrees(RADUI_getExtraJobTrees());

        jobtreeList.loadCsv("dlc\dlcradishquestui\data\actionpoint_jobtrees.csv");

        dataLoaded = true;
    }
    // ------------------------------------------------------------------------
    public function getJobTreeList() : CRadishUiFilteredList {
        if (!dataLoaded) { lazyLoad(); }

        return jobtreeList;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class JobTreeAnimSequenceProvider {
    // ------------------------------------------------------------------------
    private var actionInfo: array<SRadishAnimSequenceInfo>;
    private var actionIds: array<String>;
    private var dataLoaded: bool;
    // ------------------------------------------------------------------------
    private var animIds: array<CName>;
    // ------------------------------------------------------------------------
    private function loadAnimationNames() {
        var data: C2dArray;
        var i: int;

        data = LoadCSV("dlc\dlcradishquestui\data\all.jobanims.csv");

        // csv: <position as id>;animname
        for (i = 0; i < data.GetNumRows(); i += 1) {
            animIds.PushBack(data.GetValueAtAsName(1, i));
        }
    }
    // ------------------------------------------------------------------------
    private function animIdSequenceToArray(seq: String) : array<CName> {
        var slot: int;
        var animSequence: array<CName>;
        var nextSlot: String;
        var remainder: String;

        remainder = seq;

        while (StrSplitFirst(remainder, ":", nextSlot, remainder)) {
            slot = StringToInt(nextSlot);
            animSequence.PushBack(animIds[slot]);
        }
        if (remainder != "") {
            slot = StringToInt(remainder);
            animSequence.PushBack(animIds[slot]);
        }

        return animSequence;
    }
    // ------------------------------------------------------------------------
    private function lazyLoad() {
        var customInfoList: array<SRadUiExtraJobTreePreviewInfo>;
        var customInfo: SRadUiExtraJobTreePreviewInfo;
        var data: C2dArray;
        var i: int;

        loadAnimationNames();

        data = LoadCSV("dlc\dlcradishquestui\data\all.jobsequences.csv");

        // csv: <position as id>;animname
        // csv: ;sequence-id;template;anim-ids
        for (i = 0; i < data.GetNumRows(); i += 1) {
            actionIds.PushBack(data.GetValueAt(1, i));
            actionInfo.PushBack(
                SRadishAnimSequenceInfo(
                    data.GetValueAt(2, i),
                    animIdSequenceToArray(data.GetValueAt(3, i))
                )
            );
        }

        customInfoList = RADUI_getExtraJobTreePreviewInfos();
        for (i = 0; i < customInfoList.Size(); i += 1) {
            customInfo = customInfoList[i];

            actionIds.PushBack(customInfo.id);
            actionInfo.PushBack(
                SRadishAnimSequenceInfo(customInfo.template, customInfo.animSequence)
            );
        }

        dataLoaded = true;
    }
    // ------------------------------------------------------------------------
    public function getActionInfo(id: String) : SRadishAnimSequenceInfo {
        var slot: int;

        if (!dataLoaded) { lazyLoad(); }

        slot = actionIds.FindFirst(id);
        if (slot >= 0) {
            return actionInfo[slot];
        } else {
            return SRadishAnimSequenceInfo("unknown");
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------