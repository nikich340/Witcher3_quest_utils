// ----------------------------------------------------------------------------
// extends normal area proxy with additional spound playback ability
class CRadishSoundAreaProxy extends CRadishAreaProxy {
    // ------------------------------------------------------------------------
    private var soundEvent: String;
    private var soundBank: String;
    // ------------------------------------------------------------------------
    private var soundEmitterTemplatePath: String;
    private var soundEmitter: CEntity;
    // ------------------------------------------------------------------------
    default soundEmitterTemplatePath = "dlc\modtemplates\radishquestui\misc\soundemitter.w2ent";
    // ------------------------------------------------------------------------
    public function setSettings(settings: SRadishLayerAreaData) {
        super.setSettings(settings);
        setSoundSettings(settings.banksDependency, settings.soundEvent);
    }
    // ------------------------------------------------------------------------
    public function setSoundSettings(bank: String, sound: String) {
        if (soundEvent != sound) {
            destroySoundEmitter();
            soundBank = bank;
            soundEvent = sound;
            spawnSoundEmitter();
        }
    }
    // ------------------------------------------------------------------------
    protected function spawnSoundEmitter() {
        var template: CEntityTemplate;

        if (!hasVisibleSource) {
            if (soundEvent != "") {
                if (!theSound.SoundIsBankLoaded(soundBank)) {
                    theSound.SoundLoadBank(soundBank, false);
                }

                template = (CEntityTemplate)LoadResource(soundEmitterTemplatePath, true);
                soundEmitter = theGame.CreateEntity(template, placement.pos, placement.rot);
                soundEmitter.AddTag('RADUI');

                soundEmitter.SoundEvent(soundEvent);
            }
        }
    }
    // ------------------------------------------------------------------------
    protected function destroySoundEmitter() {
        soundEmitter.StopAllEffects();
        soundEmitter.Destroy();
    }
    // ------------------------------------------------------------------------
    protected function spawn() {
        super.spawn();
        spawnSoundEmitter();
    }
    // ------------------------------------------------------------------------
    public function destroy() {
        destroySoundEmitter();
        super.destroy();
    }
    // ------------------------------------------------------------------------
    public function moveTo(newPlacement: SRadishPlacement) {
        super.moveTo(newPlacement);
        soundEmitter.Teleport(placement.pos);
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
