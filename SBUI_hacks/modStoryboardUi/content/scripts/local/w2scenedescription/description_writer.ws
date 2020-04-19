// ----------------------------------------------------------------------------
struct SSbDescActor {
    // internalId for matching - not for exposure
    var uId: String;
    var repoActorId: String;
    var template: String;
    var appearance: String;
    var isPlayer: bool;
}
// ----------------------------------------------------------------------------
struct SSbDescItem {
    // internalId for matching - not for exposure
    var uId: String;
    var repoItemId: String;
    var template: String;
}
// ----------------------------------------------------------------------------
struct SSbDescCamera {
    // internalId for matching - not for exposure
    var uId: String;
    var repoCamId: String;
    var pos: Vector;
    var rot: EulerAngles;
    var fov: float;
    var dof: SStoryBoardCameraDofSettings;
}
// ----------------------------------------------------------------------------
struct SSbDescIdlePose {
    var repoPoseId: String;
    var idleAnimName: String;   // forcedIdleAnim
    // additional (optional) info used by
    var poseName: String;
    var poseStatus: String;
    var poseEmotionalState: String;
}
// ----------------------------------------------------------------------------
struct SSbDescAnimation {
    var uId: int;
    var repoAnimId: String;
    var animName: String;
    var frames: int;
}
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
struct SSbDescProdIdlePose {
    var prodPoseId: String;
    var prodActorId: String;
    var repoPoseId: String;
}
// ----------------------------------------------------------------------------
struct SSbDescProdAnimation {
    var prodAnimId: String;
    var prodActorId: String;
    var repoAnimId: String;
}
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
struct SSbDescEventIdlePose {
    var prodPoseId: String;
    // actorId is a cloned info from prodPose to prevent search for prodIdlePose
    // just to extract the actor (which is required for storyboard defaults)
    var _prodActorId: String;
}
// ----------------------------------------------------------------------------
struct SSbDescEventAnim {
    var prodAnimId: String;
    //TODO later maybe add blendin/out
}
// ----------------------------------------------------------------------------
struct SSbDescEventVisibility {
    var prodAssetId: String;
    var hide: Bool;
}
// ----------------------------------------------------------------------------
struct SSbDescEventLookAt {
    var prodActorId: String;
    var lookAtProdActorId: String;
    var pos: Vector;
}
// ----------------------------------------------------------------------------
struct SSbDescEventPlacement {
    var prodAssetId: String;
    var pos: Vector;
    var rot: EulerAngles;
}
// ----------------------------------------------------------------------------
struct SSbDescStoryboardShot {
    var shotId: String;
    var infoShotname: String;

    var camIdChange: String;

    var actorPose: array<SSbDescEventIdlePose>;
    var actorAnim: array<SSbDescEventAnim>;
    var actorMimic: array<SSbDescEventAnim>;
    var actorLookAt: array<SSbDescEventLookAt>;
    var actorPlacement: array<SSbDescEventPlacement>;
    var actorVisibility: array<SSbDescEventVisibility>;

    var itemPlacement: array<SSbDescEventPlacement>;
    var itemVisibility: array<SSbDescEventVisibility>;
}
// ----------------------------------------------------------------------------
struct SSbDescDialogLine {
    var prodActorId: String;
    var id: int;
    var str: String;
    var duration: float;
}
// ----------------------------------------------------------------------------
struct SSbDescDialogShot {
    var shotId: String;
    var infoShotname: String;

    var duration: float;
    var lines: array<SSbDescDialogLine>;
    // (longest) anim name defining duration
    var infoAnimId: String;
}
// ----------------------------------------------------------------------------
// output for w2encoder requires always a format with .n (1 -> 1.0)
function SbUiFloatToString(value: float) : String {
    var str: String;

    str = FloatToStringPrec(value, 10);
    if (StrFindFirst(str, ".") >= 0) {
        return str;
    }
    return str + ".0";
}
// ----------------------------------------------------------------------------
// writer for w2scene encoder YAML (only the required parts...)
class CModSbUiW2SceneDescriptionWriter {
    private var backslash: String;
    // ------------------------------------------------------------------------
    public function init() {
        backslash = StrLeft("\\", 1);
        log("#-- STORYBOARD UI - SCENE DUMP -------------------------------------------------");
    }
    // ------------------------------------------------------------------------
    private function padLineId(lineId: int) : String {
        return StrRight("0000000000" + IntToString(lineId), 10);
    }
    // ------------------------------------------------------------------------
    private function toVec2Str(vec: Vector) : String {
        return
            "[ " + SbUiFloatToString(vec.X) +
            ", " + SbUiFloatToString(vec.Y) +
            " ]";
    }
    // ------------------------------------------------------------------------
    private function toVecStr(pos: Vector) : String {
        return
            "[ " + SbUiFloatToString(pos.X) +
            ", " + SbUiFloatToString(pos.Y) +
            ", " + SbUiFloatToString(pos.Z) +
            " ]";
    }
    // ------------------------------------------------------------------------
    private function toVec4Str(pos: Vector) : String {
        return
            "[ " + SbUiFloatToString(pos.X) +
            ", " + SbUiFloatToString(pos.Y) +
            ", " + SbUiFloatToString(pos.Z) +
            ", " + SbUiFloatToString(pos.W) +
            " ]";
    }
    // ------------------------------------------------------------------------
    private function toAnglesStr(rot: EulerAngles) : String {
        // ATTENTION!!! order is DIFFERENT in the cr2w resources!
        return
            "[ " + SbUiFloatToString(rot.Roll) +
            ", " + SbUiFloatToString(rot.Pitch) +
            ", " + SbUiFloatToString(rot.Yaw) +
            " ]";
    }
    // ------------------------------------------------------------------------
    private function toScriptAnglesStr(rot: EulerAngles) : String {
        // ATTENTION!!! this information is ONLY for usage in scripts. therefore
        // order is not changed!
        return
            "[ " + SbUiFloatToString(rot.Pitch) +
            ", " + SbUiFloatToString(rot.Yaw) +
            ", " + SbUiFloatToString(rot.Roll) +
            " ]";
    }
    // ------------------------------------------------------------------------
    private function log(msg: String) {
        LogChannel('W2SCENE', msg);
    }
    // ------------------------------------------------------------------------
    private function logComment(indent: String, msg: String) {
        log(indent + "# " + msg);
    }
    // ------------------------------------------------------------------------
    private function logKey(
        indent: String, key: String, optional quoted: bool, optional isComment: bool)
    {
        if (isComment) {
            indent = indent + "#";
        }
        if (quoted) {
            log(indent + "\"" + key + "\":");
        } else {
            log(indent + key + ":");
        }
    }
    // ------------------------------------------------------------------------
    private function logKv(
        indent: String, key: String, value: String, optional isComment: bool)
    {
        if (isComment) {
            log(indent + "  #" + key + ": " + value);
        } else {
            log(indent + "  " + key + ": " + value);
        }
    }
    // ------------------------------------------------------------------------
    private function logListKv(
        indent: String, key: String, value: String, optional isComment: bool)
    {
        if (isComment) {
            log(indent + "  #- " + key + ": " + value);
        } else {
            log(indent + "  - " + key + ": " + value);
        }
    }
    // ------------------------------------------------------------------------
    private function logKv_Str(
        indent: String, key: String, value: String, optional isComment: bool)
    {
        logKv(indent, key, "\"" + StrReplaceAll(value, backslash, "\\") + "\"", isComment);
    }
    // ------------------------------------------------------------------------
    private function logKv_Float(
        indent: String, key: String, value: Float, optional isComment: bool)
    {
        logKv(indent, key, SbUiFloatToString(value), isComment);
    }
    // ------------------------------------------------------------------------
    private function logKv_Int(
        indent: String, key: String, value: Int, optional isComment: bool)
    {
        logKv(indent, key, IntToString(value), isComment);
    }
    // ------------------------------------------------------------------------
    private function logKv_Bool(
        indent: String, key: String, value: Bool, optional isComment: bool) {
        logKv(indent, key, value, isComment);
    }
    // ------------------------------------------------------------------------
    private function logKv_ListStr(
        indent: String, key: String, values: array<String>, optional isComment: bool)
    {
        var i: int;
        var elements: String;

        elements = "\"" + StrReplaceAll(values[0], backslash, "\\") + "\"";

        for (i = 1; i < values.Size(); i += 1) {
            elements += ", \"" + StrReplaceAll(values[i], backslash, "\\") + "\"";
        }

        logKv(indent, key, "[ " + elements + " ]", isComment);
    }
    // ------------------------------------------------------------------------
    private function logKv_ListStr1(
        indent: String, key: String,
        value: String, optional isComment: bool)
    {
        logKv(indent, key, "[ \"" + StrReplaceAll(value, backslash, "\\") + "\" ]", isComment);
    }
    // ------------------------------------------------------------------------
    private function logKv_ListFloat2(
        indent: String, key: String,
        value1: float, value2: float, optional isComment: bool)
    {
        logKv(indent, key,
            "[ " + SbUiFloatToString(value1) +
            ", " + SbUiFloatToString(value2) +
            " ]", isComment);
    }
    // ------------------------------------------------------------------------
    private function logKv_ListFloat4(
        indent: String, key: String,
        value1: float, value2: float, value3: float, value4: float,
        optional isComment: bool)
    {
        logKv(indent, key,
            "[ " + SbUiFloatToString(value1) +
            ", " + SbUiFloatToString(value2) +
            ", " + SbUiFloatToString(value3) +
            ", " + SbUiFloatToString(value4) +
            " ]", isComment);
    }
    // ------------------------------------------------------------------------
    private function logList_Kv_Str(
        indent: String, key: String, value: String, optional isComment: bool)
    {
        logListKv(indent, key, value, isComment);
    }
    // ------------------------------------------------------------------------
    private function logList_Kv_Float(indent: String, key: String, value: Float) {
        logListKv(indent, key, SbUiFloatToString(value));
    }
    // ------------------------------------------------------------------------
    // ------------------------------------------------------------------------
    private function writeRepoActor(parentIndent: String, data: SSbDescActor) {
        var indent: String = parentIndent + "  ";

        logKey(indent, data.repoActorId);
        logKv_Str(indent, "template", data.template);
        if (!data.isPlayer) {
            logKv_ListStr1(indent, "appearance", data.appearance);
        }
        log("");
    }
    // ------------------------------------------------------------------------
    private function writeRepoItem(parentIndent: String, data: SSbDescItem) {
        var indent: String = parentIndent + "  ";

        logKey(indent, data.repoItemId);
        logKv_Str(indent, "template", data.template);
        log("");
    }
    // ------------------------------------------------------------------------
    private function writeRepoAnim(parentIndent: String, data: SSbDescAnimation) {
        var indent: String = parentIndent + "  ";

        logKey(indent, data.repoAnimId);
        logKv_Str(indent, "animation", data.animName);
        logKv_Int(indent, "frames", data.frames);
        log("");
    }
    // ------------------------------------------------------------------------
    private function writeRepoPose(parentIndent: String, data: SSbDescIdlePose) {
        var indent: String = parentIndent + "  ";

        logKey(indent, data.repoPoseId);
        if (data.poseName != "") {
            logKv_Str(indent, "name", data.poseName);
        }
        if (data.poseEmotionalState != "") {
            logKv_Str(indent, "emotional_state", data.poseEmotionalState);
        }
        if (data.poseStatus != "") {
            logKv_Str(indent, "status", data.poseStatus);
        }
        // this is not optional!
        logKv_Str(indent, "idle_anim", data.idleAnimName);
        log("");
    }
    // ------------------------------------------------------------------------
    private function writeRepoCam(parentIndent: String, data: SSbDescCamera) {
        var indent1: String = parentIndent + "  ";
        var indent2: String = indent1 + "  ";

        logKey(indent1, data.repoCamId);
        logKv_Float(indent1, "fov", data.fov);

        logKey(indent2, "transform");
        logKv(indent2, "pos", toVecStr(data.pos));
        logKv(indent2, "rot", toAnglesStr(data.rot));

        logKv_Float(indent1, "zoom", 1.0, true);

        logKey(indent2, "dof");
        // default values (ripped from some existing scene camera) for aperture
        logKv(indent2, "aperture", toVec2Str(Vector(28.25, 1.27)), true);
        logKv(indent2, "blur", toVec2Str(Vector(data.dof.blurNear, data.dof.blurFar)));
        logKv(indent2, "focus", toVec2Str(Vector(data.dof.focusNear, data.dof.focusFar)));
        logKv_Float(indent2, "intensity", data.dof.strength);

        logKey(indent2, "event_generator");
        logKv_Str(indent2, "plane", "medium");
        logKv_ListStr1(indent2, "tags", "ext");
        log("");
    }
    // ------------------------------------------------------------------------
    public function writeRepository(
        actors: array<SSbDescActor>,
        items: array<SSbDescItem>,
        cameras: array<SSbDescCamera>,
        poses: array<SSbDescIdlePose>,
        anims: array<SSbDescAnimation>,
        mimics: array<SSbDescAnimation>)
    {
        var indent: String = "  ";
        var i: int;

        logKey("", "repository");

        logKey(indent, "actors");
        for (i = 0; i < actors.Size(); i += 1) {
            writeRepoActor(indent, actors[i]);
        }

        if (items.Size() > 0) {
            logKey(indent, "props");
            for (i = 0; i < items.Size(); i += 1) {
                writeRepoItem(indent, items[i]);
            }
        }

        if (anims.Size() > 0) {
            logKey(indent, "animations");
            for (i = 0; i < anims.Size(); i += 1) {
                writeRepoAnim(indent, anims[i]);
            }
        }

        if (mimics.Size() > 0) {
            logKey(indent, "animations.mimic");
            for (i = 0; i < mimics.Size(); i += 1) {
                writeRepoAnim(indent, mimics[i]);
            }
        }

        if (poses.Size() > 0) {
            logKey(indent, "actor.poses");
            for (i = 0; i < poses.Size(); i += 1) {
                writeRepoPose(indent, poses[i]);
            }
        }

        logKey(indent, "cameras");
        for (i = 0; i < cameras.Size(); i += 1) {
            writeRepoCam(indent, cameras[i]);
        }
    }
    // ------------------------------------------------------------------------
    // ------------------------------------------------------------------------
    private function writeProdActor(parentIndent: String, data: SSbDescActor) {
        var indent: String = parentIndent + "  ";
        var tags: array<String>;

        logKey(indent, data.repoActorId);
        logKv_Str(indent, "repo", data.repoActorId);

        if (data.isPlayer) {
            logKv_Bool(indent, "by_voicetag", true);
            tags.PushBack("PLAYER");
        } else {
            logKv_Bool(indent, "by_voicetag", true, true);
            tags.PushBack(data.repoActorId);

            if (data.appearance != "") {
                logKv_Str(indent, "appearance", data.appearance);
            }
        }

        logKv_ListStr(indent, "tags", tags);
        log("");
    }
    // ------------------------------------------------------------------------
    private function writeProdItem(parentIndent: String, data: SSbDescItem) {
        var indent: String = parentIndent + "  ";
        var tags: array<String>;

        logKey(indent, data.repoItemId);
        logKv_Str(indent, "repo", data.repoItemId);
        log("");
    }
    // ------------------------------------------------------------------------
    private function writeProdCams(parentIndent: String, data: SSbDescCamera) {
        var indent: String = parentIndent + "  ";

        logKey(indent, data.repoCamId);
        logKv_Str(indent, "repo", data.repoCamId);
        log("");
    }
    // ------------------------------------------------------------------------
    private function writeProdPoses(parentIndent: String, data: SSbDescProdIdlePose)
    {
        var indent: String = parentIndent + "  ";

        logKey(indent, data.prodPoseId);
        logKv_Str(indent, "actor", data.prodActorId);
        logKv_Str(indent, "repo", data.repoPoseId);
        log("");
    }
    // ------------------------------------------------------------------------
    private function writeProdAnims(
        parentIndent: String, data: SSbDescProdAnimation, blendTime: float, optional animDuration : SSbDescAnimation)
    {
        var indent: String = parentIndent + "  ";

        logKey(indent, data.prodAnimId);
        logKv_Str(indent, "actor", data.prodActorId);
        logKv_Str(indent, "repo", data.repoAnimId);

        // it is very convenient to see this when needing to use clipfront/clipend
        logKv_Float(indent, "duration",  ((float)animDuration.frames) /30 , true);
        logKv_Float(indent, "weight", 0.6, true);
        logKv_Float(indent, "clipfront", 0.0, true);
        logKv_Float(indent, "clipend", 99.0, true);
        logKv_Float(indent, "stretch", 1.0, true);
        logKv_Float(indent, "blendin", blendTime);
        logKv_Float(indent, "blendout", blendTime);
        log("");
    }
    // ------------------------------------------------------------------------
    public function writeProductionStart() {
        logKey("", "production");
    }
    // ------------------------------------------------------------------------
    public function writeProductionSettings(
        sceneId: int, stringsIdSpace: int, stringsIdStart: int)
    {
        var indent: String = "  ";

        logKey(indent, "settings");
        logKv_Int(indent, "sceneid", sceneId);
        logKv_Int(indent, "strings-idspace", stringsIdSpace, true);
        logKv_Int(indent, "strings-idstart", stringsIdStart, true);

        log("");
    }
    // ------------------------------------------------------------------------
    public function writeProductionPlacement(
        placementTag: String, originPos: Vector, originRot: EulerAngles)
    {
        var indent: String = "  ";
        var indent2: String = indent + "  ";

        logKv_Str("", "placement", placementTag);

        logComment(indent2, "INFO: world coordinates of used origin:");
        logKv(indent2, "pos", toVecStr(originPos), true);
        logKv(indent2, "rot", toScriptAnglesStr(originRot), true);

        log("");
    }
    // ------------------------------------------------------------------------
    public function writeProductionAssets(
        actors: array<SSbDescActor>,
        items: array<SSbDescItem>,
        cameras: array<SSbDescCamera>,
        poses: array<SSbDescProdIdlePose>,
        anims: array<SSbDescProdAnimation>,
        mimics: array<SSbDescProdAnimation>,
        optional animDuration: array<SSbDescAnimation>) // adding optional animation duration
    {
        var indent1: String = "  ";
        var indent2: String = indent1 + "  ";
        var i: int;

        logKey(indent1, "assets");

        logKey(indent2, "actors");
        for (i = 0; i < actors.Size(); i += 1) {
            writeProdActor(indent2, actors[i]);
        }

        if (items.Size() > 0) {
            logKey(indent2, "props");
            for (i = 0; i < items.Size(); i += 1) {
                writeProdItem(indent2, items[i]);
            }
        }

        logKey(indent2, "cameras");
        for (i = 0; i < cameras.Size(); i += 1) {
            writeProdCams(indent2, cameras[i]);
        }

        // rest is specialized for prod (binding to actors)
        if (anims.Size() > 0) {
            logKey(indent2, "animations");
            for (i = 0; i < anims.Size(); i += 1) {
                // blends need to be set to 0.0 cause the automatic blending
                // looks bad most of the time. needs to be manually adjusted for
                // every animation...
                writeProdAnims(indent2, anims[i], 0.0, animDuration[i]); // added animation duration
            }
        }

        if (mimics.Size() > 0) {
            logKey(indent2, "animations.mimic");
            for (i = 0; i < mimics.Size(); i += 1) {
                writeProdAnims(indent2, mimics[i], 0.5);
            }
        }

        if (poses.Size() > 0) {
            logKey(indent2, "actor.poses");
            for (i = 0; i < poses.Size(); i += 1) {
                writeProdPoses(indent2, poses[i]);
            }
        }
    }
    // ------------------------------------------------------------------------
    // ------------------------------------------------------------------------
    private function toOptionStr(time: Float, value: String) : String {
        return "[" + SbUiFloatToString(time) + ", " + value + "]";
    }
    // ------------------------------------------------------------------------
    private function toOptionStr2(time: Float, value: String, value2: String) : String
    {
        return "[" + SbUiFloatToString(time) + ", " + value + ", " + value2 + "]";
    }
    // ------------------------------------------------------------------------
    private function toOptionStr3(time: Float,
        value: String, value2: String, value3: String) : String
    {
        return "[" + SbUiFloatToString(time) + ", " + value + ", " + value2 + ", " + value3 + "]";
    }
    // ------------------------------------------------------------------------
    private function writeBoardEventCamChange(indent: String, newCam: String) {
        logList_Kv_Str(indent, "cam", toOptionStr(0, newCam));
    }
    // ------------------------------------------------------------------------
    private function writeBoardEventActorAnim(
        indent: String, key: String, data: SSbDescEventAnim)
    {
        logList_Kv_Str(indent, key, toOptionStr(0, data.prodAnimId));
        //TODO: or use extended version with other possible options as comments?
        //logList_Key(indent, key);
        //logKv(indent, ".@pos", toOptionStr(0, data.prodAnimId));
        //logKv_Float(indent, "blendin", 0.5, true);
        //logKv_Float(indent, "blendout", 0.5, true);
        //logKv_Float(indent, "clipfront", 0.1, true);
        //logKv_Float(indent, "clipend", 99.9, true);
        //logKv_Float(indent, "weight", 0.8, true);
        //logKv_Float(indent, "stretch", 1.0, true);
    }
    // ------------------------------------------------------------------------
    private function writeBoardEventAssetVisibility(
        indent: String, assetType: String, data: SSbDescEventVisibility)
    {
        if (data.hide) {
            logList_Kv_Str(indent, assetType + ".hide", toOptionStr(0, data.prodAssetId));
        } else {
            logList_Kv_Str(indent, assetType + ".show", toOptionStr(0, data.prodAssetId));
        }
    }
    // ------------------------------------------------------------------------
    private function writeBoardEventActorLookAt(
        indent: String, data: SSbDescEventLookAt)
    {
        var lookAt: String;
        // - actor.lookat: [0.8, geralt, npc]
        // - actor.lookat: [0.8, geralt, [1.0, 1.0, 1.0]]
        // - actor.lookat:
        //     .@pos: [0.8, geralt, npc] or .@pos: [0.8, geralt, [0.7, 0.1, 0.0]]
        //     # speed > 1.0 => instantly
        //     speed: 0.8
        //     level: head|eyes|body
        if (data.lookAtProdActorId != "") {
            lookAt = data.lookAtProdActorId;
        } else {
            // static point
            lookAt = toVecStr(data.pos);
        }
        logList_Kv_Str(indent, "actor.lookat",
            toOptionStr2(0, data.prodActorId, lookAt));
    }
    // ------------------------------------------------------------------------
    private function writeBoardEventPlacement(
        indent: String, assetType: String, data: SSbDescEventPlacement)
    {
        logList_Kv_Str(indent, assetType + ".placement",
            toOptionStr3(0, data.prodAssetId, toVecStr(data.pos), toAnglesStr(data.rot)));
    }
    // ------------------------------------------------------------------------
    private function writeBoardEventActorPose(
        indent: String, data: SSbDescEventIdlePose)
    {
        logList_Kv_Str(indent, "actor.pose", toOptionStr(0, data.prodPoseId));
    }
    // ------------------------------------------------------------------------
    private function writeBoardSectionShot(indent: String, data: SSbDescStoryboardShot)
    {
        var i: int;

        logComment(indent, "shot " + data.infoShotname);
        logKey(indent, data.shotId);

        // -- actor.placement
        for (i = 0; i < data.actorPlacement.Size(); i += 1) {
            writeBoardEventPlacement(indent, "actor", data.actorPlacement[i]);
        }

        // -- actor.pose
        for (i = 0; i < data.actorPose.Size(); i += 1) {
            writeBoardEventActorPose(indent, data.actorPose[i]);
        }

        // -- actor.show/hide
        for (i = 0; i < data.actorVisibility.Size(); i += 1) {
            writeBoardEventAssetVisibility(indent, "actor", data.actorVisibility[i]);
        }

        // -- item.placement
        for (i = 0; i < data.itemPlacement.Size(); i += 1) {
            writeBoardEventPlacement(indent, "prop", data.itemPlacement[i]);
        }

        // -- item.show/hide
        for (i = 0; i < data.itemVisibility.Size(); i += 1) {
            writeBoardEventAssetVisibility(indent, "prop", data.itemVisibility[i]);
        }

        // -- cam
        if (data.camIdChange != "") {
            writeBoardEventCamChange(indent, data.camIdChange);
        }

        // -- actor.anim
        for (i = 0; i < data.actorAnim.Size(); i += 1) {
            writeBoardEventActorAnim(indent, "actor.anim", data.actorAnim[i]);
        }

        // -- actor.anim.mimic
        for (i = 0; i < data.actorMimic.Size(); i += 1) {
            writeBoardEventActorAnim(indent, "actor.anim.mimic", data.actorMimic[i]);
        }

        // -- actor.lookat
        for (i = 0; i < data.actorLookAt.Size(); i += 1) {
            writeBoardEventActorLookAt(indent, data.actorLookAt[i]);
        }
    }
    // ------------------------------------------------------------------------
    public function writeStoryboardStart() {
        logKey("", "storyboard");
    }
    // ------------------------------------------------------------------------
    public function writeStoryboardDefaults(
        placement: array<SSbDescEventPlacement>, poses: array<SSbDescEventIdlePose>)
    {
        var indent: String = "  ";
        var indent2: String = indent + "  ";
        var i: int;

        logKey(indent, "defaults", false, true);

        if (placement.Size() > 0) {
            logKey(indent2, "placement", false, true);
            for (i = 0; i < placement.Size(); i += 1) {
                logKv(indent2, placement[i].prodAssetId,
                    "[" + toVecStr(placement[i].pos) +
                    ", " + toAnglesStr(placement[i].rot) +
                    "]", true);
            }
            log("");
        }

        if (poses.Size() > 0) {
            logKey(indent2, "actor.pose", false, true);
            for (i = 0; i < poses.Size(); i += 1) {
                logKv(indent2, poses[i]._prodActorId, poses[i].prodPoseId, true);
            }
            log("");
        }
    }
    // ------------------------------------------------------------------------
    public function writeStoryboardSection(
        sectionName: String, boardShotSettings: array<SSbDescStoryboardShot>)
    {
        var indent: String = "  ";
        var indent2: String = indent + "  ";
        var i: int;

        logKey(indent, sectionName);
        for (i = 0; i < boardShotSettings.Size(); i += 1) {
            writeBoardSectionShot(indent2, boardShotSettings[i]);
            log("");
        }
    }
    // ------------------------------------------------------------------------
    // ------------------------------------------------------------------------
    private function writeDialogShot(indent: String, data: SSbDescDialogShot)
    {
        var indent2: String = indent + "  ";
        var line: SSbDescDialogLine;
        var i: int;

        logComment(indent2, "shot " + data.infoShotname);
        logList_Kv_Str(indent, "CUE", data.shotId);

        for (i = 0; i < data.lines.Size(); i += 1) {
            line = data.lines[i];
            if (line.duration > 0.0) {
                logList_Kv_Str(indent,
                    line.prodActorId, "\"[" + SbUiFloatToString(line.duration) + "]"
                        + padLineId(line.id) + "|" + line.str + "\"");
            } else {
                logList_Kv_Str(indent,
                    line.prodActorId, "\"" + padLineId(line.id) + "|" + line.str + "\"");
            }
        }

        // animations do not span elements and are bound to the "dialogline".
        // therefore a following pause element will be useless.
        if (data.lines.Size() > 0) {
            if (data.infoAnimId != "") {
                logComment(indent2, "(longest) anim: " + data.infoAnimId + ": " + data.duration);
            }

        } else {
            if (data.infoAnimId != "") {
                logComment(indent2, "(longest) anim: " + data.infoAnimId);
            }
            logList_Kv_Float(indent, "PAUSE", data.duration);
        }
    }
    // ------------------------------------------------------------------------
    public function writeDialogscriptStart() {
        logKey("", "dialogscript");
    }
    // ------------------------------------------------------------------------
    public function writeDialogscriptActors(repoActors: array<SSbDescActor>) {
        var indent: String = "";
        var actors: array<String>;
        var actor: SSbDescActor;
        var i: int;

        for (i = 0; i < repoActors.Size(); i += 1) {
            actor = repoActors[i];
            if (actor.isPlayer) {
                logKv_Str(indent, "player", actor.repoActorId);
            }

            actors.PushBack(actor.repoActorId);
        }

        logKv_ListStr(indent, "actors", actors);

    }
    // ------------------------------------------------------------------------
    public function writeDialogscriptItems(repoItems: array<SSbDescItem>) {
        var indent: String = "";
        var items: array<String>;
        var i: int;

        for (i = 0; i < repoItems.Size(); i += 1) {
            items.PushBack(repoItems[i].repoItemId);
        }

        if (items.Size() > 0) {
            logKv_ListStr(indent, "props", items);
        }
    }
    // ------------------------------------------------------------------------
    public function writeDialogscriptSection(
        sectionName: String,
        dlgShotSettings: array<SSbDescDialogShot>,
        nextSection: String)
    {
        var indent: String = "  ";
        var i: int;

        logKey(indent, sectionName);
        for (i = 0; i < dlgShotSettings.Size(); i += 1) {
            writeDialogShot(indent, dlgShotSettings[i]);
        }
        logList_Kv_Str(indent, "NEXT", nextSection);
        log("");
    }
    // ------------------------------------------------------------------------
    public function writeDialogscriptStartSection(
        sectionName: String, nextSection: String)
    {
        var indent: String = "  ";
        log("");
        logKey(indent, "section_start");
        logList_Kv_Float(indent, "PAUSE", 0.0);
        logList_Kv_Str(indent, "NEXT", nextSection);
        log("");
    }
    // ------------------------------------------------------------------------
    public function writeDialogscriptExitSection(sectionName: String) {
        var indent: String = "  ";
        logKey(indent, sectionName);
        logList_Kv_Float(indent, "CAMERA_BLEND", 2.0);
        log(indent + "  - EXIT");
        log("");
    }
    // ------------------------------------------------------------------------
}
