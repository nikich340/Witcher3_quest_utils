// ----------------------------------------------------------------------------
state RadUi_ParticlesSelection in CRadishQuestLayerEntityMode
    extends RadUi_GenericListSettingSelection
{
    // ------------------------------------------------------------------------
    default labelPrefixId = "ParticlesSetting";
    // ------------------------------------------------------------------------
    protected function onListSelection(selectedId: String) {
        var proxy: CRadishParticlesProxy;
        var setting: CModUiParticlesUiSetting;
        var previewId: String;

        super.onListSelection(selectedId);

        setting = (CModUiParticlesUiSetting)editedSetting;
        proxy = (CRadishParticlesProxy)selected.getProxy();

        // get preview template
        previewId = ((CGenericListSettingList)listProvider).getExtraData(
            setting.getValueId(), 6);

        proxy.setParticlesPreviewId(previewId);
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
