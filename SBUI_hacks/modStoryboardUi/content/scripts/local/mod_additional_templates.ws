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
    itemTemplates.PushBack(SSbUiExtraTemplate("gameplay\templates\signs\pc_aard.w2ent", "pc_aard", "Signs"));
    itemTemplates.PushBack(SSbUiExtraTemplate("gameplay\templates\signs\pc_axii.w2ent", "pc_axii", "Signs"));
    itemTemplates.PushBack(SSbUiExtraTemplate("gameplay\templates\signs\pc_igni.w2ent", "pc_igni", "Signs"));
    itemTemplates.PushBack(SSbUiExtraTemplate("gameplay\templates\signs\pc_igni_collision.w2ent", "pc_igni_collision", "Signs"));
    itemTemplates.PushBack(SSbUiExtraTemplate("gameplay\templates\signs\pc_igni_range.w2ent", "pc_igni_range", "Signs"));
    itemTemplates.PushBack(SSbUiExtraTemplate("gameplay\templates\signs\pc_quen.w2ent", "pc_quen", "Signs"));
    itemTemplates.PushBack(SSbUiExtraTemplate("gameplay\templates\signs\pc_quen_hit.w2ent", "pc_quen_hit", "Signs"));
    itemTemplates.PushBack(SSbUiExtraTemplate("gameplay\templates\signs\pc_yrden.w2ent", "pc_yrden", "Signs"));
    itemTemplates.PushBack(SSbUiExtraTemplate("gameplay\templates\signs\pc_yrden_rune_0.w2ent", "pc_yrden_rune_0", "Signs"));
    itemTemplates.PushBack(SSbUiExtraTemplate("gameplay\templates\signs\pc_yrden_rune_1.w2ent", "pc_yrden_rune_1", "Signs"));
    itemTemplates.PushBack(SSbUiExtraTemplate("gameplay\templates\signs\pc_yrden_rune_2.w2ent", "pc_yrden_rune_2", "Signs"));
    itemTemplates.PushBack(SSbUiExtraTemplate("gameplay\templates\signs\pc_yrden_rune_3.w2ent", "pc_yrden_rune_3", "Signs"));
    itemTemplates.PushBack(SSbUiExtraTemplate("gameplay\templates\signs\pc_yrden_rune_4.w2ent", "pc_yrden_rune_4", "Signs"));
    itemTemplates.PushBack(SSbUiExtraTemplate("gameplay\templates\signs\pc_yrden_rune_5.w2ent", "pc_yrden_rune_5", "Signs"));
    itemTemplates.PushBack(SSbUiExtraTemplate("gameplay\templates\signs\pc_yrden_rune_6.w2ent", "pc_yrden_rune_6", "Signs"));

    //itemTemplates.PushBack(SSbUiExtraTemplate("template\pathB", "my item2", "My MOD"));

    return itemTemplates;
}
// ----------------------------------------------------------------------------
