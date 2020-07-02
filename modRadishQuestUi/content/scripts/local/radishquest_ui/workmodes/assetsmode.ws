// ----------------------------------------------------------------------------
abstract state RadUi_BaseListSettingSelection in CRadishListViewWorkMode
    extends RadUi_FilteredListSelect
{
    protected var workContext: CName;
    // ------------------------------------------------------------------------
    protected var theCam: CRadishStaticCamera;
    // ------------------------------------------------------------------------
    protected var proxy: CRadishProxyRepresentation;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        theInput.StoreContext(workContext);

        // update fields if the menu is already open
        parent.view.listMenuRef.setTitle(parent.view.title);
        parent.view.listMenuRef.setStatsLabel(parent.view.statsLabel);

        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        theInput.RestoreContext(workContext, true);
        super.OnLeaveState(nextStateName);
    }
    // ------------------------------------------------------------------------
    event OnBack(action: SInputAction) {
        parent.backToPreviousState(action);
    }
    // ------------------------------------------------------------------------
    event OnChangeWorkMode(action: SInputAction) {
        // direct jump to top level required
        parent.backToParent(action);
    }
    // ------------------------------------------------------------------------
    event OnInteractiveCam(action: SInputAction) {
        if (IsReleased(action)) {
            parent.showUi(false);
            parent.PushState('RadUi_InteractiveCamera');
        }
    }
    // ------------------------------------------------------------------------
    event OnSwitchToEntityCam(action: SInputAction) {
        if (IsPressed(action)) {
            //parent.notice(GetLocStringByKeyExt("RADUI_iCamSwitchedTo") + selectedEntity.getName());
            adjustCam(proxy);
        }
    }
    // ------------------------------------------------------------------------
    event OnToggleCamFollow(action: SInputAction) {
        if (IsPressed(action)) {
            if (parent.config.isAutoCamOnSelect()) {
                parent.notice(GetLocStringByKeyExt("RADUI_iCamFollowOff"));
            } else {
                parent.notice(GetLocStringByKeyExt("RADUI_iCamFollowOn"));
                adjustCam(proxy);
            }
            parent.config.toggleAutoCamOnSelect();
        }
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SwitchToEntityCam'));
        hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleInteractiveCam', , IK_LControl));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ToggleCamFollowMode'));
    }
    // ------------------------------------------------------------------------
    protected function setupLabels(type: String, itemName: String) {
        parent.view.title = GetLocStringByKeyExt("RADUI_" + type + "Title") + " " + itemName;
        parent.view.statsLabel = GetLocStringByKeyExt("RADUI_" + type + "ListStats");
    }
    // ------------------------------------------------------------------------
    private entry function adjustCam(proxy: CRadishProxyRepresentation) {
        latentCamAdjust(proxy);
    }
    // ------------------------------------------------------------------------
    protected latent function latentCamAdjust(proxy: CRadishProxyRepresentation) {
        var frames: int;

        // wait some frames (at least one!) until asset is spawned (required on
        // changing asset template)
        while (frames < 30 && !proxy.hasValidSize()) {
            SleepOneFrame();
            // poll size
            proxy.getSize();
            frames += 1;
        }

        theCam.setSettings(RadUi_createCamSettingsFor(RadUiCam_EntityPreview, proxy));
        theCam.switchTo();
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();
        theInput.RegisterListener(this, 'OnInteractiveCam', 'RAD_ToggleInteractiveCam');
        theInput.RegisterListener(this, 'OnSwitchToEntityCam', 'RADUI_SwitchToEntityCam');
        theInput.RegisterListener(this, 'OnToggleCamFollow', 'RADUI_ToggleCamFollowMode');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        theInput.UnregisterListener(this, 'RAD_ToggleInteractiveCam');
        theInput.UnregisterListener(this, 'RADUI_SwitchToEntityCam');
        theInput.UnregisterListener(this, 'RADUI_ToggleCamFollowMode');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
