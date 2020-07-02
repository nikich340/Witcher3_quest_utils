// ----------------------------------------------------------------------------
class CRadishUiSingleLayerEntityList extends CModUiFilteredList {
    // ------------------------------------------------------------------------
    public function setLayer(layer: CRadishQuestLayer) : int {
        var i, s: int;
        var layerItems: array<CRadishLayerEntity>;
        var layerItem: CRadishLayerEntity;

        items.Clear();

        layerItems = layer.getItems();
        s = layerItems.Size();
        for (i = 0; i < s; i += 1) {
            layerItem = layerItems[i];

            items.PushBack(SModUiCategorizedListItem(
                layerItem.getIdString(),
                layerItem.getCaption(),
                layerItem.getType()
            ));
        }
        return items.Size();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CRadishUiLayerEntityCategoryList extends CRadishUiListProvider {
    // ------------------------------------------------------------------------
    private var layer: CRadishQuestLayer;
    // ------------------------------------------------------------------------
    public function setLayer(layer: CRadishQuestLayer) {
        this.layer = layer;
        this.refreshList();
    }
    // ------------------------------------------------------------------------
    public function refreshList() {
        var i, s: int;
        var categories: array<SRadUiLayerEntityCategory>;
        var category: SRadUiLayerEntityCategory;

        items.Clear();

        categories = layer.getCategories();
        s = categories.Size();
        for (i = 0; i < s; i += 1) {
            category = categories[i];

            items.PushBack(SModUiListItem(
                category.id,
                category.caption,
            ));
        }
    }
    // ------------------------------------------------------------------------
    public function preselect() {
        if (items.Size() > 0) {
            items[0].isSelected = true;
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CRadishQuestLayerEditor {
    private var log: CModLogger;
    // ------------------------------------------------------------------------
    private var layer: CRadishQuestLayer;

    // all categories in layer
    private var categoryListProvider: CRadishUiLayerEntityCategoryList;
    // all entities in layer
    private var entityListProvider: CRadishUiMultiCategoryLayerEntityList;
    // ------------------------------------------------------------------------
    public function init(log: CModLogger, layer: CRadishQuestLayer) {
        this.log = log;
        this.layer = layer;
        log.debug("layer editor: " + layer.getName());

        entityListProvider = new CRadishUiMultiCategoryLayerEntityList in this;
        entityListProvider.setLayer(this.layer);

        categoryListProvider = new CRadishUiLayerEntityCategoryList in this;
        categoryListProvider.setLayer(this.layer);

        // make sure there is always one item selected
        categoryListProvider.preselect();
        entityListProvider.preselect(true);
    }
    // ------------------------------------------------------------------------
    public function getCategoryList() : CRadishUiListProvider {
        return this.categoryListProvider;
    }
    // ------------------------------------------------------------------------
    public function getEntityList() : CModUiFilteredList {
        return this.entityListProvider;
    }
    // ------------------------------------------------------------------------
    public function toggleVisibility(category: String) {
        var selectedId: String;
        selectedId = categoryListProvider.getSelectedId();

        this.layer.toggleCategoryVisibility(category);
        categoryListProvider.setLayer(this.layer);

        categoryListProvider.setSelection(selectedId);
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
