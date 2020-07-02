// ----------------------------------------------------------------------------
enum ERadUI_LayerEntityType {
    ERLT_Area,
    ERLT_Waypoint,
    ERLT_Scenepoint,
    ERLT_Mappin,
    ERLT_Actionpoint,
    ERLT_StaticEntity,
    ERLT_InteractiveEntity,
}
// ----------------------------------------------------------------------------
struct SRadUiLayerEntityId {
    var layerId: SRadUiLayerId;
    var entityName: String;
    var no: int;
}
// ----------------------------------------------------------------------------
abstract class CRadishLayerEntity extends IRadishQuestSelectableElement {
    // ------------------------------------------------------------------------
    protected var entityType: String;
    protected var specialization: String; default specialization = "";
    protected var initializedFromEntity: bool;
    // ------------------------------------------------------------------------
    protected var id: SRadUiLayerEntityId;
    protected var caption: String;
    protected var editableCaption: String;
    // ------------------------------------------------------------------------
    protected var placement: SRadishPlacement;
    // ------------------------------------------------------------------------
    protected var proxy: CRadishProxyRepresentation;
    protected var proxyTemplate: String;
    // ------------------------------------------------------------------------
    public function init(layerId: SRadUiLayerId, newPlacement: SRadishPlacement)
    {
        setName("new " + entityType);
        setLayerId(layerId);
        placement = newPlacement;
        initProxy();
    }
    // ------------------------------------------------------------------------
    protected function restoreFromDbgInfo(dbgInfo: SDbgInfo) {}
    // ------------------------------------------------------------------------
    public function cloneFrom(src: CRadishLayerEntity) {
        //TODO visibilitY? highlight?
        // remove old proxy which may have been initialized previously
        proxy.destroy();
    }
    // ------------------------------------------------------------------------
    public function initFromDbgInfos(entity: CEntity) {
        var dbgInfo: SDbgInfo;
        var i, s: int;
        var layerName, layerContext: String;
        var id: String;

        this.initializedFromEntity = true;

        placement.pos = entity.GetWorldPosition();
        placement.rot = entity.GetWorldRotation();

        s = entity.dbgInfo.Size();

        for (i = 0; i < s; i += 1) {
            // encoded meta information in dbgInfo
            dbgInfo = entity.dbgInfo[i];
            switch (dbgInfo.type) {
                case "layername":       layerName = dbgInfo.s;  break;
                case "layercontext":    layerContext = dbgInfo.s; break;
                case "id":              id = dbgInfo.s; break;
                default:                restoreFromDbgInfo(dbgInfo);
            }
        }
        caption = StrReplaceAll(id, "_", " ");
        if (specialization != "") {
            caption = specialization + "." + caption;
        }
        editableCaption = caption;

        this.id = SRadUiLayerEntityId(SRadUiLayerId(layerName, layerContext, true), id);

        initProxy();
    }
    // ------------------------------------------------------------------------
    protected function initProxy() {
        proxy = new CRadishProxyRepresentation in this;
        proxy.init(proxyTemplate, placement, false);
    }
    // ------------------------------------------------------------------------
    public function destroy() {
        proxy.destroy();
    }
    // ------------------------------------------------------------------------
    // meta information
    // ------------------------------------------------------------------------
    public function getLayerId() : SRadUiLayerId {
        return id.layerId;
    }
    // ------------------------------------------------------------------------
    public function getIdString() : String {
        return id.layerId.layerName + ":" + id.layerId.context + ":" + id.layerId.encoded
            + ":" + specialization + "|" + id.entityName + "#" + id.no;
    }
    // ------------------------------------------------------------------------
    public function getId() : SRadUiLayerEntityId {
        return id;
    }
    // ------------------------------------------------------------------------
    public function getIdNo() : int {
        return id.no;
    }
    // ------------------------------------------------------------------------
    public function matchesName(aName: String) : bool {
        return id.entityName == aName;
    }
    // ------------------------------------------------------------------------
    public function getType() : String {
        return entityType;
    }
    // ------------------------------------------------------------------------
    public function getSpecialization() : String {
        return specialization;
    }
    // ------------------------------------------------------------------------
    public function setLayerId(newId: SRadUiLayerId) {
        id.layerId = newId;
    }
    // ------------------------------------------------------------------------
    // naming
    // ------------------------------------------------------------------------
    public function getName() : String {
        return id.entityName;
    }
    // ------------------------------------------------------------------------
    public function getCaption() : String {
        return caption;
    }
    // ------------------------------------------------------------------------
    public function getEditableCaption() : String {
        return editableCaption;
    }
    // ------------------------------------------------------------------------
    public function getExtendedCaption() : String {
        if (proxy.isVisible()) {
            return "v " + caption;
        } else {
            return ". " + caption;
        }
    }
    // ------------------------------------------------------------------------
    public function setName(newName: String) {
        id.entityName = RadUi_escapeAsId(newName);
        if (specialization != "") {
            caption = specialization + "." + StrReplaceAll(id.entityName, "_", " ");
        } else {
            caption = StrReplaceAll(id.entityName, "_", " ");
        }
        editableCaption = caption;
    }
    // ------------------------------------------------------------------------
    // settings editing (text input)
    // ------------------------------------------------------------------------
    public function addUiSettings(settingsList: CRadishUiSettingsList);
    // ------------------------------------------------------------------------
    public function getAsUiSetting(selectedId: String) : IModUiSetting;
    // ------------------------------------------------------------------------
    public function syncSetting(id: String, settingValue: IModUiSetting);
    // ------------------------------------------------------------------------
    // visibility
    // ------------------------------------------------------------------------
    public function getProxy() : IRadishBaseProxyRepresentation {
        return this.proxy;
    }
    // ------------------------------------------------------------------------
    public function toggleVisibility() {
        this.proxy.toggleVisibility();
    }
    // ------------------------------------------------------------------------
    public function show(doShow: bool) {
        proxy.show(doShow);
    }
    // ------------------------------------------------------------------------
    public function highlight(doHighlight: bool) {
        proxy.highlight(doHighlight);
    }
    // ------------------------------------------------------------------------
    public function refreshRepresentation() {
        proxy.moveTo(placement);
    }
    // ------------------------------------------------------------------------
    protected function updateAppearanceSetting(id: name);
    // ------------------------------------------------------------------------
    public function setAppearance(id: name) {
        proxy.setAppearance(id);
        updateAppearanceSetting(proxy.getAppearance());
    }
    // ------------------------------------------------------------------------
    public function cycleAppearance() {
        proxy.cycleAppearance();
        updateAppearanceSetting(proxy.getAppearance());
    }
    // ------------------------------------------------------------------------
    // visualization properties
    // ------------------------------------------------------------------------
    public function getPlacement() : SRadishPlacement {
        return placement;
    }
    // ------------------------------------------------------------------------
    public function setPlacement(newPlacement: SRadishPlacement) {
        placement = newPlacement;
        proxy.moveTo(placement);
    }
    // ------------------------------------------------------------------------
    public function getSize() : Vector {
        var meshSize: Vector;

        meshSize = proxy.getSize();
        if (meshSize.X > 0.5f || meshSize.Y > 0.5f || meshSize.Z > 0.5f) {
            return meshSize;
        } else {
            return Vector();
        }
    }
    // ------------------------------------------------------------------------
    // definition creation
    // ------------------------------------------------------------------------
    public function asDefinition() : SEncValue;
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
abstract class CRadishLayerEntitySetMember extends CRadishLayerEntity {
    // ------------------------------------------------------------------------
    public function assignMemberId(no: int) {
        id.no = no;
        setName(id.entityName);
        if (id.no > 0) {
            caption += " #" + id.no;
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
