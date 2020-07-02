// ----------------------------------------------------------------------------
abstract class IRadishUiModeEntityManager extends IRadishUiModeManager {
    // ------------------------------------------------------------------------
    public function select(entityId: String) : CRadishLayerEntity;
    // ------------------------------------------------------------------------
    public function selectPrevious() : CRadishLayerEntity;
    // ------------------------------------------------------------------------
    public function selectNext() : CRadishLayerEntity;
    // ------------------------------------------------------------------------
    public function getSelected() : CRadishLayerEntity;
    // ------------------------------------------------------------------------
    public function getEntityCount() : int;
    // ------------------------------------------------------------------------
    public function getEntityList() : CRadishUiFilteredList;
    // ------------------------------------------------------------------------
    public function refreshListProvider(optional syncFromLayer: bool);
    // ------------------------------------------------------------------------
    public function addNew() : CRadishLayerEntity;
    // ------------------------------------------------------------------------
    public function cloneSelected() : CRadishLayerEntity;
    // ------------------------------------------------------------------------
    public function renameSelected(newName: String);
    // ------------------------------------------------------------------------
    public function deleteSelected() : bool;
    // ------------------------------------------------------------------------
    public function verifyName(newName: String) : bool;
    // ------------------------------------------------------------------------
    public function extractSpecialization(
        input: String, out specialization: String, out newName: String);
    // ------------------------------------------------------------------------
    public function changeSpecialization(newSpecialization: String, newName: String) : bool;
    // ------------------------------------------------------------------------
    public function getCam() : CRadishStaticCamera;
    // ------------------------------------------------------------------------
    public function switchCamTo(placement: SRadishPlacement);
    // ------------------------------------------------------------------------
    public function getCamPlacement() : SRadishPlacement;
    // ------------------------------------------------------------------------
    public function getCamTracker() : CRadishTracker;
    // ------------------------------------------------------------------------
    public function getLayerId() : SRadUiLayerId;
    // ------------------------------------------------------------------------
    public function getLayerCaption() : String;
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
abstract class CRadishQuestLayerEntityManager extends IRadishUiModeEntityManager {
    // ------------------------------------------------------------------------
    protected var theCam: CRadishStaticCamera;
    protected var log: CModLogger;
    protected var layer: CRadishQuestLayer;
    // ------------------------------------------------------------------------
    protected var entityType: String;
    protected var entityListProvider: CRadishUiLayerEntityList;
    protected var entities: array<CRadishLayerEntity>;
    // ------------------------------------------------------------------------
    protected var selectedEntity: CRadishLayerEntity;
    // ------------------------------------------------------------------------
    public function init(
        log: CModLogger, layer: CRadishQuestLayer, theCam: CRadishStaticCamera)
    {
        this.layer = layer;
        this.log = log;
        this.theCam = theCam;
        this.entityListProvider = new CRadishUiLayerEntityList in this;
        refreshListProvider(true);
        // preselect
        entityListProvider.preselect(true);
        this.select(entityListProvider.getSelectedId());

        log.debug(entityType + " manager initialized");
    }
    // ------------------------------------------------------------------------
    protected function refreshEntities() {
        var collection: CRadishLayerEntityCollection;

        collection = layer.getEntityCollection(entityType);
        collection.sort();
        entities = collection.getItems();
    }
    // ------------------------------------------------------------------------
    public function refreshListProvider(optional syncFromLayer: bool) {
        if (syncFromLayer) {
            refreshEntities();
        }
        entityListProvider.setItemList(entities);
    }
    // ------------------------------------------------------------------------
    public function getEntityList() : CRadishUiFilteredList {
        return this.entityListProvider;
    }
    // ------------------------------------------------------------------------
    public function verifyName(newName: String) : bool {
        var id: SRadUiLayerEntityId;
        var escapedName, spec: String;
        var i, s: int;

        if ((CRadishLayerEntitySetsCollection)(layer.getEntityCollection(entityType))) {
            // duplicate names in EntitySets are always valid and expand the set
            return true;
        }

        escapedName = RadUi_escapeAsId(newName);

        s = entities.Size();
        for (i = 0; i < s; i += 1) {
            id = entities[i].getId();
            spec = entities[i].getSpecialization();
            if (spec != "") {
                if ((spec + "_" + id.entityName) == escapedName) {
                    return false;
                }
            } else if (id.entityName == escapedName) {
                return false;
            }
        }
        return true;
    }
    // ------------------------------------------------------------------------
    public function extractSpecialization(
        input: String, out specialization: String, out newName: String)
    {
        if (!StrSplitFirst(input, ".", specialization, newName) ) {
            newName = input;
            specialization = "";
        }
    }
    // ------------------------------------------------------------------------
    public function changeSpecialization(newSpecialization: String, newName: String) : bool {
        var newEntity: CRadishLayerEntity;
        var collection: CRadishLayerEntityCollection;

        collection = layer.getEntityCollection(entityType);

        newEntity = collection.createLayerEntity(
            this, selectedEntity.getType(), newSpecialization);

        if (newEntity) {
            newEntity.cloneFrom(selectedEntity);
            newEntity.setName(newName);

            collection.add(newEntity);
            collection.remove(selectedEntity);
            selectedEntity.destroy();

            selectedEntity = newEntity;

            return true;
        } else {
            return false;
        }
    }
    // ------------------------------------------------------------------------
    public function select(entityId: String) : CRadishLayerEntity {
        var i, s: int;
        var null: CRadishLayerEntity;

        if (selectedEntity.getIdString() == entityId) {
            return selectedEntity;
        }

        selectedEntity = null;

        s = entities.Size();
        for (i = 0; i < s; i += 1) {
            if (entities[i].getIdString() == entityId) {
                selectedEntity = entities[i];
                break;
            }
        }
        return selectedEntity;
    }
    // ------------------------------------------------------------------------
    public function selectPrevious() : CRadishLayerEntity {
        entityListProvider.setSelection(entityListProvider.getPreviousId());
        return select(entityListProvider.getSelectedId());
    }
    // ------------------------------------------------------------------------
    public function selectNext() : CRadishLayerEntity {
        entityListProvider.setSelection(entityListProvider.getNextId());
        return select(entityListProvider.getSelectedId());
    }
    // ------------------------------------------------------------------------
    public function getSelected() : CRadishLayerEntity {
        return selectedEntity;
    }
    // ------------------------------------------------------------------------
    protected function createNew(optional specialization: String) : CRadishLayerEntity;
    // ------------------------------------------------------------------------
    public function addNew() : CRadishLayerEntity {
        var entity: CRadishLayerEntity;
        var i: int;
        var newName: String;
        var newPlacement: SRadishPlacement;

        newPlacement.pos = RadUi_getGroundPosFromCam(theCam.getSettings());

        entity = createNew();
        entity.init(layer.getId(), newPlacement);

        newName = "new " + entity.getType();
        while (!verifyName(newName)) {
            i += 1;
            newName = "new " + entity.getType() + " " + IntToString(i);
        }
        entity.setName(newName);
        log.debug("created new entity: " + newName);

        layer.addEntity(entity);

        refreshListProvider(true);

        entityListProvider.setSelection(entity.getIdString(), true);
        selectedEntity = entity;

        return selectedEntity;
    }
    // ------------------------------------------------------------------------
    protected function trimNameCounter(aName: String, out newName: String) : bool {
        var part1, part2: String;

        StrSplitLast(RadUi_escapeAsId(aName), "_", part1, part2);

        if (StringToInt(part2, -12345) == -12345)  {
            newName = aName;
            return false;
        } else {
            newName = part1;
            return true;
        }
    }
    // ------------------------------------------------------------------------
    public function cloneSelected() : CRadishLayerEntity {
        var entity: CRadishLayerEntity;
        var i: int;
        var newName, specPrefix, trimmedName: String;
        var newPlacement: SRadishPlacement;

        if (selectedEntity) {
            newPlacement.pos = RadUi_getGroundPosFromCam(theCam.getSettings());

            entity = createNew(selectedEntity.getSpecialization());
            entity.init(layer.getId(), newPlacement);
            entity.cloneFrom(selectedEntity);

            if (entity.getSpecialization() != "") {
                specPrefix = entity.getSpecialization() + "_";
            } else {
                specPrefix = "";
            }
            newName = entity.getName();
            if (trimNameCounter(newName, trimmedName)) {
                i = 1;
                newName = trimmedName + " 1";
            }
            while (!verifyName(specPrefix + newName)) {
                i += 1;
                newName = trimmedName + " " + IntToString(i);
            }
            entity.setName(newName);
            log.debug("cloned entity: " + newName);

            layer.addEntity(entity);

            // toggle as visible to make clear it is cloning
            selectedEntity.show(true);
            entity.show(true);

            refreshListProvider(true);

            entityListProvider.setSelection(entity.getIdString(), true);
            selectedEntity = entity;
        }

        return selectedEntity;
    }
    // ------------------------------------------------------------------------
    public function renameSelected(newName: String) {
        if (selectedEntity) {
            selectedEntity.setName(newName);
            // refresh other names since "sets" may have changed
            refreshListProvider(true);
        }
    }
    // ------------------------------------------------------------------------
    public function deleteSelected() : bool {
        var result: bool;

        if (selectedEntity) {
            log.debug("deleting entity: " + selectedEntity.getName());

            result = layer.deleteEntity(selectedEntity);
            selectedEntity.destroy();
            delete selectedEntity;

            refreshListProvider(true);

            if (entities.Size() > 0) {
                // always a selection requried
                entityListProvider.preselect(true);
                this.select(entityListProvider.getSelectedId());
            }
        }
        return result;
    }
    // ------------------------------------------------------------------------
    public function getEntityCount() : int {
        return entities.Size();
    }
    // ------------------------------------------------------------------------
    public function getCam() : CRadishStaticCamera {
        return theCam;
    }
    // ------------------------------------------------------------------------
    public function getCamPlacement() : SRadishPlacement {
        return theCam.getSettings();
    }
    // ------------------------------------------------------------------------
    public function getCamTracker() : CRadishTracker {
        return theCam.getTracker();
    }
    // ------------------------------------------------------------------------
    public function switchCamTo(placement: SRadishPlacement) {
        theCam.setSettings(placement);
        theCam.switchTo();
    }
    // ------------------------------------------------------------------------
    public function getLayerId() : SRadUiLayerId {
        return layer.getId();
    }
    // ------------------------------------------------------------------------
    public function getLayerCaption() : String {
        return layer.getCaption();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
