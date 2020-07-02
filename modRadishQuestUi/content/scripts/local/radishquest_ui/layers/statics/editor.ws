// ----------------------------------------------------------------------------
class CRadishQuestLayerStaticEntityEditor extends CRadishQuestLayerEntityEditor {
    // ------------------------------------------------------------------------
    public function init(log: CModLogger, entity: CRadishLayerEntity) {
        log.debug("static entity editor: " + entity.getName());
        super.init(log, entity);
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
