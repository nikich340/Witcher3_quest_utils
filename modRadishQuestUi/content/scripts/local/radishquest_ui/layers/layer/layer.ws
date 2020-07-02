// ----------------------------------------------------------------------------
struct SRadUiLayerId {
    var layerName: String;
    var context: String;
    var encoded: bool;
}

struct SRadUiLayerEntityCategory {
    var id: String;
    var caption: String;
}
// ----------------------------------------------------------------------------
class CRadishQuestLayer {
    // ------------------------------------------------------------------------
    // counter to track revision of data (for lazy sync of cached data in visualizer)
    protected var lastUpdate: float;
    // ------------------------------------------------------------------------
    protected var layerType: String;
    // ------------------------------------------------------------------------
    protected var id: SRadUiLayerId;
    private var caption: String;
    protected var visibility: bool;

    private var settings: SRadishLayerData;

    private var areas: CRadishLayerEntityCollection;
    private var waypoints: CRadishLayerEntityCollection;
    private var scenepoints: CRadishLayerEntityCollection;
    private var mappins: CRadishLayerEntityCollection;
    private var actionpoints: CRadishLayerEntityCollection;
    private var statics: CRadishLayerEntityCollection;
    private var interactives: CRadishLayerEntityCollection;
    // ------------------------------------------------------------------------
    public function init(id: SRadUiLayerId, worldId: String) {
        this.setId(id);
        settings.world = worldId;

        areas = new CRadishLayerEntityCollection in this;
        waypoints = new CRadishLayerEntitySetsCollection in this;
        scenepoints = new CRadishLayerEntityCollection in this;
        mappins = new CRadishLayerEntityCollection in this;
        actionpoints = new CRadishLayerEntitySetsCollection in this;
        statics = new CRadishLayerEntityCollection in this;
        interactives = new CRadishLayerEntityCollection in this;

        refreshCaption();

        this.lastUpdate = theGame.GetEngineTimeAsSeconds();
    }
    // ------------------------------------------------------------------------
    public function initFromData(data: SRadishLayerData) {
        init(SRadUiLayerId(data.layername, data.context), data.world);

        settings = data;
    }
    // ------------------------------------------------------------------------
    protected function sortCollections() {
        areas.sort();
        waypoints.sort();
        scenepoints.sort();
        mappins.sort();
        actionpoints.sort();
        statics.sort();
        interactives.sort();
    }
    // ------------------------------------------------------------------------
    public function cloneFrom(src: CRadishQuestLayer) {
        this.visibility = src.visibility;

        areas.cloneFrom(src.getEntityCollection("area"));
        waypoints.cloneFrom(src.getEntityCollection("waypoint"));
        scenepoints.cloneFrom(src.getEntityCollection("scenepoint"));
        mappins.cloneFrom(src.getEntityCollection("mappin"));
        actionpoints.cloneFrom(src.getEntityCollection("actionpoint"));
        statics.cloneFrom(src.getEntityCollection("static"));
        interactives.cloneFrom(src.getEntityCollection("interactive"));

        // important to intialize cloned sets
        sortCollections();

        refreshEntityIds();
        refreshCaption();

        this.lastUpdate = theGame.GetEngineTimeAsSeconds();
    }
    // ------------------------------------------------------------------------
    public function destroy() {
        this.resetEntities();
    }
    // ------------------------------------------------------------------------
    public function getLastUpdated() : float {
        // we are not interested in changes *within* entities just about
        // addition or removal of entities
        return lastUpdate;
    }
    // ------------------------------------------------------------------------
    public function getSettings() : SRadishLayerData {
        return settings;
    }
    // ------------------------------------------------------------------------
    public function getId() : SRadUiLayerId {
        return this.id;
    }
    // ------------------------------------------------------------------------
    public function getIdString() : String {
        return this.id.layerName + ":" + this.id.context;
    }
    // ------------------------------------------------------------------------
    // naming
    // ------------------------------------------------------------------------
    public function getName() : String {
        return this.id.layerName;
    }
    // ------------------------------------------------------------------------
    public function getCaption() : String {
        return this.caption;
    }
    // ------------------------------------------------------------------------
    public function getExtendedCaption() : String {
        var prefix: String;

        if (visibility) { prefix = "v "; } else { prefix = ". "; }

        // TODO deletionmarker, etc.
        return prefix + this.caption + " [" + IntToString(getItemCount()) + "]";
    }
    // ------------------------------------------------------------------------
    // ------------------------------------------------------------------------
    public function getItemCount() : int {
        return this.areas.count()
            + this.waypoints.count()
            + this.scenepoints.count()
            + this.mappins.count()
            + this.actionpoints.count()
            + this.statics.count()
            + this.interactives.count();
    }
    // ------------------------------------------------------------------------
    public function getItems(): array<CRadishLayerEntity> {
        var items: array<CRadishLayerEntity>;

        areas.appendTo(items);
        waypoints.appendTo(items);
        scenepoints.appendTo(items);
        mappins.appendTo(items);
        actionpoints.appendTo(items);
        statics.appendTo(items);
        interactives.appendTo(items);

        return items;
    }
    // ------------------------------------------------------------------------
    public function getItem(entityId: SRadUiLayerEntityId) : CRadishLayerEntity {
        var null, result: CRadishLayerEntity;
        var i, s: int;

        if (entityId.layerId == id) {
            result = areas.getItem(entityId);
            if (result) { return result; }

            result = waypoints.getItem(entityId);
            if (result) { return result; }

            result = scenepoints.getItem(entityId);
            if (result) { return result; }

            result = mappins.getItem(entityId);
            if (result) { return result; }

            result = actionpoints.getItem(entityId);
            if (result) { return result; }

            result = statics.getItem(entityId);
            if (result) { return result; }

            result = interactives.getItem(entityId);
            if (result) { return result; }
        }
        return null;
    }
    // ------------------------------------------------------------------------
    private function formatCategory(
        visible: bool, caption: String, items: int): String
    {
        if (visible) {
            return "v " + caption + " [" + IntToString(items) + "]";
        } else {
            return ". " + caption + " [" + IntToString(items) + "]";
        }
    }
    // ------------------------------------------------------------------------
    public function getCategories() : array<SRadUiLayerEntityCategory> {
        var categories: array<SRadUiLayerEntityCategory>;

        categories.PushBack(SRadUiLayerEntityCategory(
            "area", formatCategory(areas.isVisible(), "areas", areas.count())
        ));
        categories.PushBack(SRadUiLayerEntityCategory(
            "waypoint", formatCategory(waypoints.isVisible(), "waypoints", waypoints.count())
        ));
        categories.PushBack(SRadUiLayerEntityCategory(
            "scenepoint", formatCategory(scenepoints.isVisible(), "scenepoints", scenepoints.count())
        ));
        categories.PushBack(SRadUiLayerEntityCategory(
            "mappin", formatCategory(mappins.isVisible(), "mappins", mappins.count())
        ));
        categories.PushBack(SRadUiLayerEntityCategory(
            "actionpoint", formatCategory(actionpoints.isVisible(), "actionpoints", actionpoints.count())
        ));
        categories.PushBack(SRadUiLayerEntityCategory(
            "static", formatCategory(statics.isVisible(), "statics", statics.count())
        ));
        categories.PushBack(SRadUiLayerEntityCategory(
            "interactive", formatCategory(interactives.isVisible(), "interactives", interactives.count())
        ));

        return categories;
    }
    // ------------------------------------------------------------------------
    private function refreshCaption() {
        if (id.context == "") {
            caption = id.layerName;
        } else {
            caption = id.layerName + "/" + id.context;
        }
        caption = StrReplaceAll(caption, "_", " ");
    }
    // ------------------------------------------------------------------------
    public function toggleVisibility() {
        visibility = !visibility;

        showEntityProxies(visibility);
    }
    // ------------------------------------------------------------------------
    protected function showEntityProxies(doShow: bool) {
        areas.show(doShow);
        waypoints.show(doShow);
        scenepoints.show(doShow);
        mappins.show(doShow);
        actionpoints.show(doShow);
        statics.show(doShow);
        interactives.show(doShow);
    }
    // ------------------------------------------------------------------------
    // setter
    // ------------------------------------------------------------------------
    public function setId(newId: SRadUiLayerId) {
        id = newId;
        id.layerName = RadUi_escapeAsId(newId.layerName);
        id.context = RadUi_escapeAsId(newId.context);
        refreshEntityIds();
        refreshCaption();
    }
    // ------------------------------------------------------------------------
    public function setName(newName: String) {
        id.layerName = RadUi_escapeAsId(newName);
        refreshEntityIds();
        refreshCaption();
    }
    // ------------------------------------------------------------------------
    public function setContext(newContext: String) {
        id.context = RadUi_escapeAsId(newContext);
        refreshEntityIds();
        refreshCaption();
    }
    // ------------------------------------------------------------------------
    // enitity management
    // ------------------------------------------------------------------------
    private function refreshEntityIds() {
        areas.setLayerId(id);
        waypoints.setLayerId(id);
        scenepoints.setLayerId(id);
        mappins.setLayerId(id);
        actionpoints.setLayerId(id);
        statics.setLayerId(id);
        interactives.setLayerId(id);

        this.lastUpdate = theGame.GetEngineTimeAsSeconds();
    }
    // ------------------------------------------------------------------------
    public function resetEntities() {
        areas.reset();
        waypoints.reset();
        scenepoints.reset();
        mappins.reset();
        actionpoints.reset();
        statics.reset();
        interactives.reset();

        this.lastUpdate = theGame.GetEngineTimeAsSeconds();
    }
    // ------------------------------------------------------------------------
    public function getEntityCollection(type: String): CRadishLayerEntityCollection
    {
        var null: CRadishLayerEntityCollection;
        switch (type) {
            case "area":        return areas;
            case "waypoint":    return waypoints;
            case "scenepoint":  return scenepoints;
            case "mappin":      return mappins;
            case "actionpoint": return actionpoints;
            case "static":      return statics;
            case "interactive": return interactives;
        }
        return null;
    }
    // ------------------------------------------------------------------------
    public function addEntity(entity: CRadishLayerEntity) : bool {
        this.lastUpdate = theGame.GetEngineTimeAsSeconds();

        switch (entity.getType()) {
            case "area":        areas.add(entity); return true;
            case "waypoint":    waypoints.add(entity); return true;
            case "scenepoint":  scenepoints.add(entity); return true;
            case "mappin":      mappins.add(entity); return true;
            case "actionpoint": actionpoints.add(entity); return true;
            case "static":      statics.add(entity); return true;
            case "interactive": interactives.add(entity); return true;
            default:            return false;
        }
    }
    // ------------------------------------------------------------------------
    public function deleteEntity(entity: CRadishLayerEntity) : bool {
        this.lastUpdate = theGame.GetEngineTimeAsSeconds();

        switch (entity.getType()) {
            case "area":        return areas.remove(entity);
            case "waypoint":    return waypoints.remove(entity);
            case "scenepoint":  return scenepoints.remove(entity);
            case "mappin":      return mappins.remove(entity);
            case "actionpoint": return actionpoints.remove(entity);
            case "static":      return statics.remove(entity);
            case "interactive": return interactives.remove(entity);
            default:            return false;
        }
    }
    // ------------------------------------------------------------------------
    public function toggleCategoryVisibility(category: String) {
        switch (category) {
            case "area":        areas.toggleVisibility(); break;
            case "waypoint":    waypoints.toggleVisibility(); break;
            case "scenepoint":  scenepoints.toggleVisibility(); break;
            case "mappin":      mappins.toggleVisibility(); break;
            case "actionpoint": actionpoints.toggleVisibility(); break;
            case "static":      statics.toggleVisibility(); break;
            case "interactive": interactives.toggleVisibility(); break;
        }
    }
    // ------------------------------------------------------------------------
    // definition creation
    // ------------------------------------------------------------------------
    private function addCollectionAsDefinition(
        keyPrefix: String, collection: CRadishLayerEntityCollection, out map: SEncValue)
    {
        var specializations: array<String>;
        var spec, key: String;
        var i: int;

        if (collection.count() > 0) {
            // partition by specialization
            specializations = collection.getSpecializationIds();

            for (i = 0; i < specializations.Size(); i += 1) {
                spec = specializations[i];
                switch (spec) {
                    case "":        key = keyPrefix; break;
                    // special case for wanderpoints
                    case "wander":  key = "wanderpoints"; break;
                    default:        key = keyPrefix + "." + spec;
                }
                map.m.PushBack(SEncKeyValue(key, collection.asDefinition(spec)));
            }
        }
    }
    // ------------------------------------------------------------------------
    public function asDefinition() : SEncValue {
        var content, entityDefs: SEncValue;

        content = SEncValue(EEVT_Map);

        if (getItemCount() > 0) {

            // -- settings
            content.m.PushBack(SEncKeyValue("world", StrToEncValue(settings.world)));
            if (StrLen(id.context) > 0) {
                content.m.PushBack(SEncKeyValue("context", StrToEncValue(id.context)));
            } else {
                content.m.PushBack(SEncKeyValue("#context", StrToEncValue("")));
            }
            content.m.PushBack(SeperatorToEncKeyValue());

            // -- areas
            addCollectionAsDefinition("areas", areas, content);

            // -- waypoints
            addCollectionAsDefinition("waypoints", waypoints, content);

            // -- scenepoints
            addCollectionAsDefinition("scenepoints", scenepoints, content);

            // -- mappins
            addCollectionAsDefinition("mappins", mappins, content);

            // -- actionpoints
            addCollectionAsDefinition("actionpoints", actionpoints, content);

            // -- statics
            addCollectionAsDefinition("statics", statics, content);

            // -- interactives
            // specializations not supported!
            if (interactives.count() > 0) {
                content.m.PushBack(SEncKeyValue("interactiveentities", interactives.asDefinition("")));
            }

            // -- ?
            // ...
        }

        return content;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
