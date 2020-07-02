// ----------------------------------------------------------------------------
state RadUi_ComActorEditing in CRadishCommunityActorMode extends RadUi_ElementEditing
{
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        //elementEditor = new CRadishCommunityActorEditor in this;
        //element = parent.itemEditor.getSelected();

        super.setupLabels("ComActor", parent.itemEditor.getCommunityCaption() + "/");
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    /*
    event OnEditSetting(action: SInputAction) {
        //TODO branch on advanced -> template selection -> new state
        if (unlocked && IsPressed(action) && !parent.view.listMenuRef.isEditActive()) {
            editedSetting = entityEditor.getSelected();
            if (editedSetting.isEditable()) {
                isValueEditing = true;
                parent.view.listMenuRef.startInputMode(
                    GetLocStringByKeyExt("RADUI_lEditSetting"), editedSetting.asString());
            } else {
                parent.error(GetLocStringByKeyExt("RADUI_eSettingReadOnly"));
            }
        }
    }*/
    // ------------------------------------------------------------------------
    /*event OnToggleAppearance(action: SInputAction) {
        if (IsPressed(action)) {
            entity.cycleAppearance();
        }
    }*/
    // ------------------------------------------------------------------------
    event OnEntityHotkeyHelp(entitytype: String, out hotkeyList: array<SModUiHotkeyHelp>) {
        if (unlocked) {
            //hotkeyList.PushBack(HotkeyHelp_from('RADUI_EditSetting'));
        }
        //hotkeyList.PushBack(HotkeyHelp_from('RADUI_CycleProxyAppearance', "RADUI_CycleProxyAppearanceActor"));
        super.OnHotkeyHelp(hotkeyList);
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();
        //theInput.RegisterListener(this, 'OnCycleProxyAppearance', 'RADUI_CycleProxyAppearance');
        if (unlocked) {
            //theInput.RegisterListener(this, 'OnEditSetting', 'RADUI_EditSetting');
        }
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        //theInput.UnregisterListener(this, 'RADUI_CycleProxyAppearance');
        if (unlocked) {
            //theInput.UnregisterListener(this, 'RADUI_EditSetting');
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
statemachine class CRadishCommunityActorMode extends CRadishCommunityElementMode {
    // ------------------------------------------------------------------------
    default workMode = 'RADUI_Com_ModeActor';
    default workContext = 'MOD_RadishUi_Com_ModeActor';
    default generalHelpKey = "RADUI_ComActorGeneralHelp";
    default defaultState = 'RadUi_ComActorEditing';
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
