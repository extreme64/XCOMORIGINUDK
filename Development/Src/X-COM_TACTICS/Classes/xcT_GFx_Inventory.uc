class xcT_GFx_Inventory extends X_COM_GFx_Menu;

var X_COM_Unit mPerson;

/**
 * Treatment Options from the flash to UDK
 * 
 * Функции обращения из Флеш к UDK
 * 
 * */

function GetPerson(string aName)
{
	local X_COM_Unit lUnit;
	local int il;
	local array<X_COM_Unit> lAllUnits;

	lAllUnits = myPlayerController.GetAllUnits();
	
	foreach lAllUnits(lUnit, il)
	{
		if(lUnit.Name == name(aName))
		{
			mPerson = lUnit;
		}
	}
}

function AddItem(string Item)
{
	//local X_COM_Inventory lInventory;

	/*ForEach mPerson.InvManager.InventoryActors( class'x_Inventory', lInventory )
	{
		if(lPawn.Name == name(aName))
		{
			mPerson = lPawn;
		}
	}*/
	`log('Add Item to Inventory');
}

function RemoveItem(int aItem)
{
}

function DropItem(int aItem)
{
}

function AccessDenied(string aItem)
{
}
/*---------------------------------------------------*/

/**
 * Treatment оptions for Flash
 * 
 * Функции обращения к Флеш
 * 
 * */
function CallAddToStock(string aItem, int aQuantity){ActionScriptVoid("_root.Controller.AddToStock");}

function CallAddToInventory(string aPerson, string aItem, int aQuantity) {ActionScriptVoid("_root.Controller.AddToInventory");}

//function CallAddPerson(string Person, array Params) {ActionScriptVoid("_root.Controller.AddPerson");}

//function CallAddStat(string Person, array Params) {ActionScriptVoid("_root.Controller.AddStat");}

//function CallRemovePerson(string Person) {ActionScriptVoid("_root.Controller.RemovePerson");}

DefaultProperties
{
	MovieInfo = SwfMovie'X-COM_UI.Tactics_Inventory'
}
