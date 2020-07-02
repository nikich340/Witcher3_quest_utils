// ----------------------------------------------------------------------------
abstract class IRadishUiModeCommunityElementEditor extends IRadishUiModeManager {
    // ------------------------------------------------------------------------
    //public function init(log: CModLogger, element: IRadishQuestSelectableElement);
    // ------------------------------------------------------------------------
    public function getElementCaption() : String;
    // ------------------------------------------------------------------------
    public function getCommunityCaption() : String;
    // ------------------------------------------------------------------------
    public function getSettingsList() : CRadishUiFilteredList;
    // ------------------------------------------------------------------------
    public function select(settingsId: String);
    // ------------------------------------------------------------------------
    public function getSelected() : IModUiSetting;
    // ------------------------------------------------------------------------
    public function syncSelectedSetting();
    // ------------------------------------------------------------------------
    public function getCamPlacement() : SRadishPlacement;
    // ------------------------------------------------------------------------
    public function getCamTracker() : CRadishTracker;
    // ------------------------------------------------------------------------
    public function switchCamTo(placement: SRadishPlacement);
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
abstract class CRadishCommunityElementEditor extends IRadishUiModeCommunityElementEditor {
    protected var theCam: CRadishStaticCamera;
    protected var log: CModLogger;
    //protected var community: CRadishCommunity;
    // ------------------------------------------------------------------------
    // used to locate referenced layerentities
    protected var visualizer: CRadishProxyVisualizer;
    // ------------------------------------------------------------------------
    protected var settingsList: CRadishUiSettingsList;
    protected var selectedId: String;
    protected var editedSetting: IModUiSetting;
    protected var communityName: String;
    protected var elementName: String;
    // ------------------------------------------------------------------------
    public function init(log: CModLogger,
        communityName: String,
        element: IRadishQuestSelectableElement,
        proxyVisualizer: CRadishProxyVisualizer,
        theCam: CRadishStaticCamera)
    {
        this.log = log;
        this.theCam = theCam;
        this.visualizer = proxyVisualizer;

        this.communityName = communityName;
        elementName = element.getCaption();

        element.highlight(true);
        setElement(element);

        settingsList = new CRadishUiSettingsList in this;
        refreshSettingsList();

        settingsList.preselect(true);
        selectedId = settingsList.getSelectedId();
    }
    // ------------------------------------------------------------------------
    protected function setElement(element: IRadishQuestSelectableElement);
    // ------------------------------------------------------------------------
    protected function refreshSettingsList();
    // ------------------------------------------------------------------------
    public function getSettingsList() : CRadishUiFilteredList {
        return settingsList;
    }
    // ------------------------------------------------------------------------
    public function select(settingsId: String) {
        selectedId = settingsId;
    }
    // ------------------------------------------------------------------------
    public function getElementCaption() : String {
        return elementName;
    }
    // ------------------------------------------------------------------------
    public function getCommunityCaption() : String {
        return communityName;
    }
    // ------------------------------------------------------------------------
    public function refreshHighlight(forceCamSwitch: bool) {
        this.visualizer.refreshHighlight(forceCamSwitch);
    }
    // ------------------------------------------------------------------------
    public function clearHighlighted() {
        this.visualizer.clearHighlighted();
    }
    // ------------------------------------------------------------------------
    public function getSelected() : IModUiSetting {
        editedSetting = getAsUiSetting(selectedId);
        return editedSetting;
    }
    // ------------------------------------------------------------------------
    protected function getAsUiSetting(selectedId: String) : IModUiSetting;
    // ------------------------------------------------------------------------
    public function getCamPlacement() : SRadishPlacement {
        return theCam.getSettings();
    }
    // ------------------------------------------------------------------------
    public function getCamTracker() : CRadishTracker {
        return theCam.getTracker();
    }
    // ------------------------------------------------------------------------
    public function switchCamTo(placement: SRadishPlacement) {
        theCam.setSettings(placement);
        theCam.switchTo();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
