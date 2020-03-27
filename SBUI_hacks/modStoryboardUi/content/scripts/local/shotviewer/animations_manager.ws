// -----------------------------------------------------------------------------
//
// BUGS:
//
// TODO:
//  - adjust animation list with flags: isHuman, isMonster, isMan, isWoman,
//      isAnimal and use the information to prefilter (without triggering animations)
//
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
class CModSbUiAnimationList extends CModUiFilteredList {
    // ------------------------------------------------------------------------
    public function createCompatibleList(
        actor: CModStoryBoardActor, animInfo: CStoryBoardAnimationMetaInfo) : int
    {
        var mimicsMeta: CStoryBoardMimicsMetaInfo;

        mimicsMeta = (CStoryBoardMimicsMetaInfo)animInfo;

        items.Clear();

        // first entry of animation lists is defined as no anim (id == 0)!
        items.PushBack(SModUiCategorizedListItem(
            0,
            animInfo.animList[0].caption,
            animInfo.animList[0].cat1,
            animInfo.animList[0].cat2,
            animInfo.animList[0].cat3,
        ));

        if (mimicsMeta) {
            filterMimicsAnimations(actor, mimicsMeta);
        } else {
            filterNormalAnimations(actor, animInfo);
        }

        // anim compatibility probing plays animations -> last animation will
        // play to the end. looks strange -> prevent this
        actor.resetCompatibilityCheckAnimations();

        return items.Size();
    }
    // ------------------------------------------------------------------------
    private function filterNormalAnimations(
        actor: CModStoryBoardActor, animInfo: CStoryBoardAnimationMetaInfo)
    {
        var i: int;
        // create a compatible list of animations by actor
        for (i = 1; i < animInfo.animList.Size(); i += 1) {

            if (actor.isCompatibleAnimation(animInfo.animList[i].id)) {
                items.PushBack(SModUiCategorizedListItem(
                    // use numerical id (0 is defined as no anim!)
                    i,
                    animInfo.animList[i].caption,
                    animInfo.animList[i].cat1,
                    animInfo.animList[i].cat2,
                    animInfo.animList[i].cat3,
                ));
            }
        }
    }
    // ------------------------------------------------------------------------
    private function filterMimicsAnimations(
        actor: CModStoryBoardActor, animInfo: CStoryBoardMimicsMetaInfo)
    {
        var i: int;
        // create a compatible list of *mimics* animations by actor
        for (i = 1; i < animInfo.animList.Size(); i += 1) {

            if (actor.isCompatibleMimicsAnimation(animInfo.animList[i].id)) {
                items.PushBack(SModUiCategorizedListItem(
                    // use numerical id (0 is defined as no anim!)
                    i,
                    animInfo.animList[i].caption,
                    animInfo.animList[i].cat1,
                    animInfo.animList[i].cat2,
                    animInfo.animList[i].cat3,
                ));
            }
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
struct SStoryBoardAnimationInfo {
    var path: String;
    var cat1: String;
    var cat2: String;
    var cat3: String;
    var id: CName;
    var caption: String;
    var frames: int;
}
// ----------------------------------------------------------------------------
// Wrapper class so list can be passed by reference
class CStoryBoardAnimationMetaInfo {
    // contains info about all animations. the slot number for an animation will
    // be used as id in the filtered UI listview. this is required as the UI
    // returns the selected option id as string and there is no string -> name
    // conversion available but playing animations requires the anim name as CName.
    // meaning: this array is also used as ui selected anim id -> cname anim id LUT
    public var animList: array<SStoryBoardAnimationInfo>;
    // ------------------------------------------------------------------------
    public function loadCsv(path: String) {
        var data: C2dArray;
        var i: int;

        data = LoadCSV(path);

        animList.Clear();
        // provide entry for "empty" (aka no) animation
        animList.PushBack(SStoryBoardAnimationInfo(,,,,'no animation', "-no animation-", 0));
        // csv: path;CAT1;CAT2;CAT3;id;caption;frames
        for (i = 0; i < data.GetNumRows(); i += 1) {
            animList.PushBack(SStoryBoardAnimationInfo(
                data.GetValueAt(0, i),
                data.GetValueAt(1, i),
                data.GetValueAt(2, i),
                data.GetValueAt(3, i),
                data.GetValueAtAsName(4, i),
                data.GetValueAt(5, i),
                StringToInt(data.GetValueAt(6, i))
            ));
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CStoryBoardMimicsMetaInfo extends CStoryBoardAnimationMetaInfo {}
// ----------------------------------------------------------------------------
// Management of animations for actor assets per storyboard shot.
//  - selecting animation from available (actor compatible) list of animations
//
class CModStoryBoardAnimationListsManager {
    // ------------------------------------------------------------------------
    private var compatibleAnimationCount: int;
    protected var dataLoaded: Bool;
    // ------------------------------------------------------------------------
    // contains info about all animations. the slot number for an animation will
    // be used as id in the filtered UI listview. this is required as the UI
    // returns the selected option id as string and there is no string -> name
    // conversion available but playing animations requires the anim name as CName.
    // meaning: this array is also used as ui selected anim id -> cname anim id LUT
    protected var animMeta: CStoryBoardAnimationMetaInfo;
    // ------------------------------------------------------------------------
    public function init() { }
    // ------------------------------------------------------------------------
    protected function lazyLoad() {
        animMeta = new CStoryBoardAnimationMetaInfo in this;
        animMeta.loadCsv("dlc\storyboardui\data\actor_animations.csv");
        dataLoaded = true;
    }
    // ------------------------------------------------------------------------
    public function activate() {
    }
    // ------------------------------------------------------------------------
    public function deactivate() {
    }
    // ------------------------------------------------------------------------
    public function getAnimationListFor(actor: CModStoryBoardActor)
        : CModSbUiAnimationList
    {
        var actorAnims: CModSbUiAnimationList;
        var i: int;

        if (!dataLoaded) { lazyLoad(); }

        actorAnims = new CModSbUiAnimationList in this;
        compatibleAnimationCount = actorAnims.createCompatibleList(actor, animMeta);

        return actorAnims;
    }
    // ------------------------------------------------------------------------
    public function getAnimationCount() : int {
        return compatibleAnimationCount;
    }
    // ------------------------------------------------------------------------
    public function getAnimationName(selectedUiId: int) : CName {
        if (!dataLoaded) { lazyLoad(); }

        return animMeta.animList[selectedUiId].id;
    }
    // ------------------------------------------------------------------------
    public function getAnimationFrameCount(selectedUiId: int) : int {
        if (!dataLoaded) { lazyLoad(); }

        return animMeta.animList[selectedUiId].frames;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CModStoryBoardMimicsListsManager extends CModStoryBoardAnimationListsManager
{
    // ------------------------------------------------------------------------
    protected function lazyLoad() {
        animMeta = new CStoryBoardMimicsMetaInfo in this;
        animMeta.loadCsv("dlc\storyboardui\data\actor_mimics.csv");
        dataLoaded = true;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
