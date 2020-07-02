// ----------------------------------------------------------------------------
state RadUi_InteractivePlacement in CRadishQuestLayerMappinMode
    extends RadUi_BaseEntityInteractivePlacement
{
    default isRotatableYaw = false;
    default isRotatablePitch = false;
    default isRotatableRoll = false;
}
// ----------------------------------------------------------------------------
state RadUi_MappinEditing in CRadishQuestLayerMappinMode extends RadUi_EntityEditing
{
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        entityEditor = new CRadishQuestLayerMappinEditor in this;
        entity = parent.itemManager.getSelected();

        super.setupLabels("Mappin");
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        if (unlocked) {
            hotkeyList.PushBack(HotkeyHelp_from('RADUI_ChangeSize', "RADUI_ChangeMappinSize"));
        }
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_CycleAppearance', "RADUI_CycleAppearanceMappin"));
        super.OnEntityHotkeyHelp("Mappin", hotkeyList);
    }
    // ------------------------------------------------------------------------
    event OnChangeSize(action: SInputAction) {
        if (unlocked && action.value != 0) {
            if (((CRadishQuestLayerMappinEditor)entityEditor).expandRadius(action.value)) {
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
state RadUi_MappinManaging in CRadishQuestLayerMappinMode extends RadUi_EntityManaging
{
    default editStateName = 'RadUi_MappinEditing';
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        super.setupLabels("Mappin");
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        if (unlocked) {
            hotkeyList.PushBack(HotkeyHelp_from('RADUI_ChangeSize', "RADUI_ChangeMappinSize"));
        }
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_CycleAppearance', "RADUI_CycleAppearanceMappin"));
        super.OnEntityHotkeyHelp("Mappin", hotkeyList);
    }
    // ------------------------------------------------------------------------
    event OnChangeSize(action: SInputAction) {
        if (unlocked && action.value != 0) {
            if (((CRadishQuestLayerMappin)parent.selectedEntity).expandRadius(action.value)) {
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
// Top level management of Mappins
statemachine class CRadishQuestLayerMappinMode extends CRadishQuestLayerEntityMode {
    default workMode = 'RADUI_QL_ModeMappins';
    default workContext = 'MOD_RadishUi_QL_ModeMappins';
    default generalHelpKey = "RADUI_MappinGeneralHelp";
    default defaultState = 'RadUi_MappinManaging';
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
