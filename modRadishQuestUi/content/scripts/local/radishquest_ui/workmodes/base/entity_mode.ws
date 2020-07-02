// ----------------------------------------------------------------------------
abstract state RadUi_EntityEditing in CRadishQuestLayerEntityMode extends RadUi_FilteredListSelect
{
    //todo move into state machine to have access to selected setting in assetselection state?
    protected var entityEditor: IRadishUiModeEntityEditor;
    protected var entity: CRadishLayerEntity;
    protected var editedSetting: IModUiSetting;
    protected var unlocked: bool;

    protected var isValueEditing: bool;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        unlocked = parent.unlocked;
        entityEditor.init(parent.log, entity);

        // store in parent to have access to edited setting in subworkmodes
        // (e.g. GenericListSettingSelection)
        parent.entityEditor = entityEditor;

        // update fields if the menu is already open
        parent.view.listMenuRef.setTitle(parent.view.title);
        parent.view.listMenuRef.setStatsLabel(parent.view.statsLabel);

        listProvider = entityEditor.getSettingsList();

        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnSelected(selectedId: String) {
        if (listProvider.setSelection(selectedId, true)) {
            entityEditor.select(selectedId);
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
                    entityEditor.syncSelectedSetting();
                    entity.refreshRepresentation();
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
        var boolSetting: CModUiBoolSetting;

        if (unlocked && IsPressed(action) && !parent.view.listMenuRef.isEditActive()) {
            editedSetting = entityEditor.getSelected();
            if ((CModUiGenericListUiSetting)editedSetting) {
                parent.PushState(((CModUiGenericListUiSetting)editedSetting).getWorkmodeState());
            } else if ((CModUiBoolSetting)editedSetting) {
                // just flip bool instead of editing
                boolSetting = (CModUiBoolSetting)editedSetting;
                boolSetting.value = !boolSetting.value;
                entityEditor.syncSelectedSetting();
                entity.refreshRepresentation();
                updateView();
            } else if (editedSetting.isEditable()) {
                isValueEditing = true;
                parent.view.listMenuRef.startInputMode(
                    GetLocStringByKeyExt("RADUI_lEditSetting"), editedSetting.asString());
            } else {
                parent.error(GetLocStringByKeyExt("RADUI_eSettingReadOnly"));
            }
        }
    }
    // ------------------------------------------------------------------------
    event OnCycleAppearance(action: SInputAction) {
        if (IsPressed(action)) {
            entity.cycleAppearance();
        }
    }
    // ------------------------------------------------------------------------
    event OnBack(action: SInputAction) {
        parent.backToPreviousState(action);
    }
    // ------------------------------------------------------------------------
    event OnChangeWorkMode(action: SInputAction) {
        // direct jump to top level required
        entity.highlight(false);
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
    event OnInteractivePlacement(action: SInputAction) {
        if (unlocked && IsReleased(action)) {
            parent.showUi(false);
            parent.PushState('RadUi_InteractivePlacement');
        }
    }
    // ------------------------------------------------------------------------
    event OnEntityHotkeyHelp(entitytype: String, out hotkeyList: array<SModUiHotkeyHelp>) {
        hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleInteractiveCam', , IK_LControl));
        if (unlocked) {
            hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleInteractivePlacement', , IK_P));
            hotkeyList.PushBack(HotkeyHelp_from('RADUI_EditSetting'));
        }
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectPrev', "RADUI_SelectPrevSetting"));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectNext', "RADUI_SelectNextSetting"));
        super.OnHotkeyHelp(hotkeyList);
    }
    // ------------------------------------------------------------------------
    protected function setupLabels(type: String) {
        var itemName: String;

        itemName = entity.getCaption();
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
        theInput.RegisterListener(this, 'OnCycleAppearance', 'RADUI_CycleAppearance');
        if (unlocked) {
            theInput.RegisterListener(this, 'OnInteractivePlacement', 'RAD_ToggleInteractivePlacement');
            theInput.RegisterListener(this, 'OnEditSetting', 'RADUI_EditSetting');
        } else {
            theInput.RegisterListener(parent, 'OnLockedMode', 'RAD_ToggleInteractivePlacement');
            theInput.RegisterListener(parent, 'OnLockedMode', 'RADUI_EditSetting');
        }
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        theInput.UnregisterListener(this, 'RADUI_BackToTop');
        theInput.UnregisterListener(this, 'RAD_ToggleInteractiveCam');
        theInput.UnregisterListener(this, 'RADUI_CycleAppearance');
        if (unlocked) {
            theInput.UnregisterListener(this, 'RAD_ToggleInteractivePlacement');
            theInput.UnregisterListener(this, 'RADUI_EditSetting');
        } else {
            theInput.UnregisterListener(parent, 'RAD_ToggleInteractivePlacement');
            theInput.UnregisterListener(parent, 'RADUI_EditSetting');
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
abstract state RadUi_EntityManaging in CRadishQuestLayerEntityMode extends RadUi_FilteredListSelect
{
    protected var editStateName: CName;
    protected var unlocked: bool;
    // alias
    protected var itemManager: IRadishUiModeEntityManager;
    protected var selectedEntity: CRadishLayerEntity;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        itemManager = parent.itemManager;
        unlocked = parent.unlocked;

        // update fields if the menu is already open
        parent.view.listMenuRef.setTitle(parent.view.title);
        parent.view.listMenuRef.setStatsLabel(parent.view.statsLabel);

        listProvider = itemManager.getEntityList();
        setSelected(itemManager.getSelected());
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        // "unselect" entity
        selectedEntity.highlight(false);
        super.OnLeaveState(nextStateName);
    }
    // ------------------------------------------------------------------------
    event OnBack(action: SInputAction) {
        parent.backToParent(action);
    }
    // ------------------------------------------------------------------------
    event OnSelected(selectedId: String) {
        if (listProvider.setSelection(selectedId, true)) {
            setSelected(itemManager.select(selectedId));
        }
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnToggleVisibility(action: SInputAction) {
        if (IsPressed(action)) {
            selectedEntity.toggleVisibility();
            itemManager.refreshListProvider();
        }
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnToggleCamFollow(action: SInputAction) {
        if (IsPressed(action)) {
            if (parent.config.isAutoCamOnSelect()) {
                parent.notice(GetLocStringByKeyExt("RADUI_iCamFollowOff"));
            } else {
                parent.notice(GetLocStringByKeyExt("RADUI_iCamFollowOn"));

                if (selectedEntity) {
                    itemManager.switchCamTo(
                        RadUi_createCamSettingsFor(RadUiCam_EntityPreview, selectedEntity.getProxy())
                    );
                }
            }
            parent.config.toggleAutoCamOnSelect();
        }
    }
    // ------------------------------------------------------------------------
    event OnSwitchToEntityCam(action: SInputAction) {
        if (IsPressed(action) && selectedEntity) {
            parent.notice(GetLocStringByKeyExt("RADUI_iCamSwitchedTo") + selectedEntity.getCaption());
            itemManager.switchCamTo(
                RadUi_createCamSettingsFor(RadUiCam_EntityPreview, selectedEntity.getProxy())
            );
        }
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
    event OnInteractivePlacement(action: SInputAction) {
        if (unlocked && IsReleased(action) && selectedEntity) {
            parent.showUi(false);
            parent.PushState('RadUi_InteractivePlacement');
        }
    }
    // ------------------------------------------------------------------------
    event OnAddEntity(action: SInputAction) {
        if (unlocked && IsReleased(action)) {
            setSelected(itemManager.addNew());
            updateView();
        }
    }
    // ------------------------------------------------------------------------
    event OnCloneEntity(action: SInputAction) {
        if (unlocked && IsReleased(action)) {
            setSelected(itemManager.cloneSelected());
            updateView();
            parent.showUi(false);
            parent.PushState('RadUi_InteractivePlacement');
        }
    }
    // ------------------------------------------------------------------------
    event OnDelEntity(action: SInputAction) {
        var msgTitle, msgText: String;

        if (unlocked && IsReleased(action) && selectedEntity) {
            if (parent.confirmPopup) { delete parent.confirmPopup; }

            parent.confirmPopup = new CModUiActionConfirmation in this;
            msgTitle = GetLocStringByKeyExt("RADUI_tEntityConfirmPopup");
            msgText = GetLocStringByKeyExt("RADUI_mEntityDelete") + selectedEntity.getCaption() + "?";

            parent.confirmPopup.open(
                parent.popupCallback, msgTitle, msgText, "deleteEntity");
        }
    }
    // ------------------------------------------------------------------------
    event OnDeleteConfirmed() {
        if (unlocked && !itemManager.deleteSelected()) {
            parent.error(GetLocStringByKeyExt("RADUI_eDeleteFailed"));
        }
        setSelected(itemManager.getSelected());
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnEditEntity(action: SInputAction) {
       // prevent direct jump to first selected entity by checking "released"
       // and checking "pressed" in substate
        if (IsReleased(action) && selectedEntity) {
            parent.PushState(editStateName);
        }
    }
    // ------------------------------------------------------------------------
    event OnCycleAppearance(action: SInputAction) {
        if (IsPressed(action)) {
            selectedEntity.cycleAppearance();
        }
    }
    // ------------------------------------------------------------------------
    event OnRename(action: SInputAction) {
        if (unlocked && !parent.view.listMenuRef.isEditActive() && IsPressed(action) && selectedEntity)
        {
            parent.view.listMenuRef.startInputMode(
                GetLocStringByKeyExt("RADUI_lEntityRename"),
                selectedEntity.getEditableCaption());
        }
    }
    // ------------------------------------------------------------------------
    event OnInputEnd(inputString: String) {
        var newSpecialization, newName: String;

        if (searchFilterInput) {
            super.OnInputEnd(inputString);
        } else {
            if (StrLen(inputString) > 2) {
                // uniquenness check
                if (itemManager.verifyName(inputString)) {
                    // specialization change check (based on name prefix)
                    itemManager.extractSpecialization(inputString, newSpecialization, newName);

                    if (selectedEntity.getSpecialization() != newSpecialization) {
                        if (itemManager.changeSpecialization(newSpecialization, newName)) {
                            setSelected(itemManager.getSelected());

                            itemManager.refreshListProvider(true);
                            listProvider.setSelection(selectedEntity.getIdString(), true);

                            parent.notice(
                                GetLocStringByKeyExt("RADUI_iChangedEntitySpecialization")
                                + " " + selectedEntity.getSpecialization()
                            );
                        } else {
                            parent.error(GetLocStringByKeyExt("RADUI_eEntitySpecializationChangeFailed"));
                        }
                    } else {
                        itemManager.renameSelected(newName);
                        listProvider.setSelection(selectedEntity.getIdString(), true);
                    }
                } else {
                    parent.error(GetLocStringByKeyExt("RADUI_iUniqueLayerEntityName"));
                }
            } else {
                parent.error(GetLocStringByKeyExt("RADUI_iInvalidEntityName"));
            }

            parent.view.listMenuRef.resetEditField();
            updateView();
        }
    }
    // ------------------------------------------------------------------------
    event OnInputCancel() {
        if (searchFilterInput) {
            super.OnInputCancel();
        } else {
            parent.notice(GetLocStringByKeyExt("UI_CanceledEdit"));

            parent.view.listMenuRef.resetEditField();
            updateView();
        }
    }
    // ------------------------------------------------------------------------
    event OnEntityModeChange(action: SInputAction) {
        LogChannel('DEBUG', "OnEntityModeChange " + action.aName);
        if (IsReleased(action)) {
            switch (action.aName) {
                case 'RADUI_ManageAreas':
                case 'RADUI_ManageWaypoints':
                case 'RADUI_ManageScenepoints':
                case 'RADUI_ManageMappins':
                case 'RADUI_ManageActionpoints':
                case 'RADUI_ManageStaticEntities':
                case 'RADUI_ManageInteractiveEntities':
                    parent.backToParent(action);
                    break;
            }
        }
    }
    // ------------------------------------------------------------------------
    event OnEntityHotkeyHelp(entitytype: String, out hotkeyList: array<SModUiHotkeyHelp>) {
        if (unlocked) {
            hotkeyList.PushBack(HotkeyHelp_from('RADUI_AddEntity', "RADUI_Add" + entitytype));
            hotkeyList.PushBack(HotkeyHelp_from('RADUI_DelEntity', "RADUI_Del" + entitytype));
            hotkeyList.PushBack(HotkeyHelp_from('RADUI_CloneEntity', "RADUI_Clone" + entitytype));
            hotkeyList.PushBack(HotkeyHelp_from('RADUI_RenameEntity', "RADUI_Rename" + entitytype));
            hotkeyList.PushBack(HotkeyHelp_from('RADUI_EditEntity', "RADUI_Edit" + entitytype));
            hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleInteractivePlacement', , IK_P));
        } else {
            hotkeyList.PushBack(HotkeyHelp_from('RADUI_EditEntity', "RADUI_ViewSettings" + entitytype));
        }
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ToggleVisibility'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SwitchToEntityCam'));
        hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleInteractiveCam', , IK_LControl));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ToggleCamFollowMode'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectPrev', "RADUI_SelectPrev" + entitytype));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectNext', "RADUI_SelectNext" + entitytype));

        // TODO filter current mode by entitytype
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ManageAreas'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ManageWaypoints'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ManageScenepoints'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ManageMappins'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ManageActionpoints'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ManageStaticEntities'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ManageInteractiveEntities'));

        super.OnHotkeyHelp(hotkeyList);
    }
    // ------------------------------------------------------------------------
    protected function setSelected(entity: CRadishLayerEntity) {
        selectedEntity.highlight(false);

        selectedEntity = entity;
        parent.selectedEntity = entity;

        if (entity && parent.config.isAutoCamOnSelect()) {
            itemManager.switchCamTo(
                RadUi_createCamSettingsFor(RadUiCam_EntityPreview, selectedEntity.getProxy())
            );
        }
        selectedEntity.highlight(true);
    }
    // ------------------------------------------------------------------------
    protected function setupLabels(type: String) {
        var layerName: String;

        layerName = parent.itemManager.getLayerCaption();
        // use parent unlocked as the local one may not be synced!
        if (!parent.unlocked) {
            // indicate readonly by different layername color
            layerName = "<font color=\"#ED8D33\">" + layerName + "</font>";
        }

        parent.view.title = GetLocStringByKeyExt("RADUI_" + type + "OverviewTitle") + " " + layerName;
        parent.view.statsLabel = GetLocStringByKeyExt("RADUI_" + type + "OverviewListStats");
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();

        theInput.RegisterListener(this, 'OnEntityModeChange', 'RADUI_ManageAreas');
        theInput.RegisterListener(this, 'OnEntityModeChange', 'RADUI_ManageWaypoints');
        theInput.RegisterListener(this, 'OnEntityModeChange', 'RADUI_ManageScenepoints');
        theInput.RegisterListener(this, 'OnEntityModeChange', 'RADUI_ManageMappins');
        theInput.RegisterListener(this, 'OnEntityModeChange', 'RADUI_ManageActionpoints');
        theInput.RegisterListener(this, 'OnEntityModeChange', 'RADUI_ManageStaticEntities');
        theInput.RegisterListener(this, 'OnEntityModeChange', 'RADUI_ManageInteractiveEntities');

        theInput.RegisterListener(this, 'OnChangeWorkMode', 'RADUI_BackToTop');
        theInput.RegisterListener(this, 'OnInteractiveCam', 'RAD_ToggleInteractiveCam');
        theInput.RegisterListener(this, 'OnToggleVisibility', 'RADUI_ToggleVisibility');
        theInput.RegisterListener(this, 'OnSwitchToEntityCam', 'RADUI_SwitchToEntityCam');
        theInput.RegisterListener(this, 'OnToggleCamFollow', 'RADUI_ToggleCamFollowMode');
        theInput.RegisterListener(this, 'OnCycleAppearance', 'RADUI_CycleAppearance');
        theInput.RegisterListener(this, 'OnEditEntity', 'RADUI_EditEntity');
        if (unlocked) {
            theInput.RegisterListener(this, 'OnInteractivePlacement', 'RAD_ToggleInteractivePlacement');
            theInput.RegisterListener(this, 'OnAddEntity', 'RADUI_AddEntity');
            theInput.RegisterListener(this, 'OnCloneEntity', 'RADUI_CloneEntity');
            theInput.RegisterListener(this, 'OnDelEntity', 'RADUI_DelEntity');
            theInput.RegisterListener(this, 'OnRename', 'RADUI_RenameEntity');
        } else {
            theInput.RegisterListener(parent, 'OnLockedMode', 'RAD_ToggleInteractivePlacement');
            theInput.RegisterListener(parent, 'OnLockedMode', 'RADUI_AddEntity');
            theInput.RegisterListener(parent, 'OnLockedMode', 'RADUI_CloneEntity');
            theInput.RegisterListener(parent, 'OnLockedMode', 'RADUI_DelEntity');
            theInput.RegisterListener(parent, 'OnLockedMode', 'RADUI_RenameEntity');
        }
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        theInput.UnregisterListener(this, 'RADUI_BackToTop');
        theInput.UnregisterListener(this, 'RAD_ToggleInteractiveCam');
        theInput.UnregisterListener(this, 'RADUI_ToggleVisibility');
        theInput.UnregisterListener(this, 'RADUI_SwitchToEntityCam');
        theInput.UnregisterListener(this, 'RADUI_ToggleCamFollowMode');
        theInput.UnregisterListener(this, 'RADUI_CycleAppearance');
        theInput.UnregisterListener(this, 'RADUI_EditEntity');

        theInput.UnregisterListener(this, 'RADUI_ManageAreas');
        theInput.UnregisterListener(this, 'RADUI_ManageWaypoints');
        theInput.UnregisterListener(this, 'RADUI_ManageScenepoints');
        theInput.UnregisterListener(this, 'RADUI_ManageMappins');
        theInput.UnregisterListener(this, 'RADUI_ManageActionpoints');
        theInput.UnregisterListener(this, 'RADUI_ManageStaticEntities');
        theInput.UnregisterListener(this, 'RADUI_ManageInteractiveEntities');

        if (unlocked) {
            theInput.UnregisterListener(this, 'RAD_ToggleInteractivePlacement');
            theInput.UnregisterListener(this, 'RADUI_AddEntity');
            theInput.UnregisterListener(this, 'RADUI_CloneEntity');
            theInput.UnregisterListener(this, 'RADUI_DelEntity');
            theInput.UnregisterListener(this, 'RADUI_RenameEntity');
        } else {
            theInput.UnregisterListener(parent, 'RAD_ToggleInteractivePlacement');
            theInput.UnregisterListener(parent, 'RADUI_AddEntity');
            theInput.UnregisterListener(parent, 'RADUI_CloneEntity');
            theInput.UnregisterListener(parent, 'RADUI_DelEntity');
            theInput.UnregisterListener(parent, 'RADUI_RenameEntity');
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// Top level management of entities:
//  - Adding/Deleting/Renaming
//  - selecting current layerentity for editing and previewing
//
abstract statemachine class CRadishQuestLayerEntityMode extends CRadishListViewWorkMode {
    // ------------------------------------------------------------------------
    protected var itemManager: IRadishUiModeEntityManager;
    protected var selectedEntity: CRadishLayerEntity;
    protected var entityEditor: IRadishUiModeEntityEditor;
    protected var unlocked: bool;
    // ------------------------------------------------------------------------
    public function init(itemManager: IRadishUiModeManager, config: CRadishQuestConfigManager)
    {
        super.init(itemManager, config);
        this.itemManager = (IRadishUiModeEntityManager)itemManager;
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
    protected function getListProvider(listId: String) : CGenericListSettingList {
        return ((CRadishQuestLayerMode)parentCallback).getListProvider(listId);
    }
    // ------------------------------------------------------------------------
    event OnLockedMode() {
        this.error(GetLocStringByKeyExt("RADUI_eReadOnlyMode"));
    }
    // ------------------------------------------------------------------------
    event OnDeleteConfirmed() {}
    // ------------------------------------------------------------------------
    event OnEntityHotkeyHelp(entitytype: String, out hotkeyList: array<SModUiHotkeyHelp>) { }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
