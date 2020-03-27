// -----------------------------------------------------------------------------
//
// BUGS:
//
// TODO:
//
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
class CModStoryBoardInteractiveLookAt extends CEntity {
    // ------------------------------------------------------------------------
    private var lookAtDirector: CModStoryBoardLookAtDirector;
    // ------------------------------------------------------------------------
    private var actor: CModStoryBoardActor;
    private var lookAt: SStoryBoardLookAtSettings;
    // ------------------------------------------------------------------------
    private var isInteractiveMode: bool;

    private var distance: float; default distance = 1.0;
    private var stepRotSize: float; default stepRotSize = 0.075;
    // ------------------------------------------------------------------------
    public function init(director: CModStoryBoardLookAtDirector) {
        lookAtDirector = director;
    }
    // ------------------------------------------------------------------------
    private function refreshActorSettings() {
        var shotSettings: SStoryBoardShotAssetSettings;

        shotSettings = actor.getShotSettings();
        lookAt = shotSettings.lookAt;
        distance = lookAt.distance;

        lookAtDirector.showStaticPoint(actor);
    }
    // ------------------------------------------------------------------------
    public function isActive() : bool {
        return isInteractiveMode;
    }
    // ------------------------------------------------------------------------
    public function startInteractiveMode(selectedActor: CModStoryBoardActor) {
        if (!isInteractiveMode) {

            actor = selectedActor;
            refreshActorSettings();

            // repeats & overrideExisting = true
            AddTimer('updateInteractiveSettings', 0.015f, true, , , , true);
            isInteractiveMode = true;
        }
    }
    // ------------------------------------------------------------------------
    public function stopInteractiveMode() {
        RemoveTimer('updateInteractiveSettings');
        isInteractiveMode = false;
    }
    // ------------------------------------------------------------------------
    timer function updateInteractiveSettings(deltaTime: float, id: int) {
        var newLookAt: SStoryBoardLookAtSettings;
        var newPos: Vector;
        var directionFB, directionLR: float;
        var moveFB, moveLR, moveUD: float;
        var rotateLR, rotateUD: float;

        rotateLR = theInput.GetActionValue('GI_MouseDampX');
        rotateUD = theInput.GetActionValue('GI_MouseDampY');

        if (rotateLR != 0 || rotateUD != 0 || lookAt.distance != distance) {

            if (!actor.isStaticLookAt()) {
                // it's possible user switched multiple times to look at another
                // actor -> switch to static based on last look at
                lookAt = lookAtDirector.getStaticLookAtPosition(actor);
                distance = MaxF(0.5, lookAt.distance);
                lookAtDirector.showStaticPoint(actor, true);

                theGame.GetGuiManager().ShowNotification(
                    GetLocStringByKeyExt("SBUI_iLookAtStaticPoint"));
            }
            newLookAt = lookAt;
            newLookAt.distance = distance;

            newLookAt.rot.Pitch = ClampF(lookAt.rot.Pitch - rotateUD * stepRotSize, -75, 75);
            newLookAt.rot.Yaw = ClampF(lookAt.rot.Yaw - rotateLR * stepRotSize, -110, 110);

            // trigger controller refresh
            lookAtDirector.repositionStaticLookAt(actor, newLookAt);

            lookAt = newLookAt;
        }
    }
    // ------------------------------------------------------------------------
    public function setStepSize(rot: float) {
        stepRotSize = rot;
    }
    // ------------------------------------------------------------------------
    public function getStepSize() : float {
        return stepRotSize;
    }
    // ------------------------------------------------------------------------
    public function setLookAtDistance(newDistance: float) {
        distance = MaxF(0.5, newDistance);
    }
    // ------------------------------------------------------------------------
    public function getLookAtDistance() : float {
        return distance;
    }
    // ------------------------------------------------------------------------
}

state SbUi_ActorLookAt in CModStoryBoardLookAtMode {
    // ------------------------------------------------------------------------
    private var rotateStepSize: float;
    private var lookAtDistance: float;
    // ------------------------------------------------------------------------
    private var newLookAt: SStoryBoardLookAtSettings;
    private var actor: CModStoryBoardActor;

    private var lastLookedAtAssetId: String;
    // alias
    private var theController: CModStoryBoardInteractiveLookAt;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        parent.showUi(false);
        // TODO: freeze assets (e.g. animations)

        theController = parent.theController;
        rotateStepSize = theController.getStepSize();
        lookAtDistance = theController.getLookAtDistance();

        startInteractiveMode();
        registerListeners();
    }
   // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        theController.stopInteractiveMode();

        unregisterListeners();
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        parent.OnHotkeyHelp(hotkeyList);

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_Back', "SBUI_BackToOverview"));

        hotkeyList.PushBack(HotkeyHelp_from('GI_MouseDampX', "SBUI_AssetMoveLeftRight"));
        hotkeyList.PushBack(HotkeyHelp_from('GI_MouseDampY', "SBUI_AssetMoveForwardBack"));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ActorCycleLookAtActor'));

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_AcceptChanges', "SBUI_AcceptLookAt"));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ClearLookAt'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_AdjustLootAtDistance'));

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SelectPrev'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SelectNext'));

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ToggleSpecialWorkmodeCam', "SBUI_ToggleLookAtCamera"));

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ControlStepSize'));
    }
    // ------------------------------------------------------------------------
    event OnCycleAutoLookAt(action: SInputAction) {
        var lookedAtAsset: CModStoryBoardAsset;

        if (IsPressed(action) && actor) {

            lastLookedAtAssetId = parent.assetManager.getNextInteractionActorId(
                actor.getId(), lastLookedAtAssetId);

            // make sure there is another one
            if (lastLookedAtAssetId != actor.getId()) {

                newLookAt.enabled = true;
                newLookAt.lookAtActor = lastLookedAtAssetId;
                // disable look at for a moment because sometimes when an actor
                // is looking at another actor its "dynamic" rotation prevents
                // "seeing" the selected actor. by disabling lookat it turns back
                // towards it's normal position and may see the selected actor
                actor.disableLookAt();
                actor.setLookAt(newLookAt);

                // trigger controller to adjust current actor look at
                parent.theLookAtDirector.refreshLookAtForActor(actor);
                parent.theLookAtDirector.hideStaticPoint(actor);

                // info
                lookedAtAsset = parent.assetManager.getAsset(lastLookedAtAssetId);
                parent.notice(GetLocStringByKeyExt("SBUI_iLookAtActor") +
                    lookedAtAsset.getName());
            }

        }
    }
    // ------------------------------------------------------------------------
    event OnSelected(optionId: String) {

        theController.stopInteractiveMode();

        // currently static point for currently selected actor
        // Note: starting interactive mode will show static point for newly
        // selected actor on its own
        parent.theLookAtDirector.hideStaticPoint(actor);
        parent.assetManager.selectAsset(optionId);

        // restart interactive mode for the new asset
        startInteractiveMode();

        parent.notice(GetLocStringByKeyExt("SBUI_iSelectedAssetInfo")
                + parent.assetManager.getSelectedAsset().getName());
    }
    // ------------------------------------------------------------------------
    event OnChangeSpeed(action: SInputAction) {
        if (action.value != 0) {

            if (action.value > 0) {
                if (rotateStepSize < 0.25)   { rotateStepSize *= 1.15; }
            } else {
                if (rotateStepSize > 0.01) { rotateStepSize /= 1.15; }
            }
            rotateStepSize = ClampF(rotateStepSize, 0.01, 0.25);

            theController.setStepSize(rotateStepSize);

            parent.notice(GetLocStringByKeyExt("SBUI_iLookAtStepSize")
                + FloatToString(rotateStepSize));
        }
    }
    // ------------------------------------------------------------------------
    event OnAdjustLookAtDistance(action: SInputAction) {
        var value: float;

        if (theController.isActive() && action.value != 0) {
            value = theController.getLookAtDistance();
            if (action.value > 0) {
                value += 0.5;
            } else {
                value -= 0.5;
            }
            theController.setLookAtDistance(value);

            parent.notice(GetLocStringByKeyExt("SBUI_iLookAtDistance") + " "
                + FloatToString(theController.getLookAtDistance()));
        }
    }
    // ------------------------------------------------------------------------
    event OnBack(action: SInputAction) {
        if (IsPressed(action)) {
            parent.PopState();
        }
    }
    // ------------------------------------------------------------------------
    event OnResetLookAt(action: SInputAction) {
        if (IsPressed(action)) {
            actor.setLookAt(SStoryBoardLookAtSettings());
            parent.theLookAtDirector.hideStaticPoint(actor);

            // trigger controller refresh
            parent.theLookAtDirector.refreshLookAtForActor(actor);
            parent.notice(GetLocStringByKeyExt("SBUI_iLookAtRemoved"));
        }
    }
    // ------------------------------------------------------------------------
    private function startInteractiveMode() {
        var shotSettings: SStoryBoardShotAssetSettings;

        actor = (CModStoryBoardActor)parent.assetManager.getSelectedAsset();
        theController.startInteractiveMode(actor);

        shotSettings = actor.getShotSettings();
        newLookAt = shotSettings.lookAt;

        // special cam is actor dependent -> update
        if (parent.isSpecialCamInUse) {
            parent.OnSwitchToSpecialCam();
        }
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        theInput.RegisterListener(this, 'OnBack', 'SBUI_AcceptChanges');
        theInput.RegisterListener(this, 'OnResetLookAt', 'SBUI_ClearLookAt');
        theInput.RegisterListener(this, 'OnAdjustLookAtDistance', 'SBUI_AdjustLootAtDistance');

        theInput.RegisterListener(this, 'OnChangeSpeed', 'SBUI_ControlStepSize');
        theInput.RegisterListener(this, 'OnCycleAutoLookAt', 'SBUI_ActorCycleLookAtActor');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        theInput.UnregisterListener(this, 'SBUI_AcceptChanges');
        theInput.UnregisterListener(this, 'SBUI_ClearLookAt');

        theInput.UnregisterListener(this, 'SBUI_ControlStepSize');
        theInput.UnregisterListener(this, 'SBUI_ActorCycleLookAtActor');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// Select asset (actor/item)
// rootstate == OnBack event triggers change to Overview Mode
state SbUi_LookAtActorSelection in CModStoryBoardLookAtMode
    extends SbUi_AssetSelection
{
    // ------------------------------------------------------------------------
    default listTitleKey = "SBUI_LookAtListTitle";
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        super.OnEnterState(prevStateName);

        // since an actor will be already selected on state ente show visualization
        parent.theLookAtDirector.showStaticPoint(
            (CModStoryBoardActor)parent.assetManager.getSelectedAsset());

        theInput.RegisterListener(this, 'OnStartLookAtSetup', 'SBUI_SetupLookAt');
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        theInput.UnregisterListener(this, 'SBUI_SetupLookAt');

        super.OnLeaveState(nextStateName);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        super.OnHotkeyHelp(hotkeyList);

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SetupLookAt'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SelectAsset', "SBUI_SelectForLookAt"));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ToggleSpecialWorkmodeCam', "SBUI_ToggleLookAtCamera"));
    }
    // ------------------------------------------------------------------------
    event OnSelected(optionId: String) {
        // hide visualization from previous actor...
        parent.theLookAtDirector.hideStaticPoint(
            (CModStoryBoardActor)parent.assetManager.getSelectedAsset());

        super.OnSelected(optionId);

        // ...and visualize the look at node (if static look is active for this
        // actor)
        parent.theLookAtDirector.showStaticPoint(
            (CModStoryBoardActor)parent.assetManager.getSelectedAsset());
    }
    // ------------------------------------------------------------------------
    event OnStartLookAtSetup(action: SInputAction) {
        if (IsPressed(action)) {
            parent.PushState('SbUi_ActorLookAt');
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
            assetManager.getActorItemsList(),
            assetManager.getActorCount());

        parent.view.listMenuRef.updateView();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// Ui for adjusting lookat of actors  for currently selected storyboard shot.
//  - changing currently selected asset
//  - providing special (predefined) toggle cam for viewing the actor
//  - setup of actor look at for this shot
//
statemachine class CModStoryBoardLookAtMode extends CModStoryBoardAssetSelectionBasedWorkMode
{
    default workMode = 'SBUI_ModeLookAt';
    default workContext = 'MOD_StoryBoardUi_ModeLookAt';
    default generalHelpKey = "SBUI_LookAtGeneralHelp";
    default defaultState = 'SbUi_LookAtActorSelection';
    // ------------------------------------------------------------------------
    protected var theLookAtDirector: CModStoryBoardLookAtDirector;
    protected var theController: CModStoryBoardInteractiveLookAt;
    // ------------------------------------------------------------------------
    private function createLookAtController() : CModStoryBoardInteractiveLookAt
    {
        var ent: CEntity;
        var template: CEntityTemplate;

        template = (CEntityTemplate)LoadResource("dlc\modtemplates\storyboardui\interactive_lookat.w2ent", true);
        ent = theGame.CreateEntity(template,
            thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation());

        return (CModStoryBoardInteractiveLookAt)ent;
    }
    // ------------------------------------------------------------------------
    public function activate(shot: CModStoryBoardShot) {
        super.activate(shot);

        theController = createLookAtController();
        theLookAtDirector = shotViewer.getLookAtDirector();

        theController.init(theLookAtDirector);
    }
    // ------------------------------------------------------------------------
    public function deactivate() {
        theLookAtDirector.hideStaticPoints();

        super.deactivate();

        theController.Destroy();
        delete theController;
    }
    // ------------------------------------------------------------------------
    event OnSwitchToSpecialCam() {
        // change view to see currently selected asset
        shotViewer.switchCamTo(
            SBUI_createCamSettingsFor(
                SBUICam_ActorLookAtPreview, assetManager.getSelectedAsset()));
    }
    // ------------------------------------------------------------------------
    public function storeSettings() {
        // Note: this overwrites *all* asset settings in the shot
        storyboard.storeCurrentAssetSettingsIn(shot);
    }
    // ------------------------------------------------------------------------
    public function showUi(showUi: bool) {
        // show ui only in asset selection state
        if (showUi && GetCurrentStateName() == defaultState) {
            if (!view.listMenuRef) {
                theGame.RequestMenu('ListView', view);
            }
        } else {
            if (view.listMenuRef) {
                view.listMenuRef.close();
            }
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
