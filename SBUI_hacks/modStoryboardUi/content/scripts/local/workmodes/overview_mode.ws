// -----------------------------------------------------------------------------
//
// BUGS:
//  - rename to "" possible
//
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// Wires generic UI with Overview Controller
// ----------------------------------------------------------------------------
class CModSbWorkModePopupCallback extends IModUiConfirmPopupCallback {
    public var callback: CModStoryBoardWorkMode;

    public function OnConfirmed(action: String) {
        switch (action) {
            case "deleteShot":
                ((CModStoryBoardOverviewMode)callback).OnDeleteConfirm();
                break;

            case "deleteAsset":
                ((CModStoryBoardAssetWorkMode)callback).OnDeleteConfirm();
                break;

            case "resetScene":
                ((CModStoryBoardOverviewMode)callback).OnResetScene();
                break;
        }
    }
}
// ----------------------------------------------------------------------------
state SbUi_OverviewShotManaging in CModStoryBoardOverviewMode {
    // alias
    private var storyboard: CModStoryBoard;
    private var moveInsteadSwitch: Bool;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        storyboard = parent.storyboard;

        parent.view.title = parent.getName();
        parent.view.statsLabel = GetLocStringByKeyExt("SBUI_OverviewListTitle");
        parent.showUi(true);
        moveInsteadSwitch = false;
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        parent.OnHotkeyHelp(hotkeyList);

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_AddShot'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_DelShot'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_PrevShot'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_NextShot'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ToggleShotmovement'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_RenameShot'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_LogSceneDescription'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ResetScene'));
    }
    // ------------------------------------------------------------------------
    event OnAddNewShot(action: SInputAction) {
        if (IsPressed(action)) {
            storyboard.addNewShot();

            parent.notice(GetLocStringByKeyExt("SBUI_AddedShot"));
            updateView();
        }
    }
    // ------------------------------------------------------------------------
    event OnDeleteShot(action: SInputAction) {
        var msgTitle: String;
        var msgText: String;

        if (IsPressed(action)) {

            if (storyboard.getShotCount() > 1) {
                if (parent.confirmPopup) { delete parent.confirmPopup; }
                parent.confirmPopup = new CModUiActionConfirmation in parent;
                msgTitle = GetLocStringByKeyExt("SBUI_tOverviewConfirmPopup");
                msgText = GetLocStringByKeyExt("SBUI_mOverviewDelete");

                parent.confirmPopup.open(
                    parent.popupCallback, msgTitle, msgText, "deleteShot");
            } else {
                parent.error(GetLocStringByKeyExt("SBUI_eOverviewLastShotDelete"));
            }
        }
    }
    // ------------------------------------------------------------------------
    event OnShotChange(action: SInputAction) {
        if (IsPressed(action)) {
            if (moveInsteadSwitch) {
                switch (action.aName) {
                    case 'SBUI_PrevShot': storyboard.moveUpShot(); break;
                    case 'SBUI_NextShot': storyboard.moveDownShot(); break;
                }
            } else {
                switch (action.aName) {
                    case 'SBUI_PrevShot': storyboard.selectPrevShot(); break;
                    case 'SBUI_NextShot': storyboard.selectNextShot(); break;
                }
            }
            updateView();
        }
    }
    // ------------------------------------------------------------------------
    event OnToggleMovement(action: SInputAction) {
        if (IsPressed(action)) {
            moveInsteadSwitch = true;
        } else if (IsReleased(action)) {
            moveInsteadSwitch = false;
        }
    }
    // ------------------------------------------------------------------------
    event OnRename(action: SInputAction) {
        if (parent.isUiShown() && !parent.view.listMenuRef.isEditActive()
            && IsPressed(action))
        {
            parent.view.listMenuRef.startInputMode(
                GetLocStringByKeyExt("SBUI_lShotRename"),
                storyboard.getCurrentShot().getName());
        }
    }
    // ------------------------------------------------------------------------
    event OnDeleteConfirm() {
        storyboard.deleteCurrentShot();
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnInputEnd(inputString: String) {
        storyboard.getCurrentShot().setName(inputString);

        parent.view.listMenuRef.resetEditField();
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnInputCancel() {
        parent.notice(GetLocStringByKeyExt("UI_CanceledEdit"));

        parent.view.listMenuRef.resetEditField();
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnSelected(shotId: String) {
        // in this case it *should* be always a numerical shot id
        storyboard.selectShot(StringToInt(shotId));
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnUpdateView() {
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnConfirmResetScene(action: SInputAction) {
        var msgTitle: String;
        var msgText: String;

        if (IsPressed(action)) {
            if (parent.confirmPopup) { delete parent.confirmPopup; }
            parent.confirmPopup = new CModUiActionConfirmation in parent;
            msgTitle = GetLocStringByKeyExt("SBUI_tOverviewConfirmPopup");
            msgText = GetLocStringByKeyExt("SBUI_mResetScene");

            parent.confirmPopup.open(
                parent.popupCallback, msgTitle, msgText, "resetScene");
        }
    }
    // ------------------------------------------------------------------------
    event OnResetScene() {
        storyboard.resetScene();
        updateView();
    }
    // ------------------------------------------------------------------------
    private function updateView() {
        parent.view.listMenuRef.setListData(storyboard.getShotList());
        parent.view.listMenuRef.updateView();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
state SbUi_OverviewDeferredStart in CModStoryBoardOverviewMode {
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        deferredStart();
    }
    // ------------------------------------------------------------------------
    private entry function deferredStart() {
        var frames: int;

        // wait some frames (at least one!) until asset is spawned (required for
        // first start only)
        SleepOneFrame();
        while (frames < 5) {
            SleepOneFrame();
            frames += 1;
        }
        parent.storyboard.refreshViewer();
        parent.PushState('SbUi_OverviewShotManaging');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// Top level management of Storyboard Shots:
//  - Adding/Deleting/Renaming
//  - selecting current shot for editing and previewing
//  - storing all shot settings in log
//
statemachine class CModStoryBoardOverviewMode extends CModSbListViewWorkMode {
    default workMode = 'SBUI_ModeOverview';
    default workContext = 'MOD_StoryBoardUi_ModeOverview';
    default generalHelpKey = "SBUI_OverviewGeneralHelp";
    // ------------------------------------------------------------------------
    protected var storyboard: CModStoryBoard;
    // ------------------------------------------------------------------------
    public function init(storyboard: CModStoryBoard) {
        super.init(storyboard);
        this.storyboard = storyboard;
    }
    // ------------------------------------------------------------------------
    event OnWriteSceneDescr(action: SInputAction) {
        if (IsPressed(action)) {
            storyboard.saveW2SceneDescripton();
            notice(GetLocStringByKeyExt("SBUI_iW2SceneDescriptionLogged"));
        }
    }
    // ------------------------------------------------------------------------
    // specific events of all asset mode states
    event OnDeleteConfirm() {}
    // ------------------------------------------------------------------------
    event OnResetScene() {}
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();

        theInput.RegisterListener(this, 'OnAddNewShot', 'SBUI_AddShot');
        theInput.RegisterListener(this, 'OnDeleteShot', 'SBUI_DelShot');
        theInput.RegisterListener(this, 'OnShotChange', 'SBUI_PrevShot');
        theInput.RegisterListener(this, 'OnShotChange', 'SBUI_NextShot');
        theInput.RegisterListener(this, 'OnRename', 'SBUI_RenameShot');
        theInput.RegisterListener(this, 'OnToggleMovement', 'SBUI_ToggleShotmovement');
        theInput.RegisterListener(this, 'OnWriteSceneDescr', 'SBUI_LogSceneDescription');

        theInput.RegisterListener(this, 'OnConfirmResetScene', 'SBUI_ResetScene');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();

        theInput.UnregisterListener(this, 'SBUI_AddShot');
        theInput.UnregisterListener(this, 'SBUI_DelShot');
        theInput.UnregisterListener(this, 'SBUI_PrevShot');
        theInput.UnregisterListener(this, 'SBUI_NextShot');
        theInput.UnregisterListener(this, 'SBUI_RenameShot');
        theInput.UnregisterListener(this, 'SBUI_ToggleShotmovement');
        theInput.UnregisterListener(this, 'SBUI_LogSceneDescription');

        theInput.UnregisterListener(this, 'SBUI_ResetScene');
    }
    // ------------------------------------------------------------------------
    public function activate(shot: CModStoryBoardShot) {
        super.activate(shot);
        storyboard.getShotViewer().restoreShotCam();
        PushState('SbUi_OverviewShotManaging');
    }
    // ------------------------------------------------------------------------
    public function activateDeferred(shot: CModStoryBoardShot) {
        super.activate(shot);
        storyboard.getShotViewer().restoreShotCam();
        PushState('SbUi_OverviewDeferredStart');
    }
    // ------------------------------------------------------------------------
    public function hasModifiedSettings() : bool {
        // no shot based settings in overview mode
        return false;
    }
    // ------------------------------------------------------------------------
    public function storeSettings() {
        // no settings in overview mode
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
