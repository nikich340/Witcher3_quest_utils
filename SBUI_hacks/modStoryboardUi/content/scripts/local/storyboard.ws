// ----------------------------------------------------------------------------
class CModStoryBoard {
    private var log: CModLogger;

    // visualizes the currently selected elements
    private var shotViewer: CModStoryBoardShotViewer;
    private var assetManager: CModStoryBoardAssetManager;
    private var idlePoseListsManager: CModStoryBoardIdlePoseListsManager;
    private var animListsManager: CModStoryBoardAnimationListsManager;
    private var mimicsListsManager: CModStoryBoardMimicsListsManager;
    private var voiceLinesListsManager: CModStoryBoardVoiceLinesListsManager;
    private var shots: array<CModStoryBoardShot>;
    private var currentShotSlot: int;
    // ------------------------------------------------------------------------
    private function createShotViewer() : CModStoryBoardShotViewer {
        var ent : CEntity;
        var template : CEntityTemplate;

        // shotview is entity to get timer functionality
        template = (CEntityTemplate)LoadResource("dlc\modtemplates\storyboardui\shotviewer.w2ent", true);

        return (CModStoryBoardShotViewer) theGame.CreateEntity(
            template, thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation());
    }
    // ------------------------------------------------------------------------
    public function init(log: CModLogger, statedata: CModStoryBoardStateData) {
        // default is current player position
        var origin: SStoryBoardOriginStateData = SStoryBoardOriginStateData(
            // marker tag to indicate it should be autoselected on w2scene dump
            "-",
            thePlayer.GetWorldPosition(),
            thePlayer.GetWorldRotation()
        );
        var i: int;

        this.log = log;
        // hide the player entity as a clone will be used to prevent special
        // cases all around
        hidePlayer();

        assetManager = new CModStoryBoardAssetManager in this;
        assetManager.init(statedata.assetData);

        idlePoseListsManager = new CModStoryBoardIdlePoseListsManager in this;
        animListsManager = new CModStoryBoardAnimationListsManager in this;
        mimicsListsManager = new CModStoryBoardMimicsListsManager in this;
        voiceLinesListsManager = new CModStoryBoardVoiceLinesListsManager in this;

        shotViewer = createShotViewer();
        shotViewer.init(
            assetManager,
            idlePoseListsManager,
            animListsManager, mimicsListsManager,
            voiceLinesListsManager);

        if (statedata.shotData.Size() > 0) {
            log.debug("init from save ("
                + IntToString(statedata.shotData.Size()) + " shots)");

            origin = statedata.origin;

            for (i = 0; i < statedata.shotData.Size(); i += 1) {
                restoreShot(statedata.shotData[i]);
            }
        } else {
            // create first empty shot
            addNewShot();
        }
        // refresh placement in case of statedata provided origin
        shotViewer.getPlacementDirector().setOrigin(origin, true);
    }
    // ------------------------------------------------------------------------
    public function getState() : CModStoryBoardStateData {
        var statedata: CModStoryBoardStateData = new CModStoryBoardStateData in this;
        var i: int;

        statedata.origin = shotViewer.getPlacementDirector().getOrigin();
        statedata.assetData = assetManager.getState();

        for (i = 0; i < shots.Size(); i += 1) {
            statedata.shotData.PushBack(shots[i].getState());
        }

        return statedata;
    }
    // ------------------------------------------------------------------------
    public function activate() {
        shotViewer.activate();
        shotViewer.displayShot(this.shots[currentShotSlot]);
    }
    // ------------------------------------------------------------------------
    public function repositionOrigin(originPos: Vector, originRot: EulerAngles)
    {
        shotViewer.getPlacementDirector().setOrigin(
            SStoryBoardOriginStateData("USERDEFINED", originPos, originRot), true);
    }
    // ------------------------------------------------------------------------
    private function hidePlayer() {
        thePlayer.EnableCharacterCollisions(false);
        thePlayer.SetVisibility(false);

        // stop sbui from ever breaking by wandering enemies spotting the player
        thePlayer.SetTemporaryAttitudeGroup( 'q104_avallach_friendly_to_all', AGP_Default );
    }
    // ------------------------------------------------------------------------
    private function restorePlayer() {
        thePlayer.SetVisibility(true);
        thePlayer.EnableCharacterCollisions(true);

        // reset player attitude
        thePlayer.ResetTemporaryAttitudeGroup(AGP_Default);
    }
    // ------------------------------------------------------------------------
    public function reset() {
        shotViewer.reset();
        assetManager.reset();

        // show "real" player again
        restorePlayer();

        delete shotViewer;
    }
    // ------------------------------------------------------------------------
    public function getShotViewer() : CModStoryBoardShotViewer {
        return shotViewer;
    }
    // ------------------------------------------------------------------------
    public function getAssetManager() : CModStoryBoardAssetManager {
        return assetManager;
    }
    // ------------------------------------------------------------------------
    public function getIdlePoseListsManager() : CModStoryBoardIdlePoseListsManager
    {
        return idlePoseListsManager;
    }
    // ------------------------------------------------------------------------
    public function getAnimationListsManager() : CModStoryBoardAnimationListsManager
    {
        return animListsManager;
    }
    // ------------------------------------------------------------------------
    public function getMimicsListsManager() : CModStoryBoardMimicsListsManager
    {
        return mimicsListsManager;
    }
    // ------------------------------------------------------------------------
    public function getVoiceLinesListsManager() : CModStoryBoardVoiceLinesListsManager
    {
        return voiceLinesListsManager;
    }
    // ------------------------------------------------------------------------
    public function hasUnsavedChanges() : bool {
        // only the current shot can have unsaved changes (before creating new
        // shots or selecting other changes are stored or resetted)
        return getCurrentShot().hasUnsavedChanges();
    }
    // ------------------------------------------------------------------------
    public function getCurrentShot() : CModStoryBoardShot {
        return shots[currentShotSlot];
    }
    // ------------------------------------------------------------------------
    private function restoreShot(data: SStoryBoardShotStateData) {
        var newShot: CModStoryBoardShot;
        newShot = new CModStoryBoardShot in this;

        newShot.init(data);

        this.shots.PushBack(newShot);
    }
    // ------------------------------------------------------------------------
    public function addNewShot() : bool {
        var currentShot: CModStoryBoardShot;
        var newShot: CModStoryBoardShot;

        currentShot = getCurrentShot();
        newShot = new CModStoryBoardShot in this;

        if (currentShot) {
            newShot.cloneFrom(currentShot);
        } else {
            newShot.init();
        }

        this.shots.PushBack(newShot);

        selectShot(this.shots.Size() - 1);

        // operation always successfull
        return true;
    }
    // ------------------------------------------------------------------------
    public function deleteCurrentShot() : bool {
        var slot: int;

        if (shots.Size() > 1) {
            slot = currentShotSlot;

            shots.Remove(getCurrentShot());

            // update current shot selection to "next" shot
            if (slot >= shots.Size()) {
                currentShotSlot = shots.Size() - 1;
            }
            refreshViewer();
            return true;
        }
        return false;
    }
    // ------------------------------------------------------------------------
    public function selectShot(shotId: int) : bool {
        // precondition: no unsaved settings in currentShot!
        if (shotId != currentShotSlot && shotId >= 0 && shotId < shots.Size()) {
            currentShotSlot = shotId;

            refreshViewer();
            return true;
        }
        // no change
        return false;
    }
    // ------------------------------------------------------------------------
    public function storeCurrentAssetSettingsIn(targetShot: CModStoryBoardShot) {
        var settings: array<SStoryBoardShotAssetSettings>;
        var assets: array<CModStoryBoardAsset>;
        var i: int;

        assets = assetManager.getAssets();

        for (i = 0; i < assets.Size(); i += 1) {
            settings.PushBack(assets[i].getShotSettings());
        }

        targetShot.setAssetSettings(settings);
    }
    // ------------------------------------------------------------------------
    public function onDeleteAsset(assetId: String) {
        var i: int;

        // remove all invalid settings from all shots
        for (i = 0; i < shots.Size(); i += 1) {
            shots[i].onDeleteAsset(assetId);
        }
    }
    // ------------------------------------------------------------------------
    public function refreshViewer() {
        shotViewer.displayShot(this.shots[currentShotSlot]);
    }
    // ------------------------------------------------------------------------
    public function getShotList() : array<SModUiListItem> {
        var shotList: array<SModUiListItem>;
        var i: int;
        var marker: String;

        for (i = 0; i < shots.Size(); i+=1) {
            shotList.PushBack(SModUiListItem(
                i, shots[i].getName(), i == currentShotSlot, IntToString(i + 1) + ". "
            ));
        }
        return shotList;
    }
    // ------------------------------------------------------------------------
    public function getShotCount() : int {
        return shots.Size();
    }
    // ------------------------------------------------------------------------
    public function selectNextShot() {
        if (currentShotSlot < shots.Size() - 1) {
            selectShot(currentShotSlot + 1);
        } else {
            selectShot(0);
        }
    }
    // ------------------------------------------------------------------------
    public function selectPrevShot() {
        if (currentShotSlot > 0) {
            selectShot(currentShotSlot - 1);
        } else {
            selectShot(shots.Size() - 1);
        }
    }
    // ------------------------------------------------------------------------
    private function swapSelectedShot(targetPos: int) {
        var swapShot: CModStoryBoardShot = shots[targetPos];

        shots[targetPos] = shots[currentShotSlot];
        shots[currentShotSlot] = swapShot;

        currentShotSlot = targetPos;
    }
    // ------------------------------------------------------------------------
    public function moveUpShot() {
        swapSelectedShot((shots.Size() + currentShotSlot - 1) % shots.Size());
    }
    // ------------------------------------------------------------------------
    public function moveDownShot() {
        swapSelectedShot((currentShotSlot + 1) % shots.Size());
    }
    // ------------------------------------------------------------------------
    public function saveW2SceneDescripton() {
        var creator: CModStoryBoardW2SceneDescrCreator;

        creator = new CModStoryBoardW2SceneDescrCreator in this;

        creator.init(
            idlePoseListsManager,
            animListsManager,
            mimicsListsManager,
            voiceLinesListsManager,
            shotViewer.getPlacementDirector(),
            shotViewer.getLookAtDirector());

        creator.create(assetManager.getAssets(), shots);

        // creater need to set some settings for assets to extract correct data
        // -> make sure those won't get saved into the shotsettings by leaving
        // current workmode!
        refreshViewer();
    }
    // ------------------------------------------------------------------------
    public function resetScene() {
        while (deleteCurrentShot()) {
            // just delete
        }
        getCurrentShot().init();

        assetManager.reinit();
        storeCurrentAssetSettingsIn(getCurrentShot());

        shotViewer.getPlacementDirector().setOrigin(SStoryBoardOriginStateData(
            // marker tag to indicate it should be autoselected on w2scene dump
            "-",
            thePlayer.GetWorldPosition(),
            thePlayer.GetWorldRotation()
        ), true);
        refreshViewer();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
