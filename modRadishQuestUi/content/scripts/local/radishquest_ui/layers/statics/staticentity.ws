// ----------------------------------------------------------------------------
class CRadishQuestLayerStaticEntity extends CRadishLayerEntity {
    // ------------------------------------------------------------------------
    default entityType = "static";
    // ------------------------------------------------------------------------
    protected var settings: SRadishLayerStaticEntityData;
    // ------------------------------------------------------------------------
    protected var staticsProxy: CRadishStaticsProxy;
    // ------------------------------------------------------------------------
    public function init(layerId: SRadUiLayerId, newPlacement: SRadishPlacement)
    {
        // a valid default path
        settings.template = "environment\decorations\decoration_sets\boxes\decoration_set_boxes_chest_b.w2ent";
        settings.placement = newPlacement;
        settings.scale = Vector(1.0, 1.0, 1.0, 1.0);
        super.init(layerId, newPlacement);
    }
    // ------------------------------------------------------------------------
    protected function initProxy() {
        // statics proxy template will be visibile from the start
        staticsProxy = new CRadishStaticsProxy in this;
        proxy = staticsProxy;
        proxy.init(settings.template, placement, this.initializedFromEntity);

        staticsProxy.setSettings(settings);
    }
    // ------------------------------------------------------------------------
    public function initFromData(data: SRadishLayerStaticEntityData) {
        initProxy();
        setSettings(data);
    }
    // ------------------------------------------------------------------------
    public function cloneFrom(src: CRadishLayerEntity) {
        var newSettings: SRadishLayerStaticEntityData;

        super.cloneFrom(src);

        newSettings = ((CRadishQuestLayerStaticEntity)src).getSettings();
        // placement is valid in all "other" types
        newSettings.placement = src.getPlacement();
        if (newSettings.template == "") {
            newSettings.template = "environment\decorations\decoration_sets\boxes\decoration_set_boxes_chest_b.w2ent";
        }

        this.initFromData(newSettings);
    }
    // ------------------------------------------------------------------------
    // settings
    // ------------------------------------------------------------------------
    public function getSettings() : SRadishLayerStaticEntityData {
        settings.id = id.entityName;
        settings.entityname = id.entityName;

        // this has to be updated as base class contains the current placement data
        settings.placement = placement;
        return settings;
    }
    // ------------------------------------------------------------------------
    public function setSettings(newSettings: SRadishLayerStaticEntityData) {
        settings = newSettings;
        placement = settings.placement;
        setName(settings.entityname);

        staticsProxy.setSettings(settings);
    }
    // ------------------------------------------------------------------------
    public function setPlacement(newPlacement: SRadishPlacement) {
        super.setPlacement(newPlacement);
        // update local settings
        settings.placement = newPlacement;
    }
    // ------------------------------------------------------------------------
    protected function updateAppearanceSetting(id: name) {
        settings.appearance = id;
    }
    // ------------------------------------------------------------------------
    public function refreshRepresentation() {
        staticsProxy.setSettings(settings);
    }
    // ------------------------------------------------------------------------
    // settings editing (text input)
    // ------------------------------------------------------------------------
    public function addUiSettings(settingsList: CRadishUiSettingsList) {
        settingsList.addSetting("tags", "tags: [auto]");
        settingsList.addSetting("class", "class: " + settings.entityClass);
        settingsList.addSetting("template", "template: " + UiFormatString(settings.template));
        settingsList.addSetting("pos", "position: " + UiSettingVecToString(settings.placement.pos));
        settingsList.addSetting("rot", "rotation: " + UiSettingAnglesToString(settings.placement.rot));
        settingsList.addSetting("scale", "scale: " + UiSettingVecToString(settings.scale));
    }
    // ------------------------------------------------------------------------
    public function getAsUiSetting(id: String) : IModUiSetting {
        var null: IModUiSetting;
        switch (id) {
            case "tags":    return ReadOnlyUiSetting(this);
            case "class":   return ReadOnlyUiSetting(this);
            case "template":return TemplateToUiSetting(this, settings.template);
            case "pos":     return VecToUiSetting(this, settings.placement.pos);
            case "rot":     return AnglesToUiSetting(this, settings.placement.rot);
            case "scale":   return VecToUiSetting(this, settings.scale);
            default:        return null;
        }
    }
    // ------------------------------------------------------------------------
    public function syncSetting(id: String, settingValue: IModUiSetting) {
        switch (id) {
            case "pos":     placement.pos = UiSettingToVector(settingValue); break;
            case "rot":     placement.rot = UiSettingToAngles(settingValue); break;
            case "scale":   settings.scale = UiSettingToVector(settingValue); break;
            case "template":
                settings.template = staticsProxy.getPermanentTemplate();
                settings.entityClass = staticsProxy.getPermanentClass();
                break;
            default:    super.syncSetting(id, settingValue);
        }
        settings.placement = placement;
    }
    // ------------------------------------------------------------------------
    // definition creation
    // ------------------------------------------------------------------------
    public function asDefinition() : SEncValue {
        var content: SEncValue;
        var stdScale: Vector;

        stdScale = Vector(1.0, 1.0, 1.0, 1.0);

        content = SEncValue(EEVT_Map);

        if (StrLen(settings.entityClass) > 0) {
            content.m.PushBack(SEncKeyValue("template",
                StrToEncValue(settings.entityClass + ":" + settings.template)));
        } else {
            content.m.PushBack(SEncKeyValue("template", StrToEncValue(settings.template)));
        }
        content.m.PushBack(SEncKeyValue("pos", PosToEncValue(placement.pos)));
        content.m.PushBack(SEncKeyValue("rot", RotToEncValue(placement.rot)));
        if (settings.scale != stdScale) {
            content.m.PushBack(SEncKeyValue("scale", PosToEncValue(settings.scale)));
        }
        //TODO
        //tags
        //settings
        //?

        return content;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CRadishQuestLayerEncodedStaticEntity extends CRadishQuestLayerStaticEntity {
    // ------------------------------------------------------------------------
    protected var meshSize: Vector;
    // ------------------------------------------------------------------------
    public function initFromDbgInfos(entity: CEntity) {
        var boundingBox: Box;

        super.initFromDbgInfos(entity);

        // extract scaling
        settings.scale = entity.GetLocalScale();

        // extract mesh size from the *encoded* entity
        // try boundingbox first
        entity.CalcBoundingBox(boundingBox);
        meshSize = RadUi_extractMeshBoxSize(boundingBox, 0.25);

        if (meshSize.X == 0.25 && meshSize.Y == 0.25 && meshSize.Z == 0.25) {
            // entity doesn't have a boundingbox (yet?) return default box
            meshSize = Vector(0.5, 0.5, 0.5, 1.0);
        }
    }
    // ------------------------------------------------------------------------
    public function getSize() : Vector {
        return this.meshSize;
    }
    // ------------------------------------------------------------------------
    protected function restoreFromDbgInfo(dbgInfo: SDbgInfo) {
        switch (dbgInfo.type) {
            case "template":    settings.template = dbgInfo.s;  break;
            case "class":       settings.entityClass = dbgInfo.s;  break;
        }
        settings.placement = placement;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
