// ----------------------------------------------------------------------------
//
// BUGS:
//  - different sizes for assets require more dynamic default placement based on
//      sizes of all previous assets
//
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// default placement and placement per shot
//
class CModStoryBoardPlacementDirector {
    // ------------------------------------------------------------------------
    // this asset set defines what assets are available for placement
    private var assets: array<CModStoryBoardAsset>;
    // ------------------------------------------------------------------------
    // define the origin to use for calculating default coordinates and final
    // tranformation for scene definition log output
    private var originPos: Vector;
    private var originRot: EulerAngles;
    private var originAssetId: String;
    // ------------------------------------------------------------------------
    public function setOrigin(
        origin: SStoryBoardOriginStateData, optional refreshPlacement: Bool)
    {
        originPos = origin.pos;
        originRot = origin.rot;
        originAssetId = origin.assetId;

        if (refreshPlacement) {
            refreshDefaultPlacement();
        }
    }
    // ------------------------------------------------------------------------
    public function setOriginId(assetId: String) {
        originAssetId = assetId;
    }
    // ------------------------------------------------------------------------
    public function getOrigin() : SStoryBoardOriginStateData {
        return SStoryBoardOriginStateData(originAssetId, originPos, originRot);
    }
    // ------------------------------------------------------------------------
    public function getOriginPlacement() : SStoryBoardPlacementSettings {
        return SStoryBoardPlacementSettings(originPos, originRot);
    }
    // ------------------------------------------------------------------------
    public function setAssets(assets: array<CModStoryBoardAsset>) {
        this.assets = assets;

        // init/reset current state to default placing of assets
        this.refreshDefaultPlacement();
    }
    // ------------------------------------------------------------------------
    private function refreshDefaultPlacement() {
        var assetPos, deltaPos: Vector;
        var asset: CModStoryBoardAsset;
        var shotSettings: SStoryBoardShotAssetSettings;
        var null: SStoryBoardPlacementSettings;
        var i, distance: int;
        var itemCount, actorCount: int;
        var groundZ: float;
        var placementOrigin: Vector;
        var theWorld: CWorld;

        theWorld = theGame.GetWorld();

        // use player coordinates as placement origin to ensure the default
        // positions are actually valid ( 0/0/0 spawns cannot be moved!)
        placementOrigin = thePlayer.GetWorldPosition();

        // reposition all assets
        for (i = 0; i < assets.Size(); i += 1) {
            asset = assets[i];

            // FIXME: distance should depend on the size of previous and this asset
            if ((CModStoryBoardActor)asset) {
                distance = 4 * actorCount;
                // actor 0 == player
                actorCount += 1;

                deltaPos.X = distance * - SinF(Deg2Rad(originRot.Yaw - 90));
                deltaPos.Y = distance * CosF(Deg2Rad(originRot.Yaw - 90));
            } else {
                // put on the other side
                itemCount += 1;
                distance = 4 * itemCount;

                deltaPos.X = distance * - SinF(Deg2Rad(originRot.Yaw + 90));
                deltaPos.Y = distance * CosF(Deg2Rad(originRot.Yaw + 90));
            }

            assetPos = placementOrigin + deltaPos;

            // snap to ground
            // PhysicsCorrectZ seems to work only near ground positions
            // readjust first using NavigationComputeZ
            if (theWorld.NavigationComputeZ(
                assetPos, assetPos.Z - 1, assetPos.Z + 3, groundZ)) {

                assetPos.Z = groundZ;
            }
            theWorld.PhysicsCorrectZ(assetPos, groundZ);
            assetPos.Z = groundZ;

            shotSettings = asset.getShotSettings();

            // update shotsettings only if placement was not set previously
            asset.setDefaultPlacement(
                SStoryBoardPlacementSettings(assetPos, originRot),
                shotSettings.placement == null);
        }
    }
    // ------------------------------------------------------------------------
    public function resetPosition(asset: CModStoryBoardAsset) {
        var assetSettings: SStoryBoardShotAssetSettings;
        var newPlacement: SStoryBoardPlacementSettings;

        // Note: these are merely the saved/set *shot* settings and they
        // not necessarily mirror the *current* entity position!
        assetSettings = asset.getShotSettings();
        newPlacement = assetSettings.placement;

        // Note: current entity position/rotation must always be checked
        // since animations may change it
        if (asset.getCurrentPlacement() != newPlacement) {
            // set the entity position to the defined shot settings
            asset.setPlacement(newPlacement);
        }
    }
    // ------------------------------------------------------------------------
    public function refreshPlacement() {
        var i: int;

        for (i = 0; i < assets.Size(); i += 1) {
            resetPosition(assets[i]);
        }
    }
    // ------------------------------------------------------------------------
    public function setTemporaryPlacement(
        assetId: String, placement: SStoryBoardPlacementSettings)
    {
        var i: int;

        for (i = 0; i < assets.Size(); i += 1) {
            if (assets[i].getId() == assetId) {
                assets[i].setPlacement(placement, true);
            }
        }
    }
    // ------------------------------------------------------------------------
    public function transformToLocalPos(pos: Vector) : Vector {
        var newOriginPos: Vector;

        newOriginPos = VecTransform(
            MatrixBuiltRotation(EulerAngles(
                -originRot.Pitch, -originRot.Yaw, -originRot.Roll
            )),
            pos - originPos
        );
        return newOriginPos;
    }
    // ------------------------------------------------------------------------
    public function transformToLocalRot(rot: EulerAngles) : EulerAngles {
        return EulerAngles(
            AngleNormalize(rot.Pitch - originRot.Pitch),
            AngleNormalize(rot.Yaw - originRot.Yaw),
            AngleNormalize(rot.Roll - originRot.Roll)
        );
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
