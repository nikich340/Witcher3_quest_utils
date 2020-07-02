// ----------------------------------------------------------------------------
class CRadishCommunityPhase extends CRadishCommunityElement {
    // ------------------------------------------------------------------------
    protected var actordata: array<CRadishCommunityActorPhase>;
    // ------------------------------------------------------------------------
    protected var settings: SRadishCommunityPhaseData;
    // ------------------------------------------------------------------------
    public function getSettings() : SRadishCommunityPhaseData {
        return settings;
    }
    // ------------------------------------------------------------------------
    public function extractReferencedIds(out ids: array<String>) {
        var i, s: int;

        s = actordata.Size();
        for (i = 0; i < s; i += 1) {
            actordata[i].extractReferencedIds(ids);
        }
    }
    // ------------------------------------------------------------------------
    public function asDefinition() : SEncValue {
        var content, defs: SEncValue;
        // TODO
        return content;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
function RadUi_parseDbgLayerTag(str: String) : SRadishLayerTag {
    var tag, world: String;
    // either: "tagid" or "worldid/tagid"
    if (StrFindFirst(str, "/") >= 0) {
        return SRadishLayerTag(StrAfterFirst(str, "/"), StrBeforeFirst(str, "/"));
    } else {
        return SRadishLayerTag(str);
    }
}
// ----------------------------------------------------------------------------
class CRadishCommunityActorPhase {
    // ------------------------------------------------------------------------
    protected var id: String;
    // ------------------------------------------------------------------------
    protected var settings: SRadishCommunityActorPhaseData;
    // ------------------------------------------------------------------------
    public function getSettings() : SRadishCommunityActorPhaseData {
        return settings;
    }
    // ------------------------------------------------------------------------
    public function extractReferencedIds(out ids: array<String>) {
        var areaTag: String;
        var i, s: int;

        // aps
        s = settings.actions.Size();
        for (i = 0; i < s; i += 1) {
            ids.PushBack("actionpoint|" + settings.actions[i].apid.tag);
        }

        // spawnpoints
        s = settings.spawnpoints.Size();
        for (i = 0; i < s; i += 1) {
            ids.PushBack("waypoint|" + settings.spawnpoints[i].tag);
        }

        // areas
        s = settings.decorator.Size();
        for (i = 0; i < s; i += 1) {
            switch (settings.decorator[i].type) {
                case ERCDT_Guard:
                    ids.PushBack("area|" + settings.decorator[i].guardArea.tag);
                    areaTag = settings.decorator[i].guardPursuit.tag;
                    if (areaTag != "") {
                        ids.PushBack("area|" + areaTag);
                    }
                    break;

                case ERCDT_WanderPath:
                    ids.PushBack("waypoint|" + settings.decorator[i].wanderPoints.tag);
                    break;

                case ERCDT_WanderArea:
                    ids.PushBack("area|" + settings.decorator[i].wanderArea.tag);
                    break;

                case ERCDT_DynamicWork:
                    ids.PushBack("area|" + settings.decorator[i].workApArea.tag);
                    break;
            }
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CEncodedRadishCommunityActorPhase extends CRadishCommunityActorPhase {
    // ------------------------------------------------------------------------
    private function extractActionFromDbgInfos(metaInfo: array<SDbgInfo>) : SRadishCommunityActionData {
        var data: SRadishCommunityActionData;
        var i, s: int;

        // defaults
        data = SRadishCommunityActionData(0,,1);

        s = metaInfo.Size();
        for (i = 0; i < s; i += 1) {
            switch (metaInfo[i].type) {
                case "time":    data.time = metaInfo[i].i; break;
                case "ap":      data.apid = RadUi_parseDbgLayerTag(metaInfo[i].s); break;
                case "weight":  data.weight = metaInfo[i].i; break;
            }
        }
        return data;
    }
    // ------------------------------------------------------------------------
    private function extractSpawnDataFromDbgInfos(metaInfo: array<SDbgInfo>) : SRadishCommunitySpawnData {
        var data: SRadishCommunitySpawnData;
        var i, s: int;

        // defaults
        data = SRadishCommunitySpawnData(0, 1, false, -1);

        s = metaInfo.Size();
        for (i = 0; i < s; i += 1) {
            switch (metaInfo[i].type) {
                case "time":        data.time = metaInfo[i].i; break;
                case "quantity":    data.quantity = metaInfo[i].i; break;
                case "respawn":     data.respawn = metaInfo[i].i == 1; break;
                case "respawndelay":data.respawnDelay = metaInfo[i].i; break;
            }
        }
        return data;
    }
    // ------------------------------------------------------------------------
    private function extractGuardDecoratorFromDbgInfos(metaInfo: array<SDbgInfo>) : SRadishCommunityDecorator {
        var decorator: SRadishCommunityDecorator;
        var i, s: int;

        // defaults
        decorator = SRadishCommunityDecorator(ERCDT_Guard);
        decorator.guardPursuitRange = -1.0; // == unset

        s = metaInfo.Size();
        for (i = 0; i < s; i += 1) {
            switch (metaInfo[i].type) {
                case "guard":           decorator.guardArea = RadUi_parseDbgLayerTag(metaInfo[i].s); break;
                case "pursuit":         decorator.guardPursuit = RadUi_parseDbgLayerTag(metaInfo[i].s); break;
                case "pursuitrange":    decorator.guardPursuitRange = metaInfo[i].f; break;
            }
        }

        return decorator;
    }
    // ------------------------------------------------------------------------
    private function extractAddItemsDecoratorFromDbgInfos(metaInfo: array<SDbgInfo>) : SRadishCommunityDecorator {
        var decorator: SRadishCommunityDecorator;
        var i, s: int;
        var c: int;
        var itemInfos: array<SDbgInfo>;

        // defaults
        decorator = SRadishCommunityDecorator(ERCDT_AddItems);
        decorator.random = false; // == unset
        decorator.equip_item = false; // == unset

        s = metaInfo.Size();
        for (i = 0; i < s; i += 1) {
            switch (metaInfo[i].type) {
                case "equip_first":  decorator.equip_item = metaInfo[i].i == 1; break;
                case "random":       decorator.random = metaInfo[i].i == 1; break;
                case "items":
                    itemInfos = metaInfo[i].v;
                    for (c = 0; c < itemInfos.Size(); c += 1) {
                        if (itemInfos[c].type == "item") {
                            decorator.addItems.PushBack(itemInfos[c].s);
                        }
                    }
                break;
            }
        }

        return decorator;
    }
    // ------------------------------------------------------------------------
    private function extractDynamicWorkDecoratorFromDbgInfos(metaInfo: array<SDbgInfo>) : SRadishCommunityDecorator {
        var decorator: SRadishCommunityDecorator;
        var i, s, c: int;
        var listInfos: array<SDbgInfo>;

        // defaults
        decorator = SRadishCommunityDecorator(ERCDT_DynamicWork);

        s = metaInfo.Size();
        for (i = 0; i < s; i += 1) {
            switch (metaInfo[i].type) {
                case "categories":
                    listInfos = metaInfo[i].v;
                    for (c = 0; c < listInfos.Size(); c += 1) {
                        if (listInfos[c].type == "category") {
                            decorator.workCategories.PushBack(listInfos[c].s);
                        }
                    }
                    break;

                case "aptags":
                    listInfos = metaInfo[i].v;
                    for (c = 0; c < listInfos.Size(); c += 1) {
                        if (listInfos[c].type == "tag") {
                            decorator.workApTags.PushBack(listInfos[c].s);
                        }
                    }
                    break;

                case "aparea":   decorator.workApArea = RadUi_parseDbgLayerTag(metaInfo[i].s); break;
                case "movetype": decorator.moveType = metaInfo[i].s; break;
                case "keepaps":  decorator.workKeepAps = metaInfo[i].i == 1; break;
            }
        }

        return decorator;
    }
    // ------------------------------------------------------------------------
    private function extractWanderPathdDecoratorFromDbgInfos(metaInfo: array<SDbgInfo>) : SRadishCommunityDecorator {
        var decorator: SRadishCommunityDecorator;
        var i, s: int;

        // defaults
        decorator = SRadishCommunityDecorator(ERCDT_WanderPath);
        decorator.speed = -1.0; // == unset
        decorator.maxDistance = -1.0; // == unset

        s = metaInfo.Size();
        for (i = 0; i < s; i += 1) {
            switch (metaInfo[i].type) {
                case "wanderpoints": decorator.wanderPoints = RadUi_parseDbgLayerTag(metaInfo[i].s); break;
                case "speed":        decorator.speed = metaInfo[i].f; break;
                case "movetype":     decorator.moveType = metaInfo[i].s; break;
                case "maxdistance":  decorator.maxDistance = metaInfo[i].f; break;
                case "rightside":    decorator.rightside = metaInfo[i].i == 1; break;
            }
        }

        return decorator;
    }
    // ------------------------------------------------------------------------
    private function extractWanderAreaDecoratorFromDbgInfos(metaInfo: array<SDbgInfo>) : SRadishCommunityDecorator {
        var decorator: SRadishCommunityDecorator;
        var i, s: int;

        // defaults
        decorator = SRadishCommunityDecorator(ERCDT_WanderArea);
        decorator.speed = -1.0;
        decorator.maxDistance = -1.0;
        decorator.minDistance = -1.0;
        decorator.idleChance = -1.0;
        decorator.idleDuration = -1.0;
        decorator.moveChance = -1.0;
        decorator.moveDuration = -1.0;

        s = metaInfo.Size();
        for (i = 0; i < s; i += 1) {
            switch (metaInfo[i].type) {
                case "area":         decorator.wanderArea = RadUi_parseDbgLayerTag(metaInfo[i].s); break;
                case "speed":        decorator.speed = metaInfo[i].f; break;
                case "movetype":     decorator.moveType = metaInfo[i].s; break;
                case "maxdistance":  decorator.maxDistance = metaInfo[i].f; break;
                case "mindistance":  decorator.minDistance = metaInfo[i].f; break;
                case "idlechance":   decorator.idleChance = metaInfo[i].f; break;
                case "idleduration": decorator.idleDuration = metaInfo[i].f; break;
                case "movechance":   decorator.moveChance = metaInfo[i].f; break;
                case "moveduration": decorator.moveDuration = metaInfo[i].f; break;
            }
        }

        return decorator;
    }
    // ------------------------------------------------------------------------
    private function createAppearanceDecorator(metaInfo: CName) : SRadishCommunityDecorator {
        var decorator: SRadishCommunityDecorator;
        decorator = SRadishCommunityDecorator(ERCDT_Appearance);
        decorator.appearance = metaInfo;
        return decorator;
    }
    // ------------------------------------------------------------------------
    private function createAttitudeDecorator(metaInfo: CName) : SRadishCommunityDecorator {
        var decorator: SRadishCommunityDecorator;
        decorator = SRadishCommunityDecorator(ERCDT_Attitude);
        decorator.attitude = metaInfo;
        return decorator;
    }
    // ------------------------------------------------------------------------
    private function createImmortalityDecorator(metaInfo: String) : SRadishCommunityDecorator {
        var decorator: SRadishCommunityDecorator;
        decorator = SRadishCommunityDecorator(ERCDT_Immortality);
        decorator.immortality = metaInfo;
        return decorator;
    }
    // ------------------------------------------------------------------------
    private function createLevelDecorator(metaInfo: int) : SRadishCommunityDecorator {
        var decorator: SRadishCommunityDecorator;
        decorator = SRadishCommunityDecorator(ERCDT_Level);
        decorator.level = metaInfo;
        return decorator;
    }
    // ------------------------------------------------------------------------
    private function createScriptedDecorator(metaInfo: String) : SRadishCommunityDecorator {
        var decorator: SRadishCommunityDecorator;
        decorator = SRadishCommunityDecorator(ERCDT_Scripted);
        decorator.scriptclass = metaInfo;
        return decorator;
    }
    // ------------------------------------------------------------------------
    public function initFromDbgInfos(metaInfo: array<SDbgInfo>) {
        var addTagDecorator: SRadishCommunityDecorator;
        var i, s: int;

        s = metaInfo.Size();
        for (i = 0; i < s; i += 1) {
            // parse encoded meta information in dbgInfo
            switch (metaInfo[i].type) {
                case "id":          settings.actorid = metaInfo[i].s; break;
                case "action":      settings.actions.PushBack(extractActionFromDbgInfos(metaInfo[i].v)); break;
                case "spawntime":   settings.spawntimes.PushBack(extractSpawnDataFromDbgInfos(metaInfo[i].v)); break;
                case "spawnpoint":  settings.spawnpoints.PushBack(RadUi_parseDbgLayerTag(metaInfo[i].s)); break;
                case "guard":       settings.decorator.PushBack(extractGuardDecoratorFromDbgInfos(metaInfo[i].v)); break;
                case "appearance":  settings.decorator.PushBack(createAppearanceDecorator(metaInfo[i].n)); break;
                case "attitude":    settings.decorator.PushBack(createAttitudeDecorator(metaInfo[i].n)); break;
                case "immortality": settings.decorator.PushBack(createImmortalityDecorator(metaInfo[i].s)); break;
                case "level":       settings.decorator.PushBack(createLevelDecorator(metaInfo[i].i)); break;
                case "additems":    settings.decorator.PushBack(extractAddItemsDecoratorFromDbgInfos(metaInfo[i].v)); break;
                case "dynamicwork": settings.decorator.PushBack(extractDynamicWorkDecoratorFromDbgInfos(metaInfo[i].v)); break;
                case "wanderpath":  settings.decorator.PushBack(extractWanderPathdDecoratorFromDbgInfos(metaInfo[i].v)); break;
                case "wanderarea":  settings.decorator.PushBack(extractWanderAreaDecoratorFromDbgInfos(metaInfo[i].v)); break;
                case "scripted":    settings.decorator.PushBack(createScriptedDecorator(metaInfo[i].s)); break;

                // specially collected decorator
                case "addtag":      addTagDecorator.addTags.PushBack(metaInfo[i].s); break;

                case "startinap":   settings.startInAp = metaInfo[i].i == 1; break;
                case "uselastap":   settings.useLastAp = metaInfo[i].i == 1; break;
                case "spawnhidden": settings.spawnHidden = metaInfo[i].i == 1; break;
            }
        }
        // special case
        if (addTagDecorator.addTags.Size() > 0) {
            addTagDecorator.type = ERCDT_AddTags;
            settings.decorator.PushBack(addTagDecorator);
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CEncodedRadishCommunityPhase extends CRadishCommunityPhase {
    // ------------------------------------------------------------------------
    private var spawned: bool;
    private var scanIdTag: name;
    // ------------------------------------------------------------------------
    public function initFromDbgInfos(communityId: String, metaInfo: array<SDbgInfo>) {
        var actorPhase: CEncodedRadishCommunityActorPhase;
        var i, s: int;

        s = metaInfo.Size();
        for (i = 0; i < s; i += 1) {
            // parse encoded meta information in dbgInfo
            switch (metaInfo[i].type) {
                case "id":      settings.id = metaInfo[i].s; break;
                case "uid":     this.scanIdTag = metaInfo[i].n; break;

                case "actor":
                    actorPhase = new CEncodedRadishCommunityActorPhase in this;
                    actorPhase.initFromDbgInfos(metaInfo[i].v);
                    settings.actors.PushBack(actorPhase.getSettings());

                    this.actordata.PushBack(actorPhase);
                    break;
            }
        }
        // TODO initFromData
        this.setId(settings.id);
    }
    // ------------------------------------------------------------------------
    public function getScanIdTag() : name {
        return this.scanIdTag;
    }
    // ------------------------------------------------------------------------
    public function getExtendedCaption(parentPrefix: String) : String {
        var prefix: String;
        var suffix: String;

        if (spawned) {
            prefix = parentPrefix + "<font color=\"#8888FF\">";
            suffix = "</font>";
        } else {
            prefix = parentPrefix + "<font color=\"#777777\">";
            suffix = "</font>";
        }

        return prefix + this.caption + suffix;
    }
    // ------------------------------------------------------------------------
    public function isSpawned() : bool {
        return this.spawned;
    }
    // ------------------------------------------------------------------------
    public function markSpawned() {
        this.spawned = true;
    }
    // ------------------------------------------------------------------------
    public function markDespawned() {
        this.spawned = false;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
