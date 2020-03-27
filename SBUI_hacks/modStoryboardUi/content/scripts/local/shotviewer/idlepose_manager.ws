// -----------------------------------------------------------------------------
//
// BUGS:
//
// TODO:
//
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
class CModSbUiIdlePoseList extends CModUiFilteredList {
    // ------------------------------------------------------------------------
    public function createCompatibleList(
        actor: CModStoryBoardActor, idlePoseInfo: CStoryBoardIdlePoseMetaInfo) : int
    {
        var i: int;

        items.Clear();

        // first entry of animation lists is defined as no/default pose (id == 0)!
        items.PushBack(SModUiCategorizedListItem(
            0,
            idlePoseInfo.idlePoseList[0].caption,
            idlePoseInfo.idlePoseList[0].cat1,
            idlePoseInfo.idlePoseList[0].cat2,
            idlePoseInfo.idlePoseList[0].cat3,
        ));

        // create a compatible list of animations by actor
        for (i = 1; i < idlePoseInfo.idlePoseList.Size(); i += 1) {

            if (actor.isCompatibleAnimation(idlePoseInfo.idlePoseList[i].id)) {
                items.PushBack(SModUiCategorizedListItem(
                    // use numerical id (0 is defined as no anim!)
                    i,
                    idlePoseInfo.idlePoseList[i].caption,
                    idlePoseInfo.idlePoseList[i].cat1,
                    idlePoseInfo.idlePoseList[i].cat2,
                    idlePoseInfo.idlePoseList[i].cat3,
                ));
            }
        }

        // anim compatibility probing plays animations -> last animation will
        // play to the end. looks strange -> prevent this
        actor.resetCompatibilityCheckAnimations();

        return items.Size();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
struct SStoryBoardIdlePoseInfo {
    var type: int;
    var cat1: String;
    var cat2: String;
    var cat3: String;
    var id: CName;
    var caption: String;
    // requried for w2scenes
    var posename: String;
    var emoState: String;
    var status: String;
}
// ----------------------------------------------------------------------------
struct SStoryBoardDefaultPoseInfo {
    var uId: int;
    var type: int;
    var animId: CName;
}
// ----------------------------------------------------------------------------
// Wrapper class so list can be passed by reference
class CStoryBoardIdlePoseMetaInfo {
    // contains info about all idle pose animations. the slot number for a pose
    // anim be used as id in the filtered UI listview. this is required as the UI
    // returns the selected option id as string and there is no string -> name
    // conversion available but playing animations requires the anim name as CName.
    // meaning: this array is also used as ui selected anim id -> cname anim id LUT
    public var idlePoseList: array<SStoryBoardIdlePoseInfo>;
    // list of preselected default idle anims to probe right after actor creation
    // to use as default "pose" and prevent strange behavior (actor moving/rotating
    // triggered by behTrees after teleporting)
    public var defaultPoseList: array<SStoryBoardDefaultPoseInfo>;
    // ------------------------------------------------------------------------
    public function loadCsv(path: String) {
        var data: C2dArray;
        var i, actorType: int;

        data = LoadCSV(path);

        idlePoseList.Clear();
        defaultPoseList.Clear();

        // provide entry for "empty" (aka no) animation
        idlePoseList.PushBack(SStoryBoardIdlePoseInfo(,,,,'default', "-default pose-",,,));
        // csv: default;type;CAT1;CAT2;CAT3;id;caption;posename;emoState;status
        for (i = 1; i < data.GetNumRows(); i += 1) {
            actorType = StringToInt(data.GetValueAt(1, i), -1);
            if (data.GetValueAt(0, i) != "") {
                defaultPoseList.PushBack(SStoryBoardDefaultPoseInfo(
                    i, actorType, data.GetValueAtAsName(5, i)));
            }

            idlePoseList.PushBack(SStoryBoardIdlePoseInfo(
                actorType,
                data.GetValueAt(2, i),
                data.GetValueAt(3, i),
                data.GetValueAt(4, i),
                data.GetValueAtAsName(5, i),
                data.GetValueAt(6, i),
                data.GetValueAt(7, i),
                data.GetValueAt(8, i),
                data.GetValueAt(9, i)
            ));
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// Management of animations for actor assets per storyboard shot.
//  - selecting animation from available (actor compatible) list of animations
//
class CModStoryBoardIdlePoseListsManager {
    // ------------------------------------------------------------------------
    private var compatiblePosesCount: int;
    protected var dataLoaded: Bool;
    // ------------------------------------------------------------------------
    // contains info about all idle pose animations. the slot number for a pose
    // anim be used as id in the filtered UI listview. this is required as the UI
    // returns the selected option id as string and there is no string -> name
    // conversion available but playing animations requires the anim name as CName.
    // meaning: this array is also used as ui selected anim id -> cname anim id LUT
    protected var idlePoseMeta: CStoryBoardIdlePoseMetaInfo;
    // ------------------------------------------------------------------------
    public function init() { }
    // ------------------------------------------------------------------------
    protected function lazyLoad() {
        idlePoseMeta = new CStoryBoardIdlePoseMetaInfo in this;
        idlePoseMeta.loadCsv("dlc\storyboardui\data\actor_idle_animations.csv");
        dataLoaded = true;
    }
    // ------------------------------------------------------------------------
    public function activate() {}
    // ------------------------------------------------------------------------
    public function deactivate() {}
    // ------------------------------------------------------------------------
    public function getIdlePoseListFor(actor: CModStoryBoardActor)
        : CModSbUiIdlePoseList
    {
        var actorIdlePoses: CModSbUiIdlePoseList;
        var i: int;

        if (!dataLoaded) { lazyLoad(); }

        actorIdlePoses = new CModSbUiIdlePoseList in this;
        compatiblePosesCount = actorIdlePoses.createCompatibleList(actor, idlePoseMeta);

        return actorIdlePoses;
    }
    // ------------------------------------------------------------------------
    public function getIdlePoseCount() : int {
        return compatiblePosesCount;
    }
    // ------------------------------------------------------------------------
    public function getDefaultIdleAnimFor(actor: CModStoryBoardActor) : CName {
        var result: CName;
        var type: int = (int)actor.getActorType();
        var i: int;

        if (!dataLoaded) { lazyLoad(); }

        if (type == (int)ESB_AT_Unknown) {
            // search all
            for (i = 0; i < idlePoseMeta.defaultPoseList.Size(); i += 1) {
                if (actor.isCompatibleAnimation(idlePoseMeta.defaultPoseList[i].animId))
                {
                    return idlePoseMeta.defaultPoseList[i].animId;
                }
            }

        } else {
            // two search runs (type specific + category as fallback):

            // 1. type specific
            for (i = 0; i < idlePoseMeta.defaultPoseList.Size(); i += 1) {
                if (idlePoseMeta.defaultPoseList[i].type == type &&
                    actor.isCompatibleAnimation(
                        idlePoseMeta.defaultPoseList[i].animId))
                {
                    return idlePoseMeta.defaultPoseList[i].animId;
                }
            }

            // 2. category specific (categories have 30 slots (as of now))
            type = (type / 30);
            for (i = 0; i < idlePoseMeta.defaultPoseList.Size(); i += 1) {

                if (idlePoseMeta.defaultPoseList[i].type / 30 == type &&
                    actor.isCompatibleAnimation(
                        idlePoseMeta.defaultPoseList[i].animId))
                {
                    return idlePoseMeta.defaultPoseList[i].animId;
                }
            }
        }

        return '';
    }
    // ------------------------------------------------------------------------
    public function getPoseInformation(selectedUiId: int) : SStoryBoardIdlePoseInfo {
        var info: SStoryBoardIdlePoseInfo;

        if (!dataLoaded) { lazyLoad(); }

        if (selectedUiId >= 0) {
            info = idlePoseMeta.idlePoseList[selectedUiId];
        }
        return info;
    }
    // ------------------------------------------------------------------------
    public function getIdleAnimationName(selectedUiId: int) : CName {
        if (!dataLoaded) { lazyLoad(); }

        return idlePoseMeta.idlePoseList[selectedUiId].id;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
