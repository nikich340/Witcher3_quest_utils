// ----------------------------------------------------------------------------
class CRadishQuestLayerScenepoint extends CRadishLayerEntity {
    // ------------------------------------------------------------------------
    default entityType = "scenepoint";
    // ------------------------------------------------------------------------
    default proxyTemplate = "dlc\modtemplates\radishquestui\flags\scenepoint.w2ent";
    // ------------------------------------------------------------------------
    private var settings: SRadishLayerWaypointData;
    // ------------------------------------------------------------------------
    public function initFromData(data: SRadishLayerWaypointData) {
        initProxy();
        setSettings(data);
    }
    // ------------------------------------------------------------------------
    public function cloneFrom(src: CRadishLayerEntity) {
        var newSettings: SRadishLayerWaypointData;

        super.cloneFrom(src);

        newSettings = ((CRadishQuestLayerScenepoint)src).getSettings();
        // placement is valid in all "other" types
        newSettings.placement = src.getPlacement();

        this.initFromData(newSettings);
    }
    // ------------------------------------------------------------------------
    // settins
    // ------------------------------------------------------------------------
    public function getSettings() : SRadishLayerWaypointData {
        settings.id = id.entityName;
        settings.pointname = id.entityName;

        // this has to be updated as base class contains the current placement data
        settings.placement = placement;
        return settings;
    }
    // ------------------------------------------------------------------------
    public function setSettings(newSettings: SRadishLayerWaypointData) {
        settings = newSettings;
        placement = settings.placement;
        setName(settings.pointname);

        proxy.moveTo(placement);
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
    }
    // ------------------------------------------------------------------------
    public function getAsUiSetting(id: String) : IModUiSetting {
        var null: IModUiSetting;
        switch (id) {
            case "tags":    return ReadOnlyUiSetting(this);
            case "pos":     return VecToUiSetting(this, settings.placement.pos);
            case "rot":     return FloatToUiSetting(this, settings.placement.rot.Yaw, 0, 360);
            default:        return null;
        }
    }
    // ------------------------------------------------------------------------
    public function syncSetting(id: String, settingValue: IModUiSetting) {
        switch (id) {
            case "pos":     placement.pos = UiSettingToVector(settingValue); break;
            case "rot":     placement.rot.Yaw = UiSettingToFloat(settingValue); break;
        }
        settings.placement = placement;
    }
    // ------------------------------------------------------------------------
    // definition creation
    // ------------------------------------------------------------------------
    public function asDefinition() : SEncValue {
        return RotPosToEncValue(placement.pos, placement.rot);
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
