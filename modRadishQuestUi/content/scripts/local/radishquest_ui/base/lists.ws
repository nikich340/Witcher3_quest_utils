// ----------------------------------------------------------------------------
abstract class CRadishUiFilteredList extends CModUiFilteredList {
    // ------------------------------------------------------------------------
    public function preselect(optional openCategories: bool) {
        if (items.Size() > 0) {
            selectedId = items[0].id;
            if (openCategories) {
                selectedCat1 = items[0].cat1;
                selectedCat2 = items[0].cat2;
                selectedCat3 = items[0].cat3;
            }
        }
    }
    // ------------------------------------------------------------------------
    public function getSelectedId() : String {
        return selectedId;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CRadishUiSettingsList extends CRadishUiFilteredList {
    // ------------------------------------------------------------------------
    protected var inactiveCol: String; default inactiveCol = "#777777";
    // ------------------------------------------------------------------------
    public function clear() {
        items.Clear();
    }
    // ------------------------------------------------------------------------
    public function addSetting(
        id: String, caption: String,
        optional cat1: String, optional cat2: String, optional cat3: String)
    {
        items.PushBack(SModUiCategorizedListItem(id, caption, cat1, cat2, cat3));
    }
    // ------------------------------------------------------------------------
    public function addColoredSetting(
        col: String, id: String, caption: String,
        optional cat1: String, optional cat2: String, optional cat3: String)
    {
        items.PushBack(SModUiCategorizedListItem(id, "<font color=\"" + col + "\">" + caption + "</font>", cat1, cat2, cat3));
    }
    // ------------------------------------------------------------------------
    public function addSetting_string(
        key: String, value: String, caption: String,
        optional cat1: String, optional cat2: String, optional cat3: String)
    {
        addSetting(key, caption + ": " + StrReplaceAll(value, "_", " "), cat1, cat2, cat3);
    }
    // ------------------------------------------------------------------------
    public function addSetting_int(
        key: String, value: int, caption: String,
        optional cat1: String, optional cat2: String, optional cat3: String)
    {
        addSetting(key, caption + ": " + value, cat1, cat2, cat3);
    }
    // ------------------------------------------------------------------------
    public function addSetting_float(
        key: String, value: float, caption: String,
        optional cat1: String, optional cat2: String, optional cat3: String)
    {
        addSetting(key, caption + ": " + FloatToStringPrec(value, 1), cat1, cat2, cat3);
    }
    // ------------------------------------------------------------------------
    public function addSetting_bool(
        key: String, value: bool, caption: String,
        optional cat1: String, optional cat2: String, optional cat3: String)
    {
        addSetting(key, caption + ": " + value, cat1, cat2, cat3);
    }
    // ------------------------------------------------------------------------
    public function addSetting_string_opt(
        key: String, value: String, caption: String,
        optional cat1: String, optional cat2: String, optional cat3: String)
    {
        if (value != "") {
            addSetting_string(key, value, caption, cat1, cat2, cat3);
        }  else {
            addColoredSetting(inactiveCol, key, caption + ": -", cat1, cat2, cat3);
        }
    }
    // ------------------------------------------------------------------------
    public function addSetting_int_opt(
        key: String, value: int, min: int, caption: String,
        optional cat1: String, optional cat2: String, optional cat3: String)
    {
        if (value > min) {
            addSetting_int(key, value, caption, cat1, cat2, cat3);
        }  else {
            addColoredSetting(inactiveCol, key, caption + ": -", cat1, cat2, cat3);
        }
    }
    // ------------------------------------------------------------------------
    public function addSetting_float_opt(
        key: String, value: Float, min: Float, caption: String,
        optional cat1: String, optional cat2: String, optional cat3: String)
    {
        if (value > min) {
            addSetting_float(key, value, caption, cat1, cat2, cat3);
        }  else {
            addColoredSetting(inactiveCol, key, caption + ": -", cat1, cat2, cat3);
        }
    }
    // ------------------------------------------------------------------------
    public function addSetting_bool_opt(
        key: String, value: bool, caption: String, defaultValue: bool,
        optional cat1: String, optional cat2: String, optional cat3: String)
    {
        if (value != defaultValue) {
            addSetting(key, caption + ": " + value, cat1, cat2, cat3);
        } else {
            addColoredSetting(inactiveCol, key, caption + ": " + value, cat1, cat2, cat3);
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
