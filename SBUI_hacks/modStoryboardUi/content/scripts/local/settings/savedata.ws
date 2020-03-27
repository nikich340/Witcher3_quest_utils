// ----------------------------------------------------------------------------
//
// BUGS:
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
struct SStoryBoardActorStateData {
    var id: String;
    var assetname: String;
    var userSetName: bool;
    var templatePath: String;
    var appearanceId: int;
    var defaultIdleAnim: CName;
}
struct SStoryBoardItemStateData {
    var id: String;
    var assetname: String;
    var userSetName: bool;
    var templatePath: String;
}
// ----------------------------------------------------------------------------
struct SStoryBoardAssetsStateData {
    var lastuid: int;
    var actorData: array<SStoryBoardActorStateData>;
    var itemData: array<SStoryBoardItemStateData>;
}
// ----------------------------------------------------------------------------
struct SStoryBoardShotStateData {
    var shotname: String;
    var camera: SStoryBoardCameraSettings;
    var assets: array<SStoryBoardShotAssetSettings>;
}
// ----------------------------------------------------------------------------
struct SStoryBoardOriginStateData {
    var assetId: String;
    var pos: Vector;
    var rot: EulerAngles;
}
// ----------------------------------------------------------------------------
class CModStoryBoardStateData extends IModStorageData {
    // ------------------------------------------------------------------------
    default id = 'StoryBoardUi';
    // ------------------------------------------------------------------------
    public var origin: SStoryBoardOriginStateData;
    public var assetData: SStoryBoardAssetsStateData;
    public var shotData: array<SStoryBoardShotStateData>;
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
