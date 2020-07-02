// ----------------------------------------------------------------------------
state RadUi_LayerEntitySearch in CRadishQuestLayerSearchMode extends RadUi_FilteredListSelect
{
    // alias
    private var layerManager: CRadishQuestLayerManager;
    private var selectedEntity: CRadishLayerEntity;

    // TODO maybe as seperately saved setting?
    private var followCam: bool; default followCam = true;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        layerManager = parent.layerManager;

        parent.view.title = parent.getName();
        parent.view.statsLabel = GetLocStringByKeyExt("RADUI_EntitySearchListTitle");
        // update fields if the menu is already open
        parent.view.listMenuRef.setTitle(parent.view.title);
        parent.view.listMenuRef.setStatsLabel(parent.view.statsLabel);

        listProvider = layerManager.getLayerEntityList();

        selectedEntity = layerManager.getEntity(listProvider.getSelectedId());
        selectedEntity.highlight(true);

        // this flag is independent from the saved switchOnSelect!
        if (followCam) {
            layerManager.getCam().switchTo(
                RadUi_createCamSettingsFor(RadUiCam_EntityPreview, selectedEntity.getProxy()));
        }

        //TODO add autostart search (doesn't work by simply calling
        // startInputMode as menu may not be open)
        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        // restore cam
        layerManager.getCam().switchTo();
        // "unselect" entity
        selectedEntity.highlight(false);

        listProvider.resetWildcardFilter();
        super.OnLeaveState(nextStateName);
    }
    // ------------------------------------------------------------------------
    event OnBack(action: SInputAction) {
        action.aName = 'RADUI_BackToTop';
        parent.backToParent(action);
    }
    // ------------------------------------------------------------------------
    event OnInteractiveCam(action: SInputAction) {
        if (IsReleased(action)) {
            if (followCam) {
                followCam = false;
                parent.notice(
                    GetLocStringByKeyExt("RAD_iCamInteractive") + " " +
                    GetLocStringByKeyExt("RADUI_iEntitySearchCamFollowOff")
                );
            }
            parent.showUi(false);
            parent.PushState('RadUi_InteractiveCamera');
        }
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        parent.OnHotkeyHelp(hotkeyList);
    }
    // ------------------------------------------------------------------------
    event OnSelected(selectedId: String) {
        if (listProvider.setSelection(selectedId, true)) {
            // selection was a layerentity (and not category)
            // de-highlight previously selected
            selectedEntity.highlight(false);

            selectedEntity = layerManager.getEntity(selectedId);
            selectedEntity.highlight(true);

            parent.notice(GetLocStringByKeyExt("RADUI_iSelectedLayerEntityInfo")
                + " " + selectedEntity.getCaption());

            // this flag is independent from the saved switchOnSelect!
            if (followCam) {
                layerManager.getCam().switchTo(
                    RadUi_createCamSettingsFor(RadUiCam_EntityPreview, selectedEntity.getProxy()));
            }
        }
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnToggleCamFollow(action: SInputAction) {
        if (IsPressed(action)) {
            if (followCam) {
                parent.notice(GetLocStringByKeyExt("RADUI_iEntitySearchCamFollowOff"));
            } else {
                parent.notice(GetLocStringByKeyExt("RADUI_iEntitySearchCamFollowOn"));
                layerManager.getCam().switchTo(
                    RadUi_createCamSettingsFor(RadUiCam_EntityPreview, selectedEntity.getProxy())
                );
            }
            followCam = !followCam;
        }
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();

        theInput.RegisterListener(this, 'OnBack', 'RADUI_BackToTop');
        theInput.RegisterListener(this, 'OnInteractiveCam', 'RAD_ToggleInteractiveCam');
        theInput.RegisterListener(this, 'OnEditEntity', 'RADUI_EditEntity');
        theInput.RegisterListener(this, 'OnToggleCamFollow', 'RADUI_ToggleCamFollowMode');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();

        theInput.UnregisterListener(this, 'RADUI_BackToTop');
        theInput.UnregisterListener(this, 'RAD_ToggleInteractiveCam');
        theInput.UnregisterListener(this, 'RADUI_EditEntity');
        theInput.UnregisterListener(this, 'RADUI_ToggleCamFollowMode');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// Top level search for layerentities and direct jump to editing entity in layer
//
statemachine class CRadishQuestLayerSearchMode extends CRadishListViewWorkMode {
    default workMode = 'RADUI_QL_ModeEntitySearch';
    default workContext = 'MOD_RadishUi_QL_ModeEntitySearch';
    default generalHelpKey = "RADUI_EntitySearchGeneralHelp";
    default defaultState = 'RadUi_LayerEntitySearch';
    // ------------------------------------------------------------------------
    protected var layerManager: CRadishQuestLayerManager;
    // ------------------------------------------------------------------------
    public function init(layerManager: IRadishUiModeManager, config: CRadishQuestConfigManager)
    {
        super.init(layerManager, config);
        this.layerManager = (CRadishQuestLayerManager)layerManager;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
