// ----------------------------------------------------------------------------
class CRadishQuestLayerInteractiveEntityManager extends CRadishQuestLayerEntityManager {
    // ------------------------------------------------------------------------
    default entityType = "interactive";
    // ------------------------------------------------------------------------
    protected function createNew(optional specialization: String) : CRadishLayerEntity {
        return new CRadishQuestLayerInteractiveEntity in layer;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
