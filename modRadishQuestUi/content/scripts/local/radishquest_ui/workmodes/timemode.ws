// ----------------------------------------------------------------------------
state RadUi_InteractiveTime in CRadishListViewWorkMode
    extends Rad_InteractiveTime
{
    default workContext = 'MOD_RadishUi_ModeTime';
    // ------------------------------------------------------------------------
    default stepSizeFast = 120;
    default stepSizeNormal = 60;
    default stepSizeSlow = 15;
    // ------------------------------------------------------------------------
    private var topMenuConf: SModUiTopMenuConfig;
    private var mainMenuConf: SModUiMainMenuConfig;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        // this is a hack to force the generic listmenu to minimal display
        var empty: array<SModUiListItem>;

        topMenuConf = SModUiTopMenuConfig(
            40.0, 35.0, 37.0, 8.0, 25.0,        // x, y, width, height, alpha
            SModUiTextFieldConfig(              // title field:
                1, 37, 130, 25, 18                  // x, y, width, height, fontsize
            )
        );
        mainMenuConf = SModUiMainMenuConfig(0.0, 0.0, 0);

        super.OnEnterState(prevStateName);

        parent.showUi(true);
        if (parent.view.listMenuRef) {
            parent.view.listMenuRef.setTopMenuConfig(topMenuConf);
            parent.view.listMenuRef.setMainMenuConfig(mainMenuConf);
            parent.view.listMenuRef.setListData(empty);
            parent.view.listMenuRef.setupFields();
        }
        updateView();
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
    event OnInteractiveCam(action: SInputAction) {
        if (IsReleased(action)) {
            parent.showUi(false);
            parent.PushState('RadUi_InteractiveCamera');
        }
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        super.OnHotkeyHelp(hotkeyList);
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_BackToTop', "RADUI_ModeLayers"));
    }
    // ------------------------------------------------------------------------
    event OnUpdateView() {
        // called on opened (if menu was closed)
        parent.view.listMenuRef.setTopMenuConfig(topMenuConf);
        parent.view.listMenuRef.setMainMenuConfig(mainMenuConf);
        parent.view.listMenuRef.setupFields();
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnChangeTime(action: SInputAction) {
        super.OnChangeTime(action);
        updateView();
    }
    // ------------------------------------------------------------------------
    protected function updateView() {
        // this is a hack to reuse the default listmenu... should probably be a
        // separate hud menu type menu
        parent.view.listMenuRef.setTitle(GetLocStringByKeyExt("RADUI_lCurrentTime") + " " + getTimeCaption());
        parent.view.listMenuRef.setStatsLabel("");
        parent.view.listMenuRef.updateView();
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();
        theInput.RegisterListener(this, 'OnInteractiveCam', 'RAD_ToggleInteractiveCam');
        theInput.RegisterListener(this, 'OnChangeWorkMode', 'RADUI_BackToTop');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        theInput.UnregisterListener(this, 'RAD_ToggleInteractiveCam');
        theInput.UnregisterListener(this, 'RADUI_BackToTop');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
