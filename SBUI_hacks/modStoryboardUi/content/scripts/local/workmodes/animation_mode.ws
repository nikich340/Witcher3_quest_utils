// -----------------------------------------------------------------------------
//
// BUGS:
//
// TODO:
//
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// simple indicator for animation ends
class CModSbUiAnimModeAnimStateCallback extends IModSbUiAnimStateCallback {
    public function onAnimationStart() {
        theGame.GetGuiManager().ShowNotification(
            "anim start");
    }
    public function onAnimationEnd() {
        theGame.GetGuiManager().ShowNotification(
            GetLocStringByKeyExt("SBUI_iAnimationEnd"));
    }
}
// ----------------------------------------------------------------------------
state SbUi_ActorIdlePose in CModStoryBoardAnimationMode extends SbUi_FilteredListSelect
{
    // ------------------------------------------------------------------------
    private var actor: CModStoryBoardActor;
    private var newPose: SStoryBoardPoseSettings;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        var shotSettings: SStoryBoardShotAssetSettings;

        parent.view.title = parent.getName();
        parent.view.statsLabel = GetLocStringByKeyExt("SBUI_SelectPoseListTitle");
        // update fields if the menu is already open
        parent.view.listMenuRef.setTitle(parent.view.title);
        parent.view.listMenuRef.setStatsLabel(parent.view.statsLabel);

        actor = (CModStoryBoardActor)parent.assetManager.getSelectedAsset();
        listProvider = parent.poseListsManager.getIdlePoseListFor(actor);

        shotSettings = actor.getShotSettings();
        newPose = shotSettings.pose;

        listProvider.setSelection(newPose.idleAnimId, true);

        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        super.OnHotkeyHelp(hotkeyList);

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ClearPose'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_Back', "SBUI_BackToActorOverview"));

        // allow switching between poses
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SelectPrev'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SelectNext'));

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ToggleSpecialWorkmodeCam', "SBUI_ToggleAnimationCamera"));
    }
    // ------------------------------------------------------------------------
    event OnSelected(optionId: String) {
        if (listProvider.setSelection(optionId, true)) {

            // selection was a real animation and not a category opener/closer
            newPose.idleAnimId = StringToInt(optionId);
            newPose.idleAnimName =
                parent.poseListsManager.getIdleAnimationName(newPose.idleAnimId);

            actor.setIdlePose(newPose);

            if (parent.theAnimDirector.startIdlePoseForActor(actor)) {
                parent.notice(GetLocStringByKeyExt("SBUI_iSelectedPoseInfo")
                    + newPose.idleAnimName);
            } else {
                // failed to start animation
                parent.error(GetLocStringByKeyExt("SBUI_iSelectedPoseError")
                    + newPose.idleAnimName);
            }
        }
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnResetPose(action: SInputAction) {
        if (IsPressed(action)) {
            OnSelected("0");
        }
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();

        theInput.RegisterListener(this, 'OnBack', 'SBUI_AcceptChanges');
        theInput.RegisterListener(this, 'OnResetPose', 'SBUI_ClearPose');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();

        theInput.UnregisterListener(this, 'SBUI_AcceptChanges');
        theInput.UnregisterListener(this, 'SBUI_ClearPose');
    }
}
// ----------------------------------------------------------------------------
state SbUi_ActorAnimation in CModStoryBoardAnimationMode extends SbUi_FilteredListSelect
{
    // ------------------------------------------------------------------------
    private var actor: CModStoryBoardActor;
    private var newAnimation: SStoryBoardAnimationSettings;
    private var animStateCallback: CModSbUiAnimModeAnimStateCallback;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        var shotSettings: SStoryBoardShotAssetSettings;

        parent.view.title = parent.getName();
        parent.view.statsLabel = GetLocStringByKeyExt("SBUI_SelectAnimListTitle");
        // update fields if the menu is already open
        parent.view.listMenuRef.setTitle(parent.view.title);
        parent.view.listMenuRef.setStatsLabel(parent.view.statsLabel);

        actor = (CModStoryBoardActor)parent.assetManager.getSelectedAsset();
        listProvider = parent.animListsManager.getAnimationListFor(actor);

        shotSettings = actor.getShotSettings();
        newAnimation = shotSettings.animation;

        listProvider.setSelection(newAnimation.animId, true);

        animStateCallback = new CModSbUiAnimModeAnimStateCallback in this;

        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        super.OnHotkeyHelp(hotkeyList);

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ClearAnimation'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ClearActorItems'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ToggleActorCollision'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_Back', "SBUI_BackToActorOverview"));

        // allow switching between animations
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SelectPrev'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SelectNext'));

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ToggleSpecialWorkmodeCam', "SBUI_ToggleAnimationCamera"));
    }
    // ------------------------------------------------------------------------
    event OnSelected(optionId: String) {
        var frames: int;

        if (listProvider.setSelection(optionId, true)) {

            // selection was a real animation and not a category opener/closer
            newAnimation.animId = StringToInt(optionId);
            newAnimation.animName = parent.animListsManager.getAnimationName(newAnimation.animId);
            actor.setAnimation(newAnimation);

            if (parent.theAnimDirector.startAnimationForActor(actor, animStateCallback))
            {
                if (optionId != "0") {
                    frames = parent.animListsManager.getAnimationFrameCount(newAnimation.animId);
                    parent.log.info("selected animation: "
                        + StrReplaceAll("anim_" + optionId + "_" + newAnimation.animName, " ", "_")
                    );
                    parent.log.info("animation duration: " + FloatToString(frames / 30.0) + " s");
                }
                parent.notice(GetLocStringByKeyExt("SBUI_iSelectedAnimationInfo")
                    + newAnimation.animName);
            } else {
                // failed to start animation
                parent.error(GetLocStringByKeyExt("SBUI_iSelectedAnimationError")
                    + newAnimation.animName);
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
    event OnClearActorItems(action: SInputAction) {
        if (IsReleased(action)) {
            actor.resetItems();
        }
    }
    // ------------------------------------------------------------------------
    event OnToggleActorCollision(action: SInputAction) {
        var msgKey: String;
        if (IsReleased(action)) {
            newAnimation.enabledCollisions = !newAnimation.enabledCollisions;

            if (newAnimation.enabledCollisions) {
                msgKey = "SBUI_iAnimationCollisionOn";
            } else {
                msgKey = "SBUI_iAnimationCollisionOff";
            }
            parent.notice(GetLocStringByKeyExt(msgKey));
        }
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();

        theInput.RegisterListener(this, 'OnBack', 'SBUI_AcceptChanges');
        theInput.RegisterListener(this, 'OnResetAnim', 'SBUI_ClearAnimation');
        theInput.RegisterListener(this, 'OnClearActorItems', 'SBUI_ClearActorItems');
        theInput.RegisterListener(this, 'OnToggleActorCollision', 'SBUI_ToggleActorCollision');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();

        theInput.UnregisterListener(this, 'SBUI_AcceptChanges');
        theInput.UnregisterListener(this, 'SBUI_ClearAnimation');
        theInput.UnregisterListener(this, 'SBUI_ClearActorItems');
        theInput.UnregisterListener(this, 'SBUI_ToggleActorCollision');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// Select asset (actor/item)
// rootstate == OnBack event triggers change to Overview Mode
state SbUi_AnimationActorSelection in CModStoryBoardAnimationMode
    extends SbUi_AssetSelection
{
    // ------------------------------------------------------------------------
    default listTitleKey = "SBUI_AnimationListTitle";
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        super.OnEnterState(prevStateName);

        //thePlacementDirector.refreshPlacement();
        //animDirector.restartShotAnimations();

        theInput.RegisterListener(this, 'OnStartAnimationSelection', 'SBUI_SetupAnimation');
        theInput.RegisterListener(this, 'OnStartPoseSelection', 'SBUI_SetupPose');
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        theInput.UnregisterListener(this, 'SBUI_SetupAnimation');
        theInput.UnregisterListener(this, 'SBUI_SetupPose');

        super.OnLeaveState(nextStateName);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        super.OnHotkeyHelp(hotkeyList);

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SetupAnimation'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SetupPose'));

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SelectAsset', "SBUI_SelectForAnimation"));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ToggleSpecialWorkmodeCam', "SBUI_ToggleAnimationCamera"));
    }
    // ------------------------------------------------------------------------
    event OnStartAnimationSelection(action: SInputAction) {
        if (IsPressed(action)) {
            parent.PushState('SbUi_ActorAnimation');
        }
    }
    // ------------------------------------------------------------------------
    event OnStartPoseSelection(action: SInputAction) {
        if (IsPressed(action)) {
            parent.PushState('SbUi_ActorIdlePose');
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
// Ui for selecting animation of assets (actors only) for currently selected
// storyboard shot.
//  - changing currently selected asset
//  - providing special (predefined) toggle cam for viewing the asset in full
//  - selection of playback animation
//  - selection of idle pose (animation)
//
statemachine class CModStoryBoardAnimationMode extends CModStoryBoardAssetSelectionBasedWorkMode
{
    default workMode = 'SBUI_ModeAnimation';
    default workContext = 'MOD_StoryBoardUi_ModeAnimation';
    default generalHelpKey = "SBUI_AnimationGeneralHelp";
    default defaultState = 'SbUi_AnimationActorSelection';
    // ------------------------------------------------------------------------
    // manages the set of compatible animations to choose from
    protected var animListsManager: CModStoryBoardAnimationListsManager;
    // manages the set of compatible idle poses to choose from
    protected var poseListsManager: CModStoryBoardIdlePoseListsManager;
    // re/starts/stops/previews the animations/idles pose for selected actor
    protected var theAnimDirector: CModStoryBoardAnimationDirector;
    // ------------------------------------------------------------------------
    public function init(storyboard: CModStoryBoard) {
        super.init(storyboard);

        animListsManager = storyboard.getAnimationListsManager();
        poseListsManager = storyboard.getIdlePoseListsManager();

        theAnimDirector = shotViewer.getAnimationDirector();
    }
    // ------------------------------------------------------------------------
    public function activate(shot: CModStoryBoardShot) {
        super.activate(shot);

        animListsManager.activate();
        poseListsManager.activate();
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
                SBUICam_AnimationPreview, assetManager.getSelectedAsset())
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
