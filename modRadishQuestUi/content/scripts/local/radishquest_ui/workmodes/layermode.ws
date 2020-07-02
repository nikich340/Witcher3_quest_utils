// ----------------------------------------------------------------------------
state RadUi_LayerEditing in CRadishQuestLayerMode extends RadUi_ListSelect {
    private var layerEditor: CRadishQuestLayerEditor;
    private var layer: CRadishQuestLayer;
    private var encodedLayer: CEncodedRadishQuestLayer;
    private var unlocked: bool;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        var layerName: String;
        var null: CName;

        layerEditor = new CRadishQuestLayerEditor in this;
        layer = parent.layerManager.getSelected();
        encodedLayer = (CEncodedRadishQuestLayer)layer;
        layerEditor.init(parent.log, layer);

        layerName = layer.getCaption();
        if (encodedLayer) {
            // indicate readonly by different layername color
            layerName = " <font color=\"#ED8D33\">" + layerName + "</font>";
        } else {
            unlocked = true;
        }

        parent.view.title = GetLocStringByKeyExt("RADUI_LayerEditTitle") + layerName;
        parent.view.statsLabel = GetLocStringByKeyExt("RADUI_LayerEditListTitle");
        // update fields if the menu is already open
        parent.view.listMenuRef.setTitle(parent.view.title);
        parent.view.listMenuRef.setStatsLabel(parent.view.statsLabel);

        listProvider = layerEditor.getCategoryList();

        super.OnEnterState(prevStateName);

        if (parent.jumpToSubMode != null) {
            onQuickForwardToMode(SInputAction(parent.jumpToSubMode, 1.0, 0.0));
        }
    }
    // ------------------------------------------------------------------------
    private function onQuickForwardToMode(action: SInputAction) {
        var null: CName;

        switch (parent.jumpToSubMode) {
            case 'RADUI_ManageAreas':               OnEditAreas(action); break;
            case 'RADUI_ManageWaypoints':           OnEditWaypoints(action); break;
            case 'RADUI_ManageScenepoints':         OnEditScenepoints(action); break;
            case 'RADUI_ManageMappins':             OnEditMappins(action); break;
            case 'RADUI_ManageActionpoints':        OnEditActionpoints(action); break;
            case 'RADUI_ManageStaticEntities':      OnEditStaticEntities(action); break;
            case 'RADUI_ManageInteractiveEntities': OnEditInteractiveEntities(action); break;
        }
        parent.jumpToSubMode = null;
    }
    // ------------------------------------------------------------------------
    event OnSelected(selectedId: String) {
        listProvider.setSelection(selectedId);
        //layerEditor.setSelection(selectedId);
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnBack(action: SInputAction) {
        parent.backToPreviousState(action);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        parent.OnHotkeyHelp(hotkeyList);

        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ManageCategory'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ManageAreas'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ManageWaypoints'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ManageScenepoints'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ManageMappins'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ManageActionpoints'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ManageStaticEntities'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ManageInteractiveEntities'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectPrev', "RADUI_SelectPrevLayerCat"));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectNext', "RADUI_SelectNextLayerCat"));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ToggleVisibility', "RADUI_ToggleLayerCategoryVisibility"));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_PreviewLayerActionpointJobtrees'));
        hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleInteractiveCam'));
        hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleInteractiveTime'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ToggleCamFollowMode'));
    }
    // ------------------------------------------------------------------------
    event OnPreviewActionpoints(action: SInputAction) {
        var msg: String;

        if (unlocked && IsPressed(action) && !parent.view.listMenuRef.isEditActive()) {

            parent.theVisualizer.resetAnimated();
            if (parent.theVisualizer.selectForAnimation(
                "actionpoint", SRadUiLayerEntityId(layer.getId(), "*")) > 0)
            {
                if (parent.theVisualizer.startAnimations()) {
                    msg = GetLocStringByKeyExt("RADUI_iActionpointsPreview");
                } else {
                    msg = GetLocStringByKeyExt("RADUI_eActionpointPreview");
                }
            } else {
                msg = GetLocStringByKeyExt("RADUI_iNoActionpointsToPreview");
            }
            parent.notice(msg + " " + layer.getCaption());
        }
    }
    // ------------------------------------------------------------------------
    private function initSubmode(
        modeManager: CRadishQuestLayerEntityManager, submode: CRadishQuestLayerEntityMode)
    {
        modeManager.init(parent.log, layer, parent.layerManager.getCam());
        parent.currentSubMode = submode;

        submode.setParent(parent);
        // unlock BEFORE initializing (otherwise captions are generated for locked mode)
        if (unlocked) {
            submode.unlockEditing();
        }
        submode.init(modeManager, parent.config);
        submode.activate();
    }
    // ------------------------------------------------------------------------
    event OnEditAreas(action: SInputAction) {
        if (IsPressed(action)) {
            parent.PushState('RadUi_WaitForSubmodeEnd');

            initSubmode(
                new CRadishQuestLayerAreaManager in this,
                new CRadishQuestLayerAreaMode in this
            );
        }
    }
    // ------------------------------------------------------------------------
    event OnEditWaypoints(action: SInputAction) {
        if (IsPressed(action)) {
            parent.PushState('RadUi_WaitForSubmodeEnd');
            initSubmode(
                new CRadishQuestLayerWaypointManager in this,
                new CRadishQuestLayerWaypointMode in this
            );
        }
    }
    // ------------------------------------------------------------------------
    event OnEditScenepoints(action: SInputAction) {
        if (IsPressed(action)) {
            parent.PushState('RadUi_WaitForSubmodeEnd');
            initSubmode(
                new CRadishQuestLayerScenepointManager in this,
                new CRadishQuestLayerScenepointMode in this
            );
        }
    }
    // ------------------------------------------------------------------------
    event OnEditMappins(action: SInputAction) {
        if (IsPressed(action)) {
            parent.PushState('RadUi_WaitForSubmodeEnd');
            initSubmode(
                new CRadishQuestLayerMappinManager in this,
                new CRadishQuestLayerMappinMode in this
            );
        }
    }
    // ------------------------------------------------------------------------
    event OnEditActionpoints(action: SInputAction) {
        var manager: CRadishQuestLayerActionpointManager;
        var mode: CRadishQuestLayerActionpointMode;

        if (IsPressed(action)) {
            parent.PushState('RadUi_WaitForSubmodeEnd');
            manager = new CRadishQuestLayerActionpointManager in this;
            // inject global (caching) jobtree manager to prevent reloading on
            // every mode entering
            manager.setJobTreeProvider(parent.layerManager.getJobTreeProvider());

            mode = new CRadishQuestLayerActionpointMode in this;
            mode.setVisualizer(parent.theVisualizer);

            initSubmode(manager, mode);
        }
    }
    // ------------------------------------------------------------------------
    event OnEditStaticEntities(action: SInputAction) {
        if (IsPressed(action)) {
            parent.PushState('RadUi_WaitForSubmodeEnd');
            initSubmode(
                new CRadishQuestLayerStaticEntityManager in this,
                new CRadishQuestLayerStaticEntityMode in this
            );
        }
    }
    // ------------------------------------------------------------------------
    event OnEditInteractiveEntities(action: SInputAction) {
        if (IsPressed(action)) {
            parent.PushState('RadUi_WaitForSubmodeEnd');
            initSubmode(
                new CRadishQuestLayerInteractiveEntityManager in this,
                new CRadishQuestLayerInteractiveEntityMode in this
            );
        }
    }
    // ------------------------------------------------------------------------
    event OnEditCategory(action: SInputAction) {
        var catId: String;
        catId = listProvider.getSelectedId();
        switch (catId) {
            case "area":        return OnEditAreas(action);
            case "waypoint":    return OnEditWaypoints(action);
            case "scenepoint":  return OnEditScenepoints(action);
            case "mappin":      return OnEditMappins(action);
            case "actionpoint": return OnEditActionpoints(action);
            case "static":      return OnEditStaticEntities(action);
            case "interactive": return OnEditInteractiveEntities(action);

            default:
                parent.error("unknown category " + catId);
        }
    }
    // ------------------------------------------------------------------------
    event OnToggleVisibility(action: SInputAction) {
        if (IsPressed(action)) {
            layerEditor.toggleVisibility(listProvider.getSelectedId());
            updateView();
        }
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();
        theInput.RegisterListener(parent, 'OnInteractiveCam', 'RAD_ToggleInteractiveCam');
        theInput.RegisterListener(parent, 'OnInteractiveTime', 'RAD_ToggleInteractiveTime');
        theInput.RegisterListener(parent, 'OnToggleCamFollow', 'RADUI_ToggleCamFollowMode');
        theInput.RegisterListener(this, 'OnEditAreas', 'RADUI_ManageAreas');
        theInput.RegisterListener(this, 'OnEditWaypoints', 'RADUI_ManageWaypoints');
        theInput.RegisterListener(this, 'OnEditScenepoints', 'RADUI_ManageScenepoints');
        theInput.RegisterListener(this, 'OnEditMappins', 'RADUI_ManageMappins');
        theInput.RegisterListener(this, 'OnEditActionpoints', 'RADUI_ManageActionpoints');
        theInput.RegisterListener(this, 'OnEditStaticEntities', 'RADUI_ManageStaticEntities');
        theInput.RegisterListener(this, 'OnEditInteractiveEntities', 'RADUI_ManageInteractiveEntities');
        theInput.RegisterListener(this, 'OnEditCategory', 'RADUI_ManageCategory');
        theInput.RegisterListener(this, 'OnToggleVisibility', 'RADUI_ToggleVisibility');
        theInput.RegisterListener(this, 'OnPreviewActionpoints', 'RADUI_PreviewLayerActionpointJobtrees');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        theInput.UnregisterListener(parent, 'RAD_ToggleInteractiveCam');
        theInput.UnregisterListener(parent, 'RAD_ToggleInteractiveTime');
        theInput.UnregisterListener(parent, 'RADUI_ToggleCamFollowMode');
        theInput.UnregisterListener(this, 'RADUI_ManageAreas');
        theInput.UnregisterListener(this, 'RADUI_ManageWaypoints');
        theInput.UnregisterListener(this, 'RADUI_ManageScenepoints');
        theInput.UnregisterListener(this, 'RADUI_ManageMappins');
        theInput.UnregisterListener(this, 'RADUI_ManageActionpoints');
        theInput.UnregisterListener(this, 'RADUI_ManageStaticEntities');
        theInput.UnregisterListener(this, 'RADUI_ManageInteractiveEntities');
        theInput.UnregisterListener(this, 'RADUI_ManageCategory');
        theInput.UnregisterListener(this, 'RADUI_ToggleVisibility');
        theInput.UnregisterListener(this, 'RADUI_PreviewLayerActionpointJobtrees');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
state RadUi_LayerManaging in CRadishQuestLayerMode extends RadUi_FilteredListSelect {
    // alias
    private var layerManager: CRadishQuestLayerManager;
    private var selectedLayer: CRadishQuestLayer;
    private var selectedEncodedLayer: CEncodedRadishQuestLayer;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        var null: CName;

        layerManager = parent.layerManager;
        setSelected(layerManager.getSelected());

        parent.view.title = parent.getName();
        parent.view.statsLabel = GetLocStringByKeyExt("RADUI_LayerOverviewListTitle");
        // update fields if the menu is already open
        parent.view.listMenuRef.setTitle(parent.view.title);
        parent.view.listMenuRef.setStatsLabel(parent.view.statsLabel);

        listProvider = layerManager.getLayerList();

        super.OnEnterState(prevStateName);

        if (parent.jumpToSubMode != null) {
            parent.PushState('RadUi_LayerEditing');
        }
    }
    // ------------------------------------------------------------------------
    event OnBack(action: SInputAction) {
        parent.backToParent(action);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        parent.OnHotkeyHelp(hotkeyList);

        hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleInteractiveCam'));
        hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleInteractiveTime'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ToggleCamFollowMode'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_RenameLayer'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_AddLayer'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_DelLayer'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectPrev', "RADUI_PrevLayer"));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectNext', "RADUI_NextLayer"));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ToggleShadowedLayerVisibility'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_CloneLayer'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_UnshadowLayer'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ToggleVisibility'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ToggleW2lVisibility'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ScanForW2lEntities'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_LogDefinition'));
    }
    // ------------------------------------------------------------------------
    event OnSelected(selectedId: String) {
        if (listProvider.setSelection(selectedId, true)) {
            // selection was a layer (and not category)
            setSelected(layerManager.selectLayer(selectedId));
        }
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnQuitRequest(action: SInputAction) {
        if (IsPressed(action)) {
            ((CRadUiRootModeCallback)parent.parentCallback).callback.quitRequest();
        }
    }
    // ------------------------------------------------------------------------
    event OnEditLayer(action: SInputAction) {
       // prevent direct jump to first selected category by checking "released"
       // and checking "pressed" in substate
        if (IsReleased(action)) {
            parent.PushState('RadUi_LayerEditing');
        }
    }
    // ------------------------------------------------------------------------
    event OnAddLayer(action: SInputAction) {
        if (IsReleased(action)) {
            setSelected(layerManager.addNew());
            updateView();
        }
    }
    // ------------------------------------------------------------------------
    event OnDelLayer(action: SInputAction) {
        var msgTitle, msgText: String;

        if (IsReleased(action) && selectedLayer) {
            if (selectedEncodedLayer) {
                parent.error(GetLocStringByKeyExt("RADUI_eEncLayerDelete"));
            } else {
                if (parent.confirmPopup) { delete parent.confirmPopup; }

                parent.confirmPopup = new CModUiActionConfirmation in this;
                msgTitle = GetLocStringByKeyExt("RADUI_tLayerOverviewConfirmPopup");
                msgText = GetLocStringByKeyExt("RADUI_mLayerDelete") + "\"" + selectedLayer.getCaption() + "\"?";

                parent.confirmPopup.open(
                    parent.popupCallback, msgTitle, msgText, "deleteLayer");
            }
        }
    }
    // ------------------------------------------------------------------------
    event OnDeleteConfirmed() {
        if (!layerManager.deleteSelected()) {
            parent.error(GetLocStringByKeyExt("RADUI_eDeleteFailed"));
        }
        setSelected(layerManager.getSelected());
        updateView();
        parent.showUi(true);
    }
    // ------------------------------------------------------------------------
    event OnClone(action: SInputAction) {
        var msgTitle, msgText: String;

        if (IsReleased(action) && selectedLayer) {
            if (selectedEncodedLayer && layerManager.existsEditableLayer(selectedEncodedLayer.getId())) {
                if (parent.confirmPopup) { delete parent.confirmPopup; }

                parent.confirmPopup = new CModUiActionConfirmation in this;
                msgTitle = GetLocStringByKeyExt("RADUI_tLayerOverviewConfirmPopup");
                msgText = GetLocStringByKeyExt("RADUI_mLayerOverwrite") + "\"" + selectedEncodedLayer.getCaption() + "\"?";

                parent.confirmPopup.open(
                    parent.popupCallback, msgTitle, msgText, "cloneLayer");
            } else {
                OnCloneConfirmed();
            }
        }
    }
    // ------------------------------------------------------------------------
    event OnCloneConfirmed() {
        var msgId: String;

        if (selectedEncodedLayer) {
            msgId = GetLocStringByKeyExt("RADUI_iClonedEncodedLayer");
        } else {
            msgId = GetLocStringByKeyExt("RADUI_iClonedLayer");
        }
        setSelected(layerManager.cloneSelected());
        parent.notice(msgId);

        updateView();
        parent.showUi(true);
    }
    // ------------------------------------------------------------------------
    event OnUnShadowLayer(action: SInputAction) {
        if (IsPressed(action)) {
            if (selectedEncodedLayer) {
                if (layerManager.existsEditableLayer(selectedEncodedLayer.getId())) {
                    parent.error(GetLocStringByKeyExt("RADUI_eUnshadowedIdConflict"));
                } else {
                    layerManager.unshadowEncodedLayer(selectedEncodedLayer.getId());
                    updateView();
                }
            }
        }
    }
    // ------------------------------------------------------------------------
    event OnToggleShadowedVisibility(action: SInputAction) {
        if (IsPressed(action)) {
            if (layerManager.toggleShadowedVisibility()) {
                parent.notice(GetLocStringByKeyExt("RADUI_iShadowedLayerVisible"));
            } else {
                parent.notice(GetLocStringByKeyExt("RADUI_iShadowedLayerHidden"));
            }
            updateView();
        }
    }
    // ------------------------------------------------------------------------
    event OnToggleVisibility(action: SInputAction) {
        if (IsPressed(action)) {
            selectedLayer.toggleVisibility();
            layerManager.refreshListProvider();
            updateView();
        }
    }
    // ------------------------------------------------------------------------
    event OnToggleEncodedLayerVisibility(action: SInputAction) {
        if (IsPressed(action)) {
            if (selectedEncodedLayer) {
                selectedEncodedLayer.toggleEncodedVisibility();
                layerManager.refreshListProvider();
                updateView();
            } else {
                parent.error(GetLocStringByKeyExt("RADUI_eOnlyEncoded"));
            }
        }
    }
    // ------------------------------------------------------------------------
    event OnScanForEntities(action: SInputAction) {
        //TODO automatically as a deferred action (1s delay)?
        if (IsPressed(action)) {
            if (selectedEncodedLayer) {
                if (selectedEncodedLayer.isEncodedVisible() && !selectedEncodedLayer.isScanned()) {
                    if (selectedEncodedLayer.scanForEntities() < 1) {
                        parent.notice(GetLocStringByKeyExt("RADUI_iNoEncodedEntities"));
                    }
                    layerManager.refreshListProvider();
                    updateView();
                }
            } else {
                parent.error(GetLocStringByKeyExt("RADUI_eOnlyEncoded"));
            }
        }
    }
    // ------------------------------------------------------------------------
    event OnRename(action: SInputAction) {
        if (!selectedEncodedLayer && !parent.view.listMenuRef.isEditActive() && IsPressed(action)) {
            parent.view.listMenuRef.startInputMode(
                GetLocStringByKeyExt("RADUI_lLayerRename"),
                layerManager.getSelected().getCaption());
        }
    }
    // ------------------------------------------------------------------------
    event OnInputEnd(inputString: String) {
        var newId: SRadUiLayerId;
        var selectedLayer: CRadishQuestLayer;

        if (searchFilterInput) {
            super.OnInputEnd(inputString);
        } else {
            if (StrLen(inputString) > 2) {
                selectedLayer = layerManager.getSelected();
                newId = selectedLayer.getId();
                newId.layerName = inputString;

                //TODO activate shadowing? prevent shadowing?

                if (layerManager.verifyLayerId(newId)) {
                    selectedLayer.setId(newId);
                    layerManager.refreshListProvider();
                    listProvider.setSelection(selectedLayer.getIdString(), true);
                } else {
                    parent.error(GetLocStringByKeyExt("RADUI_iUniqueLayerName"));
                }
            } else {
                parent.error(GetLocStringByKeyExt("RADUI_iInvalidLayerName"));
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
    protected function setSelected(layer: CRadishQuestLayer) {
        selectedLayer = layer;
        selectedEncodedLayer = (CEncodedRadishQuestLayer)layer;
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();

        theInput.RegisterListener(this, 'OnQuitRequest', 'RADUI_Quit');
        theInput.RegisterListener(this, 'OnAddLayer', 'RADUI_AddLayer');
        theInput.RegisterListener(this, 'OnDelLayer', 'RADUI_DelLayer');
        theInput.RegisterListener(this, 'OnEditLayer', 'RADUI_EditLayer');
        theInput.RegisterListener(this, 'OnClone', 'RADUI_CloneLayer');
        theInput.RegisterListener(this, 'OnUnShadowLayer', 'RADUI_UnshadowLayer');
        theInput.RegisterListener(this, 'OnToggleVisibility', 'RADUI_ToggleVisibility');
        theInput.RegisterListener(this, 'OnToggleEncodedLayerVisibility', 'RADUI_ToggleW2lVisibility');
        theInput.RegisterListener(this, 'OnScanForEntities', 'RADUI_ScanForW2lEntities');
        theInput.RegisterListener(this, 'OnToggleShadowedVisibility', 'RADUI_ToggleShadowedLayerVisibility');

        theInput.RegisterListener(this, 'OnRename', 'RADUI_RenameLayer');
        theInput.RegisterListener(parent, 'OnInteractiveCam', 'RAD_ToggleInteractiveCam');
        theInput.RegisterListener(parent, 'OnInteractiveTime', 'RAD_ToggleInteractiveTime');
        theInput.RegisterListener(parent, 'OnToggleCamFollow', 'RADUI_ToggleCamFollowMode');
        theInput.RegisterListener(parent, 'OnLogDefinition', 'RADUI_LogDefinition');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        theInput.UnregisterListener(this, 'RADUI_Quit');
        theInput.UnregisterListener(this, 'RADUI_AddLayer');
        theInput.UnregisterListener(this, 'RADUI_DelLayer');
        theInput.UnregisterListener(this, 'RADUI_EditLayer');
        theInput.UnregisterListener(this, 'RADUI_CloneLayer');
        theInput.UnregisterListener(this, 'RADUI_ToggleVisibility');
        theInput.UnregisterListener(this, 'RADUI_ToggleW2lVisibility');
        theInput.UnregisterListener(this, 'RADUI_ScanForW2lEntities');
        theInput.UnregisterListener(this, 'RADUI_UnshadowLayer');
        theInput.UnregisterListener(this, 'RADUI_ToggleShadowedLayerVisibility');

        theInput.UnregisterListener(this, 'RADUI_RenameLayer');
        theInput.UnregisterListener(parent, 'RAD_ToggleInteractiveCam');
        theInput.UnregisterListener(parent, 'RAD_ToggleInteractiveTime');
        theInput.UnregisterListener(parent, 'RADUI_ToggleCamFollowMode');
        theInput.UnregisterListener(parent, 'RADUI_LogDefinition');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// Top level management of Layers:
//  - Adding/Deleting/Renaming
//  - selecting current layer for editing and previewing
//  - storing all settings in log
//
statemachine class CRadishQuestLayerMode extends CRadishListViewWorkMode {
    default workMode = 'RADUI_ModeLayers';
    default workContext = 'MOD_RadishUi_ModeLayers';
    default generalHelpKey = "RADUI_LayersGeneralHelp";
    default defaultState = 'RadUi_LayerManaging';
    // ------------------------------------------------------------------------
    protected var theVisualizer: CRadishProxyVisualizer;
    protected var layerManager: CRadishQuestLayerManager;
    protected var currentSubMode: CRadishWorkMode;
    // ------------------------------------------------------------------------
    protected var jumpToSubMode: CName;
    // ------------------------------------------------------------------------
    public function init(layerManager: IRadishUiModeManager, config: CRadishQuestConfigManager)
    {
        super.init(layerManager, config);
        this.layerManager = (CRadishQuestLayerManager)layerManager;
    }
    // ------------------------------------------------------------------------
    public function getListProvider(listId: String) : CGenericListSettingList {
        return layerManager.getListProvider(listId);
    }
    // ------------------------------------------------------------------------
    public function setVisualizer(visualizer: CRadishProxyVisualizer) {
        this.theVisualizer = visualizer;
    }
    // ------------------------------------------------------------------------
    public function deactivate() {
        // make sure sub state is left properly, too
        if (currentSubMode) {
            currentSubMode.deactivate();
            delete currentSubMode;
        }
        super.deactivate();
    }
    // ------------------------------------------------------------------------
    public function onBackFromChild(action: SInputAction) {
        var null: CName;

        jumpToSubMode = null;

        if (currentSubMode) {
            currentSubMode.deactivate();
            delete currentSubMode;
            switch (action.aName) {
                case 'RADUI_BackToTop':
                    PopState(true);
                    PushState(defaultState);
                    break;
                // quick jump between modes
                case 'RADUI_ManageAreas':
                case 'RADUI_ManageWaypoints':
                case 'RADUI_ManageScenepoints':
                case 'RADUI_ManageMappins':
                case 'RADUI_ManageActionpoints':
                case 'RADUI_ManageStaticEntities':
                case 'RADUI_ManageInteractiveEntities':
                    jumpToSubMode = action.aName;
                    PopState(true);
                    PushState(defaultState);
                    break;
                default:
                    // retrigger last state enter to reactivate everything
                    PopState();
            }

        }
    }
    // ------------------------------------------------------------------------
    public function getGeneralHelp() : String {
        if (currentSubMode) {
            return currentSubMode.getGeneralHelp();
        } else {
            return super.getGeneralHelp();
        }
    }
    // ------------------------------------------------------------------------
    public function getId() : CName {
        if (currentSubMode) {
            return currentSubMode.getId();
        } else {
            return super.getId();
        }
    }
    // ------------------------------------------------------------------------
    public function getName() : String {
        if (currentSubMode) {
            return currentSubMode.getName();
        } else {
            return super.getName();
        }
    }

    // ------------------------------------------------------------------------
    public function getStateName() : String {
        if (currentSubMode) {
            return currentSubMode.getStateName();
        } else {
            return super.getStateName();
        }
    }
    // ------------------------------------------------------------------------
    event OnLogDefinition(action: SInputAction) {
        if (IsPressed(action)) {
            layerManager.logDefinition();
            notice(GetLocStringByKeyExt("RADUI_iLayerDefinitionLogged"));
        }
    }
    // ------------------------------------------------------------------------
    event OnToggleCamFollow(action: SInputAction) {
        LogChannel('OnToggleCamFollow', "pressed");
        if (IsPressed(action)) {
            if (config.isAutoCamOnSelect()) {
                notice(GetLocStringByKeyExt("RADUI_iCamFollowOff"));
            } else {
                notice(GetLocStringByKeyExt("RADUI_iCamFollowOn"));
            }
            config.toggleAutoCamOnSelect();
        }
    }
    // ------------------------------------------------------------------------
    event OnInteractiveCam(action: SInputAction) {
        if (IsReleased(action)) {
            showUi(false);
            PushState('RadUi_InteractiveCamera');
        }
    }
    // ------------------------------------------------------------------------
    event OnInteractiveTime(action: SInputAction) {
        if (IsReleased(action)) {
            PushState('RadUi_InteractiveTime');
        }
    }
    // ------------------------------------------------------------------------
    event OnDeleteConfirmed() {}
    event OnCloneConfirmed() {}
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        if (currentSubMode) {
            currentSubMode.OnHotkeyHelp(hotkeyList);
        } else {
            super.OnHotkeyHelp(hotkeyList);
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
