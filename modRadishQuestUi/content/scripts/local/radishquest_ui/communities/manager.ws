// ----------------------------------------------------------------------------
class CRadUiCommunityList extends CRadishUiFilteredList {
    // ------------------------------------------------------------------------
    public function setCommunityList(communities: array<CRadishCommunity>) : int {
        var c, cs: int;
        var community: CRadishCommunity;

        items.Clear();

        cs = communities.Size();
        for (c = 0; c < cs; c += 1) {
            community = communities[c];

            items.PushBack(SModUiCategorizedListItem(
                community.getId(),
                community.getExtendedCaption(),
            ));
        }
        return items.Size();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CRadishCommunityManager extends IRadishUiModeManager {
    private var log: CModLogger;
    // ------------------------------------------------------------------------
    private var communities: array<CRadishCommunity>;

    // only communities
    private var communityListProvider: CRadUiCommunityList;

    private var selectedCommunity: CRadishCommunity;
    // ------------------------------------------------------------------------
    private var theCam: CRadishStaticCamera;
    // ------------------------------------------------------------------------
    public function init(log: CModLogger, questIdFilter: String, statedata: array<SRadishCommunityData>) {
        this.log = log;
        log.debug("community manager initialized");

        communities = this.extractEncodedCommunities(questIdFilter);

        communityListProvider = new CRadUiCommunityList in this;
        refreshListProvider();

        // make sure there is always one layer selected
        if (communities.Size() > 0) {
            communityListProvider.setSelection(communities[0].getId(), true);
            selectedCommunity = communities[0];
        }
    }
    // ------------------------------------------------------------------------
    private function extractEncodedCommunities(filter: String) : array<CRadishCommunity> {
        var dbgEntities: array<CEntity>;
        var communities: array<CRadishCommunity>;
        var unsorted: array<CRadishCommunity>;
        var community: CEncodedRadishCommunity;
        var i, s : int;

        theGame.GetEntitiesByTag('radish_dbg_community', dbgEntities);
        s = dbgEntities.Size();

        // extract meta information for each community
        for (i = 0; i < s; i += 1) {
            community = new CEncodedRadishCommunity in this;
            community.initFromDbgInfos(dbgEntities[i].dbgInfo);
            if (filter == "*" || filter == community.getQuestId()) {
                community.scanForActivePhase();
                unsorted.PushBack(community);

                log.debug("found community [" + community.getName()
                    + "] with " + IntToString(community.getActorCount())
                    + " actors and " + IntToString(community.getPhaseCount()) + " phases");
            } else {
                log.debug("skipping community [" + community.getName()
                    + "] for quest " + community.getQuestId());
            }
        }

        // reverse order (sort?) of communities
        s = unsorted.Size();
        for (i = 0; i < s; i += 1) {
            communities.PushBack(unsorted.PopBack());
        }

        if (communities.Size() > 0) {
            log.info("found encoded communities to manage: " + IntToString(communities.Size()));
        } else {
            log.info("no encoded community found.");
        }
        return communities;
    }
    // ------------------------------------------------------------------------
    public function activate(cam: CRadishStaticCamera) {
        log.debug("community manager activated");
        this.theCam = cam;
    }
    // ------------------------------------------------------------------------
    public function deactivate() {
        var null: CRadishStaticCamera;
        this.theCam = null;
    }
    // ------------------------------------------------------------------------
    public function refreshListProvider() {
        communityListProvider.setCommunityList(this.communities);
    }
    // ------------------------------------------------------------------------
    public function getCommunityList() : CRadishUiFilteredList {
        return this.communityListProvider;
    }
    // ------------------------------------------------------------------------
    public function getCommunityCount() : int {
        return this.communities.Size();
    }
    // ------------------------------------------------------------------------
    public function getSelected() : CRadishCommunity {
        return selectedCommunity;
    }
    // ------------------------------------------------------------------------
    public function selectCommunity(communityId: String) : CRadishCommunity {
        var null: CRadishCommunity;
        var i, s: int;

        s = communities.Size();
        for (i = 0; i < s; i += 1) {
            // does community match?
            if (communities[i].getId() == communityId) {
                selectedCommunity = communities[i];
                return selectedCommunity;
            }
        }
        selectedCommunity = null;
        return null;
    }
    // ------------------------------------------------------------------------
    public function getCam() : CRadishStaticCamera {
        return theCam;
    }
    // ------------------------------------------------------------------------
    public function scanForActivePhases() {
        var i, s: int;

        s = communities.Size();
        for (i = 0; i < s; i += 1) {
            ((CEncodedRadishCommunity)communities[i]).scanForActivePhase();
        }
    }
    // ------------------------------------------------------------------------
    public function logDefinition(optional isAutoLogged: bool) {
        var definitionWriter: CRadishDefinitionWriter;
        var defs, root: SEncValue;
        var i: int;
        var id: SRadUiLayerId;

        root = SEncValue(EEVT_Map);
        defs = SEncValue(EEVT_Map);

        for (i = 0; i < communities.Size(); i += 1) {
            //TODO comment "shadowed/deleted encoded community" ?
            if (!communities[i].isEmpty()) {
                defs.m.PushBack(SEncKeyValue(communities[i].getId(), communities[i].asDefinition()));
            } else {
                //TODO comment: community without items?
            }
        }
        root.m.PushBack(SEncKeyValue("communities", defs));

        // since nothing is written
        // definitionWriter = new CRadishDefinitionWriter in this;
        // if (isAutoLogged) {
        //     definitionWriter.create('W2COMMUNITY', "Radish Quest UI", root);
        // } else {
        //     definitionWriter.create('W2COMMUNITY', "Radish Quest UI (auto-log)", root);
        // }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
