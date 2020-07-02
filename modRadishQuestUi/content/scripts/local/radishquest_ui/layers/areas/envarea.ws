// ----------------------------------------------------------------------------
class CRadishQuestLayerEnvArea extends CRadishQuestLayerArea {
    // ------------------------------------------------------------------------
    default specialization = "env";
    // ------------------------------------------------------------------------
    public function initFromDbgInfos(entity: CEntity) {
        var bbox: Box;
        var comp: CAreaEnvironmentComponent;

        comp = ((CAreaEnvironmentComponent)entity.GetComponentByClassName('CAreaEnvironmentComponent'));
        settings.envDef = comp.environmentDefinition.GetPath();
        settings.priority = comp.priority;
        settings.blendInTime = comp.blendInTime;
        settings.blendOutTime = comp.blendOutTime;
        settings.blendDistance = comp.blendingDistance;
        settings.blendAboveAndBelow = comp.blendAboveAndBelow;
        //TODO more settings

        super.initFromDbgInfos(entity);

        // default color
        setAppearance('green');
    }
    // ------------------------------------------------------------------------
    public function cloneFrom(src: CRadishLayerEntity) {
        super.cloneFrom(src);
        // set default env
        if (settings.envDef == "") {
            settings.envDef = "dlc\bob\data\environment\definitions\quests\q704\704_cloud.env";
            settings.blendAboveAndBelow = false;
            // update proxy (if it's a preview proxy)
            refreshRepresentation();
        }

        // default color
        setAppearance('green');
    }
    // ------------------------------------------------------------------------
    // settings editing (text input)
    // ------------------------------------------------------------------------
    public function addUiSettings(settingsList: CRadishUiSettingsList) {
        settingsList.addSetting("env", "env: " + UiFormatString(settings.envDef));
        settingsList.addSetting("prio", "priority: " + IntToString(settings.priority));
        settingsList.addSetting("blendIn", "blend-in:  " + FloatToString(settings.blendInTime));
        settingsList.addSetting("blendOut", "blend-out: " + FloatToString(settings.blendOutTime));
        settingsList.addSetting("blendDist", "blend distance: " + FloatToString(settings.blendDistance));
        settingsList.addSetting("blendAboveBelow", "blend above/below: " + settings.blendAboveAndBelow);

        super.addUiSettings(settingsList);
    }
    // ------------------------------------------------------------------------
    public function getAsUiSetting(selectedId: String) : IModUiSetting {
        switch (selectedId) {
            case "env":         return EnvDefToUiSetting(this, settings.envDef);
            case "prio":        return IntToUiSetting(this, settings.priority, 0, 10000);
            case "blendIn":     return FloatToUiSetting(this, settings.blendInTime, 0.0, 1000.0);
            case "blendOut":    return FloatToUiSetting(this, settings.blendOutTime, 0.0, 1000.0);
            case "blendDist":   return FloatToUiSetting(this, settings.blendDistance, 0.0);
            case "blendAboveBelow":   return BoolToUiSetting(this, settings.blendAboveAndBelow);

            default: return super.getAsUiSetting(selectedId);
        }
    }
    // ------------------------------------------------------------------------
    public function syncSetting(id: String, settingValue: IModUiSetting) {
        switch (id) {
            case "env":         settings.envDef = ((CModUiEnvDefUiSetting)settingValue).value; break;
            case "prio":        settings.priority = UiSettingToInt(settingValue); break;
            case "blendIn":     settings.blendInTime = UiSettingToFloat(settingValue); break;
            case "blendOut":    settings.blendOutTime = UiSettingToFloat(settingValue); break;
            case "blendDist":   settings.blendDistance = UiSettingToFloat(settingValue); break;
            case "blendAboveBelow": settings.blendAboveAndBelow = UiSettingToBool(settingValue); break;
            default:            super.syncSetting(id, settingValue);
        }
    }
    // ------------------------------------------------------------------------
    // definition creation
    // ------------------------------------------------------------------------
    public function asDefinition() : SEncValue {
        var entity, transform, components, envarea, bpList: SEncValue;
        var i: int;

        // generic static entity with envarea component:
        //  .type: CGameplayEntity
        //  transform:
        //    pos: [-110.0, -200.0, 30.0]
        //    scale: [ 1.0, 1.0, 1.0]
        //  components:
        //    envcomponent:
        //      .type: CAreaEnvironmentComponent
        //      ...

        entity = encValueNewMap();
        transform = encValueNewMap();
        components = encValueNewMap();

        envarea = encValueNewMap();

        // -- envarea
        // TODO distinguish somehow between game default (== unset) values
        encMapPush_str(".type", "CAreaEnvironmentComponent", envarea);
        encMapPush_str("environmentDefinition", settings.envDef, envarea);
        encMapPush_int("priority", settings.priority, envarea);
        encMapPush_float("blendInTime", settings.blendInTime, envarea);
        encMapPush_float("blendOutTime", settings.blendOutTime, envarea);
        encMapPush_float("# terrainBlendingDistance", settings.terrainBlendingDistance, envarea);
        encMapPush_float("# blendingScale", settings.blendScale, envarea);
        encMapPush_bool_opt("blendAboveAndBelow", settings.blendAboveAndBelow, false, envarea);
        encMapPush_float_opt("blendingDistance", settings.blendDistance, 0.0, envarea);
        encMapPush_float_opt("height", settings.height, 2.0, envarea);

        bpList = encValueNewList();
        for (i = 0; i < settings.border.Size(); i += 1) {
            encListPush(Pos4ToEncValue(settings.border[i] - placement.pos, true), bpList);
        }
        encMapPush("localPoints", bpList, envarea);

        // -- transform
        encMapPush("pos", PosToEncValue(this.placement.pos), transform);
        encMapPush("scale", PosToEncValue(Vector(1.0, 1.0, 1.0)), transform);

        // -- components
        encMapPush("env", envarea, components);

        // -- entity
        encMapPush_str(".type", "CGameplayEntity", entity);
        encMapPush("transform", transform, entity);
        encMapPush("components", components, entity);

        return entity;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------

