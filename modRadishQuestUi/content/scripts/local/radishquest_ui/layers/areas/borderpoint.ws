// ----------------------------------------------------------------------------
class CRadishQuestLayerBorderpoint extends IRadishAdjustableAsset {
    // ------------------------------------------------------------------------
    private var parentArea: CRadishQuestLayerArea;
    private var placement: SRadishPlacement;

    private var proxy: CRadishBorderpointProxy;
    // ------------------------------------------------------------------------
    public function init(parentArea: CRadishQuestLayerArea, placement: Vector, height: float)
    {
        this.parentArea = parentArea;
        this.placement = SRadishPlacement(placement);

        proxy = new CRadishBorderpointProxy in this;
        proxy.init(this.placement.pos, height);
    }
    // ------------------------------------------------------------------------
    public function destroy() {
        var null: CRadishBorderpointProxy;

        proxy.destroy();
        proxy = null;
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
        parentArea.syncSelectedBorderpoint();
    }
    // ------------------------------------------------------------------------
    public function setHeight(newHeight: float) {
        proxy.setHeight(newHeight);
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
