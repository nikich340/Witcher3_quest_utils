// ----------------------------------------------------------------------------
class CRadishQuestLayerInteractiveEntityEditor extends CRadishQuestLayerEntityEditor {
    // ------------------------------------------------------------------------
    public function init(log: CModLogger, entity: CRadishLayerEntity) {
        log.debug("interactive entity editor: " + entity.getName());
        super.init(log, entity);
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
