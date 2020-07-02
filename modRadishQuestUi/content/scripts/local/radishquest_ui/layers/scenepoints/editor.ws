// ----------------------------------------------------------------------------
class CRadishQuestLayerScenepointEditor extends CRadishQuestLayerEntityEditor {
    // ------------------------------------------------------------------------
    public function init(log: CModLogger, entity: CRadishLayerEntity) {
        log.debug("scenepoint editor: " + entity.getName());
        super.init(log, entity);
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
