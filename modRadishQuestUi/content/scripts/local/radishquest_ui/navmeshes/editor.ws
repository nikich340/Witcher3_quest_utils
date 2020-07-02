// ----------------------------------------------------------------------------
class CRadishNavMeshEditor extends IRadishUiModeManager {
    protected var log: CModLogger;

    protected var navMesh: CRadishNavMesh;

    protected var settingsList: CRadishUiSettingsList;
    protected var selectedId: String;
    protected var editedSetting: IModUiSetting;

    protected var firstInnerVerticeSlot: int;
    // ------------------------------------------------------------------------
    protected var settings: SRadishNavMeshData;
    // ------------------------------------------------------------------------
    public function init(log: CModLogger, mesh: CRadishNavMesh) {
        this.log = log;
        this.navMesh = mesh;
        navMesh.highlight(true);

        settingsList = new CRadishUiSettingsList in this;
        refreshSettingsList();
        settingsList.preselect(true);
        selectedId = settingsList.getSelectedId();
        navMesh.selectVertexBySlot(0);
    }
    // ------------------------------------------------------------------------
    protected function refreshSettingsList() {
        settings = navMesh.getSettings();
        settingsList.clear();
        navMesh.addUiSettings(settingsList);
        firstInnerVerticeSlot = navMesh.getFirstInnerVertexSlot();
    }
    // ------------------------------------------------------------------------
    public function getSettingsList() : CRadishUiFilteredList {
        return settingsList;
    }
    // ------------------------------------------------------------------------
    public function select(settingsId: String) {
        selectedId = settingsId;
        navMesh.selectVertexBySlot(navMesh.extractVertexSlot(selectedId));
    }
    // ------------------------------------------------------------------------
    public function getSelected() : IModUiSetting {
        editedSetting = getAsUiSetting(selectedId);
        return editedSetting;
    }
    // ------------------------------------------------------------------------
    private function setSelectedId(newId: String) {
        selectedId = newId;
        // in order to mark the correct selection the settings list must be
        // updated, too
        settingsList.setSelection(newId);
    }
    // ------------------------------------------------------------------------
    // settings editing (text input)
    // ------------------------------------------------------------------------
    protected function getAsUiSetting(selectedId: String) : IModUiSetting {
        return navMesh.getAsUiSetting(selectedId);
    }
    // ------------------------------------------------------------------------
    public function syncSelectedSetting() {
        navMesh.syncSetting(selectedId, editedSetting);
        refreshSettingsList();
    }
    // ------------------------------------------------------------------------
    // vertex manipulation
    // ------------------------------------------------------------------------
    public function isVertexSelected() : bool {
        return StrBeginsWith(selectedId, "v");
    }
    // ------------------------------------------------------------------------
    public function getSelectedVertex() : CRadishNavMeshVertex {
        return navMesh.getSelectedVertex();
    }
    // ------------------------------------------------------------------------
    public function selectPreviousVertex() {
        var vertexNo, num: int;
        var vertexSlot: int;

        vertexSlot = navMesh.extractVertexSlot(selectedId);

        if (navMesh.isInnerVertexSelected()) {
            num = settings.vertices.Size() - firstInnerVerticeSlot;

            vertexNo = firstInnerVerticeSlot
                + (num + (vertexSlot - firstInnerVerticeSlot) - 1) % num;
        } else {
            if (firstInnerVerticeSlot >= 0) {
                num = firstInnerVerticeSlot;
            } else {
                num = settings.vertices.Size();
            }
            vertexNo = (num + vertexSlot - 1) % num;
        }
        navMesh.selectVertexBySlot(vertexNo);

        if (navMesh.isInnerVertexSelected()) {
            setSelectedId("vi" + vertexNo);
        } else {
            setSelectedId("vb" + vertexNo);
        }
    }
    // ------------------------------------------------------------------------
    public function selectNextVertex() {
        var vertexNo, num: int;
        var vertexSlot: int;

        vertexSlot = navMesh.extractVertexSlot(selectedId);

        if (navMesh.isInnerVertexSelected()) {
            num = settings.vertices.Size() - firstInnerVerticeSlot;

            vertexNo = firstInnerVerticeSlot + (vertexSlot - firstInnerVerticeSlot + 1) % num;
        } else {
            if (firstInnerVerticeSlot >= 0) {
                num = firstInnerVerticeSlot;
            } else {
                num = settings.vertices.Size();
            }
            vertexNo = (vertexSlot + 1) % num;
        }
        navMesh.selectVertexBySlot(vertexNo);

        if (navMesh.isInnerVertexSelected()) {
            setSelectedId("vi" + vertexNo);
        } else {
            setSelectedId("vb" + vertexNo);
        }
    }
    // ------------------------------------------------------------------------
    public function isInnerVertexteratorActive() : bool {
        return navMesh.isInnerVertexSelected();
    }
    // ------------------------------------------------------------------------
    public function toggleVertexTypeIteration() {
        var vertexId: int;

        if (navMesh.isInnerVertexSelected()) {
            vertexId = navMesh.selectVertexByType(false);   // border
        } else {
            vertexId = navMesh.selectVertexByType(true);   // inner
        }
        setSelectedId(navMesh.getVertexUiSettingId(vertexId));
    }
    // ------------------------------------------------------------------------
    public function deselectVertex() {
        navMesh.selectVertexBySlot(-1);
    }
    // ------------------------------------------------------------------------
    public function cycleTriangleEdge() {
        navMesh.cycleEdge();
    }
    // ------------------------------------------------------------------------
    public function toggleEdgeType() : int {
        return navMesh.toggleSelectedEdgeType();
    }
    // ------------------------------------------------------------------------
    public function addVertex() : bool {
        var bpNo, newPos, s: int;
        var p1, p2: Vector;

        var newVertexId: int;

        if (navMesh.getVertexCount() < 250) {
            newVertexId = navMesh.addVertex();

            refreshSettingsList();
            setSelectedId(navMesh.getVertexUiSettingId(newVertexId));
            return true;
        }
        return false;
    }
    // ------------------------------------------------------------------------
    public function deleteVertex() : bool {
        var newSelectedVertexId: int;

        if (navMesh.getVertexCount() > 4) {
            // vertex deletion may fail!
            if (navMesh.isSelectedVertexDeletable()) {

                newSelectedVertexId = navMesh.deleteVertex();

                refreshSettingsList();
                setSelectedId(navMesh.getVertexUiSettingId(newSelectedVertexId));
                return true;
            }
        }
        return false;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
