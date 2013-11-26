class XCOMDB_ExamplesAndTests extends Actor;

//=============================================================================
// Functions
//=============================================================================
/**
 * Initialise the databasedriver and creat/load the default databases
 */
function PostBeginPlay()
{
  super.PostBeginPlay();

  //mDLLAPI = XCOMDB_Manager(Owner).getDLLAPI();
}

/**
 * Ok consider it to be the manual to all the XCOM SQLite database system FOR USERS.
 * By 'FOR USERS' I mean programmers, who work on the other parts of the game and
 * should not bother themselves by LEFT JOINS and querries. So instead of querries
 * users can use "Providers" and regular classes. 
 * 
 * Ok, here we came to the two main concepts of the XCOMDB, 
 * 1) Providers and
 * 2) Info classes
 * 
 * - Provider classes work with DB, all querries are executed inside the Provider classes. 
 * Provider classes read DB and return data to user in form of "Info" classes. 
 * 
 * - "Info" classes represents data stored in the database. They have fields that 
 * match realted fields in the database, but also "Info" classes have functions 
 * represents logical connection between data in the database. Like you have
 * soldier.GetInventory() instead of getting inventory "Info" class through InventoryId
 * 
 * Sometimes example worth more than words; The next function is full of examples, 
 * but let me put one example in this comments since this functionality is not 
 * implemented yet =p
 * 
 * @example
 * //lets say we have a provider
 * local XCOMDB_Provider lProvider;
 * 
 * //read the XCOMDB_Info_Soldier record from the db by id. 
 * lDbSoldier = lProvider.GetSoldierById(1);
 * 
 * // Soldier record in the database have field InventoryId, by which you could
 * //reference to Inventory table  and get a data on inventory. 
 * //But "Info" classes try to make it for you. 
 * lInventory = lDbSoldier.GetInventory();   // This function will return loaded 
 *                                           // XCOMDB_Info_Inventory class, 
 * 
 * @example end
 * 
 * What happend? Actually, to get inventory lDbSoldier class will refer to a provider 
 * that loaded 'him', and use Provider.GetInventoyById(...) function to load coresponding 
 * data on soldier inventory. But user dont have to know all this. 
 * Just use lDbSoldier.GetInventory() which is logical.
 * And "Info" classes will do everything for you. 
 */
function RunTests()
{
	/*local string lLang;  //test phrase from localization
	local XCOMDB_Provider lProvider;                //database provider
	local XCOMDB_Info_Inventory lInventory;         //test inventary
	local array<class<XCOMDB_Info_InventoryItem> > lInventoryItems;   //items from test inventory
	local XCOMDB_Info_InventoryItem lInventoryItem;
	local XCOMDB_Info_Item lItem;
	local X_COM_GameInfo lGameInfo;
	local string lStr; //just temporary string for experiments
	
	//Get game info and provider
	lGameInfo = X_COM_GameInfo(Owner);
	lProvider = lGameInfo.getDbProvider();

	//Test localization
	lLang = lProvider.GetPhrase("Language");
	`log("Current language is "$lLang);

	//Test inventory
	lInventory = lProvider.GetInventoryById(1);     //we assume that inventory with Id=1 is a test inventory
	lInventoryItems = lInventory.GetItems();        //Get inventory items
	`log("Inventory has items: "$lItems.Length);

	if(lInventoryItems.Length == 0) return; //we have nothing to do if we have no items in inventory

	//lets play with first item in the inventory;
	lInventoryItem = lInventoryItems[0];

	//return XCOMDB_Info_Item - which represents information about item type, and 
	lStr = lInventoryItem.GetItem().GetName();
	`log("First item in inventory is: "$lStr);
	`log("Item loaded as : "$lInventoryItem.GetLoad());
	`log("Item quantity is : "$lInventoryItem.GetQantity());
	
	// now lets change item quantity, item load and position in the inventory grid.
	lInventoryItem.SetQuantity(2);
	lInventoryItem.SetLoad(12);
	lInventoryItem.MoveInInventory(2,2);
	
	//but you can change only one coordinate
	lInventoryItem.SetGridX(1); // so now item is (1,2) in the grid

	// (!!!)  right now we have changed lInventoryItem but this changes are NOT saved to DB
		
	//Check if the object was changet from its original state. Just you to know how to do this... 
	if(lInventoryItem.IsChanged()) `log("Item has changes");

	//save changes to the database
	lInventoryItem.SubmitChanges();
*/
}

DefaultProperties
{
	TickGroup=TG_DuringAsyncWork
	bHidden=TRUE
	Physics=PHYS_None
	bReplicateMovement=FALSE
	bStatic=FALSE
	bNoDelete=FALSE

	Name="Default__XCOMDB_ExamplesAndTests"
}

