// ----------------------------------------------------------------------------
quest function isla_undress() {
  var inv : CInventoryComponent = thePlayer.inv;
  var allItems : array<SItemUniqueId>;
  var i: int;

  // this is not the correct way as those items are not transfered to the inv
  // but oh well...
  inv.GetAllItems(allItems);
  for (i = 0; i < allItems.Size(); i += 1) {
      if (inv.IsItemHeld(allItems[i])) {
          thePlayer.UnequipItem(allItems[i]);
      } else if (inv.IsItemMounted(allItems[i])) {
          inv.UnmountItem(allItems[i]);
      }
  }
}
// ----------------------------------------------------------------------------
quest function IllusionaryquestDoorChangeState(tag : name, newState : string, optional keyItemName : name, optional removeKeyOnUse : bool, optional smoooth : bool, optional dontBlockInCombat : bool ) 
{
  //var newDoorState : EDoorQuestState;

  switch(newState) {
			case "EDQS_Open":
				DoorChangeState(tag, EDQS_Open, keyItemName, removeKeyOnUse, smoooth, dontBlockInCombat);
				break;
			case "EDQS_Close":
				DoorChangeState(tag, EDQS_Close, keyItemName, removeKeyOnUse, smoooth, dontBlockInCombat);
				break;
			case "EDQS_Enable":
				DoorChangeState(tag, EDQS_Enable, keyItemName, removeKeyOnUse, smoooth, dontBlockInCombat);
				break;
			case "EDQS_Disable":
				DoorChangeState(tag, EDQS_Disable, keyItemName, removeKeyOnUse, smoooth, dontBlockInCombat);
				break;
			case "EDQS_RemoveLock":
				DoorChangeState(tag, EDQS_RemoveLock, keyItemName, removeKeyOnUse, smoooth, dontBlockInCombat);
				break;
			case "EDQS_Lock":
				DoorChangeState(tag, EDQS_Lock, keyItemName, removeKeyOnUse, smoooth, dontBlockInCombat);
				break;			
	}
}
