// ----------------------------------------------------------------------------
class CRadishQuestLayerParticles extends CRadishQuestGenericEntity {
    // ------------------------------------------------------------------------
    default entityType = "static";
    default specialization = "particles";
    // ------------------------------------------------------------------------
    protected function initProxy() {
        // use specialized proxy
        proxy = new CRadishParticlesProxy in this;
        proxy.init(proxyTemplate, placement, this.initializedFromEntity);

        ((CRadishParticlesProxy)proxy).setSettings(settings);
    }
    // ------------------------------------------------------------------------
    public function initFromDbgInfos(entity: CEntity) {
        var comp: CParticleComponent;

        comp = ((CParticleComponent)entity.GetComponentByClassName('CParticleComponent'));

        settings.particles = comp.particleSystem.GetPath();

        extractAdditionalDbgInfos(comp);

        super.initFromDbgInfos(entity);
    }
    // ------------------------------------------------------------------------
    protected function extractAdditionalDbgInfos(comp: CParticleComponent) {
        var i, s: int;

        s = comp.dbgInfo.Size();
        for (i = 0; i < s; i += 1) {
            switch (comp.dbgInfo[i].type) {
                case "proxytemplate":  settings.particlesPreview = comp.dbgInfo[i].s; break;
            }
        }
    }
    // ------------------------------------------------------------------------
    public function cloneFrom(src: CRadishLayerEntity) {
        super.cloneFrom(src);
        // set default event
        if (settings.particles == "") {
            settings.particles = "fx\level_specific\novigad\swamps_waterfall_mist.w2p";
            settings.particlesPreview = "swamps_waterfall_mist.w2ent";
            // update proxy
            refreshRepresentation();
        }
    }
    // ------------------------------------------------------------------------
    // settings
    // ------------------------------------------------------------------------
    public function setSettings(newSettings: SRadishLayerGenericEntityData) {
        super.setSettings(newSettings);

        ((CRadishParticlesProxy)proxy).setSettings(newSettings);
    }
    // ------------------------------------------------------------------------
    public function refreshRepresentation() {
        ((CRadishParticlesProxy)proxy).setSettings(settings);
    }
    // ------------------------------------------------------------------------
    // settings editing (text input)
    // ------------------------------------------------------------------------
    public function addUiSettings(settingsList: CRadishUiSettingsList) {
        settingsList.addSetting("particles", "particles: " + UiFormatString(settings.particles));
        super.addUiSettings(settingsList);
    }
    // ------------------------------------------------------------------------
    public function getAsUiSetting(id: String) : IModUiSetting {
        var null: IModUiSetting;
        switch (id) {
            case "particles":    return ParticlesToUiSetting(this, settings.particles);

            default: return super.getAsUiSetting(id);
        }
    }
    // ------------------------------------------------------------------------
    public function syncSetting(id: String, settingValue: IModUiSetting) {
        switch (id) {
            case "particles":
                settings.particles = ((CModUiParticlesUiSetting)settingValue).value;
                settings.particlesPreview = ((CRadishParticlesProxy)proxy).getParticlesPreviewId();
                break;

            default:            super.syncSetting(id, settingValue);
        }
        settings.placement = placement;
    }
    // ------------------------------------------------------------------------
    // definition creation
    // ------------------------------------------------------------------------
    protected function createAdditionalDbgInfos() : SEncValue {
        var debug: SEncValue;

        debug = encValueNewMap();

        encMapPush_str_opt("proxytemplate", settings.particlesPreview, "", debug);

        return debug;
    }
    // ------------------------------------------------------------------------
    protected function componentAsDefinition() : SEncValue {
        var particles: SEncValue;

        particles = encValueNewMap();

        // add additional debug infos that cannot be saved in "real" properties
        // e.g. info for preview templates
        encMapPush(".debug", createAdditionalDbgInfos(), particles);

        encMapPush_str(".type", "CParticleComponent", particles);
        encMapPush_str("particleSystem", settings.particles, particles);
        encMapPush_bool("isStreamed", false, particles);

        return particles;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
