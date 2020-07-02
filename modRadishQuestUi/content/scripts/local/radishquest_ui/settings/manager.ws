// ----------------------------------------------------------------------------
class CRadishQuestConfigManager extends IRadishConfigManager {
    protected var log: CModLogger;

    protected var config: SRadishUiConfig;
    // ------------------------------------------------------------------------
    public function init(log: CModLogger, configData: CRadishQuestConfigData) {
        this.log = log;

        if (config == configData.config) {
            // not set -> setup defaults
            config = getDefaults();
        } else {
            config = configData.config;
        }
    }
    // ------------------------------------------------------------------------
    private function getDefaults() : SRadishUiConfig {
        return SRadishUiConfig(
            // DO NOT CHANGE ORDER (important for initialization!)
            SRadishCamConfig(
                SRadishInteractiveStepConfig(0.025, 0.05),
                SRadishInteractiveStepConfig(0.25, 0.10),
                SRadishInteractiveStepConfig(0.80, 0.20),
                true,
                RadUi_createCamSettingsFor(RadUiCam_Empty)
            ),
            SRadishPlacementConfig(
                SRadishInteractiveStepConfig(0.005, 0.1),
                SRadishInteractiveStepConfig(0.03, 0.2),
                SRadishInteractiveStepConfig(0.1, 0.3),
            )
        );
    }
    // ------------------------------------------------------------------------
    // setter
    // ------------------------------------------------------------------------
    public function setLastCamPosition(placement: SRadishPlacement) {
        config.cam.lastPos = placement;
    }
    // ------------------------------------------------------------------------
    public function setAutoCamOnSelect(doSwitch: bool) {
        config.cam.switchOnSelect = doSwitch;
    }
    // ------------------------------------------------------------------------
    // getter
    // ------------------------------------------------------------------------
    public function getLastCamPosition(): SRadishPlacement {
        return config.cam.lastPos;
    }
    // ------------------------------------------------------------------------
    public function isAutoCamOnSelect() : bool {
        return config.cam.switchOnSelect;
    }
    // ------------------------------------------------------------------------
    public function toggleAutoCamOnSelect() {
        config.cam.switchOnSelect = !config.cam.switchOnSelect;
    }
    // ------------------------------------------------------------------------
    public function getCamConfig() : SRadishCamConfig {
        return config.cam;
    }
    // ------------------------------------------------------------------------
    public function getPlacementConfig() : SRadishPlacementConfig {
        return config.placement;
    }
    // ------------------------------------------------------------------------
    public function getConfig() : CRadishQuestConfigData {
        var configData: CRadishQuestConfigData;

        configData = new CRadishQuestConfigData in this;
        configData.config = config;

        return configData;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
