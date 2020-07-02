// ----------------------------------------------------------------------------
// Radish Quest UI: additional entries for setting list values can be added
// dynamically, these are the required infos:
struct SRadUiCustomSettingEntry {
    var id: String;
    var caption: String;
    var subCategory1: String;
    var subCategory2: String;
    // Note: extra data NOT supported for customEntries since access is by
    // column number - use custom csv instead
}
// ----------------------------------------------------------------------------
function RADUI_getCustomSettingListEntries(listId: String) : array<SRadUiCustomSettingEntry>
{
    // listId will specify the setting list that will be extend
    //
    // see "dlc/dlcradishquestui/data/settinglist_<listId>.csv for expected
    // format of id, caption and subcategories
    //
    // cat1 will always be set to "[ Custom ]"
    //
    // Note: entries must be sorted by subCategory1, subCategory2
    //
    var entries: array<SRadUiCustomSettingEntry>;

    switch (listId) {
        //case "<id>": return "full/path/to/values_<id>.csv";
        case "entity_templates":
            //entries.PushBack(SRadUiCustomSettingEntry("template\pathA", "my item1", "My MOD", "optional subcategory"));
            //entries.PushBack(SRadUiCustomSettingEntry("template\pathB", "my item2", "My MOD"));
        break;

        case "env":             break;

        case "particles":       break;

        case "sound_ambient":   break;

        case "sound_reverb":    break;
    }

    return entries;
}
// ----------------------------------------------------------------------------
// Radish Quest UI: provide an additional csv to extend the radui value list
// for a specific entity setting
// ----------------------------------------------------------------------------
function RADUI_getCustomSettingListCsv(listId: String) : String {
    //
    // listId will specify the setting list that will be extend
    //
    // see "dlc/dlcradishquestui/data/settinglist_<listId>.csv for expected
    // format of the csv
    //
    // leave cat1 columen empty as it will always be overriden with "[ Custom ]"
    //

    switch (listId) {
        //case "<id>": return "dlc/full/path/to/values_<id>.csv";
        case "entity_templates": return "";
        case "env":              return "";
        case "particles":        return "";
        case "sound_ambient":    return "";
        case "sound_reverb":     return "";
    }

    return "";
}
// ----------------------------------------------------------------------------
