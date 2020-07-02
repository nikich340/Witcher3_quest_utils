// ----------------------------------------------------------------------------
// RadishQuest UI: additional (existing!) layerentities can be added to see
// where spawnpoints, areas, etc. are. These are the required infos:
//
// valid ERadUI_LayerEntityType:
//    ERLT_Area,
//    ERLT_Waypoint,
//    ERLT_Scenepoint,
//    ERLT_Mappin,
//    ERLT_Actionpoint,
//    ERLT_StaticEntity,
//    ERLT_InteractiveEntity,
//
struct SRadUi_AdditionalEntity {
    var type: ERadUI_LayerEntityType;
    var tgtLayer: String;
    var srcTag: name;
    var tgtName: String;
    var appearance: name;
}
// ----------------------------------------------------------------------------
// add additional layer entities here:
// ----------------------------------------------------------------------------
function RadUI_getAdditionalEntities() : array<SRadUi_AdditionalEntity> {
    var entities: array<SRadUi_AdditionalEntity>;

    //entities.PushBack(SRadUi_AdditionalEntity(ERLT_Area,
    //    "layer name in qlui",
    //    'entity_tag_to_search_for', "custom name in qlui",
    //    'optional_apperanceid'   // for areas: green, red, yellow, lilac, white, blue
    //));
    //entities.PushBack(SRadUi_AdditionalEntity(ERLT_Area,
    //    "layer name in qlui",
    //    'entity_tag_to_search_for', "guardarea:entity_tag_to_search_for",
    //    'green'
    //));
    // ...

    return entities;
}
// ----------------------------------------------------------------------------
