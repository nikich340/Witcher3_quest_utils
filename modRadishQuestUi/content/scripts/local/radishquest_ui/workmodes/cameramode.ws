// ----------------------------------------------------------------------------
abstract state RadUi_BaseInteractiveCamera in CRadishListViewWorkMode extends Rad_InteractiveCamera
{
    default workContext = 'MOD_RadishUi_ModeInteractiveCam';
    // ------------------------------------------------------------------------
    protected function backToPreviousState(action: SInputAction) {
        parent.backToPreviousState(action);
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        super.OnLeaveState(nextStateName);
        parent.notice(GetLocStringByKeyExt("RAD_iCamInteractiveStop"));
    }
    // ------------------------------------------------------------------------
    event OnChangeWorkMode(action: SInputAction) {
        // direct jump to top level required
        parent.backToParent(action);
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();
        theInput.RegisterListener(this, 'OnChangeWorkMode', 'RADUI_BackToTop');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        theInput.UnregisterListener(this, 'RADUI_BackToTop');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
state RadUi_InteractiveCamera in CRadishQuestLayerEntityMode extends RadUi_BaseInteractiveCamera
{
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        if (parent.config.isAutoCamOnSelect()) {
            parent.config.setAutoCamOnSelect(false);
            parent.notice(
                GetLocStringByKeyExt("RAD_iCamInteractive") + " " +
                GetLocStringByKeyExt("RADUI_iCamFollowOff")
            );
        } else {
            parent.notice(GetLocStringByKeyExt("RAD_iCamInteractive"));
        }
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        // interactive cam MUST be stopped before changing to static cam!
        theCam.stopInteractiveMode();

        // reactivate the static cam *AFTER* destroying the interactive one
        parent.itemManager.switchCamTo(theCam.getActiveSettings());

        super.OnLeaveState(nextStateName);
    }
    // ------------------------------------------------------------------------
    protected function createCam() : CRadishInteractiveCamera {
        return createAndSetupInteractiveCam(
            parent.config, parent.itemManager.getCamPlacement(), parent.itemManager.getCamTracker());
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
state RadUi_InteractiveCamera in CRadishQuestLayerMode extends RadUi_BaseInteractiveCamera
{
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        if (parent.config.isAutoCamOnSelect()) {
            parent.config.setAutoCamOnSelect(false);
            parent.notice(
                GetLocStringByKeyExt("RAD_iCamInteractive") + " " +
                GetLocStringByKeyExt("RADUI_iCamFollowOff")
            );
        } else {
            parent.notice(GetLocStringByKeyExt("RAD_iCamInteractive"));
        }
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        // interactive cam MUST be stopped before changing to static cam!
        theCam.stopInteractiveMode();

        // reactivate the static cam *AFTER* destroying the interactive one
        parent.layerManager.getCam().setSettings(theCam.getActiveSettings());
        parent.layerManager.getCam().switchTo();

        super.OnLeaveState(nextStateName);
    }
    // ------------------------------------------------------------------------
    protected function createCam() : CRadishInteractiveCamera {
        var staticCam: CRadishStaticCamera;

        staticCam = parent.layerManager.getCam();
        return createAndSetupInteractiveCam(
            parent.config, staticCam.getActiveSettings(), staticCam.getTracker());
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
state RadUi_InteractiveCamera in CRadishQuestLayerSearchMode extends RadUi_BaseInteractiveCamera
{
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        if (parent.config.isAutoCamOnSelect()) {
            parent.config.setAutoCamOnSelect(false);
            parent.notice(
                GetLocStringByKeyExt("RAD_iCamInteractive") + " " +
                GetLocStringByKeyExt("RADUI_iCamFollowOff")
            );
        } else {
            parent.notice(GetLocStringByKeyExt("RAD_iCamInteractive"));
        }
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        // interactive cam MUST be stopped before changing to static cam!
        theCam.stopInteractiveMode();

        // reactivate the static cam *AFTER* destroying the interactive one
        parent.layerManager.getCam().setSettings(theCam.getActiveSettings());
        parent.layerManager.getCam().switchTo();

        super.OnLeaveState(nextStateName);
    }
    // ------------------------------------------------------------------------
    protected function createCam() : CRadishInteractiveCamera {
        var staticCam: CRadishStaticCamera;

        staticCam = parent.layerManager.getCam();
        return createAndSetupInteractiveCam(
            parent.config, staticCam.getActiveSettings(), staticCam.getTracker());
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
state RadUi_InteractiveCamera in CRadishCommunityMode extends RadUi_BaseInteractiveCamera
{
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        if (parent.config.isAutoCamOnSelect()) {
            parent.config.setAutoCamOnSelect(false);
            parent.notice(
                GetLocStringByKeyExt("RAD_iCamInteractive") + " " +
                GetLocStringByKeyExt("RADUI_iCamFollowOff")
            );
        } else {
            parent.notice(GetLocStringByKeyExt("RAD_iCamInteractive"));
        }

        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        // interactive cam MUST be stopped before changing to static cam!
        theCam.stopInteractiveMode();

        // reactivate the static cam *AFTER* destroying the interactive one
        parent.communityManager.getCam().setSettings(theCam.getActiveSettings());
        parent.communityManager.getCam().switchTo();

        super.OnLeaveState(nextStateName);
    }
    // ------------------------------------------------------------------------
    protected function createCam() : CRadishInteractiveCamera {
        var staticCam: CRadishStaticCamera;

        staticCam = parent.communityManager.getCam();
        return createAndSetupInteractiveCam(
            parent.config, staticCam.getActiveSettings(), staticCam.getTracker());
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
state RadUi_InteractiveCamera in CRadishCommunityElementMode extends RadUi_BaseInteractiveCamera
{
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        if (parent.config.isAutoCamOnSelect()) {
            parent.config.setAutoCamOnSelect(false);
            parent.notice(
                GetLocStringByKeyExt("RAD_iCamInteractive") + " " +
                GetLocStringByKeyExt("RADUI_iCamFollowOff")
            );
        } else {
            parent.notice(GetLocStringByKeyExt("RAD_iCamInteractive"));
        }
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        // interactive cam MUST be stopped before changing to static cam!
        theCam.stopInteractiveMode();

        // reactivate the static cam *AFTER* destroying the interactive one
        parent.itemEditor.switchCamTo(theCam.getActiveSettings());

        super.OnLeaveState(nextStateName);
    }
    // ------------------------------------------------------------------------
    protected function createCam() : CRadishInteractiveCamera {
        return createAndSetupInteractiveCam(
            parent.config, parent.itemEditor.getCamPlacement(), parent.itemEditor.getCamTracker());
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
