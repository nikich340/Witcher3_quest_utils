// ----------------------------------------------------------------------------
class CRadishParticlesProxy extends CRadishGenericEntityProxy {
    // ------------------------------------------------------------------------
    private var particleEmitter: CEntity;
    private var emitterPreviewId: String;
    // ------------------------------------------------------------------------
    public function setSettings(settings: SRadishLayerGenericEntityData) {
        super.setSettings(settings);
        setParticlesPreviewId(settings.particlesPreview);
    }
    // ------------------------------------------------------------------------
    public function setParticlesPreviewId(particlesPreview: String) {
        if (emitterPreviewId != particlesPreview) {
            destroyParticlesEmitter();
            emitterPreviewId = particlesPreview;
            spawnParticlesEmitter();
        }
    }
    // ------------------------------------------------------------------------
    public function getParticlesPreviewId() : String {
        return emitterPreviewId;
    }
    // ------------------------------------------------------------------------
    protected function spawnParticlesEmitter() {
        var template: CEntityTemplate;

        if (!hasVisibleSource) {
            if (emitterPreviewId != "") {
                template = (CEntityTemplate)LoadResource("dlc/modtemplates/radishquestui/particles/" + emitterPreviewId, true);
                particleEmitter = theGame.CreateEntity(template, placement.pos, placement.rot);
                particleEmitter.AddTag('RADUI');
            }
        }
    }
    // ------------------------------------------------------------------------
    protected function destroyParticlesEmitter() {
        particleEmitter.StopAllEffects();
        particleEmitter.Destroy();
    }
    // ------------------------------------------------------------------------
    protected function spawn() {
        super.spawn();
        spawnParticlesEmitter();
    }
    // ------------------------------------------------------------------------
    public function destroy() {
        destroyParticlesEmitter();
        super.destroy();
    }
    // ------------------------------------------------------------------------
    public function moveTo(newPlacement: SRadishPlacement) {
        super.moveTo(newPlacement);
        particleEmitter.TeleportWithRotation(placement.pos, placement.rot);
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
