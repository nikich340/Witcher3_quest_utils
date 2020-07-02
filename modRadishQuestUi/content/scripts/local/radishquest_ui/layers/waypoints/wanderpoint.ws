// ----------------------------------------------------------------------------
class CRadishQuestLayerWanderpoint extends CRadishQuestLayerMappin {
    // ------------------------------------------------------------------------
    default entityType = "waypoint";
    default specialization = "wander";
    // ------------------------------------------------------------------------
    default proxyTemplate = "engine\templates\editor\markers\review\closed_flag.w2ent";
    // ------------------------------------------------------------------------
    public function initFromDbgInfos(entity: CEntity) {
        super.initFromDbgInfos(entity);

        // default color
        setAppearance('green');
    }
    // ------------------------------------------------------------------------
    public function cloneFrom(src: CRadishLayerEntity) {
        super.cloneFrom(src);

        // default color
        setAppearance('green');
        refreshRepresentation();
    }
    // ------------------------------------------------------------------------
    protected function restoreFromDbgInfo(dbgInfo: SDbgInfo) {
        switch (dbgInfo.type) {
            case "radius":      settings.radius = RoundF(dbgInfo.f);  break;
        }
        settings.placement = placement;
    }
    // ------------------------------------------------------------------------
    // settings editing (text input)
    // ------------------------------------------------------------------------
    public function addUiSettings(settingsList: CRadishUiSettingsList) {
        settingsList.addSetting("tags", "tags: [auto]");
        settingsList.addSetting("pos", "position: " + UiSettingVecToString(settings.placement.pos));
        settingsList.addSetting("r", "radius: " + settings.radius);
        //super.addUiSettings(settingsList);
    }
    // ------------------------------------------------------------------------
    public function getAsUiSetting(id: String) : IModUiSetting {
        var null: IModUiSetting;
        switch (id) {
            case "tags":    return ReadOnlyUiSetting(this);
            case "pos":     return VecToUiSetting(this, settings.placement.pos);
            case "r":       return IntToUiSetting(this, settings.radius);
            default:        return null;
            //default: return super.getAsUiSetting(selectedId);
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
            //default:            super.syncSetting(id, settingValue);
        }
        settings.placement = placement;
    }
    // ------------------------------------------------------------------------
    // definition creation
    // ------------------------------------------------------------------------
    public function asDefinition() : SEncValue {
        var content: SEncValue;

        if (settings.radius > 0) {
            content = encValueNewList();
            encListPush_float(placement.pos.X, content);
            encListPush_float(placement.pos.Y, content);
            encListPush_float(placement.pos.Z, content);
            encListPush_int(settings.radius, content);
            return content;
        } else {
            return PosToEncValue(placement.pos);
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
