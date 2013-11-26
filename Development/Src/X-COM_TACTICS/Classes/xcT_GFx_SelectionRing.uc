class xcT_GFx_SelectionRing extends X_COM_GFx_Menu;

//=============================================================================
// Functions: ActionScript functions calls
//=============================================================================
function InitSelectionMenu(int aUnitQuantity)
{
     ActionScriptVoid("InitSelectionMenu");
		myPlayerController.SetBlockMouseInput(true);
}

//=============================================================================
// Functions: UnrealScript functions calls from ActionScript
//=============================================================================


//=============================================================================
// Functions: Init and Close. Used to ignore mouse input
//=============================================================================
public function InitUI(X_COM_HUD amyHUD)
{
	super.InitUI(amyHUD);
	myPlayerController.SetBlockMouseInput(true);
}

event OnClose()
{
	SelectUnit(GetVariableNumber("_root.SelectedUnitIndex"));
	myPlayerController.SetBlockMouseInput(false);
	super.OnClose();
}

function SelectUnit(int aUnitIndex)
{
	myPlayerController.SelectedUnitsClear();
	myPlayerController.SelectPlayerUnit(myPlayerController.GetAllUnits()[aUnitIndex]);
}

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
	MovieInfo = SwfMovie'X-COM_UI.Tactics_SelectionRing'
	bPauseGameWhileActive = true
}
