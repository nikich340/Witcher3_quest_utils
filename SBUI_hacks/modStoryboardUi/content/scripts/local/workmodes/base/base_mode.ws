// ----------------------------------------------------------------------------
// Workaround for missing input event triggering: simulate propagation of
// "back" event from a workmode
//
class CModSbUiParentCallback {
    public var callback: CModStoryBoardUi;

    public function OnBackToParent(action: SInputAction) {
        // default is always overview mode
        action.aName = 'SBUI_ModeOverview';

        callback.OnChangeWorkMode(action);
    }
}
// ----------------------------------------------------------------------------
abstract state SbUi_WorkModeRootState in CModStoryBoardWorkMode {

    event OnBack(action: SInputAction) {
        if (IsPressed(action)) {
            parent.parentCallback.OnBackToParent(action);
        }
    }

}
// ----------------------------------------------------------------------------
abstract statemachine class CModStoryBoardWorkMode {
    // Note: must be identical to switch action (to verify if this mode is
    // different from current mode)
    protected var workMode: CName;
    protected var workContext: CName; default workContext = 'MOD_StoryBoardUi';
    protected var generalHelpKey: String; default generalHelpKey = "NoHelpKey";

    protected var shot: CModStoryBoardShot;
    protected var log: CModLogger;

    protected var parentCallback: CModSbUiParentCallback;
    // ------------------------------------------------------------------------
    // workaround for missing input action event triggering
    public final function setParent(callback: CModSbUiParentCallback) {
        parentCallback = callback;
    }
    // ------------------------------------------------------------------------
    public function init(storyboard: CModStoryBoard) {
        log = new CModLogger in this;
        log.init(workContext, MLOG_DEBUG);
    }
    // ------------------------------------------------------------------------
    public function activate(shot: CModStoryBoardShot) {
        this.shot = shot;

        theInput.StoreContext(workContext);

        registerListeners();

        log.debug("started");

        // TODO display current mode in top right corner all the time (somehow)
        this.showModeInfo();
    }
    // ------------------------------------------------------------------------
    public function deactivate() {
        // hide all UI on deactivation
        showUi(false);
        unregisterListeners();
        theInput.RestoreContext(workContext, true);
    }
    // ------------------------------------------------------------------------
    public function showModeInfo() {
        this.notice(GetLocStringByKeyExt("SBUI_ModName") + " - " + getName());
    }
    // ------------------------------------------------------------------------
    public function hasModifiedSettings() : bool;
    public function storeSettings();
    // ------------------------------------------------------------------------
    public function getGeneralHelp() : String {
        return GetLocStringByKeyExt(generalHelpKey);
    }
    // ------------------------------------------------------------------------
    public function getId() : CName {
        return workMode;
    }
    // ------------------------------------------------------------------------
    public function getName() : String {
        return GetLocStringByKeyExt(NameToString(workMode) + "Name");
    }
    // ------------------------------------------------------------------------
    public function isUiShown() : bool;
    // ------------------------------------------------------------------------
    public function showUi(showUi: bool);
    // ------------------------------------------------------------------------
    protected function toggleUi() {
        showUi(!isUiShown());
    }
    // ------------------------------------------------------------------------
    protected function error(msg: String) {
        theGame.GetGuiManager().ShowNotification(msg);
    }
    // ------------------------------------------------------------------------
    protected function notice(msg: String) {
        theGame.GetGuiManager().ShowNotification(msg);
    }
    // ------------------------------------------------------------------------
    event OnToggleUi(action: SInputAction) {
        if (action.lastFrameValue == 0 && action.value == 1) {
            toggleUi();
        }
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        //TODO escape -> OnBAck? ctrl+s -> save?
        theInput.RegisterListener(this, 'OnToggleUi', 'SBUI_ToggleUi');
        theInput.RegisterListener(this, 'OnBack', 'SBUI_Back');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        theInput.UnregisterListener(this, 'SBUI_ToggleUi');
        theInput.UnregisterListener(this, 'SBUI_Back');
    }
    // ------------------------------------------------------------------------
    // required for all workmodes + states!
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ToggleUi'));
        //TODO Back hotkey help?
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
