// ----------------------------------------------------------------------------
state RadUi_CommunityEditing in CRadishCommunityMode extends RadUi_ListSelect {
    private var editor: CRadishCommunityEditor;
    private var community: CRadishCommunity;
    private var encodedCommunity: CEncodedRadishCommunity;
    private var unlocked: bool;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        var communityName: String;

        editor = new CRadishCommunityEditor in this;
        community = parent.communityManager.getSelected();
        encodedCommunity = (CEncodedRadishCommunity)community;
        editor.init(parent.log, community, parent.theVisualizer);

        communityName = community.getName();
        if (encodedCommunity) {
            // indicate readonly by different layername color
            communityName = " <font color=\"#ED8D33\">" + communityName + "</font>";
        } else {
            unlocked = true;
        }

        parent.view.title = GetLocStringByKeyExt("RADUI_CommunityEditTitle") + communityName;
        parent.view.statsLabel = GetLocStringByKeyExt("RADUI_CommunityEditListStats");
        // update fields if the menu is already open
        parent.view.listMenuRef.setTitle(parent.view.title);
        parent.view.listMenuRef.setStatsLabel(parent.view.statsLabel);

        listProvider = editor.getCommunityElementsList();

        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        editor.clearHighlighted();
        super.OnLeaveState(nextStateName);
    }
    // ------------------------------------------------------------------------
    event OnSelected(selectedId: String) {
        listProvider.setSelection(selectedId);
        editor.select(selectedId);
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnBack(action: SInputAction) {
        if (community.isDirty()) {
            community.resetDirtyFlag();
            parent.communityManager.refreshListProvider();
        }
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
    event OnToggleCamFollow(action: SInputAction) {
        parent.OnToggleCamFollow(action);

        if (IsPressed(action) && parent.config.isAutoCamOnSelect()) {
            editor.refreshHighlight(true);
        }
    }
    // ------------------------------------------------------------------------
    event OnSwitchCamToHighlighted(action: SInputAction) {
        if (IsPressed(action)) {
            editor.refreshHighlight(true);
        }
    }
    // ------------------------------------------------------------------------
    private function initSubmode(
        element: CRadishCommunityElement,
        modeManager: CRadishCommunityElementEditor,
        submode: CRadishCommunityElementMode)
    {
        modeManager.init(parent.log,
            community.getName(), element,
            parent.theVisualizer,
            parent.communityManager.getCam());
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
    event OnEditElement(action: SInputAction) {
        var element: CRadishCommunityElement;
        var phase: CRadishCommunityPhase;
        var actor: CRadishCommunityActor;

        if (IsPressed(action)) {
            element = editor.getElement(listProvider.getSelectedId());
            phase = (CRadishCommunityPhase)element;
            actor = (CRadishCommunityActor)element;

            if (actor) {
                parent.PushState('RadUi_WaitForSubmodeEnd');
                initSubmode(
                    actor,
                    new CRadishCommunityActorEditor in this,
                    new CRadishCommunityActorMode in this
                );
            } else if (phase) {
                parent.PushState('RadUi_WaitForSubmodeEnd');
                initSubmode(
                    phase,
                    new CRadishCommunityPhaseEditor in this,
                    new CRadishCommunityPhaseMode in this
                );
            }
        }
    }
    // ------------------------------------------------------------------------
    event OnTogglePhaseSpawn(action: SInputAction) {
        var result: CRadishCommunityPhase;
        var id: String;

        if (IsPressed(action)) {
            id = listProvider.getSelectedId();
//            element = (CRadishCommunityPhase)editor.getElement(id);

            //TODO move prefix detection into phase?
            if (StrFindFirst(id, "p:") == 0) {
                id = StrAfterFirst(id, "p:");

                result = encodedCommunity.spawnPhase(id);
                if (result) {
                    parent.notice(GetLocStringByKeyExt("RADUI_iCommunitySpawn")
                        + encodedCommunity.getName()
                        + GetLocStringByKeyExt("RADUI_iPhaseSpawn")
                        + result.getCaption());
                }

                editor.refreshList();
                updateView();
            }
        }
    }
    // ------------------------------------------------------------------------
    event OnDespawn(action: SInputAction) {
        if (IsPressed(action) && encodedCommunity) {

            if (encodedCommunity.isSpawned()) {
                parent.notice(GetLocStringByKeyExt("RADUI_iCommunityDespawn"
                    + encodedCommunity.getName()));
            }

            encodedCommunity.despawn();
            editor.refreshList();
            updateView();
        }
    }
    // ------------------------------------------------------------------------
    event OnToggleVisibility(action: SInputAction) {
        if (IsPressed(action)) {
            //TODO
            //eEditor.toggleVisibility(listProvider.getSelectedId());
            //editor.refreshList();
            updateView();
        }
    }
    // ------------------------------------------------------------------------
    event OnEntityHotkeyHelp(subtype: String, out hotkeyList: array<SModUiHotkeyHelp>) {
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_TogglePhaseSpawn'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_Despawn'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SwitchCamToHighlighted'));
        hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleInteractiveCam', , IK_LControl));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ToggleCamFollowMode'));
        if (unlocked) {
            hotkeyList.PushBack(HotkeyHelp_from('RADUI_EditElement'));
        } else {
            hotkeyList.PushBack(HotkeyHelp_from('RADUI_EditElement', "RADUI_ViewSettingsCommunity"));
        }
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectPrev', "RADUI_SelectPrevCommunity"));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectNext', "RADUI_SelectNextCommunity"));
        super.OnHotkeyHelp(hotkeyList);
    }

    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();
        theInput.RegisterListener(this, 'OnInteractiveCam', 'RAD_ToggleInteractiveCam');
        theInput.RegisterListener(this, 'OnSwitchCamToHighlighted', 'RADUI_SwitchCamToHighlighted');
        theInput.RegisterListener(this, 'OnToggleCamFollow', 'RADUI_ToggleCamFollowMode');

        theInput.RegisterListener(this, 'OnEditElement', 'RADUI_EditElement');

        theInput.RegisterListener(this, 'OnTogglePhaseSpawn', 'RADUI_TogglePhaseSpawn');
        theInput.RegisterListener(this, 'OnDespawn', 'RADUI_Despawn');
        theInput.RegisterListener(this, 'OnToggleVisibility', 'RADUI_ToggleVisibility');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        theInput.UnregisterListener(this, 'RAD_ToggleInteractiveCam');
        theInput.UnregisterListener(this, 'RADUI_SwitchCamToHighlighted');
        theInput.UnregisterListener(this, 'RADUI_ToggleCamFollowMode');

        theInput.UnregisterListener(this, 'RADUI_EditElement');

        theInput.UnregisterListener(this, 'RADUI_TogglePhaseSpawn');
        theInput.UnregisterListener(this, 'RADUI_Despawn');
        theInput.UnregisterListener(this, 'RADUI_ToggleVisibility');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
state RadUi_CommunityManaging in CRadishCommunityMode extends RadUi_FilteredListSelect {
    // alias
    private var manager: CRadishCommunityManager;
    private var selected: CRadishCommunity;
    private var selectedEncoded: CEncodedRadishCommunity;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        manager = parent.communityManager;
        setSelected(manager.getSelected());

        parent.view.title = parent.getName();
        parent.view.statsLabel = GetLocStringByKeyExt("RADUI_CommunityOverviewListTitle");
        // update fields if the menu is already open
        parent.view.listMenuRef.setTitle(parent.view.title);
        parent.view.listMenuRef.setStatsLabel(parent.view.statsLabel);

        listProvider = manager.getCommunityList();

        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnBack(action: SInputAction) {
        parent.backToParent(action);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        parent.OnHotkeyHelp(hotkeyList);

        //hotkeyList.PushBack(HotkeyHelp_from('RADUI_PrevLayer'));
        //hotkeyList.PushBack(HotkeyHelp_from('RADUI_NextLayer'));
    }
    // ------------------------------------------------------------------------
    event OnInteractiveCam(action: SInputAction) {
        if (IsReleased(action)) {
            parent.showUi(false);
            parent.PushState('RadUi_InteractiveCamera');
        }
    }
    // ------------------------------------------------------------------------
    event OnSelected(selectedId: String) {
        if (listProvider.setSelection(selectedId, true)) {
            setSelected(manager.selectCommunity(selectedId));
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
    event OnEditCommunity(action: SInputAction) {
       // prevent direct jump to first selected category by checking "released"
       // and checking "pressed" in substate
        if (IsReleased(action)) {
            parent.PushState('RadUi_CommunityEditing');
        }
    }
    // ------------------------------------------------------------------------
    event OnTogglePhaseSpawn(action: SInputAction) {
        var result: CRadishCommunityPhase;

        if (IsPressed(action)) {
            if (!selectedEncoded.isSpawned()) {

                result = selectedEncoded.spawnFirstPhase();
                if (result) {
                    parent.notice(GetLocStringByKeyExt("RADUI_iCommunitySpawn") + selectedEncoded.getName()
                        + GetLocStringByKeyExt("RADUI_iPhaseSpawn")
                        + result.getCaption());
                }

                manager.refreshListProvider();
                updateView();
            }
        }
    }
    // ------------------------------------------------------------------------
    event OnDespawn(action: SInputAction) {
        if (IsPressed(action) && selectedEncoded) {

            if (selectedEncoded.isSpawned()) {
                parent.notice(GetLocStringByKeyExt("RADUI_iCommunityDespawn" + selectedEncoded.getName()));
            }

            selectedEncoded.despawn();
            manager.refreshListProvider();
            updateView();
        }
    }
    // ------------------------------------------------------------------------
    event OnScanForCommunities(action:SInputAction) {
        if (IsPressed(action)) {
            manager.scanForActivePhases();
            manager.refreshListProvider();
            updateView();
        }
    }
    // ------------------------------------------------------------------------
    protected function setSelected(community: CRadishCommunity) {
        selected = community;
        selectedEncoded = (CEncodedRadishCommunity)community;
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();
        theInput.RegisterListener(this, 'OnQuitRequest', 'RADUI_Quit');
        theInput.RegisterListener(this, 'OnInteractiveCam', 'RAD_ToggleInteractiveCam');
        theInput.RegisterListener(this, 'OnEditCommunity', 'RADUI_EditCommunity');
        theInput.RegisterListener(this, 'OnToggleApVisibility', 'RADUI_ToggleVisibility');
        theInput.RegisterListener(this, 'OnTogglePhaseSpawn', 'RADUI_TogglePhaseSpawn');
        theInput.RegisterListener(this, 'OnDespawn', 'RADUI_Despawn');
        theInput.RegisterListener(this, 'OnScanForCommunities', 'RADUI_RescanPhases');
        // TODO ap visibility toggle
        // -> extract all aps for phase, query layermanager for all aps by id-list, set visibility
        // -> on change of phase hide (or if permanent visiblity, do not hide)

        //theInput.RegisterListener(parent, 'OnLogDefinition', 'RADUI_LogDefinition');
        theInput.RegisterListener(parent, 'OnToggleCamFollow', 'RADUI_ToggleCamFollowMode');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        theInput.UnregisterListener(this, 'RADUI_Quit');
        theInput.UnregisterListener(this, 'RAD_ToggleInteractiveCam');
        theInput.UnregisterListener(this, 'RADUI_EditCommunity');
        theInput.UnregisterListener(this, 'RADUI_ToggleVisibility');
        theInput.UnregisterListener(this, 'RADUI_TogglePhaseSpawn');
        theInput.UnregisterListener(this, 'RADUI_Despawn');
        theInput.UnregisterListener(this, 'RADUI_RescanPhases');

        //theInput.UnregisterListener(parent, 'RADUI_LogDefinition');
        theInput.UnregisterListener(parent, 'RADUI_ToggleCamFollowMode');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// Top level management of communities:
//
statemachine class CRadishCommunityMode extends CRadishListViewWorkMode {
    default workMode = 'RADUI_ModeCommunities';
    default workContext = 'MOD_RadishUi_ModeCommunities';
    default generalHelpKey = "RADUI_CommunityGeneralHelp";
    default defaultState = 'RadUi_CommunityManaging';
    // ------------------------------------------------------------------------
    protected var theVisualizer: CRadishProxyVisualizer;
    protected var communityManager: CRadishCommunityManager;
    protected var currentSubMode: CRadishWorkMode;
    // ------------------------------------------------------------------------
    public function init(communityManager: IRadishUiModeManager, config: CRadishQuestConfigManager)
    {
        super.init(communityManager, config);
        this.communityManager = (CRadishCommunityManager)communityManager;
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
        if (currentSubMode) {
            currentSubMode.deactivate();
            delete currentSubMode;
            switch (action.aName) {
                case 'RADUI_BackToTop':
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
            communityManager.logDefinition();
            notice(GetLocStringByKeyExt("RADUI_iCommunityDefinitionLogged"));
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
    event OnDeleteConfirm() {}
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
