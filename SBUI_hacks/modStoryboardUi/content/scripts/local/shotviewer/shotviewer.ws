// -----------------------------------------------------------------------------
//
// BUGS:
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
statemachine class CModStoryBoardShotViewer extends CEntity {
    private var log: CModLogger;
    // ------------------------------------------------------------------------
    // static cam which will be used to switch between shots, only
    private var theShotCam: CStoryBoardShotCamera;

    // manages actors + items & their spawning
    private var assetManager: CModStoryBoardAssetManager;

    // manages filtering of compatible animations and their selection/preview
    private var animListsManager: CModStoryBoardAnimationListsManager;
    private var mimicsListsManager: CModStoryBoardMimicsListsManager;
    private var voiceLinesListsManager: CModStoryBoardVoiceLinesListsManager;

    private var poseListManager: CModStoryBoardIdlePoseListsManager;

    // manages placing of all assets according to shot settings
    private var thePlacementDirector: CModStoryBoardPlacementDirector;

    // manages starting / stoping of shot animations for one/all actors according
    // to shot settings
    private var theAnimDirector: CModStoryBoardAnimationDirector;

    // manages re/setting lookats for one/all actors according to shot settings
    private var theLookAtDirector: CModStoryBoardLookAtDirector;

    // manages playback of voicelines
    private var theAudioDirector: CModStoryBoardAudioDirector;
    // ------------------------------------------------------------------------
    public function init(
        assetMgr: CModStoryBoardAssetManager,
        poseListMgr: CModStoryBoardIdlePoseListsManager,
        animListMgr: CModStoryBoardAnimationListsManager,
        mimicsListMgr: CModStoryBoardMimicsListsManager,
        voiceListMgr: CModStoryBoardVoiceLinesListsManager)
    {
        log = new CModLogger in this;
        log.init('StoryBoardShotViewer', MLOG_DEBUG);
        log.debug("initialized");

        thePlacementDirector = new CModStoryBoardPlacementDirector in this;
        theAnimDirector = new CModStoryBoardAnimationDirector in this;
        theLookAtDirector = new CModStoryBoardLookAtDirector in this;
        theAudioDirector = new CModStoryBoardAudioDirector in this;

        poseListManager = poseListMgr;
        poseListManager.init();
        animListsManager = animListMgr;
        animListsManager.init();
        mimicsListsManager = mimicsListMgr;
        mimicsListsManager.init();
        voiceLinesListsManager = voiceListMgr;
        voiceLinesListsManager.init();

        assetManager = assetMgr;
        assetManager.initDirectors(
            thePlacementDirector,
            theAnimDirector,
            theLookAtDirector,
            theAudioDirector);

        // setup the shot cam but do not start yet
        setupShotCam();
    }
    // ------------------------------------------------------------------------
    private function setupShotCam() {
        var template: CEntityTemplate;
        var entity: CEntity;

        template = (CEntityTemplate)LoadResource("dlc\modtemplates\storyboardui\shotcamera.w2ent", true);
        entity = theGame.CreateEntity(template,
            thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation());

        theShotCam = (CStoryBoardShotCamera)entity;
    }
    // ------------------------------------------------------------------------
    public function activate() {
        // preparation of the viewer to display shots
        theShotCam.activate();

        //hotkey; toggle animation pause (?)
    }
    // ------------------------------------------------------------------------
    private function setAssetShotSettings(shot: CModStoryBoardShot) {
        var assetSettings: array<SStoryBoardShotAssetSettings>;
        var assets: array<CModStoryBoardAsset>;
        var assetId: String;
        var i, s: int;
        var hasSettings: bool;

        assetSettings = shot.getAssetSettings();
        assets = assetManager.getAssets();

        // O(n*m)
        for (i = 0; i < assets.Size(); i += 1) {
            assetId = assets[i].getId();

            hasSettings = false;
            for (s = 0; s < assetSettings.Size(); s += 1) {
                if (assetSettings[s].assetId == assetId) {
                    assets[i].setShotSettings(assetSettings[s]);
                    hasSettings = true;
                    break;
                }
            }
            if (!hasSettings) {
                // create default settings
                assets[i].setShotSettings();
            }
        }
    }
    // ------------------------------------------------------------------------
    public function displayShot(newShot: CModStoryBoardShot) {
        theShotCam.setSettings(newShot.getCameraSettings());

        // before setting new placement stop all animations
        theAnimDirector.stopAnimations();
        theAudioDirector.stopAudio();

        // (asset) settings for current shot must be injected into the assets
        // so the following "settings handler" *may* query asset for its settings
        // and workmodes *may* use those settings to update things, e.g. placement
        // until saving on workmode exit
        setAssetShotSettings(newShot);

        // placement director already knows all assets
        thePlacementDirector.refreshPlacement();

        theShotCam.switchTo();

        theAnimDirector.startShotAnimations();
        theLookAtDirector.startShotLookAts();
        theAudioDirector.startShotPlayback();
    }
    // ------------------------------------------------------------------------
    // temporaery switch for "special" workmode cameras
    public function switchCamTo(settings: SStoryBoardCameraSettings) {
        theShotCam.switchTo(settings);
    }
    // ------------------------------------------------------------------------
    public function restoreShotCam() {
        theShotCam.switchTo();
    }
    // ------------------------------------------------------------------------
    public function reset() {
        log.debug("reset");
        // TODO proper way to destroy/remove the cam?
        theShotCam.deactivate();
        theShotCam.Destroy();

        theLookAtDirector.deactivate();

        RemoveTimers();
        Destroy();
    }
    // ------------------------------------------------------------------------
    public function getPlacementDirector() : CModStoryBoardPlacementDirector {
        return thePlacementDirector;
    }
    // ------------------------------------------------------------------------
    public function getAnimationDirector() : CModStoryBoardAnimationDirector {
        return theAnimDirector;
    }
    // ------------------------------------------------------------------------
    public function getLookAtDirector() : CModStoryBoardLookAtDirector {
        return theLookAtDirector;
    }
    // ------------------------------------------------------------------------
    public function getAudioDirector() : CModStoryBoardAudioDirector {
        return theAudioDirector;
    }
    // ------------------------------------------------------------------------
    public function getCameraHeading() : float {
        return theShotCam.GetHeading();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
