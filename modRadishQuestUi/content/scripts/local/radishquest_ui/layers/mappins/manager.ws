// ----------------------------------------------------------------------------
class CRadishQuestLayerMappinManager extends CRadishQuestLayerEntityManager {
    // ------------------------------------------------------------------------
    default entityType = "mappin";
    // ------------------------------------------------------------------------
    protected function createNew(optional specialization: String) : CRadishLayerEntity {
        return new CRadishQuestLayerMappin in layer;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
