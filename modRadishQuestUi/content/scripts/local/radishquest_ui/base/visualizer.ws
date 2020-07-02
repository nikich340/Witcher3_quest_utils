// ----------------------------------------------------------------------------
// Collection to account for multiple elements highlighted at once
class CRadishProxyGroup extends IRadishHighlightableElement {
    // ------------------------------------------------------------------------
    private var highlighted: array<IRadishHighlightableElement>;
    // ------------------------------------------------------------------------
    private var min, max: Vector;
    private var size: Vector;
    // ------------------------------------------------------------------------
    public function matchesName(id: String) : bool {
        return false;
    }
    // ------------------------------------------------------------------------
    public function add(item: IRadishHighlightableElement) {
        var itemPos: SRadishPlacement;

        item.highlight(true);
        highlighted.PushBack(item);

        // this is not entirely correct as area size is not taken into account
        itemPos = item.getPlacement();

        if (highlighted.Size() == 1) {
            min = itemPos.pos;
            max = itemPos.pos;
        } else {
            max.X = MaxF(max.X, itemPos.pos.X);
            max.Y = MaxF(max.Y, itemPos.pos.Y);
            max.Z = MaxF(max.Z, itemPos.pos.Z);

            min.X = MinF(min.X, itemPos.pos.X);
            min.Y = MinF(min.Y, itemPos.pos.Y);
            min.Z = MinF(min.Z, itemPos.pos.Z);
        }
    }
    // ------------------------------------------------------------------------
    public function clear() {
        highlight(false);
        highlighted.Clear();
        min = Vector();
        max = Vector();
        size = Vector();
    }
    // ------------------------------------------------------------------------
    public function isEmpty() : bool {
        return highlighted.Size() == 0;
    }
    // ------------------------------------------------------------------------
    public function highlight(doHighlight: bool) {
        var i, s: int;
        s = highlighted.Size();

        for (i = 0; i < s; i += 1) {
            highlighted[i].highlight(doHighlight);
        }
    }
    // ------------------------------------------------------------------------
    public function getPlacement() : SRadishPlacement {
        return SRadishPlacement(min + 0.5 * (max - min));
    }
    // ------------------------------------------------------------------------
    public function getSize() : Vector {
        var meshSize: Vector;

        if (highlighted.Size() > 1) {
            // approx by using bounding box of centers
            meshSize = max - min;
            // scale height with size (taken from areas meshsize)
            meshSize.Z = MaxF(2.0f, 0.5f * MinF(499, MaxF(meshSize.X, meshSize.Y)));

            return meshSize;
        } else {
            return highlighted[0].getSize();
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
abstract class CAnimatedProxyWrapper extends IRadishAnimatedActor {
    // ------------------------------------------------------------------------
    protected var id: String;
    protected var animInfo: SRadishAnimSequenceInfo;
    // ------------------------------------------------------------------------
    public function getId(): String {
        return id;
    }
    // ------------------------------------------------------------------------
    public function getAnimationSequence(): array<CName> {
        return animInfo.animSequence;
    }
    // ------------------------------------------------------------------------
    public function getIdleAnimationName(): CName {
        return '';
    }
    // ------------------------------------------------------------------------
    public function getMimicsAnimationName(): CName {
        return '';
    }
    // ------------------------------------------------------------------------
    public function hasAnimation(): bool {
        return true;
    }
    // ------------------------------------------------------------------------
    public function hasMimicsAnimation(): bool {
        return false;
    }
    // ------------------------------------------------------------------------
    public function hasIdleAnimation(): bool {
        return false;
    }
    // ------------------------------------------------------------------------
    public function hasAnimSequence() : bool;
    public function setAnimSequence(seq: SRadishAnimSequenceInfo);
    public function getAnimatedEntity(): CEntity;
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CAnimatedActionpoint extends CAnimatedProxyWrapper {
    // ------------------------------------------------------------------------
    private var ap: CRadishActionpointProxy;
    // ------------------------------------------------------------------------
    private var lastActionId: String;
    // ------------------------------------------------------------------------
    public function init(id: String, ap: CRadishActionpointProxy) {
        this.id = id;
        this.ap = ap;
    }
    // ------------------------------------------------------------------------
    public function getActionId() : String {
        return ap.getActionId();
    }
    // ------------------------------------------------------------------------
    public function hasAnimSequence() : bool {
        // update to sequence is required if action changed
        return lastActionId == ap.getActionId();
    }
    // ------------------------------------------------------------------------
    public function setAnimSequence(seq: SRadishAnimSequenceInfo) {
        lastActionId = ap.getActionId();
        animInfo = seq;
        ap.setActorTemplate(seq.template, true);
    }
    // ------------------------------------------------------------------------
    public function getAnimatedEntity(): CEntity {
        return ap.getActorEntity();
    }
    // ------------------------------------------------------------------------
    /*
    public function freeze() {
        var animatedComponent: CAnimatedComponent;

        animatedComponent = (CAnimatedComponent)((CActor)entity)
            .GetComponentByClassName('CAnimatedComponent');

        animatedComponent.FreezePose();
    }
    // ------------------------------------------------------------------------
    public function unfreeze() {
        var animatedComponent: CAnimatedComponent;
        var actor: CActor;

        animatedComponent = (CAnimatedComponent)((CActor)entity)
            .GetComponentByClassName('CAnimatedComponent');

        if (animatedComponent.HasFrozenPose()) {

            actor = (CActor)entity;
            actor.SetBehaviorVariable('requestedFacingDirection',
                AngleNormalize(shotSettings.placement.rot.Yaw));

            animatedComponent.UnfreezePose();
        }
    }
    // ------------------------------------------------------------------------
    private function preventBehTreeRotation() {
        var movementAdjustor: CMovementAdjustor;
        var ticket : SMovementAdjustmentRequestTicket;

        movementAdjustor = ((CActor)entity).GetMovingAgentComponent().GetMovementAdjustor();
        // prevent beh tree to turn around
        movementAdjustor.CancelByName('RotateAwayEvent');
        movementAdjustor.CancelByName('RotateEvent');

        ticket = movementAdjustor.CreateNewRequest('RotateAwayEvent');
        movementAdjustor.Continuous(ticket);
        movementAdjustor.RotateTo(ticket, shotSettings.placement.rot.Yaw);
    }
    // ------------------------------------------------------------------------
    public function setPlacement(
        newPlacement: SStoryBoardPlacementSettings, optional dontUpdateShotSettings: bool)
    {
        super.setPlacement(newPlacement, dontUpdateShotSettings);

        // Teleporting with rotation makes the actor rotate back (don't know
        // how to properly rotate without animation). workaround is to setup
        // a (fast) rotate request in the movement adjuster
        if (!dontUpdateShotSettings){
            preventBehTreeRotation();
        }
    }*/
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CRadishProxyVisualizer {
    private var log: CModLogger;
    private var conf: CRadishQuestConfigManager;
    // ------------------------------------------------------------------------
    private var theCam: CRadishStaticCamera;
    // ------------------------------------------------------------------------
    private var animSeqProvider: JobTreeAnimSequenceProvider;
    // ------------------------------------------------------------------------
    private var layerManager: CRadishQuestLayerManager;
    private var lastUpdate: float;
    // ------------------------------------------------------------------------
    private var animDirector: CRadishAnimationDirector;
    // ------------------------------------------------------------------------
    // tracks all hightlighted elements
    private var highlighted: CRadishProxyGroup;
    // tracks all selected for animations
    private var animatedProxies: array<CAnimatedProxyWrapper>;

    // caches for all highlight-/animateable layer entities
    private var areas: array<IRadishHighlightableElement>;
    private var actionpoints: array<IRadishHighlightableElement>;
    private var waypoints: array<IRadishHighlightableElement>;
    // ------------------------------------------------------------------------
    public function init(
        log: CModLogger,
        animSeqProvider: JobTreeAnimSequenceProvider,
        layerManager: CRadishQuestLayerManager,
        conf: CRadishQuestConfigManager)
    {
        this.lastUpdate = -1;
        this.log = log;
        this.conf = conf;

        this.animSeqProvider = animSeqProvider;
        this.animDirector = new CRadishAnimationDirector in this;
        this.animDirector.init();

        this.layerManager = layerManager;

        this.highlighted = new CRadishProxyGroup in this;
    }
    // ------------------------------------------------------------------------
    public function setCam(cam: CRadishStaticCamera) {
        this.theCam = cam;
    }
    // ------------------------------------------------------------------------
    public function refreshHighlight(forceCamSwitch: bool) {
        highlighted.highlight(true);

        if (!highlighted.isEmpty() && (forceCamSwitch || conf.isAutoCamOnSelect())) {
            theCam.setSettings(RadUi_createCamSettingsFor(RadUiCam_EntityPreview, highlighted));
            theCam.switchTo();
        }
    }
    // ------------------------------------------------------------------------
    private function adjustCam() {
        if (conf.isAutoCamOnSelect() && !highlighted.isEmpty()) {
            theCam.setSettings(RadUi_createCamSettingsFor(RadUiCam_EntityPreview, highlighted));
            theCam.switchTo();
        }
    }
    // ------------------------------------------------------------------------
    public function clearHighlighted() {
        lazyEntitiesRefresh();
        highlighted.clear();
    }
    // ------------------------------------------------------------------------
    public function highlight(typedId: String) {
        lazyEntitiesRefresh();
        highlighted.clear();

        doHighlight(typedId);
        adjustCam();
    }
    // ------------------------------------------------------------------------
    public function highlightMultiple(typedIds: array<String>) {
        var i, s: int;
        lazyEntitiesRefresh();
        highlighted.clear();

        s = typedIds.Size();
        for (i = 0; i < s; i += 1) {
            doHighlight(typedIds[i]);
        }
        adjustCam();
    }
    // ------------------------------------------------------------------------
    protected function doHighlight(typedId: String) {
        var type, id: String;

        log.debug("highlight " + typedId);

        StrSplitFirst(typedId, "|", type, id);
        switch (type) {
            case "area":            highlightItems(areas, id); break;
            case "actionpoint":     highlightItems(actionpoints, id); break;
            case "waypoint":        highlightItems(waypoints, id); break;
        }
    }
    // ------------------------------------------------------------------------
    protected function highlightItems(items: array<IRadishHighlightableElement>, id: string) {
        var i, s: int;
        s = items.Size();

        for (i = 0; i < s; i += 1) {
            if (items[i].matchesName(id)) {
                highlighted.add(items[i]);
            }
        }
    }
    // ------------------------------------------------------------------------
    public function resetAnimated() {
        animDirector.stopAnimations();
        animatedProxies.Clear();
    }
    // ------------------------------------------------------------------------
    protected function selectApsForAnimation(id: SRadUiLayerEntityId) {
        var animatedAp: CAnimatedActionpoint;
        var ap: CRadishQuestLayerActionpoint;
        var i, s: int;
        var checkedId: SRadUiLayerEntityId;
        var all: bool;

        s = actionpoints.Size();
        all = id.entityName == "*";

        for (i = 0; i < s; i += 1) {
            ap = (CRadishQuestLayerActionpoint)actionpoints[i];
            checkedId = ap.getId();
            if (checkedId.layerId == id.layerId
                && (all || (checkedId.entityName == id.entityName && checkedId.no == id.no)))
            {
                animatedAp = new CAnimatedActionpoint in this;
                animatedAp.init(ap.getIdString(), (CRadishActionpointProxy)ap.getProxy());

                animatedProxies.PushBack(animatedAp);
            }
        }
    }
    // ------------------------------------------------------------------------
    public function selectForAnimation(type: String, id: SRadUiLayerEntityId) : int {
        var i, s: int;
        var actors: array<IRadishAnimatedActor>;

        animDirector.stopAnimations();
        lazyEntitiesRefresh();

        switch (type) {
            case "actionpoint": selectApsForAnimation(id); break;
        }

        actors.Clear();
        for (i = 0; i < animatedProxies.Size(); i += 1) {
            actors.PushBack(animatedProxies[i]);
        }
        animDirector.setActors(actors);

        return actors.Size();
    }
    // ------------------------------------------------------------------------
    public function startAnimations(optional callback: IRadishAnimStateCallback) : bool {
        var actionpoint: CAnimatedActionpoint;
        var i, s: int;
        s = animatedProxies.Size();

        // update animsequence on demand
        for (i = 0; i < s; i += 1) {
            actionpoint = (CAnimatedActionpoint)animatedProxies[i];
            if (actionpoint && !actionpoint.hasAnimSequence()) {
                actionpoint.setAnimSequence(
                    animSeqProvider.getActionInfo(actionpoint.getActionId()));
            }
        }

        return animDirector.startAllActorsAnimations(callback);
    }
    // ------------------------------------------------------------------------
    public function stopAnimations() {
        animDirector.stopAnimations();
    }
    // ------------------------------------------------------------------------
    protected function resetEntityReferences() {
        areas.Clear();
        actionpoints.Clear();
        waypoints.Clear();
    }
    // ------------------------------------------------------------------------
    protected function lazyEntitiesRefresh() {
        var layers: array<CRadishQuestLayer>;
        var items: array<CRadishLayerEntity>;
        var layerUpdate: float;
        var e, i, s, es: int;

        layerUpdate = layerManager.getLastUpdated();
        if (lastUpdate >= layerUpdate) {
            return;
        }
        resetEntityReferences();

        layers = layerManager.getLayers();
        s = layers.Size();
        for (i = 0; i < s; i += 1) {
            if (((CEncodedRadishQuestLayer)layers[i]).isShadowed()) {
                continue;
            }
            items = layers[i].getItems();

            es = items.Size();
            for (e = 0; e < es; e += 1) {
                // highlighting only interesting in a couple of categories
                switch (items[e].getType()) {
                    case "area":        areas.PushBack(items[e]); break;
                    case "actionpoint": actionpoints.PushBack(items[e]); break;
                    case "waypoint":    waypoints.PushBack(items[e]); break;
                }
            }
        }

        this.lastUpdate = layerUpdate;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
