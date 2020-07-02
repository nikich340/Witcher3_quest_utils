// ----------------------------------------------------------------------------
class CRadishInteractivesProxy extends CRadishPermanentProxy {
    // ------------------------------------------------------------------------
    default templatePath = "dlc\modtemplates\radishquestui\flags\interactive.w2ent";
    // ------------------------------------------------------------------------
    public function setSettings(newSettings: SRadishLayerInteractiveEntityData) {
        if (newSettings.template != permanentTemplatePath) {
            permanentTemplatePath = newSettings.template;
            despawnPermanent();
            spawnPermanent();
        }
        if (placement != newSettings.placement) {
            placement = newSettings.placement;
            moveTo(placement);
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
