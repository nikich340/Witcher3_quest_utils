// ----------------------------------------------------------------------------
struct SRadUiEncodedLayerMeta {
    var questId: String;
    var world: String;
    var groupId: name;

    var layerName: String;
    var layerContext: String;
}
// ----------------------------------------------------------------------------
class CEncodedRadishQuestLayer extends CRadishQuestLayer {
    // ------------------------------------------------------------------------
    default layerType = "encoded";
    //private var refreshRequired: bool;
    private var questId: String;
    private var tagId: CName;
    private var w2lVisibility: bool;
    private var w2lScanned: bool;
    // ------------------------------------------------------------------------
    private var shadowed: bool;
    // ------------------------------------------------------------------------
    public function init(id: SRadUiLayerId, worldId: String) {
        id.encoded = true;
        super.init(id, worldId);
    }
    // ------------------------------------------------------------------------
    public function setTagGroupId(questId: String, groupId: CName) {
        this.questId = questId;
        this.tagId = groupId;
    }
    // ------------------------------------------------------------------------
    public function isEncodedVisible() : bool {
        return w2lVisibility;
    }
    // ------------------------------------------------------------------------
    public function isScanned() : bool {
        return w2lScanned;
    }
    // ------------------------------------------------------------------------
    public function getIdString() : String {
        return super.getIdString() + ":e";
    }
    // ------------------------------------------------------------------------
    // naming
    // ------------------------------------------------------------------------
    public function getExtendedCaption() : String {
        var prefix: String;
        var suffix: String;

        if (w2lVisibility) {
            suffix = "";
            if (w2lScanned) {
                if (shadowed) {
                    prefix = "enc:<font color=\"#996666\">";
                } else {
                    prefix = "enc:";
                }
            } else {
                prefix = "<font color=\"#FF8888\">w2l:</font>";
            }
        } else {
            if (shadowed) {
                prefix = "enc:<font color=\"#552222\">";
            } else {
                prefix = "enc:<font color=\"#777777\">";
            }
            suffix = "</font>";
        }
        return prefix + super.getExtendedCaption() + suffix;
    }
    // ------------------------------------------------------------------------
    // ------------------------------------------------------------------------
    // change w2l visibility in *encoded* layer
    private function showEncodedLayer(doShow: bool) {
        var factid: String;

        // be conservative and remove factid every time
        factid = "radish_layer_" + this.questId + "_" + id.layerName + "_visibility";
        FactsRemove(factid);

        if (w2lVisibility != doShow) {
            if (doShow) {
                FactsAdd(factid, 1);
            } else {
                FactsAdd(factid, -1);
            }
        }
        w2lVisibility = doShow;
    }
    // ------------------------------------------------------------------------
    public function toggleEncodedVisibility() {
        showEncodedLayer(!w2lVisibility);
    }
    // ------------------------------------------------------------------------
    private function extractLayerEntityType(
        entity: CEntity, out type: String, out specialization: String) : bool
    {
        var foundType, foundSpecialization: String;
        var i, s: int;

        s = entity.dbgInfo.Size();
        for (i = 0; i < s; i += 1) {
            // encoded meta information in dbgInfo
            switch (entity.dbgInfo[i].type) {
                case "type":
                    switch (entity.dbgInfo[i].s) {
                        // invisible entities (no need to distinguish between editable/encoded)
                        case "layer_area":        foundType = "area"; break;
                        case "layer_waypoint":    foundType = "waypoint"; break;
                        case "layer_scenepoint":  foundType = "scenepoint"; break;
                        case "layer_mappin":      foundType = "mappin"; break;
                        case "layer_actionpoint": foundType = "actionpoint"; break;
                        case "layer_static":      foundType = "static"; break;
                        case "layer_interactive": foundType = "interactive"; break;

                        // special case wanderpoint -> remap to specialized waypoint
                        case "layer_wanderpoint":
                            foundType = "waypoint";
                            foundSpecialization = "wander";
                            break;

                        default:            return false;
                    }
                    break;
                case "specialization":  foundSpecialization = entity.dbgInfo[i].s; break;
            }
        }
        if (foundType != "") {
            type = foundType;
            specialization = foundSpecialization;
            return true;
        }
        return false;
    }
    // ------------------------------------------------------------------------
    public function scanForEntities(optional dontMarkAsScanned: bool) : int {
        var entities: array<CEntity>;
        var layerEntity: CRadishLayerEntity;
        var type: ERadUI_LayerEntityType;
        var typeId, specId: String;
        var i, s, n: int;
        var entityFactory: CRadishLayerEntityCollection;

        entityFactory = new CRadishLayerEntityCollection in this;

        theGame.GetEntitiesByTag(tagId, entities);
        s = entities.Size();

        for (i = 0; i < s; i += 1) {
            if (extractLayerEntityType(entities[i], typeId, specId)) {

                if (specId != "") {
                    layerEntity = entityFactory.createLayerEntity(this, typeId, specId);
                } else {
                    // visible entities (editable spawn template, encoded only a
                    // marker to prevent dupes)
                    switch (typeId) {
                        case "static":
                            layerEntity = new CRadishQuestLayerEncodedStaticEntity in this;
                            break;

                        case "interactive":
                            layerEntity = new CRadishQuestLayerEncodedInteractiveEntity in this;
                            break;

                        default:
                            layerEntity = entityFactory.createLayerEntity(this, typeId, specId);
                    }
                }

                if (layerEntity) {
                    layerEntity.initFromDbgInfos(entities[i]);
                    addEntity(layerEntity);
                    n += 1;
                }
            }
        }
        if (s > 0) {
            // if any entity was found -> mark layer as currently visible (and scanned)
            w2lVisibility = true;
            w2lScanned = true;
        }
        if (!dontMarkAsScanned) {
            w2lScanned = true;
        }

        // initial sort for collections (important to initialize sets)
        sortCollections();

        this.lastUpdate = theGame.GetEngineTimeAsSeconds();
        return n;
    }
    // ------------------------------------------------------------------------
    // ------------------------------------------------------------------------
    public function setShadowed(shadowed: bool) {
        if (shadowed) {
            // hide w2l
            showEncodedLayer(false);
            // hide visual proxies
            showEntityProxies(false);
            visibility = false;
        }
        this.shadowed = shadowed;
    }
    // ------------------------------------------------------------------------
    public function isShadowed() : bool {
        return shadowed;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
