// ----------------------------------------------------------------------------
//
// BUGS:
//
// TODO:
//  - replace apple with good visible (white glowing?) sphere entity
//
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// assigning setup lookats to actors
//
class CModStoryBoardLookAtDirector {
    // ------------------------------------------------------------------------
    // defines what actors are available to setup lookats
    private var actors: array<CModStoryBoardActor>;

    // set of static (invisible?) lookat points to be tracked by actors (will
    // always be equal to number of actors)
    private var staticPoints: array<CEntity>;
    // ------------------------------------------------------------------------
    // ------------------------------------------------------------------------
    public function init() {}
    // ------------------------------------------------------------------------
    public function deactivate() {
        var i: int;
        var s: int = staticPoints.Size();

        for (i = s; i > 0; i -= 1) {
            staticPoints.PopBack().Destroy();
        }
    }
    // ------------------------------------------------------------------------
    public function showStaticPoint(
        actor: CModStoryBoardActor, optional forceShow: bool)
    {
        var i: int;

        i = actors.FindFirst(actor);
        staticPoints[i].SetHideInGame(!(forceShow || actor.isStaticLookAt()));
    }
    // ------------------------------------------------------------------------
    public function hideStaticPoint(actor: CModStoryBoardActor) {
        var i: int;

        i = actors.FindFirst(actor);
        staticPoints[i].SetHideInGame(true);
    }
    // ------------------------------------------------------------------------
    public function hideStaticPoints() {
        var i: int;
        for (i = 0; i < staticPoints.Size(); i += 1) {
            staticPoints[i].SetHideInGame(true);
        }
    }
    // ------------------------------------------------------------------------
    private function createStaticPoint() : CEntity {
        var template: CEntityTemplate;
        var entity: CEntity;

        template = (CEntityTemplate)LoadResource(
            "dlc/modtemplates/storyboardui/sphere.w2ent", true);

        // spawning sphere at 0/0/0 makes it invisible even if it is teleported
        // to a cam visible position lateron (streaming settings of ent?)
        entity = theGame.CreateEntity(template, thePlayer.GetWorldPosition());
        entity.SetHideInGame(true);

        return entity;
    }
    // ------------------------------------------------------------------------
    public function setActors(actors: array<CModStoryBoardActor>) {
        var a: int = actors.Size();
        var p: int = staticPoints.Size();
        var i: int;

        this.actors = actors;

        // sync number of static lookat points
        if (a != p) {
            if (a < p) {
                for (i = p; i > a; i -= 1) {
                    staticPoints.PopBack().Destroy();
                }
            } else {
                for (i = p; i < a; i += 1) {
                    staticPoints.PushBack(createStaticPoint());
                }
            }
        }
    }
    // ------------------------------------------------------------------------
    public function onDeleteAsset(assetId: String) {
        var shotSettings: SStoryBoardShotAssetSettings;
        var lookAtSettings: SStoryBoardLookAtSettings;
        var i: int;

        // make sure no other lookat settings references the deleted asset
        for (i = 0; i < actors.Size(); i += 1) {
            shotSettings = actors[i].getShotSettings();

            if (shotSettings.lookAt.lookAtActor == assetId) {
                actors[i].setLookAt(SStoryBoardLookAtSettings(false));
                actors[i].disableLookAt();
            }
        }
    }
    // ------------------------------------------------------------------------
    public function getStaticLookAtPosition(
        sbActor: CModStoryBoardActor) : SStoryBoardLookAtSettings
    {
        var shotSettings: SStoryBoardShotAssetSettings = sbActor.getShotSettings();
        var lookAtSettings: SStoryBoardLookAtSettings = shotSettings.lookAt;
        var actor: CModStoryBoardActor;
        var i: int;
        var pos, null: Vector;

        // interactive lookats adjustment switch to static mode -> recalculate
        // current lookat to a pos which will be interactively updated
        if (lookAtSettings.lookAtActor != "") {

            // try to get head of looked at actor
            for (i = 0; i < actors.Size(); i += 1) {
                if (actors[i].getId() == lookAtSettings.lookAtActor) {

                    lookAtSettings.rot = VecToRotation(
                        VecTransform(
                            MatrixBuiltRotation(
                                EulerAngles(0, -sbActor.getEntity().GetHeading(), 0)
                            ),
                            actors[i].getHeadPosition() - sbActor.getHeadPosition()
                        )
                    );

                    break;
                }
            }

        } else {
            // looking straight ahead
            lookAtSettings.rot = EulerAngles(0, 0, 0);
            lookAtSettings.distance = 1.0;
        }

        // it has to be static now
        lookAtSettings.enabled = true;
        lookAtSettings.lookAtActor = "";

        return lookAtSettings;
    }
    // ------------------------------------------------------------------------
    public function repositionStaticLookAt(
        actor: CModStoryBoardActor, lookAtSettings: SStoryBoardLookAtSettings)
    {
        var point: CEntity;
        var pos: Vector;
        var i: int;

        i = actors.FindFirst(actor);

        // use reserved static point of this actor
        if (i >= 0) {
            point = staticPoints[i];

            pos = VecTransform(
                MatrixBuiltTranslation(actor.getHeadPosition()) *
                MatrixBuiltRotation(EulerAngles(0, actor.getEntity().GetHeading(), 0)) *
                MatrixBuiltRotation(lookAtSettings.rot),
                Vector(0, lookAtSettings.distance, 0)
            );

            point.Teleport(pos);

            // update staring node only if actor is not already staring at it
            if (!actor.isStaticLookAt()) {
                actor.staticLookAt(point);
            }
        }

        lookAtSettings.lookAtActor = "";
        actor.setLookAt(lookAtSettings);
    }
    // ------------------------------------------------------------------------
    public function refreshLookAtForActor(actor: CModStoryBoardActor) {
        var point: CEntity;
        var null: Vector;
        var shotSettings: SStoryBoardShotAssetSettings = actor.getShotSettings();
        var lookAtSettings: SStoryBoardLookAtSettings = shotSettings.lookAt;
        var i: int;

        if (lookAtSettings.enabled) {
            if (lookAtSettings.lookAtActor != "") {
                // find lookedAtNode
                for (i = 0; i < actors.Size(); i += 1) {
                    if (actors[i].getId() == lookAtSettings.lookAtActor) {
                        actor.dynamicLookAt(actors[i].getEntity());
                        return;
                    }
                }
            } else {
                return repositionStaticLookAt(actor, lookAtSettings);
            }
        }
        actor.disableLookAt();
    }
    // ------------------------------------------------------------------------
    public function startShotLookAts() {
        var actorCount: int = actors.Size();
        var i: int;

        for (i = 0; i < actorCount; i += 1) {
            // disable look at to let actor move into "normal" position so a
            // successive look at in different direction is catched ?
            //actors[i].disableLookAt();
            refreshLookAtForActor(actors[i]);
        }
    }
    // ------------------------------------------------------------------------
    public function transformToStaticPos(
        actorId: String, lookAtAngles: EulerAngles, distance: Float) : Vector
    {
        var i: int;
        var actorRot: EulerAngles;

        // find actor to get head position (actor MUST be already placed correctly!)
        for (i = 0; i < actors.Size(); i += 1) {
            if (actors[i].getId() == actorId) {

                actorRot = actors[i].getEntity().GetWorldRotation();
                if (distance < 0.5) {
                    distance = 0.5;
                }

                return VecTransform(
                    MatrixBuiltRotation(EulerAngles(
                        -actorRot.Pitch, -actorRot.Yaw, -actorRot.Roll
                    )),
                    VecTransform(
                        MatrixBuiltTranslation(actors[i].getHeadPosition()) *
                        MatrixBuiltRotation(EulerAngles(0, actors[i].getEntity().GetHeading(), 0)) *
                        MatrixBuiltRotation(lookAtAngles),
                        Vector(0, distance, 0)
                    ) - actors[i].getEntity().GetWorldPosition()
                );
            }
        }
        return Vector(0, 0, 0);
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
