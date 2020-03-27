// ----------------------------------------------------------------------------
// Storyboard UI: additional templates can be added dynamically, these are the
// required infos:
struct SSbUiExtraTemplate {
    var templatePath: String;
    var caption: String;
    var subCategory1: String;
    var subCategory2: String;
}
// ----------------------------------------------------------------------------
// add custom mod templates for actors here:
// ----------------------------------------------------------------------------
function SBUI_getExtraActorTemplates() : array<SSbUiExtraTemplate> {
    var actorTemplates: array<SSbUiExtraTemplate>;

    // Note: order must be sorted by subCategory1, subCategory2
    //actorTemplates.PushBack(SSbUiExtraTemplate("template\pathA", "my actor1", "My MOD", "optional subcategory"));
    //actorTemplates.PushBack(SSbUiExtraTemplate("template\pathB", "my actor2", "My MOD"));

    return actorTemplates;
}
// ----------------------------------------------------------------------------
// add custom mod templates for items here:
// ----------------------------------------------------------------------------
function SBUI_getExtraItemTemplates() : array<SSbUiExtraTemplate> {
    var itemTemplates: array<SSbUiExtraTemplate>;

    // Note: order must be sorted by subCategory1, subCategory2
    //itemTemplates.PushBack(SSbUiExtraTemplate("template\pathA", "my item1", "My MOD", "optional subcategory"));
    //itemTemplates.PushBack(SSbUiExtraTemplate("template\pathB", "my item2", "My MOD"));

    return itemTemplates;
}
// ----------------------------------------------------------------------------
