// ----------------------------------------------------------------------------
class CModUiEnvDefUiSetting extends CModUiGenericListUiSetting {
    // ------------------------------------------------------------------------
    default valueListId = "env";
    default workModeState = 'RadUi_EnvDefSelection';
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
function EnvDefToUiSetting(parentObj: CObject, env: String) : CModUiEnvDefUiSetting {
    var s: CModUiEnvDefUiSetting;
    s = new CModUiEnvDefUiSetting in parentObj;
    s.setValueId(env);

    return s;
}
// ----------------------------------------------------------------------------
