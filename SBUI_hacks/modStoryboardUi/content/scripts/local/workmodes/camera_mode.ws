// -----------------------------------------------------------------------------
//
// BUGS:
//
// TODO:
//  - add hotkey for camera settings info (relative to origin from placementDirector)
//
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
class CStoryBoardInteractiveCamera extends CStoryBoardShotCamera {
    private var isInteractiveMode: bool;

    private var stepMoveSize: float; default stepMoveSize = 0.05;
    private var stepRotSize: float; default stepRotSize = 0.05;

    private var defaultDofCenterRadius: float; default defaultDofCenterRadius = 0.5;
    // ------------------------------------------------------------------------
    public function startInteractiveMode() {
        if (!isInteractiveMode) {
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
        var newPos: Vector;
        var newRot: EulerAngles;
        var directionFB, directionLR: float;
        var moveFB, moveLR, moveUD: float;
        var rotYaw, rotPitch: float;

        moveFB = theInput.GetActionValue('SBUI_MoveForwardBack');
        moveLR = theInput.GetActionValue('SBUI_MoveLeftRight');
        moveUD = theInput.GetActionValue('SBUI_MoveUpDown');

        rotYaw = theInput.GetActionValue('GI_MouseDampX');
        rotPitch = theInput.GetActionValue('GI_MouseDampY');

        if (moveFB != 0 || moveLR != 0 || moveUD != 0 || rotYaw != 0 || rotPitch != 0)
        {
            newPos = settings.pos;
            newRot = settings.rot;

            directionFB = Deg2Rad(GetHeading() + 90);
            directionLR = Deg2Rad(GetHeading());

            newPos.X += moveFB * stepMoveSize * CosF(directionFB)
                      + moveLR * stepMoveSize * CosF(directionLR);

            newPos.Y += moveFB * stepMoveSize * SinF(directionFB)
                      + moveLR * stepMoveSize * SinF(directionLR);

            newPos.Z += moveUD * stepMoveSize;

            newRot.Yaw -= rotYaw * stepRotSize;
            newRot.Pitch -= rotPitch * stepRotSize;

            if (newPos != settings.pos || newRot != settings.rot) {
                settings.pos = newPos;
                settings.rot = newRot;

                this.TeleportWithRotation(settings.pos, settings.rot);
            }
        }
    }
    // ------------------------------------------------------------------------
    public function adjustFov(step: float) {
        settings.fov = ClampF(RoundF(settings.fov + step), 1, 150);
        this.comp.fov = settings.fov;
    }
    // ------------------------------------------------------------------------
    public function adjustDofStrength(step: float) {
        settings.dof.strength = settings.dof.strength + step;
        // clamping will be applied in setDof
        this.setDof(settings.dof);
        settings.dof = getDof();
    }
    // ------------------------------------------------------------------------
    public function adjustDofBlur(isNear: bool, step: float) {
        if (isNear) {
            settings.dof.blurNear = settings.dof.blurNear + step;
        } else {
            settings.dof.blurFar = settings.dof.blurFar + step;
        }
        // clamping will be applied in setDof
        this.setDof(settings.dof);
        settings.dof = getDof();
    }
    // ------------------------------------------------------------------------
    public function adjustDofFocus(isNear: bool, step: float) {
        if (isNear) {
            settings.dof.focusNear = settings.dof.focusNear + step;
        } else {
            settings.dof.focusFar = settings.dof.focusFar + step;
        }
        // clamping will be applied in setDof
        this.setDof(settings.dof);
        settings.dof = getDof();
    }
    // ------------------------------------------------------------------------
    public function adjustDofRadius(step: float) {
        var radius: float;
        var near, far: float;

        radius = (settings.dof.blurFar - settings.dof.blurNear) / 2.0;
        near = settings.dof.blurNear -= step;
        far = settings.dof.blurFar += step;

        if (near < far) {
            settings.dof.blurNear = near;
            settings.dof.blurFar = far;
        } else {
            settings.dof.blurNear = near + radius;
            settings.dof.blurFar = settings.dof.blurNear;
        }

        radius = (settings.dof.focusNear - settings.dof.focusNear) / 2.0;
        near = settings.dof.focusNear -= step;
        far = settings.dof.focusFar += step;

        if (near < far) {
            settings.dof.focusNear = near;
            settings.dof.focusFar = far;
        } else {
            settings.dof.focusNear = near + radius;
            settings.dof.focusFar = settings.dof.focusNear;
        }

        this.setDof(settings.dof);
        settings.dof = getDof();
    }
    // ------------------------------------------------------------------------
    public function setDofCenterPoint(p: Vector) {
        var dist: float = VecDistance(settings.pos, p);
        var radiusBlur, radiusFocus: float;

        // Note: this is a total hack. correct calculation requires more effort...
        // http://www.dofmaster.com/articles.html
        // and probably cannot be previewed anyway...

        radiusBlur = defaultDofCenterRadius * 2.0;
        radiusFocus = defaultDofCenterRadius;

        settings.dof.blurFar = dist + radiusBlur * 2.0;
        settings.dof.blurNear = dist - radiusBlur;

        settings.dof.focusFar = dist + radiusFocus;
        settings.dof.focusNear = dist - radiusFocus;

        this.setDof(settings.dof);

        settings.dof = getDof();
    }
    // ------------------------------------------------------------------------
    public function getDofSettings() : SStoryBoardCameraDofSettings {
        return getDof();
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
}
// ----------------------------------------------------------------------------
// rootstate == OnBack event triggers change to Overview Mode
state SbUi_InteractiveCamera in CModStoryBoardCameraMode extends SbUi_WorkModeRootState
{
    // alias
    private var theCam: CStoryBoardInteractiveCamera;
    // current step sizes
    private var fovStepSize: float; default fovStepSize = 5.0;
    private var moveStepSize: float;
    private var rotStepSize: float;

    private var dofStepSize: float; default dofStepSize = 0.1;
    private var dofDistStepSize: float; default dofDistStepSize = 0.5;

    private var isDofNear: Bool;
    private var isDofMode: Bool;
    private var lastDofCenterActorId: String;
    private var areGuidesVisible: bool;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        // start default interactive mode
        theCam = parent.theCam;
        theCam.startInteractiveMode();
        theCam.getStepSize(moveStepSize, rotStepSize);

        theInput.RegisterListener(this, 'OnBack', 'SBUI_AcceptChanges');

        showCamGuides(true);
        isDofNear = false;
        isDofMode = false;
        // (any) valid id is required as start
        lastDofCenterActorId = parent.assetManager.getPreviousActorId();
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        showCamGuides(false);
        theInput.UnregisterListener(this, 'SBUI_AcceptChanges');
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_AcceptChanges', "SBUI_AcceptCamChanges"));

        hotkeyList.PushBack(HotkeyHelp_from('GI_MouseDampX', "SBUI_CamRotYaw"));
        hotkeyList.PushBack(HotkeyHelp_from('GI_MouseDampY', "SBUI_CamRotPitch"));

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_MoveForwardBack'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_MoveLeftRight'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_MoveUpDown'));

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_CamGuides'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_CamFovAdjust'));

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_CamDofToggle'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_CycleDofOnAsset'));

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_CamDofAdjust'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_CamDofIntensity'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_CamDofToggleDofNear'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_CamDofBlurAdjust'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_CamDofFocusAdjust'));

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ControlStepSize'));
    }
    // ------------------------------------------------------------------------
    event OnChangeFov(action: SInputAction) {
        if (!isDofMode && action.value != 0) {
            // value is -1 or 1 (as specified in input settings!)
            theCam.adjustFov(action.value * fovStepSize);

            parent.notice(GetLocStringByKeyExt("SBUI_iCamFov")
                + FloatToString(theCam.GetFov()));
        }
    }
    // ------------------------------------------------------------------------
    event OnToggleGuides(action: SInputAction) {
        if (!IsPressed(action)) {
            showCamGuides(!areGuidesVisible);
        }
    }
    // ------------------------------------------------------------------------
    private function showCamGuides(doShow: bool) {
        if (doShow) {
            theGame.RequestPopup('TestPopup');
        } else {
            theGame.ClosePopup('TestPopup');
        }
        areGuidesVisible = doShow;
    }
    // ------------------------------------------------------------------------
    private function cycleDofOnAsset() {
        var actor: CModStoryBoardActor;
        var placement: SStoryBoardPlacementSettings;
        var dofCenterActorId: String;

        dofCenterActorId = parent.assetManager.getNextInteractionActorId(
                "-", lastDofCenterActorId);

        if (dofCenterActorId != lastDofCenterActorId) {
            actor = (CModStoryBoardActor)parent.assetManager.getAsset(dofCenterActorId);

            placement = actor.getCurrentPlacement();

            theCam.setDofCenterPoint(placement.pos);

            lastDofCenterActorId = dofCenterActorId;

            // info
            parent.notice(GetLocStringByKeyExt("SBUI_iCamDofActor")
                + actor.getName() + " " );
                //+);
        }
    }
    // ------------------------------------------------------------------------
    event OnChangeDof(action: SInputAction) {
        var dof: SStoryBoardCameraDofSettings;

        if (isDofMode && action.value != 0) {
            switch (action.aName) {
                case 'SBUI_CycleDofOnAsset':
                    if (IsPressed(action)) {
                        this.cycleDofOnAsset();
                    }
                    // different notice output
                    return false;

                case 'SBUI_CamDofAdjust':
                    theCam.adjustDofRadius(action.value * dofDistStepSize);
                    break;

                case 'SBUI_CamDofIntensity':
                    theCam.adjustDofStrength(action.value * dofStepSize);
                    break;

                case 'SBUI_CamDofBlurAdjust':
                    theCam.adjustDofBlur(isDofNear, action.value * dofDistStepSize);
                    break;

                case 'SBUI_CamDofFocusAdjust':
                    theCam.adjustDofFocus(isDofNear, action.value * dofDistStepSize);
                    break;
            }
            dof = theCam.getDofSettings();

            parent.notice(GetLocStringByKeyExt("SBUI_iCamDof")
                + FloatToString(dof.strength) + " "
                + FloatToString(dof.blurNear) + "/"
                + FloatToString(dof.blurFar) + " "
                + FloatToString(dof.focusNear) + "/"
                + FloatToString(dof.focusFar));
        }
    }
    // ------------------------------------------------------------------------
    event OnModifierChange(action: SInputAction) {
        if (IsPressed(action)) {
            switch (action.aName) {
                case 'SBUI_CamDofToggle':           isDofMode = true; break;
                case 'SBUI_CamDofToggleDofNear':    isDofNear = true; break;
            }
        } else if (IsReleased(action)) {
            switch (action.aName) {
                case 'SBUI_CamDofToggle':           isDofMode = false; break;
                case 'SBUI_CamDofToggleDofNear':    isDofNear = false; break;
            }
        }
    }
    // ------------------------------------------------------------------------
    event OnChangeSpeed(action: SInputAction) {
        if (action.value != 0) {

            if (action.value > 0) {
                if (fovStepSize < 25)       { fovStepSize *= 1.25; }
                if (moveStepSize < 5)       { moveStepSize *= 1.75; }
                if (rotStepSize < 1.0)      { rotStepSize *= 1.15; }
                if (dofStepSize < 1.0)      { dofStepSize *= 1.15; }
                if (dofDistStepSize < 25.0) { dofDistStepSize *= 1.75; }
            } else {
                if (fovStepSize > 1)        { fovStepSize /= 1.25; }
                if (moveStepSize > 0.005)    { moveStepSize /= 1.75; }
                if (rotStepSize > 0.005)     { rotStepSize /= 1.15; }
                if (dofStepSize > 0.01)     { dofStepSize /= 1.15; }
                if (dofDistStepSize > 0.01) { dofDistStepSize /= 1.75; }
            }
            fovStepSize = ClampF(fovStepSize, 1, 25);
            moveStepSize = ClampF(moveStepSize, 0.005, 5);
            rotStepSize = ClampF(rotStepSize, 0.005, 0.5);

            dofStepSize = ClampF(dofStepSize, 0.01, 25);

            parent.theCam.setStepSize(moveStepSize, rotStepSize);

            parent.notice(GetLocStringByKeyExt("SBUI_iCamStepSize")
                + IntToString(RoundF(fovStepSize)) + "/"
                + FloatToString(moveStepSize) + "/"
                + FloatToString(rotStepSize) + "/"
                + FloatToString(dofStepSize) + "/"
                + FloatToString(dofDistStepSize));
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
statemachine class CModStoryBoardCameraMode extends CModStoryBoardWorkMode {
    default workMode = 'SBUI_ModeCamera';
    default workContext = 'MOD_StoryBoardUi_ModeCamera';
    default generalHelpKey = "SBUI_CameraGeneralHelp";
    // ------------------------------------------------------------------------
    protected var theCam: CStoryBoardInteractiveCamera;
    protected var assetManager: CModStoryBoardAssetManager;
    // ------------------------------------------------------------------------
    public function init(storyboard: CModStoryBoard) {
        super.init(storyboard);
        this.assetManager = storyboard.getAssetManager();
    }
    // ------------------------------------------------------------------------
    private function createInteractiveCam() : CStoryBoardInteractiveCamera {
        var ent: CEntity;
        var template: CEntityTemplate;

        template = (CEntityTemplate)LoadResource("dlc\modtemplates\storyboardui\interactive_camera.w2ent", true);
        ent = theGame.CreateEntity(template,
            thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation());

        return (CStoryBoardInteractiveCamera)ent;
    }
    // ------------------------------------------------------------------------
    public function isUiShown() : bool { return false; }
    // ------------------------------------------------------------------------
    public function showUi(showUi: bool) { }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();

        theInput.RegisterListener(this, 'OnChangeFov', 'SBUI_CamFovAdjust');
        theInput.RegisterListener(this, 'OnToggleGuides', 'SBUI_CamGuides');

        theInput.RegisterListener(this, 'OnModifierChange', 'SBUI_CamDofToggle');
        theInput.RegisterListener(this, 'OnModifierChange', 'SBUI_CamDofToggleDofNear');

        theInput.RegisterListener(this, 'OnChangeDof', 'SBUI_CycleDofOnAsset');
        theInput.RegisterListener(this, 'OnChangeDof', 'SBUI_CamDofAdjust');

        theInput.RegisterListener(this, 'OnChangeDof', 'SBUI_CamDofIntensity');
        theInput.RegisterListener(this, 'OnChangeDof', 'SBUI_CamDofBlurAdjust');
        theInput.RegisterListener(this, 'OnChangeDof', 'SBUI_CamDofFocusAdjust');

        theInput.RegisterListener(this, 'OnChangeSpeed', 'SBUI_ControlStepSize');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();

        theInput.UnregisterListener(this, 'SBUI_CamFovAdjust');
        theInput.UnregisterListener(this, 'SBUI_CamGuides');

        theInput.UnregisterListener(this, 'SBUI_CamDofToggle');
        theInput.UnregisterListener(this, 'SBUI_CamDofToggleDofNear');

        theInput.UnregisterListener(this, 'SBUI_CycleDofOnAsset');
        theInput.UnregisterListener(this, 'SBUI_CamDofAdjust');

        theInput.UnregisterListener(this, 'SBUI_CamDofIntensity');
        theInput.UnregisterListener(this, 'SBUI_CamDofBlurAdjust');
        theInput.UnregisterListener(this, 'SBUI_CamDofFocusAdjust');

        theInput.UnregisterListener(this, 'SBUI_ControlStepSize');
    }
    // ------------------------------------------------------------------------
    public function activate(shot: CModStoryBoardShot) {
        super.activate(shot);

        // create interactive cam and setup shotsettings
        theCam = createInteractiveCam();

        theCam.setSettings(shot.getCameraSettings());
        theCam.activate();

        PushState('SbUi_InteractiveCamera');
    }
    // ------------------------------------------------------------------------
    public function hasModifiedSettings() : bool {
        //FIXME verify if cam settings differ from start settings
        return true;
    }
    // ------------------------------------------------------------------------
    public function storeSettings() {
        shot.setCameraSettings(theCam.getSettings());
    }
    // ------------------------------------------------------------------------
    public function deactivate() {
        super.deactivate();
        // destroy guides popup if it is still shown
        theGame.ClosePopup('TestPopup');

        // do NOT deactivate this cam cause it will trigger a return to the
        // gamecamera!
        //theCam.deactivate();
        theCam.stopInteractiveMode();
        theCam.Destroy();
        delete theCam;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
