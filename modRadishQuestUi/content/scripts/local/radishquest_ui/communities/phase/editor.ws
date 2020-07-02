// ----------------------------------------------------------------------------
class CRadishCommunityPhaseEditor extends CRadishCommunityElementEditor {
    // ------------------------------------------------------------------------
    private var phase: CRadishCommunityPhase;
    // ------------------------------------------------------------------------
    protected function setElement(element: IRadishQuestSelectableElement) {
        this.phase = (CRadishCommunityPhase)element;
    }
    // ------------------------------------------------------------------------
    public function select(settingsId: String) {
        var settings: SRadishCommunityPhaseData;
        var type, element, actorSlot, dataSlot, listItemSlot: String;
        var actor: SRadishCommunityActorPhaseData;
        var slot, i: int;

        super.select(settingsId);

        StrSplitFirst(settingsId, "|", type, actorSlot);
        StrSplitFirst(type, ":", type, dataSlot);
        StrSplitFirst(type, ".", type, element);

        settings = phase.getSettings();
        actor = settings.actors[StringToInt(actorSlot, -1)];
        slot = StringToInt(dataSlot, -1);
        switch (type) {
            case "decoGuard":
                switch (element) {
                    case "area":
                        this.visualizer.highlight("area|" + actor.decorator[slot].guardArea.tag);
                        break;

                    case "pursuitArea":
                        this.visualizer.highlight("area|" + actor.decorator[slot].guardPursuit.tag);
                        break;
                }
                break;

            case "decoWanderPath":
                this.visualizer.highlight("waypoint|" + actor.decorator[slot].wanderPoints.tag);
                break;

            case "decoWanderArea":
                this.visualizer.highlight("area|" + actor.decorator[slot].wanderArea.tag);
                break;

            case "decoDynamicWork":
                if (element == "area") {
                    this.visualizer.highlight("area|" + actor.decorator[slot].workApArea.tag);
                }
                break;

            case "ap":
                this.visualizer.highlight("actionpoint|" + actor.actions[slot].apid.tag);
                break;

            case "sp":
                this.visualizer.highlight("waypoint|" + actor.spawnpoints[slot].tag);
                break;

            default:
                this.visualizer.clearHighlighted();
        }
    }
    // ------------------------------------------------------------------------
    protected function refreshSettingsList() {
        var settings: SRadishCommunityPhaseData;
        var a, as: int;

        settings = phase.getSettings();
        settingsList.clear();

        as = settings.actors.Size();
        for (a = 0; a < as; a += 1) {
            addActorPhaseSettings(settingsList, settings.actors[a], a);
        }
    }
    // ------------------------------------------------------------------------
    protected function addActorPhaseSettings(
        list: CRadishUiSettingsList, data: SRadishCommunityActorPhaseData, actorSlot: int)
    {
        var actorName, actorId, id, time, iCol, value: String;
        var action: SRadishCommunityActionData;
        var spawndata: SRadishCommunitySpawnData;
        var i, s: int;

        // inactive col
        iCol = "#777777";

        actorName = StrReplaceAll(data.actorid, "_", " ");
        actorId = actorSlot;

        settingsList.addSetting_bool("startAp|" + actorId, data.startInAp, "start in ap", actorName);
        settingsList.addSetting_bool("useLastAp|" + actorId, data.useLastAp, "use last ap", actorName);
        settingsList.addSetting_bool("spawnHidden|" + actorId, data.spawnHidden, "spawn hidden", actorName);

        // --- actions
        s = data.actions.Size();
        if (s == 0) {
            settingsList.addColoredSetting(iCol, "ap:-|" + actorId, "actions: -", actorName);
        }
        for (i = 0; i < s; i += 1) {
            action = data.actions[i];

            time = RadUi_TimeToHHmm(action.time);

            id = "ap:" + i + "|" + actorId;
            value = StrReplaceAll(action.apid.tag, "_", " ");
            if (action.weight != 1) {
                value = "(" + FloatToStringPrec(action.weight, 3)+ ") " + value;
            }
            settingsList.addSetting(id, "action at " + time + ": " + value, actorName);
            //settingsList.addColoredSetting("#eee0c0", id, "action at " + time + ": " + value, actorName);
        }

        // --- spawntimes
        s = data.spawntimes.Size();
        if (s == 0) {
            settingsList.addColoredSetting(iCol, "st:-|" + actorId, "spawntimes: -", actorName);
        }
        for (i = 0; i < s; i += 1) {
            spawndata = data.spawntimes[i];
            time = RadUi_TimeToHHmm(spawndata.time);

            id = "st:" + i + "|" + actorId;

            settingsList.addSetting(id,
                "spawn at " + time + ": " + spawndata.quantity + " (respawn: " + spawndata.respawn + ")",
                actorName);
        }

        // --- spawnpoints
        s = data.spawnpoints.Size();
        if (s == 0) {
            settingsList.addColoredSetting(iCol, "sp:-|" + actorId, "spawnpoints: -", actorName);
        }
        for (i = 0; i < s; i += 1) {
            id = "sp:" + i + "|" + actorId;

            value = StrReplaceAll(data.spawnpoints[i].tag, "_", " ");
            settingsList.addSetting(id, "spawn in: " + value, actorName);
        }

        // --- decorator
        addDecoratorSettings(settingsList, actorSlot, actorName, data.decorator);
    }
    // ------------------------------------------------------------------------
    protected function addDecoratorSettings(
        list: CRadishUiSettingsList, actorSlot: int, actorName: String, decorator: array<SRadishCommunityDecorator>)
    {
        var deco: SRadishCommunityDecorator;
        var decoGuard, decoTags, decoAppearance, decoScripted, decoWanderPath, decoWanderArea, decoDynamicWork: bool;
        var decoAttitude, decoImmortality, decoLevel, decoAddItems : bool;
        var decoGuardSlot, decoTagsSlot, decoAppearanceSlot, decoScriptedSlot: int;
        var decoAttitudeSlot, decoImmortalitySlot, decoLevelSlot, decoAddItemsSlot: int;
        var decoWanderPathSlot, decoWanderAreaSlot, decoDynamicWorkSlot: int;
        var idSuffix: String;
        var id, value: String;
        var iCol: String;
        var i, s: int;

        // inactive col
        iCol = "#777777";

        // we want to show all possible, so if settings are not set some placeholders
        // check if data is set and overwrite placeholder
        s = decorator.Size();
        for (i = 0; i < s; i += 1) {
            switch (decorator[i].type) {
                case ERCDT_Guard:
                    decoGuard = true;
                    decoGuardSlot = i;
                    break;

                case ERCDT_AddTags:
                    decoTags = true;
                    decoTagsSlot = i;
                    break;

                case ERCDT_Appearance:
                    decoAppearance = true;
                    decoAppearanceSlot = i;
                    break;

                case ERCDT_Attitude:
                    decoAttitude = true;
                    decoAttitudeSlot = i;
                    break;

                case ERCDT_Immortality:
                    decoImmortality = true;
                    decoImmortalitySlot = i;
                    break;

                case ERCDT_Level:
                    decoLevel = true;
                    decoLevelSlot = i;
                    break;

                case ERCDT_AddItems:
                    decoAddItems = true;
                    decoAddItemsSlot = i;
                    break;

                case ERCDT_DynamicWork:
                    decoDynamicWork = true;
                    decoDynamicWorkSlot = i;
                    break;

                case ERCDT_WanderPath:
                    decoWanderPath = true;
                    decoWanderPathSlot = i;
                    break;

                case ERCDT_WanderArea:
                    decoWanderArea = true;
                    decoWanderAreaSlot = i;
                    break;

                case ERCDT_Scripted:
                    decoScripted = true;
                    decoScriptedSlot = i;
                    break;
            }
        }

        // -- guard
        if (decoGuard) {
            idSuffix = decoGuardSlot + "|" + actorSlot;
            deco = decorator[decoGuardSlot];

            settingsList.addSetting_string("decoGuard.area:" + idSuffix, deco.guardArea.tag, "guard area", actorName);
            if (deco.guardPursuitRange > 0) {
                settingsList.addSetting_float("decoGuard.range:" + idSuffix, deco.guardPursuitRange, "pursuit range", actorName);
            } else {
                settingsList.addSetting_string("decoGuard.pursuitArea:" + idSuffix, deco.guardPursuit.tag, "pursuit area", actorName);
            }
        } else {
            settingsList.addColoredSetting(iCol, "decoGuard:|" + actorSlot, "guard area: -", actorName);
        }

        // -- appearance
        settingsList.addSetting_string_opt(
            "decoAppearance:" + decoAppearanceSlot + "|" + actorSlot,
            decorator[decoAppearanceSlot].appearance, "appearance", actorName);

        // -- attitude
        settingsList.addSetting_string_opt(
            "decoAttitude:" + decoAttitudeSlot + "|" + actorSlot,
            decorator[decoAttitudeSlot].attitude, "attitude", actorName);

        // -- immortality
        settingsList.addSetting_string_opt(
            "decoImmortality:" + decoImmortalitySlot + "|" + actorSlot,
            StrReplace(decorator[decoImmortalitySlot].immortality, "AIM_", " "), "immortality", actorName);

        // -- level
        settingsList.addSetting_int_opt(
            "decoLevel:" + decoLevelSlot + "|" + actorSlot,
            decorator[decoLevelSlot].level, 0, "changed level", actorName);

        // -- additional items
        if (decoAddItems) {
            idSuffix = decoAddItemsSlot + "|" + actorSlot;
            deco = decorator[decoAddItemsSlot];

            settingsList.addSetting_bool("decoAddItems.random:" + idSuffix, deco.random, "only one random", actorName, "additional items");
            settingsList.addSetting_bool("decoAddItems.equip:" + idSuffix, deco.equip_item, "equip first", actorName, "additional items");

            s = deco.addItems.Size();
            if (s > 1) {
                for (i = 0; i < s; i += 1) {
                    settingsList.addSetting_string(
                        "decoAddItems.item:" + decoAddItemsSlot + "#" + i + "|" + actorSlot,
                            deco.addItems[i], "item", actorName, "additional items");
                }
            } else {
                settingsList.addSetting_string(
                    "decoAddItems.item:" + decoAddItemsSlot + "#0|" + actorSlot,
                        deco.addItems[0], "item", actorName, "additional items");
            }
        } else {
            settingsList.addColoredSetting(iCol, "decoAddItems:|" + actorSlot, "additional items: -", actorName);
        }

        // -- dynamicwork
        if (decoDynamicWork) {
            idSuffix = decoDynamicWorkSlot + "|" + actorSlot;
            deco = decorator[decoDynamicWorkSlot];

            settingsList.addSetting_string("decoDynamicWork.moveType:" + idSuffix, StrReplace(deco.moveType, "MT_", ""), "move type", actorName, "dynamic work");

            s = deco.workCategories.Size();
            if (s > 1) {
                for (i = 0; i < s; i += 1) {
                    settingsList.addSetting(
                        "decoDynamicWork.category:" + decoDynamicWorkSlot + "#" + i + "|" + actorSlot, deco.workCategories[i], actorName, "dynamic work", "categories");
                }
            } else {
                settingsList.addSetting_string(
                    "decoDynamicWork.category:" + decoDynamicWorkSlot + "#0|" + actorSlot, deco.workCategories[0], "category", actorName, "dynamic work");
            }

            s = deco.workApTags.Size();
            if (s > 1) {
                for (i = 0; i < s; i += 1) {
                    settingsList.addSetting(
                        "decoDynamicWork.aptag:" + decoDynamicWorkSlot + "#" + i + "|" + actorSlot, deco.workApTags[i], actorName, "dynamic work", "actionpoint tags");
                }
            } else {
                settingsList.addSetting_string(
                    "decoDynamicWork.aptag:" + decoDynamicWorkSlot + "#0|" + actorSlot, deco.workApTags[0], "actionpoint tag", actorName, "dynamic work");
            }

            if (deco.workApArea.tag != "") {
                settingsList.addSetting_string(
                    "decoDynamicWork.area:" + idSuffix, deco.workApArea.tag, "actionpoint restriction", actorName, "dynamic work");
            } else {
                settingsList.addColoredSetting(iCol, "decoDynamicWork.area:|" + idSuffix, "actionpoint restriction: -", actorName, "dynamic work");
            }

            settingsList.addSetting_bool("decoDynamicWork.keepaps:" + idSuffix, deco.workKeepAps, "keep aps", actorName, "dynamic work");
        } else {
            settingsList.addColoredSetting(iCol, "decoDynamicWork:|" + actorSlot, "dynamic work: -", actorName);
        }

        // -- wander path
        if (decoWanderPath) {
            idSuffix = decoWanderPathSlot + "|" + actorSlot;
            deco = decorator[decoWanderPathSlot];

            settingsList.addSetting_string("decoWanderPath.moveType:" + idSuffix, StrReplace(deco.moveType, "MT_", ""), "move type", actorName, "wander path");
            settingsList.addSetting_string("decoWanderPath.wpg:" + idSuffix, deco.wanderPoints.tag, "wander points", actorName, "wander path");
            settingsList.addSetting_float_opt("decoWanderPath.speed:" + idSuffix, deco.speed, 0, "speed", actorName, "wander path");
            settingsList.addSetting_float_opt("decoWanderPath.maxDist:" + idSuffix, deco.maxDistance, 0, "max distance", actorName, "wander path");
            settingsList.addSetting_bool("decoWanderPath.rightside:" + idSuffix, deco.rightside, "right side", actorName, "wander path");
        } else {
            settingsList.addColoredSetting(iCol, "decoWanderPath:|" + actorSlot, "wander path: -", actorName);
        }

        // -- wander area
        if (decoWanderArea) {
            idSuffix = decoWanderAreaSlot + "|" + actorSlot;
            deco = decorator[decoWanderAreaSlot];

            settingsList.addSetting_string("decoWanderArea.moveType:" + idSuffix, StrReplace(deco.moveType, "MT_", ""), "move type", actorName, "wander area");
            settingsList.addSetting_string("decoWanderArea.area:" + idSuffix, deco.wanderArea.tag, "wander area", actorName, "wander area");
            settingsList.addSetting_float_opt("decoWanderArea.speed:" + idSuffix, deco.speed, 0, "speed", actorName, "wander area");
            settingsList.addSetting_float_opt("decoWanderArea.maxDist:" + idSuffix, deco.maxDistance, 0, "max distance", actorName, "wander area");
            settingsList.addSetting_float_opt("decoWanderArea.minDist:" + idSuffix, deco.minDistance, 0, "min distance", actorName, "wander area");

            settingsList.addSetting_float_opt("decoWanderArea.idleChance:" + idSuffix, deco.idleChance, 0, "idle chance", actorName, "wander area");
            settingsList.addSetting_float_opt("decoWanderArea.idleDuration:" + idSuffix, deco.idleDuration, 0, "idle duration", actorName, "wander area");
            settingsList.addSetting_float_opt("decoWanderArea.moveChance:" + idSuffix, deco.moveChance, 0, "move chance", actorName, "wander area");
            settingsList.addSetting_float_opt("decoWanderArea.moveDuration:" + idSuffix, deco.moveDuration, 0, "move duration", actorName, "wander area");
        } else {
            settingsList.addColoredSetting(iCol, "decoWanderArea:|" + actorSlot, "wander area: -", actorName);
        }

        // -- additional tags
        if (decoTags) {
            deco = decorator[decoTagsSlot];
            s = deco.addTags.Size();
            if (s > 1) {
                for (i = 0; i < s; i += 1) {
                    settingsList.addSetting(
                        "decoAddTags:" + decoTagsSlot + "#" + i + "|" + actorSlot, deco.addTags[i], actorName, "additional tags");
                }
            } else {
                settingsList.addSetting_string(
                    "decoAddTags:" + decoTagsSlot + "#0|" + actorSlot, deco.addTags[0], "additional tag", actorName);
            }
        } else {
            settingsList.addColoredSetting(iCol, "decoAddTags:|" + actorSlot, "additional tags: -", actorName);
        }

        // -- scripted
        settingsList.addSetting_string_opt(
            "decoScr:" + decoScriptedSlot + "|" + actorSlot,
            decorator[decoScriptedSlot].scriptclass, "scripted initializer", actorName);
    }
    // ------------------------------------------------------------------------
    // settings editing (text input)
    // ------------------------------------------------------------------------
    protected function getAsUiSetting(selectedId: String) : IModUiSetting {
        var null: IModUiSetting;
        switch (selectedId) {
            case "tags":    return ReadOnlyUiSetting(this);
            default:        return null;
        }
    }
    // ------------------------------------------------------------------------
    public function syncSelectedSetting() {
        //switch (selectedId) {
        //    case "category":settings.category = UiSettingToString(editedSetting); break;
        //}
        //entity.setSettings(settings);
        //refreshSettingsList();
    }
    // ------------------------------------------------------------------------
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
