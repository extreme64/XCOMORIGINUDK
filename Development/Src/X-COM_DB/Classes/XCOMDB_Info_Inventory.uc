/**
 * X-Com database inventory records info.
 */
class XCOMDB_Info_Inventory extends XCOMDB_Object;

//=============================================================================
// Private variables
//=============================================================================

/**
 * A collection of items in the inventory
 */
var private array<class<XCOMDB_Info_Item> > mItems;

/**
 * Id of database... 
 */
var int mId;

//=============================================================================
// functions
//=============================================================================


/**
 * Gets the items of this inventory.
 */
function array<XCOMDB_Info_InventoryItem> GetItems()
{
	return mProvider.GetInventoryItems(mId);
}

/**
 * Create xDB_Info_InventoryItem and add it to this inventory using item type id
 */
function XCOMDB_Info_InventoryItem AddItemByParams(int aItemId, int aQuantity, int aLoad, int aX, int aY)
{
	return mProvider.CreateInventoryItem(mId, aItemId, aQuantity, aLoad, aX, aY);
}

/**
 *  Create xDB_Info_InventoryItem and add it to this inventory using item type name
 */
function XCOMDB_Info_InventoryItem AddItemByName(string aName, int aQuantity, int aLoad, int aX, int aY)
{
	return mProvider.CreateInventoryItemByName(mId, aName, aQuantity, aLoad, aX, aY);
}

/**
 * Put item to this inventory. The function removes item from other inventory. 
 * If this InventoryItem does not exist in database it will be created.
 */
function bool PutItem(XCOMDB_Info_InventoryItem aItem)
{
	return mProvider.MoveInventoryItem(mId, aItem);
}

/**
 * Removes the item from this inventory
 */
function RemoveItem(XCOMDB_Info_InventoryItem aItem)
{
	mProvider.RemoveItemFromInventory(mId, aItem.GetId());
}

/**
 * Removes the item from this inventory
 */
function RemoveItemById(int aInventoryItemId)
{
	mProvider.RemoveItemFromInventory(mId, aInventoryItemId);

}

DefaultProperties
{
	Name="Default__XCOMDB_Info_Inventory"
}
