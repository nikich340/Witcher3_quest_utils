// ----------------------------------------------------------------------------
class CRadishQuestLayerAreaEditor extends CRadishQuestLayerEntityEditor {
    // ------------------------------------------------------------------------
    private var areaEntity: CRadishQuestLayerArea;
    private var settings: SRadishLayerAreaData;
    // ------------------------------------------------------------------------
    public function init(log: CModLogger, entity: CRadishLayerEntity) {
        log.debug("area editor: " + entity.getName());
        this.areaEntity = (CRadishQuestLayerArea)entity;

        super.init(log, entity);
    }
    // ------------------------------------------------------------------------
    protected function refreshSettingsList() {
        settings = areaEntity.getSettings();

        settingsList.clear();
        areaEntity.addUiSettings(settingsList);
    }
    // ------------------------------------------------------------------------
    public function select(settingsId: String) {
        super.select(settingsId);

        areaEntity.selectBorderpoint(extractBorderpointNo(selectedId));
    }
    // ------------------------------------------------------------------------
    private function setSelectedId(newId: String) {
        selectedId = newId;
        // in order to mark the correct selection the settings list must be
        // updated, too
        settingsList.setSelection(newId);
    }
    // ------------------------------------------------------------------------
    // borderpoint editing
    // ------------------------------------------------------------------------
    protected function extractBorderpointNo(id: String) : int {
        if (StrBeginsWith(id, "bp")) {
            return StringToInt(StrAfterFirst(id, "bp"), 1) - 1;
        } else {
            return -1;
        }
    }
    // ------------------------------------------------------------------------
    public function isBorderpointSelected() : bool {
        return StrBeginsWith(selectedId, "bp");
    }
    // ------------------------------------------------------------------------
    public function getSelectedBorderpoint() : CRadishQuestLayerBorderpoint {
        return areaEntity.getSelectedBorderpoint();
    }
    // ------------------------------------------------------------------------
    public function selectPreviousBorderpoint() {
        var bpNo: int;

        bpNo = (extractBorderpointNo(selectedId) + 1) % settings.border.Size();
        setSelectedId("bp" + IntToString(bpNo + 1));
        areaEntity.selectBorderpoint(bpNo);
    }
    // ------------------------------------------------------------------------
    public function selectNextBorderpoint() {
        var bpNo: int;

        bpNo = extractBorderpointNo(selectedId) - 1;
        bpNo = (settings.border.Size() + bpNo) % settings.border.Size();

        setSelectedId("bp" + IntToString(bpNo + 1));
        areaEntity.selectBorderpoint(bpNo);
    }
    // ------------------------------------------------------------------------
    public function deselectBorderpoint() {
        areaEntity.selectBorderpoint(-1);
    }
    // ------------------------------------------------------------------------
    public function addBorderpoint() : bool {
        var bpNo, newPos, s: int;
        var p1, p2: Vector;

        // refresh settings as interactive mode may have updated position
        // of last bp
        settings = areaEntity.getSettings();
        s = settings.border.Size();

        if (s < 32) {
            bpNo = extractBorderpointNo(selectedId) % s;
            newPos = (bpNo + 1) % s;

            p1 = settings.border[bpNo];
            p2 = settings.border[newPos];
            settings.border.Insert(newPos,
                VecInterpolate(
                    settings.placement.pos,
                    VecInterpolate(p1, p2, 0.5), 1.2)
            );

            // select new borderpoint (note: 1 == first point)
            setSelectedId("bp" + IntToString(newPos + 1));

            areaEntity.setSettings(settings);
            areaEntity.selectBorderpoint(newPos);

            refreshSettingsList();
            return true;
        }
        return false;
    }
    // ------------------------------------------------------------------------
    public function deleteBorderpoint() : bool {
        var bpNo: int;

        bpNo = extractBorderpointNo(selectedId);
        if (settings.border.Size() > 4 && bpNo >= 0) {
            settings.border.Erase(bpNo);

            // first bp always available
            setSelectedId("bp1");

            areaEntity.setSettings(settings);
            areaEntity.selectBorderpoint(0);

            refreshSettingsList();
            return true;
        }
        return false;
    }
    // ------------------------------------------------------------------------
    // expands/reduces border by amount with center as direction
    public function expandBorder(amount: float) : bool {
        if (areaEntity.expandBorder(amount)) {
            refreshSettingsList();
            return true;
        }
        return false;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
