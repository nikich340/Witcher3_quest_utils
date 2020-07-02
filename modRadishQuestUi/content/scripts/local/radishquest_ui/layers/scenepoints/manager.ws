// ----------------------------------------------------------------------------
class CRadishQuestLayerScenepointManager extends CRadishQuestLayerEntityManager {
    // ------------------------------------------------------------------------
    default entityType = "scenepoint";
    // ------------------------------------------------------------------------
    protected function createNew(optional specialization: String) : CRadishLayerEntity {
        return new CRadishQuestLayerScenepoint in layer;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
