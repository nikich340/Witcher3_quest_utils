// ----------------------------------------------------------------------------
// Workaround for missing input event triggering: simulate propagation of
// "back" event from a workmode
//
abstract class IRadUiParentCallback extends IScriptable {
    public function onBackFromChild(action: SInputAction);
}
// ----------------------------------------------------------------------------
state RadUi_WaitForSubmodeEnd in CRadishWorkMode {}
// ----------------------------------------------------------------------------
abstract state RadUi_WorkModeRootState in CRadishWorkMode {
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        //LogChannel('ROOTSTATE', "OnEnterState: "+ prevStateName + "->" + parent.GetCurrentStateName());
        registerListeners();
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        unregisterListeners();
        //LogChannel('ROOTSTATE', "OnLeaveState: " + parent.GetCurrentStateName() + "->" + nextStateName);
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        theInput.RegisterListener(this, 'OnBack', 'RADUI_Back');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        theInput.UnregisterListener(this, 'RADUI_Back');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
state RadUi_PauseState in CRadishWorkMode {}
// ----------------------------------------------------------------------------
abstract statemachine class CRadishWorkMode extends IRadUiParentCallback {
    // Note: must be identical to switch action (to verify if this mode is
    // different from current mode)
    protected var workMode: CName;
    protected var workContext: CName; default workContext = 'MOD_RadishQuestUi';
    protected var generalHelpKey: String; default generalHelpKey = "NoHelpKey";

    protected var log: CModLogger;

    protected var parentCallback: IRadUiParentCallback;
    protected var config: CRadishQuestConfigManager;
    // ------------------------------------------------------------------------
    // workaround for missing input action event triggering
    public final function setParent(callback: IRadUiParentCallback) {
        parentCallback = callback;
    }
    // ------------------------------------------------------------------------
    public function init(modeManager: IRadishUiModeManager, config: CRadishQuestConfigManager)
    {
        log = new CModLogger in this;
        this.config = config;
        log.init(workContext, MLOG_DEBUG);
        log.debug("initialized");
    }
    // ------------------------------------------------------------------------
    public function activate() {
        theInput.StoreContext(workContext);
        this.showModeInfo();
    }
    // ------------------------------------------------------------------------
    public function deactivate() {
        // make sure active sub state is left properly (with its OnLeaveState
        // function)
        if (GetCurrentStateName() != 'None') {
            GetCurrentState().OnLeaveState('null');
        }
        PopState(true);
        theInput.RestoreContext(workContext, true);
    }
    // ------------------------------------------------------------------------
    public function pause() {
        if (GetCurrentStateName() != 'RadUi_PauseState') {
            PushState('RadUi_PauseState');
        }
    }
    // ------------------------------------------------------------------------
    public function unpause() {
        if (IsInState('RadUi_PauseState')) {
            PopState();
        }
    }
    // ------------------------------------------------------------------------
    public function showModeInfo() {
        this.notice(GetLocStringByKeyExt("RADUI_ModName") + " - " + getName());
    }
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
    public function getStateName() : String {
        return GetLocStringByKeyExt(NameToString(GetCurrentStateName()));
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
    protected function backToParent(action: SInputAction) {
        if (IsReleased(action)) {
            parentCallback.onBackFromChild(action);
        }
    }
    // ------------------------------------------------------------------------
    // required for all workmodes + states!
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ToggleUi'));
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
