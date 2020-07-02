// ----------------------------------------------------------------------------
state RadUi_InteractivePlacement in CRadishQuestLayerWaypointMode
    extends RadUi_BaseEntityInteractivePlacement
{
    default isRotatableYaw = true;
    default isRotatablePitch = false;
    default isRotatableRoll = false;
}
// ----------------------------------------------------------------------------
state RadUi_WaypointEditing in CRadishQuestLayerWaypointMode extends RadUi_EntityEditing
{
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        entityEditor = new CRadishQuestLayerWaypointEditor in this;
        entity = parent.itemManager.getSelected();

        super.setupLabels("Waypoint");
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        if (unlocked) {
            hotkeyList.PushBack(HotkeyHelp_from('RADUI_ChangeSize', "RADUI_ChangeWanderpointRadius"));
        }
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_CycleAppearance', "RADUI_CycleAppearanceWaypoint"));
        super.OnEntityHotkeyHelp("Waypoint", hotkeyList);
    }
     // ------------------------------------------------------------------------
    event OnChangeSize(action: SInputAction) {
        if (unlocked && action.value != 0) {
            if (((CRadishQuestLayerWaypointEditor)entityEditor).expandRadius(action.value)) {
                entity.refreshRepresentation();
            }
        }
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();
        if (unlocked) {
            theInput.RegisterListener(this, 'OnChangeSize', 'RADUI_ChangeSize');
        } else {
            theInput.RegisterListener(parent, 'OnLockedMode', 'RADUI_ChangeSize');
        }
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        if (unlocked) {
            theInput.UnregisterListener(this, 'RADUI_ChangeSize');
        } else {
            theInput.UnregisterListener(parent, 'RADUI_ChangeSize');
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
state RadUi_WaypointManaging in CRadishQuestLayerWaypointMode extends RadUi_EntityManaging
{
    default editStateName = 'RadUi_WaypointEditing';
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        super.setupLabels("Waypoint");
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
         if (unlocked) {
            hotkeyList.PushBack(HotkeyHelp_from('RADUI_ChangeSize', "RADUI_ChangeWanderpointRadius"));
        }
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_CycleAppearance', "RADUI_CycleAppearanceWaypoint"));
        super.OnEntityHotkeyHelp("Waypoint", hotkeyList);
    }
    // ------------------------------------------------------------------------
    event OnChangeSize(action: SInputAction) {
        if (unlocked && action.value != 0) {
            if (((CRadishQuestLayerWanderpoint)parent.selectedEntity).expandRadius(action.value)) {
                parent.selectedEntity.refreshRepresentation();
            }
        }
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();
        if (unlocked) {
            theInput.RegisterListener(this, 'OnChangeSize', 'RADUI_ChangeSize');
        } else {
            theInput.RegisterListener(parent, 'OnLockedMode', 'RADUI_ChangeSize');
        }
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        if (unlocked) {
            theInput.UnregisterListener(this, 'RADUI_ChangeSize');
        } else {
            theInput.UnregisterListener(parent, 'RADUI_ChangeSize');
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// Top level management of Waypoints:
//  - Adding/Deleting/Renaming
//  - selecting current waypoint for editing and previewing
//
statemachine class CRadishQuestLayerWaypointMode extends CRadishQuestLayerEntityMode {
    default workMode = 'RADUI_QL_ModeWaypoints';
    default workContext = 'MOD_RadishUi_QL_ModeWaypoints';
    default generalHelpKey = "RADUI_WaypointGeneralHelp";
    default defaultState = 'RadUi_WaypointManaging';
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
