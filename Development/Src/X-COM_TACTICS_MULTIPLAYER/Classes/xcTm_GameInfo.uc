class xcTm_GameInfo extends xcT_GameInfo;

//=============================================================================
// Functions: init
//=============================================================================
event InitGame( string Options, out string ErrorMessage )
{	
	Super.InitGame(Options, ErrorMessage);
	Worldinfo.NetMode = NM_ListenServer;
}

event PreBeginPlay()
{
	super.PreBeginPlay();
	CreateTeam(ET_HUMAN_Player_2);
}

function GenerateMap()
{
	TLevelManager = Spawn(class'xcT_LevelManager', self); //Initalize LevelManager
	TLevelManager.GenerateMap(UfoCrash, LittleGrass, StartLocation, StartRotation, GetRandomLandingLocation(), Village, Day, Sunny, Buran, Interceptor);
	TLevelManager.GenerateCellMap();
	TLevelManager.AddAliens(EA_Sectoid, 1, ET_ALIEN);
}

event PlayerController Login(string Portal, string Options, const UniqueNetID UniqueID, out string ErrorMessage)
{
	local PlayerController NewPlayer;
	`log("-------------------------------------------------------");
	`log("Options: "$Options);
	`log("-------------------------------------------------------");
	NewPlayer=Super(X_COM_GameInfo).Login(Portal, Options, UniqueID, ErrorMessage);
	NewPlayer.GotoState('EnemyTurn');
	return NewPlayer;
}

//=============================================================================
// Functions: EndGame
//=============================================================================
public function bool Check_MissionEnd_For(ETeams aTeam)
{
	switch (aTeam)
	{
		case ET_HUMAN_Player_1:
			if ( (xcT_PlayerController(GetPlayerController(ET_HUMAN_Player_2)).GetAllUnits().Length <= 0) && ( Alien_AI.GetAllFriends().Length <= 0 ) )
			{
				EndTacticsMission(true);
				return true;
			}
		break;
		case ET_HUMAN_Player_2:
			if ( (xcT_PlayerController(GetPlayerController(ET_HUMAN_Player_1)).GetAllUnits().Length <= 0) && ( Alien_AI.GetAllFriends().Length <= 0 ) )
			{
				EndTacticsMission(true);
				return true;
			}
		break;
		case ET_ALIEN:
			if ( (xcT_PlayerController(GetPlayerController(ET_HUMAN_Player_1)).GetAllUnits().Length <= 0) && (xcT_PlayerController(GetPlayerController(ET_HUMAN_Player_2)).GetAllUnits().Length <= 0) )
			{
				EndTacticsMission(false);
				return true;
			}
		break;
	}
	return false;
}

//=============================================================================
// Default properties
//=============================================================================
defaultproperties
{
	Name="Default__xcTm_GameInfo"

	//bDelayedStart = TRUE
	//bWaitingToStartMatch = FALSE
}