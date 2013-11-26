class X_COM_InventoryManager_OLD extends InventoryManager;

/*

//=============================================================================
// Variables
//=============================================================================


//=============================================================================
// Functions
//=============================================================================

/**
 * Calculate the total item weight in item queue
 * 
 * @return double
 */
function float getTotalWeight()
{
  local float lTotalWeight;
	local Inventory lItem;

  lTotalWeight = 0.0;

  for(lItem = InventoryChain; lItem != None; lItem = lItem.Inventory){
	  lTotalWeight += X_COM_Inventory(lItem).mReference.mWeight;
  }

	return lTotalWeight;
}

function X_COM_Inventory findEquippedItem(XCOMDB_Ref_Location aLocation)
{
	local Inventory lItem;
  local XCOMDB_Ref_Location lItemLocation;

  for(lItem = InventoryChain; lItem != None; lItem = lItem.Inventory){
    lItemLocation = X_COM_Inventory(lItem).mContainerLocation;

    if(lItemLocation == aLocation){
      return X_COM_Inventory(lItem);
    }
    if(aLocation.mIdent == "loc_both"){
      if(lItemLocation.mIdent == "loc_both" ||
         lItemLocation.mIdent == "loc_primary" ||
         lItemLocation.mIdent == "loc_secondary"){
        return X_COM_Inventory(lItem);
      }
    }else if(aLocation.mIdent == "loc_primary"){
      if(lItemLocation.mIdent == "loc_both" ||
         lItemLocation.mIdent == "loc_primary"){
        return X_COM_Inventory(lItem);
      }
    }else if(aLocation.mIdent == "loc_secondary"){
      if(lItemLocation.mIdent == "loc_both" ||
         lItemLocation.mIdent == "loc_secondary"){
        return X_COM_Inventory(lItem);
      }
    }
  }
  return none;
}

/**
 * Attempts to remove an item from the inventory list if it exists.
 *
 * @param[in]	aItemToRemove [Inventory]
 */
simulated function RemoveFromInventory(Inventory aItemToRemove)
{
	local Inventory lItem;
	local bool lFound;

  lFound = false;

	if(aItemToRemove != None){
		if(InventoryChain == aItemToRemove){
			lFound = true;
			InventoryChain = aItemToRemove.Inventory;
		}
		else
		{
			// If this item is in our inventory chain, unlink it.
			for(lItem = InventoryChain; lItem != none; lItem = lItem.Inventory){
				if(lItem.Inventory == aItemToRemove){
					lFound = true;
					lItem.Inventory = aItemToRemove.Inventory;
					break;
				}
			}
		}

		if( lFound ){
			`LogInv("removed" @ aItemToRemove);
			aItemToRemove.ItemRemovedFromInvManager();
			aItemToRemove.SetOwner(none);
			aItemToRemove.Inventory = none;
		}

		// make sure we don't have other references to the item
		if( aItemToRemove == Instigator.Weapon ){
			Instigator.Weapon = none;
		}
	}
}

/**
 * Discard full inventory, generally because the owner died
 */
simulated function DiscardInventory()
{
	local Inventory	lInventory;

	`LogInv("");

	ForEach InventoryActors(class'Inventory', lInventory){
		lInventory.Destroy();
	}
}

/**
 * Create the inventory for the given Pawn from the loaded gameplay database.
 * 
 * @param[in] aPawn [X_COM_Pawn]
 * 
 * @return bool
 */
simulated function loadInventoryFromDatabase(X_COM_Pawn aPawn)
{
  local X_COM_GameInfo lGameInfo;
  local XCOMDB_Manager lDBMgr;
  local XCOMDB_DLLAPI lDLLAPI;
  local string lQuery;

  local int il;
  local int lItemID;
  local int lItemRefID;
  local X_COM_Inventory lNewItem;
  local string lItemContainerLoc;

  local array<XCOMDB_Ref_Item> lRefItems;
  local array<X_COM_Inventory> lNewItems;
  local array<string> lNewItemContainerLocs;

  lGameInfo = X_COM_GameInfo(WorldInfo.Game);
  if(lGameInfo == none){
    `log("No valid GameInfo to create inventory!");
    return;
  }
  
  lDBMgr = lGameInfo.getDBMgr();  
  lDBMgr.getDBCache().getDBRefItems(0, lRefItems);

  lDLLAPI = lDBMgr.getDLLAPI();
  lDLLAPI.SQL_selectDatabase(lDBMgr.mGameplayDatabaseIdx);

  lQuery = "SELECT ID, ItemRef, ContainerLocation FROM ITEMS WHERE ContainerType='pawn' AND ContainerID=@ID;";
  lDLLAPI.SQL_prepareStatement(lQuery);
  lDLLAPI.SQL_bindNamedValueInt("@ID", aPawn.mStats.mPawnID);
  if(lDLLAPI.SQL_executeStatement()){
    while(lDLLAPI.SQL_nextResult()){
      lNewItem = None;
      `XCOM_InitString(lItemContainerLoc,30);

      lDLLAPI.SQL_getIntVal("ID", lItemID);
      lDLLAPI.SQL_getIntVal("ItemRef", lItemRefID);
      lDLLAPI.SQL_getStringVal("ContainerLocation", lItemContainerLoc);

      for(il=0; il<lRefItems.Length; il++){
        if(lRefItems[il].mDBId == lItemRefID){
          lNewItem = class'X_COM_Inventory'.static.CreateXCOMInventory(WorldInfo, lRefItems[il].mIdent, lItemID);
          break;
        }
      }
      lNewItems.AddItem(lNewItem);      
      lNewItemContainerLocs.AddItem(lItemContainerLoc);
    }

    for(il=0; il<lNewItems.Length; il++){
      if(lNewItems[il] != None){
        lNewItems[il].GiveTo(Instigator);
        //lNewInventory.setContainer(Instigator);
        if(lNewItemContainerLocs[il] != "loc_undefined"){
          lNewItems[il].equipItem();
        }
      }
    }
  }
}


DefaultProperties
{
	bMustHoldWeapon=true
	PendingFire(0)=0
	PendingFire(1)=0
}

*/