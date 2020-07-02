// ----------------------------------------------------------------------------
state RadUi_InteractivePlacement in CRadishQuestLayerInteractiveEntityMode
    extends RadUi_BaseEntityInteractivePlacement
{
    default isRotatableYaw = true;
    default isRotatablePitch = true;
    default isRotatableRoll = true;
}
// ----------------------------------------------------------------------------
state RadUi_InteractiveEntityEditing in CRadishQuestLayerInteractiveEntityMode extends RadUi_EntityEditing
{
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        entityEditor = new CRadishQuestLayerInteractiveEntityEditor in this;
        entity = parent.itemManager.getSelected();

        super.setupLabels("InteractiveEntity");
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        if (unlocked) {
            hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectTemplate', "RADUI_SelectInteractivesTemplate"));
        }
        super.OnEntityHotkeyHelp("InteractiveEntity", hotkeyList);
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();
        if (unlocked) {
            theInput.RegisterListener(parent, 'OnSelectTemplate', 'RADUI_SelectTemplate');
        } else {
            theInput.RegisterListener(parent, 'OnLockedMode', 'RADUI_SelectTemplate');
        }
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        theInput.UnregisterListener(parent, 'RADUI_SelectTemplate');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
state RadUi_InteractiveEntityManaging in CRadishQuestLayerInteractiveEntityMode extends RadUi_EntityManaging
{
    default editStateName = 'RadUi_InteractiveEntityEditing';
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        super.setupLabels("InteractiveEntity");
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        if (unlocked) {
            hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectTemplate', "RADUI_SelectInteractivesTemplate"));
        }
        super.OnEntityHotkeyHelp("InteractiveEntity", hotkeyList);
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();
        if (unlocked) {
            theInput.RegisterListener(parent, 'OnSelectTemplate', 'RADUI_SelectTemplate');
        } else {
            theInput.RegisterListener(parent, 'OnLockedMode', 'RADUI_SelectTemplate');
        }
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        theInput.UnregisterListener(parent, 'RADUI_SelectTemplate');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// Top level management of InteractiveEntities
//
statemachine class CRadishQuestLayerInteractiveEntityMode extends CRadishQuestLayerEntityMode {
    default workMode = 'RADUI_QL_ModeInteractiveEntities';
    default workContext = 'MOD_RadishUi_QL_ModeInteractiveEntities';
    default generalHelpKey = "RADUI_InteractiveEntityGeneralHelp";
    default defaultState = 'RadUi_InteractiveEntityManaging';
    // ------------------------------------------------------------------------
    event OnSelectTemplate(action: SInputAction) {
        if (unlocked && IsPressed(action) && itemManager.getSelected() && !view.listMenuRef.isEditActive()) {
            entityEditor = new CRadishQuestLayerInteractiveEntityEditor in this;
            itemManager.getSelected().highlight(true);
            entityEditor.init(log, itemManager.getSelected());
            entityEditor.select("template");
            PushState('RadUi_InteractivesTemplateSelection');
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
