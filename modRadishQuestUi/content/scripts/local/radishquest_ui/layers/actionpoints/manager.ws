// ----------------------------------------------------------------------------
class CRadishQuestLayerActionpointManager extends CRadishQuestLayerEntityManager {
    // ------------------------------------------------------------------------
    default entityType = "actionpoint";
    // ------------------------------------------------------------------------
    private var jobTreeProvider: CRadishJobTreeManager;
    // ------------------------------------------------------------------------
    protected function createNew(optional specialization: String) : CRadishLayerEntity {
        return new CRadishQuestLayerActionpoint in layer;
    }
    // ------------------------------------------------------------------------
    public function setJobTreeProvider(provider: CRadishJobTreeManager) {
        this.jobTreeProvider = provider;
    }
    // ------------------------------------------------------------------------
    public function getJobTreeList() : CRadishUiFilteredList {
        return jobTreeProvider.getJobTreeList();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
