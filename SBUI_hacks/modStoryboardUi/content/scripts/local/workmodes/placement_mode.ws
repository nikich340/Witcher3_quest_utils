// -----------------------------------------------------------------------------
//
// BUGS:
//  - toggleSnapToGround does not work if asset is far away from ground (> 1m?)
//      -> recalculate Z to snap on activating toggle (and adjust help if it works)?
//
// TODO:
//  - add some visible marker for selected asset (floating orb above asset?)
//
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
class CModStoryBoardInteractivePlacement extends CEntity {
    // ------------------------------------------------------------------------
    protected var placement: SStoryBoardPlacementSettings;
    protected var asset: CModStoryBoardAsset;
    // ------------------------------------------------------------------------
    private var isInteractiveMode: bool;
    private var snapToGround: bool;
    private var isRotationMode: bool;

    private var stepMoveSize: float; default stepMoveSize = 0.005;
    private var stepRotSize: float; default stepRotSize = 0.1;

    private var camHeading: float;

    private var theWorld: CWorld;
    // ------------------------------------------------------------------------
    public function refreshActorPlacement() {
        var shotSettings: SStoryBoardShotAssetSettings;

        shotSettings = asset.getShotSettings();
        placement = shotSettings.placement;
    }
    // ------------------------------------------------------------------------
    public function startInteractiveMode(selectedAsset: CModStoryBoardAsset) {
        if (!isInteractiveMode) {
            theWorld = theGame.GetWorld();

            asset = selectedAsset;
            // freeze asset while moving/rotating
            asset.freeze();

            refreshActorPlacement();

            // repeats & overrideExisting = true
            AddTimer('updateInteractiveSettings', 0.015f, true, , , , true);
            isInteractiveMode = true;
        }
    }
    // ------------------------------------------------------------------------
    public function stopInteractiveMode() {
        RemoveTimer('updateInteractiveSettings');
        isInteractiveMode = false;
        // unfreeze after moving/rotation is done
        asset.unfreeze();
    }
    // ------------------------------------------------------------------------
    private var isBirdsEyeView : bool; default isBirdsEyeView = false;
    public function GetBirdsEye():bool{return this.isBirdsEyeView;}
    public function SetBirdsEye(set:bool){this.isBirdsEyeView = set;}
    // ------------------------------------------------------------------------
    timer function updateInteractiveSettings(deltaTime: float, id: int) {
        var newPlacement: SStoryBoardPlacementSettings;
        var directionFB, directionLR: float;
        var moveFB, moveLR, moveUD: float;
        var rotateLR: float;
        var groundZ: float;
        var camera : CStaticCamera;
        var camPos : Vector;


        newPlacement = placement;

        if (isRotationMode) {
            rotateLR = theInput.GetActionValue('GI_MouseDampX');

            newPlacement.rot.Yaw -= rotateLR * stepRotSize;

        } else {

            moveLR = theInput.GetActionValue('GI_MouseDampX');
            moveFB = - theInput.GetActionValue('GI_MouseDampY');

            moveUD = theInput.GetActionValue('SBUI_AssetMoveUpDown');

            // use current set cam heading so movement is aligned with visuals
            directionFB = Deg2Rad(camHeading + 90);
            directionLR = Deg2Rad(camHeading);

            newPlacement.pos.X += moveFB * stepMoveSize * CosF(directionFB)
                                + moveLR * stepMoveSize * CosF(directionLR);

            newPlacement.pos.Y += moveFB * stepMoveSize * SinF(directionFB)
                                + moveLR * stepMoveSize * SinF(directionLR);

            // somehow this is much slower than with mouse adjustments
            newPlacement.pos.Z += moveUD * stepMoveSize * 4;

            // deactivate snaptoGround when up/down hotkeys are used
            if (moveUD != 0) {
                snapToGround = false;
            }

            // adjust to world surface
            if (snapToGround && theWorld.PhysicsCorrectZ(newPlacement.pos, groundZ))
            {
                newPlacement.pos.Z = groundZ;
            }
        }

        if (newPlacement != placement) {
            asset.setPlacement(newPlacement);
            placement = newPlacement;

            if(isBirdsEyeView){
                camera = (CStaticCamera)theCamera.GetTopmostCameraObject();
                camPos = camera.GetWorldPosition();
                camPos.X = placement.pos.X;
                camPos.Y = placement.pos.Y;                
                camera.Teleport(camPos);
            }
        }
    }
    // ------------------------------------------------------------------------
    public function setCameraHeading(newHeading: float) {
        camHeading = newHeading;
    }
    // ------------------------------------------------------------------------
    public function setStepSize(move: float, rot: float) {
        stepMoveSize = move;
        stepRotSize = rot;
    }
    // ------------------------------------------------------------------------
    public function getStepSize(out moveStep: float, out rotStep: float) {
        moveStep = stepMoveSize;
        rotStep = stepRotSize;
    }
    // ------------------------------------------------------------------------
    public function activateSnapToGound(activate: bool) {
        snapToGround = activate;
    }
    // ------------------------------------------------------------------------
    public function isSnapToGroundActive() : bool {
        return snapToGround;
    }
    // ------------------------------------------------------------------------
    public function activateRotationMode(activate: bool) {
        isRotationMode = activate;
    }
    // ------------------------------------------------------------------------
    public function isRotationMode() : bool {
        return isRotationMode;
    }
    // ------------------------------------------------------------------------
    public function activate() {
    }
    // ------------------------------------------------------------------------
    public function deactivate() {
    }
    // ------------------------------------------------------------------------
}

state SbUi_AssetPlacement in CModStoryBoardPlacementMode
{
    // ------------------------------------------------------------------------
    private var moveStepSize: float;
    private var rotStepSize: float;
    private var isRotationMode: bool;
    // ------------------------------------------------------------------------
    private var newPlacement: SStoryBoardPlacementSettings;
    private var asset: CModStoryBoardAsset;

    private var lastFacedAssetId: String;
    // alias
    private var theController: CModStoryBoardInteractivePlacement;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        var shotSettings: SStoryBoardShotAssetSettings;

        parent.showUi(false);

        asset = parent.assetManager.getSelectedAsset();

        theController = parent.theController;
        theController.startInteractiveMode(asset);

        theController.getStepSize(moveStepSize, rotStepSize);

        // default is no snap to ground to prevent auto changing
        theController.activateSnapToGound(false);

        shotSettings = asset.getShotSettings();
        newPlacement = shotSettings.placement;

        theController.setCameraHeading(parent.shotViewer.getCameraHeading());

        theInput.RegisterListener(this, 'OnChangeSpeed', 'SBUI_ControlStepSize');
        theInput.RegisterListener(this, 'OnBack', 'SBUI_AcceptChanges');
        theInput.RegisterListener(this, 'OnToggleSnapToGround', 'SBUI_ToggleSnapToGround');
        theInput.RegisterListener(this, 'OnToggleRotation', 'SBUI_ToggleMoveRotate');

        //theInput.RegisterListener(this, 'OnCycleAutoPlacement', 'SBUI_AssetCyclePresetPlacement');
        theInput.RegisterListener(this, 'OnCycleAutoFacing', 'SBUI_AssetCycleActorFacing');
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        theController.stopInteractiveMode();

        // some asset may need a "fresh" start
        if (asset.needsRespawn()) {
            asset.respawn();
        }

        theInput.UnregisterListener(this, 'SBUI_ControlStepSize');
        theInput.UnregisterListener(this, 'SBUI_AcceptChanges');
        theInput.UnregisterListener(this, 'SBUI_ToggleSnapToGround');
        theInput.UnregisterListener(this, 'SBUI_ToggleMoveRotate');
        theInput.UnregisterListener(this, 'SBUI_AssetCycleActorFacing');
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        parent.OnHotkeyHelp(hotkeyList);

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_Back', "SBUI_BackToOverview"));

        hotkeyList.PushBack(HotkeyHelp_from('GI_MouseDampX', "SBUI_AssetMoveLeftRight"));
        hotkeyList.PushBack(HotkeyHelp_from('GI_MouseDampY', "SBUI_AssetMoveForwardBack"));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_AssetMoveUpDown'));
        hotkeyList.PushBack(HotkeyHelp_from('GI_MouseDampX', "SBUI_AssetRotYaw"));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ToggleMoveRotate'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ToggleSnapToGround'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_AssetCycleActorFacing'));

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_AcceptChanges', "SBUI_AcceptPosition"));

        // allow switching between asset directly in placement state, too
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SelectPrev'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SelectNext'));

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ToggleSpecialWorkmodeCam', "SBUI_TogglePlacementCamera"));

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ControlStepSize'));
    }
    // ------------------------------------------------------------------------
    event OnToggleSpecialCam(action: SInputAction) {
        parent.OnToggleSpecialCam(action);

        // update the heading of the currently set camera to align movement with
        // displayed plane
        theController.setCameraHeading(parent.shotViewer.getCameraHeading());
    }
    // ------------------------------------------------------------------------
    event OnToggleRotation(action: SInputAction) {
        var msgKey: String;
        if (IsPressed(action)) {
            theController.activateRotationMode(!theController.isRotationMode());

            if (theController.isRotationMode()) {
                msgKey = "SBUI_iRotationMode";
            } else {
                msgKey = "SBUI_iMovementMode";
            }
            parent.notice(GetLocStringByKeyExt(msgKey));
        }
    }
    // ------------------------------------------------------------------------
    event OnToggleSnapToGround(action: SInputAction) {
        var msgKey: String;
        if (IsPressed(action)) {
            theController.activateSnapToGound(!theController.isSnapToGroundActive());

            if (theController.isSnapToGroundActive()) {
                // TODO recalculate Z to snap (cause the PhysicsCorrectZ method
                // works only near gorund correctly)
                msgKey = "SBUI_iSnapToGroundOn";
            } else {
                msgKey = "SBUI_iSnapToGroundOff";
            }
            parent.notice(GetLocStringByKeyExt(msgKey));
        }
    }
    // ------------------------------------------------------------------------
    event OnCycleAutoFacing(action: SInputAction) {
        var facedAsset: CModStoryBoardAsset;
        var actor: CModStoryBoardActor;

        actor = (CModStoryBoardActor)asset;

        if (IsPressed(action) && actor) {

            lastFacedAssetId = parent.assetManager.getNextInteractionActorId(
                actor.getId(), lastFacedAssetId);

            // make sure there is another one
            if (lastFacedAssetId != actor.getId()) {
                facedAsset = parent.assetManager.getAsset(lastFacedAssetId);

                actor.rotateToFace(facedAsset);
                // trigger controller to refetch current actor positioning
                theController.refreshActorPlacement();

                parent.notice(GetLocStringByKeyExt("SBUI_iFacingActor") +
                    facedAsset.getName());
            }

        }
    }
    // ------------------------------------------------------------------------
    event OnSelected(optionId: String) {
        var shotSettings: SStoryBoardShotAssetSettings;

        // some assets may need a "fresh" start
        if (asset.needsRespawn()) {
            asset.respawn();
        }

        parent.assetManager.selectAsset(optionId);

        asset = parent.assetManager.getSelectedAsset();
        newPlacement = shotSettings.placement;
        // restart interactive mode for the new asset
        theController.stopInteractiveMode();
        theController.startInteractiveMode(asset);

        // special cam may be actor dependent -> update
        if (parent.isSpecialCamInUse) {
            parent.OnSwitchToSpecialCam();
        }

        parent.notice(GetLocStringByKeyExt("SBUI_iSelectedAssetInfo")
                + asset.getName());
    }
    // ------------------------------------------------------------------------
    event OnChangeSpeed(action: SInputAction) {
        if (action.value != 0) {

            if (action.value > 0) {
                if (moveStepSize < 0.5)  { moveStepSize *= 1.75; }
                if (rotStepSize < 0.5)   { rotStepSize *= 1.15; }
            } else {
                if (moveStepSize > 0.001){ moveStepSize /= 1.75; }
                if (rotStepSize > 0.001) { rotStepSize /= 1.15; }
            }
            moveStepSize = ClampF(moveStepSize, 0.001, 0.5);
            rotStepSize = ClampF(rotStepSize, 0.001, 0.5);

            theController.setStepSize(moveStepSize, rotStepSize);

            parent.notice(GetLocStringByKeyExt("SBUI_iPlacementStepSize")
                + FloatToString(moveStepSize) + "/"
                + FloatToString(rotStepSize));
        }
    }
    // ------------------------------------------------------------------------
    event OnBack(action: SInputAction) {
        if (IsPressed(action)) {
            parent.PopState();
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// Select asset (actor/item)
// rootstate == OnBack event triggers change to Overview Mode
state SbUi_PlacementAssetSelection in CModStoryBoardPlacementMode
    extends SbUi_AssetSelection
{
    // ------------------------------------------------------------------------
    default listTitleKey = "SBUI_AssetsListTitle";
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        super.OnEnterState(prevStateName);

        theInput.RegisterListener(this, 'OnToggleAssetVisibility', 'SBUI_ToggleAssetVisibility');
        theInput.RegisterListener(this, 'OnStartAssetPlacement', 'SBUI_ChangePlacement');
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        theInput.UnregisterListener(this, 'SBUI_ToggleAssetVisibility');
        theInput.UnregisterListener(this, 'SBUI_ChangePlacement');

        super.OnLeaveState(nextStateName);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        super.OnHotkeyHelp(hotkeyList);

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ToggleAssetVisibility'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ChangePlacement'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SelectAsset', "SBUI_SelectForPlacement"));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ToggleSpecialWorkmodeCam', "SBUI_TogglePlacementCamera"));
    }
    // ------------------------------------------------------------------------
    event OnStartAssetPlacement(action: SInputAction) {
        if (IsPressed(action)) {
            parent.PushState('SbUi_AssetPlacement');
        }
    }
    // ------------------------------------------------------------------------
    event OnToggleAssetVisibility(action: SInputAction) {
        if (IsPressed(action)) {
            parent.notice("TODO: trigger asset visibility");

            // update flag and name in list?
        }
    }
    // ------------------------------------------------------------------------
    protected function switchToSpecialCam() {
        parent.OnSwitchToSpecialCam();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// Ui for adjusting placement of assets (actors/items) for currently selected
// storyboard shot.
//  - changing currently selected asset
//  - providing special (predefined) toggle cam for viewing the whole scene
//  - placement of assets for this shot
//
statemachine class CModStoryBoardPlacementMode extends CModStoryBoardAssetSelectionBasedWorkMode
{
    default workMode = 'SBUI_ModePlacement';
    default workContext = 'MOD_StoryBoardUi_ModePlacement';
    default generalHelpKey = "SBUI_PlacementGeneralHelp";
    default defaultState = 'SbUi_PlacementAssetSelection';
    // ------------------------------------------------------------------------
    protected var thePlacementDirector: CModStoryBoardPlacementDirector;
    protected var theController: CModStoryBoardInteractivePlacement;
    // ------------------------------------------------------------------------
    private function createPlacementController() : CModStoryBoardInteractivePlacement
    {
        var ent: CEntity;
        var template: CEntityTemplate;

        template = (CEntityTemplate)LoadResource("dlc\modtemplates\storyboardui\interactive_placement.w2ent", true);
        ent = theGame.CreateEntity(template,
            thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation());

        return (CModStoryBoardInteractivePlacement)ent;
    }
    // ------------------------------------------------------------------------
    public function activate(shot: CModStoryBoardShot) {
        super.activate(shot);

        theController = createPlacementController();

        // easiest way to reference this entity from other classes
        theController.AddTag('SBUI_PlacementModeEntity');
        thePlacementDirector = shotViewer.getPlacementDirector();
    }
    // ------------------------------------------------------------------------
    public function deactivate() {
        super.deactivate();

        theController.Destroy();
        delete theController;
    }
    // ------------------------------------------------------------------------
    event OnSwitchToSpecialCam() {
        // constant overview cam        
        shotViewer.switchCamTo(
            SBUI_createCamSettingsFor(SBUICam_BirdsEyeView,
                assetManager.getSelectedAsset(),,
                thePlacementDirector.getOriginPlacement()));
    }
    // ------------------------------------------------------------------------
    public function storeSettings() {
        // Note: this overwrites *all* asset settings in the shot (not just
        // placement settings!)
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
