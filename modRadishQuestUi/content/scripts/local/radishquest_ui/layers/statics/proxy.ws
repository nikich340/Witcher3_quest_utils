// ----------------------------------------------------------------------------
class CRadishStaticsProxy extends CRadishPermanentProxy {
    // ------------------------------------------------------------------------
    default templatePath = "dlc\modtemplates\radishquestui\flags\static.w2ent";
    // ------------------------------------------------------------------------
    public function setSettings(newSettings: SRadishLayerStaticEntityData) {
        if (newSettings.template != permanentTemplatePath) {
            permanentTemplatePath = newSettings.template;
            despawnPermanent();
            spawnPermanent();
        }
        if (placement != newSettings.placement) {
            placement = newSettings.placement;
            moveTo(placement);
        }
        if (permanentEntityScale != newSettings.scale) {
            permanentEntityScale = newSettings.scale;
            scaleTo(permanentEntityScale);
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
