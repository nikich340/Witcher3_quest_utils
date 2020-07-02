// ----------------------------------------------------------------------------
class CRadishQuestLayerAmbientSoundArea extends CRadishQuestLayerArea {
    // ------------------------------------------------------------------------
    default specialization = "sound";
    // ------------------------------------------------------------------------
    protected function initProxy() {
        // use specialized proxy with sound playback ability
        proxy = new CRadishSoundAreaProxy in this;
        proxy.init(proxyTemplate, placement, this.initializedFromEntity);

        ((CRadishSoundAreaProxy)proxy).setSettings(settings);

        initBorderpoint();
    }
    // ------------------------------------------------------------------------
    public function initFromDbgInfos(entity: CEntity) {
        var comp: CSoundAmbientAreaComponent;

        comp = ((CSoundAmbientAreaComponent)entity.GetComponentByClassName('CSoundAmbientAreaComponent'));

        settings.triggerPrio = 0;
        settings.soundEvent = "";               // from .debug
        settings.reverbName = "";               // from .debug
        settings.maxDistance = comp.maxDistance;
        settings.maxDistanceVertical = comp.maxDistanceVertical;
        settings.musicParamPriority = comp.priorityParameterMusic;
        settings.paramEnteringTime = comp.parameterEnteringTime;
        settings.paramExitingTime = comp.parameterExitingTime;

        settings.paramName = "";                // from .debug
        settings.paramValue = 0.0;
        // only one dependency for soundEvent supported
        settings.banksDependency = "";

        if (comp.parameters.Size() > 0) {
            settings.paramValue = comp.parameters[0].gameParameterValue;
        }
        if (comp.banksDependency.Size() > 0) {
            settings.banksDependency = comp.banksDependency[0];
        }
        extractAdditionalDbgInfos(comp);

        //TODO more settings?

        super.initFromDbgInfos(entity);

        // default color
        setAppearance('white');
    }
    // ------------------------------------------------------------------------
    protected function extractAdditionalDbgInfos(comp: CSoundAmbientAreaComponent) {
        var i, s: int;

        s = comp.dbgInfo.Size();
        for (i = 0; i < s; i += 1) {
            switch (comp.dbgInfo[i].type) {
                case "soundEvent":  settings.soundEvent = comp.dbgInfo[i].s; break;
                case "reverbName":  settings.reverbName = comp.dbgInfo[i].s; break;
                case "paramName":   settings.paramName = comp.dbgInfo[i].s; break;
            }
        }
    }
    // ------------------------------------------------------------------------
    public function cloneFrom(src: CRadishLayerEntity) {
        super.cloneFrom(src);
        // set default event
        if (settings.soundEvent == "") {
            settings.soundEvent = "amb_qu_EXT_EM_crowd_kids_cheering_2_25m";
            settings.banksDependency = "amb_qu_crowd_kids_cheering.bnk";
            // update proxy
            refreshRepresentation();
        }
        // default color
        setAppearance('white');
    }
    // ------------------------------------------------------------------------
    // settings editing (text input)
    // ------------------------------------------------------------------------
    public function addUiSettings(settingsList: CRadishUiSettingsList) {
        var paramCat: String;

        settingsList.addSetting("soundEvent", "sound event: " + settings.soundEvent);
        settingsList.addSetting("maxDist", "max distance: " + FloatToString(settings.maxDistance));
        settingsList.addSetting("maxDistVert", "max distance vert.: " + FloatToString(settings.maxDistanceVertical));

        settingsList.addSetting("reverbName", "reverb: " + settings.reverbName);

        paramCat = "sound param";

        //settingsList.addSetting("musicParamPriority", "music priority: " + settings.musicParamPriority, paramCat);
        settingsList.addSetting("paramEnterTime", "enter time: " + FloatToString(settings.paramEnteringTime), paramCat);
        settingsList.addSetting("paramExitTime", "exit time : " + FloatToString(settings.paramExitingTime), paramCat);

        settingsList.addSetting("paramName", "sound name: " + settings.paramName, paramCat);
        settingsList.addSetting("paramValue", "sound value: " + FloatToString(settings.paramValue), paramCat);

        settingsList.addSetting("bankDependency", "bank dependency: " + settings.banksDependency);

        settingsList.addSetting("triggerPrio", "area priority: " + IntToString(settings.triggerPrio));

        super.addUiSettings(settingsList);
    }
    // ------------------------------------------------------------------------
    public function getAsUiSetting(selectedId: String) : IModUiSetting {
        switch (selectedId) {
            case "soundEvent":
                return AmbientSoundToUiSetting(this, settings.soundEvent, settings.banksDependency);
            case "paramName":           return StringToUiSetting(this, settings.paramName);
            case "maxDist":             return FloatToUiSetting(this, settings.maxDistance, 0.0);
            case "maxDistVert":         return FloatToUiSetting(this, settings.maxDistanceVertical, 0.0);
            case "reverbName":          return ReverbSoundToUiSetting(this, settings.reverbName);
            //case "musicParamPriority":  return ReadOnlyUiSetting(this);
            case "bankDependency":      return ReadOnlyUiSetting(this);
            case "paramEnterTime":      return FloatToUiSetting(this, settings.paramEnteringTime, 0.0);
            case "paramExitTime":       return FloatToUiSetting(this, settings.paramExitingTime, 0.0);
            case "paramValue":          return FloatToUiSetting(this, settings.paramValue, 0.0, 1.0);
            case "triggerPrio":         return IntToUiSetting(this, settings.triggerPrio, 0);
            default: return super.getAsUiSetting(selectedId);
        }
    }
    // ------------------------------------------------------------------------
    public function syncSetting(id: String, settingValue: IModUiSetting) {
        switch (id) {
            case "soundEvent":
                settings.soundEvent = ((CModUiAmbientSoundUiSetting)settingValue).sound;
                settings.banksDependency = ((CModUiAmbientSoundUiSetting)settingValue).bank;
                break;
            case "reverbName":
                settings.reverbName = ((CModUiReverbSoundUiSetting)settingValue).value;
                break;

            case "paramName":           settings.paramName = UiSettingToString(settingValue); break;
            case "maxDist":             settings.maxDistance = UiSettingToFloat(settingValue); break;
            case "maxDistVert":         settings.maxDistanceVertical = UiSettingToFloat(settingValue); break;
            //case "musicParamPriority":  settings.musicParamPriority = UiSettingToBool(settingValue); break;
            case "paramEnterTime":      settings.paramEnteringTime = UiSettingToFloat(settingValue); break;
            case "paramExitTime":       settings.paramExitingTime = UiSettingToFloat(settingValue); break;
            case "paramValue":          settings.paramValue = UiSettingToFloat(settingValue); break;
            case "triggerPrio":         settings.triggerPrio = UiSettingToInt(settingValue); break;
            default:            super.syncSetting(id, settingValue);
        }
    }
    // ------------------------------------------------------------------------
    // definition creation
    // ------------------------------------------------------------------------
    protected function createAdditionalDbgInfos() : SEncValue {
        var debug: SEncValue;

        debug = encValueNewMap();

        encMapPush_str_opt("soundEvent", settings.soundEvent, "", debug);
        encMapPush_str_opt("reverbName", settings.reverbName, "", debug);
        encMapPush_str_opt("paramName", settings.paramName, "", debug);

        return debug;
    }
    // ------------------------------------------------------------------------
    public function asDefinition() : SEncValue {
        var entity, transform, components, soundarea, reverb, bpList: SEncValue;
        var param, paramList, banksList: SEncValue;
        var i: int;

        // generic static entity with ambientsound component:
        //  .type: CGameplayEntity
        //  transform:
        //    pos: [-110.0, -200.0, 30.0]
        //    scale: [ 1.0, 1.0, 1.0]
        //  components:
        //    soundarea:
        //      .debug
        //        soundEvents: monster_ice_giant_bodyfall
        //        gameParameterName: amb_interior
        //      .type: CSoundAmbientAreaComponent
        //      ...

        entity = encValueNewMap();
        transform = encValueNewMap();
        components = encValueNewMap();

        soundarea = encValueNewMap();

        // add additional debug infos that cannot be saved in "real" properties
        // because of missing type support (e.g. StringAnsi)
        encMapPush(".debug", createAdditionalDbgInfos(), soundarea);

        // -- soundarea specific settings
        encMapPush_str(".type", "CSoundAmbientAreaComponent", soundarea);

        encMapPush_str_opt("soundEvents", settings.soundEvent, "", soundarea);

        reverb = encValueNewMap();
        if (settings.reverbName != "") {
            //encMapPush_str(".type", "SReverbDefinition", reverb);
            encMapPush_str("reverbName", settings.reverbName, reverb);
            encMapPush_bool("enabled", true, reverb);
        }
        encMapPush_orComment("reverb", reverb, "<SReverbDefinition>", soundarea);

        encMapPush_float_opt("maxDistance", settings.maxDistance, 0.0, soundarea);
        encMapPush_float_opt("maxDistanceVertical", settings.maxDistanceVertical, 0.0, soundarea);
        //encMapPush_bool_opt("priorityParameterMusic", settings.musicParamPriority, false, soundarea);

        encMapPush_float_opt("parameterEnteringTime", settings.paramEnteringTime, 0.0, soundarea);
        encMapPush_float_opt("parameterExitingTime", settings.paramExitingTime, 0.0, soundarea);

        paramList = encValueNewList();
        if (settings.paramName != "")  {
            param = encValueNewMap();

            encMapPush_str("gameParameterName", settings.paramName, param);
            encMapPush_float("gameParameterValue", settings.paramValue, param);

            encListPush(param, paramList);
        }
        encMapPush_orComment("parameters", paramList, "<SSoundGameParameterValue[]>", soundarea);

        banksList = encValueNewList();
        if (settings.banksDependency != "") {
            encListPush_str(settings.banksDependency, banksList);
        }
        encMapPush_orComment("banksDependency", banksList, "<CName[]>", soundarea);

        encMapPush_int_opt("triggerPriority", settings.triggerPrio, 0, soundarea);

        // -- area settings
        encMapPush_float_opt("height", settings.height, 2.0, soundarea);
        bpList = encValueNewList();
        for (i = 0; i < settings.border.Size(); i += 1) {
            encListPush(Pos4ToEncValue(settings.border[i] - placement.pos, true), bpList);
        }
        encMapPush("localPoints", bpList, soundarea);

        // -- transform
        encMapPush("pos", PosToEncValue(this.placement.pos), transform);
        encMapPush("scale", PosToEncValue(Vector(1.0, 1.0, 1.0)), transform);

        // -- components
        encMapPush("soundarea", soundarea, components);

        // -- entity
        encMapPush_str(".type", "CEntity", entity);
        encMapPush("transform", transform, entity);
        encMapPush("components", components, entity);

        return entity;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
