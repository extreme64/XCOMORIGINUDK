/**
 * X-COM planet HUD class
 */
class xcGEO_GFx_HUD_inBase_Aircrafts extends X_COM_GFx_Menu;

//=============================================================================
// Functions: Buttons
//=============================================================================
protected function BTN_Released(string aButtonName)
{
	super.BTN_Released(aButtonName);

	switch (aButtonName)
	{
		case "BTN_SetWeapon"    :	BTN_SetWeapon_Click();
										
		break;

		case "BTN_Exit"   :			BTN_Exit_Click();
										
		break;

		default:
		break;
	}
}

function BTN_Exit_Click()
{
	local xcGEO_PlayerController xcPC;

	xcPC = xcGEO_PlayerController(myPlayerController);

	xcPC.ExitFromAircraftsManagement();
	
}

function BTN_SetWeapon_Click()
{
	local xcGEO_PlayerController xcPC;

	//if (aWeaponName == "") return;

	xcPC = xcGEO_PlayerController(myPlayerController);

	xcPC.AircraftsManager.CreateWeapon("");
}

//=============================================================================
// Functions: ActionScript functions calls
//=============================================================================
function UpdateWeaponList(String WeaponName, int Quantity)
{
	ActionScriptVoid("UpdateWeaponList");
}

function ClearWeaponsList()
{
	ActionScriptVoid("ClearWeaponsList");
}

//=============================================================================
// Default Properties:
//=============================================================================
DefaultProperties
{
	MovieInfo = SwfMovie'X-COM_UI.GEO_Base_Aircrafts'
}