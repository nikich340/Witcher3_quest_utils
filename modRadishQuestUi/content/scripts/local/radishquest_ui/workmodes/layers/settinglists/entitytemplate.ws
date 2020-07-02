// ----------------------------------------------------------------------------
state RadUi_StaticsTemplateSelection in CRadishQuestLayerEntityMode
    extends RadUi_GenericListSettingSelection
{
    // ------------------------------------------------------------------------
    default labelPrefixId = "StaticTemplate";
    default changedInfoId = "RADUI_iChangedEntityTemplate";
    default selectPrefixId = "EntityTemplate";
    // ------------------------------------------------------------------------
    protected function onListSelection(selectedId: String) {
        var proxy: CRadishPermanentProxy;

        super.onListSelection(selectedId);

        proxy = (CRadishPermanentProxy)selected.getProxy();
        proxy.setPermanentTemplate(selectedId);
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
state RadUi_InteractivesTemplateSelection in CRadishQuestLayerEntityMode
    extends RadUi_StaticsTemplateSelection
{
    // ------------------------------------------------------------------------
    default labelPrefixId = "InteractiveTemplate";
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
