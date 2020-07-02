// ----------------------------------------------------------------------------
abstract class IRadishUiModeManager {}
// ----------------------------------------------------------------------------
abstract class IRadishSizedElement extends IRadishResizeableElement {}
// ----------------------------------------------------------------------------
abstract class IRadishHighlightableElement extends IRadishSizedElement {
    // ------------------------------------------------------------------------
    public function matchesName(id: String) : bool;
    // ------------------------------------------------------------------------
    public function highlight(doHighlight: bool);
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
abstract class IRadishAdjustableAsset extends IRadishHighlightableElement {
    // ------------------------------------------------------------------------
    public function getProxy() : IRadishBaseProxyRepresentation;
    // ------------------------------------------------------------------------
    public function onPlacementStart() {
        getProxy().onPlacementStart();
        highlight(true);
    }
    // ------------------------------------------------------------------------
    public function onPlacementEnd() {
        highlight(false);
        getProxy().onPlacementEnd();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
abstract class IRadishQuestSelectableElement extends IRadishAdjustableAsset {
    // ------------------------------------------------------------------------
    public function getCaption() : String;
    // ------------------------------------------------------------------------
    public function toggleVisibility();
    // ------------------------------------------------------------------------
    //public function show(doShow: bool);
    // ------------------------------------------------------------------------
    public function refreshRepresentation();
    // ------------------------------------------------------------------------
    public function cycleAppearance();
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
