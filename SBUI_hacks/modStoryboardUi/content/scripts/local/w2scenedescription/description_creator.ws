// ----------------------------------------------------------------------------
//
// BUGS:
//
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
class CModStoryBoardW2SceneDescrCreator {
    private var poseMgr: CModStoryBoardIdlePoseListsManager;
    private var animMgr: CModStoryBoardAnimationListsManager;
    private var mimicsMgr: CModStoryBoardMimicsListsManager;
    private var voiceLinesMgr: CModStoryBoardVoiceLinesListsManager;

    // required for recalculating all positions/rot relative to origin
    private var thePlacement: CModStoryBoardPlacementDirector;
    // required for calculating static point coordinates for look at events
    private var theLookAtDirector: CModStoryBoardLookAtDirector;
    // ------------------------------------------------------------------------
    // saved for lookup of by uIds
    private var repoActors: array<SSbDescActor>;
    private var repoItems: array<SSbDescItem>;
    private var repoCameras: array<SSbDescCamera>;
    // ------------------------------------------------------------------------
    // sbui uses a special player template. for the encoder the original must
    // be used
    private var playerTemplate: String;
    default playerTemplate = "gameplay\templates\characters\player\player.w2ent";
    // ------------------------------------------------------------------------
    public function init(
        poseLists: CModStoryBoardIdlePoseListsManager,
        animLists: CModStoryBoardAnimationListsManager,
        mimicsLists: CModStoryBoardMimicsListsManager,
        voiceLinesLists: CModStoryBoardVoiceLinesListsManager,
        placementDirector: CModStoryBoardPlacementDirector,
        lookAtDirector: CModStoryBoardLookAtDirector)
    {
        poseMgr = poseLists;
        animMgr = animLists;
        mimicsMgr = mimicsLists;
        voiceLinesLists = voiceLinesLists;
        thePlacement = placementDirector;
        theLookAtDirector = lookAtDirector;
    }
    // ------------------------------------------------------------------------
    private function collectRepoActors(
        assets: array<CModStoryBoardAsset>, out actors: array<SSbDescActor>)
    {
        var actor: CModStoryBoardActor;
        var a: SSbDescActor;
        var i: int;

        for (i = 0; i < assets.Size(); i += 1) {
            actor = (CModStoryBoardActor)assets[i];

            if (actor) {
                a = SSbDescActor(
                    actor.getId(),
                    actor.getName(true),
                    actor.getTemplatePath(),
                    actor.getAppearanceName(),
                    actor.isPlayerClone()
                );
                // replace player standin template with games player template
                // AND make sure name is "geralt" (or "ciri"?) because otherwise
                // player will not be "found by voicetag"
                if (a.isPlayer) {
                    a.template = playerTemplate;
                    a.repoActorId = "geralt";
                }
                actors.PushBack(a);
            }
        }
    }
    // ------------------------------------------------------------------------
    private function collectRepoItems(
        assets: array<CModStoryBoardAsset>, out items: array<SSbDescItem>)
    {
        var item: CModStoryBoardItem;
        var a: SSbDescItem;
        var i: int;

        for (i = 0; i < assets.Size(); i += 1) {
            item = (CModStoryBoardItem)assets[i];

            if (item) {
                a = SSbDescItem(
                    item.getId(),
                    item.getName(true),
                    item.getTemplatePath()
                );
                items.PushBack(a);
            }
        }
    }
    // ------------------------------------------------------------------------
    private function getActorNameId(actorId: String) : String {
        var i: int;

        for (i = 0; i < repoActors.Size(); i += 1) {
            if (repoActors[i].uId == actorId) {
                return repoActors[i].repoActorId;
            }
        }
        return "actorname-not-found";
    }
    // ------------------------------------------------------------------------
    private function getItemNameId(itemId: String) : String {
        var i: int;

        for (i = 0; i < repoItems.Size(); i += 1) {
            if (repoItems[i].uId == itemId) {
                return repoItems[i].repoItemId;
            }
        }
        return "itemname-not-found";
    }
    // ------------------------------------------------------------------------
    private function getCameraNameId(camHash: String) : String {
        var i: int;

        for (i = 0; i < repoCameras.Size(); i += 1) {
            if (repoCameras[i].uId == camHash) {
                return repoCameras[i].repoCamId;
            }
        }
        return "camname-not-found";
    }
    // ------------------------------------------------------------------------
    private function isActor(assetId: String) : bool {
        return StrLeft(assetId, 5) == "actor";
    }
    // ------------------------------------------------------------------------
    private function isItem(assetId: String) : bool {
        return !isActor(assetId);
    }
    // ------------------------------------------------------------------------
    private function cameraHashId(cam: SStoryBoardCameraSettings) : String {
        var dofHash: String;

        if (cam.dof.strength > 0) {
            dofHash = FloatToString(cam.dof.strength)
                + " " + FloatToString(cam.dof.blurNear)
                + " " + FloatToString(cam.dof.blurFar)
                + "|" + FloatToString(cam.dof.focusNear)
                + " " + FloatToString(cam.dof.focusFar);
        }
        //TODO maybe VecToStringPrec/FloatToStringPrec with a fixed precision
        return
            VecToString(cam.pos)
            + "|"  + cam.rot.Pitch + " " + cam.rot.Yaw + " " + cam.rot.Roll
            + "|" + FloatToString(cam.fov)
            + "|" + dofHash;
    }
    // ------------------------------------------------------------------------
    private function collectRepoCams(
        shots: array<CModStoryBoardShot>, out cams: array<SSbDescCamera>)
    {
        var camSettings: SStoryBoardCameraSettings;
        var i: int;
        var usedCams: array<String>;
        var hashId: String;

        for (i = 0; i < shots.Size(); i += 1) {
            camSettings = shots[i].getCameraSettings();

            // ignore dupes for "globals"
            hashId = cameraHashId(camSettings);
            if (!usedCams.Contains(hashId)) {
                // transform according to origin actor
                cams.PushBack(SSbDescCamera(
                    hashId,
                    "cam_" + IntToString(i + 1) + "_" + shots[i].getEscapedName(),
                    thePlacement.transformToLocalPos(camSettings.pos),
                    thePlacement.transformToLocalRot(camSettings.rot),
                    camSettings.fov,
                    camSettings.dof
                ));
                usedCams.PushBack(hashId);
            }
        }
    }
    // ------------------------------------------------------------------------
    private function createPoseRepoId(poseSettings: SStoryBoardPoseSettings) : String
    {
        var poseInfo: SStoryBoardIdlePoseInfo;
        var repoId: String;

        poseInfo = poseMgr.getPoseInformation(poseSettings.idleAnimId);

        repoId = "pose_" + IntToString(poseSettings.idleAnimId) + "_";

        // prefer usage of (optional!) posemeta as it's probably more
        if (poseSettings.idleAnimId > 0
            && poseInfo.posename != ""
            && poseInfo.status != ""
            && poseInfo.emoState != "")
        {
            repoId += poseInfo.status + "_" + poseInfo.posename + "_" + poseInfo.emoState;
        } else {
            // take (default) idle animation from settings for default pose as
            // poseMgr has no knowledge what default means for a specific actor.
            // however the idle anim of pose settings is set in all cases
            repoId += NameToString(poseSettings.idleAnimName);
        }

        return StrReplaceAll(repoId, " ", "_");
    }
    // ------------------------------------------------------------------------
    private function createAnimRepoId(
        prefix: String, animSettings: SStoryBoardAnimationSettings) : String
    {
        var repoId: String;

        repoId = prefix + "_" + IntToString(animSettings.animId) + "_" + animSettings.animName;

        // some anim names contain blanks!
        return StrReplaceAll(repoId, " ", "_");
    }
    // ------------------------------------------------------------------------
    private function collectRepoPoses(
        shots: array<CModStoryBoardShot>, out poses: array<SSbDescIdlePose>)
    {
        var assetSettings: array<SStoryBoardShotAssetSettings>;
        var poseSettings: SStoryBoardPoseSettings;
        var poseInfo: SStoryBoardIdlePoseInfo;
        var i, a: int;
        var repoId: String;
        var usedPoses: array<String>;

        for (i = 0; i < shots.Size(); i += 1) {
            assetSettings = shots[i].getAssetSettings();

            for (a = 0; a < assetSettings.Size(); a += 1) {

                if (isActor(assetSettings[a].assetId)) {
                    poseSettings = assetSettings[a].pose;

                    // unfortunately default pose (0) cannot be skipped as some assets
                    // have specific idle animations which DON'T get picked up by the
                    // game automatically (for example wild hunt)!
                    repoId = createPoseRepoId(poseSettings);
                    // ignore dupes
                    if (!usedPoses.Contains(repoId)) {

                        poseInfo = poseMgr.getPoseInformation(poseSettings.idleAnimId);

                        poses.PushBack(SSbDescIdlePose(
                            repoId,
                            poseSettings.idleAnimName,
                            poseInfo.posename,
                            poseInfo.status,
                            poseInfo.emoState
                        ));
                        usedPoses.PushBack(repoId);
                    }
                }
            }
        }
    }
    // ------------------------------------------------------------------------
    private function collectRepoAnims(
        shots: array<CModStoryBoardShot>,
        out anims: array<SSbDescAnimation>,
        out mimics: array<SSbDescAnimation>)
    {
        var assetSettings: array<SStoryBoardShotAssetSettings>;
        var animSettings: SStoryBoardAnimationSettings;
        var uId, i, a: int;
        var repoId: String;
        var usedAnims: array<Int>;
        var usedMimics: array<Int>;

        for (i = 0; i < shots.Size(); i += 1) {
            assetSettings = shots[i].getAssetSettings();

            for (a = 0; a < assetSettings.Size(); a += 1) {

                if (isActor(assetSettings[a].assetId)) {
                    // -- animations
                    animSettings = assetSettings[a].animation;

                    // id == 0 => asset has no animation
                    uId = animSettings.animId;
                    // ignore dupes
                    if (uId != 0 && !usedAnims.Contains(uId)) {
                        repoId = createAnimRepoId("anim", animSettings);

                        anims.PushBack(SSbDescAnimation(
                            uId,
                            repoId,
                            animSettings.animName,
                            animMgr.getAnimationFrameCount(uId)
                        ));
                        usedAnims.PushBack(uId);
                    }

                    // -- mimics
                    animSettings = assetSettings[a].mimics;

                    // id == 0 => asset has no animation
                    uId = animSettings.animId;
                    // ignore dupes
                    if (uId != 0 && !usedMimics.Contains(uId)) {
                        repoId = createAnimRepoId("mimicsanim", animSettings);

                        mimics.PushBack(SSbDescAnimation(
                            uId,
                            repoId,
                            animSettings.animName,
                            mimicsMgr.getAnimationFrameCount(uId)
                        ));
                        usedMimics.PushBack(uId);
                    }
                }
            }
        }
    }
    // ------------------------------------------------------------------------
    private function createPoseProdId(
        actorNameId: String, poseSettings: SStoryBoardPoseSettings) : String
    {
        var poseInfo: SStoryBoardIdlePoseInfo;
        var prodId: String;

        poseInfo = poseMgr.getPoseInformation(poseSettings.idleAnimId);

        prodId = actorNameId + "_";

        // prefer usage of (optional!) posemeta as it's probably more
        if (poseSettings.idleAnimId > 0
            && poseInfo.posename != ""
            && poseInfo.status != ""
            && poseInfo.emoState != "")
        {
            prodId += poseInfo.status + "_" + poseInfo.posename + "_" + poseInfo.emoState;
        } else {
            // take (default) idle animation from settings for default pose as
            // poseMgr has no knowledge what default means for a specific actor.
            // however the idle anim of pose settings is set in all cases
            prodId += NameToString(poseSettings.idleAnimName);
        }

        return StrReplaceAll(prodId, " ", "_");
    }
    // ------------------------------------------------------------------------
    private function collectProdPoses(
        shots: array<CModStoryBoardShot>,
        out poses: array<SSbDescProdIdlePose>)
    {
        var assetSettings: array<SStoryBoardShotAssetSettings>;
        var poseSettings: SStoryBoardPoseSettings;
        var actorNameId: String;
        var uId, i, a: int;
        var prodPoseId: String;
        var usedPoses: array<String>;

        for (i = 0; i < shots.Size(); i += 1) {
            assetSettings = shots[i].getAssetSettings();

            for (a = 0; a < assetSettings.Size(); a += 1) {

                if (isActor(assetSettings[a].assetId)) {

                    actorNameId = getActorNameId(assetSettings[a].assetId);

                    poseSettings = assetSettings[a].pose;

                    // encode default poses selection, too: some actors need specific
                    // idle animations (for example wild hunt) which do NOT get chosen
                    // by the game in scenes!
                    uId = poseSettings.idleAnimId;
                    prodPoseId = createPoseProdId(actorNameId, poseSettings);

                    // ignore dupes
                    if (!usedPoses.Contains(prodPoseId)) {
                        poses.PushBack(SSbDescProdIdlePose(
                            prodPoseId, actorNameId, createPoseRepoId(poseSettings)
                        ));
                        usedPoses.PushBack(prodPoseId);
                    }
                }
            }
        }
    }
    // ------------------------------------------------------------------------
    private function createAnimProdId(
        actorNameId: String, animSettings: SStoryBoardAnimationSettings) : String
    {
        var prodId: String;

        prodId = actorNameId + "_" + animSettings.animName;

        return StrReplaceAll(prodId, " ", "_");
    }
    // ------------------------------------------------------------------------
    private function collectProdAnims(
        shots: array<CModStoryBoardShot>,
        out anims: array<SSbDescProdAnimation>,
        out mimics: array<SSbDescProdAnimation>)
    {
        var assetSettings: array<SStoryBoardShotAssetSettings>;
        var animSettings: SStoryBoardAnimationSettings;
        var actorNameId: String;
        var uId, i, a: int;
        var repoId: String;
        var prodAnimId: String;
        var usedAnims: array<String>;
        var usedMimics: array<String>;

        for (i = 0; i < shots.Size(); i += 1) {
            assetSettings = shots[i].getAssetSettings();

            for (a = 0; a < assetSettings.Size(); a += 1) {

                if (isActor(assetSettings[a].assetId)) {
                    actorNameId = getActorNameId(assetSettings[a].assetId);

                    // -- animations
                    animSettings = assetSettings[a].animation;

                    // id == 0 => asset has no animation
                    uId = animSettings.animId;
                    prodAnimId = createAnimProdId(actorNameId, animSettings);
                    // ignore dupes
                    if (uId != 0 && !usedAnims.Contains(prodAnimId)) {
                        repoId = createAnimRepoId("anim", animSettings);
                        anims.PushBack(SSbDescProdAnimation(
                            prodAnimId,
                            actorNameId,
                            repoId,
                        ));
                        usedAnims.PushBack(prodAnimId);
                    }

                    // -- mimics
                    animSettings = assetSettings[a].mimics;

                    // id == 0 => asset has no animation
                    uId = animSettings.animId;
                    prodAnimId = createAnimProdId(actorNameId, animSettings);
                    // ignore dupes
                    if (uId != 0 && !usedMimics.Contains(prodAnimId)) {
                        repoId = createAnimRepoId("mimicsanim", animSettings);
                        mimics.PushBack(SSbDescProdAnimation(
                            prodAnimId,
                            actorNameId,
                            repoId,
                        ));
                        usedMimics.PushBack(prodAnimId);
                    }
                }
            }
        }
    }
    // ------------------------------------------------------------------------
    private function addPoseEvent(
        out events: array<SSbDescEventIdlePose>,
        actorNameId: String,
        idlePose: SStoryBoardPoseSettings,
        lastIdlePose: SStoryBoardPoseSettings,
        isFirstShot: bool)
    {
        if (isFirstShot || (idlePose.idleAnimId != lastIdlePose.idleAnimId)) {
            // add additional actorNameId info to be used for defaults
            events.PushBack(SSbDescEventIdlePose(
                createPoseProdId(actorNameId, idlePose), actorNameId));
        }
    }
    // ------------------------------------------------------------------------
    private function addAnimEvent(
        out events: array<SSbDescEventAnim>,
        actorNameId: String,
        animSettings: SStoryBoardAnimationSettings)
    {
        if (animSettings.animId != 0) {
            events.PushBack(SSbDescEventAnim(
                createAnimProdId(actorNameId, animSettings)));
        }
    }
    // ------------------------------------------------------------------------
    private function addLookAtEvent(
        out events: array<SSbDescEventLookAt>,
        actorId: String,
        actorNameId: String,
        lookAtSettings: SStoryBoardLookAtSettings)
    {
        if (lookAtSettings.enabled) {
            if (lookAtSettings.lookAtActor != "") {
                events.PushBack(SSbDescEventLookAt(
                    actorNameId, getActorNameId(lookAtSettings.lookAtActor))
                );
            } else {
                events.PushBack(
                    SSbDescEventLookAt(actorNameId, "",
                        //thePlacement.transformToLocalPos(
                            theLookAtDirector.transformToStaticPos(
                                actorId, lookAtSettings.rot, lookAtSettings.distance)
                        //)
                    )
                );
            }
        }
    }
    // ------------------------------------------------------------------------
    private function addVisibilityEvent(
        out events: array<SSbDescEventVisibility>,
        assetNameId: String,
        placement: SStoryBoardPlacementSettings,
        lastPlacement: SStoryBoardPlacementSettings,
        isFirstShot: bool)
    {
        // isHidden for empty (=non existing) lastAssetPlacement is false
        // -> need to make sure lastAssetPlacement really existed!
        if ((isFirstShot && placement.isHidden)
            || (!isFirstShot && placement.isHidden != lastPlacement.isHidden))
        {
            events.PushBack(
                SSbDescEventVisibility(assetNameId, placement.isHidden));
        }
    }
    // ------------------------------------------------------------------------
    private function addPlacementEvent(
        out events: array<SSbDescEventPlacement>,
        assetNameId: String,
        placement: SStoryBoardPlacementSettings,
        lastPlacement: SStoryBoardPlacementSettings)
    {
        // -- placement (only if visible)
        if (!placement.isHidden
            && (placement.pos != lastPlacement.pos
                || placement.rot != lastPlacement.rot))
        {
            events.PushBack(SSbDescEventPlacement(
                assetNameId,
                thePlacement.transformToLocalPos(placement.pos),
                thePlacement.transformToLocalRot(placement.rot)
            ));
        }
    }
    // ------------------------------------------------------------------------
    private function boardShotHasEvents(
        out boardShot: SSbDescStoryboardShot) : bool
    {
        var i: int;
        if (boardShot.camIdChange != "") {
            i = 1;
        }

        i += boardShot.actorPose.Size();
        i += boardShot.actorAnim.Size();
        i += boardShot.actorMimic.Size();
        i += boardShot.actorLookAt.Size();
        i += boardShot.actorPlacement.Size();
        i += boardShot.actorVisibility.Size();

        i += boardShot.itemPlacement.Size();
        i += boardShot.itemVisibility.Size();

        return i > 0;
    }
    // ------------------------------------------------------------------------
    private function newSSbDescStoryboardShot(
        shotId: String, shotName: String) : SSbDescStoryboardShot
    {
        var boardShot: SSbDescStoryboardShot = SSbDescStoryboardShot(shotId, shotName);
        return boardShot;
    }
    // ------------------------------------------------------------------------
    private function collectStoryboardEvents(
        shots: array<CModStoryBoardShot>,
        out shotEvents: array<SSbDescStoryboardShot>)
    {
        var camSettings: SStoryBoardCameraSettings;
        var boardShot: SSbDescStoryboardShot;

        var camHashId: String;
        var lastCamHashId: String;

        var assetSettings: array<SStoryBoardShotAssetSettings>;
        var lastAssetSettings: array<SStoryBoardShotAssetSettings>;

        var assetPlacement, lastAssetPlacement: SStoryBoardPlacementSettings;

        var assetNameId: String;
        var i, a: int;
        var isFirstShot: Bool;

        // some events do not need to be repeated if nothing changed (e.g.
        // cams, visibility, placement)

        // Note: there are no default cameras defined in the dump therefore it's
        // ok to not save a camera in every shot to prevent successive dupes
        for (i = 0; i < shots.Size(); i += 1) {
            // call required to generate new *completely* empty struct
            boardShot = newSSbDescStoryboardShot(
                "shot_" + IntToString(i + 1), shots[i].getName());

            isFirstShot = i == 0;
            // -- cam change
            camSettings = shots[i].getCameraSettings();
            camHashId = cameraHashId(camSettings);

            if (camHashId != lastCamHashId) {
                boardShot.camIdChange = getCameraNameId(camHashId);
            }

            // -- asset events
            assetSettings = shots[i].getAssetSettings();

            for (a = 0; a < assetSettings.Size(); a += 1) {

                assetPlacement = assetSettings[a].placement;
                lastAssetPlacement = lastAssetSettings[a].placement;

                // some event data extraction require assets to be in correct
                // shot positioning (e.g. look ats)!
                thePlacement.setTemporaryPlacement(
                    assetSettings[a].assetId, assetPlacement);

                if (isActor(assetSettings[a].assetId)) {
                    assetNameId = getActorNameId(assetSettings[a].assetId);

                    // -- pose
                    addPoseEvent(boardShot.actorPose,
                        assetNameId,
                        assetSettings[a].pose, lastAssetSettings[a].pose,
                        isFirstShot);

                    // -- anim
                    addAnimEvent(boardShot.actorAnim,
                        assetNameId, assetSettings[a].animation);

                    // -- mimic
                    addAnimEvent(boardShot.actorMimic,
                        assetNameId, assetSettings[a].mimics);

                    // -- lookat
                    addLookAtEvent(boardShot.actorLookAt,
                        assetSettings[a].assetId,
                        assetNameId, assetSettings[a].lookAt);

                    // -- visibility
                    addVisibilityEvent(boardShot.actorVisibility,
                        assetNameId, assetPlacement, lastAssetPlacement,
                        isFirstShot);

                    // -- placement
                    addPlacementEvent(boardShot.actorPlacement,
                        assetNameId, assetPlacement, lastAssetPlacement);

                } else {
                    assetNameId = getItemNameId(assetSettings[a].assetId);

                    // -- visibility
                    addVisibilityEvent(boardShot.itemVisibility,
                        assetNameId, assetPlacement, lastAssetPlacement,
                        isFirstShot);

                    // -- placement
                    addPlacementEvent(boardShot.itemPlacement,
                        assetNameId, assetPlacement, lastAssetPlacement);
                }
            }

            lastAssetSettings = assetSettings;
            lastCamHashId = camHashId;

            if (boardShotHasEvents(boardShot)) {
                shotEvents.PushBack(boardShot);
            }
        }
    }
    // ------------------------------------------------------------------------
    private function injectLongerAnimDuration(
        animId: int,
        animMgr: CModStoryBoardAnimationListsManager,
        out dlgShot: SSbDescDialogShot)
    {
        var animLength: Float;

        if (animId != 0) {
            animLength = animMgr.getAnimationFrameCount(animId) / 30.0;

            if (animLength > dlgShot.duration) {
                dlgShot.duration = animLength;
                dlgShot.infoAnimId = animMgr.getAnimationName(animId);
            }
        }
    }
    // ------------------------------------------------------------------------
    private function newSSbDescDialogShot(
        nr: int, shotName: String) : SSbDescDialogShot
    {
        var dlgShot: SSbDescDialogShot;

        // default minimum duration is 1sec
        dlgShot = SSbDescDialogShot("shot_" + IntToString(nr), shotName, 1);
        return dlgShot;
    }
    // ------------------------------------------------------------------------
    private function collectDialogsectionElements(
        shots: array<CModStoryBoardShot>,
        out sectionElements: array<SSbDescDialogShot>)
    {
        var dlgShot: SSbDescDialogShot;
        var assetSettings: array<SStoryBoardShotAssetSettings>;
        var actorNameId: String;
        var lineId, i, a: int;
        var duration: float;

        for (i = 0; i < shots.Size(); i += 1) {

            // call required to generate new *completely* empty struct
            dlgShot = newSSbDescDialogShot(i + 1, shots[i].getName());

            assetSettings = shots[i].getAssetSettings();

            // find lines & longest animation
            for (a = 0; a < assetSettings.Size(); a += 1) {

                actorNameId = getActorNameId(assetSettings[a].assetId);

                lineId = assetSettings[a].audio.lineId;
                duration = assetSettings[a].audio.duration;

                if (lineId != 0) {
                    dlgShot.lines.PushBack(SSbDescDialogLine(
                        actorNameId,
                        lineId,
                        GetLocStringById(lineId),
                        duration
                    ));
                }

                // -- anims
                injectLongerAnimDuration(
                    assetSettings[a].animation.animId, animMgr, dlgShot);

                // -- mimics
                injectLongerAnimDuration(
                    assetSettings[a].mimics.animId, mimicsMgr, dlgShot);
            }

            sectionElements.PushBack(dlgShot);
        }
    }
    // ------------------------------------------------------------------------
    private function refreshOrigin(
        assets: array<CModStoryBoardAsset>,
        firstShot: CModStoryBoardShot) : String
    {
        var originAssetId: String;
        var asset: CModStoryBoardAsset;
        var actor: CModStoryBoardActor;
        var assetSettings: array<SStoryBoardShotAssetSettings>;
        var placement: SStoryBoardPlacementSettings;
        var newOrigin: SStoryBoardOriginStateData;
        var assetFound: Bool;
        var placementTag: String = "NonPlayerActorNotFound";
        var i, a: int;

        // relevant for the final origin is the currently set tag. it may be an
        // user selected asset tag or not initalized or even frozen if origin was
        // provided as CLI param

        newOrigin = thePlacement.getOrigin();
        originAssetId = newOrigin.assetId;

        if (originAssetId == "USERDEFINED") {
            // do nothing - origin was provided as parameter
            return "USERDEFINED";
        }

        // try to find actor with tag (if found it was set userselected)
        for (i = 0; i < assets.Size(); i += 1) {
            asset = assets[i];

            if (originAssetId == asset.getId()) {
                assetFound = true;
                placementTag = asset.getName();
                break;
            }
        }

        if (!assetFound || originAssetId == "-") {
            // find first non player actor
            for (i = 0; i < assets.Size(); i += 1) {
                actor = (CModStoryBoardActor)assets[i];

                if (actor && !actor.isPlayerClone()) {
                    assetFound = true;
                    originAssetId = actor.getId();
                    placementTag = actor.getName();
                    break;
                }
            }
        }

        if (assetFound) {
            assetSettings = firstShot.getAssetSettings();
            for (i = 0; i < assetSettings.Size(); i += 1) {
                if (assetSettings[i].assetId == originAssetId) {
                    newOrigin.pos = assetSettings[i].placement.pos;
                    newOrigin.rot = assetSettings[i].placement.rot;

                    thePlacement.setOrigin(newOrigin);
                }
            }
        }

        return placementTag;
    }
    // ------------------------------------------------------------------------
    public function create(
        assets: array<CModStoryBoardAsset>,
        shots: array<CModStoryBoardShot>)
    {
        var repoAnims: array<SSbDescAnimation>;
        var repoMimics: array<SSbDescAnimation>;
        var repoPoses: array<SSbDescIdlePose>;

        var prodAnims: array<SSbDescProdAnimation>;
        var prodMimics: array<SSbDescProdAnimation>;
        var prodPoses: array<SSbDescProdIdlePose>;

        var boardShots: array<SSbDescStoryboardShot>;
        var dlgSectionShots: array<SSbDescDialogShot>;

        var writer: CModSbUiW2SceneDescriptionWriter;
        var origin: SStoryBoardOriginStateData;
        var placementTag: String;

        // refresh origin position for position/rotation transformations from
        // first shot
        placementTag = refreshOrigin(assets, shots[0]);
        origin = thePlacement.getOrigin();

        // -- collect global (repo) settings
        // Note: these collectors iterate multiple times over the same data but
        // performance is not important here... this is meant to be easy to
        // follow and easy to extend
        collectRepoActors(assets, repoActors);
        collectRepoItems(assets, repoItems);
        collectRepoCams(shots, repoCameras);
        collectRepoPoses(shots, repoPoses);
        collectRepoAnims(shots, repoAnims, repoMimics);

        // -- collect global (production) settings
        collectProdAnims(shots, prodAnims, prodMimics);
        collectProdPoses(shots, prodPoses);

        // -- collect all storyboard events
        collectStoryboardEvents(shots, boardShots);

        // -- collect all dialogsection named elements (line/required pause)
        collectDialogsectionElements(shots, dlgSectionShots);

        // ----- write all w2scene data at once
        writer = new CModSbUiW2SceneDescriptionWriter in this;
        writer.init();

        // --- repository
        writer.writeRepository(
            repoActors, repoItems, repoCameras, repoPoses, repoAnims, repoMimics);

        // --- production
        // Note: all the info required for prod actor assets and cameras is
        // contained in repo.actors/cameras
        writer.writeProductionStart();
        writer.writeProductionSettings(1, 9999, 0);
        writer.writeProductionPlacement(placementTag, origin.pos, origin.rot);
        writer.writeProductionAssets(
            repoActors, repoItems, repoCameras, prodPoses, prodAnims, prodMimics, repoAnims); // adding duration to production

        // --- storyboard
        // -- collect shot settings
        writer.writeStoryboardStart();
        writer.writeStoryboardDefaults(
            boardShots[0].actorPlacement,
            boardShots[0].actorPose,
        );
        writer.writeStoryboardSection("section_storyboard_ui", boardShots);

        // --- dialogscript
        writer.writeDialogscriptStart();
        writer.writeDialogscriptActors(repoActors);
        writer.writeDialogscriptItems(repoItems);

        writer.writeDialogscriptStartSection(
            "section_start", "section_storyboard_ui");

        writer.writeDialogscriptSection(
            "section_storyboard_ui", dlgSectionShots, "section_exit");

        writer.writeDialogscriptExitSection("section_exit");
    }
    // ------------------------------------------------------------------------
}
