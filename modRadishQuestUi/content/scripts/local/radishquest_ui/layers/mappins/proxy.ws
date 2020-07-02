// ----------------------------------------------------------------------------
class CRadishMappinProxy extends CRadishProxyRepresentation {
    // ------------------------------------------------------------------------
    default areaTemplatePath = "dlc\modtemplates\radishquestui\mappins\area.w2ent";
    // ------------------------------------------------------------------------
    protected var areaTemplatePath: String;
    protected var areaProxy: array<CEntity>;
    // ------------------------------------------------------------------------
    private var areaCorners: int;
    private var areaHeight: float;
    default areaCorners = 15;
    default areaHeight = 2.0;
    // ------------------------------------------------------------------------
    private var appearanceNames: array<CName>;
    private var border: array<Vector>;
    // ------------------------------------------------------------------------
    private var radius: int;
    // ------------------------------------------------------------------------
    public function setSettings(settings: SRadishLayerMappinData) {
        if (placement != settings.placement) {
            placement = settings.placement;
            moveTo(placement);
        }
        if (radius != settings.radius) {
            radius = settings.radius;
            resizeArea();
        }
    }
    // ------------------------------------------------------------------------
    protected function resizeArea() {
        var meshComponent: CMeshComponent;
        var i, s, b: int;
        var rot: EulerAngles;
        var p1, p2: Vector;
        var dist: float;
        var angle: float;
        var newPoints: array<Vector>;

        for (i = 0; i < areaCorners; i += 1) {
            angle = Deg2Rad(i * 360 / areaCorners);
            newPoints.PushBack(
                placement.pos + VecNormalize(Vector(CosF(angle), SinF(angle), 0)) * radius
            );
        }
        border = newPoints;

        s = areaCorners;
        if (radius > 0) {
            for (i = 0; i < s; i += 1) {
                p1 = border[i];
                p2 = border[(i + 1) % s];

                dist = VecDistance(p1, p2);
                rot.Yaw = VecHeading(p1 - p2);

                meshComponent = (CMeshComponent)areaProxy[i].GetComponentByClassName('CMeshComponent');
                meshComponent.SetScale( Vector(1, dist, areaHeight));

                areaProxy[i].TeleportWithRotation(border[i], rot);
                areaProxy[i].SetHideInGame(!(isVisible || isHighlighted));
            }
        } else {
            for (i = 0; i < s; i += 1) {
                areaProxy[i].SetHideInGame(true);
            }
        }
    }
    // ------------------------------------------------------------------------
    protected function spawn() {
        var i: int;
        var flagTemplate: CEntityTemplate;
        var areaTemplate: CEntityTemplate;
        var meshComponent: CMeshComponent;
        var appearance: CAppearanceComponent;
        var entity: CEntity;
        var rot: EulerAngles;
        var p1, p2: Vector;
        var dist, angle: float;

        // center flag is always available
        flagTemplate = (CEntityTemplate)LoadResource(templatePath, true);
        proxy = theGame.CreateEntity(flagTemplate, placement.pos, placement.rot);
        proxy.SetHideInGame(true);
        proxy.AddTag('RADUI');

        proxy.SetHideInGame(!isVisible && !isHighlighted);

        areaTemplate = (CEntityTemplate)LoadResource(areaTemplatePath, true);

        for (i = 0; i < areaCorners; i += 1) {
            angle = Deg2Rad(i * 360 / areaCorners);
            border.PushBack(
                placement.pos + VecNormalize(
                    Vector(CosF(angle), SinF(angle), 0)
                ) * radius);
        }

        for (i = 0; i < areaCorners; i += 1) {
            p1 = border[i];
            p2 = border[(i + 1) % areaCorners];

            dist = VecDistance(p1, p2);
            rot.Yaw = VecHeading(p1 - p2);
            entity = theGame.CreateEntity(areaTemplate, p1, rot);
            entity.AddTag('RADUI');

            appearance = (CAppearanceComponent)entity.GetComponentByClassName('CAppearanceComponent');
            appearance.ApplyAppearance(appearanceId);

            meshComponent = (CMeshComponent)entity.GetComponentByClassName('CMeshComponent');
            meshComponent.SetScale( Vector(1, dist, areaHeight));

            areaProxy.PushBack(entity);

            entity.SetHideInGame(!(isVisible || isHighlighted) || radius <= 0);
        }
    }
    // ------------------------------------------------------------------------
    public function destroy() {
        var i, s: int;

        s = areaProxy.Size();
        for (i = 0; i < s; i += 1) {
            areaProxy[i].StopAllEffects();
            areaProxy[i].Destroy();
        }
        areaProxy.Clear();
        super.destroy();
    }
    // ------------------------------------------------------------------------
    protected function highlightProxy(doHighlight: bool) {
        var i, s : int;

        s = areaProxy.Size();
        if (radius > 0) {
            for (i = 0; i < s; i += 1) {
                areaProxy[i].SetHideInGame(!doHighlight);
            }
        }
        proxy.SetHideInGame(!doHighlight);
    }
    // ------------------------------------------------------------------------
    protected function showProxy(doShow: bool) {
        var i, s : int;

        s = areaProxy.Size();
        if (radius > 0) {
            for (i = 0; i < s; i += 1) {
                areaProxy[i].SetHideInGame(!doShow);
            }
        }
        proxy.SetHideInGame(!doShow);
    }
    // ------------------------------------------------------------------------
    public function moveTo(newPlacement: SRadishPlacement) {
        var diffPos: Vector;
        var meshComponent: CMeshComponent;
        var i, s, b: int;
        var rot: EulerAngles;
        var p1, p2: Vector;
        var dist: float;

        diffPos = newPlacement.pos - placement.pos;

        this.placement = newPlacement;
        proxy.Teleport(placement.pos);

        if (radius > 0) {
            s = areaProxy.Size();
            for (i = 0; i < s; i += 1) {
                border[i] += diffPos;
                areaProxy[i].Teleport(border[i]);
            }
        }
    }
    // ------------------------------------------------------------------------
    public function setAppearance(newAppearance: CName) {
        var meshComponent: CMeshComponent;
        var appearance: CAppearanceComponent;
        var i, s: int;

        appearanceId = newAppearance;

        s = areaProxy.Size();
        for (i = 0; i < s; i += 1) {
            appearance = (CAppearanceComponent)areaProxy[i].GetComponentByClassName('CAppearanceComponent');
            appearance.ApplyAppearance(newAppearance);

            // refresh size as appearance change seems to respawn entity
            meshComponent = (CMeshComponent)areaProxy[i].GetComponentByClassName('CMeshComponent');
            meshComponent.SetScale(
                Vector(1, VecDistance(border[i], border[(i + 1) % s]), areaHeight));
        }
    }
    // ------------------------------------------------------------------------
    public function cycleAppearance() {
        var i: int;

        i = appearanceNames.FindFirst(appearanceId);
        if (i == -1) {
            i = 0;
        }
        setAppearance(appearanceNames[(i + 1) % appearanceNames.Size()]);
    }
    // ------------------------------------------------------------------------
    public function getSize() : Vector {
        var size: Vector;

        if (radius > 1) {
            size = Vector(2 * radius, 2 * radius, 1.0);
        } else {
            size = Vector(2.0, 2.0, 2.0);
        }
        // scale height with size
        size.Z = MaxF(2.0f, 0.4f * MinF(499, MaxF(size.X, size.Y)));

        return size;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
