// ----------------------------------------------------------------------------
class CEncodedRadishCommunity extends CRadishCommunity {
    // ------------------------------------------------------------------------
    private var questId: String;
    // ------------------------------------------------------------------------
    private var spawnedPhase: CEncodedRadishCommunityPhase;
    private var spawned: bool;
    // ------------------------------------------------------------------------
    default readOnly = true;
    // ------------------------------------------------------------------------
    public function initFromDbgInfos(metaInfo: array<SDbgInfo>) {
        var i, s: int;

        s = metaInfo.Size();
        for (i = 0; i < s; i += 1) {
            // parse encoded meta information in dbgInfo
            switch (metaInfo[i].type) {
                case "id":    this.setId(metaInfo[i].s); break;
                case "actor": this.addActorFromDbgInfos(metaInfo[i].v); break;
                case "phase": this.addPhaseFromDbgInfos(metaInfo[i].v); break;
                case "quest": this.questId = metaInfo[i].s; break;
            }
        }
        settings.id = this.id;
    }
    // ------------------------------------------------------------------------
    private function addActorFromDbgInfos(metaInfo: array<SDbgInfo>) {
        var actor: CEncodedRadishCommunityActor;

        actor = new CEncodedRadishCommunityActor in this;
        actor.initFromDbgInfos(this.id, metaInfo);
        if (actor.getId() != "") {
            actors.PushBack((CRadishCommunityActor)actor);
        }
    }
    // ------------------------------------------------------------------------
    private function addPhaseFromDbgInfos(metaInfo: array<SDbgInfo>) {
        var phase: CEncodedRadishCommunityPhase;

        phase = new CEncodedRadishCommunityPhase in this;
        phase.initFromDbgInfos(this.id, metaInfo);
        if (phase.getId() != "") {
            phases.PushBack((CRadishCommunityPhase)phase);
        }
    }
    // ------------------------------------------------------------------------
    public function getQuestId() : String {
        return this.questId;
    }
    // ------------------------------------------------------------------------
    public function getExtendedCaption() : String {
        var prefix, suffix: String;

        if (spawned) {
            prefix = "enc: ";
            suffix = " (<font color=\"#8888FF\">" + spawnedPhase.getCaption() + "</font>)";
        } else {
            prefix = "enc: <font color=\"#777777\">";
            suffix = "</font>";
        }

        return prefix + super.getExtendedCaption() + suffix;
    }
    // ------------------------------------------------------------------------
    public function isSpawned() : bool {
        return this.spawned;
    }
    // ------------------------------------------------------------------------
    // phase management
    // ------------------------------------------------------------------------
    public function scanForActivePhase() : bool {
        var actors: array<CEntity>;
        var phaseScanTag: name;
        var p, ps: int;
        var phase: CEncodedRadishCommunityPhase;

        spawned = false;
        spawnedPhase = phase;

        ps = phases.Size();
        for (p = 0; p < ps; p += 1) {
            phase = (CEncodedRadishCommunityPhase)phases[p];
            phaseScanTag = phase.getScanIdTag();
            actors.Clear();

            theGame.GetEntitiesByTag(phaseScanTag, actors);

            if (actors.Size() > 0) {
                // is active
                phase.markSpawned();
                spawned = true;
                spawnedPhase = phase;
            } else {
                phase.markDespawned();
            }
        }
        return this.spawned;
    }
    // ------------------------------------------------------------------------
    public function spawnFirstPhase() : CRadishCommunityPhase {
        var factid: String;
        var i, p: int;
        var result: CEncodedRadishCommunityPhase;

        spawned = false;
        spawnedPhase = result;

        result = (CEncodedRadishCommunityPhase)phases[0];
        if (result) {

            // be conservative and remove factid every time
            factid = "radish_comm_" + this.questId + "_" + this.id + "_phase";
            FactsRemove(factid);

            FactsAdd(factid, 1);
            result.markSpawned();

            spawned = true;
            spawnedPhase = result;
            isDirty = true;
        }
        return result;
    }
    // ------------------------------------------------------------------------
    public function spawnPhase(id: String) : CRadishCommunityPhase {
        var factid: String;
        var i, p: int;
        var result: CEncodedRadishCommunityPhase;

        spawned = false;
        spawnedPhase = result;

        p = phases.Size();
        for (i = 0; i < p; i += 1) {
            if (phases[i].getId() == id) {
                result = (CEncodedRadishCommunityPhase)phases[i];

                // be conservative and remove factid every time
                factid = "radish_comm_" + this.questId + "_" + this.id + "_phase";
                FactsRemove(factid);

                FactsAdd(factid, i + 1);
                result.markSpawned();

                spawned = true;
                spawnedPhase = result;
                isDirty = true;
            } else {
                ((CEncodedRadishCommunityPhase)phases[i]).markDespawned();
            }
        }
        // return null if phase was already spawned
        return result;
    }
    // ------------------------------------------------------------------------
    public function despawn() {
        var null: CEncodedRadishCommunityPhase;
        var factid: String;
        var i, p: int;

        spawned = false;
        spawnedPhase = null;
        isDirty = true;

        // be conservative and remove factid every time
        factid = "radish_comm_" + this.questId + "_" + this.id + "_phase";
        FactsRemove(factid);
        FactsAdd(factid, -1);

        // mark all phases as despawned
        p = phases.Size();
        for (i = 0; i < p; i += 1) {
            ((CEncodedRadishCommunityPhase)phases[i]).markDespawned();
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
