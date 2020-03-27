// -----------------------------------------------------------------------------
//
// BUGS:
//  - AssetPreview is wrong. depends on player heading or something?
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
enum ESBUI_CamSettings {
    // default for initial empty shot
    SBUICam_EmptyShot,
    // "normal" default dialogue cam
    // (above shoulder looking at some point, e.g another actor)
    SBUICam_ActorLookAtPreview,
    // zoomed in at actor
    // (e.g. quick cam for mimics mode)
    SBUICam_MimicsPreview,
    SBUICam_VoiceLinePreview,
    // full view of actor/item
    // (e.g. quick cam for assets mode)
    SBUICam_AssetPreview,
    // overview cam (from above looking at the whole scene)
    // (e.g. quick cam for placement mode)
    SBUICam_BirdsEyeView,
    // full view of actor to preview animation
    SBUICam_AnimationPreview,
    // ...
}
// ----------------------------------------------------------------------------
function SBUI_rasterizeSize(
    input: float, optional stepSize: float, optional tolerance: float) : float
{
    var result: float = 2.0;

    if (stepSize == 0.0)    { stepSize = 1.75; }
    if (tolerance == 0.0)   { tolerance = 1.25; }

    // allow for some overshoot
    while (result * tolerance < input) {
        result *= stepSize;
    }
    return result;
}
// ----------------------------------------------------------------------------
function SBUI_createCamSettingsFor(
    type: ESBUI_CamSettings,
    optional asset: CModStoryBoardAsset,
    optional lookAt: CModStoryBoardAsset,
    optional referencePlacement: SStoryBoardPlacementSettings)
        : SStoryBoardCameraSettings
{
    var baseEntity: CEntity;
    var s: SStoryBoardCameraSettings;

    var headPos: Vector;
    var distance: float;
    var camHeight: float;

    var headHeight, headOffset: float;
    var meshSize: Vector;
    var isInvalidMeshSize: bool;

    // sane default
    s.fov = 45;

    switch (type) {
        case SBUICam_EmptyShot:

            baseEntity = thePlayer;
            s.pos = baseEntity.GetWorldPosition();
            s.rot = baseEntity.GetWorldRotation();
            s.rot.Yaw -= 20;
            s.rot.Pitch -= 10;
            s.pos += VecConeRand(baseEntity.GetHeading(), 0, -1.2, -1.2);
            s.pos += VecConeRand(baseEntity.GetHeading() + 90, 0, 1, 1);
            s.pos.Z += 1.8;
            // some arbitrary dof settings to see dof is available
            s.dof.strength = 0.25;
            s.dof.blurNear = 1.0;
            s.dof.blurFar = 5.0;
            s.dof.focusNear = 1.0;
            s.dof.focusFar = 5.0;

            s.fov = 40;

            break;

        case SBUICam_AssetPreview:

            baseEntity = asset.getEntity();
            s.pos = baseEntity.GetWorldPosition();
            s.rot = baseEntity.GetWorldRotation();
            s.rot.Yaw -= 180;
            s.rot.Pitch = -15;

            if ((CModStoryBoardActor)asset) {
                headPos = ((CModStoryBoardActor)asset).getHeadPosition();
                headHeight = ClampF(headPos.Z - s.pos.Z, 1.0, 20.0);
                headOffset = ClampF(AbsF(headPos.X - s.pos.X), 0, 1.0);

                asset.getMeshSize(meshSize);

                // clip extreme width / depth / height differences (e.g. griffin)
                // and clip some way too high bounding boxes
                distance = MaxF(MaxF(
                    ClampF(meshSize.X, 0, 3.0 * headHeight),
                    ClampF(meshSize.Y, 0, 2.5 * headHeight)),
                    ClampF(meshSize.Z, headHeight, 1.5 * headHeight)
                );

                // tolerance value "optimized" for humanid actors to stay in
                // same camera defintion
                distance = 1.5 + SBUI_rasterizeSize(headOffset + distance, 1.5, 1.265);

                s.pos.Z += SBUI_rasterizeSize(headHeight, 1.9);

            } else {
                s.rot.Pitch = -25;

                isInvalidMeshSize = asset.getMeshSize(meshSize);

                if (isInvalidMeshSize) {
                    // fallback to a mid sized cam
                    meshSize = Vector(10, 10, 10);

                    GetWitcherPlayer().DisplayHudMessage(
                        GetLocStringByKeyExt("SBUI_eInvalidMeshsizeCamFallback"));

                } else {
                    meshSize.X = ClampF(meshSize.X, 0.5, 30);
                    meshSize.Y = ClampF(meshSize.Y, 0.5, 30);
                    meshSize.Z = ClampF(meshSize.Z, 0.5, 45); // buildings may be high

                    if (meshSize.Z > 20) {
                        s.rot.Pitch = -30;
                    }
                }

                // clip extreme sizes
                distance = MaxF(MaxF(meshSize.X, meshSize.Y), meshSize.Z);
                distance = 2.5 + 1.15 * SBUI_rasterizeSize(distance, 1.5, 1.05);

                s.pos.Z += 1.0 + 1.05 * SBUI_rasterizeSize(meshSize.Z, 1.25, 1.05);
            }

            s.pos.X -= distance * SinF(Deg2Rad(baseEntity.GetHeading() - 15));
            s.pos.Y += distance * CosF(Deg2Rad(baseEntity.GetHeading() - 15));

            break;

        case SBUICam_AnimationPreview:

            baseEntity = asset.getEntity();
            s.pos = baseEntity.GetWorldPosition();
            s.rot = baseEntity.GetWorldRotation();
            s.rot.Yaw -= 180;
            s.rot.Pitch -= 15;

            headPos = ((CModStoryBoardActor)asset).getHeadPosition();
            headHeight = ClampF(headPos.Z - s.pos.Z, 1.0, 10.0);

            asset.getMeshSize(meshSize);

            // clip extreme width / depth / height differences (e.g. griffin)
            // and clip some way too high bounding boxes
            distance = MaxF(MaxF(
                ClampF(meshSize.X, 0, 4 * headHeight),
                ClampF(meshSize.Y, 0, 4 * headHeight)),
                ClampF(meshSize.Z, headHeight, 1.5 * headHeight)
            );
            camHeight = ClampF(distance, headHeight, 2.25 * headHeight);
            distance = 0.5 + 1.4 * distance;

            s.pos.X = headPos.X - distance * SinF(Deg2Rad(baseEntity.GetHeading() - 15));
            s.pos.Y = headPos.Y + distance * CosF(Deg2Rad(baseEntity.GetHeading() - 15));
            s.pos.Z += camHeight;

            break;

        case SBUICam_ActorLookAtPreview:
        case SBUICam_MimicsPreview:

            baseEntity = asset.getEntity();
            s.pos = baseEntity.GetWorldPosition();
            s.rot = baseEntity.GetWorldRotation();
            s.rot.Yaw -= 180;
            s.rot.Pitch -= 10;

            headPos = ((CModStoryBoardActor)asset).getHeadPosition();
            headHeight = ClampF(headPos.Z - s.pos.Z, 1.0, 10.0);
            camHeight = 0.15 + headHeight;
            distance = 1.25;

            s.pos.X = headPos.X - distance * SinF(Deg2Rad(baseEntity.GetHeading() - 10));
            s.pos.Y = headPos.Y + distance * CosF(Deg2Rad(baseEntity.GetHeading() - 10));

            s.pos.Z += camHeight;

            s.fov = 30;

            break;

        case SBUICam_VoiceLinePreview:
            baseEntity = asset.getEntity();
            s.pos = baseEntity.GetWorldPosition();
            s.rot = baseEntity.GetWorldRotation();
            s.rot.Yaw -= 180;
            s.rot.Pitch -= 3;

            headPos = ((CModStoryBoardActor)asset).getHeadPosition();
            headHeight = ClampF(headPos.Z - s.pos.Z, 1.0, 10.0);
            camHeight = 0.07 + headHeight;
            distance = 1.0;

            s.pos.X = headPos.X - distance * SinF(Deg2Rad(baseEntity.GetHeading() - 7));
            s.pos.Y = headPos.Y + distance * CosF(Deg2Rad(baseEntity.GetHeading() - 7));

            s.pos.Z += camHeight;

            s.fov = 20;
            break;

        case SBUICam_BirdsEyeView:
            baseEntity = asset.getEntity();
            // reference rotation but entity position so it is always visible
            // (at least at the beginning of the placement)
            s.pos = baseEntity.GetWorldPosition();
            s.rot = referencePlacement.rot;
            // if it is exactly -90 heading is ambiguous
            s.rot.Pitch = -89;

            isInvalidMeshSize = asset.getMeshSize(meshSize);

            if (isInvalidMeshSize) {
                // fallback to a small sized meshSize
                meshSize = Vector(3, 3, 3);
            } else {
                meshSize.X = ClampF(meshSize.X, 0.5, 30);
                meshSize.Y = ClampF(meshSize.Y, 0.5, 30);
                meshSize.Z = ClampF(meshSize.Z, 0.5, 45); // buildings may be high
            }

            distance = MaxF(MaxF(meshSize.X, meshSize.Y), meshSize.Z);

            s.pos.Z += ClampF(3 * distance, 15, 30);

            s.fov = 60;

            break;
        // ...
    }

    return s;
}
// ----------------------------------------------------------------------------
