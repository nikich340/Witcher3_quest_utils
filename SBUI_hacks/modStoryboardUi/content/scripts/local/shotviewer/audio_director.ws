// ----------------------------------------------------------------------------
//
// BUGS:
//
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// Starting/stoping audio of all actors in a shot
//
class CModStoryBoardAudioDirector {
    // ------------------------------------------------------------------------
    // this actor set defines what actors are available for playback
    private var actors: array<CModStoryBoardActor>;
    // ------------------------------------------------------------------------
    // ------------------------------------------------------------------------
    public function init() {
    }
    // ------------------------------------------------------------------------
    public function setActors(actors: array<CModStoryBoardActor>) {
        this.actors = actors;
    }
    // ------------------------------------------------------------------------
    public function startPlaybackForActor(actor: CModStoryBoardActor) {
        var shotSettings: SStoryBoardShotAssetSettings = actor.getShotSettings();
        var audioSettings: SStoryBoardAudioSettings = shotSettings.audio;
        var audioActor: CActor;

        if (audioSettings.lineId != 0) {
            audioActor = (CActor)actor.getEntity();
            if (audioActor.IsSpeaking()) {
                audioActor.EndLine();
            }
            audioActor.PlayLine(audioSettings.lineId, false);
        }
    }
    // ------------------------------------------------------------------------
    public function startShotPlayback() {
        var actorCount: int = actors.Size();
        var i: int;

        for (i = 0; i < actorCount; i += 1) {
            startPlaybackForActor(actors[i]);
        }
    }
    // ------------------------------------------------------------------------
    public function stopAudio() {
        var actor: CActor;
        var i: int;

        for (i = 0; i < actors.Size(); i += 1) {
            actor = (CActor)actors[i].getEntity();
            if (actor.IsSpeaking()) {
                actor.EndLine();
            }
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
