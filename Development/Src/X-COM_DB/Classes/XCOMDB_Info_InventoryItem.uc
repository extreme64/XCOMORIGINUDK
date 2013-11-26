/**
 * X-Com database Info of item stored in inventory.
 */
class XCOMDB_Info_InventoryItem extends XCOMDB_Object;

//=============================================================================
// Private variables
//=============================================================================
/**
 * You can change this variable directly, but dont do it (unless you know...)
 */
var int mId; 
/**You can change this variable directly, but dont do it (unless you know...)*/
var int mInventoryId; 
/**You can change this variable directly, but dont do it (unless you know...)*/
var int mItemId;
/**You can change this variable directly, but dont do it (unless you know...)*/
var int mQuantity;
/**You can change this variable directly, but dont do it (unless you know...)*/
var int mGridX;
/**You can change this variable directly, but dont do it (unless you know...)*/
var int mGridY;
/**You can change this variable directly, but dont do it (unless you know...)*/
var int mLoad;

//=============================================================================
// Setters and Getters functions for fields
//=============================================================================

/* (we assume we not changing items from game, so no setters for database fields) */

/** 
 * database unique id
 */
function int GetId()
{
	return mId;	
}

/**
 * Uniq record Id of the Inventory to which this item is related
 */
function int GetInventoryId()
{
	return mInventoryId;	
}

/**
 * Set uniq record Id of the Inventory to which this item is related
 */
function SetInventoryId(int aInventoryId)
{
	mInventoryId = aInventoryId;
	mIsChanged = TRUE;
}

/**
 * Uniq record Id of the Inventory to which this item is related.
 * This function uses DB to load inventory. Have it in mind.
 */
function XCOMDB_Info_Inventory GetInventory()
{
	return mProvider.GetInventoryById(mInventoryId);	
}

/**
 * Uniq record Id of the Item which is related to this record
 */
function int GetItemId() 
{
	return mItemId;	
}

/**
 * Set uniq record Id of the Item. (!!!) dont use this function. 
 * Use xDB_Info_Inventory class to add items to the inventory
 */
function SetItemId(int aItemId) 
{
	
	mItemId = mItemId;
	mIsChanged = TRUE;
}

/**
 * Loads item (item type description) related to this InventoryItem from the database
 */
function XCOMDB_Info_Item GetItem() 
{
	return mProvider.GetItemById(mItemId);
}

/**
 * Quantity of items. 'Qantity' is like '10 engines on the base'
 */
function int GetQuantity() 
{
	return mQuantity;
}

/**
 * Sets quantity of items. 'Qantity' is like 10 engines on the base
 */
function SetQuantity(int aQuantity) 
{
	mQuantity = aQuantity;
	mIsChanged = TRUE;
}

/**
 * Item X coordinate in inventory grid.  
 * This field is not validated in any kind.
 */
function int GetGridX() 
{
	return mGridX;
}

/**
 * Set item X coordinate in inventory grid.
 * This field is not validated in any kind.
 * One can call @see MoveInInventory(x,y) to change X and Y
 */
function SetGridX(int aGridX) 
{
	mGridX = aGridX;
	mIsChanged = TRUE;
}

/**
 * Item Y coordinate in inventory grid.  
 * This field is not validated in any kind.
 */
function int GetGridY() 
{
	return mGridY;
}

/**
 * Set item Y coordinate in inventory grid.
 * This field is not validated in any kind.
 * One can call @ref MoveInInventory(x,y) to change X and Y
 */
function SetGridY(int aGridY) 
{
	mGridY = aGridY;
	mIsChanged = TRUE;
}

/** Set item X and Y coordinate in inventory grid.
 * 
 */
function MoveInInventory(int aX, int aY)
{
	SetGridX(aX);
	SetGridY(aY);
}

/**
 * Gets the load of item in inventory. 'Load' is like gun load of bullets. 
 * Maximum load @remarks LoadMax is @ref xDB_Info_Item property
 */
function int GetLoad() 
{
	return mLoad;
	
}

/**
 *  Sets the load of item in inventory. 'Load' is like gun load of bullets. 
 *  Maximum load @remarks LoadMax is @ref xDB_Info_Item property
 */
function SetLoad(int aLoad) 
{
	mLoad = aLoad;
	mIsChanged = TRUE;
}

//=============================================================================
// Db functions
//=============================================================================

//Moves inventory item from old inventory to new inventory
function bool MoveToInventory(XCOMDB_Info_InventoryItem aInventory)
{
	return self.mProvider.MoveInventoryItem(aInventory.GetId(), self);
}

//=============================================================================
// Override xDB_Objects
//=============================================================================

/** 
 *  Submits changes to the DB. 
 *  
 *  Calling of SetXXX, SetYYY of the "Info" classes does not automatically submit changes to the DB. 
 *  Call this function to save changes to the database;
 */
function bool SubmitChanges()
{
	return mProvider.UpdateInventoryItem(self);	
}

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
	Name="Default__XCOMDB_Info_InventoryItem"
}
