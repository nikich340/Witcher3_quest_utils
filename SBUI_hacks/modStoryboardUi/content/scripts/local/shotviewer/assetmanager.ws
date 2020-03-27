// -----------------------------------------------------------------------------
//
// BUGS:
//
// TODO:
//  - are actors / items arrays still necessary?
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
class CModSbUiEntityTemplateList extends CModUiFilteredList {
    // ------------------------------------------------------------------------
    public function loadCsv(path: String) {
        var data: C2dArray;
        var i: int;

        data = LoadCSV(path);

        items.Clear();
        // csv: col0;CAT1;CAT2;CAT3;id;caption
        for (i = 0; i < data.GetNumRows(); i += 1) {
            items.PushBack(SModUiCategorizedListItem(
                data.GetValueAt(4, i),
                data.GetValueAt(5, i),
                data.GetValueAt(1, i),
                data.GetValueAt(2, i),
                data.GetValueAt(3, i)
            ));
        }
    }
    // ------------------------------------------------------------------------
    public function addExtraTemplates(cat1: String, templates: array<SSbUiExtraTemplate>) {
        var topCat: String;
        var i: int;

        topCat = GetLocStringByKeyExt("SBUI_ExtraTemplateCat");

        for (i = 0; i < templates.Size(); i += 1) {
            items.PushBack(SModUiCategorizedListItem(
                templates[i].templatePath,
                templates[i].caption,
                topCat,
                templates[i].subCategory1,
                templates[i].subCategory2));
        }
    }
    // ------------------------------------------------------------------------
    public function getCaption(itemId: String) : String {
        var i: int;

        for (i = 0; i < items.Size(); i += 1) {
            if (items[i].id == itemId) {
                return items[i].caption;
            }
        }
        return "";
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// Management of assets (actors/items) for WHOLE storyboard. Added assets are
// available in all shots and can then be selected to create shot dependent
// settings. Deleting of assets removes it from all shots including settings!
// Exchanging an asset (different mesh/appearance/etc) changes in ALL shots!
//  - adding/deleting/renaming of assets
//  - changing asset
class CModStoryBoardAssetManager {
    // ------------------------------------------------------------------------
    // Note: these 3 arrays must be in sync!
    // contains all assets (references to objects from actors + items)
    private var assets: array<CModStoryBoardAsset>;
    // assets from assets array partitioned into actors and items
    private var actors: array<CModStoryBoardActor>;
    private var items: array<CModStoryBoardItem>;
    // ------------------------------------------------------------------------
    // manages placement
    private var placementDirector: CModStoryBoardPlacementDirector;
    // manages animations
    private var animDirector: CModStoryBoardAnimationDirector;
    // manages look-ats
    private var lookAtDirector: CModStoryBoardLookAtDirector;
    // manages audio lines
    private var audioDirector: CModStoryBoardAudioDirector;

    // assetid counter
    private var lastuid: int;
    private var selectedAsset: CModStoryBoardAsset;
    // helper for selecting next/prev asset
    private var selectedSlot: int;

    // template lists
    private var actorTemplates: CModSbUiEntityTemplateList;
    private var itemTemplates: CModSbUiEntityTemplateList;
    private var dataLoaded: bool;
    // ------------------------------------------------------------------------
    private function getUid(optional prefix: String) : String {
        lastuid += 1;
        return prefix + IntToString(lastuid);
    }
    // ------------------------------------------------------------------------
    private function createPlayerActor() : CModStoryBoardActor {
        var actor: CModStoryBoardActor;

        actor = new CModStoryBoardActor in this;
        actor.init(getUid("actor"));
        changeActorToPlayer(actor);

        return actor;
    }
    // ------------------------------------------------------------------------
    private function changeActorToPlayer(actor: CModStoryBoardActor) {
        actor.setName("Player");

        // set default placement and init shotsettings with it
        actor.setDefaultPlacement(SStoryBoardPlacementSettings(
            thePlayer.GetWorldPosition(),
            thePlayer.GetWorldRotation()
        ), true);
        // setting a template will spawn the actor directly
        actor.setTemplatePath(actor.getPlayerTemplatePath());
        actor.setDefaultIdleAnim('high_standing_determined_idle');
    }
    // ------------------------------------------------------------------------
    public function init(statedata: SStoryBoardAssetsStateData) {
        var null: SStoryBoardAssetsStateData;
        var actor: CModStoryBoardActor;

        if (statedata != null) {
            lastuid = statedata.lastuid;
            restoreActors(statedata.actorData);
            restoreItems(statedata.itemData);
            repartitionAssetsList();
        } else {
            // playeractor exists on start
            actor = createPlayerActor();
            assets.PushBack(actor);
            actors.PushBack(actor);
        }
    }
    // ------------------------------------------------------------------------
    public function reinit() {
        var lastActorId: String;

        // delete every asset until only one (actor) is left
        while (assets.Size() > 1) {
            if (isDeletable(selectedAsset)) {
                deleteSelectedAsset();
            } else {
                selectAsset(getNextAssetId());
                deleteSelectedAsset();
            }
        }
        lastActorId = selectedAsset.getId();
        // create new actor with default settings
        addActor();
        // remove last actor of previous board
        selectAsset(lastActorId);
        deleteSelectedAsset();

        // last one must be newly actor -> reset to player
        changeActorToPlayer((CModStoryBoardActor)selectedAsset);
    }
    // ------------------------------------------------------------------------
    private function lazyLoad() {
        actorTemplates = new CModSbUiEntityTemplateList in this;
        itemTemplates = new CModSbUiEntityTemplateList in this;

        actorTemplates.loadCsv("dlc\storyboardui\data\actor_templates.csv");
        actorTemplates.addExtraTemplates("XTRA", SBUI_getExtraActorTemplates());
        itemTemplates.loadCsv("dlc\storyboardui\data\item_templates.csv");
        itemTemplates.addExtraTemplates("XTRA", SBUI_getExtraItemTemplates());

        dataLoaded = true;
    }
    // ------------------------------------------------------------------------
    public function getState() : SStoryBoardAssetsStateData {
        var statedata: SStoryBoardAssetsStateData;
        var i: int;

        statedata.lastuid = lastuid;

        for (i = 0; i < actors.Size(); i += 1) {
            statedata.actorData.PushBack(actors[i].getState());
        }
        for (i = 0; i < items.Size(); i += 1) {
            statedata.itemData.PushBack(items[i].getState());
        }

        return statedata;
    }
    // ------------------------------------------------------------------------
    private function restoreActors(data: array<SStoryBoardActorStateData>) {
        var newActor: CModStoryBoardActor;
        var i: int;

        for (i = 0; i < data.Size(); i += 1) {
            newActor = new CModStoryBoardActor in this;
            newActor.init("", data[i]);
            actors.PushBack(newActor);
            newActor.spawn();
        }
    }
    // ------------------------------------------------------------------------
    private function restoreItems(data: array<SStoryBoardItemStateData>) {
        var newItem: CModStoryBoardItem;
        var i: int;

        for (i = 0; i < data.Size(); i += 1) {
            newItem = new CModStoryBoardItem in this;
            newItem.init("", data[i]);
            items.PushBack(newItem);
            newItem.spawn();
        }
    }
    // ------------------------------------------------------------------------
    public function initDirectors(
        placementDirector: CModStoryBoardPlacementDirector,
        animDirector: CModStoryBoardAnimationDirector,
        lookAtDirector: CModStoryBoardLookAtDirector,
        audioDirector: CModStoryBoardAudioDirector)
    {
        this.placementDirector = placementDirector;
        this.animDirector = animDirector;
        this.lookAtDirector = lookAtDirector;
        this.audioDirector = audioDirector;

        placementDirector.setAssets(assets);

        animDirector.setActors(actors);
        lookAtDirector.setActors(actors);
        audioDirector.setActors(actors);

        // required for replacement on loops, etc
        animDirector.init(placementDirector);
        lookAtDirector.init();
        audioDirector.init();
    }
    // ------------------------------------------------------------------------
    public function reset() {
        var i: int;
        // remove all spawned assets
        for (i = 0; i < assets.Size(); i += 1) {
            assets[i].despawn();
        }
        assets.Clear();
    }
    // ------------------------------------------------------------------------
    private function findAsset(assetId: String, out slotNr: int)
        : CModStoryBoardAsset
    {
        var null: CModStoryBoardAsset;
        var i: int;

        for (i = 0; i < assets.Size(); i += 1) {
            if (assets[i].getId() == assetId) {
                slotNr = i;
                return assets[i];
            }
        }
        slotNr = -1;
        return null;
    }
    // ------------------------------------------------------------------------
    public function getAsset(assetId: String) : CModStoryBoardAsset {
        var dummy: int;
        return findAsset(assetId, dummy);
    }
    // ------------------------------------------------------------------------
    public function getSelectedAsset() : CModStoryBoardAsset {
        return selectedAsset;
    }
    // ------------------------------------------------------------------------
    public function getPreviousAssetId() : String {
        return assets[(assets.Size() + selectedSlot - 1) % assets.Size()].getId();
    }
    // ------------------------------------------------------------------------
    public function getNextAssetId() : String {
        return assets[(selectedSlot + 1) % assets.Size()].getId();
    }
    // ------------------------------------------------------------------------
    public function getPreviousActorId() : String {
        // even if an item is selected the modulo will move it to some valid actor
        return actors[(actors.Size() + selectedSlot -1) % actors.Size()].getId();
    }
    // ------------------------------------------------------------------------
    public function getNextActorId() : String {
        // even if an item is selected the modulo will move it to some valid actor
        return actors[(selectedSlot + 1) % actors.Size()].getId();
    }
    // ------------------------------------------------------------------------
    // returns a different actor than provided (round robin). returns lastActorId
    // if no other actor found
    public function getNextInteractionActorId(
        srcActorId: String, lastActorId: String) : String
    {
        var actorId: String = lastActorId;
        var actorCount: int = actors.Size();
        var lastSlot: int = -1;
        var i: int;

        if (actorCount > 1) {
            // find lastActor
            for (i = 0; i < actorCount; i += 1) {
                if (actors[i].getId() == lastActorId) {
                    lastSlot = i;
                    break;
                }
            }

            if (lastSlot < 0) {
                // none selected pick first one after srcActor
                for (i = 0; i < actorCount; i += 1) {
                    if (actors[i].getId() == srcActorId) {
                        actorId = actors[(i + 1) % actorCount].getId();
                        break;
                    }
                }

            } else {
                actorId = actors[(lastSlot + 1) % actorCount].getId();
                // make sure it's not srcActor
                if (actorId == srcActorId) {
                    // just take the next one (even if it's lastActor the
                    // selection will be valid)
                    actorId = actors[(lastSlot + 2) % actorCount].getId();
                }
            }
        }

        return actorId;
    }
    // ------------------------------------------------------------------------
    private function repartitionAssetsList() {
        var i: int;

        // this is required to have all actors first followed by items
        assets.Clear();
        for (i = 0; i < actors.Size(); i += 1) { assets.PushBack(actors[i]); }
        for (i = 0; i < items.Size(); i += 1) { assets.PushBack(items[i]); }
    }
    // ------------------------------------------------------------------------
    public function addActor(optional cloneFrom: CModStoryBoardAsset) : String {
        var newActor: CModStoryBoardActor;
        var srcActor: CModStoryBoardActor;

        newActor = new CModStoryBoardActor in this;
        // make sure it's the correct type
        srcActor = (CModStoryBoardActor)cloneFrom;

        // no player cloning
        if (srcActor && !srcActor.isPlayerClone()) {
            newActor.cloneFrom(getUid("actor"), srcActor);
        } else {
            newActor.init(getUid("actor"));
        }
        actors.PushBack(newActor);
        repartitionAssetsList();

        // refresh default placements
        placementDirector.setAssets(assets);
        // new actor do not have any shotsettings yet so they must be initialized
        // with default settings (and default positions is available *after*
        // placementDirector processed the asset)
        newActor.setShotSettings();
        newActor.spawn();

        animDirector.setActors(actors);
        lookAtDirector.setActors(actors);
        audioDirector.setActors(actors);

        return newActor.getId();
    }
    // ------------------------------------------------------------------------
    public function addItem(optional cloneFrom: CModStoryBoardAsset) : String {
        var newItem: CModStoryBoardItem;
        var srcItem: CModStoryBoardItem;

        newItem = new CModStoryBoardItem in this;
        // make sure it's the correct type
        srcItem = (CModStoryBoardItem)cloneFrom;

        if (srcItem) {
            newItem.cloneFrom(getUid("item"), srcItem);
        } else {
            newItem.init(getUid("item"));
        }
        items.PushBack(newItem);
        repartitionAssetsList();

        // refresh default placements
        placementDirector.setAssets(assets);
        newItem.spawn();

        return newItem.getId();
    }
    // ------------------------------------------------------------------------
    public function deleteSelectedAsset() {
        var actor: CModStoryBoardActor;
        var i: int;

        actor = (CModStoryBoardActor)selectedAsset;

        if (isDeletable(selectedAsset)) {
            if (actor) {
                actors.Remove(actor);
                // refresh list of valid actors
                animDirector.setActors(actors);
                lookAtDirector.setActors(actors);
                lookAtDirector.onDeleteAsset(actor.getId());
                audioDirector.setActors(actors);
            } else {
                items.Remove((CModStoryBoardItem)selectedAsset);
            }
            // Note: repartition not necessary as partitions order was not changed
            assets.Remove(selectedAsset);
            selectedAsset.despawn();

            // no fancy previous item search -> actor 0 is always available
            selectedAsset = actors[0];
            selectedSlot = 0;

            // refresh default placements
            placementDirector.setAssets(assets);
        }
    }
    // ------------------------------------------------------------------------
    public function isDeletable(asset: CModStoryBoardAsset) : bool {
        var actor: CModStoryBoardActor;
        actor = (CModStoryBoardActor)asset;

        if (actor && actors.Size() < 2) {
            return false;
        }
        return true;
    }
    // ------------------------------------------------------------------------
    public function isPlayerActorSpawned() : bool {
        var i: int;
        for (i = 0; i < actors.Size(); i += 1) {
            if (actors[i].isPlayerClone()) {
                return true;
            }
        }
        return false;
    }
    // ------------------------------------------------------------------------
    public function selectAsset(assetId: String) : bool {
        var asset: CModStoryBoardAsset;
        var slotNr: int;
        asset = findAsset(assetId, slotNr);

        if (asset) {
            selectedAsset = asset;
            selectedSlot = slotNr;
        } else {
            // select first asset (there must be always at least one actor!)
            selectedAsset = assets[0];
            selectedSlot = 0;
        }
        return true;
    }
    // ------------------------------------------------------------------------
    public function changeAppearance(bySlots : int) : String {
        var actor: CModStoryBoardActor;

        actor = (CModStoryBoardActor)selectedAsset;
        actor.changeAppearance(bySlots);

        return actor.getAppearanceName(true);
    }
    // ------------------------------------------------------------------------
    public function getAssets() : array<CModStoryBoardAsset> {
        return assets;
    }
    // ------------------------------------------------------------------------
    public function getAssetItemsList() : array<SModUiListItem> {
        var itemList: array<SModUiListItem>;
        var asset: CModStoryBoardAsset;
        var selectedId: String;
        var isItemCatEntryAdded: bool;
        var i: int;

        selectedId = selectedAsset.getId();

        // id == IGNORE => list will ignore (=not notify) user selection
        itemList.PushBack(SModUiListItem(
            "IGNORE", GetLocStringByKeyExt("SBUI_AssetsActorCategory")));

        for (i = 0; i < assets.Size(); i += 1) {
            asset = assets[i];

            // prepend item category entry before first item
            if (!isItemCatEntryAdded && (CModStoryBoardItem)asset) {
                isItemCatEntryAdded = true;
                itemList.PushBack(SModUiListItem(
                    "IGNORE", GetLocStringByKeyExt("SBUI_AssetsItemCategory")));
            }

            itemList.PushBack(SModUiListItem(
                asset.getId(), asset.getName(), asset.getId() == selectedId));
        }

        return itemList;
    }
    // ------------------------------------------------------------------------
    public function getActorItemsList() : array<SModUiListItem> {
        var itemList: array<SModUiListItem>;
        var actor: CModStoryBoardActor;
        var selectedId: String;
        var i: int;

        selectedId = selectedAsset.getId();

        for (i = 0; i < actors.Size(); i += 1) {
            actor = actors[i];

            itemList.PushBack(SModUiListItem(
                actor.getId(), actor.getName(), actor.getId() == selectedId));
        }

        return itemList;
    }
    // ------------------------------------------------------------------------
    public function getAssetCount() : int {
        return assets.Size();
    }
    // ------------------------------------------------------------------------
    public function getActorCount() : int {
        return actors.Size();
    }
    // ------------------------------------------------------------------------
    public function getItemsCount() : int {
        return items.Size();
    }
    // ------------------------------------------------------------------------
    public function getTemplateListFor(asset: CModStoryBoardAsset)
        : CModSbUiEntityTemplateList
    {
        if (!dataLoaded) { lazyLoad(); }

        if ((CModStoryBoardActor)asset) {
            return actorTemplates;
        } else {
            return itemTemplates;
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
