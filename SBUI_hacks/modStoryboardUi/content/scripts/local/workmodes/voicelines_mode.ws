// -----------------------------------------------------------------------------
//
// BUGS:
//
// TODO:
//
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
state SbUi_ActorLines in CModStoryBoardVoiceLinesMode extends SbUi_FilteredListSelect
{
    // ------------------------------------------------------------------------
    private var actor: CModStoryBoardActor;
    private var newVoiceLine: SStoryBoardAudioSettings;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        var shotSettings: SStoryBoardShotAssetSettings;

        parent.view.title = parent.getName();
        parent.view.statsLabel = GetLocStringByKeyExt("SBUI_SelectVoiceLinesListTitle");
        // update fields if the menu is already open
        parent.view.listMenuRef.setTitle(parent.view.title);
        parent.view.listMenuRef.setStatsLabel(parent.view.statsLabel);

        actor = (CModStoryBoardActor)parent.assetManager.getSelectedAsset();
        listProvider = parent.voiceLinesListsManager.getVoiceLinesList(actor);

        shotSettings = actor.getShotSettings();
        newVoiceLine = shotSettings.audio;

        listProvider.setSelection(newVoiceLine.lineId, true);

        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        super.OnHotkeyHelp(hotkeyList);

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ClearVoiceLine'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_Back', "SBUI_BackToActorOverview"));

        // allow switching between animations
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SelectPrev'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SelectNext'));

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ToggleSpecialWorkmodeCam', "SBUI_ToggleMimicsCamera"));
    }
    // ------------------------------------------------------------------------
    event OnSelected(optionId: String) {
        if (listProvider.setSelection(optionId, true)) {

            // selection was a real voiceline and not a category opener/closer
            newVoiceLine.lineId = StringToInt(optionId);
            newVoiceLine.duration = parent.voiceLinesListsManager.getDuration(optionId);

            actor.setVoiceLine(newVoiceLine);

            parent.theAudioDirector.startPlaybackForActor(actor);
            parent.notice(GetLocStringByKeyExt("SBUI_iSelectedVoiceLineInfo")
                + optionId);
        }
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnResetLine(action: SInputAction) {
        if (IsPressed(action)) {
            OnSelected("0");
        }
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();

        theInput.RegisterListener(this, 'OnBack', 'SBUI_AcceptChanges');
        theInput.RegisterListener(this, 'OnResetLine', 'SBUI_ClearVoiceLine');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();

        theInput.UnregisterListener(this, 'SBUI_AcceptChanges');
        theInput.UnregisterListener(this, 'SBUI_ClearVoiceLine');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// Select asset (actor/item)
// rootstate == OnBack event triggers change to Overview Mode
state SbUi_VoiceLinesActorSelection in CModStoryBoardVoiceLinesMode
    extends SbUi_AssetSelection
{
    // ------------------------------------------------------------------------
    default listTitleKey = "SBUI_VoiceLinesListTitle";
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        super.OnEnterState(prevStateName);

        theInput.RegisterListener(this, 'OnStartVoiceLinesSelection', 'SBUI_SetupVoiceLines');
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        theInput.UnregisterListener(this, 'SBUI_SetupVoiceLines');

        super.OnLeaveState(nextStateName);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        super.OnHotkeyHelp(hotkeyList);

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SetupVoiceLines'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SelectAsset', "SBUI_SelectForVoiceLines"));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ToggleSpecialWorkmodeCam', "SBUI_ToggleVoiceLinesCamera"));
    }
    // ------------------------------------------------------------------------
    event OnStartVoiceLinesSelection(action: SInputAction) {
        if (IsPressed(action)) {
            parent.PushState('SbUi_ActorLines');
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
// Ui for selecting voice lines of actors only for currently selected storyboard
// shot.
//  - changing currently selected asset
//  - providing special (predefined) toggle cam for close up viewing the actor
//  - selection of playback dialogline
//
statemachine class CModStoryBoardVoiceLinesMode extends CModStoryBoardAssetSelectionBasedWorkMode
{
    default workMode = 'SBUI_ModeVoiceLines';
    default workContext = 'MOD_StoryBoardUi_ModeVoiceLines';
    default generalHelpKey = "SBUI_VoiceLinesGeneralHelp";
    default defaultState = 'SbUi_VoiceLinesActorSelection';
    // ------------------------------------------------------------------------
    // manages the set of voicelines to choose from
    protected var voiceLinesListsManager: CModStoryBoardVoiceLinesListsManager;
    // re/starts/stops the audio lines for selected actor
    protected var theAudioDirector: CModStoryBoardAudioDirector;
    // ------------------------------------------------------------------------
    public function init(storyboard: CModStoryBoard) {
        super.init(storyboard);

        voiceLinesListsManager = storyboard.getVoiceLinesListsManager();

        theAudioDirector = shotViewer.getAudioDirector();
    }
    // ------------------------------------------------------------------------
    public function activate(shot: CModStoryBoardShot) {
        super.activate(shot);

        voiceLinesListsManager.activate();
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
                SBUICam_VoiceLinePreview, assetManager.getSelectedAsset())
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
