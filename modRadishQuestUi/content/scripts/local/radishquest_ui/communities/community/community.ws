// ----------------------------------------------------------------------------
class CRadishCommunity {
    // ------------------------------------------------------------------------
    protected var id: String;
    private var caption: String;
    protected var visibility: bool;

    protected var settings: SRadishCommunityData;
    protected var readOnly: bool;
    protected var isDirty: bool;
    // ------------------------------------------------------------------------
    protected var actors: array<CRadishCommunityActor>;
    protected var phases: array<CRadishCommunityPhase>;
    // ------------------------------------------------------------------------
    public function init(id: String) {
        this.id = id;

        refreshCaption();
    }
    // ------------------------------------------------------------------------
    public function initFromData(data: SRadishCommunityData) {
        //TODO
        settings = data;
    }
    // ------------------------------------------------------------------------
    public function getSettings() : SRadishCommunityData {
        return settings;
    }
    // ------------------------------------------------------------------------
    public function getId() : String {
        return this.id;
    }
    // ------------------------------------------------------------------------
    public function getActor(id: String) : CRadishCommunityActor {
        var i, s: int;
        var result: CRadishCommunityActor;

        s = actors.Size();
        for (i = 0; i < s; i += 1) {
            if (actors[i].getId() == id) {
                return actors[i];
            }
        }
        return result;
    }
    // ------------------------------------------------------------------------
    public function getPhase(id: String) : CRadishCommunityPhase {
        var i, s: int;
        var result: CRadishCommunityPhase;

        s = phases.Size();
        for (i = 0; i < s; i += 1) {
            if (phases[i].getId() == id) {
                return phases[i];
            }
        }
        return result;
    }
    // ------------------------------------------------------------------------
    public function getActors() : array<CRadishCommunityActor> {
        return this.actors;
    }
    // ------------------------------------------------------------------------
    public function getPhases() : array<CRadishCommunityPhase> {
        return this.phases;
    }
    // ------------------------------------------------------------------------
    public function getActorCount() : int {
        return this.actors.Size();
    }
    // ------------------------------------------------------------------------
    public function getPhaseCount() : int {
        return this.phases.Size();
    }
    // ------------------------------------------------------------------------
    public function isSpawned() : bool {
        return false;
    }
    // ------------------------------------------------------------------------
    public function isDirty() : bool {
        return isDirty;
    }
    // ------------------------------------------------------------------------
    public function resetDirtyFlag() {
        isDirty = false;
    }
    // ------------------------------------------------------------------------
    // naming
    // ------------------------------------------------------------------------
    public function getName() : String {
        return this.caption;
    }
    // ------------------------------------------------------------------------
    public function getExtendedCaption() : String {
        var prefix: String;
        var suffix: String;

        //if (visibility) { prefix = "v "; } else {
        //  prefix = ". ";
        //}

        return prefix + this.caption + suffix;
    }
    // ------------------------------------------------------------------------
    private function refreshCaption() {
        var i, p: int;

        caption = id;
        StrReplaceAll(caption, "_", " ");
    }
    // ------------------------------------------------------------------------
    // setter
    // ------------------------------------------------------------------------
    public function setId(newId: String) {
        id = newId;
        refreshCaption();
    }
    // ------------------------------------------------------------------------
    public function isEmpty() : bool {
        return actors.Size() == 0 || phases.Size() == 0;
    }
    // ------------------------------------------------------------------------
    // definition creation
    // ------------------------------------------------------------------------
    public function asDefinition() : SEncValue {
        var content, defs: SEncValue;
        var i: int;

        content = SEncValue(EEVT_Map);

        if (!isEmpty()) {
            // -- actors
            defs = SEncValue(EEVT_Map);
            for (i = 0; i < actors.Size(); i += 1) {
                defs.m.PushBack(SEncKeyValue(actors[i].getId(), actors[i].asDefinition()));
            }
            content.m.PushBack(SEncKeyValue("actors", defs));

            // -- phases
            defs = SEncValue(EEVT_Map);
            for (i = 0; i < phases.Size(); i += 1) {
                defs.m.PushBack(SEncKeyValue(phases[i].getId(), phases[i].asDefinition()));
            }
            content.m.PushBack(SEncKeyValue("phases", defs));
        }

        return content;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
