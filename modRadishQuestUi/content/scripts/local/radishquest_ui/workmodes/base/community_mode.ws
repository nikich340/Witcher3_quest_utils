// ----------------------------------------------------------------------------
abstract state RadUi_ElementEditing in CRadishCommunityElementMode extends RadUi_FilteredListSelect
{
    protected var itemEditor: IRadishUiModeCommunityElementEditor;
    protected var editedSetting: IModUiSetting;
    protected var unlocked: bool;

    protected var isValueEditing: bool;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        // alias
        itemEditor = parent.itemEditor;
        unlocked = parent.unlocked;

        // update fields if the menu is already open
        parent.view.listMenuRef.setTitle(parent.view.title);
        parent.view.listMenuRef.setStatsLabel(parent.view.statsLabel);

        listProvider = itemEditor.getSettingsList();

        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        ((CRadishCommunityElementEditor)itemEditor).clearHighlighted();
        super.OnLeaveState(nextStateName);
    }
    // ------------------------------------------------------------------------
    event OnSelected(selectedId: String) {
        if (listProvider.setSelection(selectedId, true)) {
            itemEditor.select(selectedId);
        }
        updateView();
    }
    // ------------------------------------------------------------------------
    // -- overwritten to handle filtering AND value editing
    event OnInputCancel() {
        if (isValueEditing) {
            parent.notice(GetLocStringByKeyExt("RADUI_iEditCanceled"));
        } else {
            parent.notice(GetLocStringByKeyExt("UI_CanceledSearch"));
        }

        isValueEditing = false;
        parent.view.listMenuRef.resetEditField();
        updateView();
    }
    // ------------------------------------------------------------------------
    // -- overwritten to handle filtering AND value editing
    event OnInputEnd(inputString: String) {
        if (inputString == "") {
            OnResetFilter();
        } else {
            if (isValueEditing) {
                if (editedSetting.parseAndUpdate(inputString)) {
                    itemEditor.syncSelectedSetting();
                } else {
                    parent.error(GetLocStringByKeyExt("RADUI_eSettingUpdateFailed")
                        + GetLocStringByKeyExt(editedSetting.getLastError()));
                }
                parent.view.listMenuRef.resetEditField();
            } else {
                // Note: filter field is not removed to indicate the current filter
                listProvider.setWildcardFilter(inputString);
            }
            updateView();
        }
        isValueEditing = false;
    }
    // ------------------------------------------------------------------------
    event OnEditSetting(action: SInputAction) {
        if (unlocked && IsPressed(action) && !parent.view.listMenuRef.isEditActive()) {
            editedSetting = itemEditor.getSelected();
            //TODO more advanced settings branch into new state (select template, search area, ap, etc)
            //-> check on customIno ?
            if (editedSetting.isEditable()) {
                isValueEditing = true;
                parent.view.listMenuRef.startInputMode(
                    GetLocStringByKeyExt("RADUI_lEditSetting"), editedSetting.asString());
            } else {
                parent.error(GetLocStringByKeyExt("RADUI_eSettingReadOnly"));
            }
        }
    }
    // ------------------------------------------------------------------------
    event OnBack(action: SInputAction) {
        parent.backToParent(action);
    }
    // ------------------------------------------------------------------------
    event OnChangeWorkMode(action: SInputAction) {
        // direct jump to top level required
        parent.backToParent(action);
    }
    // ------------------------------------------------------------------------
    event OnInteractiveCam(action: SInputAction) {
        if (IsReleased(action)) {
            parent.showUi(false);
            parent.PushState('RadUi_InteractiveCamera');
        }
    }
    // ------------------------------------------------------------------------
    event OnToggleCamFollow(action: SInputAction) {
        if (IsPressed(action)) {
            if (parent.config.isAutoCamOnSelect()) {
                parent.notice(GetLocStringByKeyExt("RADUI_iCamFollowOff"));
            } else {
                parent.notice(GetLocStringByKeyExt("RADUI_iCamFollowOn"));

                ((CRadishCommunityElementEditor)itemEditor).refreshHighlight(true);
            }
            parent.config.toggleAutoCamOnSelect();
        }
    }
    // ------------------------------------------------------------------------
    event OnSwitchCamToHighlighted(action: SInputAction) {
        if (IsPressed(action)) {
            ((CRadishCommunityElementEditor)itemEditor).refreshHighlight(true);
        }
    }
    // ------------------------------------------------------------------------
    event OnEntityHotkeyHelp(subtype: String, out hotkeyList: array<SModUiHotkeyHelp>) {
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SwitchCamToHighlighted'));
        hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleInteractiveCam', , IK_LControl));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ToggleCamFollowMode'));
        if (unlocked) {
            hotkeyList.PushBack(HotkeyHelp_from('RADUI_EditSetting'));
        }
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectPrev', "RADUI_SelectPrevSetting"));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectNext', "RADUI_SelectNextSetting"));
        super.OnHotkeyHelp(hotkeyList);
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_BackToTop', "RADUI_BackToTopCommunity"));
    }
    // ------------------------------------------------------------------------
    protected function setupLabels(type: String, prefix: String) {
        var itemName: String;

        itemName = prefix + parent.itemEditor.getElementCaption();
        // use parent unlocked as the local one may not be synced!
        if (!parent.unlocked) {
            // indicate readonly by different layername color
            itemName = "<font color=\"#ED8D33\">" + itemName + "</font>";
        }

        parent.view.title = GetLocStringByKeyExt("RADUI_" + type + "SettingsTitle") + " " + itemName;
        parent.view.statsLabel = GetLocStringByKeyExt("RADUI_" + type + "SettingsListStats");
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();
        theInput.RegisterListener(this, 'OnChangeWorkMode', 'RADUI_BackToTop');
        theInput.RegisterListener(this, 'OnInteractiveCam', 'RAD_ToggleInteractiveCam');
        theInput.RegisterListener(this, 'OnSwitchCamToHighlighted', 'RADUI_SwitchCamToHighlighted');
        theInput.RegisterListener(this, 'OnToggleCamFollow', 'RADUI_ToggleCamFollowMode');
        //theInput.RegisterListener(this, 'OnCycleProxyAppearance', 'RADUI_CycleProxyAppearance');
        if (unlocked) {
            //theInput.RegisterListener(this, 'OnEditSetting', 'RADUI_EditSetting');
        } else {
            //theInput.RegisterListener(parent, 'OnLockedMode', 'RADUI_EditSetting');
        }
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        theInput.UnregisterListener(this, 'RADUI_BackToTop');
        theInput.UnregisterListener(this, 'RAD_ToggleInteractiveCam');
        theInput.UnregisterListener(this, 'RADUI_SwitchCamToHighlighted');
        theInput.UnregisterListener(this, 'RADUI_ToggleCamFollowMode');
        //theInput.UnregisterListener(this, 'RADUI_CycleProxyAppearance');
        if (unlocked) {
            //theInput.UnregisterListener(this, 'RADUI_EditSetting');
        } else {
            //theInput.UnregisterListener(parent, 'RADUI_EditSetting');
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
abstract statemachine class CRadishCommunityElementMode extends CRadishListViewWorkMode {
    // ------------------------------------------------------------------------
    protected var itemEditor: IRadishUiModeCommunityElementEditor;
    protected var unlocked: bool;
    // ------------------------------------------------------------------------
    public function init(itemEditor: IRadishUiModeManager, config: CRadishQuestConfigManager)
    {
        super.init(itemEditor, config);
        this.itemEditor = (IRadishUiModeCommunityElementEditor)itemEditor;
    }
    // ------------------------------------------------------------------------
    public function unlockEditing() {
        this.unlocked = true;
    }
    // ------------------------------------------------------------------------
    public function getStateName() : String {
        if (unlocked) {
            return GetLocStringByKeyExt(NameToString(GetCurrentStateName()));
        } else {
            return GetLocStringByKeyExt(NameToString(GetCurrentStateName()) + "Locked");
        }
    }
    // ------------------------------------------------------------------------
    public function getGeneralHelp() : String {
        if (unlocked) {
            return GetLocStringByKeyExt(generalHelpKey);
        } else {
            return GetLocStringByKeyExt(generalHelpKey + "Locked");
        }
    }
    // ------------------------------------------------------------------------
    event OnLockedMode() {
        this.error(GetLocStringByKeyExt("RADUI_eReadOnlyMode"));
    }
    // ------------------------------------------------------------------------
    event OnEntityHotkeyHelp(subtype: String, out hotkeyList: array<SModUiHotkeyHelp>) { }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
