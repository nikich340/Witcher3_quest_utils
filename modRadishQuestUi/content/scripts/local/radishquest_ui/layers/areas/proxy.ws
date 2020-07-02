// ----------------------------------------------------------------------------
// most simple borderpoint visualisation (no highlight, no visibility toggles,
// no appearances, etc.)
class CRadishBorderpointProxy extends IRadishBaseProxyRepresentation {
    // ------------------------------------------------------------------------
    protected var templatePath: String;
    protected var proxy: CEntity;

    protected var height: Float;
    protected var placement: SRadishPlacement;

    default templatePath = "dlc\modtemplates\radishquestui\areas\borderpoint.w2ent";
    // ------------------------------------------------------------------------
    public function init(placement: Vector, height: float)
    {
        var template: CEntityTemplate;

        template = (CEntityTemplate)LoadResource(templatePath, true);
        proxy = theGame.CreateEntity(template, placement, EulerAngles());
        proxy.AddTag('RADUI');

        setHeight(height);
        this.placement = SRadishPlacement(placement);
    }
    // ------------------------------------------------------------------------
    public function setHeight(newHeight: float) {
        var meshComponent: CMeshComponent;

        height = newHeight;
        meshComponent = (CMeshComponent)proxy.GetComponentByClassName('CMeshComponent');
        meshComponent.SetScale(Vector(0.05, 0.05, newHeight));
    }
    // ------------------------------------------------------------------------
    public function show(doShow: bool) {
        proxy.SetHideInGame(!doShow);
    }
    // ------------------------------------------------------------------------
    public function moveTo(placement: SRadishPlacement) {
        this.placement = placement;
        proxy.Teleport(placement.pos);
    }
    // ------------------------------------------------------------------------
    public function getPlacement() : SRadishPlacement {
        return placement;
    }
    // ------------------------------------------------------------------------
    public function getSize() : Vector {
        return Vector(0.5, 0.5, height);
    }
    // ------------------------------------------------------------------------
    public function destroy() {
        proxy.StopAllEffects();
        proxy.Destroy();
        delete proxy;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CRadishAreaProxy extends CRadishProxyRepresentation {
    // ------------------------------------------------------------------------
    protected var areaProxy: array<CEntity>;
    // ------------------------------------------------------------------------
    private var appearanceNames: array<CName>;
    private var border: array<Vector>;
    private var height: float;
    // ------------------------------------------------------------------------
    public function setSettings(settings: SRadishLayerAreaData) {
        var prevBorderpoints: int;

        prevBorderpoints = border.Size();

        placement = settings.placement;
        border = settings.border;
        height = settings.height;
        appearanceId = settings.appearance;

        if (prevBorderpoints == border.Size()) {
            adjustPlanes();
        } else {
            despawnArea();
            spawn();
        }
    }
    // ------------------------------------------------------------------------
    private function adjustPlanes() {
        var meshComponent: CMeshComponent;
        var i, s, b: int;
        var rot: EulerAngles;
        var p1, p2: Vector;
        var dist: float;

        s = border.Size();
        for (i = 0; i < s; i += 1) {
            p1 = border[i];
            p2 = border[(i + 1) % s];

            dist = VecDistance(p1, p2);
            rot.Yaw = VecHeading(p1 - p2);

            meshComponent = (CMeshComponent)areaProxy[i].GetComponentByClassName('CMeshComponent');
            meshComponent.SetScale(Vector(1, dist, height));

            areaProxy[i].TeleportWithRotation(border[i], rot);
        }
    }
    // ------------------------------------------------------------------------
    protected function spawn() {
        var i, s: int;
        var template: CEntityTemplate;
        var meshComponent: CMeshComponent;
        var appearance: CAppearanceComponent;
        var entity: CEntity;
        var rot: EulerAngles;
        var p1, p2: Vector;
        var dist: float;

        template = (CEntityTemplate)LoadResource(templatePath, true);
        GetAppearanceNames(template, appearanceNames);

        s = border.Size();
        for (i = 0; i < s; i += 1) {
            p1 = border[i];
            p2 = border[(i + 1) % s];

            dist = VecDistance(p1, p2);
            rot.Yaw = VecHeading(p1 - p2);
            entity = theGame.CreateEntity(template, p1, rot);
            entity.AddTag('RADUI');

            appearance = (CAppearanceComponent)entity.GetComponentByClassName('CAppearanceComponent');
            appearance.ApplyAppearance(appearanceId);

            meshComponent = (CMeshComponent)entity.GetComponentByClassName('CMeshComponent');
            meshComponent.SetScale( Vector(1, dist, height));

            areaProxy.PushBack(entity);
            // since area will be respawned every time borderpoint count changes
            // it needs to respect the current visiblity settings
            entity.SetHideInGame(!isVisible && !isHighlighted);
        }
    }
    // ------------------------------------------------------------------------
    private function despawnArea() {
        var i, s: int;

        s = areaProxy.Size();
        for (i = 0; i < s; i += 1) {
            areaProxy[i].StopAllEffects();
            areaProxy[i].Destroy();
        }
        areaProxy.Clear();
    }
    // ------------------------------------------------------------------------
    public function destroy() {
        despawnArea();
        super.destroy();
    }
    // ------------------------------------------------------------------------
    protected function highlightProxy(doHighlight: bool) {
        var i, s : int;

        s = areaProxy.Size();
        for (i = 0; i < s; i += 1) {
            areaProxy[i].SetHideInGame(!doHighlight);
        }
    }
    // ------------------------------------------------------------------------
    protected function showProxy(doShow: bool) {
        var i, s : int;

        s = areaProxy.Size();
        for (i = 0; i < s; i += 1) {
            areaProxy[i].SetHideInGame(!doShow);
        }
    }
    // ------------------------------------------------------------------------
    public function moveTo(newPlacement: SRadishPlacement) {
        var diffPos: Vector;
        var i, s: int;

        diffPos = newPlacement.pos - placement.pos;

        super.moveTo(newPlacement);

        s = areaProxy.Size();
        for (i = 0; i < s; i += 1) {
            border[i] += diffPos;
            areaProxy[i].Teleport(border[i]);
        }
    }
    // ------------------------------------------------------------------------
    public function setAppearance(newAppearance: CName) {
        var meshComponent: CMeshComponent;
        var appearanceComp: CAppearanceComponent;
        var i, s: int;

        appearanceId = newAppearance;

        s = areaProxy.Size();
        for (i = 0; i < s; i += 1) {
            appearanceComp = (CAppearanceComponent)areaProxy[i].GetComponentByClassName('CAppearanceComponent');
            appearanceComp.ApplyAppearance(newAppearance);

            // refresh size as appearance change seems to respawn entity
            meshComponent = (CMeshComponent)areaProxy[i].GetComponentByClassName('CMeshComponent');
            meshComponent.SetScale(
                Vector(1, VecDistance(border[i], border[(i + 1) % s]), height));
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
        var i, s: int;
        var size, bPoint: Vector;
        var box: Box;

        // init with first point
        bPoint = border[0];
        box.Max = bPoint;
        box.Min = bPoint;

        s = border.Size();
        for (i = 1; i < s; i += 1) {
            bPoint = border[i];
            box.Max.X = MaxF(box.Max.X, bPoint.X);
            box.Max.Y = MaxF(box.Max.Y, bPoint.Y);
            box.Max.Z = MaxF(box.Max.Z, bPoint.Z);

            box.Min.X = MinF(box.Min.X, bPoint.X);
            box.Min.Y = MinF(box.Min.Y, bPoint.Y);
            box.Min.Z = MinF(box.Min.Z, bPoint.Z);
        }

        size = RadUi_extractMeshBoxSize(box, 2.0);
        // scale height with size
        size.Z = MaxF(2.0f, 0.5f * MinF(499, MaxF(size.X, size.Y)));

        if (size.X < 5000 || size.Y < 5000 || size.Z < 5000) {
            return size;
        }
        // invalid by default
        return Vector(-1.0f, -1.0f, -1.0f);
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
