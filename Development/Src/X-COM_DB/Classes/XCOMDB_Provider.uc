/**
 * This is the BASE class for all "Provider" classes for xDB
 * The Provider classes interact with the appropriate DB tables
 * and return a "Info" classes, which are derived from @see XCOMDB_Object.
 * 
 * Right now we will implement all in this Provider class. 
 * In future we will separate in on different Provider classes like
 * "Provider_Items", "Provider_Soldiers"... But... Maybe we won't...
 */
class XCOMDB_Provider extends Actor
  dependson(XCOMDB_Manager);

//=============================================================================
// Variables
//=============================================================================
var private XCOMDB_DLLAPI mDLLAPI; // backreference to XCOMDB_Manager


//=============================================================================
// Functions
//=============================================================================
/**
 * Initialise the databasedriver and creat/load the default databases
 */
function PostBeginPlay()
{
  super.PostBeginPlay();

  mDLLAPI = XCOMDB_Manager(Owner).getDLLAPI();
}

//=============================================================================
//   L O C A L I Z A T I O N   Functions
//=============================================================================
/** @brief gets localized phrase by key
 * 
 * 
 * @param [in] key - key of the phrase to return
 * @return localized phrase that corresponds to this key
 * 
 */
function string GetPhrase(string aKey)
{
	local string lQuery;
	local string lResult;
	local int lTextLength; //The length of result string
	
	
	//select db
	mDLLAPI.SQL_selectDatabase(XCOMDB_Manager(Owner).mLocalizationDatabaseIdx);
	
	//prepare query, we will read length of Phrase along with Phrase
	lQuery = "SELECT Phrase, length(Phrase) AS Lenght FROM Phrases WHERE Key=@key;";
	mDLLAPI.SQL_prepareStatement(lQuery);
	mDLLAPI.SQL_bindNamedValueString("@key", aKey);

	//query query =)
	if(mDLLAPI.SQL_queryDatabase(lQuery))
	{
		//suppose we have one answer...
		if (mDLLAPI.SQL_nextResult())
		{	
			//first we have to extract the length of string
			mDLLAPI.SQL_getIntVal("Lenght", lTextLength);
			`XCOMDB_InitString(lResult,lTextLength);
			mDLLAPI.SQL_getStringVal("Phrase", lResult);
		}
		else
		{
			//ups... looks like we haven't found this key
			`log("(!)Warning in localization. Phrase not found for key: "$aKey);
		}
	}
	return lResult;
}

//=============================================================================
//   I T E M S   Functions
//=============================================================================
/** 
 *  @brief gets item by its database unique Id
 *  
 *  @param [in] aId - database unique Id
 *  @return XCOMDB_Info_Item if item is found, null othervise
 */
function array<XCOMDB_Info_Item> GetAllItems(int aId)
{
	local string lQuery;
	local XCOMDB_Info_Item lItem;
	local array<XCOMDB_Info_Item> lItems;
	
	lItems.Length = 0;

	//select db
	mDLLAPI.SQL_selectDatabase(XCOMDB_Manager(Owner).mContentDatabaseIdx); 

	//query database
	lQuery = "SELECT Id, Name, Price, Weight, LoadMax, Height, Width, SmallPicName, MediumPicName, FullPicName, Mesh FROM XCom_Items;";
	if(mDLLAPI.SQL_queryDatabase(lQuery))
	{
		//read row by row
		while(mDLLAPI.SQL_nextResult())
		{
			lItem = Spawn(class'XCOMDB_Info_Item');
			mDLLAPI.SQL_getIntVal("Id", lItem.mId);
			
			`XCOMDB_InitString(lItem.mName,120);
			mDLLAPI.SQL_getStringVal("Name", lItem.mName);
			mDLLAPI.SQL_getIntVal("Price", lItem.mPrice);
			mDLLAPI.SQL_getIntVal("Weight", lItem.mWeight);
			mDLLAPI.SQL_getIntVal("LoadMax", lItem.mMaxLoad);
			mDLLAPI.SQL_getIntVal("Height", lItem.mHeight);
			mDLLAPI.SQL_getIntVal("Width", lItem.mWidth);

			`XCOMDB_InitString(lItem.mSmallPicName,255);
			mDLLAPI.SQL_getStringVal("SmallPicName", lItem.mSmallPicName);

			`XCOMDB_InitString(lItem.mMediumPicName,255);
			mDLLAPI.SQL_getStringVal("MediumPicName", lItem.mMediumPicName);

			`XCOMDB_InitString(lItem.mFullPicName,255);
			mDLLAPI.SQL_getStringVal("FullPicName", lItem.mFullPicName);

			`XCOMDB_InitString(lItem.mMesh,255);
			mDLLAPI.SQL_getStringVal("Mesh", lItem.mMesh);
			

			//Now we prepare some specific flags;
			lItem.SetProvider(self);
			lItem.mIsChanged = FALSE;
			lItem.mIsLoaded = TRUE;

			lItems.AddItem(lItem);
		}
	}
	else //some error in db?
	{
		`log("(!!!) Unagle to load items from the DB = "$aId);
	}

	return lItems;

}

/** 
 *  @brief gets item by its database unique Id
 *  
 *  @param [in] aId - database unique Id
 *  @return XCOMDB_Info_Item if item is found, null othervise
 */
function XCOMDB_Info_Item GetItemById(int aId)
{
	local XCOMDB_Info_Item lItem;
	local string lQuery;

	//select db
	mDLLAPI.SQL_selectDatabase(XCOMDB_Manager(Owner).mContentDatabaseIdx); 
	lItem = None;

	//query database
	lQuery = "SELECT Id, Name, Price, Weight, LoadMax, Height, Width, SmallPicName, MediumPicName, FullPicName, Mesh FROM XCom_Items WHERE Id = @Id ;";
	mDLLAPI.SQL_prepareStatement(lQuery);
	mDLLAPI.SQL_bindNamedValueInt("@Id", aId);

	if(mDLLAPI.SQL_executeStatement() && mDLLAPI.SQL_nextResult())
	{
		lItem = Spawn(class'XCOMDB_Info_Item');
		mDLLAPI.SQL_getIntVal("Id", lItem.mId);
		
		`XCOMDB_InitString(lItem.mName,120);
		mDLLAPI.SQL_getStringVal("Name", lItem.mName);
		mDLLAPI.SQL_getIntVal("Price", lItem.mPrice);
		mDLLAPI.SQL_getIntVal("Weight", lItem.mWeight);
		mDLLAPI.SQL_getIntVal("LoadMax", lItem.mMaxLoad);
		mDLLAPI.SQL_getIntVal("Height", lItem.mHeight);
		mDLLAPI.SQL_getIntVal("Width", lItem.mWidth);

		`XCOMDB_InitString(lItem.mSmallPicName,255);
		mDLLAPI.SQL_getStringVal("SmallPicName", lItem.mSmallPicName);

		`XCOMDB_InitString(lItem.mMediumPicName,255);
		mDLLAPI.SQL_getStringVal("MediumPicName", lItem.mMediumPicName);

		`XCOMDB_InitString(lItem.mFullPicName,255);
		mDLLAPI.SQL_getStringVal("FullPicName", lItem.mFullPicName);

		`XCOMDB_InitString(lItem.mMesh,255);
		mDLLAPI.SQL_getStringVal("Mesh", lItem.mMesh);
		
		//Now we prepare some specific flags;
		lItem.SetProvider(self);
		lItem.mIsChanged = FALSE;
		lItem.mIsLoaded = TRUE;
	}
	else //some error in db?
	{
		`log("(!!!) Item was not found in database. Item Id = "$aId);
	}
	
	return lItem;
}

/** 
 *  @brief gets item by its database unique Id
 *  
 *  @param [in] aId - database unique Id
 *  @return XCOMDB_Info_Item if item is found, null othervise
 */
function XCOMDB_Info_Item GetItemByName(string aName)
{
	local XCOMDB_Info_Item lItem;
	local string lQuery;

	//select db
	mDLLAPI.SQL_selectDatabase(XCOMDB_Manager(Owner).mContentDatabaseIdx); 
	lItem = None;

	//query database
	lQuery = "SELECT Id, Name, Price, Weight, LoadMax, Height, Width, SmallPicName, MediumPicName, FullPicName, Mesh FROM XCom_Items WHERE Name = @Name;";
	mDLLAPI.SQL_prepareStatement(lQuery);
	mDLLAPI.SQL_bindNamedValueString("@Name", aName);

	if(mDLLAPI.SQL_executeStatement() && mDLLAPI.SQL_nextResult())
	{
		lItem = Spawn(class'XCOMDB_Info_Item');
		mDLLAPI.SQL_getIntVal("Id", lItem.mId);
		
		`XCOMDB_InitString(lItem.mName,120);
		mDLLAPI.SQL_getStringVal("Name", lItem.mName);
		mDLLAPI.SQL_getIntVal("Price", lItem.mPrice);
		mDLLAPI.SQL_getIntVal("Weight", lItem.mWeight);
		mDLLAPI.SQL_getIntVal("LoadMax", lItem.mMaxLoad);
		mDLLAPI.SQL_getIntVal("Height", lItem.mHeight);
		mDLLAPI.SQL_getIntVal("Width", lItem.mWidth);

		`XCOMDB_InitString(lItem.mSmallPicName,255);
		mDLLAPI.SQL_getStringVal("SmallPicName", lItem.mSmallPicName);

		`XCOMDB_InitString(lItem.mMediumPicName,255);
		mDLLAPI.SQL_getStringVal("MediumPicName", lItem.mMediumPicName);

		`XCOMDB_InitString(lItem.mFullPicName,255);
		mDLLAPI.SQL_getStringVal("FullPicName", lItem.mFullPicName);

		`XCOMDB_InitString(lItem.mMesh,255);
		mDLLAPI.SQL_getStringVal("Mesh", lItem.mMesh);
		
		//Now we prepare some specific flags;
		lItem.SetProvider(self);
		lItem.mIsChanged = FALSE;
		lItem.mIsLoaded = TRUE;
	}
	else //some error in db?
	{
		`log("(!!!) Item was not found in database. Item Name  = "$aName);
	}
	
	return lItem;
}

//=============================================================================
//   I N V E N T O R Y   Functions
//=============================================================================

/** 
 *  @brief Add item to the inventory by its id
 *  @return inserted item id if inserted or INDEX_NONE (-1) if failed
 */
function XCOMDB_Info_Inventory CreateInventory()
{	
	local string lQuery;
	local XCOMDB_Info_Inventory lInventory;


	//select db
	mDLLAPI.SQL_selectDatabase(XCOMDB_Manager(Owner).mGameplayDatabaseIdx); 

	//query database
	lQuery = "INSERT INTO Inventories ";
	
	//do query
	if(mDLLAPI.SQL_queryDatabase(lQuery))
	{
		lInventory = Spawn(class'XCOMDB_Info_Inventory');

		//fill id
		lInventory.mId = mDLLAPI.SQL_lastInsertID();
		
		//Now we prepare some specific flags;
		lInventory.SetProvider(self);
		lInventory.mIsLoaded = true;
		lInventory.mIsChanged = false;

		return lInventory;
	}
	else
	{//error...
		return None;
	}  
}


/** 
 *  @brief gets item by its database unique Id
 *  
 *  @param [in] aId - database unique Id
 *  @return XCOMDB_Info_Item if item is found, null othervise
 */
function XCOMDB_Info_Inventory GetInventoryById(int aId)
{
	local XCOMDB_Info_Inventory lInventory;
	local string lQuery;

	//select db
	mDLLAPI.SQL_selectDatabase(XCOMDB_Manager(Owner).mGameplayDatabaseIdx); 
	lInventory = None;

	//query database
	lQuery = "SELECT Id FROM Inventories WHERE Id = @Id ;";
	mDLLAPI.SQL_prepareStatement(lQuery);
	mDLLAPI.SQL_bindNamedValueInt("@Id", aId);

	if(mDLLAPI.SQL_executeStatement() && mDLLAPI.SQL_nextResult())
	{
		lInventory = Spawn(class'XCOMDB_Info_Inventory');
		lInventory.mId=aId;
		//Now we prepare some specific flags;
		lInventory.SetProvider(self);
		lInventory.mIsChanged = FALSE;
		lInventory.mIsLoaded = TRUE;
	}

	return lInventory;
}

/** 
 *  @brief gets InventoryItems info by inventory id
 *  
 *  @param [in] aId - database unique Id
 *  @return XCOMDB_Info_Item if item is found, null othervise
 */
function array<XCOMDB_Info_InventoryItem> GetInventoryItems(int aInventoryId)
{
	local XCOMDB_Info_InventoryItem lItem;
	local array<XCOMDB_Info_InventoryItem> lItems;
	local string lQuery;

	//select db
	mDLLAPI.SQL_selectDatabase(XCOMDB_Manager(Owner).mGameplayDatabaseIdx); 

	//query database
	lQuery = "SELECT Id, ItemId, Quantity, GridX, GridY, Load FROM InventoryItems WHERE InventoryId = @Id ;";
	mDLLAPI.SQL_prepareStatement(lQuery);
	mDLLAPI.SQL_bindNamedValueInt("@Id", aInventoryId);

	if(mDLLAPI.SQL_executeStatement())
	{
		//read row by row
		while(mDLLAPI.SQL_nextResult())
		{
			lItem = Spawn(class'XCOMDB_Info_InventoryItem');

			mDLLAPI.SQL_getIntVal("Id", lItem.mId);
			lItem.mInventoryId = aInventoryId;			
			mDLLAPI.SQL_getIntVal("ItemId", lItem.mItemId);
			mDLLAPI.SQL_getIntVal("Quantity", lItem.mQuantity);
			mDLLAPI.SQL_getIntVal("GridX", lItem.mGridX);
			mDLLAPI.SQL_getIntVal("GridY", lItem.mGridY);
			mDLLAPI.SQL_getIntVal("Load", lItem.mLoad);
			
			//Now we prepare some specific flags;
			lItem.SetProvider(self);
			lItem.mIsChanged = FALSE;
			lItem.mIsLoaded = TRUE;

			lItems.AddItem(lItem);
		}
	}
	else //some error in db?
	{
		`log("(!!!) Unagle to load items from the DB = "$aInventoryId);
	}

	return lItems;
}

/** 
 *  @brief Add item to the inventory by its id
 *  @return inserted item id if inserted or INDEX_NONE (-1) if failed
 */
function XCOMDB_Info_InventoryItem CreateInventoryItem(int aInventoryId, int aItemId, int aQuantity, int aLoad, int aX, int aY)
{
	local XCOMDB_Info_InventoryItem lItem;
	
	lItem = Spawn(class'XCOMDB_Info_InventoryItem');
	lItem.mInventoryId = aInventoryId;
	lItem.mItemId = aItemId;
	lItem.mQuantity = aQuantity;
	lItem.mLoad = aLoad;
	lItem.mGridX = aX;
	lItem.mGridY = aY;
	
	//do query
	if(AddItemToInventory(lItem))
	{
		return lItem;
	}
	else
	{//error...
		return None;
	}  
}


/** 
 *  @brief Add item to the inventory by its id
 *  @return inserted item id if inserted or INDEX_NONE (-1) if failed
 */
function XCOMDB_Info_InventoryItem CreateInventoryItemByName(int aInventoryId, string aItemTypeName, int aQuantity, int aLoad, int aX, int aY)
{
//	local XCOMDB_Info_InventoryItem lInventoryItem;
	local XCOMDB_Info_Item lItem;

	lItem = GetItemByName(aItemTypeName);
	if(lItem == None) return None;

	return CreateInventoryItem(aInventoryId, lItem.mId, aQuantity, aLoad, aX, aY);
}


/** 
 *  @brief Add item to the inventory by its id
 *  @return inserted item id if inserted or INDEX_NONE (-1) if failed
 */
function bool AddItemToInventory(XCOMDB_Info_InventoryItem aItem)
{	
	local string lQuery;


	//select db
	mDLLAPI.SQL_selectDatabase(XCOMDB_Manager(Owner).mGameplayDatabaseIdx); 

	//query database
	lQuery = "INSERT INTO InventoryItems (InventoryId, ItemId, Quantity, GridX, GridY, Load)"$
	        " VALUES (@InventoryId, @ItemId, @Quantity, @GridX, @GridY, @Load);";
	
	mDLLAPI.SQL_prepareStatement(lQuery);
	mDLLAPI.SQL_bindNamedValueInt("@InventoryId", aItem.mInventoryId);
	mDLLAPI.SQL_bindNamedValueInt("@ItemId", aItem.mItemId);
	mDLLAPI.SQL_bindNamedValueInt("@Quantity", aItem.mQuantity);
	mDLLAPI.SQL_bindNamedValueInt("@GridX", aItem.mGridX);
	mDLLAPI.SQL_bindNamedValueInt("@GridY", aItem.mGridY);
	mDLLAPI.SQL_bindNamedValueInt("@Load", aItem.mLoad);
	
	
	//do query
	if(mDLLAPI.SQL_executeStatement())
	{
		//fill id
		aItem.mId = mDLLAPI.SQL_lastInsertID();
		
		//Now we prepare some specific flags;
		aItem.SetProvider(self);
		aItem.mIsLoaded = true;
		aItem.mIsChanged = false;

		return True;
	}
	else
	{//error...
		return False;
	}  
}


/** 
 *  @brief Remove item from the inventory by its id
 */
function RemoveItemFromInventory(int aInventoryId, int aInventoryItemId)
{
	local string lQuery;

	//select db
	mDLLAPI.SQL_selectDatabase(XCOMDB_Manager(Owner).mGameplayDatabaseIdx); 

	//query database
	lQuery = "DELETE FROM InventoryItems WHERE Id=@Id AND InventoryId=@InventoryId";
	mDLLAPI.SQL_prepareStatement(lQuery);
	mDLLAPI.SQL_bindNamedValueInt("@Id", aInventoryItemId);
	mDLLAPI.SQL_bindNamedValueInt("@InventoryId", aInventoryId);

	if(!mDLLAPI.SQL_queryDatabase(lQuery))
	{
		`log("(!!!)XCOMDB_Provider::RemoveItemFromInventory unable to remove item with id: "$aInventoryItemId$" from inventory  "$aInventoryId); 
	}
}

/** 
 *  @brief Updates item in the inventory
 */
function bool UpdateInventoryItem(XCOMDB_Info_InventoryItem aItem)
{
	local string lQuery;

	//select db
	mDLLAPI.SQL_selectDatabase(XCOMDB_Manager(Owner).mGameplayDatabaseIdx);

	lQuery = "UPDATE InventoryItems SET Quantity=@Quantity, GridX=@GridX, GridY=@GridY, Load=@Load WHERE Id = @Id";
	mDLLAPI.SQL_prepareStatement(lQuery);
	mDLLAPI.SQL_bindNamedValueInt("@Id", aItem.mId);
	mDLLAPI.SQL_bindNamedValueInt("@Quantity", aItem.mQuantity);
	mDLLAPI.SQL_bindNamedValueInt("@GridX", aItem.mGridX);
	mDLLAPI.SQL_bindNamedValueInt("@GridY", aItem.mGridY);
	mDLLAPI.SQL_bindNamedValueInt("@Load", aItem.mLoad);
	
	if(!mDLLAPI.SQL_executeStatement())
	{
		`log("(!!!)XCOMDB_Provider::UpdateInventoryItem unable to update item with id: "$aItem.mId); 
		return false;
	}

	//Now we prepare some specific flags;
	aItem.mIsChanged = FALSE;
	aItem.mIsLoaded = TRUE;
	return true;
}

/** 
 *  @brief Updates item in the inventory
 */
function bool MoveInventoryItem(int aNewInventoryId, XCOMDB_Info_InventoryItem aItem)
{
	local string lQuery;
	//select db
	mDLLAPI.SQL_selectDatabase(XCOMDB_Manager(Owner).mGameplayDatabaseIdx);

	lQuery = "SELECT Id FROM InventoryItems WHERE Id = @Id ;";
	mDLLAPI.SQL_prepareStatement(lQuery);
	mDLLAPI.SQL_bindNamedValueInt("@Id", aItem.mId);

	//Such item was found?
	if(mDLLAPI.SQL_executeStatement() && mDLLAPI.SQL_nextResult())
	{
		lQuery = "UPDATE InventoryItems SET InventoryId=@InventoryId WHERE Id = @Id";
		mDLLAPI.SQL_prepareStatement(lQuery);
		mDLLAPI.SQL_bindNamedValueInt("@Id", aItem.GetId());
		mDLLAPI.SQL_bindNamedValueInt("@InventoryId", aNewInventoryId);
	
		if(!mDLLAPI.SQL_executeStatement())
		{
			`log("(!!!)XCOMDB_Provider::MoveInventoryItem unable to update item with id: "$aItem.mId); 
			return false;
		}
		return true;
	}
	else //no such item in inventory
	{
		return AddItemToInventory(aItem);
	}
	
}

//private X_COM_GameInfo mGameInfo;
//lGameInfo = X_COM_GameInfo(WorldInfo.Game);

//=============================================================================
// Default Properties: 
//=============================================================================
DefaultProperties
{
	TickGroup=TG_DuringAsyncWork
	bHidden=TRUE
	Physics=PHYS_None
	bReplicateMovement=FALSE
	bStatic=FALSE
	bNoDelete=FALSE

	Name="Default__XCOMDB_Provider"
}
/*
	struct KeyValue
{
   var string key;
   var string value;
}

var array<KeyValue> stringMap;

...

idx = stringMap.find('key', "myKey");
value = idx!=INDEX_NONE?stringMap[idx].value:"";*/