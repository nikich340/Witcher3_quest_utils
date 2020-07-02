// ----------------------------------------------------------------------------
abstract state RadUi_BaseInteractivePlacement in CRadishListViewWorkMode
    extends Rad_InteractivePlacement
{
    default workContext = 'MOD_RadishUi_ModePlacement';
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        super.OnEnterState(prevStateName);
        notice(GetLocStringByKeyExt("RAD_iPlacementInteractive"));
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        super.OnLeaveState(nextStateName);
        notice(GetLocStringByKeyExt("RAD_iPlacementInteractiveStop"));
    }
    // ------------------------------------------------------------------------
    protected function backToPreviousState(action: SInputAction) {
        parent.backToPreviousState(action);
    }
    // ------------------------------------------------------------------------
    protected function notice(msg: String) {
        parent.notice(msg);
    }
    // ------------------------------------------------------------------------
    event OnChangeWorkMode(action: SInputAction) {
        // direct jump to top level required
        parent.backToParent(action);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        super.OnHotkeyHelp(hotkeyList);
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_BackToTop', "RADUI_ModeLayers"));
        hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleInteractiveCam'));
    }
    // ------------------------------------------------------------------------
    event OnInteractiveCam(action: SInputAction) {
        if (IsReleased(action)) {
            parent.showUi(false);
            parent.PushState('RadUi_InteractiveCamera');
        }
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();
        theInput.RegisterListener(this, 'OnChangeWorkMode', 'RADUI_BackToTop');
        theInput.RegisterListener(this, 'OnCycleSelection', 'RADUI_SelectPrev');
        theInput.RegisterListener(this, 'OnCycleSelection', 'RADUI_SelectNext');
        theInput.RegisterListener(this, 'OnInteractiveCam', 'RAD_ToggleInteractiveCam');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        theInput.UnregisterListener(this, 'RADUI_BackToTop');
        theInput.UnregisterListener(this, 'RADUI_SelectPrev');
        theInput.UnregisterListener(this, 'RADUI_SelectNext');
        theInput.UnregisterListener(this, 'RAD_ToggleInteractiveCam');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
abstract state RadUi_BaseEntityInteractivePlacement in CRadishQuestLayerEntityMode
    extends RadUi_BaseInteractivePlacement
{
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        selectedElement = parent.selectedEntity;
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
        var selectedEntity: CRadishLayerEntity;

        if (IsPressed(action)) {
            parent.selectedEntity.highlight(false);

            if (action.aName == 'RADUI_SelectPrev') {
                selectedEntity = parent.itemManager.selectPrevious();
            } else {
                selectedEntity = parent.itemManager.selectNext();
            }
            selectedElement = selectedEntity;
            parent.selectedEntity = selectedEntity;

            // restart interactive mode for the new asset
            theController.stopInteractiveMode();
            theController.startInteractiveMode(selectedElement);

            parent.notice(GetLocStringByKeyExt("RADUI_iSelectedEntityInfo")
                + selectedEntity.getCaption());

            parent.selectedEntity.highlight(true);
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
