// ----------------------------------------------------------------------------
state RadUi_InteractivePlacement in CRadishQuestLayerActionpointMode
    extends RadUi_BaseEntityInteractivePlacement
{
    default isRotatableYaw = true;
    default isRotatablePitch = false;
    default isRotatableRoll = false;
}
// ----------------------------------------------------------------------------
state RadUi_ActionpointJobTreeSelection in CRadishQuestLayerActionpointMode
    extends RadUi_BaseListSettingSelection
{
    default workContext = 'MOD_RadishUi_ModeJobtreeSelection';
    // ------------------------------------------------------------------------
    private var apProxy: CRadishActionpointProxy;
    // ------------------------------------------------------------------------
    var camPlacement: SRadishPlacement;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        var manager: CRadishQuestLayerActionpointManager;
        var selected: CRadishQuestLayerActionpoint;

        manager = (CRadishQuestLayerActionpointManager)parent.itemManager;
        selected = (CRadishQuestLayerActionpoint)manager.getSelected();

        apProxy = (CRadishActionpointProxy)selected.getProxy();
        proxy = apProxy;

        parent.theVisualizer.resetAnimated();
        parent.theVisualizer.selectForAnimation("actionpoint", selected.getId());
        if (!parent.theVisualizer.startAnimations()) {
            parent.error(
                GetLocStringByKeyExt("RADUI_eActionpointPreview") + " " + apProxy.getActionId());
        }

        theCam = manager.getCam();
        camPlacement = theCam.getSettings();

        if (parent.config.isAutoCamOnSelect()) {
            manager.switchCamTo(RadUi_createCamSettingsFor(RadUiCam_EntityPreview, proxy));
        }

        listProvider = manager.getJobTreeList();
        listProvider.setSelection(apProxy.getActionId(), true);

        super.setupLabels("Jobtree", selected.getCaption());
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    private function shouldIgnoreCollision(action: String) : bool {
        var result: bool;

        result = StrBeginsWith(action, "sit_") || StrFindFirst(action, "_sit_") > 0;
        result = result || StrFindFirst(action, "_sitting_") > 0 || StrEndsWith(action, "_sitting");

        result = result || StrBeginsWith(action, "lie_") || StrFindFirst(action, "_lie_") > 0;
        result = result || StrBeginsWith(action, "lying_") || StrFindFirst(action, "_lying_") > 0;

        return result;
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        var selected: CRadishQuestLayerActionpoint;
        var settings: SRadishLayerActionpointData;
        var null: CRadishActionpointProxy;

        selected = (CRadishQuestLayerActionpoint)parent.itemManager.getSelected();
        settings = selected.getSettings();

        settings.action = apProxy.getAction();
        settings.category = apProxy.getCategory();
        // preset collisions flag heuristically by deriving from selected action name
        settings.ignoreCollisions = this.shouldIgnoreCollision(settings.action);
        selected.setSettings(settings);

        // do not stop animations for placement change -> anim will only be frozen
        if (nextStateName == 'RadUi_InteractivePlacement') {
            LogChannel('DEBUG', "->PLACMENT MODE");
            apProxy.freezeActor();
        } else {
            parent.theVisualizer.stopAnimations();
        }
        apProxy = null;
        proxy = null;

        super.OnLeaveState(nextStateName);
    }
    // ------------------------------------------------------------------------
    event OnSelected(selectedId: String) {
        var msg: String;

        if (listProvider.setSelection(selectedId, true)) {
            parent.theVisualizer.stopAnimations();
            apProxy.setActionId(selectedId);
            if (parent.theVisualizer.startAnimations()) {
                msg = GetLocStringByKeyExt("RADUI_iChangedJobTree");
            } else {
                parent.log.error("failed animpreview for actionid: " + apProxy.getActionId());
                msg = GetLocStringByKeyExt("RADUI_eActionpointPreview");
            }
            parent.notice(msg + " " + apProxy.getActionId());

            if (parent.config.isAutoCamOnSelect()) {
                adjustActionpointCam(proxy);
            }
        }
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnInteractivePlacement(action: SInputAction) {
        if (IsReleased(action)) {
            parent.showUi(false);
            parent.PushState('RadUi_InteractivePlacement');
        }
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        super.OnHotkeyHelp(hotkeyList);
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectPrev', "RADUI_SelectPrevJobtree"));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectNext', "RADUI_SelectNextJobtree"));
        hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleInteractivePlacement', , IK_P));
    }
    // ------------------------------------------------------------------------
    // entry functions seem to require having different names (in hierarchy)
    protected entry function adjustActionpointCam(proxy: CRadishProxyRepresentation) {
        latentCamAdjust(proxy);
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();
        theInput.RegisterListener(this, 'OnInteractivePlacement', 'RAD_ToggleInteractivePlacement');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        theInput.UnregisterListener(this, 'RAD_ToggleInteractivePlacement');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
state RadUi_ActionpointEditing in CRadishQuestLayerActionpointMode extends RadUi_EntityEditing
{
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        entityEditor = new CRadishQuestLayerActionpointEditor in this;
        entity = parent.itemManager.getSelected();

        super.setupLabels("Actionpoint");
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnEditSetting(action: SInputAction) {
        if (unlocked && IsPressed(action) && !parent.view.listMenuRef.isEditActive()) {
            editedSetting = entityEditor.getSelected();
            // redirect ap workjob editing to special state with selection menu
            if ((CModUiActionpointJobUiSetting)editedSetting) {
                parent.PushState('RadUi_ActionpointJobTreeSelection');
                //TODO how to get return values?
            } else {
                super.OnEditSetting(action);
            }
        }
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        if (unlocked) {
            hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectActionpointJobtree'));
        }
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_CycleAppearance', "RADUI_CycleAppearanceActionpoint"));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_PreviewCurrentActionpointJobtree'));
        super.OnEntityHotkeyHelp("Actionpoint", hotkeyList);
    }
    // ------------------------------------------------------------------------
    event OnPreviewActionpoint(action: SInputAction) {
        var msg: String;

        if (unlocked && IsPressed(action) && !parent.view.listMenuRef.isEditActive()) {
            parent.theVisualizer.resetAnimated();
            parent.theVisualizer.selectForAnimation("actionpoint", entity.getId());
            if (parent.theVisualizer.startAnimations()) {
                msg = GetLocStringByKeyExt("RADUI_iActionpointsPreview");
            } else {
                msg = GetLocStringByKeyExt("RADUI_eActionpointPreview");
            }
            parent.notice(msg + " " + entity.getCaption());
        }
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();
        if (unlocked) {
            theInput.RegisterListener(parent, 'OnSelectActionpointJobTree', 'RADUI_SelectActionpointJobtree');
        } else {
            theInput.RegisterListener(parent, 'OnLockedMode', 'RADUI_SelectActionpointJobtree');
        }
        theInput.RegisterListener(parent, 'OnPreviewActionpoint', 'RADUI_PreviewCurrentActionpointJobtree');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        theInput.UnregisterListener(parent, 'RADUI_SelectActionpointJobtree');
        theInput.UnregisterListener(parent, 'RADUI_PreviewCurrentActionpointJobtree');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
state RadUi_ActionpointManaging in CRadishQuestLayerActionpointMode extends RadUi_EntityManaging
{
    default editStateName = 'RadUi_ActionpointEditing';
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        super.setupLabels("Actionpoint");
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        if (unlocked) {
            hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectActionpointJobtree'));
        }
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_CycleAppearance', "RADUI_CycleAppearanceActionpoint"));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_PreviewCurrentActionpointJobtree'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_PreviewLayerActionpointJobtrees'));
        super.OnEntityHotkeyHelp("Actionpoint", hotkeyList);
    }
    // ------------------------------------------------------------------------
    event OnPreviewSelectedActionpoint(action: SInputAction) {
        var entity: CRadishLayerEntity;
        var msg: String;

        if (unlocked && IsPressed(action) && !parent.view.listMenuRef.isEditActive()) {
            entity = parent.itemManager.getSelected();
            if (entity) {

                // reset animated proxy list and play only the selected anim because
                // previously selected ap (actors) may have been deleted (despawned) already
                parent.theVisualizer.resetAnimated();
                parent.theVisualizer.selectForAnimation("actionpoint", entity.getId());
                if (parent.theVisualizer.startAnimations()) {
                    msg = GetLocStringByKeyExt("RADUI_iActionpointsPreview");
                } else {
                    msg = GetLocStringByKeyExt("RADUI_eActionpointPreview");
                }
                parent.notice(msg + " " + entity.getCaption());
            }
        }
    }
    // ------------------------------------------------------------------------
    event OnPreviewAllActionpoints(action: SInputAction) {
        var entity: CRadishLayerEntity;
        var msg: String;

        if (unlocked && IsPressed(action) && !parent.view.listMenuRef.isEditActive()) {
            parent.theVisualizer.resetAnimated();
            if (parent.theVisualizer.selectForAnimation(
                "actionpoint", SRadUiLayerEntityId(parent.itemManager.getLayerId(), "*")) > 0)
            {
                if (parent.theVisualizer.startAnimations()) {
                    msg = GetLocStringByKeyExt("RADUI_iActionpointsPreview");
                } else {
                    msg = GetLocStringByKeyExt("RADUI_eActionpointPreview");
                }
            } else {
                msg = GetLocStringByKeyExt("RADUI_iNoActionpointsToPreview");
            }
            parent.notice(msg + " " + parent.itemManager.getLayerCaption());
        }
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();
        if (unlocked) {
            theInput.RegisterListener(parent, 'OnSelectActionpointJobTree', 'RADUI_SelectActionpointJobtree');
            //theInput.RegisterListener(parent, 'OnFreezeActionPointPreview', 'RADUI_ActionpointPreviewFreezeToggle');
        } else {
            theInput.RegisterListener(parent, 'OnLockedMode', 'RADUI_SelectActionpointJobtree');
        }
        theInput.RegisterListener(parent, 'OnPreviewSelectedActionpoint', 'RADUI_PreviewCurrentActionpointJobtree');
        theInput.RegisterListener(parent, 'OnPreviewAllActionpoints', 'RADUI_PreviewLayerActionpointJobtrees');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        theInput.UnregisterListener(parent, 'RADUI_SelectActionpointJobtree');
        theInput.UnregisterListener(parent, 'RADUI_PreviewCurrentActionpointJobtree');
        theInput.UnregisterListener(parent, 'RADUI_PreviewLayerActionpointJobtrees');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// Top level management of Actionpoints
statemachine class CRadishQuestLayerActionpointMode extends CRadishQuestLayerEntityMode {
    default workMode = 'RADUI_QL_ModeActionpoints';
    default workContext = 'MOD_RadishUi_QL_ModeActionpoints';
    default generalHelpKey = "RADUI_ActionpointGeneralHelp";
    default defaultState = 'RadUi_ActionpointManaging';
    // ------------------------------------------------------------------------
    protected var theVisualizer: CRadishProxyVisualizer;
    // ------------------------------------------------------------------------
    public function setVisualizer(visualizer: CRadishProxyVisualizer) {
        this.theVisualizer = visualizer;
    }
    // ------------------------------------------------------------------------
    event OnSelectActionpointJobTree(action: SInputAction) {
        if (unlocked && IsPressed(action) && itemManager.getSelected() && !view.listMenuRef.isEditActive()) {
            PushState('RadUi_ActionpointJobTreeSelection');
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
