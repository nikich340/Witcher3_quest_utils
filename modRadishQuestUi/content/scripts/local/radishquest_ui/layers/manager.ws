// ----------------------------------------------------------------------------
class CRadishUiLayerList extends CRadishUiFilteredList {
    // ------------------------------------------------------------------------
    public function setLayerList(layers: array<CRadishQuestLayer>, showShadowed: bool) : int {
        var l, ls: int;
        var layer: CRadishQuestLayer;

        items.Clear();

        ls = layers.Size();
        for (l = 0; l < ls; l += 1) {
            layer = layers[l];

            if (showShadowed || !((CEncodedRadishQuestLayer)layer).isShadowed()) {
                items.PushBack(SModUiCategorizedListItem(
                    layer.getIdString(),
                    layer.getExtendedCaption(),
                ));
            }
        }
        return items.Size();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CRadishQuestLayerHash {
    public var worldId: String;
    // ------------------------------------------------------------------------
    private var layerIds: array<SRadUiLayerId>;
    private var layers: array<CRadishQuestLayer>;
    // ------------------------------------------------------------------------
    public function getOrCreate(layerId: SRadUiLayerId, owner: CObject) : CRadishQuestLayer
    {
        var layerSlot: int;
        var layer: CRadishQuestLayer;
        // find or create layer
        layerSlot = layerIds.FindFirst(layerId);
        if (layerSlot == -1) {
            layer = new CRadishQuestLayer in owner;
            layer.init(layerId, worldId);

            layerIds.PushBack(layerId);
            layers.PushBack(layer);
        } else {
            layer = layers[layerSlot];
        }
        return layer;
    }
    // ------------------------------------------------------------------------
    public function add(layer: CRadishQuestLayer) : CRadishQuestLayer {
        var layerSlot: int;
        var id: SRadUiLayerId;

        // Note: layerIds.FindFirst(layer.getId()) crashes the game!
        id = layer.getId();
        layerSlot = layerIds.FindFirst(id);
        if (layerSlot == -1) {
            layerIds.PushBack(layer.getId());
            layers.PushBack(layer);
        } else {
            layer = layers[layerSlot];
        }
        return layer;
    }
    // ------------------------------------------------------------------------
    public function count() : int {
        return layers.Size();
    }
    // ------------------------------------------------------------------------
    public function toArray() : array<CRadishQuestLayer> {
        return layers;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CRadishQuestLayerManager extends IRadishUiModeManager {
    private var log: CModLogger;
    // ------------------------------------------------------------------------
    // countre to track revision of data (for lazy sync of cached data in visualizer)
    private var lastUpdate: float;
    // ------------------------------------------------------------------------
    private var worldId: String;
    private var layers: array<CRadishQuestLayer>;

    // only layers
    private var layerListProvider: CRadishUiLayerList;
    // all entities in all layers for searches
    private var layerEntityListProvider: CRadishUiMultiLayerEntityList;

    private var selectedLayer: CRadishQuestLayer;
    // ------------------------------------------------------------------------
    private var showShadowed: bool;
    // ------------------------------------------------------------------------
    private var theCam: CRadishStaticCamera;
    // ------------------------------------------------------------------------
    private var jobtreeManager: CRadishJobTreeManager;
    // ------------------------------------------------------------------------
    private var genericSettingListProvider: CGenericSettingListProvider;
    // ------------------------------------------------------------------------
    public function init(log: CModLogger, questIdFilter: String, statedata: CRadishQuestStateData)
    {
        this.log = log;
        this.worldId = this.detectWorldId();
        log.debug("layer manager initialized for world [" + this.worldId + "]");

        layers = this.buildLayerInfos(worldId, questIdFilter);

        layerListProvider = new CRadishUiLayerList in this;
        layerEntityListProvider = new CRadishUiMultiLayerEntityList in this;
        refreshListProvider();

        // make sure there is always one layer selected
        if (layers.Size() > 0) {
            layerListProvider.setSelection(layers[0].getIdString(), true);
            selectedLayer = layers[0];
        }
        layerEntityListProvider.preselect(true);

        jobtreeManager = new CRadishJobTreeManager in this;

        genericSettingListProvider = new CGenericSettingListProvider in this;
    }
    // ------------------------------------------------------------------------
    public function getLastUpdated() : float {
        var i: int;
        var lastUpdate: float;

        lastUpdate = 0;
        for (i = 0; i < layers.Size(); i += 1) {
            lastUpdate = MaxF(lastUpdate, layers[i].getLastUpdated());
        }
        return lastUpdate;
    }
    // ------------------------------------------------------------------------
    public function getState() : CRadishQuestStateData {
        return new CRadishQuestStateData in this;
    }
    // ------------------------------------------------------------------------
    private function detectWorldId() : String {
        var manager: CCommonMapManager;
        var worldPath: String;
        var currentArea: EAreaName;

        manager = theGame.GetCommonMapManager();
        worldPath = theGame.GetWorld().GetDepotPath();
        currentArea = manager.GetAreaFromWorldPath(worldPath);

        // mapping to encoder defined ids (see repository/worlds)
        switch (currentArea) {
            case AN_NMLandNovigrad:             return "novigrad";
            case AN_Skellige_ArdSkellig:        return "skellige";
            case AN_Kaer_Morhen:                return "kaer_morhen";
            case AN_Prologue_Village:           return "prologue";
            case AN_Wyzima:                     return "vizima";
            case AN_Island_of_Myst:             return "isle_of_mists";
            case AN_Spiral:                     return "spiral";
            case AN_Prologue_Village_Winter:    return "prologue_winter";
            case AN_Velen:                      return "velen";
            //case AN_CombatTestLevel:            return "";
            default:
                return AreaTypeToName(currentArea);
        }
    }
    // ------------------------------------------------------------------------
    private function entityTypeToId(type: ERadUI_LayerEntityType) : String {
        switch (type) {
            case ERLT_Area:         return "area";
            case ERLT_Waypoint:     return "waypoint";
            case ERLT_Scenepoint:   return "scenepoint";
            case ERLT_Mappin:       return "mappin";
            case ERLT_Actionpoint:  return "actionpoint";
            case ERLT_StaticEntity: return "static";
            case ERLT_InteractiveEntity: return "interactive";
            default: return "";
        }
    }
    // ------------------------------------------------------------------------
    private function buildLayerInfos(worldId: String, questIdFilter: String) : array<CRadishQuestLayer>
    {
        var hLayers: CRadishQuestLayerHash;

        hLayers = new CRadishQuestLayerHash in this;
        // all layers are from the current hub
        hLayers.worldId = worldId;

        // -- extract layers to manage (not all may be visible!)
        extractEncodedLayers(hLayers, worldId, questIdFilter);

        // -- extract layer entities for every (visible!) layer
        scanForEncodedEntities(hLayers.toArray());

        // -- additionally added entities
        addAdditionalEntities(hLayers);

        return hLayers.toArray();
    }
    // ------------------------------------------------------------------------
    private function extractLayerMetaInfo(metaInfo: array<SDbgInfo>) : SRadUiEncodedLayerMeta {
        var result: SRadUiEncodedLayerMeta;
        var i, s: int;
        var dbgInfo: SDbgInfo;

        s = metaInfo.Size();

        for (i = 0; i < s; i += 1) {
            // encoded meta information in dbgInfo
            dbgInfo = metaInfo[i];
            switch (dbgInfo.type) {
                case "world":   result.world = dbgInfo.s; break;
                case "name":    result.layerName = dbgInfo.s; break;
                case "context": result.layerContext = dbgInfo.s; break;
                case "groupid": result.groupId = dbgInfo.n; break;
                case "quest":   result.questId = dbgInfo.s; break;
            }
        }

        return result;
    }
    // ------------------------------------------------------------------------
    private function extractEncodedLayers(
        hLayers: CRadishQuestLayerHash, worldId: String, questIdFilter: String)
    {
        var entities: array<CEntity>;
        var layer: CEncodedRadishQuestLayer;
        var meta: SRadUiEncodedLayerMeta;
        var i, s : int;

        theGame.GetEntitiesByTag('radish_dbg_layer', entities);
        s = entities.Size();

        // extract meta information for each layer
        for (i = 0; i < s; i += 1) {
            meta = this.extractLayerMetaInfo(entities[i].dbgInfo);
            if (meta.world == worldId && (questIdFilter == "*" || questIdFilter == meta.questId)) {
                layer = new CEncodedRadishQuestLayer in this;
                layer.init(SRadUiLayerId(meta.layerName, meta.layerContext), worldId);
                layer.setTagGroupId(meta.questId, meta.groupId);
                hLayers.add(layer);
            } else {
                log.debug("ignoring encoded layer [" + meta.layerName + "] for quest ["
                    + meta.questId + "] in world: " + meta.world );
            }
        }

        if (hLayers.count() > 0) {
            log.info("found encoded layers (in [" + meta.world + "]) to manage: " + IntToString(hLayers.count()));
        } else {
            log.info("no encoded layers found.");
        }
    }
    // ------------------------------------------------------------------------
    private function scanForEncodedEntities(encodedLayers: array<CRadishQuestLayer>) {
        var i, s, e: int;

        s = encodedLayers.Size();
        for (i = 0; i < s; i += 1) {

            encodedLayers[i].resetEntities();
            // auto scan will try to scan hidden layers, too
            // there the scan should not mark as already scanned

            // Note: we do NOT set hidden layer to visible automatically before scanning as this
            // could make a triggerarea visible and directly trigger (always!) some questgraph action
            // therefore: hidden layers need to be manually set to visible (and scanned)
            e = ((CEncodedRadishQuestLayer)encodedLayers[i]).scanForEntities(true);
            log.debug("found entities in layer [" + encodedLayers[i].getName() + "]: " + IntToString(e));
        }
    }
    // ------------------------------------------------------------------------
    private function addAdditionalEntities(hLayers: CRadishQuestLayerHash) {
        var metaInfos: array<SRadUi_AdditionalEntity>;
        var meta: SRadUi_AdditionalEntity;
        var entities: array<CEntity>;
        var entity: CEntity;
        var layerEntity: CRadishLayerEntity;
        var i, s, e, es: int;
        var entityName: String;
        var layerName: String;

        var entityFactory: CRadishLayerEntityCollection;

        metaInfos = RadUI_getAdditionalEntities();
        layerName = GetLocStringByKeyExt("RADUI_lAdditionalLayer");

        entityFactory = new CRadishLayerEntityCollection in this;

        s = metaInfos.Size();
        for (i = 0; i < s; i += 1) {
            meta = metaInfos[i];

            entities.Clear();
            theGame.GetEntitiesByTag(meta.srcTag, entities);

            es = entities.Size();
            if (es > 0) {
                for (e = 0; e < es; e += 1) {
                    entity = entities[e];

                    layerEntity = entityFactory.createLayerEntity(
                        this, entityTypeToId(meta.type), "");

                    layerEntity.initFromDbgInfos(entity);
                    layerEntity.setLayerId(SRadUiLayerId(layerName, meta.tgtLayer));

                    if (meta.tgtName) {
                        entityName = meta.tgtName;
                    } else {
                        entityName = meta.srcTag;
                    }
                    if (e > 0) {
                        entityName += " " + IntToString(e + 1);
                    }
                    layerEntity.setName(entityName);

                    layerEntity.setAppearance(meta.appearance);
                    hLayers.getOrCreate(layerEntity.getLayerId(), this).addEntity(layerEntity);

                    log.info("additional entity found: " + NameToString(meta.srcTag));
                }

            } else {
                log.error("additonal entity not found: " + NameToString(meta.srcTag));
                theGame.GetGuiManager().ShowNotification(
                    GetLocStringByKeyExt("RADUI_eAdditionalEntityNotFound") + NameToString(meta.srcTag));
            }
        }
    }
    // ------------------------------------------------------------------------
    public function activate(cam: CRadishStaticCamera) {
        log.debug("layer manager activated");
        this.theCam = cam;
    }
    // ------------------------------------------------------------------------
    public function deactivate() {
        var null: CRadishStaticCamera;
        this.theCam = null;
    }
    // ------------------------------------------------------------------------
    public function refreshListProvider() {
        layerListProvider.setLayerList(this.layers, this.showShadowed);
        layerEntityListProvider.setLayerList(this.layers, this.showShadowed);
    }
    // ------------------------------------------------------------------------
    public function getLayerList() : CRadishUiFilteredList {
        return this.layerListProvider;
    }
    // ------------------------------------------------------------------------
    public function getLayerEntityList() : CRadishUiFilteredList {
        return this.layerEntityListProvider;
    }
    // ------------------------------------------------------------------------
    public function getJobTreeProvider() : CRadishJobTreeManager {
        return this.jobtreeManager;
    }
    // ------------------------------------------------------------------------
    public function getListProvider(listId: String) : CGenericListSettingList {
        return genericSettingListProvider.getListProvider(listId);
    }
    // ------------------------------------------------------------------------
    public function getSelected() : CRadishQuestLayer {
        return selectedLayer;
    }
    // ------------------------------------------------------------------------
    public function getLayers() : array<CRadishQuestLayer> {
        return layers;
    }
    // ------------------------------------------------------------------------
    public function getCam() : CRadishStaticCamera {
        return theCam;
    }
    // ------------------------------------------------------------------------
    public function getEntity(selectedId: String) : CRadishLayerEntity {
        var null, entity: CRadishLayerEntity;
        var id: SRadUiLayerEntityId;
        var i, s: int;

        id = RadUi_LayerEntityIdFromString(selectedId);
        s = layers.Size();

        for (i = 0; i < s; i += 1) {
            entity = layers[i].getItem(id);
            if (entity != null) {
                return entity;
            }
        }
        return null;
    }
    // ------------------------------------------------------------------------
    public function selectLayer(layerIdString: String) : CRadishQuestLayer {
        var null: CRadishQuestLayer;
        var i, s: int;
        s = layers.Size();

        for (i = 0; i < s; i += 1) {
            if (layers[i].getIdString() == layerIdString) {
                selectedLayer = layers[i];
                return selectedLayer;
            }
        }
        selectedLayer = null;
        return null;
    }
    // ------------------------------------------------------------------------
    // checks whether name is unique for all non-encoded (!) layers, ignoring
    // context.
    public function verifyLayerId(newId: SRadUiLayerId) : bool {
        var encoded: CEncodedRadishQuestLayer;
        var i, s: int;
        var tmpId: SRadUiLayerId;
        var newLayerName: String;

        newLayerName = RadUi_escapeAsId(newId.layerName);

        s = layers.Size();
        for (i = 0; i < s; i += 1) {
            tmpId = layers[i].getId();
            encoded = (CEncodedRadishQuestLayer)layers[i];
            if (!encoded && tmpId.layerName == newLayerName) {
                return false;
            }
        }
        return true;
    }
    // ------------------------------------------------------------------------
    // layer management
    // ------------------------------------------------------------------------
    private function generateUniqueLayerId(baseId: SRadUiLayerId) : SRadUiLayerId {
        var newId: SRadUiLayerId;
        var i: int;

        newId = baseId;
        while (!verifyLayerId(newId)) {
            i += 1;
            newId.layerName = baseId.layerName + IntToString(i);
        }
        return newId;
    }
    // ------------------------------------------------------------------------
    public function addNew() : CRadishQuestLayer {
        var layer: CRadishQuestLayer;
        var newId: SRadUiLayerId;

        newId = generateUniqueLayerId(SRadUiLayerId("new layer",,));

        layer = new CRadishQuestLayer in this;
        layer.init(newId, worldId);
        log.debug("created new layer: " + newId.layerName);

        layers.PushBack(layer);
        // TODO hide all encoded layers with this id => shadowing? O(n²)

        refreshListProvider();
        layerListProvider.setSelection(layer.getIdString(), true);
        selectedLayer = layer;

        this.lastUpdate = theGame.GetEngineTimeAsSeconds();
        return selectedLayer;
    }
    // ------------------------------------------------------------------------
    private function deleteEditableById(id: SRadUiLayerId) {
        var encoded: CEncodedRadishQuestLayer;
        var tmpLayers: array<CRadishQuestLayer>;
        var i, s: int;

        // layers = layers.iter().filter(l.getId() != id && !l.isEncoded()).collect();
        s = layers.Size();
        for (i = 0; i < s; i += 1) {
            encoded = (CEncodedRadishQuestLayer)layers[i];
            if (layers[i].getId() == id && !encoded) {
                layers[i].destroy();
            } else {
                tmpLayers.PushBack(layers[i]);
            }
        }
        layers = tmpLayers;
    }
    // ------------------------------------------------------------------------
    public function cloneSelected() : CRadishQuestLayer {
        var layer: CRadishQuestLayer;
        var newId: SRadUiLayerId;

        if (selectedLayer) {
            if ((CEncodedRadishQuestLayer)selectedLayer) {
                // use identical id
                newId = selectedLayer.getId();
                newId.encoded = false;

                // pre definition cloning encoded layer will overwrite previously
                // cloned layer!
                // -> remove any non encoded layer with this id
                deleteEditableById(newId);

            } else {
                newId = generateUniqueLayerId(selectedLayer.getId());
                newId.encoded = false;
            }
            layer = new CRadishQuestLayer in this;
            layer.init(newId, worldId);
            layer.cloneFrom(selectedLayer);
            log.debug("cloned layer: " + layer.getName());

            // "hide" original non-deleteable layer in list and all entity proxies
            // *after* cloning so original visibility information may be cloned, too
            // these layer defs won't be logged!
            ((CEncodedRadishQuestLayer)selectedLayer).setShadowed(true);

            layers.PushBack(layer);
            refreshListProvider();
            layerListProvider.setSelection(layer.getIdString(), true);
            selectedLayer = layer;
        }

        this.lastUpdate = theGame.GetEngineTimeAsSeconds();
        return selectedLayer;
    }
    // ------------------------------------------------------------------------
    public function deleteSelected() : bool {
        var encoded: CEncodedRadishQuestLayer;

        encoded = (CEncodedRadishQuestLayer)selectedLayer;
        if (selectedLayer && !encoded) {
            log.debug("deleting layer: " + selectedLayer.getName());

            if (layers.Remove(selectedLayer)) {
                selectedLayer.destroy();
                delete selectedLayer;

                refreshListProvider();

                if (layers.Size() > 0) {
                    layerListProvider.setSelection(layers[0].getIdString(), true);
                    selectedLayer = layers[0];
                }
                layerEntityListProvider.preselect(true);
                this.lastUpdate = theGame.GetEngineTimeAsSeconds();
                return true;
            }
        }
        return false;
    }
    // ------------------------------------------------------------------------
    public function existsEditableLayer(id: SRadUiLayerId) : bool {
        var i, s: int;
        id.encoded = false;

        s = layers.Size();
        for (i = 0; i < s; i += 1) {
            if (layers[i].getId() == id) {
                return true;
            }
        }
        return false;
    }
    // ------------------------------------------------------------------------
    public function unshadowEncodedLayer(id: SRadUiLayerId) {
        var i, s: int;

        id.encoded = true;

        s = layers.Size();
        for (i = 0; i < s; i += 1) {
            if (layers[i].getId() == id) {
                ((CEncodedRadishQuestLayer)layers[i]).setShadowed(false);
                refreshListProvider();

                this.lastUpdate = theGame.GetEngineTimeAsSeconds();
                break;
            }
        }
    }
    // ------------------------------------------------------------------------
    public function toggleShadowedVisibility() : bool {
        showShadowed = !showShadowed;
        refreshListProvider();
        return showShadowed;
    }
    // ------------------------------------------------------------------------
    // definition creation
    // ------------------------------------------------------------------------
    public function logDefinition(optional isAutoLogged: bool) {
        var definitionWriter: CRadishDefinitionWriter;
        var defs, root: SEncValue;
        var i: int;
        var id: SRadUiLayerId;

        root = SEncValue(EEVT_Map);
        defs = SEncValue(EEVT_Map);

        for (i = 0; i < layers.Size(); i += 1) {
            //TODO comment "shadowed/deleted encoded layer" ?
            if (layers[i].getItemCount() > 0 && !((CEncodedRadishQuestLayer)layers[i]).isShadowed()) {
                id = layers[i].getId();
                defs.m.PushBack(SEncKeyValue(id.layerName, layers[i].asDefinition()));
            } else {
                //TODO comment: layer without items?
            }
        }
        root.m.PushBack(SEncKeyValue("layers", defs));

        definitionWriter = new CRadishDefinitionWriter in this;
        if (isAutoLogged) {
            definitionWriter.create('W2LAYER', "Radish Quest UI", root);
        } else {
            definitionWriter.create('W2LAYER', "Radish Quest UI (auto-log)", root);
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
