// -----------------------------------------------------------------------------
//
// BUGS:
//  - renaming possible even if no asset selected (-> default select or check in OnRename)
//  - rename to "" possible
//  - CHECK: should work: hiding and showing UI does not restore an active filter in the UI
//  - coming back into the workmode should alkways reset filter
//
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// changing of template and appearances for selected actor/item
//
state SbUi_AssetEditing in CModStoryBoardAssetWorkMode extends SbUi_FilteredListSelect {

    private var asset: CModStoryBoardAsset;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        parent.view.title = GetLocStringByKeyExt("SBUI_EditAssetListTitle");
        // update fields if the menu is already open
        parent.view.listMenuRef.setTitle(parent.view.title);
        parent.view.listMenuRef.setStatsLabel(parent.view.title);

        asset = parent.assetManager.getSelectedAsset();
        listProvider = parent.assetManager.getTemplateListFor(asset);
        listProvider.setSelection(asset.getTemplatePath(), true);

        super.OnEnterState(prevStateName);
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        super.OnLeaveState(nextStateName);

        // some things may have changed and asset needs a "fresh" start
        if (asset.needsRespawn()) {
            asset.respawn();

            // start idle pose playback for actors to make sure actor is frozen
            // after playback (prevents running away of some monsters)
            if ((CModStoryBoardActor)asset) {
                parent.animDirector.startIdlePoseForActor((CModStoryBoardActor)asset);
            }
        }
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        super.OnHotkeyHelp(hotkeyList);

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_AssetAppearanceCycle'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SetAssetTemplate'));

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SelectPrev', "SBUI_SelectPrevTemplate"));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SelectNext', "SBUI_SelectNextTemplate"));
    }
    // ------------------------------------------------------------------------
    event OnCycleAppearance(action: SInputAction) {
        var appearance: String;
        if (IsPressed(action)) {
            if(theInput.GetActionValue('SBUI_AssetAppearanceCycleBack')) {
                appearance = parent.assetManager.changeAppearance(-1);
                parent.notice(GetLocStringByKeyExt("SBUI_ChangedAppearance") + appearance);
            } else {
                appearance = parent.assetManager.changeAppearance(1);
                parent.notice(GetLocStringByKeyExt("SBUI_ChangedAppearance") + appearance);
            }
        }
    }
    // ------------------------------------------------------------------------
    private function setupIdlePose(actor: CModStoryBoardActor) {
        var idleAnimId: CName = actor.getDefaultIdleAnim();

        if (idleAnimId == '') {
            idleAnimId =
                parent.idlePoseManager.getDefaultIdleAnimFor(actor);

            actor.setDefaultIdleAnim(idleAnimId);
        }

        if (idleAnimId != '') {
            parent.notice(
                GetLocStringByKeyExt("SBUI_ChangedTemplate")
                    + actor.getTemplatePath()
                    + " [" + idleAnimId + "]");

            // start idle pose playback to make sure actor is frozen after playback
            // (prevents running away of some monsters)
            parent.animDirector.startIdlePoseForActor(actor);

        } else {
            parent.error(GetLocStringByKeyExt("SBUI_ChangedTemplateNoIdle")
                + actor.getTemplatePath());
        }
    }
    // ------------------------------------------------------------------------
    event OnSelected(optionId: String) {
        var actor: CModStoryBoardActor;

        asset = parent.assetManager.getSelectedAsset();

        // do not allow changing to a player if one is already spawned
        actor = (CModStoryBoardActor)asset;
        if (actor && optionId == actor.getPlayerTemplatePath()
            && !actor.isPlayerClone()
            && parent.assetManager.isPlayerActorSpawned())
        {
            parent.error(GetLocStringByKeyExt("SBUI_eNoMultiplePlayersAllowed"));

        } else {

            if (listProvider.setSelection(optionId, true)) {
                // selection was a real item and not a category opener/closer
                asset.setTemplatePath(optionId);
                // adjust name of asset
                asset.setName(
                    ((CModSbUiEntityTemplateList)listProvider).getCaption(optionId));

                if (actor) {
                    // actor template was changed probe for compatible idle anim
                    setupIdlePose(actor);

                } else {
                    parent.notice(GetLocStringByKeyExt("SBUI_ChangedTemplate") + optionId);
                }

                // change view to see accomodate size of currently selected template
                adjustAssetCam(asset);
            }
            updateView();
        }
    }
    // ------------------------------------------------------------------------
    private entry function adjustAssetCam(asset: CModStoryBoardAsset) {
        var frames: int;

        // wait some frames (at least one!) until asset is spawned (required on
        // changing asset template)
        SleepOneFrame();
        while (frames < 30 && !asset.isMeshSizeAvailable()) {
            SleepOneFrame();
            frames += 1;
        }

        parent.shotViewer.switchCamTo(
            SBUI_createCamSettingsFor(SBUICam_AssetPreview, asset));
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();

        theInput.RegisterListener(this, 'OnCycleAppearance', 'SBUI_AssetAppearanceCycle');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();

        theInput.UnregisterListener(this, 'SBUI_AssetAppearanceCycle');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// Add/Delete/Rename/Select asset (actor/item)
// rootstate == OnBack event triggers change to Overview Mode
state SbUi_AssetManaging in CModStoryBoardAssetWorkMode extends SbUi_WorkModeRootState
{
    private var maxActors: int; default maxActors = 8;
    private var maxItems: int; default maxItems = 10;
    // alias to prevent using "parent." all the time
    private var assetManager: CModStoryBoardAssetManager;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        parent.view.title = parent.getName();
        parent.view.statsLabel = GetLocStringByKeyExt("SBUI_AssetsListTitle");
        parent.showUi(true);
        assetManager = parent.assetManager;
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        parent.OnHotkeyHelp(hotkeyList);

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_AddActor'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_AddItem'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_EditAsset'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_DeleteAsset'));

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_RenameAsset'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SetAssetAsOrigin'));

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SelectPrev'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SelectNext'));
    }
    // ------------------------------------------------------------------------
    private function addNewActor() : String {
        var actor: CModStoryBoardActor;
        var assetId: String;

        if (assetManager.getActorCount() < maxActors) {
            assetId = assetManager.addActor(assetManager.getSelectedAsset());

            // start idle pose playback to make sure actor is frozen
            // after playback (prevents running away of some monsters)
            actor = (CModStoryBoardActor)assetManager.getAsset(assetId);
            if (actor) {
                parent.animDirector.startIdlePoseForActor(actor);
            }

        } else {
            parent.error(GetLocStringByKeyExt("SBUI_eMaxActors") + maxActors);
        }
        return assetId;
    }
    // ------------------------------------------------------------------------
    private function addNewItem() : String {
        var assetId: String;
        if (assetManager.getItemsCount() < maxItems) {
            assetId = assetManager.addItem(assetManager.getSelectedAsset());
        } else {
            parent.error(GetLocStringByKeyExt("SBUI_eMaxItems") + maxItems);
        }
        return assetId;
    }
    // ------------------------------------------------------------------------
    event OnAddNewAsset(action: SInputAction) {
        var assetId: String;

        if (IsPressed(action)) {
            // create new asset with default template
            switch (action.aName) {
                case 'SBUI_AddActor': assetId = addNewActor(); break;
                case 'SBUI_AddItem': assetId = addNewItem(); break;
            }
            if (assetId != "") {
                parent.notice(GetLocStringByKeyExt(NameToString(action.aName) + "Info"));
                OnSelected(assetId);
            }
        }
    }
    // ------------------------------------------------------------------------
    event OnDeleteAsset(action: SInputAction) {
        var msgTitle: String;
        var msgText: String;
        var asset: CModStoryBoardAsset;

        if (IsPressed(action)) {

            asset = assetManager.getSelectedAsset();
            if (assetManager.isDeletable(asset)) {

                if (parent.confirmPopup) { delete parent.confirmPopup; }

                parent.confirmPopup = new CModUiActionConfirmation in this;
                msgTitle = GetLocStringByKeyExt("SBUI_tAssetConfirmPopup");
                msgText = GetLocStringByKeyExt("SBUI_mAssetDelete") + asset.getName();

                parent.confirmPopup.open(
                    parent.popupCallback, msgTitle, msgText, "deleteAsset");
            } else {
                parent.error(GetLocStringByKeyExt("SBUI_eLastAssetDelete"));
            }
        }
    }
    // ------------------------------------------------------------------------
    event OnDeleteConfirm() {
        parent.storyboard.onDeleteAsset(
                assetManager.getSelectedAsset().getId());

        assetManager.deleteSelectedAsset();
        parent.showUi(true);
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnRename(action: SInputAction) {
        if (!parent.view.listMenuRef.isEditActive() && IsPressed(action)) {

            parent.view.listMenuRef.startInputMode(
                GetLocStringByKeyExt("SBUI_lAssetRename"),
                assetManager.getSelectedAsset().getName());
        }
    }
    // ------------------------------------------------------------------------
    event OnSetAsOrigin(action: SInputAction) {
        var asset: CModStoryBoardAsset;

        if (IsPressed(action)) {
            asset = assetManager.getSelectedAsset();

            parent.shotViewer.getPlacementDirector().setOriginId(asset.getId());
            parent.notice(
                GetLocStringByKeyExt("SBUI_iAssetSetOrigin") + asset.getName());
        }
    }
    // ------------------------------------------------------------------------
    event OnEditAsset(action: SInputAction) {
        var asset: CModStoryBoardAsset;

        if (IsPressed(action)) {
            // edit only if any asset is selected
            asset = assetManager.getSelectedAsset();
            parent.PushState('SbUi_AssetEditing');
        }
    }
    // ------------------------------------------------------------------------
    event OnInputEnd(inputString: String) {
        assetManager.getSelectedAsset().setName(inputString, true);

        parent.view.listMenuRef.resetEditField();
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnInputCancel() {
        parent.notice(GetLocStringByKeyExt("UI_CanceledEdit"));

        parent.view.listMenuRef.resetEditField();
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnSelected(optionId: String) {
        assetManager.selectAsset(optionId);

        // change view to see currently selected asset
        switchToAssetCam();

        updateView();
    }
    // ------------------------------------------------------------------------
    event OnCycleSelection(action: SInputAction) {
        var assetId: String;
        if (IsPressed(action)) {
            if (action.aName == 'SBUI_SelectPrev') {
                assetId = assetManager.getPreviousAssetId();
            } else {
                assetId = assetManager.getNextAssetId();
            }
            OnSelected(assetId);
        }
    }
    // ------------------------------------------------------------------------
    event OnUpdateView() {
        // change view to see currently selected asset
        switchToAssetCam();

        updateView();
    }
    // ------------------------------------------------------------------------
    private function updateView() {
        // assets are categorized => listSize != assetcount
        // provide info to override stats info in listview
        parent.view.listMenuRef.setListData(
            assetManager.getAssetItemsList(), assetManager.getAssetCount());

        parent.view.listMenuRef.updateView();
    }
    // ------------------------------------------------------------------------
    private entry function switchToAssetCam() {
        // wait until asset is spawned (required on adding a new asset)
        SleepOneFrame();

        parent.shotViewer.switchCamTo(
            SBUI_createCamSettingsFor(
                SBUICam_AssetPreview, assetManager.getSelectedAsset())
        );
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// Ui for management of assets (actors/items) for WHOLE storyboard.
//  - adding/deleting/renaming of assets
//  - changing currently selected asset
//  - providing special toggle cam for viewing currently selected actor in full
//
statemachine class CModStoryBoardAssetWorkMode extends CModSbListViewWorkMode {
    default workMode = 'SBUI_ModeAssets';
    default workContext = 'MOD_StoryBoardUi_ModeAssets';
    default generalHelpKey = "SBUI_AssetsGeneralHelp";
    // ------------------------------------------------------------------------
    protected var storyboard: CModStoryBoard;
    protected var shotViewer: CModStoryBoardShotViewer;
    protected var assetManager: CModStoryBoardAssetManager;
    protected var idlePoseManager: CModStoryBoardIdlePoseListsManager;

    // required to start idlepose animations on new/respawned actors
    protected var animDirector: CModStoryBoardAnimationDirector;
    // ------------------------------------------------------------------------
    public function init(storyboard: CModStoryBoard) {
        super.init(storyboard);
        this.storyboard = storyboard;
        this.shotViewer = storyboard.getShotViewer();
        this.assetManager = storyboard.getAssetManager();
        this.idlePoseManager = storyboard.getIdlePoseListsManager();

        this.animDirector = shotViewer.getAnimationDirector();
    }
    // ------------------------------------------------------------------------
    public function activate(shot: CModStoryBoardShot) {
        super.activate(shot);

        // make sure something is selected
        if (!assetManager.getSelectedAsset()) {
            // select player actor
            assetManager.selectAsset(-1);
        }

        PushState('SbUi_AssetManaging');
    }
    // ------------------------------------------------------------------------
    public function deactivate() {
        if (GetCurrentStateName() == 'SbUi_AssetEditing') {
            GetCurrentState().OnLeaveState('null');
        }
        // adding assets rearranges assets into a line so everyone can be visible
        // when editing. make sure the shot positions are restored on leaving
        // this mode
        shotViewer.displayShot(shot);
        super.deactivate();
    }
    // ------------------------------------------------------------------------
    // specific events of all asset mode states
    event OnAddNewAsset(action: SInputAction) {}
    event OnDeleteAsset(action: SInputAction) {}
    event OnRename(action: SInputAction) {}
    event OnEditAsset(action: SInputAction) {}
    event OnCycleSelection(action: SInputAction) {}

    event OnDeleteConfirm() {}
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();

        theInput.RegisterListener(this, 'OnAddNewAsset', 'SBUI_AddActor');
        theInput.RegisterListener(this, 'OnAddNewAsset', 'SBUI_AddItem');
        theInput.RegisterListener(this, 'OnDeleteAsset', 'SBUI_DeleteAsset');
        theInput.RegisterListener(this, 'OnEditAsset', 'SBUI_EditAsset');

        theInput.RegisterListener(this, 'OnRename', 'SBUI_RenameAsset');
        theInput.RegisterListener(this, 'OnSetAsOrigin', 'SBUI_SetAssetAsOrigin');

        theInput.RegisterListener(this, 'OnCycleSelection', 'SBUI_SelectPrev');
        theInput.RegisterListener(this, 'OnCycleSelection', 'SBUI_SelectNext');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();

        theInput.UnregisterListener(this, 'SBUI_AddActor');
        theInput.UnregisterListener(this, 'SBUI_AddItem');
        theInput.UnregisterListener(this, 'SBUI_DeleteAsset');
        theInput.UnregisterListener(this, 'SBUI_EditAsset');

        theInput.UnregisterListener(this, 'SBUI_RenameAsset');
        theInput.UnregisterListener(this, 'SBUI_SetAssetAsOrigin');

        theInput.UnregisterListener(this, 'SBUI_SelectPrev');
        theInput.UnregisterListener(this, 'SBUI_SelectNext');
    }
    // ------------------------------------------------------------------------
    public function hasModifiedSettings() : bool {
        return true;
    }
    // ------------------------------------------------------------------------
    public function storeSettings() {
        // (default/changed) settings for (new) assets are stored in assets
        // shotsettings and must be transfered to shotsettings of storyboard
        storyboard.storeCurrentAssetSettingsIn(shot);
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
