// ----------------------------------------------------------------------------
struct SRadishLayerTag {
    var tag: String;
    var world: String;
}
// ----------------------------------------------------------------------------
// Layerdata
// ----------------------------------------------------------------------------
struct SRadishLayerData {
    var world: String;

    var id: String;

    var layername: String;
    var context: String;

    var areas: array<SRadishLayerAreaData>;
    var waypoints: array<SRadishLayerWaypointData>;
    var scenepoints: array<SRadishLayerWaypointData>;
    var mappins: array<SRadishLayerMappinData>;
    var actionpoints: array<SRadishLayerActionpointData>;
    var statics: array<SRadishLayerStaticEntityData>;
    var interactives: array<SRadishLayerInteractiveEntityData>;
}
// ----------------------------------------------------------------------------
struct SRadishLayerWaypointData {
    var id: String;
    var pointname: String;

    var placement: SRadishPlacement;
    var appearance: CName;
}
// ----------------------------------------------------------------------------
struct SRadishLayerMappinData {
    var id: String;
    var pointname: String;

    var placement: SRadishPlacement;
    var radius: Int;
    var appearance: CName;
}
// ----------------------------------------------------------------------------
struct SRadishLayerActionpointData {
    var id: String;
    var pointname: String;

    var placement: SRadishPlacement;
    var action: String;
    var category: String;
    var tags: array<String>;
    var ignoreCollisions: bool;

    var appearance: CName;
}
// ----------------------------------------------------------------------------
struct SRadishLayerStaticEntityData {
    var id: String;
    var entityname: String;

    var placement: SRadishPlacement;
    var scale: Vector;
    var template: String;
    var entityClass: String;

    var appearance: CName;
}
// ----------------------------------------------------------------------------
struct SRadishLayerGenericEntityData {
    var id: String;
    var entityname: String;

    var placement: SRadishPlacement;

    // -- specialization for particles
    var particles: String;
    var particlesPreview: String;

    // --
    var appearance: CName;
}
// ----------------------------------------------------------------------------
struct SRadishLayerInteractiveEntityData {
    var id: String;
    var entityname: String;

    var placement: SRadishPlacement;
    var scale: Vector;
    var template: String;
    var entityClass: String;

    //TODO much more data!

    var appearance: CName;
}
// ----------------------------------------------------------------------------
struct SRadishLayerAreaData {
    var id: String;
    var areaname: String;

    var placement: SRadishPlacement;

    var height: Float;
    var border: array<Vector>;
    // -- specialization for env areas
    var envDef: String;
    var priority: int;
    var blendInTime: Float;
    var blendOutTime: Float;
    var terrainBlendingDistance: Float;
    var blendScale: Float;
    var blendAboveAndBelow: bool;
    var blendDistance: Float;
    // -- specialization for ambient sound areas
    var triggerPrio: int;
    var soundEvent: String;
    var reverbName: String;
    // var soundOnEnter: String;    // not working?
    // var soundOnExit: String;     // not working?
    var maxDistance: Float;
    var maxDistanceVertical: Float;
    var musicParamPriority: bool;
    var paramEnteringTime: Float;
    var paramExitingTime: Float;
    var paramName: String;
    var paramValue: Float;
    var banksDependency: String;
    // --
    var appearance: CName;
}
// ----------------------------------------------------------------------------
// Communities
// ----------------------------------------------------------------------------
struct SRadishCommunityData {
    var id: String;

    var actors: array<SRadishCommunityActorData>;
    var phases: array<SRadishCommunityPhaseData>;
}
// ----------------------------------------------------------------------------
struct SRadishCommunityActorData {
    var id: String;

    var template: String;
    var appearances: array<CName>;
    var tags: array<String>;
    var reactToRain: bool;
}
// ----------------------------------------------------------------------------
struct SRadishCommunityPhaseData {
    var id: String;

    var actors: array<SRadishCommunityActorPhaseData>;
}
// ----------------------------------------------------------------------------
struct SRadishCommunityActorPhaseData {
    var actorid: String;

    // has to be sorted by time!
    var actions: array<SRadishCommunityActionData>;
    var spawntimes: array<SRadishCommunitySpawnData>;
    var spawnpoints: array<SRadishLayerTag>;
    var decorator: array<SRadishCommunityDecorator>;
    var startInAp: bool;
    var useLastAp: bool;
    var spawnHidden: bool;
}
// ----------------------------------------------------------------------------
struct SRadishCommunityActionData {
    var time: int;

    var apid: SRadishLayerTag;
    var weight: float;
}
// ----------------------------------------------------------------------------
struct SRadishCommunitySpawnData {
    var time: int;

    var quantity: int;
    var respawn: bool;
    var respawnDelay: int;
}
// ----------------------------------------------------------------------------
enum ERadUI_CommunityDecoratorType {
    ERCDT_None,
    ERCDT_Guard,
    ERCDT_AddTags,
    ERCDT_Appearance,
    ERCDT_Attitude,
    ERCDT_Immortality,
    ERCDT_Level,
    ERCDT_AddItems,
    ERCDT_DynamicWork,
    ERCDT_WanderPath,
    ERCDT_WanderArea,
    ERCDT_Scripted,
}
// ----------------------------------------------------------------------------
// union of all decorators with type-discriminator enum
struct SRadishCommunityDecorator {
    var type: ERadUI_CommunityDecoratorType;
    // -- guard
    var guardArea: SRadishLayerTag;
    var guardPursuit: SRadishLayerTag;
    var guardPursuitRange: float;
    // -- addtags
    var addTags: array<String>;
    // -- appearance
    var appearance: String;
    // -- attitude
    var attitude: String;
    // -- immortality
    var immortality: String;
    // -- level
    var level: int;
    // -- additional items
    var random: bool;
    var equip_item: bool;
    var addItems: array<String>;
    // -- wanderpath
    var speed: float;
    var moveType: String;
    var maxDistance: Float;
    var wanderPoints: SRadishLayerTag;
    var rightside: bool;
    // -- wander area
    var minDistance: Float;
    var wanderArea: SRadishLayerTag;
    var idleChance: Float;
    var idleDuration: Float;
    var moveChance: Float;
    var moveDuration: Float;
    // -- dynamicwork
    var workCategories: array<String>;
    var workApTags: array<String>;
    var workApArea: SRadishLayerTag;
    var workKeepAps: bool;
    // -- scripted
    var scriptclass: String;
}
// ----------------------------------------------------------------------------
// Navigation Meshes
// ----------------------------------------------------------------------------
struct SRadUiTriangle {
    var a: int;
    var b: int;
    var c: int;
}
// ----------------------------------------------------------------------------
struct SRadUiEdge {
    var a: int;
    var b: int;
    var adjacentTriangles: int;
}
// ----------------------------------------------------------------------------
struct SRadishNavMeshData {
    var id: String;

    var placement: SRadishPlacement;

    var vertices: array<Vector>;
    var triangles: array<SRadUiTriangle>;
    var phantomBorder: array<SRadUiEdge>;

    var appearance: CName;
}
// ----------------------------------------------------------------------------
class CRadishQuestStateData extends IModStorageData {
    // ------------------------------------------------------------------------
    default id = 'RadishQuestUi';
    // ------------------------------------------------------------------------
    public var layerData: array<SRadishLayerData>;
    public var communityData: array<SRadishCommunityData>;
    public var navMeshData: array<SRadishNavMeshData>;
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
