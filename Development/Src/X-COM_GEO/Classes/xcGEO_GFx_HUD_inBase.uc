/**
 * X-COM in Base mode HUD class
 */
class xcGEO_GFx_HUD_inBase extends X_COM_GFx_Menu;

//=============================================================================
// Functions: Buttons
//=============================================================================
protected function BTN_Released(string aButtonName)
{
	super.BTN_Released(aButtonName);

	switch (aButtonName)
	{
		case "BTN_ExitBase"       :	    xcGEO_PlayerController(myPlayerController).ExitFromBase();
		break;

		case "BTN_Build1x1"   :       xcGEO_PlayerController(myPlayerController).Place1tilemodule();
		break;

		case "BTN_Build1x2"	    :       xcGEO_PlayerController(myPlayerController).Place2tilemodule();
		break;

		case "BTN_Build2x2"	    :       xcGEO_PlayerController(myPlayerController).Place4tilemodule();
		break;

		case "BTN_AircraftsManagement"	    :       xcGEO_PlayerController(myPlayerController).Open_AircraftsManagement();
		break;

		default:
		break;
	}
}

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
	MovieInfo = SwfMovie'X-COM_UI.GEO_Base' 
}
