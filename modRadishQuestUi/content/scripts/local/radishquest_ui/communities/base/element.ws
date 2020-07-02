// ----------------------------------------------------------------------------
abstract class CRadishCommunityElement extends IRadishQuestSelectableElement {
    // ------------------------------------------------------------------------
    protected var id: String;
    protected var caption: String;
    // ------------------------------------------------------------------------
    public function init() {
        //TODO set visualizationmanager to toggle external proxies like aps, areas etc.
    }
    // ------------------------------------------------------------------------
    public function getId() : String {
        return this.id;
    }
    // ------------------------------------------------------------------------
    public function getCaption() : String {
        return this.caption;
    }
    // ------------------------------------------------------------------------
    public function highlight(doHighlight: bool) {
        //TODO
    }
    // ------------------------------------------------------------------------
    public function toggleVisibility() {
        //TODO
    }
    // ------------------------------------------------------------------------
    public function refreshRepresentation() {
        //TODO
    }
    // ------------------------------------------------------------------------
    public function cycleAppearance() {
        //TODO
    }
    // ------------------------------------------------------------------------
    public function getPlacement() : SRadishPlacement {
        var null: SRadishPlacement;

        return null;
    }
    // ------------------------------------------------------------------------
    public function getSize() : Vector {
        return Vector();
    }
    // ------------------------------------------------------------------------
    public function getExtendedCaption(parentPrefix: String) : String {
        return parentPrefix + caption;
    }
    // ------------------------------------------------------------------------
    public function setId(newId: String) {
        this.id = newId;
        refreshCaption();
    }
    // ------------------------------------------------------------------------
    private function refreshCaption() {
        this.caption = id;
        StrReplaceAll(this.caption, "_", " ");
    }
    // ------------------------------------------------------------------------
    public function asDefinition() : SEncValue;
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
