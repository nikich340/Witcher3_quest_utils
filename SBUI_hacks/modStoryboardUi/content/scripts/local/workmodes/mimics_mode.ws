// -----------------------------------------------------------------------------
//
// BUGS:
//
// TODO:
//
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
state SbUi_ActorMimics in CModStoryBoardMimicsMode extends SbUi_FilteredListSelect
{
    // ------------------------------------------------------------------------
    private var actor: CModStoryBoardActor;
    private var newMimics: SStoryBoardAnimationSettings;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        var shotSettings: SStoryBoardShotAssetSettings;

        parent.view.title = parent.getName();
        parent.view.statsLabel = GetLocStringByKeyExt("SBUI_SelectMimicsListTitle");
        // update fields if the menu is already open
        parent.view.listMenuRef.setTitle(parent.view.title);
        parent.view.listMenuRef.setStatsLabel(parent.view.statsLabel);

        actor = (CModStoryBoardActor)parent.assetManager.getSelectedAsset();
        listProvider = parent.mimicsListsManager.getAnimationListFor(actor);

        shotSettings = actor.getShotSettings();
        newMimics = shotSettings.mimics;

        listProvider.setSelection(newMimics.animId, true);

        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        super.OnHotkeyHelp(hotkeyList);

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ClearAnimation', "SBUI_ClearMimics"));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_Back', "SBUI_BackToActorOverview"));

        // allow switching between animations
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SelectPrev'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SelectNext'));

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ToggleSpecialWorkmodeCam', "SBUI_ToggleMimicsCamera"));
    }
    // ------------------------------------------------------------------------
    event OnSelected(optionId: String) {
        var animName: CName;
        var frames: int;

        if (listProvider.setSelection(optionId, true)) {

            // selection was a real animation and not a category opener/closer
            newMimics.animId = StringToInt(optionId);
            newMimics.animName = parent.mimicsListsManager.getAnimationName(newMimics.animId);
            actor.setMimicsAnimation(newMimics);

            if (parent.theAnimDirector.startMimicsForActor(actor))
            {
                if (optionId != "0") {
                    frames = parent.mimicsListsManager.getAnimationFrameCount(newMimics.animId);
                    parent.log.info("selected mimicsanim: "
                        + StrReplaceAll("mimicsanim_" + optionId + "_" + newMimics.animName, " ", "_")
                    );
                    parent.log.info(" animation duration: " + FloatToString(frames / 30.0) + " s");
                }
                parent.notice(GetLocStringByKeyExt("SBUI_iSelectedMimicsInfo")
                    + newMimics.animName);
            } else {
                // failed to start animation
                parent.error(GetLocStringByKeyExt("SBUI_iSelectedMimicsError")
                    + newMimics.animName);
            }
        }
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnResetAnim(action: SInputAction) {
        if (IsPressed(action)) {
            OnSelected("0");
        }
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();

        theInput.RegisterListener(this, 'OnBack', 'SBUI_AcceptChanges');
        theInput.RegisterListener(this, 'OnResetAnim', 'SBUI_ClearAnimation');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();

        theInput.UnregisterListener(this, 'SBUI_AcceptChanges');
        theInput.UnregisterListener(this, 'SBUI_ClearAnimation');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// Select asset (actor/item)
// rootstate == OnBack event triggers change to Overview Mode
state SbUi_MimicsActorSelection in CModStoryBoardMimicsMode
    extends SbUi_AssetSelection
{
    // ------------------------------------------------------------------------
    default listTitleKey = "SBUI_MimicsListTitle";
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        super.OnEnterState(prevStateName);

        theInput.RegisterListener(this, 'OnStartMimicsSelection', 'SBUI_SetupMimics');
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        theInput.UnregisterListener(this, 'SBUI_SetupMimics');

        super.OnLeaveState(nextStateName);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        super.OnHotkeyHelp(hotkeyList);

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SetupMimics'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SelectAsset', "SBUI_SelectForMimics"));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ToggleSpecialWorkmodeCam', "SBUI_ToggleMimicsCamera"));
    }
    // ------------------------------------------------------------------------
    event OnStartMimicsSelection(action: SInputAction) {
        if (IsPressed(action)) {
            parent.PushState('SbUi_ActorMimics');
        }
    }
    // ------------------------------------------------------------------------
    protected function switchToSpecialCam() {
        parent.OnSwitchToSpecialCam();
    }
    // ------------------------------------------------------------------------
    // overwrite to present only actors in list
    protected function updateView() {
        // provide info to override stats info in listview
        parent.view.listMenuRef.setListData(
            //assetManager.getAssetListWithExtendedInfo(),
            assetManager.getActorItemsList(),
            assetManager.getActorCount());

        parent.view.listMenuRef.updateView();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// Ui for selecting mimics animation of assets (actors only) for currently selected
// storyboard shot.
//  - changing currently selected asset
//  - providing special (predefined) toggle cam for viewing the asset in full
//  - selection of playback mimics animation
//
statemachine class CModStoryBoardMimicsMode extends CModStoryBoardAssetSelectionBasedWorkMode
{
    default workMode = 'SBUI_ModeMimics';
    default workContext = 'MOD_StoryBoardUi_ModeMimics';
    default generalHelpKey = "SBUI_MimicsGeneralHelp";
    default defaultState = 'SbUi_MimicsActorSelection';
    // ------------------------------------------------------------------------
    // manages the set of compatible animations to choose from
    protected var mimicsListsManager: CModStoryBoardMimicsListsManager;
    // re/starts/stops the animations for selected actor
    protected var theAnimDirector: CModStoryBoardAnimationDirector;
    // ------------------------------------------------------------------------
    public function init(storyboard: CModStoryBoard) {
        super.init(storyboard);

        mimicsListsManager = storyboard.getMimicsListsManager();

        theAnimDirector = shotViewer.getAnimationDirector();
    }
    // ------------------------------------------------------------------------
    public function activate(shot: CModStoryBoardShot) {
        super.activate(shot);

        mimicsListsManager.activate();
    }
    // ------------------------------------------------------------------------
    // overwrite to cycle only actors
    event OnCycleSelection(action: SInputAction) {
        var actorId: String;
        if (IsPressed(action)) {
            if (action.aName == 'SBUI_SelectPrev') {
                actorId = assetManager.getPreviousActorId();
            } else {
                actorId = assetManager.getNextActorId();
            }
            OnSelected(actorId);
        }
    }
    // ------------------------------------------------------------------------
    event OnSwitchToSpecialCam() {

        // change view to see currently selected asset
        shotViewer.switchCamTo(
            SBUI_createCamSettingsFor(
                SBUICam_MimicsPreview, assetManager.getSelectedAsset())
        );

    }
    // ------------------------------------------------------------------------
    public function storeSettings() {
        // Note: this overwrites *all* asset settings in the shot
        storyboard.storeCurrentAssetSettingsIn(shot);
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
