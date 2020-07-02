class CRadishQuestLayerStaticShadowEntity extends CRadishQuestLayerStaticEntity {
    // ------------------------------------------------------------------------
    default entityType = "static";
    default specialization = "shadows";
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CRadishQuestLayerStaticEntityManager extends CRadishQuestLayerEntityManager {
    // ------------------------------------------------------------------------
    default entityType = "static";
    // ------------------------------------------------------------------------
    protected function createNew(optional specialization: String) : CRadishLayerEntity {
        switch (specialization) {
            case "particles":  return new CRadishQuestLayerParticles in layer;
            case "shadows":    return new CRadishQuestLayerStaticShadowEntity in layer;
            default:           return new CRadishQuestLayerStaticEntity in layer;
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
