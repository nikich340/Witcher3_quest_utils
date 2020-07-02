// ----------------------------------------------------------------------------
class CRadUiNavMeshList extends CRadishUiFilteredList {
    // ------------------------------------------------------------------------
    public function setNavMeshList(navMeshes: array<CRadishNavMesh>) : int {
        var n, ns: int;
        var navMesh: CRadishNavMesh;

        items.Clear();

        ns = navMeshes.Size();
        for (n = 0; n < ns; n += 1) {
            navMesh = navMeshes[n];

            items.PushBack(SModUiCategorizedListItem(
                navMesh.getId(),
                navMesh.getExtendedCaption(),
            ));
        }
        return items.Size();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CRadishNavMeshManager extends IRadishUiModeManager {
    private var log: CModLogger;
    // ------------------------------------------------------------------------
    private var worldId: String;
    private var worldCaption: String;
    // ------------------------------------------------------------------------
    private var navMeshes: array<CRadishNavMesh>;
    private var navMeshListProvider: CRadUiNavMeshList;

    private var selectedNavMesh: CRadishNavMesh;
    // ------------------------------------------------------------------------
    private var theCam: CRadishStaticCamera;
    // ------------------------------------------------------------------------
    public function init(log: CModLogger, questIdFilter: String, statedata: array<SRadishNavMeshData>) {
        this.log = log;
        this.worldId = this.detectWorldId();
        this.worldCaption = StrReplaceAll(this.worldId, "_", " ");
        log.debug("navmesh manager initialized");

        navMeshes = this.extractEncodedNavMeshes(questIdFilter);

        navMeshListProvider = new CRadUiNavMeshList in this;
        refreshListProvider();

        // make sure there is always one selected
        if (navMeshes.Size() > 0) {
            navMeshListProvider.setSelection(navMeshes[0].getId(), true);
            selectedNavMesh = navMeshes[0];
        }
    }
    // ------------------------------------------------------------------------
    private function detectWorldId() : String {
        var manager: CCommonMapManager;
        var worldPath: String;
        var currentArea: EAreaName;

        manager = theGame.GetCommonMapManager();
        worldPath = theGame.GetWorld().GetDepotPath();
        currentArea = manager.GetAreaFromWorldPath(worldPath);

        // mapping to encoder defined ids (see repository/worlds)
        switch (currentArea) {
            case AN_NMLandNovigrad:             return "novigrad";
            case AN_Skellige_ArdSkellig:        return "skellige";
            case AN_Kaer_Morhen:                return "kaer_morhen";
            case AN_Prologue_Village:           return "prologue";
            case AN_Wyzima:                     return "vizima";
            case AN_Island_of_Myst:             return "isle_of_mists";
            case AN_Spiral:                     return "spiral";
            case AN_Prologue_Village_Winter:    return "prologue_winter";
            case AN_Velen:                      return "velen";
            //case AN_CombatTestLevel:            return "";
            default:
                return AreaTypeToName(currentArea);
        }
    }
    // ------------------------------------------------------------------------
    private function isFiltered(filterId: String, metaInfo: array<SDbgInfo>) : bool {
        var i, s: int;
        var dbgInfo: SDbgInfo;
        var meshId, questId: String;

        if (filterId == "*") return false;

        s = metaInfo.Size();

        for (i = 0; i < s; i += 1) {
            dbgInfo = metaInfo[i];
            switch (dbgInfo.type) {
                case "id":      meshId = dbgInfo.s; break;
                case "quest":
                    questId = dbgInfo.s;
                    if (questId == filterId) {
                        return false;
                    }
                    break;
            }
        }
        log.debug("ignoring navmesh [" + meshId + "] for quest [" + questId + "]");
        return true;
    }
    // ------------------------------------------------------------------------
    private function extractEncodedNavMeshes(questIdFilter: String) : array<CRadishNavMesh> {
        var dbgEntities: array<CEntity>;
        var encodedMeshes: array<CRadishNavMesh>;
        var navMesh: CEncodedRadishNavMesh;
        var i, s : int;

        theGame.GetEntitiesByTag('radish_dbg_navmesh', dbgEntities);
        s = dbgEntities.Size();

        // extract meta information for each navmesh
        for (i = 0; i < s; i += 1) {
            if (!this.isFiltered(questIdFilter, dbgEntities[i].dbgInfo)) {
                navMesh = new CEncodedRadishNavMesh in this;
                navMesh.initFromDbgInfos(dbgEntities[i].dbgInfo);

                encodedMeshes.PushBack(navMesh);
                log.debug("found navmesh [" + navMesh.getId() + "]");
            }
        }

        if (encodedMeshes.Size() > 0) {
            log.info("found encoded navigation meshes to manage: " + IntToString(encodedMeshes.Size()));
        } else {
            log.info("no encoded navigation meshes found.");
        }
        return encodedMeshes;
    }
    // ------------------------------------------------------------------------
    public function activate(cam: CRadishStaticCamera) {
        log.debug("navmesh manager activated");
        this.theCam = cam;
    }
    // ------------------------------------------------------------------------
    public function deactivate() {
        var null: CRadishStaticCamera;
        this.theCam = null;
    }
    // ------------------------------------------------------------------------
    public function refreshListProvider() {
        navMeshListProvider.setNavMeshList(this.navMeshes);
    }
    // ------------------------------------------------------------------------
    public function getNavMeshList() : CRadishUiFilteredList {
        return this.navMeshListProvider;
    }
    // ------------------------------------------------------------------------
    public function getNavMeshCount() : int {
        return this.navMeshes.Size();
    }
    // ------------------------------------------------------------------------
    public function getSelected() : CRadishNavMesh {
        return selectedNavMesh;
    }
    // ------------------------------------------------------------------------
    public function selectNavMesh(navMeshId: String) : CRadishNavMesh {
        var null: CRadishNavMesh;
        var i, s: int;

        s = navMeshes.Size();
        for (i = 0; i < s; i += 1) {
            // does navmesh match?
            if (navMeshes[i].getId() == navMeshId) {
                selectedNavMesh = navMeshes[i];
                return selectedNavMesh;
            }
        }
        selectedNavMesh = null;
        return null;
    }
    // ------------------------------------------------------------------------
    public function selectPrevious() : CRadishNavMesh {
        navMeshListProvider.setSelection(navMeshListProvider.getPreviousId());
        return selectNavMesh(navMeshListProvider.getSelectedId());
    }
    // ------------------------------------------------------------------------
    public function selectNext() : CRadishNavMesh {
        navMeshListProvider.setSelection(navMeshListProvider.getNextId());
        return selectNavMesh(navMeshListProvider.getSelectedId());
    }
    // ------------------------------------------------------------------------
    public function verifyId(newId: String) : bool {
        var i, s: int;

        newId = RadUi_escapeAsId(newId);

        s = navMeshes.Size();
        for (i = 0; i < s; i += 1) {
            if (navMeshes[i].getId() == newId) {
                return false;
            }
        }
        return true;
    }
    // ------------------------------------------------------------------------
    // navmesh management
    // ------------------------------------------------------------------------
    private function generateUniqueId(baseId: String) : String {
        var newId: String;
        var i: int;

        newId = baseId;
        while (!verifyId(newId)) {
            i += 1;
            newId = baseId + " " + IntToString(i);
        }
        return newId;
    }
    // ------------------------------------------------------------------------
    public function addNew() : CRadishNavMesh {
        var newMesh: CRadishNavMesh;
        var newId: String;
        var newPlacement: SRadishPlacement;

        newPlacement.pos = RadUi_getGroundPosFromCam(theCam.getSettings());

        newId = generateUniqueId("new navmesh");

        newMesh = new CRadishNavMesh in this;
        newMesh.init(newId, newPlacement);
        log.debug("created new navmesh: " + newId);

        navMeshes.PushBack(newMesh);

        refreshListProvider();
        navMeshListProvider.setSelection(newMesh.getId(), true);
        selectedNavMesh = newMesh;

        return selectedNavMesh;
    }
    // ------------------------------------------------------------------------
    public function deleteSelected() : bool {
         log.debug("deleting navmesh: " + selectedNavMesh.getId());

        if (navMeshes.Remove(selectedNavMesh)) {
            selectedNavMesh.destroy();
            delete selectedNavMesh;

            refreshListProvider();

            if (navMeshes.Size() > 0) {
                navMeshListProvider.setSelection(navMeshes[0].getId(), true);
                selectedNavMesh = navMeshes[0];
            }
            return true;
        }

        return false;
    }
    // ------------------------------------------------------------------------
    // helper
    // ------------------------------------------------------------------------
    public function getHubName() : String {
        return worldId;
    }
    // ------------------------------------------------------------------------
    public function switchCamTo(placement: SRadishPlacement) {
        theCam.setSettings(placement);
        theCam.switchTo();
    }
    // ------------------------------------------------------------------------
    public function getCam() : CRadishStaticCamera {
        return theCam;
    }
    // ------------------------------------------------------------------------
    public function getCamPlacement() : SRadishPlacement {
        return theCam.getSettings();
    }
    // ------------------------------------------------------------------------
    public function getCamTracker() : CRadishTracker {
        return theCam.getTracker();
    }
    // ------------------------------------------------------------------------
    // definition creation
    // ------------------------------------------------------------------------
    public function logDefinition(optional isAutoLogged: bool) {
        var definitionWriter: CRadishDefinitionWriter;
        var defs, hub, root: SEncValue;
        var i: int;

        root = encValueNewMap();
        hub = encValueNewMap();
        defs = encValueNewMap();

        for (i = 0; i < navMeshes.Size(); i += 1) {
            encMapPush(navMeshes[i].getId(), navMeshes[i].asDefinition(), defs);
        }
        encMapPush(worldId, defs, hub);
        encMapPush("navdata", hub, root);

        definitionWriter = new CRadishDefinitionWriter in this;
        if (isAutoLogged) {
            definitionWriter.create('W3NAVMESH', "Radish Quest UI", root);
        } else {
            definitionWriter.create('W3NAVMESH', "Radish Quest UI (auto-log)", root);
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
