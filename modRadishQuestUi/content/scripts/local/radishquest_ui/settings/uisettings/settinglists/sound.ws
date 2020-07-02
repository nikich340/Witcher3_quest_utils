// ----------------------------------------------------------------------------
class CModUiAmbientSoundUiSetting extends CModUiGenericListUiSetting {
    // ------------------------------------------------------------------------
    default valueListId = "sound_ambient";
    default workModeState = 'RadUi_AmbientSoundSelection';
    // ------------------------------------------------------------------------
    public var sound: String;
    public var bank: String;
    // ------------------------------------------------------------------------
    public function setValueId(valueId: String) {
        value = valueId;
        StrSplitFirst(valueId, ":", bank, sound);
    }
    // ------------------------------------------------------------------------
    public function asString() : String {
        return sound;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CModUiReverbSoundUiSetting extends CModUiGenericListUiSetting {
    // ------------------------------------------------------------------------
    default valueListId = "sound_reverb";
    default workModeState = 'RadUi_ReverbSoundSelection';
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
function AmbientSoundToUiSetting(
    parentObj: CObject, sound: String, bankdependency: String) : CModUiAmbientSoundUiSetting
{
    var s: CModUiAmbientSoundUiSetting;
    s = new CModUiAmbientSoundUiSetting in parentObj;
    s.setValueId(bankdependency + ":" + sound);

    return s;
}
// ----------------------------------------------------------------------------
function ReverbSoundToUiSetting(
    parentObj: CObject, reverbName: String) : CModUiReverbSoundUiSetting
{
    var s: CModUiReverbSoundUiSetting;
    s = new CModUiReverbSoundUiSetting in parentObj;
    s.setValueId(reverbName);

    return s;
}
// ----------------------------------------------------------------------------
