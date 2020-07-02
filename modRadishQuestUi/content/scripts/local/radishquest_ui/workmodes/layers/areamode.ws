// ----------------------------------------------------------------------------
state RadUi_InteractivePlacement in CRadishQuestLayerAreaMode
    extends RadUi_BaseEntityInteractivePlacement
{
    default isRotatableYaw = false;
    default isRotatablePitch = false;
    default isRotatableRoll = false;
}
// ----------------------------------------------------------------------------
state RadUi_InteractiveBorderpointPlacement in CRadishQuestLayerAreaMode
    extends RadUi_BaseInteractivePlacement
{
    default workContext = 'MOD_RadishUi_QL_ModeBorderpointPlacement';
    default isGroundSnapable = false;
    default snapToGround = false;
    default isUpDownMoveable = false;
    default isRotatableYaw = false;
    default isRotatablePitch = false;
    default isRotatableRoll = false;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        selectedElement = parent.areaEditor.getSelectedBorderpoint();
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    protected function createInteractivePlacement() : CRadishInteractivePlacement {
        var camPlacement: SRadishPlacement;

        camPlacement = parent.itemManager.getCamPlacement();

        return createAndSetupInteractivePlacement(parent.config, camPlacement.rot.Yaw);
    }
    // ------------------------------------------------------------------------
    event OnCycleSelection(action: SInputAction) {
        if (IsPressed(action)) {
            theController.stopInteractiveMode();
            if (action.aName == 'RADUI_SelectPrev') {
                parent.areaEditor.selectPreviousBorderpoint();
            } else {
                parent.areaEditor.selectNextBorderpoint();
            }
            // restart to readjust the placement settings
            theController.startInteractiveMode(selectedElement);
        }
    }
    // ------------------------------------------------------------------------
    event OnChangeSize(action: SInputAction) {
        if (action.value != 0) {
            theController.stopInteractiveMode();
            if (parent.areaEditor.expandBorder(action.value)) {
                parent.selectedEntity.refreshRepresentation();
            }
            // restart to readjust the placement settings
            theController.startInteractiveMode(selectedElement);
        }
    }
    // ------------------------------------------------------------------------
    event OnManageBorder(action: SInputAction) {
        var isUpdated: bool;
        var bpCount: int;

        if (IsPressed(action)) {
            theController.stopInteractiveMode();
            bpCount = ((CRadishQuestLayerArea)parent.selectedEntity).getBorderpointCount();
            switch (action.aName) {
                case 'RADUI_AddBorderPoint':
                    if (bpCount < 32) {
                        isUpdated = parent.areaEditor.addBorderpoint();
                    } else {
                        parent.error(GetLocStringByKeyExt("RADUI_eMaxBorderpoints") + 32);
                    }
                    break;

                case 'RADUI_DeleteBorderPoint':
                    if (bpCount > 4) {
                        isUpdated = parent.areaEditor.deleteBorderpoint();
                    } else {
                        parent.error(GetLocStringByKeyExt("RADUI_eMinBorderpoints") + 4);
                    }
                    break;
            }
            if (isUpdated) {
                parent.selectedEntity.refreshRepresentation();
            }
            // restart to readjust the placement settings
            theController.startInteractiveMode(selectedElement);
        }
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ChangeSize', "RADUI_ChangeAreaSize"));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_AddBorderPoint'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_DeleteBorderPoint'));
        super.OnHotkeyHelp(hotkeyList);
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();
        theInput.RegisterListener(this, 'OnChangeSize', 'RADUI_ChangeSize');
        theInput.RegisterListener(this, 'OnManageBorder', 'RADUI_AddBorderPoint');
        theInput.RegisterListener(this, 'OnManageBorder', 'RADUI_DeleteBorderPoint');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        theInput.UnregisterListener(this, 'RADUI_ChangeSize');
        theInput.UnregisterListener(this, 'RADUI_AddBorderPoint');
        theInput.UnregisterListener(this, 'RADUI_DeleteBorderPoint');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
state RadUi_AreaEditing in CRadishQuestLayerAreaMode extends RadUi_EntityEditing
{
    // ------------------------------------------------------------------------
    // alias for selected editor (so casting is not required for specialized area
    // operations)
    protected var areaEditor: CRadishQuestLayerAreaEditor;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        areaEditor = parent.areaEditor;
        entityEditor = areaEditor;
        entity = parent.itemManager.getSelected();

        super.setupLabels("Area");
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        // cleanup
        if (nextStateName != 'RadUi_InteractiveBorderpointPlacement') {
            areaEditor.deselectBorderpoint();
        }
        super.OnLeaveState(nextStateName);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        if (unlocked) {
            hotkeyList.PushBack(HotkeyHelp_from('RADUI_AddBorderPoint'));
            hotkeyList.PushBack(HotkeyHelp_from('RADUI_DeleteBorderPoint'));
            hotkeyList.PushBack(HotkeyHelp_from('RADUI_ChangeSize', "RADUI_ChangeAreaSize"));
        }
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_CycleAppearance', "RADUI_CycleAppearanceArea"));

        super.OnEntityHotkeyHelp("Area", hotkeyList);
    }
    // ------------------------------------------------------------------------
    event OnChangeSize(action: SInputAction) {
        if (unlocked && action.value != 0) {
            if (areaEditor.expandBorder(action.value)) {
                entity.refreshRepresentation();
            }
        }
    }
    // ------------------------------------------------------------------------
    event OnManageBorder(action: SInputAction) {
        var isUpdated: bool;
        var bpCount: int;

        if (unlocked && IsPressed(action)) {
            bpCount = ((CRadishQuestLayerArea)entity).getBorderpointCount();
            switch (action.aName) {
                case 'RADUI_AddBorderPoint':
                    if (bpCount < 32) {
                        isUpdated = areaEditor.addBorderpoint();
                    } else {
                        parent.error(GetLocStringByKeyExt("RADUI_eMaxBorderpoints") + 32);
                    }
                    break;

                case 'RADUI_DeleteBorderPoint':
                    if (bpCount > 4) {
                        isUpdated = areaEditor.deleteBorderpoint();
                    } else {
                        parent.error(GetLocStringByKeyExt("RADUI_eMinBorderpoints") + 4);
                    }
                    break;
            }
            if (isUpdated) {
                entity.refreshRepresentation();
                updateView();
            }
        }
    }
    // ------------------------------------------------------------------------
    event OnSelected(selectedId: String) {
        super.OnSelected(selectedId);
        areaEditor.getSelectedBorderpoint().show(areaEditor.isBorderpointSelected());
    }
    // ------------------------------------------------------------------------
    event OnInteractivePlacement(action: SInputAction) {
        if (unlocked && IsReleased(action)) {
            if (!areaEditor.isBorderpointSelected()) {
                areaEditor.selectNextBorderpoint();
            }
            parent.showUi(false);
            parent.PushState('RadUi_InteractiveBorderpointPlacement');
        }
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();
        if (unlocked) {
            theInput.RegisterListener(this, 'OnChangeSize', 'RADUI_ChangeSize');
            theInput.RegisterListener(this, 'OnManageBorder', 'RADUI_AddBorderPoint');
            theInput.RegisterListener(this, 'OnManageBorder', 'RADUI_DeleteBorderPoint');
            theInput.RegisterListener(this, 'OnInteractivePlacement', 'RAD_ToggleInteractivePlacement');
        } else {
            theInput.RegisterListener(parent, 'OnLockedMode', 'RADUI_ChangeSize');
            theInput.RegisterListener(parent, 'OnLockedMode', 'RADUI_AddBorderPoint');
            theInput.RegisterListener(parent, 'OnLockedMode', 'RADUI_DeleteBorderPoint');
            theInput.RegisterListener(parent, 'OnLockedMode', 'RAD_ToggleInteractivePlacement');
        }
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        if (unlocked) {
            theInput.UnregisterListener(this, 'RADUI_ChangeSize');
            theInput.UnregisterListener(this, 'RADUI_AddBorderPoint');
            theInput.UnregisterListener(this, 'RADUI_DeleteBorderPoint');
            theInput.UnregisterListener(this, 'RAD_ToggleInteractivePlacement');
        } else {
            theInput.UnregisterListener(parent, 'RADUI_ChangeSize');
            theInput.UnregisterListener(parent, 'RADUI_AddBorderPoint');
            theInput.UnregisterListener(parent, 'RADUI_DeleteBorderPoint');
            theInput.UnregisterListener(parent, 'RAD_ToggleInteractivePlacement');
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
state RadUi_AreaManaging in CRadishQuestLayerAreaMode extends RadUi_EntityManaging
{
    default editStateName = 'RadUi_AreaEditing';
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        super.setupLabels("Area");
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        if (unlocked) {
            hotkeyList.PushBack(HotkeyHelp_from('RADUI_ChangeSize', "RADUI_ChangeAreaSize"));
        }
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_CycleAppearance', "RADUI_CycleAppearanceArea"));
        super.OnEntityHotkeyHelp("Area", hotkeyList);
    }
    // ------------------------------------------------------------------------
    event OnChangeSize(action: SInputAction) {
        if (unlocked && action.value != 0) {
            if (((CRadishQuestLayerArea)selectedEntity).expandBorder(action.value)) {
                selectedEntity.refreshRepresentation();
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
// Top level management of layer areas:
//  - Adding/Deleting/Renaming
//  - selecting current layer area for editing and previewing
//
statemachine class CRadishQuestLayerAreaMode extends CRadishQuestLayerEntityMode {
    default workMode = 'RADUI_QL_ModeAreas';
    default workContext = 'MOD_RadishUi_QL_ModeAreas';
    default generalHelpKey = "RADUI_AreasGeneralHelp";
    default defaultState = 'RadUi_AreaManaging';
    // ------------------------------------------------------------------------
    protected var areaEditor: CRadishQuestLayerAreaEditor;
    // ------------------------------------------------------------------------
    public function init(itemManager: IRadishUiModeManager, config: CRadishQuestConfigManager)
    {
        super.init(itemManager, config);
        // areaeditor must survice state changes to enable selection of borderpoints
        // therefore it cannot be created in OnEnterState of areaEditing -> just
        // initialized with selected area
        areaEditor = new CRadishQuestLayerAreaEditor in this;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
