// ----------------------------------------------------------------------------
abstract class IRadishAnimatedActor {
   public function getId(): String;
   public function getAnimatedEntity(): CEntity;

   public function getAnimationSequence(): array<CName>;
   public function getIdleAnimationName(): CName;
   public function getMimicsAnimationName(): CName;

   public function hasAnimation(): bool;
   public function hasMimicsAnimation(): bool;
   public function hasIdleAnimation(): bool;
}
// ----------------------------------------------------------------------------
// Callback for animation start/ends
abstract class IRadishAnimStateCallback {
    public function onAnimationStart();
    public function onAnimationEnd();
}
// ----------------------------------------------------------------------------
// Starting/stoping animations of all actors in a shot
//
class CRadishAnimationDirector {
    // ------------------------------------------------------------------------
    // this actor set defines what actors are available for animation
    private var actors: array<IRadishAnimatedActor>;
    // ------------------------------------------------------------------------
    // required for resetting the position of actors (eg. for looped animations)
    //private var thePlacementDirector: CModStoryBoardPlacementDirector;

    // "low-level" animation sequencer
    private var animSequencer: CRadishAnimationSequencer;

    // fake a "continous" idle pose animation by looping a couple of times after
    // normal animation
    private var idleLoops: int; default idleLoops = 5;

    // optional callback to indicate start/stop of animations
    private var animStateCallback: IRadishAnimStateCallback;
    // ------------------------------------------------------------------------
    //public function init(placementDirector: CModStoryBoardPlacementDirector) {
    public function init() {
        //thePlacementDirector = placementDirector;

        animSequencer = new CRadishAnimationSequencer in this;
        // required for callback
        animSequencer.init(this);
    }
    // ------------------------------------------------------------------------
    public function setActors(actors: array<IRadishAnimatedActor>) {
        this.actors = actors;
    }
    // ------------------------------------------------------------------------
    public function startIdlePoseForActor(actor: IRadishAnimatedActor) : bool {
        var animSequence: array<CName>;

        // stop current animation - but only for this actor as a stop means no
        // freeze on end and thus some monsters WILL run away...
        animSequencer.stopAnimationsFor(actor.getId());

        // reposition actor to shot placement
//thePlacementDirector.resetPosition(actor);
        if (actor.hasIdleAnimation()) {
            appendFakeLoop(animSequence, actor.getIdleAnimationName(), idleLoops);
        }

        return animSequencer.setupAnimSequence(
            actor.getId(), animSequence, actor.getAnimatedEntity());
    }
    // ------------------------------------------------------------------------
    public function startAnimationForActor(
        actor: IRadishAnimatedActor, callback: IRadishAnimStateCallback) : bool
    {
        // stop current animation - but only for this actor as a stop means no
        // freeze on end and thus some monsters WILL run away...
        animSequencer.stopAnimationsFor(actor.getId());

        animStateCallback = callback;

        // reposition actor to shot placement
//thePlacementDirector.resetPosition(actor);

        // start currently set animation (if any is set)
        if (setupAnimationForActor(actor, false)) {
            animSequencer.startAnimations();

            animStateCallback.onAnimationStart();
            return true;
        }
        return false;
    }
    // ------------------------------------------------------------------------
    public function startMimicsForActor(actor: IRadishAnimatedActor) : bool {
        var animSequence: array<CName>;
        var mimicsActor: CActor;

        // stop current animation - but only for this actor as a stop means no
        // freeze on end and thus some monsters WILL run away...
        animSequencer.stopAnimationsFor(actor.getId());

        // this will not start the "normal" animation as anims may move actor
        // and mimics preview needs close cam
        // BUT it will start an idle loop
        if (actor.hasIdleAnimation()) {
            appendFakeLoop(animSequence, actor.getIdleAnimationName(), idleLoops);

            animSequencer.setupAnimSequence(
                actor.getId(), animSequence, actor.getAnimatedEntity());
        }

        if (actor.hasMimicsAnimation()) {
            mimicsActor = (CActor)(actor.getAnimatedEntity());
            return mimicsActor.PlayMimicAnimationAsync(actor.getMimicsAnimationName());
        }
        return true;
    }
    // ------------------------------------------------------------------------
    private function appendFakeLoop(
        out animSequence: array<CName>, animName: CName, loops: int)
    {
        var i: int;
        for (i = 0; i < loops; i += 1) {
            animSequence.PushBack(animName);
        }
    }
    // ------------------------------------------------------------------------
    private function setupAnimationForActor(
        actor: IRadishAnimatedActor, optional noIdleLoop: bool) : bool
    {
        var result: bool;
        var mimicsActor: CActor;
        var animSequence: array<CName>;
        var i: int;

        if (actor.hasMimicsAnimation()) {
            mimicsActor = (CActor)(actor.getAnimatedEntity());
            mimicsActor.PlayMimicAnimationAsync(actor.getMimicsAnimationName());
        }

        // idle animation defined by pose will be appended after "normal"
        // animation or played instead to simulate specified pose. Otherwise
        // only a freeze at end or blend to default actor animation would be
        // possible. this also prevents some actors, especially monsters (I'm
        // looking at you bies!) to walk away since at end of sequence the actor
        // is frozen
        if (actor.hasAnimation()) {
            animSequence = actor.getAnimationSequence();

            if (!noIdleLoop && actor.hasIdleAnimation()) {
                appendFakeLoop(animSequence, actor.getIdleAnimationName(), idleLoops);
            }
        } else {
            // no "main" animation -> use more idle loops as some idle anims are
            // short
            if (actor.hasIdleAnimation()) {
                appendFakeLoop(animSequence, actor.getIdleAnimationName(), idleLoops * 2);
            }
        }

        result = animSequencer.setupAnimSequence(
                actor.getId(), animSequence, actor.getAnimatedEntity());

        if (!result) {
            LogChannel('RadUi', "ERROR: animDirector setupAnimationSequence failed for " + actor.getId());
            for (i = 0; i < animSequence.Size(); i += 1) {
                LogChannel('RadUi', "animdirector.animSequence " + i + " : " + animSequence[i]);
            }
        }
        return result;
    }
    // ------------------------------------------------------------------------
    // preconditions:
    //  - animations already stopped
    //  - placement of actors already prepared for start
    public function startAllActorsAnimations(optional callback: IRadishAnimStateCallback) : bool {
        var actorCount: int = actors.Size();
        var i: int;

        animStateCallback = callback;

        for (i = 0; i < actorCount; i += 1) {
            if (!setupAnimationForActor(actors[i])) {
                return false;
            }
        }

        animSequencer.startAnimations();
        return true;
    }
    // ------------------------------------------------------------------------
    public function stopAnimations() {
        animSequencer.stopAnimations();
    }
    // ------------------------------------------------------------------------
    // callback for animSequencer to indicate sequence ended
    public function onSequenceEnd() {
        if (animStateCallback) {
            animStateCallback.onAnimationEnd();
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
state RadAnim_Idle in CRadishAnimationSequencer {}
// ----------------------------------------------------------------------------
state RadAnim_Active in CRadishAnimationSequencer {
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: name) {
        super.OnEnterState(prevStateName);
        Run();
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(prevStateName: name) {
        super.OnLeaveState(prevStateName);

        parent.masterEntity.OnSyncAnimEnd();
        // inform animation director about end of all sequences (events would be
        // nicer - this is a shortcut...)
        parent.animDirector.onSequenceEnd();
    }
    // ------------------------------------------------------------------------
    entry function Run() {
        var size: int = parent.seqInstances.Size();
        var i: int;

        while (size > 0) {
            for (i = size - 1; i >= 0; i -= 1) {
                parent.seqInstances[i].update(theTimer.timeDelta);

                if (parent.seqInstances[i].hasEnded()) {
                    parent.seqInstances.Erase(i);
                }
            }

            SleepOneFrame();
            size = parent.seqInstances.Size();
        }

        parent.PopState(true);
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// wrapper around SlotSyncInstance with embedded id to be able to stop sequence
// for specific actors
class CRadishAnimSequence {
    var sequenceId: String;
    var slotSyncInstance: CAnimationManualSlotSyncInstance;
    // ------------------------------------------------------------------------
    public function stop() {
        // stop at first sequence (even if more sequences are set it will
        // stop immediately)
        slotSyncInstance.StopSequence(0);
    }
    // ------------------------------------------------------------------------
    public function update(delta: float) { slotSyncInstance.Update(delta); }
    public function hasEnded() : bool { return slotSyncInstance.HasEnded(); }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
// sequencer to playback animations for *one* actor with the possibility to chain
// multiple animations.
// ripped from W3SyncAnimationManager
//
statemachine class CRadishAnimationSequencer {
    // ------------------------------------------------------------------------
    default autoState = 'RadAnim_Idle';
    // ------------------------------------------------------------------------
    protected var seqInstances: array<CRadishAnimSequence>;
    protected var masterEntity: CGameplayEntity;

    protected var animDirector: CRadishAnimationDirector;
    // ------------------------------------------------------------------------
    public function init(animDirector: CRadishAnimationDirector) {
        this.animDirector = animDirector;
    }
    // ------------------------------------------------------------------------
    private function createNewAnimSequence(
        sequenceId: String, out index: int) : CRadishAnimSequence
    {
        var newAnimSequence: CRadishAnimSequence;

        newAnimSequence = new CRadishAnimSequence in this;

        newAnimSequence.sequenceId = sequenceId;
        newAnimSequence.slotSyncInstance = new CAnimationManualSlotSyncInstance in newAnimSequence;

        seqInstances.PushBack(newAnimSequence);

        index = seqInstances.Size() - 1;

        return newAnimSequence;
    }
    // ------------------------------------------------------------------------
    private function setupSequencePart(
        idx: int, animName: CName) : SAnimationSequencePartDefinition
    {
        var sequencePart: SAnimationSequencePartDefinition;

        sequencePart.animation = animName;
        sequencePart.syncType = AMST_SyncBeginning;
        sequencePart.syncEventName = 'SyncEvent';
        sequencePart.shouldSlide = false;
        sequencePart.shouldRotate = false;
        sequencePart.blendInTime = 0;
        sequencePart.blendOutTime = 0;
        sequencePart.sequenceIndex = idx;

        return sequencePart;
    }
    // ------------------------------------------------------------------------
    public function setupAnimSequence(
        sequenceId: String, animNames: array<CName>, entity: CEntity) : bool
    {
        var animSequence: CRadishAnimSequence;
        var masterDef: SAnimationSequenceDefinition;
        var instanceIndex: int;
        var sequenceIndex: int;
        var i: int;

        var actor: CActor;

        var rot : EulerAngles = entity.GetWorldRotation();
        var pos : Vector = entity.GetWorldPosition();

        animSequence = createNewAnimSequence(sequenceId, instanceIndex);

        for (i = 0; i < animNames.Size(); i += 1) {
            masterDef.parts.PushBack(setupSequencePart(i, animNames[i]));
        }
        masterDef.entity = entity;
        if (((CNewNPC)entity).IsHorse()) {
            masterDef.manualSlotName = 'MANUAL_DIALOG_SLOT';
        } else {
            masterDef.manualSlotName = 'GAMEPLAY_SLOT';
        }
        masterDef.freezeAtEnd = true;

        sequenceIndex = animSequence.slotSyncInstance.RegisterMaster(masterDef);
        if (sequenceIndex == -1) {
            seqInstances.Remove( animSequence );
            return false;
        }

        // these are probably not required for the storyboard sequencer
        actor = (CActor)entity;
        if (actor) {
            actor.SignalGameplayEventParamInt('SetupSyncInstance', instanceIndex);
            actor.SignalGameplayEventParamInt('SetupSequenceIndex', sequenceIndex);
            actor.SignalGameplayEvent('PlaySyncedAnim');
        }

        return true;
    }
    // ------------------------------------------------------------------------
    public function startAnimations() {
        if (GetCurrentStateName() != 'RadAnim_Active' && seqInstances.Size() > 0) {
            GotoState('RadAnim_Active', true);
        }
    }
    // ------------------------------------------------------------------------
    public function stopAnimations() {
        var i: int;

        for (i = seqInstances.Size() - 1; i >= 0; i -= 1) {
            seqInstances[i].stop();
        }
    }
    // ------------------------------------------------------------------------
    public function stopAnimationsFor(animSequenceId: String) {
        var i: int;

        for (i = seqInstances.Size() - 1; i >= 0; i -= 1) {
            if (seqInstances[i].sequenceId == animSequenceId) {
                seqInstances[i].stop();
            }
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
