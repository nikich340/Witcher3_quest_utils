// ----------------------------------------------------------------------------
enum ERadUi_CamSettings {
    // default for initial empty shot
    RadUiCam_Empty,
    // trying to get complete entity visible
    RadUiCam_EntityPreview,
    // overview cam (from above looking at the whole scene)
    // (e.g. quick cam for placement mode)
    RadUiCam_BirdsEyeView,
    // ...
}
// ----------------------------------------------------------------------------
function RadUi_rasterizeSize(
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
function RadUi_createCamSettingsFor(
    type: ERadUi_CamSettings,
    optional entity: IRadishSizedElement,
    optional referencePlacement: SRadishPlacement)
        : SRadishPlacement
{
    var s: SRadishPlacement;
    var distance: float;
    var meshSize: Vector;

    switch (type) {
        case RadUiCam_Empty:

            if (thePlayer.IsInInterior()) {
                s.pos = theCamera.GetCameraPosition();
                s.rot = theCamera.GetCameraRotation();
            } else {
                s.pos = thePlayer.GetWorldPosition();
                s.rot = thePlayer.GetWorldRotation();
                s.rot.Pitch -= 25;
                s.rot.Roll = 0;
                distance = -5.0;
                s.pos.X -= distance * SinF(Deg2Rad(s.rot.Yaw - 15));
                s.pos.Y += distance * CosF(Deg2Rad(s.rot.Yaw - 15));
                s.pos.Z += 4.0;
                s.pos.W = 1.0;
            }

            break;

        case RadUiCam_EntityPreview:

            s = entity.getPlacement();
            s.rot.Yaw = -180;
            s.rot.Pitch = -25;
            s.rot.Roll = 0;
            meshSize = entity.getSize();

            if (meshSize.W != -1) {
                meshSize.X = ClampF(meshSize.X, 0.5, 30);
                meshSize.Y = ClampF(meshSize.Y, 0.5, 30);
                meshSize.Z = ClampF(meshSize.Z, 0.5, 45); // buildings may be high

                if (meshSize.Z > 20) {
                    s.rot.Pitch = -30;
                }
            } else {
                // fallback to a mid sized cam
                meshSize = Vector(10, 10, 10);

                GetWitcherPlayer().DisplayHudMessage(
                    GetLocStringByKeyExt("RADUI_eInvalidMeshsizeCamFallback"));
            }

            // clip extreme sizes
            distance = MaxF(MaxF(meshSize.X, meshSize.Y), meshSize.Z);
            distance = 2.5 + 1.15 * RadUi_rasterizeSize(distance, 1.5, 1.05);

            s.pos.Z += 1.0 + 1.05 * RadUi_rasterizeSize(meshSize.Z, 1.25, 1.05);
            s.pos.Y += distance;
            s.pos.W = 1.0;
            break;

        case RadUiCam_BirdsEyeView:
            // reference rotation but entity position so it is always visible
            // (at least at the beginning of the placement)
            s = entity.getPlacement();
            s.rot = referencePlacement.rot;
            // if it is exactly -90 heading is ambiguous
            s.rot.Pitch = -89;
            s.rot.Roll = 0;

            meshSize = entity.getSize();

            if (meshSize != Vector()) {
                meshSize.X = ClampF(meshSize.X, 0.5, 30);
                meshSize.Y = ClampF(meshSize.Y, 0.5, 30);
                meshSize.Z = ClampF(meshSize.Z, 0.5, 45); // buildings may be high
            } else {
                // fallback to a small sized meshSize
                meshSize = Vector(3, 3, 3);
            }

            distance = MaxF(MaxF(meshSize.X, meshSize.Y), meshSize.Z);

            s.pos.Z += ClampF(3 * distance, 15, 30);
            s.pos.W = 1.0;

            break;
        // ...
    }

    return s;
}
// ----------------------------------------------------------------------------
