// ----------------------------------------------------------------------------
state RadUi_InteractiveCamera in CRadishNavMeshMode extends RadUi_BaseInteractiveCamera
{
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        if (parent.config.isAutoCamOnSelect()) {
            parent.config.setAutoCamOnSelect(false);
            parent.notice(
                GetLocStringByKeyExt("RAD_iCamInteractive") + " " +
                GetLocStringByKeyExt("RADUI_iCamFollowOff")
            );
        } else {
            parent.notice(GetLocStringByKeyExt("RAD_iCamInteractive"));
        }
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        // interactive cam MUST be stopped before changing to static cam!
        theCam.stopInteractiveMode();

        // reactivate the static cam *AFTER* destroying the interactive one
        parent.navMeshManager.switchCamTo(theCam.getActiveSettings());

        super.OnLeaveState(nextStateName);
    }
    // ------------------------------------------------------------------------
    protected function createCam() : CRadishInteractiveCamera {
        return createAndSetupInteractiveCam(
            parent.config, parent.navMeshManager.getCamPlacement(), parent.navMeshManager.getCamTracker());
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
state RadUi_InteractiveVertexPlacement in CRadishNavMeshMode
    extends RadUi_BaseInteractivePlacement {
    // ------------------------------------------------------------------------
    default workContext = 'MOD_RadishUi_NM_ModeVertexPlacement';
    default isGroundSnapable = true;
    default snapToGround = false;
    default isUpDownMoveable = true;

    default isRotatableYaw = false;
    default isRotatablePitch = false;
    default isRotatableRoll = false;
    // ------------------------------------------------------------------------
    private var conf: CRadishQuestConfigManager;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        var configData: CRadishQuestConfigData;

        configData = parent.config.getConfig();
        // slowdown movement for vertex placement
        configData.config.placement.slow.stepMove *= 0.5;
        configData.config.placement.normal.stepMove *= 0.5;
        configData.config.placement.fast.stepMove *= 0.5;

        conf = new CRadishQuestConfigManager in this;
        conf.init(parent.log, configData);

        selectedElement = parent.editor.getSelectedVertex();
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnManageVertices(action: SInputAction) {
        var isUpdated: bool;
        var vertexCount: int;

        if (IsPressed(action)) {
            theController.stopInteractiveMode();
            vertexCount = parent.selectedNavMesh.getVertexCount();
            switch (action.aName) {
                case 'RADUI_AddVertex':
                    if (vertexCount < 250) {
                        isUpdated = parent.editor.addVertex();
                    } else {
                        parent.error(GetLocStringByKeyExt("RADUI_eMaxNavMeshVertices") + " " + 250);
                    }
                    break;

                case 'RADUI_DeleteVertex':
                    if (vertexCount > 4) {
                        isUpdated = parent.editor.deleteVertex();
                    } else {
                        parent.error(GetLocStringByKeyExt("RADUI_eMinNavMeshVertices") + 4);
                    }
                    break;
            }
            if (isUpdated) {
                parent.selectedNavMesh.refreshRepresentation();
            }
            // restart to readjust the placement settings
            theController.startInteractiveMode(selectedElement);
        }
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_AddVertex'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_DeleteVertex'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ToggleVertexTypeIterator'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_CycleTriangleEdges'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ToggleEdgeType'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SwitchToNavMeshVertexCam'));
        super.OnHotkeyHelp(hotkeyList);
    }
    // ------------------------------------------------------------------------
    protected function createInteractivePlacement() : CRadishInteractivePlacement {
        var camPlacement: SRadishPlacement;

        camPlacement = parent.navMeshManager.getCamPlacement();

        return createAndSetupInteractivePlacement(conf, camPlacement.rot.Yaw);
    }
    // ------------------------------------------------------------------------
    event OnCycleSelection(action: SInputAction) {
        if (IsPressed(action)) {
            theController.stopInteractiveMode();
            if (action.aName == 'RADUI_SelectPrev') {
                parent.editor.selectPreviousVertex();
            } else {
                parent.editor.selectNextVertex();
            }
            // restart to readjust the placement settings
            theController.startInteractiveMode(selectedElement);
        }
    }
    // ------------------------------------------------------------------------
    event OnCycleEdges(action: SInputAction) {
        if (IsReleased(action)) {
            parent.editor.cycleTriangleEdge();
        }
    }
    // ------------------------------------------------------------------------
    event OnToggleEdgeType(action: SInputAction) {
        var msgKey: String;

        if (IsReleased(action)) {
            switch (parent.editor.toggleEdgeType()) {
                case 1: msgKey = "RADUI_iEdgeToNormalBorder"; break;
                case 2: msgKey = "RADUI_iEdgeToPhantomBorder"; break;
                default: return true;
            }
            parent.notice(GetLocStringByKeyExt(msgKey));
        }
    }
    // ------------------------------------------------------------------------
    event OnToggleVertexIterator(action: SInputAction) {
        var msgKey: String;

        if (IsPressed(action)) {
            theController.stopInteractiveMode();
            parent.editor.toggleVertexTypeIteration();
            // restart to readjust the placement settings
            theController.startInteractiveMode(selectedElement);

            if (parent.editor.isInnerVertexteratorActive()) {
                msgKey = "RADUI_iInnerVertexIteratorActive";
            } else {
                msgKey = "RADUI_iBorderVertexIteratorActive";
            }
            parent.notice(GetLocStringByKeyExt(msgKey));
        }
    }
    // ------------------------------------------------------------------------
    event OnSwitchToSelectedVertex(action: SInputAction) {
        if (IsPressed(action) && parent.editor.isVertexSelected()) {
            parent.navMeshManager.switchCamTo(
                RadUi_createCamSettingsFor(RadUiCam_EntityPreview,
                    parent.editor.getSelectedVertex().getProxy())
            );
        }
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();
        theInput.RegisterListener(this, 'OnManageVertices', 'RADUI_AddVertex');
        theInput.RegisterListener(this, 'OnManageVertices', 'RADUI_DeleteVertex');
        theInput.RegisterListener(this, 'OnToggleVertexIterator', 'RADUI_ToggleVertexTypeIterator');
        theInput.RegisterListener(this, 'OnCycleEdges', 'RADUI_CycleTriangleEdges');
        theInput.RegisterListener(this, 'OnToggleEdgeType', 'RADUI_ToggleEdgeType');
        theInput.RegisterListener(this, 'OnSwitchToSelectedVertex', 'RADUI_SwitchToNavMeshVertexCam');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        theInput.UnregisterListener(this, 'RADUI_AddVertex');
        theInput.UnregisterListener(this, 'RADUI_DeleteVertex');
        theInput.UnregisterListener(this, 'RADUI_ToggleVertexTypeIterator');
        theInput.UnregisterListener(this, 'RADUI_CycleTriangleEdges');
        theInput.UnregisterListener(this, 'RADUI_ToggleEdgeType');
        theInput.UnregisterListener(this, 'RADUI_SwitchToNavMeshVertexCam');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
state RadUi_InteractivePlacement in CRadishNavMeshMode
    extends RadUi_BaseInteractivePlacement
{
    default snapToGround = false;

    default isRotatableYaw = false;
    default isRotatablePitch = false;
    default isRotatableRoll = false;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        selectedElement = parent.selectedNavMesh;
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    protected function createInteractivePlacement() : CRadishInteractivePlacement {
        var camPlacement: SRadishPlacement;

        camPlacement = parent.navMeshManager.getCamPlacement();

        return createAndSetupInteractivePlacement(parent.config, camPlacement.rot.Yaw);
    }
    // ------------------------------------------------------------------------
    event OnCycleSelection(action: SInputAction) {
        var selectedNavMesh: CRadishNavMesh;

        if (IsPressed(action)) {
            parent.selectedNavMesh.highlight(false);

            if (action.aName == 'RADUI_SelectPrev') {
                selectedNavMesh = parent.navMeshManager.selectPrevious();
            } else {
                selectedNavMesh = parent.navMeshManager.selectNext();
            }
            selectedElement = selectedNavMesh;
            parent.selectedNavMesh = selectedNavMesh;

            // restart interactive mode for the new asset
            theController.stopInteractiveMode();
            theController.startInteractiveMode(selectedElement);

            parent.notice(GetLocStringByKeyExt("RADUI_iSelectedNavMeshInfo")
                + selectedNavMesh.getCaption());

            parent.selectedNavMesh.highlight(true);
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
state RadUi_NavMeshEditing in CRadishNavMeshMode extends RadUi_FilteredListSelect {
    // ------------------------------------------------------------------------
    // alias
    private var editor: CRadishNavMeshEditor;
    private var navMesh: CRadishNavMesh;
    // ------------------------------------------------------------------------
    protected var editedSetting: IModUiSetting;
    protected var isValueEditing: bool;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        editor = parent.editor;
        navMesh = parent.selectedNavMesh;

        if (prevStateName != 'RadUi_InteractiveCamera'
            && prevStateName != 'RadUi_InteractiveVertexPlacement') {
            editor.init(parent.log, navMesh);
        }

        setupLabels();

        // update fields if the menu is already open
        parent.view.listMenuRef.setTitle(parent.view.title);
        parent.view.listMenuRef.setStatsLabel(parent.view.statsLabel);

        listProvider = editor.getSettingsList();

        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        // cleanup
        if (nextStateName != 'RadUi_InteractiveVertexPlacement'
            && nextStateName != 'RadUi_InteractiveCamera')
        {
            editor.deselectVertex();
        }
        super.OnLeaveState(nextStateName);
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
                    editor.syncSelectedSetting();
                    navMesh.refreshRepresentation();
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
        if (IsPressed(action) && !parent.view.listMenuRef.isEditActive()) {
            editedSetting = editor.getSelected();
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
    event OnCycleAppearance(action: SInputAction) {
        if (IsPressed(action)) {
            navMesh.cycleAppearance();
        }
    }
    // ------------------------------------------------------------------------
    event OnCycleEdges(action: SInputAction) {
        if (IsReleased(action)) {
            editor.cycleTriangleEdge();
        }
    }
    // ------------------------------------------------------------------------
    event OnToggleEdgeType(action: SInputAction) {
        var msgKey: String;

        if (IsReleased(action)) {
            switch (editor.toggleEdgeType()) {
                case 1: msgKey = "RADUI_iEdgeToNormalBorder"; break;
                case 2: msgKey = "RADUI_iEdgeToPhantomBorder"; break;
                default: return true;
            }
            parent.notice(GetLocStringByKeyExt(msgKey));
        }
    }
    // ------------------------------------------------------------------------
    event OnBack(action: SInputAction) {
        parent.backToPreviousState(action);
    }
    // ------------------------------------------------------------------------
    event OnInteractiveCam(action: SInputAction) {
        if (IsReleased(action)) {
            parent.showUi(false);
            parent.PushState('RadUi_InteractiveCamera');
        }
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_AddVertex'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_DeleteVertex'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ToggleEdgeType'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SwitchToNavMeshVertexCam'));

        hotkeyList.PushBack(HotkeyHelp_from('RADUI_CycleAppearance', "RADUI_CycleAppearanceNavMesh"));
        hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleInteractiveCam', , IK_LControl));

        hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleInteractivePlacement', , IK_P));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_EditSetting'));

        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectPrev', "RADUI_SelectPrevSetting"));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectNext', "RADUI_SelectNextSetting"));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ToggleVertexTypeIterator'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_CycleTriangleEdges'));
        super.OnHotkeyHelp(hotkeyList);
    }
    // ------------------------------------------------------------------------
    event OnManageVertices(action: SInputAction) {
        var isUpdated: bool;
        var vertexCount: int;

        if (IsPressed(action)) {
            vertexCount = navMesh.getVertexCount();
            switch (action.aName) {
                case 'RADUI_AddVertex':
                    if (vertexCount < 250) {
                        isUpdated = editor.addVertex();
                    } else {
                        parent.error(GetLocStringByKeyExt("RADUI_eMaxNavMeshVertices") + " " + 250);
                    }
                    break;

                case 'RADUI_DeleteVertex':
                    if (vertexCount > 4) {
                        isUpdated = editor.deleteVertex();
                    } else {
                        parent.error(GetLocStringByKeyExt("RADUI_eMinNavMeshVertices") + 4);
                    }
                    break;
            }
            if (isUpdated) {
                navMesh.refreshRepresentation();
                updateView();
            }
        }
    }
    // ------------------------------------------------------------------------
    event OnToggleVertexIterator(action: SInputAction) {
        var msgKey: String;

        if (IsPressed(action)) {
            editor.toggleVertexTypeIteration();

            if (editor.isInnerVertexteratorActive()) {
                msgKey = "RADUI_iInnerVertexIteratorActive";
            } else {
                msgKey = "RADUI_iBorderVertexIteratorActive";
            }
            parent.notice(GetLocStringByKeyExt(msgKey));
        }
    }
    // ------------------------------------------------------------------------
    event OnSelected(selectedId: String) {
        if (listProvider.setSelection(selectedId, true)) {
            editor.select(selectedId);
        }
        updateView();
        editor.getSelectedVertex().show(editor.isVertexSelected());
    }
    // ------------------------------------------------------------------------
    event OnInteractivePlacement(action: SInputAction) {
        if (IsReleased(action)) {
            if (!editor.isVertexSelected()) {
                editor.selectNextVertex();
            }
            parent.showUi(false);
            parent.PushState('RadUi_InteractiveVertexPlacement');
        }
    }
    // ------------------------------------------------------------------------
    event OnSwitchToSelectedVertex(action: SInputAction) {
        if (IsPressed(action) && editor.isVertexSelected()) {
            parent.navMeshManager.switchCamTo(
                RadUi_createCamSettingsFor(RadUiCam_EntityPreview,
                    editor.getSelectedVertex().getProxy())
            );
        }
    }
    // ------------------------------------------------------------------------
    protected function setupLabels() {
        parent.view.title = GetLocStringByKeyExt("RADUI_NavMeshSettingsTitle") + " " + navMesh.getCaption();
        parent.view.statsLabel = GetLocStringByKeyExt("RADUI_NavMeshSettingsListStats");
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();
        theInput.RegisterListener(this, 'OnInteractiveCam', 'RAD_ToggleInteractiveCam');
        theInput.RegisterListener(this, 'OnCycleAppearance', 'RADUI_CycleAppearance');
        theInput.RegisterListener(this, 'OnToggleVertexIterator', 'RADUI_ToggleVertexTypeIterator');
        theInput.RegisterListener(this, 'OnSwitchToSelectedVertex', 'RADUI_SwitchToNavMeshVertexCam');

        theInput.RegisterListener(this, 'OnManageVertices', 'RADUI_AddVertex');
        theInput.RegisterListener(this, 'OnManageVertices', 'RADUI_DeleteVertex');
        theInput.RegisterListener(this, 'OnCycleEdges', 'RADUI_CycleTriangleEdges');
        theInput.RegisterListener(this, 'OnToggleEdgeType', 'RADUI_ToggleEdgeType');
        theInput.RegisterListener(this, 'OnInteractivePlacement', 'RAD_ToggleInteractivePlacement');

        theInput.RegisterListener(this, 'OnEditSetting', 'RADUI_EditSetting');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        theInput.UnregisterListener(this, 'RAD_ToggleInteractiveCam');
        theInput.UnregisterListener(this, 'RADUI_CycleAppearance');
        theInput.UnregisterListener(this, 'RADUI_ToggleVertexTypeIterator');
        theInput.UnregisterListener(this, 'RADUI_SwitchToNavMeshVertexCam');

        theInput.UnregisterListener(this, 'RADUI_AddVertex');
        theInput.UnregisterListener(this, 'RADUI_DeleteVertex');
        theInput.UnregisterListener(this, 'RADUI_CycleTriangleEdges');
        theInput.UnregisterListener(this, 'RADUI_ToggleEdgeType');
        theInput.UnregisterListener(this, 'RAD_ToggleInteractivePlacement');

        theInput.UnregisterListener(this, 'RADUI_EditSetting');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
state RadUi_NavMeshManaging in CRadishNavMeshMode extends RadUi_FilteredListSelect {
    // alias
    private var manager: CRadishNavMeshManager;
    private var selected: CRadishNavMesh;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        manager = parent.navMeshManager;
        setSelected(manager.getSelected());

        parent.view.title = GetLocStringByKeyExt("RADUI_NavMeshOverviewListTitle") + " " + manager.getHubName();
        parent.view.statsLabel = GetLocStringByKeyExt("RADUI_NavMeshOverviewListStats");
        // update fields if the menu is already open
        parent.view.listMenuRef.setTitle(parent.view.title);
        parent.view.listMenuRef.setStatsLabel(parent.view.statsLabel);

        listProvider = manager.getNavMeshList();

        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        // "unselect"
        selected.highlight(false);
        super.OnLeaveState(nextStateName);
    }
    // ------------------------------------------------------------------------
    event OnBack(action: SInputAction) {
        parent.backToParent(action);
    }
    // ------------------------------------------------------------------------
    event OnSelected(selectedId: String) {
        if (listProvider.setSelection(selectedId, true)) {
            setSelected(manager.selectNavMesh(selectedId));
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
    event OnToggleVisibility(action: SInputAction) {
        if (IsPressed(action)) {
            selected.toggleVisibility();
            manager.refreshListProvider();
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

                if (selected) {
                    manager.switchCamTo(
                        RadUi_createCamSettingsFor(RadUiCam_EntityPreview, selected.getProxy())
                    );
                }
            }
            parent.config.toggleAutoCamOnSelect();
        }
    }
    // ------------------------------------------------------------------------
    event OnSwitchToNavMeshCam(action: SInputAction) {
        if (IsPressed(action) && selected) {
            parent.notice(GetLocStringByKeyExt("RADUI_iCamSwitchedTo") + selected.getCaption());
            manager.switchCamTo(
                RadUi_createCamSettingsFor(RadUiCam_EntityPreview, selected.getProxy())
            );
        }
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
        if (IsReleased(action) && selected) {
            parent.showUi(false);
            parent.PushState('RadUi_InteractivePlacement');
        }
    }
    // ------------------------------------------------------------------------
    event OnAddNavMesh(action: SInputAction) {
        if (IsReleased(action)) {
            setSelected(manager.addNew());
            updateView();
        }
    }
    // ------------------------------------------------------------------------
    event OnDelNavMesh(action: SInputAction) {
        var msgTitle, msgText: String;

        if (IsReleased(action) && selected) {
            if (parent.confirmPopup) { delete parent.confirmPopup; }

            parent.confirmPopup = new CModUiActionConfirmation in this;
            msgTitle = GetLocStringByKeyExt("RADUI_tNavMeshConfirmPopup");
            msgText = GetLocStringByKeyExt("RADUI_mNavMeshDelete") + " " + selected.getCaption() + "?";

            parent.confirmPopup.open(
                parent.popupCallback, msgTitle, msgText, "deleteNavMesh");
        }
    }
    // ------------------------------------------------------------------------
    event OnDeleteConfirmed() {
        if (!manager.deleteSelected()) {
            parent.error(GetLocStringByKeyExt("RADUI_eDeleteFailed"));
        }
        setSelected(manager.getSelected());
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnEditNavMesh(action: SInputAction) {
       // prevent direct jump to first selected category by checking "released"
       // and checking "pressed" in substate
        if (IsReleased(action)) {
            parent.PushState('RadUi_NavMeshEditing');
        }
    }
    // ------------------------------------------------------------------------
    event OnCycleAppearance(action: SInputAction) {
        if (IsPressed(action)) {
            selected.cycleAppearance();
        }
    }
    // ------------------------------------------------------------------------
    event OnRename(action: SInputAction) {
        if (!parent.view.listMenuRef.isEditActive() && IsPressed(action) && selected)
        {
            parent.view.listMenuRef.startInputMode(
                GetLocStringByKeyExt("RADUI_lNavMeshRename"),
                selected.getCaption());
        }
    }
    // ------------------------------------------------------------------------
    event OnInputEnd(inputString: String) {
        if (searchFilterInput) {
            super.OnInputEnd(inputString);
        } else {
            if (StrLen(inputString) > 2) {
                // uniqueness check
                if (manager.verifyId(inputString)) {
                    selected.setId(inputString);
                    manager.refreshListProvider();
                    listProvider.setSelection(selected.getId(), true);
                } else {
                    parent.error(GetLocStringByKeyExt("RADUI_eUniqueNavMeshName"));
                }
            } else {
                parent.error(GetLocStringByKeyExt("RADUI_eInvalidNavMeshName"));
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
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_AddNavMesh'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_DelNavMesh'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_RenameNavMesh'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_EditNavMesh'));
        hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleInteractivePlacement', , IK_P));

        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ToggleVisibility', "RADUI_ToggleVisibilityNavMesh"));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SwitchToNavMeshCam'));
        hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleInteractiveCam', , IK_LControl));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ToggleCamFollowMode'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_CycleAppearance', "RADUI_CycleAppearanceNavMesh"));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectPrev', "RADUI_SelectPrevNavMesh"));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectNext', "RADUI_SelectNextNavMesh"));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_LogDefinition', "RADUI_LogNavMeshDefinition"));

        super.OnHotkeyHelp(hotkeyList);
    }
    // ------------------------------------------------------------------------
    protected function setSelected(navMesh: CRadishNavMesh) {
        selected.highlight(false);

        selected = navMesh;
        parent.selectedNavMesh = navMesh;

        if (navMesh && parent.config.isAutoCamOnSelect()) {
            manager.switchCamTo(
                RadUi_createCamSettingsFor(RadUiCam_EntityPreview, selected.getProxy())
            );
        }
        selected.highlight(true);
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();
        theInput.RegisterListener(this, 'OnQuitRequest', 'RADUI_Quit');
        theInput.RegisterListener(this, 'OnInteractiveCam', 'RAD_ToggleInteractiveCam');
        theInput.RegisterListener(this, 'OnInteractivePlacement', 'RAD_ToggleInteractivePlacement');

        theInput.RegisterListener(this, 'OnToggleVisibility', 'RADUI_ToggleVisibility');
        theInput.RegisterListener(this, 'OnSwitchToNavMeshCam', 'RADUI_SwitchToNavMeshCam');
        theInput.RegisterListener(this, 'OnToggleCamFollow', 'RADUI_ToggleCamFollowMode');
        theInput.RegisterListener(this, 'OnCycleAppearance', 'RADUI_CycleAppearance');

        theInput.RegisterListener(this, 'OnEditNavMesh', 'RADUI_EditNavMesh');
        theInput.RegisterListener(this, 'OnAddNavMesh', 'RADUI_AddNavMesh');
        theInput.RegisterListener(this, 'OnDelNavMesh', 'RADUI_DelNavMesh');
        theInput.RegisterListener(this, 'OnRename', 'RADUI_RenameNavMesh');

        theInput.RegisterListener(parent, 'OnLogDefinition', 'RADUI_LogDefinition');
        theInput.RegisterListener(parent, 'OnToggleCamFollow', 'RADUI_ToggleCamFollowMode');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        theInput.UnregisterListener(this, 'RADUI_Quit');
        theInput.UnregisterListener(this, 'RAD_ToggleInteractiveCam');
        theInput.UnregisterListener(this, 'RAD_ToggleInteractivePlacement');

        theInput.UnregisterListener(this, 'RADUI_ToggleVisibility');
        theInput.UnregisterListener(this, 'RADUI_SwitchToNavMeshCam');
        theInput.UnregisterListener(this, 'RADUI_ToggleCamFollowMode');
        theInput.UnregisterListener(this, 'RADUI_CycleAppearance');

        theInput.UnregisterListener(this, 'RADUI_EditNavMesh');
        theInput.UnregisterListener(this, 'RADUI_AddNavMesh');
        theInput.UnregisterListener(this, 'RADUI_DelNavMesh');
        theInput.UnregisterListener(this, 'RADUI_RenameNavMesh');

        theInput.UnregisterListener(parent, 'RADUI_LogDefinition');
        theInput.UnregisterListener(parent, 'RADUI_ToggleCamFollowMode');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// Top level management of navmeshes
//
statemachine class CRadishNavMeshMode extends CRadishListViewWorkMode {
    default workMode = 'RADUI_ModeNavMeshes';
    default workContext = 'MOD_RadishUi_ModeNavMeshes';
    default generalHelpKey = "RADUI_NavMeshGeneralHelp";
    default defaultState = 'RadUi_NavMeshManaging';
    // ------------------------------------------------------------------------
    protected var theVisualizer: CRadishProxyVisualizer;
    protected var navMeshManager: CRadishNavMeshManager;
    protected var selectedNavMesh: CRadishNavMesh;
    // ------------------------------------------------------------------------
    protected var editor: CRadishNavMeshEditor;
    // ------------------------------------------------------------------------
    public function init(navMeshManager: IRadishUiModeManager, config: CRadishQuestConfigManager)
    {
        super.init(navMeshManager, config);
        this.navMeshManager = (CRadishNavMeshManager)navMeshManager;

        // navMesh editor must survice state changes to enable selection of
        // borderpoints therefore it cannot be created in OnEnterState of
        // meshEditing -> just initialized with selected navMesh
        editor = new CRadishNavMeshEditor in this;
    }
    // ------------------------------------------------------------------------
    public function setVisualizer(visualizer: CRadishProxyVisualizer) {
        this.theVisualizer = visualizer;
    }
    // ------------------------------------------------------------------------
    event OnLogDefinition(action: SInputAction) {
        if (IsPressed(action)) {
            navMeshManager.logDefinition();
            notice(GetLocStringByKeyExt("RADUI_iNavMeshDefinitionLogged"));
        }
    }
    // ------------------------------------------------------------------------
    event OnToggleCamFollow(action: SInputAction) {
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
    event OnDeleteConfirmed() {}
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
