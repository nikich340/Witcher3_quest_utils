// -----------------------------------------------------------------------------
//
// BUGS:
//
// TODO:
//
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
abstract state SbUi_AssetSelection in CModStoryBoardAssetSelectionBasedWorkMode
    extends SbUi_WorkModeRootState
{
    // ------------------------------------------------------------------------
    protected var listTitleKey: String;
    // alias to prevent using "parent." all the time
    protected var assetManager: CModStoryBoardAssetManager;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        parent.view.title = parent.getName();
        parent.view.statsLabel = GetLocStringByKeyExt(listTitleKey);
        // update fields if the menu is already open
        parent.view.listMenuRef.setTitle(parent.view.title);
        parent.view.listMenuRef.setStatsLabel(parent.view.statsLabel);

        parent.showUi(true);
        assetManager = parent.assetManager;
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        parent.OnHotkeyHelp(hotkeyList);

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SelectPrev'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SelectNext'));
    }
    // ------------------------------------------------------------------------
    event OnSelected(optionId: String) {
        var asset: CModStoryBoardAsset;
        if (assetManager.selectAsset(optionId)) {
            //TODO toggle some floating orb above selected asset?
            asset = assetManager.getSelectedAsset();

            parent.notice(GetLocStringByKeyExt("SBUI_iSelectedAssetInfo")
                + asset.getName());

            // special cam may be actor dependent -> update
            if (parent.isSpecialCamInUse) {
                switchToSpecialCam();
            }
        }

        updateView();

    }
    // ------------------------------------------------------------------------
    protected function switchToSpecialCam();
    // ------------------------------------------------------------------------
    event OnUpdateView() {
        updateView();
    }
    // ------------------------------------------------------------------------
    protected function updateView() {
        // assets are categorized => listSize != assetcount
        // provide info to override stats info in listview
        parent.view.listMenuRef.setListData(
            //assetManager.getAssetListWithExtendedInfo(),
            assetManager.getAssetItemsList(),
            assetManager.getAssetCount());

        parent.view.listMenuRef.updateView();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// abstract workmode class for modes with selection of an asset before doing the
// "real" work. provides the setup (keybinds) for selection.
//
abstract statemachine class CModStoryBoardAssetSelectionBasedWorkMode
    extends CModSbListViewWorkMode
{
    // ------------------------------------------------------------------------
    protected var defaultState: CName;
    // ------------------------------------------------------------------------
    protected var storyboard: CModStoryBoard;
    protected var shotViewer: CModStoryBoardShotViewer;
    protected var assetManager: CModStoryBoardAssetManager;
    // ------------------------------------------------------------------------
    protected var isSpecialCamInUse: bool;
    // ------------------------------------------------------------------------
    public function init(storyboard: CModStoryBoard) {
        super.init(storyboard);
        this.storyboard = storyboard;
        this.shotViewer = storyboard.getShotViewer();
        this.assetManager = storyboard.getAssetManager();
    }
    // ------------------------------------------------------------------------
    public function activate(shot: CModStoryBoardShot) {
        super.activate(shot);
        shotViewer.restoreShotCam();
        PushState(defaultState);

        // make sure an *actor* is selected
        // this is biased toward actors as in most workmodes (so far) only actors
        // can be selected
        if (!((CModStoryBoardActor)assetManager.getSelectedAsset())) {
            // select player actor
            assetManager.selectAsset(-1);
        }
    }
    // ------------------------------------------------------------------------
    public function deactivate() {
        // make sure active sub state is left properly (with its OnLeaveState
        // function)
        if (GetCurrentStateName() != defaultState) {
            GetCurrentState().OnLeaveState('null');
        }
        super.deactivate();
    }
    // ------------------------------------------------------------------------
    event OnCycleSelection(action: SInputAction) {
        var assetId: String;
        if (IsPressed(action)) {
            if (action.aName == 'SBUI_SelectPrev') {
                assetId = assetManager.getPreviousAssetId();
            } else {
                assetId = assetManager.getNextAssetId();
            }
            OnSelected(assetId);
        }
    }
    // ------------------------------------------------------------------------
    // specific events of all mode states
    event OnSelected(optionId: String) {}
    event OnSwitchToSpecialCam() {
        // Note: setting this to false in generic OnSwitchToSpecialCam
        // will "reset" switch and prevent toggle to shot cam
        // if sub state overwrites this event and sets another cam it doesn't
        // need to update this flag
        isSpecialCamInUse = false;
    }
    // ------------------------------------------------------------------------
    event OnToggleSpecialCam(action: SInputAction) {
        var interactivePlacementEntity : CModStoryBoardInteractivePlacement;

        if (IsPressed(action)) {
            if (!isSpecialCamInUse) {
                isSpecialCamInUse = true;
                OnSwitchToSpecialCam();
            } else {
                isSpecialCamInUse = false;
                shotViewer.restoreShotCam();
                notice(GetLocStringByKeyExt("SBUI_iBackToShotCam"));
            }

            // referencing "theController" entity in an easy way :)
            interactivePlacementEntity = (CModStoryBoardInteractivePlacement)theGame.GetEntityByTag('SBUI_PlacementModeEntity');
            interactivePlacementEntity.SetBirdsEye( isSpecialCamInUse );
        }
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();

        theInput.RegisterListener(this, 'OnCycleSelection', 'SBUI_SelectPrev');
        theInput.RegisterListener(this, 'OnCycleSelection', 'SBUI_SelectNext');
        theInput.RegisterListener(this, 'OnToggleSpecialCam', 'SBUI_ToggleSpecialWorkmodeCam');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();

        theInput.UnregisterListener(this, 'SBUI_SelectPrev');
        theInput.UnregisterListener(this, 'SBUI_SelectNext');
        theInput.UnregisterListener(this, 'SBUI_ToggleSpecialWorkmodeCam');
    }
    // ------------------------------------------------------------------------
    public function hasModifiedSettings() : bool {
        return true;
    }
    // ------------------------------------------------------------------------
    public function storeSettings();
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
