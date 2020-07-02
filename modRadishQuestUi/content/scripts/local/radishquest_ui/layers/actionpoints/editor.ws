// ----------------------------------------------------------------------------
class CRadishQuestLayerActionpointEditor extends CRadishQuestLayerEntityEditor {
    // ------------------------------------------------------------------------
    public function init(log: CModLogger, entity: CRadishLayerEntity) {
        log.debug("actionpoint editor: " + entity.getName());
        super.init(log, entity);
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
