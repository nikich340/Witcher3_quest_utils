// ----------------------------------------------------------------------------
state RadUi_ReverbSoundSelection in CRadishQuestLayerEntityMode
    extends RadUi_GenericListSettingSelection
{
    // ------------------------------------------------------------------------
    default labelPrefixId = "ReverbSetting";
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
state RadUi_AmbientSoundSelection in CRadishQuestLayerEntityMode
    extends RadUi_GenericListSettingSelection
{
    // ------------------------------------------------------------------------
    default labelPrefixId = "AmbientSoundSetting";
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        theSound.SoundEvent("amb_pause_all");
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        theSound.SoundEvent("amb_resume_all");
        super.OnLeaveState(nextStateName);
    }
    // ------------------------------------------------------------------------
    protected function onListSelection(selectedId: String) {
        var proxy: CRadishSoundAreaProxy;
        var setting: CModUiAmbientSoundUiSetting;

        super.onListSelection(selectedId);

        setting = (CModUiAmbientSoundUiSetting)editedSetting;
        proxy = (CRadishSoundAreaProxy)selected.getProxy();

        if (proxy) {
            proxy.setSoundSettings(setting.bank, setting.sound);
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
