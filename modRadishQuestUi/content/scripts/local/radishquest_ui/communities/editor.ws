// ----------------------------------------------------------------------------
class CRadishUiCommunityElementList extends CRadishUiListProvider {
    // ------------------------------------------------------------------------
    private var community: CRadishCommunity;
    // ------------------------------------------------------------------------
     public function setCommunity(community: CRadishCommunity) {
        this.community = community;
        this.refreshList();
    }
    // ------------------------------------------------------------------------
    public function refreshList() {
        var actors: array<CRadishCommunityActor>;
        var phases: array<CRadishCommunityPhase>;
        var a, as, p, ps: int;
        var actorPrefix, phasePrefix: String;

        actorPrefix = GetLocStringByKeyExt("RADUI_lCommunityActorItemPrexix");
        phasePrefix = GetLocStringByKeyExt("RADUI_lCommunityPhaseItemPrexix");

        items.Clear();

        actors = community.getActors();
        as = actors.Size();
        for (a = 0; a < as; a += 1) {
            items.PushBack(SModUiListItem(
                "a:" + actors[a].getId(),
                actors[a].getExtendedCaption(actorPrefix)
            ));
        }

        phases = community.getPhases();
        ps = phases.Size();
        for (p = 0; p < ps; p += 1) {
            items.PushBack(SModUiListItem(
                "p:" + phases[p].getId(),
                phases[p].getExtendedCaption(phasePrefix),
            ));
        }
    }
    // ------------------------------------------------------------------------
    public function preselect() {
        if (items.Size() > 0) {
            items[0].isSelected = true;
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CRadishCommunityEditor {
    private var log: CModLogger;
    // ------------------------------------------------------------------------
    // used to locate referenced layerentities
    protected var visualizer: CRadishProxyVisualizer;
    // ------------------------------------------------------------------------
    private var community: CRadishCommunity;

    private var listProvider: CRadishUiCommunityElementList;
    // ------------------------------------------------------------------------
    public function init(
        log: CModLogger, community: CRadishCommunity, proxyVisualizer: CRadishProxyVisualizer)
    {
        this.log = log;
        this.visualizer = proxyVisualizer;
        this.community = community;

        log.debug("community editor: " + community.getName());

        listProvider = new CRadishUiCommunityElementList in this;
        listProvider.setCommunity(this.community);

        listProvider.preselect();
    }
    // ------------------------------------------------------------------------
    public function getCommunityElementsList() : CRadishUiListProvider {
        return this.listProvider;
    }
    // ------------------------------------------------------------------------
    public function getElement(id: String) : CRadishCommunityElement {
        var element: CRadishCommunityElement;

        if (StrFindFirst(id, "p:") == 0) {
            return community.getPhase(StrAfterFirst(id, "p:"));
        } else if (StrFindFirst(id, "a:") == 0) {
            return community.getActor(StrAfterFirst(id, "a:"));
        }

        return element;
    }
    // ------------------------------------------------------------------------
    public function refreshList() {
        listProvider.refreshList();
    }
    // ------------------------------------------------------------------------
    public function refreshHighlight(forceCamSwitch: bool) {
        this.visualizer.refreshHighlight(forceCamSwitch);
    }
    // ------------------------------------------------------------------------
    public function clearHighlighted() {
        this.visualizer.clearHighlighted();
    }
    // ------------------------------------------------------------------------
    public function select(elemenId: String) {
        var referenced: array<String>;

        if (StrFindFirst(elemenId, "p:") == 0) {
            community.getPhase(StrAfterFirst(elemenId, "p:")).extractReferencedIds(referenced);
            visualizer.highlightMultiple(referenced);
        } else {
            visualizer.clearHighlighted();
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
