// ----------------------------------------------------------------------------
statemachine class CStoryBoardShotCamera extends CStaticCamera {
    // ------------------------------------------------------------------------
    protected var settings: SStoryBoardCameraSettings;

    protected var comp: CCameraComponent;
    protected var env: CEnvironmentDefinition;
    protected var gameDofSettings: SStoryBoardCameraDofSettings;
    // ------------------------------------------------------------------------
    event OnSpawned(spawnData: SEntitySpawnData) {
        var world: CGameWorld;
        comp = (CCameraComponent)this.GetComponentByClassName('CCameraComponent');
        world = (CGameWorld)theGame.GetWorld();
        env = world.environmentParameters.environmentDefinition;
    }
    // ------------------------------------------------------------------------
    public function setSettings(newSettings: SStoryBoardCameraSettings) {
        settings = newSettings;
    }
    // ------------------------------------------------------------------------
    public function getSettings() : SStoryBoardCameraSettings {
        return settings;
    }
    // ------------------------------------------------------------------------
    public function switchTo(optional tempSettings: SStoryBoardCameraSettings) {
        var i: SStoryBoardCameraSettings;

        if (!IsRunning()) {
            this.Run();
        }
        if (tempSettings != i) {
            applySettings(tempSettings);
        } else {
            applySettings(settings);
        }
    }
    // ------------------------------------------------------------------------
    protected function getDof() : SStoryBoardCameraDofSettings {
        // don't even think to copy only CEnvDepthOfFieldParameters into local
        // var -> game freezes
        return SStoryBoardCameraDofSettings(
            env.envParams.m_depthOfField.intensity.dataCurveValues[0].lue,
            env.envParams.m_depthOfField.nearBlurDist.dataCurveValues[0].lue,
            env.envParams.m_depthOfField.farBlurDist.dataCurveValues[0].lue,
            env.envParams.m_depthOfField.nearFocusDist.dataCurveValues[0].lue,
            env.envParams.m_depthOfField.farFocusDist.dataCurveValues[0].lue
        );
    }
    // ------------------------------------------------------------------------
    protected function setDof(dof: SStoryBoardCameraDofSettings) {
        env.envParams.m_depthOfField.intensity.dataCurveValues[0].lue = ClampF(dof.strength, 0, 1);
        env.envParams.m_depthOfField.nearBlurDist.dataCurveValues[0].lue = ClampF(dof.blurNear, 0, 30);
        env.envParams.m_depthOfField.farBlurDist.dataCurveValues[0].lue = ClampF(dof.blurFar, 0, 150);
        env.envParams.m_depthOfField.nearFocusDist.dataCurveValues[0].lue = ClampF(dof.focusNear, 0, 30);
        env.envParams.m_depthOfField.farFocusDist.dataCurveValues[0].lue = ClampF(dof.focusFar, 0, 150);
    }
    // ------------------------------------------------------------------------
    protected function applySettings(settings: SStoryBoardCameraSettings) {
        this.TeleportWithRotation(settings.pos, settings.rot);
        this.comp.fov = settings.fov;
        this.setDof(settings.dof);
    }
    // ------------------------------------------------------------------------
    public function activate() {
        this.Run();
        gameDofSettings = getDof();
        settings.dof = gameDofSettings;
        applySettings(settings);
    }
    // ------------------------------------------------------------------------
    public function deactivate() {
        this.setDof(gameDofSettings);
        this.Stop();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
