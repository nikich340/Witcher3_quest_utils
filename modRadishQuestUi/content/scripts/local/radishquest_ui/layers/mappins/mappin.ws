// ----------------------------------------------------------------------------
class CRadishQuestLayerMappin extends CRadishLayerEntitySetMember {
    // ------------------------------------------------------------------------
    default entityType = "mappin";
    // ------------------------------------------------------------------------
    default proxyTemplate = "dlc\modtemplates\radishquestui\flags\mappin.w2ent";
    // ------------------------------------------------------------------------
    protected var settings: SRadishLayerMappinData;
    // ------------------------------------------------------------------------
    public function init(layerId: SRadUiLayerId, newPlacement: SRadishPlacement)
    {
        // init settings before call to setupProxy (in init)
        settings.radius = 0;
        settings.placement = newPlacement;
        super.init(layerId, newPlacement);
    }
    // ------------------------------------------------------------------------
    protected function initProxy() {
        proxy = new CRadishMappinProxy in this;
        proxy.init(proxyTemplate, placement, false);

        ((CRadishMappinProxy)proxy).setSettings(settings);
    }
    // ------------------------------------------------------------------------
    public function initFromData(data: SRadishLayerMappinData) {
        initProxy();
        setSettings(data);
    }
    // ------------------------------------------------------------------------
    protected function restoreFromDbgInfo(dbgInfo: SDbgInfo) {
        switch (dbgInfo.type) {
            case "radius":      settings.radius = dbgInfo.i;  break;
        }
        settings.placement = placement;
    }
    // ------------------------------------------------------------------------
    public function cloneFrom(src: CRadishLayerEntity) {
        var newSettings: SRadishLayerMappinData;

        super.cloneFrom(src);

        newSettings = ((CRadishQuestLayerMappin)src).getSettings();
        // placement is valid in all "other" types
        newSettings.placement = src.getPlacement();

        this.initFromData(newSettings);
    }
    // ------------------------------------------------------------------------
    public function getExtendedCaption() : String {
        if (settings.radius > 0) {
            return super.getExtendedCaption() + " (" + settings.radius + ")";
        } else {
            return super.getExtendedCaption();
        }
    }
    // ------------------------------------------------------------------------
    // expands/reduces proxy border by amount with center as direction
    public function expandRadius(amount: float) : bool {
        var newPoints: array<Vector>;
        if ((settings.radius <= 0 && amount <= 0) || (settings.radius >= 250 && amount >=0)) {
            return false;
        }
        settings.radius = Clamp(settings.radius + RoundF(amount), 0, 250);

        ((CRadishMappinProxy)proxy).setSettings(settings);
        return true;
    }
    // ------------------------------------------------------------------------
    // settings
    // ------------------------------------------------------------------------
    public function getSettings() : SRadishLayerMappinData {
        settings.id = id.entityName;
        settings.pointname = id.entityName;

        // this has to be updated as base class contains the current placement data
        settings.placement = placement;
        return settings;
    }
    // ------------------------------------------------------------------------
    public function setSettings(newSettings: SRadishLayerMappinData) {
        settings = newSettings;
        placement = settings.placement;
        setName(settings.pointname);
        ((CRadishMappinProxy)proxy).setSettings(settings);
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
        ((CRadishMappinProxy)proxy).setSettings(settings);
    }
    // ------------------------------------------------------------------------
    // settings editing (text input)
    // ------------------------------------------------------------------------
    public function addUiSettings(settingsList: CRadishUiSettingsList) {
        settingsList.addSetting("pos", "position: " + UiSettingVecToString(settings.placement.pos));
        settingsList.addSetting("r", "radius: " + settings.radius);
    }
    // ------------------------------------------------------------------------
    public function getAsUiSetting(id: String) : IModUiSetting {
        var null: IModUiSetting;
        switch (id) {
            case "pos":     return VecToUiSetting(this, settings.placement.pos);
            case "r":       return IntToUiSetting(this, settings.radius);
            default:        return null;
        }
    }
    // ------------------------------------------------------------------------
    public function syncSetting(id: String, settingValue: IModUiSetting) {
        switch (id) {
            case "pos":     placement.pos = UiSettingToVector(settingValue); break;
            case "r":       settings.radius = UiSettingToInt(settingValue); break;
            default:
                super.syncSetting(id, settingValue);
                settings.placement = placement;
        }
        settings.placement = placement;
    }
    // ------------------------------------------------------------------------
    // definition creation
    // ------------------------------------------------------------------------
    public function asDefinition() : SEncValue {
        var content: SEncValue;

        content = SEncValue(EEVT_Map);
        if (settings.radius > 0) {
            // add comment
            content.m.PushBack(SEncKeyValue("#radius for quest instructions", IntToEncValue(settings.radius)));
            content.m.PushBack(SEncKeyValue("pos", PosToEncValue(placement.pos)));
            return content;
        } else {
            return PosToEncValue(placement.pos);
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
