// ----------------------------------------------------------------------------
class CModUiParticlesUiSetting extends CModUiGenericListUiSetting {
    // ------------------------------------------------------------------------
    default valueListId = "particles";
    default workModeState = 'RadUi_ParticlesSelection';
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
function ParticlesToUiSetting(
    parentObj: CObject, particles: String) : CModUiParticlesUiSetting
{
    var s: CModUiParticlesUiSetting;
    s = new CModUiParticlesUiSetting in parentObj;
    s.setValueId(particles);

    return s;
}
// ----------------------------------------------------------------------------
