// ----------------------------------------------------------------------------
abstract state RadUi_GenericListSettingSelection in CRadishQuestLayerEntityMode
    extends RadUi_BaseListSettingSelection
{
    default workContext = 'MOD_RadishUi_GenericListSettingSelection';
    // ------------------------------------------------------------------------
    protected var labelPrefixId: String; default labelPrefixId = "GenericSetting";
    protected var changedInfoId: String; default changedInfoId = "RADUI_iChangedSetting";
    protected var selectPrefixId: String; default selectPrefixId = "GenericSetting";
    // ------------------------------------------------------------------------
    protected var selected: CRadishLayerEntity;
    protected var editedSetting: CModUiGenericListUiSetting;

    protected var camPlacement: SRadishPlacement;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        selected = parent.itemManager.getSelected();
        editedSetting = (CModUiGenericListUiSetting)parent.entityEditor.getSelected();

        theCam = parent.itemManager.getCam();
        camPlacement = theCam.getSettings();

        // required for switchToEntity camera changes
        proxy = (CRadishProxyRepresentation)selected.getProxy();

        if (parent.config.isAutoCamOnSelect()) {
            parent.itemManager.switchCamTo(RadUi_createCamSettingsFor(
                RadUiCam_EntityPreview, proxy));
        }

        listProvider = parent.getListProvider(editedSetting.getValueListId());
        this.setListSelection();

        super.setupLabels(labelPrefixId, selected.getCaption());
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        parent.entityEditor.syncSelectedSetting();
        super.OnLeaveState(nextStateName);
    }
    // ------------------------------------------------------------------------
    protected function setListSelection() {
        listProvider.setSelection(editedSetting.getValueId(), true);
    }
    // ------------------------------------------------------------------------
    protected function onListSelection(selectedId: String) {
        editedSetting.setValueId(selectedId);
    }
    // ------------------------------------------------------------------------
    event OnSelected(selectedId: String) {
        if (listProvider.setSelection(selectedId, true)) {
            onListSelection(selectedId);
            parent.notice(
                GetLocStringByKeyExt(changedInfoId) + " " + editedSetting.asString()
            );

            if (parent.config.isAutoCamOnSelect()) {
                adjustInteractivesCam(proxy);
            }
        }
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        super.OnHotkeyHelp(hotkeyList);
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectPrev', "RADUI_" + selectPrefixId + "SelectPrev"));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectNext', "RADUI_" + selectPrefixId + "SelectNext"));
    }
    // ------------------------------------------------------------------------
    // entry functions seem to require having different names (in hierarchy)
    protected entry function adjustInteractivesCam(proxy: CRadishProxyRepresentation) {
        latentCamAdjust(proxy);
    }
    // ------------------------------------------------------------------------
}