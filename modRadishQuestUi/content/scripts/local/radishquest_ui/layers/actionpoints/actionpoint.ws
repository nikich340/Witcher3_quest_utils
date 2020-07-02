// ----------------------------------------------------------------------------
class CRadishQuestLayerActionpoint extends CRadishLayerEntitySetMember {
    // ------------------------------------------------------------------------
    default entityType = "actionpoint";
    // ------------------------------------------------------------------------
    default proxyTemplate = "dlc\modtemplates\radishquestui\flags\actionpoint.w2ent";
    // ------------------------------------------------------------------------
    protected var settings: SRadishLayerActionpointData;
    // ------------------------------------------------------------------------
    public function init(layerId: SRadUiLayerId, newPlacement: SRadishPlacement)
    {
        // a valid jobtree action
        settings.category = "work_woman";
        settings.action = "stand_mwd_picking_herbs_jt";
        settings.placement = newPlacement;
        super.init(layerId, newPlacement);
    }
    // ------------------------------------------------------------------------
    public function initFromData(data: SRadishLayerActionpointData) {
        initProxy();
        setSettings(data);
    }
    // ------------------------------------------------------------------------
    protected function restoreFromDbgInfo(dbgInfo: SDbgInfo) {
        switch (dbgInfo.type) {
            case "action":      settings.action = dbgInfo.s;  break;
            case "category":    settings.category = dbgInfo.s; break;
        }
        settings.placement = placement;
    }
    // ------------------------------------------------------------------------
    public function initFromDbgInfos(entity: CEntity) {
        var comp: CActionPointComponent;

        comp = ((CActionPointComponent)entity.GetComponentByClassName('CActionPointComponent'));
        settings.ignoreCollisions = comp.ignoreCollosions;

        super.initFromDbgInfos(entity);
   }
    // ------------------------------------------------------------------------
    public function cloneFrom(src: CRadishLayerEntity) {
        var newSettings: SRadishLayerActionpointData;

        super.cloneFrom(src);

        newSettings = ((CRadishQuestLayerActionpoint)src).getSettings();
        // placement is valid in all "other" types
        newSettings.placement = src.getPlacement();
        if (newSettings.category == "") {
            newSettings.category = "work_woman";
            newSettings.action = "stand_mwd_picking_herbs_jt";
        }

        this.initFromData(newSettings);
    }
    // ------------------------------------------------------------------------
    protected function initProxy() {
        proxy = new CRadishActionpointProxy in this;
        proxy.init(proxyTemplate, placement, false);

        ((CRadishActionpointProxy)proxy).setSettings(settings);
    }
    // ------------------------------------------------------------------------
    // settings
    // ------------------------------------------------------------------------
    public function getSettings() : SRadishLayerActionpointData {
        settings.id = id.entityName;
        settings.pointname = id.entityName;

        // this has to be updated as base class contains the current placement data
        settings.placement = placement;
        return settings;
    }
    // ------------------------------------------------------------------------
    public function setSettings(newSettings: SRadishLayerActionpointData) {
        settings = newSettings;
        placement = settings.placement;
        setName(settings.pointname);

        //proxy.moveTo(placement);
        ((CRadishActionpointProxy)proxy).setSettings(settings);
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
    // settings editing (text input)
    // ------------------------------------------------------------------------
    public function addUiSettings(settingsList: CRadishUiSettingsList) {
        settingsList.addSetting("tags", "tags: [auto]");
        settingsList.addSetting("pos", "position: " + UiSettingVecToString(settings.placement.pos));
        settingsList.addSetting("rot", "heading: " + FloatToString(settings.placement.rot.Yaw));
        settingsList.addSetting("action", "action: " + StrReplaceAll(settings.action, "_" , " "));
        settingsList.addSetting("ignoreCollisions", "ignore collisions: " + settings.ignoreCollisions);
    }
    // ------------------------------------------------------------------------
    public function getAsUiSetting(id: String) : IModUiSetting {
        var null: IModUiSetting;
        switch (id) {
            case "tags":    return ReadOnlyUiSetting(this);
            case "pos":     return VecToUiSetting(this, settings.placement.pos);
            case "rot":     return FloatToUiSetting(this, settings.placement.rot.Yaw, 0, 360);
            case "action":  return ActionpointJobToUiSetting(this, settings.category, settings.action);
            case "ignoreCollisions":  return BoolToUiSetting(this, settings.ignoreCollisions);
            default:        return null;
        }
    }
    // ------------------------------------------------------------------------
    public function syncSetting(id: String, settingValue: IModUiSetting) {
        switch (id) {
            case "pos":     placement.pos = UiSettingToVector(settingValue); break;
            case "rot":     placement.rot.Yaw = UiSettingToFloat(settingValue); break;
            case "ignoreCollisions":  settings.ignoreCollisions = UiSettingToBool(settingValue); break;
            // category + action are updated directly in job selection
        }
        settings.placement = placement;
    }
    // ------------------------------------------------------------------------
    // definition creation
    // ------------------------------------------------------------------------
    public function asDefinition() : SEncValue {
        var content: SEncValue;

        if (settings.ignoreCollisions) {
            // extended definition
            content = SEncValue(EEVT_Map);
            encMapPush("pos", PosToEncValue(placement.pos), content);
            encMapPush("rot", RotToEncValue(placement.rot), content);
            encMapPush("action", StrToEncValue(settings.category + "/" + settings.action), content);
            encMapPush("ignoreCollisions", BoolToEncValue(settings.ignoreCollisions), content);

        } else {
            // simple definition
            content = RotPosToEncValue(placement.pos, placement.rot);
            content.l.PushBack(StrToEncValue(settings.category + "/" + settings.action));
        }
        return content;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
