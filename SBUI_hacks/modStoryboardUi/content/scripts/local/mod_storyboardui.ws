// -----------------------------------------------------------------------------
//
// BUGS:
//
// TODO:
//  - add generic hotkey "i" for info about currently selected shot,
//      selected asset, selected camera (special/shot), ...?
//
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
class CModSbUiPopupCallback extends IModUiConfirmPopupCallback {
    public var callback: CModStoryBoardUi;

    public function OnConfirmed(action: String) {
        switch (action) {
            case "quit": return callback.doQuit();
        }
    }
}
// ----------------------------------------------------------------------------
class CModStoryBoardUi extends CMod {
    default modName = 'StoryBoardUi';
    default modAuthor = "rmemr, erxv";
    default modUrl = "http://www.nexusmods.com/witcher3/mods/2114/";
    default modVersion = '0.7.3';

    default logLevel = MLOG_DEBUG;
    // ------------------------------------------------------------------------
    private var sceneId: CName;
	private var sceneTag: CName;
    // ------------------------------------------------------------------------
    // UI stuff
    private var confirmPopup: CModUiActionConfirmation;
    private var viewCallback: CModSbUiPopupCallback;
    // ------------------------------------------------------------------------
    // the real stuff
    private var storyboard: CModStoryBoard;
    private var currentMode: CModStoryBoardWorkMode;
    private var modeCallback: CModSbUiParentCallback;
    // ------------------------------------------------------------------------
    // some settings need to be tweaked while in storyboard
    // save original values
    private var hudModules: array<CName>;
    private var hudModulesEnabled: array<bool>;
    private var hoursPerMinute: float;
    // ------------------------------------------------------------------------
    public function init() {
        super.init();

        this.registerListeners();

        modeCallback = new CModSbUiParentCallback in this;
        modeCallback.callback = this;

        storyboard = new CModStoryBoard in this;

        storyboard.init(this.log, (CModStoryBoardStateData)GetModStorage().load(modName, sceneId));

        // top level management of shots will be used as starting point
        currentMode = new CModStoryBoardOverviewMode in this;
        currentMode.setParent(modeCallback);
        currentMode.init(storyboard);

        // prepare view callback wiring
        viewCallback = new CModSbUiPopupCallback in this;
        viewCallback.callback = this;

        deactivateHud();
    }
    // ------------------------------------------------------------------------
    public function initWithSceneId(id: CName) {
        this.sceneId = id;
        this.init();
    }
    // ------------------------------------------------------------------------
    public function activate() {
        GetWitcherPlayer().DisplayHudMessage(GetLocStringByKeyExt("SBUI_Started"));

        hoursPerMinute = theGame.GetHoursPerMinute();
        theGame.SetHoursPerMinute(0);

        storyboard.activate();

        ((CModStoryBoardOverviewMode)currentMode).activateDeferred(storyboard.getCurrentShot());
    }
    // ------------------------------------------------------------------------
    public function repositionOrigin(originPos: Vector, originRot: EulerAngles) {
        storyboard.repositionOrigin(originPos, originRot);
        GetWitcherPlayer().DisplayHudMessage(
            GetLocStringByKeyExt("SBUI_OriginOverwrite")
            + VecToString(originPos));
    }
    // ------------------------------------------------------------------------
    private function deactivateHud() {
        var hud: CR4ScriptedHud;
        var hudModule: CR4HudModuleBase;
        var i: int;

        // collect all hud modules to disable
        hud = (CR4ScriptedHud)theGame.GetHud();
        hudModules = hud.hudModulesNames;

        for (i = 0; i < hudModules.Size(); i += 1) {
            hudModule = (CR4HudModuleBase)hud.GetHudModule(hudModules[i]);
            hudModulesEnabled.PushBack(hudModule.GetEnabled());

            // message module required for some info output
            if (hudModules[i] != 'MessageModule') {
                hudModule.SetEnabled(false);
            }
        }
    }
    // ------------------------------------------------------------------------
    private function reactivateHud() {
        var hud: CR4ScriptedHud;
        var hudModule: CR4HudModuleBase;
        var i: int;

        hud = (CR4ScriptedHud)theGame.GetHud();
        for (i = 0; i < hudModules.Size(); i += 1) {
            hudModule = (CR4HudModuleBase)hud.GetHudModule(hudModules[i]);
            hudModule.SetEnabled(hudModulesEnabled[i]);
        }
    }
    // ------------------------------------------------------------------------
    private function deactivate() {
        storyboard.reset();
        reactivateHud();
        theGame.SetHoursPerMinute(hoursPerMinute);

        GetWitcherPlayer().DisplayHudMessage(GetLocStringByKeyExt("SBUI_Stopped"));
    }
    // ------------------------------------------------------------------------
    public function doQuit() {
        var sbuiState: CModStoryBoardStateData;

        sbuiState = storyboard.getState();
        sbuiState.containerId = sceneId;

        GetModStorage().save(sbuiState);
        storyboard.saveW2SceneDescripton();

        unregisterListeners();
        // to prevent problems with wrongly restored state use this hardcoded
        // "safe" value
        theInput.SetContext('Exploration');

        deactivate();
    }
	// ------------------------------------------------------------------------
	public function setSceneTag(tag : CName) {
        this.sceneTag = tag;
    }
    // ------------------------------------------------------------------------
    event OnQuitRequest() {
        var msgTitle: String;
        var msgText: String;

        //SetIgnoreInput(true);
        if (confirmPopup) { delete confirmPopup; }

        confirmPopup = new CModUiActionConfirmation in this;

        if (storyboard.hasUnsavedChanges()) {
            msgTitle = "SBUI_tQuitConfirmUnsaved";
            msgText = "SBUI_mQuitConfirmUnsaved";
        } else {
            msgTitle = "SBUI_tQuitConfirm";
            msgText = "SBUI_mQuitConfirm";
        }
        confirmPopup.open(viewCallback,
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

            titleKey = "SBUI_tHelpHotkey";
            introText = "<p align=\"left\">" + GetLocStringByKeyExt("SBUI_mHelpCurrentWorkmode") + currentMode.getName() + "</p>";
            introText += "<p>" + currentMode.getGeneralHelp() + "</p>";

            // this must be available all the time
            hotkeyList.PushBack(HotkeyHelp_from('SBUI_ShowHelp'));
            // QUIT is only available in overview mode!
            if (currentMode.getId() == 'SBUI_ModeOverview') {
                hotkeyList.PushBack(HotkeyHelp_from('SBUI_Quit'));
            }
            // TODO remove currentMode from Hotkeylist?
            hotkeyList.PushBack(HotkeyHelp_from('SBUI_ModeOverview'));
            hotkeyList.PushBack(HotkeyHelp_from('SBUI_ModeAssets'));
            hotkeyList.PushBack(HotkeyHelp_from('SBUI_ModeCamera'));
            hotkeyList.PushBack(HotkeyHelp_from('SBUI_ModePlacement'));
            hotkeyList.PushBack(HotkeyHelp_from('SBUI_ModeAnimation'));
            hotkeyList.PushBack(HotkeyHelp_from('SBUI_ModeMimics'));
            hotkeyList.PushBack(HotkeyHelp_from('SBUI_ModeLookAt'));
            hotkeyList.PushBack(HotkeyHelp_from('SBUI_ModeVoiceLines'));

            currentMode.OnHotkeyHelp(hotkeyList);

            helpPopup.open(titleKey, introText, hotkeyList);
        }
    }
    // ------------------------------------------------------------------------
    public function doChangeWorkMode(workMode: CName, saveSettings: bool) {
        if (saveSettings) {
            currentMode.storeSettings();
            storyboard.refreshViewer();
        } else if (currentMode.getId() == 'SBUI_ModeCamera') {
            // camera mode uses its own camera and deactivates the shot cam
            // -> reactivate it (even if no settings changed)
            storyboard.refreshViewer();
        }

        currentMode.deactivate();
        delete currentMode;

        switch (workMode) {
            case 'SBUI_ModeOverview':
                currentMode = new CModStoryBoardOverviewMode in this;
                currentMode.init(storyboard);
                break;

            case 'SBUI_ModeAssets':
                currentMode = new CModStoryBoardAssetWorkMode in this;
                currentMode.init(storyboard);
                break;

            case 'SBUI_ModeCamera':
                currentMode = new CModStoryBoardCameraMode in this;
                currentMode.init(storyboard);
                break;

            case 'SBUI_ModePlacement':
                currentMode = new CModStoryBoardPlacementMode in this;
                currentMode.init(storyboard);
                break;

            case 'SBUI_ModeAnimation':
                currentMode = new CModStoryBoardAnimationMode in this;
                currentMode.init(storyboard);
                break;

            case 'SBUI_ModeMimics':
                currentMode = new CModStoryBoardMimicsMode in this;
                currentMode.init(storyboard);
                break;

            case 'SBUI_ModeLookAt':
                currentMode = new CModStoryBoardLookAtMode in this;
                currentMode.init(storyboard);
                break;

            case 'SBUI_ModeVoiceLines':
                currentMode = new CModStoryBoardVoiceLinesMode in this;
                currentMode.init(storyboard);
                break;
        }
        currentMode.setParent(modeCallback);
        currentMode.activate(storyboard.getCurrentShot());
    }
    // ------------------------------------------------------------------------
    event OnChangeWorkMode(action: SInputAction) {
        if (IsPressed(action) && currentMode.getId() != action.aName) {
            // top level work mode changes. current work mode must cleanup if it
            // has subviews and confirm successfull "leaving"

            //TODO cleanup request first?
            if (currentMode.hasModifiedSettings()) {
                // FIXME!!!
                doChangeWorkMode(action.aName, true);
            } else {
                doChangeWorkMode(action.aName, false);
            }
        }
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        // -- generic hotkeys
        theInput.RegisterListener(this, 'OnHelpMePrettyPlease', 'SBUI_ShowHelp');
        theInput.RegisterListener(this, 'OnQuitRequest', 'SBUI_Quit');

        // -- supported workmodes
        theInput.RegisterListener(this, 'OnChangeWorkMode', 'SBUI_ModeOverview');
        theInput.RegisterListener(this, 'OnChangeWorkMode', 'SBUI_ModeAssets');
        theInput.RegisterListener(this, 'OnChangeWorkMode', 'SBUI_ModePlacement');
        theInput.RegisterListener(this, 'OnChangeWorkMode', 'SBUI_ModeAnimation');
        theInput.RegisterListener(this, 'OnChangeWorkMode', 'SBUI_ModeCamera');
        theInput.RegisterListener(this, 'OnChangeWorkMode', 'SBUI_ModeMimics');
        theInput.RegisterListener(this, 'OnChangeWorkMode', 'SBUI_ModeLookAt');
        theInput.RegisterListener(this, 'OnChangeWorkMode', 'SBUI_ModeVoiceLines');
        //...
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        // -- generic hotkeys
        theInput.UnregisterListener(this, 'SBUI_Quit');
        theInput.UnregisterListener(this, 'SBUI_ShowHelp');

        // -- supported workmodes
        theInput.UnregisterListener(this, 'SBUI_ModeOverview');
        theInput.UnregisterListener(this, 'SBUI_ModeAssets');
        theInput.UnregisterListener(this, 'SBUI_ModePlacement');
        theInput.UnregisterListener(this, 'SBUI_ModeAnimation');
        theInput.UnregisterListener(this, 'SBUI_ModeCamera');
        theInput.UnregisterListener(this, 'SBUI_ModeMimics');
        theInput.UnregisterListener(this, 'SBUI_ModeLookAt');
        theInput.UnregisterListener(this, 'SBUI_ModeVoiceLines');
        //...
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
function modCreate_StoryBoardUi() : CModStoryBoardUi {
    return new CModStoryBoardUi in thePlayer;
}
// ----------------------------------------------------------------------------
exec function sbui(optional sceneId: CName) {
    var mod: CModStoryBoardUi;
    mod = modCreate_StoryBoardUi();

    if (sceneId) {
        mod.initWithSceneId(sceneId);
    } else {
        mod.init();
    }

    mod.activate();
}
// ----------------------------------------------------------------------------
exec function sbui_with_origin(
    x: Float, y: Float, z: Float, pitch: float, yaw: float, roll: float,
    optional sceneId: CName)
{
    var mod: CModStoryBoardUi;
    mod = modCreate_StoryBoardUi();

    if (sceneId) {
        mod.initWithSceneId(sceneId);
    } else {
        mod.init();
    }
    mod.repositionOrigin(Vector(x, y, z), EulerAngles(pitch, yaw, roll));
    mod.activate();
}
// ----------------------------------------------------------------------------
exec function sbui_with_scenepoint(tag: CName, optional sceneId: CName) {
    var scenepoint: CEntity;
    var mod: CModStoryBoardUi;
    var pos: Vector;
    var rot: EulerAngles;

    scenepoint = (CEntity)theGame.GetEntityByTag(tag);

    if (scenepoint) {
        mod = modCreate_StoryBoardUi();

        pos = scenepoint.GetWorldPosition();
        rot = scenepoint.GetWorldRotation();

		mod.setSceneTag(tag);
        if (sceneId) {
            mod.initWithSceneId(sceneId);
        } else {
            mod.init();
        }
        mod.repositionOrigin(pos, rot);
        mod.activate();
    } else {
        theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt("SBUI_ScenepointNotFound"));
    }
}
// ----------------------------------------------------------------------------
exec function sbui_list() {
    var viewCallback: CModSbUiPopupCallback;
    var infoPopup: CModUiActionConfirmation;
    var msg, id: String;
    var boardIds: array<CName>;
    var s, i: int;

    infoPopup = new CModUiActionConfirmation in thePlayer;

    boardIds = GetModStorage().listContainerIds('StoryBoardUi');
    s = boardIds.Size();

    if (s == 0) {
        msg = GetLocStringByKeyExt("SBUI_iNoStoredBoards");
    } else {
        msg = "<p align=\"left\">" + GetLocStringByKeyExt("SBUI_iFoundStoredBoards")
            + "</p></br></br><p align=\"left\"><ul>";

        for (i = 0; i < s; i += 1) {
            if (boardIds[i] != '') {
                id = boardIds[i];
            } else {
                id = "[default]";
            }
            msg += "<li>" + id + "</li>";
        }

        msg += "</ul></p>";
    }

    infoPopup.open(viewCallback, GetLocStringByKeyExt("SBUI_tStoredBoardsList"), msg, "ok");
}
// ----------------------------------------------------------------------------
function sbui_clear_storyboard(optional sceneId: CName) {
    var caption: String;

    if (sceneId){
        caption = sceneId;
    } else {
        caption = "[default]";
    }
    if (GetModStorage().remove('StoryBoardUi', sceneId)) {
        theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt("SBUI_BoardDeleted") + " " + caption);
    } else {
        theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt("SBUI_BoardNotDeleted") + " " + caption);
    }
}
// ----------------------------------------------------------------------------
exec function sbui_clear(optional sceneId: CName) {
    sbui_clear_storyboard(sceneId);
}
// ----------------------------------------------------------------------------
exec function sbui_clear_board(optional sceneId: CName) {
    sbui_clear_storyboard(sceneId);
}
// ----------------------------------------------------------------------------