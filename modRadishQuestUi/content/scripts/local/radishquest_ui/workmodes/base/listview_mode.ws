// ----------------------------------------------------------------------------
class CRadishWorkModePopupCallback extends IModUiConfirmPopupCallback {
    public var callback: CRadishListViewWorkMode;

    public function OnConfirmed(action: String) {
        switch (action) {
            case "deleteEntity":
                ((CRadishQuestLayerEntityMode)callback).OnDeleteConfirmed();
                break;
            case "deleteLayer":
                ((CRadishQuestLayerMode)callback).OnDeleteConfirmed();
                break;
            case "cloneLayer":
                ((CRadishQuestLayerMode)callback).OnCloneConfirmed();
                break;
            case "deleteNavMesh":
                ((CRadishNavMeshMode)callback).OnDeleteConfirmed();
                break;
        }
    }
}
// ----------------------------------------------------------------------------
class CRadishWorkModeUiListCallback extends IModUiEditableListCallback {
    public var callback: CRadishListViewWorkMode;

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
        var null: CModUiEditableListView;
        delete this.listMenuRef;
        this.listMenuRef = null;
        callback.OnClosedView();
    }

    public function OnSelected(optionName: String) {
        callback.OnSelected(optionName);
    }
}
// ----------------------------------------------------------------------------
abstract state RadUi_ListSelect in CRadishListViewWorkMode extends RadUi_WorkModeRootState
{
    // ------------------------------------------------------------------------
    protected var listProvider: CRadishUiListProvider;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        super.OnEnterState(prevStateName);
        parent.showUi(true);
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        parent.OnHotkeyHelp(hotkeyList);

        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectPrev'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SelectNext'));
    }
    // ------------------------------------------------------------------------
    event OnToggleUi(action: SInputAction) {
        if (IsPressed(action)) {
            parent.toggleUi();
        }
    }
    // ------------------------------------------------------------------------
    event OnSelected(optionId: String);
    // ------------------------------------------------------------------------
    event OnCycleSelection(action: SInputAction) {
        var optionId: String;

        if (IsPressed(action)) {
            if (action.aName == 'RADUI_SelectPrev') {
                optionId = listProvider.getPreviousId();
            } else {
                optionId = listProvider.getNextId();
            }
            OnSelected(optionId);
        }
    }
    // ------------------------------------------------------------------------
    event OnUpdateView() {
        updateView();
    }
    // ------------------------------------------------------------------------
    protected function updateView() {
        parent.view.listMenuRef.setListData(listProvider.getList());
        parent.view.listMenuRef.updateView();
    }
    // ------------------------------------------------------------------------
    protected function registerListeners() {
        super.registerListeners();
        theInput.RegisterListener(this, 'OnToggleUi', 'RADUI_ToggleUi');
        theInput.RegisterListener(this, 'OnCycleSelection', 'RADUI_SelectPrev');
        theInput.RegisterListener(this, 'OnCycleSelection', 'RADUI_SelectNext');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        theInput.UnregisterListener(this, 'RADUI_ToggleUi');
        theInput.UnregisterListener(this, 'RADUI_SelectPrev');
        theInput.UnregisterListener(this, 'RADUI_SelectNext');
    }
    // ------------------------------------------------------------------------
}

// ----------------------------------------------------------------------------
abstract state RadUi_FilteredListSelect in CRadishListViewWorkMode
    extends RadUi_WorkModeRootState
{
    // ------------------------------------------------------------------------
    protected var listProvider: CRadishUiFilteredList;
    protected var searchFilterInput: bool;
    // ------------------------------------------------------------------------
    event OnEnterState(prevStateName: CName) {
        super.OnEnterState(prevStateName);
        parent.showUi(true);
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnHotkeyHelp(out hotkeyList: array<SModUiHotkeyHelp>) {
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_SetFilter'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ResetFilter'));
        hotkeyList.PushBack(HotkeyHelp_from('RADUI_ListCategoryUp'));
        parent.OnHotkeyHelp(hotkeyList);
    }
    // ------------------------------------------------------------------------
    event OnToggleUi(action: SInputAction) {
        if (IsPressed(action)) {
            parent.toggleUi();
        }
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
            searchFilterInput = true;
            parent.view.listMenuRef.startInputMode(
                GetLocStringByKeyExt("RADUI_lListFilter"),
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
        searchFilterInput = false;
    }
    // ------------------------------------------------------------------------
    event OnInputCancel() {
        searchFilterInput = false;
        parent.notice(GetLocStringByKeyExt("UI_CanceledSearch"));

        parent.view.listMenuRef.resetEditField();
        updateView();
    }
    // ------------------------------------------------------------------------
    event OnSelected(optionId: String);
    // ------------------------------------------------------------------------
    event OnCycleSelection(action: SInputAction) {
        var optionId: String;

        if (IsPressed(action)) {
            if (action.aName == 'RADUI_SelectPrev') {
                optionId = listProvider.getPreviousId();
            } else {
                optionId = listProvider.getNextId();
            }
            OnSelected(optionId);
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
                GetLocStringByKeyExt("RADUI_lListFilter"), wildcard);
        }
        updateView();
    }
    // ------------------------------------------------------------------------
    protected function updateView() {
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
        super.registerListeners();
        theInput.RegisterListener(this, 'OnToggleUi', 'RADUI_ToggleUi');
        theInput.RegisterListener(this, 'OnFilter', 'RADUI_SetFilter');
        theInput.RegisterListener(this, 'OnResetFilter', 'RADUI_ResetFilter');
        theInput.RegisterListener(this, 'OnCategoryUp', 'RADUI_ListCategoryUp');

        theInput.RegisterListener(this, 'OnCycleSelection', 'RADUI_SelectPrev');
        theInput.RegisterListener(this, 'OnCycleSelection', 'RADUI_SelectNext');
    }
    // ------------------------------------------------------------------------
    protected function unregisterListeners() {
        super.unregisterListeners();
        theInput.UnregisterListener(this, 'RADUI_ToggleUi');
        theInput.UnregisterListener(this, 'RADUI_SetFilter');
        theInput.UnregisterListener(this, 'RADUI_ResetFilter');
        theInput.UnregisterListener(this, 'RADUI_ListCategoryUp');

        theInput.UnregisterListener(this, 'RADUI_SelectPrev');
        theInput.UnregisterListener(this, 'RADUI_SelectNext');
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
abstract statemachine class CRadishListViewWorkMode extends CRadishWorkMode {
    // ------------------------------------------------------------------------
    protected var defaultState: CName;
    // ------------------------------------------------------------------------
    protected var view: CRadishWorkModeUiListCallback;
    protected var confirmPopup: CModUiActionConfirmation;
    protected var popupCallback: CRadishWorkModePopupCallback;
    // ------------------------------------------------------------------------
    // flags indicating to pop state/go back to parent *after* currently open
    // view is closed
    private var popStateAfterViewClose: bool;
    private var backToParentAfterViewClose: SInputAction;
    // ------------------------------------------------------------------------
    public function init(modeManager: IRadishUiModeManager, config: CRadishQuestConfigManager)
    {
        super.init(modeManager, config);

        // prepare view callback wiring
        view = new CRadishWorkModeUiListCallback in this;
        view.callback = this;

        popupCallback = new CRadishWorkModePopupCallback in this;
        popupCallback.callback = this;
    }
    // ------------------------------------------------------------------------
    public function activate() {
        super.activate();
        PushState(defaultState);
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
    event OnClosedView() {
        var null: SInputAction;
        if (popStateAfterViewClose) {
            popStateAfterViewClose = false;
            PopState();
        } else if (backToParentAfterViewClose != null) {
            super.backToParent(backToParentAfterViewClose);
            backToParentAfterViewClose = null;
        }
    }
    event OnSelected(optionName: String) {}
    // ------------------------------------------------------------------------
    protected function backToParent(action: SInputAction) {
        var null: CModUiEditableListView;

        if (IsReleased(action)) {
            if (isUiShown()) {
                // defer restoring previous workmode to enable clean close of listview
                // otherwise (previous) workmode tries to open view on OnEnterState but
                // it gets immediately closed again

                // view is closed automatically only if action was triggered with
                // ESCAPE otherwise it has to be closed manually
                if (action.aName != 'RADUI_Back') {
                    showUi(false);
                }
                backToParentAfterViewClose = action;
                delete view.listMenuRef;
                view.listMenuRef = null;
            } else {
                super.backToParent(action);
            }
        }
    }
    // ------------------------------------------------------------------------
    protected function backToPreviousState(action: SInputAction) {
        var null: CModUiEditableListView;

        if (IsReleased(action)) {
            if (isUiShown()) {
                // defer restoring previous state to enable clean close of listview
                // otherwise (previous) state tries to open view on OnEnterState but
                // it gets immediately closed again
                popStateAfterViewClose = true;
                // since back is bound to ESCAPE which automatically closes an
                // open menu view the view must no be closed *again*
                delete view.listMenuRef;
                view.listMenuRef = null;
            } else {
                PopState();
            }
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
