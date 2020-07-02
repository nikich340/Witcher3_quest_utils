// ----------------------------------------------------------------------------
// base class for extending specialized entities containing some of the
// boilerplate as overwriteable base methods
//
abstract class CRadishQuestGenericEntity extends CRadishLayerEntity {
    // ------------------------------------------------------------------------
    default entityType = "static";
    default specialization = "-";
    // ------------------------------------------------------------------------
    default proxyTemplate = "engine\templates\editor\markers\review\opened_flag.w2ent";
    // ------------------------------------------------------------------------
    protected var settings: SRadishLayerGenericEntityData;
    // ------------------------------------------------------------------------
    public function init(layerId: SRadUiLayerId, newPlacement: SRadishPlacement) {
        settings.placement = newPlacement;
        super.init(layerId, newPlacement);
    }
    // ------------------------------------------------------------------------
    protected function initProxy() {
        // use specialized proxy
        proxy = new CRadishGenericEntityProxy in this;
        proxy.init(proxyTemplate, placement, this.initializedFromEntity);

        ((CRadishGenericEntityProxy)proxy).setSettings(settings);
    }
    // ------------------------------------------------------------------------
    public function initFromData(data: SRadishLayerGenericEntityData) {
        initProxy();
        setSettings(data);
    }
    // ------------------------------------------------------------------------
    public function initFromDbgInfos(entity: CEntity) {
        // super method spawns proxy therefore settings must already contain
        // correct placement
        settings.placement.pos = entity.GetWorldPosition();
        settings.placement.rot = entity.GetWorldRotation();

        super.initFromDbgInfos(entity);
    }
    // ------------------------------------------------------------------------
    public function cloneFrom(src: CRadishLayerEntity) {
        var newSettings: SRadishLayerGenericEntityData;

        super.cloneFrom(src);

        newSettings = ((CRadishQuestGenericEntity)src).getSettings();
        // placement is valid in all "other" types
        newSettings.placement = src.getPlacement();

        this.initFromData(newSettings);
    }
    // ------------------------------------------------------------------------
    // settings
    // ------------------------------------------------------------------------
    public function getSettings() : SRadishLayerGenericEntityData {
        settings.id = id.entityName;
        settings.entityname = id.entityName;

        // this has to be updated as base class contains the current placement data
        settings.placement = placement;
        return settings;
    }
    // ------------------------------------------------------------------------
    public function setSettings(newSettings: SRadishLayerGenericEntityData) {
        settings = newSettings;
        placement = settings.placement;
        setName(settings.entityname);

        ((CRadishGenericEntityProxy)proxy).setSettings(newSettings);
    }
    // ------------------------------------------------------------------------
    public function setPlacement(newPlacement: SRadishPlacement) {
        super.setPlacement(newPlacement);
        settings.placement = newPlacement;
    }
    // ------------------------------------------------------------------------
    protected function updateAppearanceSetting(id: name) {
        settings.appearance = id;
    }
    // ------------------------------------------------------------------------
    // settings editing (text input)
    // ------------------------------------------------------------------------
    public function addUiSettings(settingsList: CRadishUiSettingsList) {
        settingsList.addSetting("pos", "position: " + UiSettingVecToString(settings.placement.pos));
        settingsList.addSetting("rot", "rotation: " + UiSettingAnglesToString(settings.placement.rot));
    }
    // ------------------------------------------------------------------------
    public function getAsUiSetting(id: String) : IModUiSetting {
        var null: IModUiSetting;
        switch (id) {
            case "pos":     return VecToUiSetting(this, settings.placement.pos);
            case "rot":     return AnglesToUiSetting(this, settings.placement.rot);
            default:        return null;
        }
    }
    // ------------------------------------------------------------------------
    public function syncSetting(id: String, settingValue: IModUiSetting) {
        switch (id) {
            case "pos":     placement.pos = UiSettingToVector(settingValue); break;
            case "rot":     placement.rot = UiSettingToAngles(settingValue); break;
        }
        settings.placement = placement;
    }
    // ------------------------------------------------------------------------
    // definition creation
    // ------------------------------------------------------------------------
    public function asDefinition() : SEncValue {
        var entity, transform, components: SEncValue;

        // generic static entity with particles component:
        //  .type: CGameplayEntity
        //  transform:
        //    pos: [-110.0, -200.0, 30.0]
        //    scale: [ 1.0, 1.0, 1.0]
        //  components:
        //    <specialization>:
        //      .type: ...
        //      ...

        entity = encValueNewMap();
        transform = encValueNewMap();
        components = encValueNewMap();

        // -- transform
        encMapPush("pos", PosToEncValue(this.placement.pos), transform);
        encMapPush("rot", RotToEncValue(this.placement.rot), transform);
        encMapPush("scale", PosToEncValue(Vector(1.0, 1.0, 1.0)), transform);

        // -- components
        encMapPush(this.specialization, this.componentAsDefinition(), components);

        // -- entity
        encMapPush_str(".type", "CEntity", entity);
        encMapPush("transform", transform, entity);
        encMapPush("components", components, entity);

        return entity;
    }
    // ------------------------------------------------------------------------
    protected function componentAsDefinition() : SEncValue;
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
