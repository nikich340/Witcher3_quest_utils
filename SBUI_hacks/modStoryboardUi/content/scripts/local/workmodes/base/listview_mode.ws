// ----------------------------------------------------------------------------
// Wires generic UI with asset mode Controller
//
class CModSbWorkModeUiListCallback extends IModUiEditableListCallback {
    public var callback: CModSbListViewWorkMode;

    public function OnOpened() {
        callback.OnUpdateView();
    }

    public function OnInputEnd(inputString: String) {
        callback.OnInputEnd(inputString);
    }

    public function OnInputCancel() {
        callback.OnInputCancel();
    }

    public function OnClosed() {
        delete listMenuRef;
        callback.OnClosedView();
    }

    public function OnSelected(optionName: String) {
        callback.OnSelected(optionName);
    }
}
// ----------------------------------------------------------------------------
abstract state SbUi_FilteredListSelect in CModSbListViewWorkMode {
    // ------------------------------------------------------------------------
    protected var listProvider: CModUiFilteredList;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        registerListeners();

        parent.showUi(true);
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnLeaveState(nextStateName: CName) {
        unregisterListeners();
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        parent.OnHotkeyHelp(hotkeyList);

        hotkeyList.PushBack(HotkeyHelp_from('SBUI_SetFilter'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ResetFilter'));
        hotkeyList.PushBack(HotkeyHelp_from('SBUI_ListCategoryUp'));
    }
    // ------------------------------------------------------------------------
    event OnCategoryUp(action: SInputAction) {
        if (IsPressed(action)) {
            listProvider.clearLowestSelectedCategory();
            updateView();
        }
    }
    // ------------------------------------------------------------------------
    event OnResetFilter() {
        listProvider.resetWildcardFilter();
        parent.view.listMenuRef.resetEditField();

        updateView();
    }
    // ------------------------------------------------------------------------
    event OnFilter(action: SInputAction) {
        if (!parent.view.listMenuRef.isEditActive() && IsPressed(action)) {

            parent.view.listMenuRef.startInputMode(
                GetLocStringByKeyExt("SBUI_lListFilter"),
                listProvider.getWildcardFilter());
        }
    }
    // ------------------------------------------------------------------------
    event OnInputEnd(inputString: String) {
        if (inputString == "") {
            OnResetFilter();
        } else {
            // Note: filter field is not removed to indicate the current filter
            listProvider.setWildcardFilter(inputString);
            updateView();
        }
    }
    // ------------------------------------------------------------------------
    event OnInputCancel() {
        parent.notice(GetLocStringByKeyExt("UI_CanceledSearch"));

        parent.view.listMenuRef.resetEditField();
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnSelected(optionId: String);
    // ------------------------------------------------------------------------
    event OnCycleSelection(action: SInputAction) {
        var templateId: String;

        if (IsPressed(action)) {
            if (action.aName == 'SBUI_SelectPrev') {
                templateId = listProvider.getPreviousId();
            } else {
                templateId = listProvider.getNextId();
            }
            OnSelected(templateId);
        }
    }
    // ------------------------------------------------------------------------
    event OnBack(action: SInputAction) {
        if (IsPressed(action)) {
            parent.PopState();
        }
    }
    // ------------------------------------------------------------------------
    event OnUpdateView() {
        var wildcard: String;
        // Note: if search filter is active show the wildcard to indicate the
        // current filter
        wildcard = listProvider.getWildcardFilter();
        if (wildcard != "") {
            parent.view.listMenuRef.setInputFieldData(
                GetLocStringByKeyExt("SBUI_lListFilter"), wildcard);
        }
        updateView();
    }
    // ------------------------------------------------------------------------
    protected function updateView() {
        // assets are categorized => listSize != assetcount
        // provide info to override stats info in listview
        parent.view.listMenuRef.setListData(
            listProvider.getFilteredList(),
            // list may contain category entries which do not count as items!
            listProvider.getMatchingItemCount(),
            // number of items without filtering
            listProvider.getTotalCount());

        parent.view.listMenuRef.updateView();
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        theInput.RegisterListener(this, 'OnFilter', 'SBUI_SetFilter');
        theInput.RegisterListener(this, 'OnResetFilter', 'SBUI_ResetFilter');
        theInput.RegisterListener(this, 'OnCategoryUp', 'SBUI_ListCategoryUp');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        theInput.UnregisterListener(this, 'SBUI_SetFilter');
        theInput.UnregisterListener(this, 'SBUI_ResetFilter');
        theInput.UnregisterListener(this, 'SBUI_ListCategoryUp');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
abstract statemachine class CModSbListViewWorkMode extends CModStoryBoardWorkMode {
    // ------------------------------------------------------------------------
    protected var view: CModSbWorkModeUiListCallback;
    protected var confirmPopup: CModUiActionConfirmation;
    protected var popupCallback: CModSbWorkModePopupCallback;
    // ------------------------------------------------------------------------
    public function init(optional storyboard: CModStoryBoard) {
        super.init(storyboard);

        // prepare view callback wiring
        view = new CModSbWorkModeUiListCallback in this;
        view.callback = this;

        popupCallback = new CModSbWorkModePopupCallback in this;
        popupCallback.callback = this;
    }
    // ------------------------------------------------------------------------
    public function isUiShown() : bool {
        return view.listMenuRef;
    }
    // ------------------------------------------------------------------------
    public function showUi(showUi: bool) {
        if (showUi) {
            if (!view.listMenuRef) {
                theGame.RequestMenu('ListView', view);
            }
        } else {
            if (view.listMenuRef) {
                view.listMenuRef.close();
            }
        }
    }
    // ------------------------------------------------------------------------
    // events required for generalized listview callback (maybe this should go
    // into a dedicated subclass?)
    event OnUpdateView() {}
    event OnInputEnd(inputString: String) {}
    event OnInputCancel() {}
    event OnClosedView() {}
    event OnSelected(optionName: String) {}
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
