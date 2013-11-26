class xcT_GFx_HUD extends X_COM_GFx_Menu;

//=============================================================================
// Functions: Buttons
//=============================================================================
protected function BTN_Released(string aButtonName)
{
	super.BTN_Released(aButtonName);

	`log(" "$self$" BTN_Released():: myPlayerController="$myPlayerController);
	`log(" "$self$" BTN_Released():: myPlayerController.GetTeamNum()="$myPlayerController.GetTeamNum());

	switch (aButtonName)
	{
		case "kn_shapShotR"       :	   xcT_PlayerController(myPlayerController).SpawnAimBox(EFM_Snap);
		break;

		case "kn_burstShotR"	    :   xcT_PlayerController(myPlayerController).SpawnAimBox(EFM_Burst);
		break;

		case "kn_sniperShotR"	    :   xcT_PlayerController(myPlayerController).SpawnAimBox(EFM_Sniper);
		break;


		case "kn_throwR"	    :   xcT_PlayerController(myPlayerController).EndPlayerTurn(); //xcT_PlayerController(myPlayerController).ThrowWeapon();
		break;


		case "BTN_Crouch"   :       xcT_PlayerController(myPlayerController).SitDown();
		break;


		case "BTN_Lvl_up"	    :   xcT_PlayerController(myPlayerController).BoxLevelUp();
		break;

		case "BTN_Lvl_down"	    :       xcT_PlayerController(myPlayerController).BoxLevelDown();
		break;


		case "BTN_ENDTURN"	    :       xcT_PlayerController(myPlayerController).EndPlayerTurn();
		break;

		default:
		break;
	}
}

//=============================================================================
// Functions: ActionScript functions calls
//=============================================================================

//=============================================================================
// Default Properties:
//=============================================================================
DefaultProperties
{
	//MovieInfo = SwfMovie'X-COM_UI.TacticsHUD'
	MovieInfo = SwfMovie'X-COM_UI.TacticsHUD'
}
