// ----------------------------------------------------------------------------
class CModUiEntityTemplateUiSetting extends CModUiGenericListUiSetting {
    // ------------------------------------------------------------------------
    default valueListId = "entity_templates";
    default workModeState = 'RadUi_StaticsTemplateSelection';
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CModUiInteractiveTemplateUiSetting extends CModUiEntityTemplateUiSetting {
    // ------------------------------------------------------------------------
    default workModeState = 'RadUi_InteractivesTemplateSelection';
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
function TemplateToUiSetting(parentObj: CObject, value: String) : CModUiEntityTemplateUiSetting
{
    var s: CModUiEntityTemplateUiSetting;
    s = new CModUiEntityTemplateUiSetting in parentObj;
    s.value = value;

    return s;
}
// ----------------------------------------------------------------------------
function InteractivesTemplateToUiSetting(parentObj: CObject, value: String) : CModUiInteractiveTemplateUiSetting
{
    var s: CModUiInteractiveTemplateUiSetting;
    s = new CModUiInteractiveTemplateUiSetting in parentObj;
    s.value = value;

    return s;
}
// ----------------------------------------------------------------------------
