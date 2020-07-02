// ----------------------------------------------------------------------------
abstract class IRadishUiModeEntityEditor extends IRadishUiModeManager {
    // ------------------------------------------------------------------------
    public function init(log: CModLogger, entity: CRadishLayerEntity);
    // ------------------------------------------------------------------------
    public function getSettingsList() : CRadishUiFilteredList;
    // ------------------------------------------------------------------------
    public function select(settingsId: String);
    // ------------------------------------------------------------------------
    public function getSelected() : IModUiSetting;
    // ------------------------------------------------------------------------
    public function syncSelectedSetting();
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
abstract class CRadishQuestLayerEntityEditor extends IRadishUiModeEntityEditor {
    protected var log: CModLogger;

    protected var entity: CRadishLayerEntity;

    protected var settingsList: CRadishUiSettingsList;
    protected var selectedId: String;
    protected var editedSetting: IModUiSetting;
    // ------------------------------------------------------------------------
    public function init(log: CModLogger, entity: CRadishLayerEntity) {
        this.log = log;
        this.entity = entity;
        entity.highlight(true);

        settingsList = new CRadishUiSettingsList in this;
        refreshSettingsList();
        settingsList.preselect(true);
        selectedId = settingsList.getSelectedId();
    }
    // ------------------------------------------------------------------------
    protected function refreshSettingsList() {
        settingsList.clear();
        entity.addUiSettings(settingsList);
    }
    // ------------------------------------------------------------------------
    public function getSettingsList() : CRadishUiFilteredList {
        return settingsList;
    }
    // ------------------------------------------------------------------------
    public function select(settingsId: String) {
        selectedId = settingsId;
    }
    // ------------------------------------------------------------------------
    public function getSelected() : IModUiSetting {
        editedSetting = getAsUiSetting(selectedId);
        return editedSetting;
    }
    // ------------------------------------------------------------------------
    // settings editing (text input)
    // ------------------------------------------------------------------------
    protected function getAsUiSetting(selectedId: String) : IModUiSetting {
        return entity.getAsUiSetting(selectedId);
    }
    // ------------------------------------------------------------------------
    public function syncSelectedSetting() {
        entity.syncSetting(selectedId, editedSetting);
        refreshSettingsList();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
