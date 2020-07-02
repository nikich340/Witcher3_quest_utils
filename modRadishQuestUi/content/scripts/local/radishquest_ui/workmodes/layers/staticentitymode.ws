// ----------------------------------------------------------------------------
state RadUi_InteractivePlacement in CRadishQuestLayerStaticEntityMode
    extends RadUi_BaseEntityInteractivePlacement
{
    default isRotatableYaw = true;
    default isRotatablePitch = true;
    default isRotatableRoll = true;
}
// ----------------------------------------------------------------------------
state RadUi_StaticEntityEditing in CRadishQuestLayerStaticEntityMode extends RadUi_EntityEditing
{
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        entityEditor = new CRadishQuestLayerStaticEntityEditor in this;
        entity = parent.itemManager.getSelected();

        super.setupLabels("StaticEntity");
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        // only default static entities use the template hotkey
        if (unlocked && entity.getSpecialization() == "") {
            hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectTemplate', "RADUI_SelectStaticsTemplate"));
        }
        super.OnEntityHotkeyHelp("StaticEntity", hotkeyList);
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();
        // only default static entities use the template hotkey
        if (entity.getSpecialization() == "") {
            if (unlocked) {
                theInput.RegisterListener(parent, 'OnSelectTemplate', 'RADUI_SelectTemplate');
            } else {
                theInput.RegisterListener(parent, 'OnLockedMode', 'RADUI_SelectTemplate');
            }
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
state RadUi_StaticEntityManaging in CRadishQuestLayerStaticEntityMode extends RadUi_EntityManaging
{
    default editStateName = 'RadUi_StaticEntityEditing';
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        super.setupLabels("StaticEntity");
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        if (unlocked) {
            hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectTemplate', "RADUI_SelectStaticsTemplate"));
        }
        super.OnEntityHotkeyHelp("StaticEntity", hotkeyList);
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
// Top level management of StaticEntities
//
statemachine class CRadishQuestLayerStaticEntityMode extends CRadishQuestLayerEntityMode {
    default workMode = 'RADUI_QL_ModeStaticEntities';
    default workContext = 'MOD_RadishUi_QL_ModeStaticEntities';
    default generalHelpKey = "RADUI_StaticEntityGeneralHelp";
    default defaultState = 'RadUi_StaticEntityManaging';
    // ------------------------------------------------------------------------
    event OnSelectTemplate(action: SInputAction) {
        // only default static entities use the template hotkey
        if (selectedEntity.getSpecialization() == "") {
            if (unlocked && IsPressed(action) && itemManager.getSelected() && !view.listMenuRef.isEditActive()) {
                entityEditor = new CRadishQuestLayerStaticEntityEditor in this;
                itemManager.getSelected().highlight(true);
                entityEditor.init(log, itemManager.getSelected());
                entityEditor.select("template");
                PushState('RadUi_StaticsTemplateSelection');
            }
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
