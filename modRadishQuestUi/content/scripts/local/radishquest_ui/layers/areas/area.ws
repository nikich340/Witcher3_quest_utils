// ----------------------------------------------------------------------------
class CRadishQuestLayerArea extends CRadishLayerEntity {
    // ------------------------------------------------------------------------
    default entityType = "area";
    default specialization = "";
    // ------------------------------------------------------------------------
    default proxyTemplate = "dlc\modtemplates\radishquestui\areas\plane.w2ent";
    protected var settings: SRadishLayerAreaData;
    // ------------------------------------------------------------------------
    private var borderpoint: CRadishQuestLayerBorderpoint;
    private var selectedBorderpoint: int; default selectedBorderpoint = -1;
    // ------------------------------------------------------------------------
    public function init(layerId: SRadUiLayerId, newPlacement: SRadishPlacement)
    {
        // init settings before call to initProxy (in init)
        settings.height = 2.0;
        settings.border.PushBack(newPlacement.pos + Vector(-2, 2, 0));
        settings.border.PushBack(newPlacement.pos + Vector(-2, -2, 0));
        settings.border.PushBack(newPlacement.pos + Vector(2, -2, 0));
        settings.border.PushBack(newPlacement.pos + Vector(2, 2, 0));
        settings.placement = newPlacement;

        super.init(layerId, newPlacement);
    }
    // ------------------------------------------------------------------------
    protected function initProxy() {
        proxy = new CRadishAreaProxy in this;
        proxy.init(proxyTemplate, placement, false);

        ((CRadishAreaProxy)proxy).setSettings(settings);

        // not strictly a proxy but a thin wrapper which gets passed around to
        // interactive placement mode (and auto syncs with this area)
        initBorderpoint();
    }
    // ------------------------------------------------------------------------
    public function initFromData(data: SRadishLayerAreaData) {
        initProxy();
        setSettings(data);
    }
    // ------------------------------------------------------------------------
    public function initFromDbgInfos(entity: CEntity) {
        var bbox: Box;
        var comp: CAreaComponent;

        comp = ((CAreaComponent)entity.GetComponentByClassName('CAreaComponent'));
        comp.GetWorldPoints(settings.border);

        bbox = comp.GetBoundingBox();
        settings.height = MaxF(1.0, bbox.Max.Z - bbox.Min.Z);
        // super method spawns proxy therefore settings must already contain
        // correct placement
        settings.placement.pos = entity.GetWorldPosition();
        settings.placement.rot = entity.GetWorldRotation();

        super.initFromDbgInfos(entity);

        // default color
        setAppearance('lilac');
    }
    // ------------------------------------------------------------------------
    public function cloneFrom(src: CRadishLayerEntity) {
        var newSettings: SRadishLayerAreaData;

        super.cloneFrom(src);

        newSettings = ((CRadishQuestLayerArea)src).getSettings();
        // placement is valid in all "other" types
        newSettings.placement = src.getPlacement();

        this.initFromData(newSettings);

        // default color
        setAppearance('lilac');
    }
    // ------------------------------------------------------------------------
    public function getExtendedCaption() : String {
        return super.getExtendedCaption() + " [" + settings.border.Size() + "]";
    }
    // ------------------------------------------------------------------------
    public function setPlacement(newPlacement: SRadishPlacement) {
        var diffPos: Vector;
        var i, s: int;

        diffPos = newPlacement.pos - placement.pos;

        settings.placement = newPlacement;
        s = settings.border.Size();
        for (i = 0; i < s; i += 1) {
            settings.border[i] += diffPos;
        }
        super.setPlacement(newPlacement);
    }
    // ------------------------------------------------------------------------
    public function refreshRepresentation() {
        ((CRadishAreaProxy)proxy).setSettings(settings);
    }
    // ------------------------------------------------------------------------
    // settings
    // ------------------------------------------------------------------------
    public function getSettings() : SRadishLayerAreaData {
        settings.id = id.entityName;
        settings.areaname = id.entityName;

        // this has to be updated as base class contains the current placement data
        settings.placement = placement;
        return settings;
    }
    // ------------------------------------------------------------------------
    public function setSettings(newSettings: SRadishLayerAreaData) {
        settings = newSettings;
        placement = settings.placement;
        setName(settings.areaname);

        borderpoint.setPlacement(SRadishPlacement(settings.border[selectedBorderpoint]));
        borderpoint.setHeight(settings.height);
        ((CRadishAreaProxy)proxy).setSettings(settings);
    }
    // ------------------------------------------------------------------------
    protected function updateAppearanceSetting(id: name) {
        settings.appearance = id;
    }
    // ------------------------------------------------------------------------
    // settings editing (text input)
    // ------------------------------------------------------------------------
    public function addUiSettings(settingsList: CRadishUiSettingsList) {
        var bpNo: String;
        var i: int;

        settingsList.addSetting("h", "height: " + FloatToString(settings.height));

        for (i = 0; i < settings.border.Size(); i += 1) {
            bpNo = IntToString(i + 1);
            settingsList.addSetting(
                "bp" + bpNo,
                "corner: " + UiSettingVecToString(settings.border[i]),
                "borderpoints");
        }
    }
    // ------------------------------------------------------------------------
    public function getAsUiSetting(id: String) : IModUiSetting {
        var null: IModUiSetting;
        var bpPointNo: int;

        switch (id) {
            case "h":   return FloatToUiSetting(this, settings.height);

            default:
                bpPointNo = extractBorderpointNo(id);
                if (bpPointNo >= 0) {
                    return VecToUiSetting(this, settings.border[bpPointNo]);
                }
                return null;
        }
    }
    // ------------------------------------------------------------------------
    public function syncSetting(id: String, settingValue: IModUiSetting) {
        var bpPointNo: int;

        switch (id) {
            case "h":   settings.height = UiSettingToFloat(settingValue); break;

            default:
                bpPointNo = extractBorderpointNo(id);
                if (bpPointNo >= 0) {
                    settings.border[bpPointNo] = UiSettingToVector(settingValue);
                    settings.border[bpPointNo].Z = settings.placement.pos.Z;
                }
        }
    }
    // ------------------------------------------------------------------------
    protected function extractBorderpointNo(id: String) : int {
        if (StrBeginsWith(id, "bp")) {
            return StringToInt(StrAfterFirst(id, "bp"), 1) - 1;
        } else {
            return -1;
        }
    }
    // ------------------------------------------------------------------------
    // border manipulation
    // ------------------------------------------------------------------------
    protected function initBorderpoint() {
        borderpoint = new CRadishQuestLayerBorderpoint in this;
        borderpoint.init(this, settings.border[0], settings.height);
        borderpoint.show(false);
    }
    // ------------------------------------------------------------------------
    public function getBorderpointCount() : int {
        return settings.border.Size();
    }
    // ------------------------------------------------------------------------
    public function selectBorderpoint(bpNo: int) {
        selectedBorderpoint = bpNo;

        if (bpNo >= 0 && bpNo < settings.border.Size()) {
            borderpoint.setPlacement(SRadishPlacement(settings.border[bpNo]));
            borderpoint.show(true);
        } else {
            // just hide the bp
            borderpoint.show(false);
        }
    }
    // ------------------------------------------------------------------------
    public function getSelectedBorderpoint() : CRadishQuestLayerBorderpoint {
        return borderpoint;
    }
    // ------------------------------------------------------------------------
    public function syncSelectedBorderpoint() {
        var newPlacement: SRadishPlacement;

        newPlacement = borderpoint.getPlacement();
        // ignore z changes as it breaks the plane calculation (and makes no sense
        // for borderpoints)
        newPlacement.pos.Z = placement.pos.Z;
        settings.border[selectedBorderpoint] = newPlacement.pos;

        ((CRadishAreaProxy)proxy).setSettings(settings);
    }
    // ------------------------------------------------------------------------
    // expands/reduces border by amount with center as direction
    public function expandBorder(amount: float) : bool {
        var i, s: int;
        var distance: float;
        var newPoints: array<Vector>;
        var center: Vector;

        s = settings.border.Size();
        center = placement.pos;
        for (i = 0; i < s; i += 1) {
            distance = VecDistance(center, settings.border[i]) + amount;
            if (distance < 1.0 || distance > 5000.0) {
                return false;
            }
            newPoints.PushBack(center + VecNormalize(settings.border[i] - center) * distance);
        }
        settings.border = newPoints;
        ((CRadishAreaProxy)proxy).setSettings(settings);

        // refresh position of borderpoint
        selectBorderpoint(selectedBorderpoint);

        return true;
    }
    // ------------------------------------------------------------------------
    // definition creation
    // ------------------------------------------------------------------------
    public function asDefinition() : SEncValue {
        var content: SEncValue;
        var bpList: SEncValue;
        var i: int;

        content = SEncValue(EEVT_Map);
        if (settings.height != 2.0) {
            content.m.PushBack(SEncKeyValue("height", FloatToEncValue(settings.height)));
        } else {
            // add comment
            content.m.PushBack(SEncKeyValue("#height", FloatToEncValue(2.0)));
        }

        bpList = SEncValue(EEVT_List);
        for (i = 0; i < settings.border.Size(); i += 1) {
            bpList.l.PushBack(PosToEncValue(settings.border[i]));
        }
        content.m.PushBack(SEncKeyValue("borderpoints", bpList));

        return content;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
