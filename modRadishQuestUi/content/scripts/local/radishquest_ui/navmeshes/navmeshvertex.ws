// ----------------------------------------------------------------------------
class CRadishNavMeshVertex extends IRadishAdjustableAsset {
    // ------------------------------------------------------------------------
    private var parentMesh: CRadishNavMesh;
    private var placement: SRadishPlacement;
    private var proxy: CRadUiMeshVertexProxy;
    // ------------------------------------------------------------------------
    public function init(parentMesh: CRadishNavMesh) {
        this.parentMesh = parentMesh;
        this.placement = SRadishPlacement(Vector());

        proxy = new CRadUiMeshVertexProxy in this;
        proxy.init();
    }
    // ------------------------------------------------------------------------
    public function destroy() {
        var null: CRadUiMeshVertexProxy;

        proxy.destroy();
        proxy = null;
    }
    // ------------------------------------------------------------------------
    public function initWithVertexData(
        vertexPos: Vector, fixedVertexPos1: Vector, fixedVertexPos2: Vector)
    {
        placement.pos = vertexPos;
        proxy.setVertexData(vertexPos, fixedVertexPos1, fixedVertexPos2);
    }
    // ------------------------------------------------------------------------
    public function show(doShow: bool) {
        proxy.show(doShow);
    }
    // ------------------------------------------------------------------------
    public function getProxy() : IRadishBaseProxyRepresentation {
        return proxy;
    }
    // ------------------------------------------------------------------------
    public function getPlacement() : SRadishPlacement {
        return placement;
    }
    // ------------------------------------------------------------------------
    public function setPlacement(newPlacement: SRadishPlacement) {
        placement = newPlacement;
        proxy.moveTo(newPlacement);
        parentMesh.syncSelectedVertexPos(newPlacement.pos);
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
