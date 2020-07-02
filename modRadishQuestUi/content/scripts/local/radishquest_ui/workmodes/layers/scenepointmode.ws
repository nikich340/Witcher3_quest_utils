// ----------------------------------------------------------------------------
state RadUi_InteractivePlacement in CRadishQuestLayerScenepointMode
    extends RadUi_BaseEntityInteractivePlacement
{
    default isRotatableYaw = true;
    default isRotatablePitch = false;
    default isRotatableRoll = false;
}
// ----------------------------------------------------------------------------
state RadUi_ScenepointEditing in CRadishQuestLayerScenepointMode extends RadUi_EntityEditing
{
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        entityEditor = new CRadishQuestLayerScenepointEditor in this;
        entity = parent.itemManager.getSelected();

        super.setupLabels("Scenepoint");
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_CycleAppearance', "RADUI_CycleAppearanceScenepoint"));
        super.OnEntityHotkeyHelp("Scenepoint", hotkeyList);
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
state RadUi_ScenepointManaging in CRadishQuestLayerScenepointMode extends RadUi_EntityManaging
{
    default editStateName = 'RadUi_ScenepointEditing';
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        super.setupLabels("Scenepoint");
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_CycleAppearance', "RADUI_CycleAppearanceScenepoint"));
        super.OnEntityHotkeyHelp("Scenepoint", hotkeyList);
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// Top level management of Scenepoints:
statemachine class CRadishQuestLayerScenepointMode extends CRadishQuestLayerEntityMode {
    default workMode = 'RADUI_QL_ModeScenepoints';
    default workContext = 'MOD_RadishUi_QL_ModeScenepoints';
    default generalHelpKey = "RADUI_ScenepointGeneralHelp";
    default defaultState = 'RadUi_ScenepointManaging';
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
