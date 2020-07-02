// ----------------------------------------------------------------------------
// Radish Quest UI: additional jobtrees can be added dynamically, these are the
// required infos:
struct SRadUiExtraJobTree {
    var actionId: String;
    var caption: String;
    var subCategory1: String;
    var subCategory2: String;
}
// ----------------------------------------------------------------------------
// add custom mod jobtrees for actionpoints here:
// ----------------------------------------------------------------------------
function RADUI_getExtraJobTrees() : array<SRadUiExtraJobTree> {
    var jobTrees: array<SRadUiExtraJobTree>;

    // Note: order must be sorted by subCategory1, subCategory2
    //jobTrees.PushBack(SRadUiExtraJobTree("myJobTreeCategory:myAction1", "my action caption 1", "My MOD", "optional subcategory"));
    //jobTrees.PushBack(SRadUiExtraJobTree("myJobTreeCategory:myAction2", "my action caption 2", "My MOD", "optional subcategory"));

    return jobTrees;
}
// ----------------------------------------------------------------------------
// add jobtree list(s) provided as csv (useful if there are many new jobtrees)
// ----------------------------------------------------------------------------
function RADUI_getExtraJobTreeCsvs() : array<String> {
    var jobTreeCsvList: array<String>;

    // Note: format of csv must be: TODO
    //jobTreeCsvList.PushBack("dlc\dlcradishquestui\data\my_quest_jobtrees.csv");
    //jobTreeCsvList.PushBack("dlc\dlcradishquestui\data\my_quest_jobtrees2.csv");

    return jobTreeCsvList;
}
// ----------------------------------------------------------------------------
// define custom jobtree preview-animation sequences here
// ----------------------------------------------------------------------------
// make sure there is a preview definition for EVERY extra jobtree defined above!
// ----------------------------------------------------------------------------
struct SRadUiExtraJobTreePreviewInfo {
    var id: String;
    var template: String;
    var animSequence: array<CName>;
}
// ----------------------------------------------------------------------------
function RADUI_getExtraJobTreePreviewInfos() : array<SRadUiExtraJobTreePreviewInfo> {
    var jobTreePreviewInfos: array<SRadUiExtraJobTreePreviewInfo>;
    var animSequence: array<CName>;

    /*
    animSequence.Clear();
    animSequence.PushBack('man_npc_bow_shoot_to_aim');
    animSequence.PushBack('man_npc_bow_aim_to_idle_lp');
    animSequence.PushBack('man_npc_bow_idle_to_aim_lp');
    animSequence.PushBack('man_npc_bow_idle_lp_01');
    //animSequence.PushBack('man_noble_staring_at_woman_loop_03');
    jobTreePreviewInfos.PushBack(SRadUiExtraJobTreePreviewInfo(
        "myJobTreeCategory:myAction1",
        // template must have compatible animatonset!
        "gameplay/community/community_npcs/prologue/regular/temerian_hunter.w2ent",
        animSequence
    ));

    animSequence.Clear();
    animSequence.PushBack('man_npc_sword_1hand_burn_start_left');
    animSequence.PushBack('man_npc_sword_1hand_taunt_1_right');
    animSequence.PushBack('man_npc_sword_1hand_burn_stop_left');
    jobTreePreviewInfos.PushBack(SRadUiExtraJobTreePreviewInfo(
        "myJobTreeCategory:myAction2",
        "characters/npc_entities/crowd_npc/prolog_villager/prolog_villager.w2ent",
        animSequence
    ));
    */

    return jobTreePreviewInfos;
}
// ----------------------------------------------------------------------------
