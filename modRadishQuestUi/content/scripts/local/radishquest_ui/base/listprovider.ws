// ----------------------------------------------------------------------------
abstract class CRadishUiListProvider {
    protected var items: array<SModUiListItem>;

    protected var selectedSlot: int;
    // ------------------------------------------------------------------------
    public function setSelection(id: String) {
        var i, s: int;

        s = items.Size();
        for (i = 0; i < s; i += 1) {
            if (items[i].id == id) {
                items[i].isSelected = true;
                selectedSlot = i;
            } else {
                items[i].isSelected = false;
            }
        }
    }
    // ------------------------------------------------------------------------
    public function getSelectedId() : String {
        return items[selectedSlot].id;
    }
    // ------------------------------------------------------------------------
    public function getPreviousId() : String {
        var slot: int;
        slot = (items.Size() + selectedSlot - 1) % items.Size();

        return items[slot].id;
    }
    // ------------------------------------------------------------------------
    public function getNextId() : String {
        var slot: int;
        slot = (selectedSlot + 1) % items.Size();

        return items[slot].id;
    }
    // ------------------------------------------------------------------------
    public function getList() : array<SModUiListItem> {
        return items;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
