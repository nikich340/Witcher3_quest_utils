// ----------------------------------------------------------------------------
class CRadishGenericEntityProxy extends CRadishProxyRepresentation {
    // ------------------------------------------------------------------------
    public function setSettings(newSettings: SRadishLayerGenericEntityData) {
        if (placement != newSettings.placement) {
            placement = newSettings.placement;
            moveTo(placement);
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
