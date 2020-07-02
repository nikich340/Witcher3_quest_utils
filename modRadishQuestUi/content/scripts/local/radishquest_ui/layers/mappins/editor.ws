// ----------------------------------------------------------------------------
class CRadishQuestLayerMappinEditor extends CRadishQuestLayerEntityEditor {
    // ------------------------------------------------------------------------
    public function init(log: CModLogger, entity: CRadishLayerEntity) {
        log.debug("mappin editor: " + entity.getName());
        super.init(log, entity);
    }
    // ------------------------------------------------------------------------
    // interactive radius updates
    // ------------------------------------------------------------------------
    // expands/reduces proxy border by amount with center as direction
    public function expandRadius(amount: float) : bool {
        if (((CRadishQuestLayerMappin)entity).expandRadius(amount)) {
            refreshSettingsList();
            return true;
        }
        return false;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
