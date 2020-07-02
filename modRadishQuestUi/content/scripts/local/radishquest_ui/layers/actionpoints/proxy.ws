// ----------------------------------------------------------------------------
class CRadishActionpointProxy extends CRadishProxyRepresentation {
    // ------------------------------------------------------------------------
    //protected var showMarker: bool;
    //protected var showActor: bool;
    // ------------------------------------------------------------------------
    private var category: String;
    private var action: String;
    private var actionInfo: SRadishAnimSequenceInfo;

    private var actorTemplate: String;
    private var actorProxy: CActor;
    private var actorProxyIsFrozen: bool;
    private var interactivePositioningOffset: Vector;
    // ------------------------------------------------------------------------
    public function setSettings(settings: SRadishLayerActionpointData) {
        if (placement != settings.placement) {
            placement = settings.placement;
            moveTo(placement);
        }
        category = settings.category;
        action = settings.action;

        //appearanceId = settings.appearance;

        // TODO if different actor template -> respawn
    }
    // ------------------------------------------------------------------------
    /*public function setActorTemplate(optional template: String, optional appearance: name) {

    }*/
    // ------------------------------------------------------------------------
    public function getActionId() : String {
        return category + ":" + action;
    }
    // ------------------------------------------------------------------------
    public function getCategory() : String {
        return category;
    }
    // ------------------------------------------------------------------------
    public function getAction() : String {
        return action;
    }
    // ------------------------------------------------------------------------
    public function setActionId(newActionId: String) {
        StrSplitFirst(newActionId, ":", category, action);
    }
    // ------------------------------------------------------------------------
    public function setActionInfo(actionInfo: SRadishAnimSequenceInfo) {
        this.actionInfo = actionInfo;
    }
    // ------------------------------------------------------------------------
    public function show(doShow: bool) {
        if (isVisible != doShow) {
            // ignore a hide if it's currently highlighted -> just despawn
            // actorproxy in this case
            if (isHighlighted) {
                if (!doShow && actorProxy) {
                    despawnActor();
                }
            } else {
                showProxy(doShow);
            }
            isVisible = doShow;
        }
    }
    // ------------------------------------------------------------------------
    protected function showProxy(doShow: bool) {
        proxy.SetHideInGame(!doShow);
        // actorproxies are only shown if preview animation is started
        // BUT actorproxies are despawned every time the proxy should be hidden.
        if (!doShow && actorProxy) {
            despawnActor();
        }
    }
    // ------------------------------------------------------------------------
    protected function spawn() {
        super.spawn();
        meshSize = Vector(1.0, 1.0, 1.0, 1.0);

        if (actorTemplate != "") {
            spawnActor();
        }
    }
    // ------------------------------------------------------------------------
    protected function spawnActor() {
        var template: CEntityTemplate;
        var aiTree: CAIIdleTree;

        template = (CEntityTemplate)LoadResource(actorTemplate, true);

        actorProxy = (CActor)theGame.CreateEntity(template, placement.pos, placement.rot);
        actorProxy.AddTag('RADUI');

        actorProxy.EnableCharacterCollisions(false);
        // make sure *everybody* is friendly or they attack player
        actorProxy.SetTemporaryAttitudeGroup('q104_avallach_friendly_to_all', AGP_Default);

        // force actor to stay in place
        aiTree = new CAIIdleTree in actorProxy;
        aiTree.OnCreated();
        actorProxy.ForceAIBehavior(aiTree, BTAP_AboveCombat);
    }
    // ------------------------------------------------------------------------
    protected function despawnActor() {
        var null: CActor;

        actorProxy.StopAllEffects();
        actorProxy.Destroy();
        actorProxy = null;
        actorProxyIsFrozen = false;
        actorTemplate = "";
    }
    // ------------------------------------------------------------------------
    public function setActorTemplate(template: String, optional showActor: bool) {
        var inv: CInventoryComponent;

        if (template != actorTemplate) {
            despawnActor();
        }
        actorTemplate = template;
        if (showActor) {
            if (!actorProxy) {
                spawnActor();
            } else {
                actorProxy.TeleportWithRotation(placement.pos, placement.rot);
            }
            inv = actorProxy.GetInventory();

            inv.UnmountItem(inv.GetItemFromSlot('r_weapon'), true);
            inv.UnmountItem(inv.GetItemFromSlot('l_weapon'), true);
        }
    }
    // ------------------------------------------------------------------------
    public function getActorEntity() : CActor {
        return actorProxy;
    }
    // ------------------------------------------------------------------------
    public function freezeActor() {
        var animatedComponent: CAnimatedComponent;
        var mac: CMovingPhysicalAgentComponent;

        if (actorProxy) {
            animatedComponent = (CAnimatedComponent)actorProxy
                .GetComponentByClassName('CAnimatedComponent');

            if (!animatedComponent.HasFrozenPose()) {
                animatedComponent.FreezePose();
                actorProxyIsFrozen = true;

                actorProxy.EnableCollisions(false);
                mac = (CMovingPhysicalAgentComponent)((CNewNPC)actorProxy).GetMovingAgentComponent();
                if (mac) {
                    mac.SetEnabledFeetIK(false);
                }
            }
        }
    }
    // ------------------------------------------------------------------------
    public function unfreezeActor() {
        var animatedComponent: CAnimatedComponent;
        var mac: CMovingPhysicalAgentComponent;

        if (actorProxy) {
            animatedComponent = (CAnimatedComponent)actorProxy
                .GetComponentByClassName('CAnimatedComponent');

            if (animatedComponent.HasFrozenPose()) {
                actorProxy.SetBehaviorVariable('requestedFacingDirection',
                    AngleNormalize(placement.rot.Yaw));

                animatedComponent.UnfreezePose();
                actorProxyIsFrozen = false;

                actorProxy.EnableCollisions(true);
                mac = (CMovingPhysicalAgentComponent)((CNewNPC)actorProxy).GetMovingAgentComponent();
                if (mac) {
                    mac.SetEnabledFeetIK(true);
                }
            }
        }
    }
    // ------------------------------------------------------------------------
    public function onPlacementStart() {
        if (!actorProxyIsFrozen) {
            freezeActor();
            interactivePositioningOffset = actorProxy.GetWorldPosition() - placement.pos;
        }
    }
    // ------------------------------------------------------------------------
    public function moveTo(placement: SRadishPlacement) {
        this.placement = placement;
        proxy.TeleportWithRotation(placement.pos, placement.rot);

        if (actorProxy) {
            actorProxy.TeleportWithRotation(
                placement.pos + interactivePositioningOffset, placement.rot);
        }
    }
    // ------------------------------------------------------------------------
    public function onPlacementEnd() {
        if (actorProxyIsFrozen) {
            unfreezeActor();
        }
    }
    // ------------------------------------------------------------------------
    public function getSize() : Vector {
        return meshSize;
    }
    // ------------------------------------------------------------------------
    public function destroy() {
        super.destroy();
        despawnActor();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
