// ----------------------------------------------------------------------------
class CRadishUiLayerEntityList extends CRadishUiFilteredList {
    // ------------------------------------------------------------------------
    public function setItemList(layerItems: array<CRadishLayerEntity>) {
        var i, s: int;

        items.Clear();
        s = layerItems.Size();
        for (i = 0; i < s; i += 1) {
            items.PushBack(SModUiCategorizedListItem(
                layerItems[i].getIdString(),
                layerItems[i].getExtendedCaption(),
            ));
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CRadishUiMultiCategoryLayerEntityList extends CRadishUiFilteredList {
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
class CRadishUiMultiLayerEntityList extends CRadishUiFilteredList {
    // ------------------------------------------------------------------------
    public function setLayerList(layers: array<CRadishQuestLayer>, showShadowed: bool) : int {
        var l, ls, i, is: int;
        var layer: CRadishQuestLayer;
        var layerItems: array<CRadishLayerEntity>;
        var layerItem: CRadishLayerEntity;

        items.Clear();

        ls = layers.Size();

        for (l = 0; l < ls; l += 1) {
            layer = layers[l];

            if (showShadowed || !((CEncodedRadishQuestLayer)layer).isShadowed()) {

                layerItems = layer.getItems();
                is = layerItems.Size();

                for (i = 0; i < is; i += 1) {
                    layerItem = layerItems[i];

                    items.PushBack(SModUiCategorizedListItem(
                        layerItem.getIdString(),
                        layerItem.getCaption(),
                        layer.getCaption(),
                        layerItem.getType()
                    ));
                }
            }
        }

        return items.Size();
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
