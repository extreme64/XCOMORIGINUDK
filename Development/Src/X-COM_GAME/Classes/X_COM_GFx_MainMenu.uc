class X_COM_GFx_MainMenu extends X_COM_GFx_Menu
	dependson(X_COM_Defines);

//=============================================================================
// Functions: UnrealScript functions calls from ActionScript
//=============================================================================
private function StartNewGame()
{
	myGameInfo.getSaveLoadMgr().LoadNewGame(); 
	Close();
}

private function StartTacticsTestGame()
{
	myGameInfo.getSaveLoadMgr().RunTacticsTest();
	Close();
}

private function ExitGame()
{
	ConsoleCommand("quit");
	Close();
}

private function StartHotSeatGame()
{
	`log(self.class$" StartHotSeatGame()");
}

private function StartHostGame(string aPlayerName)
{
	local string lStartString;
	local int lTeam;

	lTeam = ET_HUMAN_Player_1;
	lStartString = class'X_COM_Settings'.default.MultiplayerMap;
	lStartString $= "?game=X-COM_TACTICS_MULTIPLAYER.xcTm_GameInfo";
	lStartString $= "?listen=true";
	lStartString $= "?Name="$aPlayerName;
	lStartString $= "?Team="$lTeam;

		`log(self.class$" StartHostGame() URL="$lStartString);

	ConsoleCommand("open "$lStartString);
}


private function StartJoinGame(string aIpAddress, string aPlayerName)
{
	local string lStartString;
	local int lTeam;

	lTeam = ET_HUMAN_Player_2;
	lStartString $= aIpAddress;
	lStartString $= "?Name="$aPlayerName;
	lStartString $= "?Team="$lTeam;

	`log(self.class$" StartJoinGame() URL="$lStartString);

	ConsoleCommand("open "$lStartString);
}

//=============================================================================
// Flash calls
//=============================================================================
public function OpenGameMenu()
{
	ActionScriptVoid("OpenGameMenu");
}

//=============================================================================
// Default Properties:
//=============================================================================
DefaultProperties
{
	// The path to the swf asset
	MovieInfo = SwfMovie'X-COM_UI.MainMenu'

    bDisplayWithHudOff = TRUE // do you want the HUD displayed while this is open?
}