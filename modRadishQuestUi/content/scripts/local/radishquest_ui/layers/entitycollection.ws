// ----------------------------------------------------------------------------
class CRadishLayerEntityCollection {
    // ------------------------------------------------------------------------
    private var visibility: bool;
    protected var entities: array<CRadishLayerEntity>;
    // ------------------------------------------------------------------------
    public function createLayerEntity(
        owner: CObject, type: String, specialization: String) : CRadishLayerEntity
    {
        var entity: CRadishLayerEntity;

        switch (type + "|" + specialization) {
            case "area|":           entity = new CRadishQuestLayerArea in owner; break;
            case "area|env":        entity = new CRadishQuestLayerEnvArea in owner; break;
            case "area|sound":      entity = new CRadishQuestLayerAmbientSoundArea in owner; break;

            case "waypoint|":       entity = new CRadishQuestLayerWaypoint in owner; break;
            case "waypoint|wander": entity = new CRadishQuestLayerWanderpoint in owner; break;

            case "scenepoint|":     entity = new CRadishQuestLayerScenepoint in owner; break;
            case "mappin|":         entity = new CRadishQuestLayerMappin in owner; break;
            case "actionpoint|":    entity = new CRadishQuestLayerActionpoint in owner; break;

            case "static|":         entity = new CRadishQuestLayerStaticEntity in owner; break;
            case "static|particles":entity = new CRadishQuestLayerParticles in owner; break;
            case "static|shadows":  entity = new CRadishQuestLayerStaticShadowEntity in owner; break;

            case "interactive|":    entity = new CRadishQuestLayerInteractiveEntity in owner; break;
        }

        return entity;
    }
    // ------------------------------------------------------------------------
    private function cloneEntity(src: CRadishLayerEntity) : CRadishLayerEntity {
        var entity: CRadishLayerEntity;

        entity = createLayerEntity(this, src.getType(), src.getSpecialization());
        entity.cloneFrom(src);

        return entity;
    }
    // ------------------------------------------------------------------------
    public function cloneFrom(src: CRadishLayerEntityCollection) {
        var null, entity: CRadishLayerEntity;
        var srcEntities: array<CRadishLayerEntity>;
        var i, s: int;

        srcEntities = src.getItems();
        s = srcEntities.Size();

        for (i = 0; i < s; i += 1) {
            entity = cloneEntity(srcEntities[i]);
            if (entity != null) {
                entities.PushBack(entity);
            }
        }

        visibility = src.visibility;
        show(visibility);
    }
    // ------------------------------------------------------------------------
    public function setLayerId(newId: SRadUiLayerId) {
        var i, s: int;

        s = entities.Size();
        for (i = 0; i < s; i += 1) {
            entities[i].setLayerId(newId);
        }
    }
    // ------------------------------------------------------------------------
    public function reset() {
        var i, s: int;

        s = entities.Size();
        for (i = 0; i < s; i += 1) {
            entities[i].destroy();
        }
        entities.Clear();
    }
    // ------------------------------------------------------------------------
    public function getItem(entityId: SRadUiLayerEntityId) : CRadishLayerEntity
    {
        var null: CRadishLayerEntity;
        var i, s: int;

        s = entities.Size();
        for (i = 0; i < s; i += 1) {
            if (entities[i].getId() == entityId) {
                return entities[i];
            }
        }
        return null;
    }
    // ------------------------------------------------------------------------
    public function add(item: CRadishLayerEntity) {
        item.show(visibility);
        entities.PushBack(item);
    }
    // ------------------------------------------------------------------------
    public function remove(entity: CRadishLayerEntity) : bool {
        return entities.Remove(entity);
    }
    // ------------------------------------------------------------------------
    public function getItems() : array<CRadishLayerEntity> {
        return entities;
    }
    // ------------------------------------------------------------------------
    public function sort() {
        if (entities.Size() > 0) {
            radMergeSortEntities(entities);
        }
    }
    // ------------------------------------------------------------------------
    public function count() : int {
        return entities.Size();
    }
    // ------------------------------------------------------------------------
    public function appendTo(out items: array<CRadishLayerEntity>) {
        var i, s: int;
        s = entities.Size();

        for (i = 0; i < s; i += 1) {
            items.PushBack(entities[i]);
        }
    }
    // ------------------------------------------------------------------------
    public function isVisible() : bool {
        return visibility;
    }
    // ------------------------------------------------------------------------
    public function toggleVisibility() {
        show(!visibility);
    }
    // ------------------------------------------------------------------------
    public function show(doShow: bool) {
        var i, s: int;

        visibility = doShow;

        s = entities.Size();
        for (i = 0; i < s; i += 1) {
            entities[i].show(visibility);
        }
    }
    // ------------------------------------------------------------------------
    public function getSpecializationIds(): array<String> {
        var ids: array<String>;
        var i: int;
        var spec: String;

        for (i = 0; i < entities.Size(); i += 1) {
            spec = entities[i].getSpecialization();
            if (!ids.Contains(spec)) {
                ids.PushBack(spec);
            }
        }
        ArraySortStrings(ids);

        return ids;
    }
    // ------------------------------------------------------------------------
    // definition creation
    // ------------------------------------------------------------------------
    public function asDefinition(specialization: String) : SEncValue {
        var entityDefs: SEncValue;
        var i: int;

        entityDefs = SEncValue(EEVT_Map);

        for (i = 0; i < entities.Size(); i += 1) {
            if (entities[i].getSpecialization() == specialization) {
                entityDefs.m.PushBack(
                    KeyValueToEncKeyValue(entities[i].getName(), entities[i].asDefinition()));
                entityDefs.m.PushBack(
                    SeperatorToEncKeyValue());
            }
        }
        return entityDefs;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CRadishLayerEntitySetsCollection extends CRadishLayerEntityCollection {
    // ------------------------------------------------------------------------
    public function sort() {
        var ids: array<String>;
        var count: array<int>;
        var i, slot: int;
        var entity: CRadishLayerEntitySetMember;
        var idStr: String;

        // refresh names of all entities: dupes create sets and rename
        if (entities.Size() > 0) {
            // -- collect information about which names are sets (== dupes)
            for (i = 0; i < entities.Size(); i += 1) {
                entity = (CRadishLayerEntitySetMember)entities[i];

                idStr = entity.getSpecialization() + "|" + entity.getName();
                slot = ids.FindFirst(idStr);
                if (slot >= 0) {
                    // found dupe
                    if (count[slot] < 0) {
                        count[slot] = 2;
                    } else {
                        count[slot] += 1;
                    }
                } else {
                    ids.PushBack(idStr);
                    count.PushBack(-1);
                }
            }

            // -- refresh id no & captions
            for (i = entities.Size() - 1; i >= 0; i -= 1) {
                entity = (CRadishLayerEntitySetMember)entities[i];

                idStr = entity.getSpecialization() + "|" + entity.getName();

                slot = ids.FindFirst(idStr);
                if (slot >= 0) {
                    if (count[slot] > 0) {
                        // is set
                        entity.assignMemberId(count[slot]);
                        count[slot] = count[slot] - 1;
                    } else {
                        // no dupe, so set
                        entity.assignMemberId(0);
                    }
                }
            }
            radMergeSortEntities(entities);
        }
    }
    // ------------------------------------------------------------------------
    // definition creation
    // ------------------------------------------------------------------------
    public function asDefinition(specialization: String) : SEncValue {
        var entity: CRadishLayerEntitySetMember;
        var ids: array<String>;
        var sets: array<SEncValue>;
        var slot: int;
        var entityDefs, newSet: SEncValue;
        var i: int;

        entityDefs = SEncValue(EEVT_Map);

        for (i = 0; i < entities.Size(); i += 1) {
            if (entities[i].getSpecialization() == specialization) {

                entity = (CRadishLayerEntitySetMember)entities[i];

                if (entity.getIdNo() > 0) {
                    // this is a set member
                    slot = ids.FindFirst(entity.getName());

                    if (slot == -1) {
                        // first entry
                        slot = ids.Size();
                        ids.PushBack(entity.getName());
                        sets.PushBack(SEncValue(EEVT_List));
                    }
                    // extend set
                    sets[slot].l.PushBack(entity.asDefinition());
                } else {
                    // no set member
                    entityDefs.m.PushBack(
                        KeyValueToEncKeyValue(entities[i].getName(),
                            entities[i].asDefinition()));
                    entityDefs.m.PushBack(
                        SeperatorToEncKeyValue());
                }
            }
        }
        // serialize collected sets
        for (i = 0; i < sets.Size(); i += 1) {
            entityDefs.m.PushBack(KeyValueToEncKeyValue(ids[i], sets[i]));
            entityDefs.m.PushBack(SeperatorToEncKeyValue());
        }
        return entityDefs;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// based on https://www.techiedelight.com/iterative-merge-sort-algorithm-bottom-up/
// ----------------------------------------------------------------------------
function radMergeSortMerge(
    out entities: array<CRadishLayerEntity>, out temp: array<CRadishLayerEntity>,
    from: int, mid: int, to: int)
{
    var k, i, j: int;
    var idA, idB: String;
    var a, b: CRadishLayerEntity;

    k = from;
    i = from;
    j = mid + 1;

    while (i <= mid && j <= to) {
        a = entities[i];
        b = entities[j];

        idA = a.getSpecialization() + "." + a.getName() + "#" + a.getIdNo();
        idB = b.getSpecialization() + "." + b.getName() + "#" + b.getIdNo();

        if (StrCmp(idA, idB) < 0) {
            temp[k] = entities[i];
            i += 1;
        } else {
            temp[k] = entities[j];
            j += 1;
        }
        k += 1;
    }

    while (i <= mid) {
        temp[k] = entities[i];
        k += 1;
        i += 1;
    }

    for (i = from; i <= to; i += 1) {
        entities[i] = temp[i];
    }
}
// ----------------------------------------------------------------------------
function radMergeSortEntities(out entities: array<CRadishLayerEntity>) {
    var low, high: int;
    var m, i: int;
    var from, mid, to: int;
    var temp: array<CRadishLayerEntity>;

    low = 0;
    high = entities.Size() - 1;

    for (i = 0; i <= high; i += 1) {
        temp.PushBack(entities[i]);
    }

    for (m = 1; m <= high - low; m = 2 * m) {
        for (i = low; i < high; i += 2 * m) {
            from = i;
            mid = i + m - 1;
            to = Min(i + 2 * m - 1, high);

            radMergeSortMerge(entities, temp, from, mid, to);
        }
    }
}
// ----------------------------------------------------------------------------
