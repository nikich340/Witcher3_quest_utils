// -----------------------------------------------------------------------------
//
// BUGS:
//
// TODO:
// ----------------------------------------------------------------------------
class CRadUiPopupCallback extends IModUiConfirmPopupCallback {
    public var callback: CRadishQuestUiMod;

    public function OnConfirmed(action: String) {
        switch (action) {
            case "quit": return callback.doQuit();
        }
    }
}
// ----------------------------------------------------------------------------
class CRadUiRootModeCallback extends IRadUiParentCallback {
    public var callback: CRadishQuestUi;

    public function onBackFromChild(action: SInputAction) {
        callback.OnChangeWorkMode(action);
    }
}
// ----------------------------------------------------------------------------
state RadUi_Maximized in CRadishQuestUiMod {
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        parent.modEnv.deactivateHud();
        parent.modEnv.hidePlayer();
        parent.modEnv.freezeTime();

        // refresh camera position to player position
        parent.configManager.setLastCamPosition(RadUi_createCamSettingsFor(RadUiCam_Empty));
        parent.radUi.activate();
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        theInput.SetContext('Exploration');
        parent.radUi.deactivate();

        parent.modEnv.unfreezeTime();
        parent.modEnv.restorePlayer();
        parent.modEnv.reactivateHud();
    }
    // ------------------------------------------------------------------------
    event OnMinimize(action: SInputAction) {
        if (IsPressed(action)) {
            if (action.aName == 'RADUI_ModeMinimize') {
                parent.PopState();
            }
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
state RadUi_Minimized in CRadishQuestUiMod {
    // ------------------------------------------------------------------------
    event OnMaximize(action: SInputAction) {
        var entity : CEntity;
        var template : CEntityTemplate;

        if (IsPressed(action)) {
            if (!parent.radUi) {
                template = (CEntityTemplate)LoadResource("dlc\modtemplates\radishquestui\radui.w3mod", true);
                entity = theGame.CreateEntity(template,
                    thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation());

                parent.radUi = (CRadishQuestUi)entity;
                parent.radUi.init(parent.log, parent.configManager, parent.questId, parent.quitConfirmCallback);

                template = (CEntityTemplate)LoadResource("dlc\modtemplates\radishseeds\radish_modutils.w2ent", true);
                entity = theGame.CreateEntity(template,
                    thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation());
                parent.modEnv = (CRadishModUtils)entity;
            }

            parent.PushState('RadUi_Maximized');
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
statemachine class CRadishQuestUiMod extends CMod {
    default modName = 'RadishQuestUi';
    default modAuthor = "rmemr";
    default modUrl = "http://www.nexusmods.com/witcher3/mods/3620/";
    default modVersion = '0.6.2';

    default logLevel = MLOG_DEBUG;
    // ------------------------------------------------------------------------
    protected var radUi: CRadishQuestUi;
    // optional filter for encoded layers/communities
    protected var questId: String;

    protected var modEnv: CRadishModUtils;
    // ------------------------------------------------------------------------
    // UI stuff
    protected var quitConfirmCallback: CRadUiPopupCallback;
    // ------------------------------------------------------------------------
    private var modConfigId: CName; default modConfigId = 'RadishUiConfig';
    protected var configManager: CRadishQuestConfigManager;
    // ------------------------------------------------------------------------
    private var gameTime: GameTime;
    // ------------------------------------------------------------------------
    public function init() {
        super.init();

        this.questId = StrLower(RADUI_getQuestId());

        configManager = new CRadishQuestConfigManager in this;
        configManager.init(this.log, (CRadishQuestConfigData)GetModStorage().load(modConfigId));

        this.registerListeners();

        // prepare view callback wiring
        quitConfirmCallback = new CRadUiPopupCallback in this;
        quitConfirmCallback.callback = this;

        // store time on activation to reset from any interactive time changes
        gameTime = theGame.GetGameTime();
        PushState('RadUi_Minimized');
    }
    // ------------------------------------------------------------------------
    event OnMinimize(action: SInputAction) {}
    event OnMaximize(action: SInputAction) {}
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        theInput.RegisterListener(this, 'OnMinimize', 'RADUI_ModeMinimize');
        theInput.RegisterListener(this, 'OnMaximize', 'RADUI_Maximize');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        theInput.UnregisterListener(this, 'RADUI_ModeMinimize');
        theInput.UnregisterListener(this, 'RADUI_Maximize');
    }
    // ------------------------------------------------------------------------
    public function doQuit() {
        var null: CRadishQuestUi;

        // reset every change made to time
        theGame.SetGameTime(gameTime, true);

        this.radUi.doQuit();
        this.radUi = null;
        PopState();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CRadishQuestUi extends CEntity {
    // ------------------------------------------------------------------------
    private var autoLogInterval: float; default autoLogInterval = 600.0;
    private var autoLogDefLayer: bool;
    private var autoLogDefCommunities: bool;
    private var autoLogDefNavMeshes: bool;
    private var isRadUiActive: bool;
    // ------------------------------------------------------------------------
    private var log: CModLogger;
    // ------------------------------------------------------------------------
    // UI stuff
    private var confirmPopup: CModUiActionConfirmation;
    private var quitConfirmCallback: CRadUiPopupCallback;
    // ------------------------------------------------------------------------
    private var globalHotKeyMode: bool;
    // ------------------------------------------------------------------------
    // the real stuff
    private var layerManager: CRadishQuestLayerManager;
    private var communityManager: CRadishCommunityManager;
    private var navMeshManager: CRadishNavMeshManager;
    private var theVisualizer: CRadishProxyVisualizer;
    private var currentMode: CRadishWorkMode;
    private var modeCallback: CRadUiRootModeCallback;
    // ------------------------------------------------------------------------
    private var cameraTracker: CRadishTracker;
    // ------------------------------------------------------------------------
    // global cam shared for all managers
    private var theCam: CRadishStaticCamera;
    // ------------------------------------------------------------------------
    private var jobtreeAnimSeqProvider: JobTreeAnimSequenceProvider;
    // ------------------------------------------------------------------------
    private var configManager: CRadishQuestConfigManager;
    // ------------------------------------------------------------------------
    public function init(
        log: CModLogger, configManager: CRadishQuestConfigManager, questId: String, quitConfirmCallback: CRadUiPopupCallback)
    {
        var stateData: CRadishQuestStateData;

        GetWitcherPlayer().DisplayHudMessage(GetLocStringByKeyExt("RADUI_Started"));

        this.log = log;
        this.configManager = configManager;
        this.quitConfirmCallback = quitConfirmCallback;

        this.registerListeners();

        modeCallback = new CRadUiRootModeCallback in this;
        modeCallback.callback = this;

        stateData = (CRadishQuestStateData)GetModStorage().load('RadishQuestUi');


        layerManager = new CRadishQuestLayerManager in this;
        layerManager.init(this.log, questId, stateData);

        jobtreeAnimSeqProvider = new JobTreeAnimSequenceProvider in this;
        theVisualizer = new CRadishProxyVisualizer in this;
        theVisualizer.init(this.log, jobtreeAnimSeqProvider, layerManager, configManager);

        communityManager = new CRadishCommunityManager in this;
        communityManager.init(this.log, questId, stateData.communityData);

        navMeshManager = new CRadishNavMeshManager in this;
        navMeshManager.init(this.log, questId, stateData.navMeshData);

        // top level management of layers will be used as starting point
        this.initLayerMode();

        AddTimer('autoLogDefinition', this.autoLogInterval, true, , , , true);
    }
    // ------------------------------------------------------------------------
    private function initLayerMode() {
        currentMode = new CRadishQuestLayerMode in this;
        ((CRadishQuestLayerMode)currentMode).setVisualizer(theVisualizer);

        currentMode.setParent(modeCallback);
        currentMode.init(layerManager, configManager);
        autoLogDefLayer = true;
    }
    // ------------------------------------------------------------------------
    private function initCommunityMode() {
        currentMode = new CRadishCommunityMode in this;
        ((CRadishCommunityMode)currentMode).setVisualizer(theVisualizer);

        currentMode.setParent(modeCallback);
        currentMode.init(communityManager, configManager);
        autoLogDefCommunities = true;
    }
    // ------------------------------------------------------------------------
    private function initNavMeshMode() {
        currentMode = new CRadishNavMeshMode in this;
        ((CRadishNavMeshMode)currentMode).setVisualizer(theVisualizer);

        currentMode.setParent(modeCallback);
        currentMode.init(navMeshManager, configManager);
        autoLogDefNavMeshes = true;
    }
    // ------------------------------------------------------------------------
    public function activate() {
        this.theCam = this.createStaticCamera();
        this.cameraTracker = this.createCameraTracker();

        // tracker must be attached to cam because cam position adjusts (invisible)
        // player pos on cam movement and visibility trigger position must be synced
        // with player pos
        theCam.setTracker(cameraTracker);
        theCam.activate();
        theCam.setSettings(configManager.getLastCamPosition());
        theCam.switchTo();

        // managers are "latent" activated (switching between workmodes must ensure
        // all managers can be used)
        layerManager.activate(theCam);
        communityManager.activate(theCam);
        navMeshManager.activate(theCam);
        theVisualizer.setCam(theCam);

        currentMode.activate();
        currentMode.showUi(true);
        //TODO rescan layers on activation?

        this.isRadUiActive = true;
    }
    // ------------------------------------------------------------------------
    private function createStaticCamera() : CRadishStaticCamera {
        var template: CEntityTemplate;
        var entity: CEntity;

        template = (CEntityTemplate)LoadResource("dlc\modtemplates\radishseeds\static_camera.w2ent", true);
        entity = theGame.CreateEntity(template,
            thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation());

        return (CRadishStaticCamera)entity;
    }
    // ------------------------------------------------------------------------
    private function createCameraTracker() : CRadishTracker {
        var template: CEntityTemplate;
        var entity: CEntity;

        template = (CEntityTemplate)LoadResource("dlc\modtemplates\radishseeds\radish_tracker.w2ent", true);
        entity = theGame.CreateEntity(template,
            thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation());

        return (CRadishTracker)entity;
    }
    // ------------------------------------------------------------------------
    public function deactivate(optional destroyProxies: bool) {
        //TODO despawning in entities?
        var proxies: array<CEntity>;
        var i, s: int;

        this.isRadUiActive = false;
        currentMode.showUi(false);

        if (destroyProxies) {
            theGame.GetEntitiesByTag('RADUI', proxies);
            s = proxies.Size();
            for (i = 0; i < s; i += 1) {
                proxies[i].StopAllEffects();
                proxies[i].Destroy();
            }
        }

        layerManager.deactivate();
        communityManager.deactivate();
        navMeshManager.deactivate();

        this.cameraTracker.stop();
        this.cameraTracker.Destroy();
        theCam.deactivate();
        theCam.Destroy();
    }
    // ------------------------------------------------------------------------
    timer function autoLogDefinition(deltaTime: float, id: int) {
        var modeid: CName;

        if (autoLogDefLayer || autoLogDefCommunities || autoLogDefNavMeshes || isRadUiActive) {
            this.log.info("auto-saving definitions to scriptlog...");
        }

        // TODO add check for last time updated? (must include *any* change in layerentities!)

        // save flag is only set on mode *change*. if radui is maximized the
        // last mode is only *activated* so the flag may not be set
        // -> always consider saving current mode
        modeid = currentMode.getId();

        if (autoLogDefLayer || (isRadUiActive && modeid == 'RADUI_ModeLayers')) {
            layerManager.logDefinition(true);
        }
        if (autoLogDefCommunities || (isRadUiActive && modeid == 'RADUI_ModeCommunities')) {
            communityManager.logDefinition(true);
        }
        if (autoLogDefNavMeshes || (isRadUiActive && modeid == 'RADUI_ModeNavMeshes')) {
            navMeshManager.logDefinition(true);
        }

        if (autoLogDefLayer || autoLogDefCommunities || autoLogDefNavMeshes || isRadUiActive) {
            theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt("RADUI_iAutoDefinitionLogged"));
            autoLogDefLayer = false;
            autoLogDefCommunities = false;
            autoLogDefNavMeshes = false;
        }
    }
    // ------------------------------------------------------------------------
    public function doQuit() {
        RemoveTimer('autoLogDefinition');

        configManager.setLastCamPosition(layerManager.getCam().getSettings());
        GetModStorage().save(layerManager.getState());
        GetModStorage().save(configManager.getConfig());

        layerManager.logDefinition();
        communityManager.logDefinition();
        navMeshManager.logDefinition();

        unregisterListeners();
        // to prevent problems with wrongly restored state use this hardcoded
        // "safe" value
        theInput.SetContext('Exploration');

        deactivate(true);
        GetWitcherPlayer().DisplayHudMessage(GetLocStringByKeyExt("RADUI_Stopped"));
    }
    // ------------------------------------------------------------------------
    public function quitRequest() {
        var msgTitle: String;
        var msgText: String;

        //SetIgnoreInput(true);
        if (confirmPopup) { delete confirmPopup; }

        confirmPopup = new CModUiActionConfirmation in this;
        msgTitle = "RADUI_tQuitConfirm";
        msgText = "RADUI_mQuitConfirm";

        confirmPopup.open(quitConfirmCallback,
            GetLocStringByKeyExt(msgTitle),
            GetLocStringByKeyExt(msgText), "quit");
    }
    // ------------------------------------------------------------------------
    event OnHelpMePrettyPlease(action: SInputAction) {
        var helpPopup: CModUiHotkeyHelp;
        var titleKey: String;
        var introText: String;
        var hotkeyList: array<SModUiHotkeyHelp>;

        if (IsPressed(action)) {
            helpPopup = new CModUiHotkeyHelp in this;

            titleKey = "RADUI_tHelpHotkey";
            introText = "<p align=\"left\">" + GetLocStringByKeyExt("RADUI_mHelpCurrentWorkmode") + " " + currentMode.getStateName() + "</p>";
            introText += "<p>" + currentMode.getGeneralHelp() + "</p>";

            currentMode.OnHotkeyHelp(hotkeyList);

            // QUIT is only available in overview mode!
            if (currentMode.getId() == 'RADUI_ModeLayers') {
                hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleFoliage'));
                hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleWater'));
                hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleTerrain', 'RAD_ToggleTerrain', IK_RControl, IK_F11));

                hotkeyList.PushBack(HotkeyHelp_from('RADUI_ModeCommunities', 'RADUI_SwitchToCommunityMode', IK_RControl, IK_2));
                hotkeyList.PushBack(HotkeyHelp_from('RADUI_ModeNavMeshes', 'RADUI_SwitchToNavmeshMode', IK_RControl, IK_3));
                hotkeyList.PushBack(HotkeyHelp_from('RADUI_Quit'));
            }
            if (currentMode.getId() == 'RADUI_ModeCommunities') {
                hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleFoliage'));
                hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleWater'));
                hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleTerrain', 'RAD_ToggleTerrain', IK_RControl, IK_F11));

                hotkeyList.PushBack(HotkeyHelp_from('RADUI_ModeLayers', 'RADUI_SwitchToLayerMode', IK_RControl, IK_1));
                hotkeyList.PushBack(HotkeyHelp_from('RADUI_ModeNavMeshes', 'RADUI_SwitchToNavmeshMode', IK_RControl, IK_3));
                hotkeyList.PushBack(HotkeyHelp_from('RADUI_Quit'));
            }
            if (currentMode.getId() == 'RADUI_ModeNavMeshes') {
                hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleFoliage'));
                hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleWater'));
                hotkeyList.PushBack(HotkeyHelp_from('RAD_ToggleTerrain', 'RAD_ToggleTerrain', IK_RControl, IK_F11));

                hotkeyList.PushBack(HotkeyHelp_from('RADUI_ModeLayers', 'RADUI_SwitchToLayerMode', IK_RControl, IK_1));
                hotkeyList.PushBack(HotkeyHelp_from('RADUI_ModeCommunities', 'RADUI_SwitchToCommunityMode', IK_RControl, IK_2));
                hotkeyList.PushBack(HotkeyHelp_from('RADUI_Quit'));
            }
            hotkeyList.PushBack(HotkeyHelp_from('RADUI_ShowHelp'));

            helpPopup.open(titleKey, introText, hotkeyList);
        }
    }
    // ------------------------------------------------------------------------
    public function doChangeWorkMode(workMode: CName) {
        var lastMode: String;
        lastMode = currentMode.getId();

        currentMode.deactivate();
        delete currentMode;

        if (workMode == 'RADUI_BackToTop') {
            if (lastMode == "RADUI_ModeCommunities") {
                workMode = 'RADUI_ModeCommunities';
            } else if (lastMode == "RADUI_ModeNavMeshes") {
                workMode = 'RADUI_ModeNavMeshes';
            } else {
                workMode = 'RADUI_ModeLayers';
            }
        }

        switch (workMode) {
            case 'RADUI_ModeLayers': initLayerMode(); break;
            case 'RADUI_QL_ModeEntitySearch':
                currentMode = new CRadishQuestLayerSearchMode in this;
                currentMode.init(layerManager, configManager);
                break;
            case 'RADUI_ModeCommunities': initCommunityMode(); break;
            case 'RADUI_ModeNavMeshes': initNavMeshMode(); break;
            //TODO global setttings
            default:
                theGame.GetGuiManager().ShowNotification(
                    GetLocStringByKeyExt("RADUI_eUnknownWorkmode") + workMode);
                log.error("tried to change into unknown Workmode: " + workMode);
                // fallback to layermode
                initLayerMode();
        }
        currentMode.setParent(modeCallback);
        currentMode.activate();
    }
    // ------------------------------------------------------------------------
    event OnChangeWorkMode(action: SInputAction) {
        if (IsReleased(action) && action.aName != 'RADUI_Back' && currentMode.getId() != action.aName) {
            // top level work mode changes. current work mode must cleanup if it
            // has subviews and confirm successfull "leaving"

            doChangeWorkMode(action.aName);
        }
    }
    // ------------------------------------------------------------------------
    event OnGlobalModifier(action: SInputAction) {
        if (IsPressed(action)) {
            globalHotKeyMode = true;
            // make sure submodes don't catch any hotkeys
            currentMode.pause();
        } else if (IsReleased(action)) {
            globalHotKeyMode = false;
            currentMode.unpause();
        }
    }
    // ------------------------------------------------------------------------
    event OnSwitchGlobalMode(action: SInputAction) {
        if (globalHotKeyMode && IsReleased(action)) {
            OnChangeWorkMode(action);
        }
    }
    // ------------------------------------------------------------------------
    event OnToggleFoliage(action: SInputAction) {
        if (IsPressed(action)) {
            cameraTracker.toggleFoliageVisibilityWithInfo();
        }
    }
    // ------------------------------------------------------------------------
    event OnToggleWater(action: SInputAction) {
        if (!globalHotKeyMode && IsPressed(action)) {
            cameraTracker.toggleWaterVisibilityWithInfo();
        }
    }
    // ------------------------------------------------------------------------
    event OnToggleTerrain(action: SInputAction) {
        if (globalHotKeyMode && IsReleased(action)) {
            cameraTracker.toggleTerrainVisibilityWithInfo();
        }
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        // -- generic hotkeys
        theInput.RegisterListener(this, 'OnHelpMePrettyPlease', 'RADUI_ShowHelp');
        theInput.RegisterListener(this, 'OnToggleFoliage', 'RAD_ToggleFoliage');
        theInput.RegisterListener(this, 'OnToggleWater', 'RAD_ToggleWater');
        theInput.RegisterListener(this, 'OnToggleTerrain', 'RAD_ToggleTerrain');

        // -- supported workmodes
        theInput.RegisterListener(this, 'OnChangeWorkMode', 'RADUI_BackToTop');
        theInput.RegisterListener(this, 'OnChangeWorkMode', 'RADUI_QL_ModeEntitySearch');

        theInput.RegisterListener(this, 'OnGlobalModifier', 'RADUI_ToggleGlobalModifier');
        theInput.RegisterListener(this, 'OnSwitchGlobalMode', 'RADUI_ModeLayers');
        theInput.RegisterListener(this, 'OnSwitchGlobalMode', 'RADUI_ModeCommunities');
        theInput.RegisterListener(this, 'OnSwitchGlobalMode', 'RADUI_ModeNavMeshes');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        // -- generic hotkeys
        theInput.UnregisterListener(this, 'RADUI_ShowHelp');
        theInput.UnregisterListener(this, 'RAD_ToggleFoliage');
        theInput.UnregisterListener(this, 'RAD_ToggleWater');
        theInput.UnregisterListener(this, 'RAD_ToggleTerrain');

        // -- supported workmodes
        theInput.UnregisterListener(this, 'RADUI_BackToTop');
        theInput.UnregisterListener(this, 'RADUI_QL_ModeEntitySearch');

        theInput.UnregisterListener(this, 'RADUI_ToggleGlobalModifier');
        theInput.UnregisterListener(this, 'RADUI_ModeLayers');
        theInput.UnregisterListener(this, 'RADUI_ModeCommunities');
        theInput.UnregisterListener(this, 'RADUI_ModeNavMeshes');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
function modCreate_RadishUi() : CRadishQuestUiMod {
    return new CRadishQuestUiMod in thePlayer;
}
// ----------------------------------------------------------------------------
exec function radishui_clear_saved() {
    GetModStorage().remove('RadishQuestUi');
    theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt("RADUI_LayersDeleted"));
}
// ----------------------------------------------------------------------------
