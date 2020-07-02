// ----------------------------------------------------------------------------
abstract class IRadishBaseProxyRepresentation extends IRadishSizedElement {
    // ------------------------------------------------------------------------
    public function show(doShow: bool);
    // ------------------------------------------------------------------------
    public function onPlacementStart() {}
    // ------------------------------------------------------------------------
    public function moveTo(placement: SRadishPlacement);
    // ------------------------------------------------------------------------
    public function onPlacementEnd() {}
    // ------------------------------------------------------------------------
    public function destroy();
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
abstract class IRadishProxyRepresentation extends IRadishBaseProxyRepresentation {
    // ------------------------------------------------------------------------
    public function enable(doEnable: bool);
    // ------------------------------------------------------------------------
    public function highlight(doHighlight: bool);
    // ------------------------------------------------------------------------
    //public function unhighlight();
    // ------------------------------------------------------------------------
    //public function hide();
    // ------------------------------------------------------------------------
    public function isVisible() : bool;
    // ------------------------------------------------------------------------
    public function toggleVisibility();
    // ------------------------------------------------------------------------
    public function setAppearance(id: name);
    // ------------------------------------------------------------------------
    public function getAppearance() : name;
    // ------------------------------------------------------------------------
    public function cycleAppearance();
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CRadishProxyRepresentation extends IRadishProxyRepresentation {
    // ------------------------------------------------------------------------
    protected var templatePath: String;
    protected var proxy: CEntity;
    protected var appearanceId: name;
    // ------------------------------------------------------------------------
    // flag inidicating layerentity has visible parts (important for proxies of
    // encoded layer entities)
    protected var hasVisibleSource: bool;
    protected var isVisible: bool;
    protected var isHighlighted: bool;
    // ------------------------------------------------------------------------
    protected var placement: SRadishPlacement;
    protected var meshSize: Vector;
    // ------------------------------------------------------------------------
    public function init(
        templatePath: String, placement: SRadishPlacement, visibleSourceEntity: bool)
    {
        this.templatePath = templatePath;
        this.placement = placement;
        this.hasVisibleSource = visibleSourceEntity;
        //TODO think about on-demand spawn/despawn
        spawn();
    }
    // ------------------------------------------------------------------------
    public function enable(doEnable: bool) {

    }
    // ------------------------------------------------------------------------
    protected function spawn() {
        var template: CEntityTemplate;

        if (!proxy) {
            template = (CEntityTemplate)LoadResource(templatePath, true);
            proxy = theGame.CreateEntity(template, placement.pos, placement.rot);
            proxy.AddTag('RADUI');

            proxy.SetHideInGame(!isVisible && !isHighlighted);
            meshSize = Vector(-1, -1, -1, -1);
        }
    }
    // ------------------------------------------------------------------------
    public function highlight(doHighlight: bool) {
        if (isHighlighted != doHighlight) {
            // ignore an unhighlight if it's currently set to visible
            if (!isVisible || doHighlight) {
                highlightProxy(doHighlight);
            }
            isHighlighted = doHighlight;
        }
    }
    // ------------------------------------------------------------------------
    public function show(doShow: bool) {
        if (isVisible != doShow) {
            // ignore a hide if it's currently highlighted
            if (!isHighlighted || doShow) {
                showProxy(doShow);
            }
            isVisible = doShow;
        }
    }
    // ------------------------------------------------------------------------
    // separate method to allow easy overwrite
    protected function highlightProxy(doHighlight: bool) {
        proxy.SetHideInGame(!doHighlight);
    }
    // ------------------------------------------------------------------------
    // separate method to allow easy overwrite
    protected function showProxy(doShow: bool) {
        proxy.SetHideInGame(!doShow);
    }
    // ------------------------------------------------------------------------
    public function isVisible() : bool {
        return this.isVisible;
    }
    // ------------------------------------------------------------------------
    public function toggleVisibility() {
        show(!isVisible);
    }
    // ------------------------------------------------------------------------
    public function setAppearance(id: name) {
        appearanceId = id;
    }
    // ------------------------------------------------------------------------
    public function getAppearance() : name {
        return appearanceId;
    }
    // ------------------------------------------------------------------------
    public function cycleAppearance() {

    }
    // ------------------------------------------------------------------------
    public function onPlacementStart() {}
    // ------------------------------------------------------------------------
    public function moveTo(placement: SRadishPlacement) {
        this.placement = placement;
        proxy.TeleportWithRotation(placement.pos, placement.rot);
    }
    // ------------------------------------------------------------------------
    public function onPlacementEnd() {}
    // ------------------------------------------------------------------------
    public function getSize() : Vector {
        var boundingBox: Box;

        // use cached if possible
        if (meshSize.W == -1) {
            // try boundingbox first
            proxy.CalcBoundingBox(boundingBox);
            meshSize = RadUi_extractMeshBoxSize(boundingBox, 0.01);

            if (meshSize.X == 0.01 && meshSize.Y == 0.01 && meshSize.Z == 0.01) {
                // entity doesn't have a boundingbox (yet?) return default box
                meshSize = Vector(0.5, 0.5, 0.5, 1.0);
            }
        }
        return meshSize;
    }
    // ------------------------------------------------------------------------
    public function hasValidSize() : bool {
        return meshSize.W != -1;
    }
    // ------------------------------------------------------------------------
    public function getPlacement() : SRadishPlacement {
        return this.placement;
    }
    // ------------------------------------------------------------------------
    public function destroy() {
        var null: CEntity;

        proxy.StopAllEffects();
        proxy.Destroy();
        proxy = null;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
abstract class CRadishPermanentProxy extends CRadishProxyRepresentation {
    // ------------------------------------------------------------------------
    protected var dontShowMarker: bool;
    // ------------------------------------------------------------------------
    protected var permanentProxy: CEntity;
    protected var permanentTemplatePath: String;
    protected var permanentEntityClass: String;
    // ------------------------------------------------------------------------
    // scaling has to be done for every component (entityScale * compScale!)
    // -> store "original" scales
    protected var permanentEntityScale: Vector;
    protected var meshCompScales: array<Vector>;
    // ------------------------------------------------------------------------
    default permanentEntityClass = 'CEntity';
    // ------------------------------------------------------------------------
    public function init(
        permanentPath: String, placement: SRadishPlacement, visibleSourceEntity: bool)
    {
        this.hasVisibleSource = visibleSourceEntity;
        this.permanentTemplatePath = permanentPath;
        this.permanentEntityScale = Vector(1.0, 1.0, 1.0, 1.0);
        this.placement = placement;
        spawn();
    }
    // ------------------------------------------------------------------------
    public function setPermanentTemplate(newTemplate: String) {
        this.permanentTemplatePath = newTemplate;
        despawnPermanent();
        spawnPermanent();
    }
    // ------------------------------------------------------------------------
    public function getPermanentTemplate() : String {
        return permanentTemplatePath;
    }
    // ------------------------------------------------------------------------
    public function getPermanentClass() : String {
        return permanentEntityClass;
    }
    // ------------------------------------------------------------------------
    protected function spawn() {
        super.spawn();
        spawnPermanent();
    }
    // ------------------------------------------------------------------------
    protected function spawnPermanent() {
        var template: CEntityTemplate;

        if (!hasVisibleSource) {
            template = (CEntityTemplate)LoadResource(permanentTemplatePath, true);
            permanentEntityClass = template.entityClass;
            permanentProxy = theGame.CreateEntity(template, placement.pos, placement.rot);

            permanentProxy.AddTag('RADUI');
            meshSize = Vector(-1, -1, -1, -1);
            meshCompScales.Clear();

            if (permanentEntityScale != permanentProxy.GetLocalScale()) {
                scaleTo(permanentEntityScale);
            }
        }
    }
    // ------------------------------------------------------------------------
    protected function despawnPermanent() {
        var null: CEntity;

        permanentProxy.StopAllEffects();
        permanentProxy.Destroy();
        permanentProxy = null;
    }
    // ------------------------------------------------------------------------
    protected function highlightProxy(doHighlight: bool) {
        proxy.SetHideInGame(dontShowMarker || !doHighlight);
    }
    // ------------------------------------------------------------------------
    public function onPlacementStart() {
        // hide marker entity as moving should use permanent proxy only
        proxy.SetHideInGame(true);
        dontShowMarker = true;
    }
    // ------------------------------------------------------------------------
    public function moveTo(placement: SRadishPlacement) {
        this.placement = placement;
        proxy.TeleportWithRotation(placement.pos, placement.rot);
        permanentProxy.TeleportWithRotation(placement.pos, placement.rot);
    }
    // ------------------------------------------------------------------------
    public function onPlacementEnd() {
        dontShowMarker = false;
        // restore marker entity to previous state
        proxy.SetHideInGame(!isVisible && !isHighlighted);
    }
    // ------------------------------------------------------------------------
    protected function extractMeshCompScales() {
        var meshComps: array<CComponent>;
        var i: int;

        // store original component scales as basis for all rescales
        meshComps.Clear();
        meshCompScales.Clear();
        meshComps = permanentProxy.GetComponentsByClassName('CMeshComponent');
        for (i = 0; i < meshComps.Size(); i += 1) {
            LogChannel('DEBUG', "orig comp scale: " + VecToString(meshComps[i].GetLocalScale()));
            meshCompScales.PushBack(meshComps[i].GetLocalScale());
        }
    }
    // ------------------------------------------------------------------------
    public function scaleTo(newScale: Vector) {
        var meshComps: array<CComponent>;
        var i: int;

        if (meshCompScales.Size() == 0) {
            extractMeshCompScales();
        }

        if (meshCompScales.Size() > 0) {
            permanentEntityScale = newScale;
            permanentEntityScale.W = 1.0;

            // unfortunately this doesn't work correctly as it scales only the
            // component itself but not in relation to its position in the entity
            // (scaling must be the last transfrom on the absolute-in-relation-to
            // -entity-center coordinates)
            meshComps = permanentProxy.GetComponentsByClassName('CMeshComponent');
            for (i = 0; i < meshComps.Size(); i += 1) {
                meshComps[i].SetScale(Vector(
                    meshCompScales[i].X * permanentEntityScale.X,
                    meshCompScales[i].Y * permanentEntityScale.Y,
                    meshCompScales[i].Z * permanentEntityScale.Z,
                    meshCompScales[i].W * permanentEntityScale.W
                ));
            }
        }
    }
    // ------------------------------------------------------------------------
    public function getSize() : Vector {
        var boundingBox: Box;

        // use cached if possible
        if (meshSize.W == -1) {
            // try boundingbox first
            permanentProxy.CalcBoundingBox(boundingBox);
            meshSize = RadUi_extractMeshBoxSize(boundingBox, 0.01);

            if (meshSize.X == 0.01 && meshSize.Y == 0.01 && meshSize.Z == 0.01) {
                // entity doesn't have a boundingbox (yet?) return default box
                meshSize = Vector(0.5, 0.5, 0.5, -1.0);
            }
        }
        return meshSize;
    }
    // ------------------------------------------------------------------------
    public function destroy() {
        super.destroy();
        despawnPermanent();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
