class xcT_GFx_Screen_EndMission extends X_COM_GFx_Menu;

//=============================================================================
// Functions: Buttons
//=============================================================================
protected function BTN_Released(string aButtonName)
{
	super.BTN_Released(aButtonName);

	switch (aButtonName)
	{
		case "BTN_OK"       :	  	myGameInfo.getSaveLoadMgr().RunGame(); 
									Close();
		break;

		default:
		break;
	}
}

//=============================================================================
// Functions: window type
//=============================================================================
public function ShowWindowType(bool bShow_Mission_Win)
{
	if (bShow_Mission_Win) ActionScriptVoid("OpenWindow_Win");
	else ActionScriptVoid("OpenWindow_Lose");
}

//=============================================================================
// Functions: mission statistics
//=============================================================================
public function Set_Humans_Killed(int aHumans_Killed)
{
	ActionScriptVoid("Set_Humans_Killed");
}

public function Set_Humans_Score(int aHumans_Score)
{
	ActionScriptVoid("Set_Humans_Score");
}

public function Set_Aliens_Killed(int aAliens_Killed)
{
	ActionScriptVoid("Set_Aliens_Killed");
}

public function Set_Aliens_Score(int aAliens_Score)
{
	ActionScriptVoid("Set_Aliens_Score");
}

public function Set_Rating(String aRating)
{
	ActionScriptVoid("Set_Rating");
}

public function Set_Score(int aScore)
{
	ActionScriptVoid("Set_Score");
}

public function Set_MissionTime(int aMissionTime)
{
	ActionScriptVoid("Set_MissionTime");
}

//=============================================================================
// Default Properties:
//=============================================================================
DefaultProperties
{
	// The path to the swf asset
	MovieInfo = SwfMovie'X-COM_UI.Tactics_Screen_EndMission'

	bPauseGameWhileActive = TRUE // do you want your game paused when this is open? //overriden in menu type selection

    bDisplayWithHudOff = TRUE // do you want the HUD displayed while this is open?
}