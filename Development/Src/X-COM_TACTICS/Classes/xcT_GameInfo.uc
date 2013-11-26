/**
 * X-COM Tactical game type.. 
 * Uses for Tactics-game rules.
 */
class xcT_GameInfo extends X_COM_GameInfo;

/**
 * 
Что сделать:

1. Интерфейс:
1.1. Выбор следующего юнита
1.2. Иконки пришельцев
1.3. Миникарта

2. Пофиксить эффекты выделения персов

3. Пофикстить скрывание пришельцев и появление экрана хода пришельцев, оно появляется скрывается не вовремя

**/

//=============================================================================
// Variables:
//=============================================================================
var vector                          CameraStartLocation, StartLocation; //controller and x-com soldiers start location
var rotator                         CameraStartRotation, StartRotation; //controller and x-com soldiers start rotation
var xcT_LevelManager                TLevelManager;
var xcT_AI_Computer                 Alien_AI;

var public xcT_Game_Statistics      Game_Statistics; // сюда записывается вся статистика тактического боя

//=============================================================================
// Variables: Turn-based: global indicator of alien turn
//=============================================================================
//var public bool    bIsAlienTurn;
var public ETeams  TeamInTurn;

//=============================================================================
// Functions: init
//=============================================================================
event InitGame( string Options, out string ErrorMessage )
{
	Super.InitGame(Options, ErrorMessage);	
}

event PreBeginPlay()
{
	super.PreBeginPlay();
	CreateTeam(ET_CIVILIAN);
}

event PostBeginPlay()
{
	super.PostBeginPlay();
	Alien_AI = Spawn(class'xcT_AI_Computer');
	GenerateMap();
}

function GenerateMap()
{
	TLevelManager = Spawn(class'xcT_LevelManager', self); //Initalize LevelManager
	TLevelManager.GenerateMap(UfoCrash, LittleGrass, StartLocation, StartRotation, GetRandomLandingLocation(), Village, Day, Sunny, Buran, Interceptor);
	TLevelManager.GenerateCellMap();
	//TLevelManager.GeneratePassabilityMap();
	TLevelManager.AddAliens(EA_Sectoid, 10, ET_ALIEN);
}

function int GetRandomLandingLocation()
{
	local int lXcomCell; //x-com place in map
	local int lRotationSelector;
	local int lBaseAndMapRelativeSize;
	local int lMapSize, lMapCellSize, lNumCols, lCellRows;

	//First we should divide map it to equal sections and randomly select location of x-com team
	//Number of map sections is set in X_COM_Settings class.
	lBaseAndMapRelativeSize = class'X_COM_Settings'.default.Base_BaseAndMapRelativeSize;
	lXcomCell = 1 + Rand((lBaseAndMapRelativeSize*lBaseAndMapRelativeSize)/4); // get new position of x-com team from relative map size
	//Setup and save team location for spawn ship and pawns

	lMapSize = (class'X_COM_Settings'.default.T_LevelSize.X + class'X_COM_Settings'.default.T_LevelSize.Y)/2;
	lMapCellSize = class'X_COM_Settings'.default.T_CellSize;
	lNumCols = lMapSize / lMapCellSize;
	lCellRows = (lXcomCell - 1) / lNumCols;

	StartLocation.X = (lXcomCell - lCellRows*lNumCols - 1)*lMapCellSize + lMapCellSize/2;
	StartLocation.Y = lCellRows*lMapCellSize + lMapCellSize/2;
	StartLocation.Z = 0;

	`log(" xcT_GameInfo StartLocation : "$StartLocation);

	lRotationSelector = Rand(4); // get new rotation angle of x-com team 
	StartRotation.YAW = lRotationSelector * 90.0f * DegToRad * RadToUnrRot; //Setup and save team rotation for spawn ship and pawns and controller

	return lXcomCell;
}

event PlayerController Login(string Portal, string Options, const UniqueNetID UniqueID, out string ErrorMessage)
{
	local PlayerController NewPlayer;

	CameraStartRotation=StartRotation;
	CameraStartRotation.Pitch = (295.0f * DegToRad) * RadToUnrRot; 
	
	NewPlayer = SpawnPlayerController(StartLocation, CameraStartRotation); //spawn without playerstart in map.

	if( NewPlayer == None ) // Handle Controller spawn failure.
	{
		`log("Couldn't spawn player controller of class "$PlayerControllerClass);
		ErrorMessage = PathName(WorldInfo.Game.GameMessageClass) $ ".FailedSpawnMessage";
		return None;
	}

	ChangeTeam(newPlayer, ET_HUMAN_Player_1, false);

	//NewPlayer.GotoState('TacticsControllerState');
	NewPlayer.GotoState('EnemyTurn'); // вход в экран когда ходит противник и невозможность совершать действия в ожидании хода другого игрока
	return NewPlayer;
}

function StartMatch()
{
	super.StartMatch();
	Game_Statistics = new(self)class'xcT_Game_Statistics';
	Game_Statistics.Set_MissionStartTime(Worldinfo.TimeSeconds);
	StartTurn_For(ET_HUMAN_Player_1);
}

function RestartPlayer(Controller NewPlayer)
{
	local X_COM_PlayerController lPC;
	super.RestartPlayer(NewPlayer);
	lPC = X_COM_PlayerController(NewPlayer);
	if (lPC != none) TLevelManager.AddUnitsFor(lPC);
}

//=============================================================================
// Functions: Notifications
//=============================================================================
public function NotifyUnitDied(X_COM_Unit aUnit)
{
	if (aUnit != none)
	{
		switch(aUnit.GetTeamNum())
		{
			case ET_HUMAN_Player_1 :
			case ET_HUMAN_Player_2 : 
				Game_Statistics.Increase_HumansKilled();
			break;
			case ET_ALIEN : 	
				Alien_AI.UnRegisterSquadUnit(aUnit);
				Game_Statistics.Increase_AliensKilled();
			break;
		}
	}
}

//=============================================================================
// Functions: Turn-based
//=============================================================================
//public function SetAlienTurn(bool bnewturn)
//{
//	bIsAlienTurn = bnewturn;
//	if (bnewturn) Alien_AI.StartNewTurn(bnewturn);
//	else xcT_PlayerController(GetPlayerController()).StartPlayerTurn();
//}

public function EndTurn_For(ETeams aOldTeam)
{
	local ETeams lNextTeam;
	local ETeams lFirstTeam;
	local bool bNewRound;
	local bool bSkipTeam;

	if (!Check_MissionEnd_For(aOldTeam))
	{
		lFirstTeam = 1;

		lNextTeam = ETeams(int(aOldTeam) + 1);

		bNewRound = lNextTeam >= Teams.Length;

		if (bNewRound) StartTurn_For(lFirstTeam);
		else
		{
			bSkipTeam = Teams[lNextTeam] == none;
			if (bSkipTeam) EndTurn_For(lNextTeam);
			else StartTurn_For(lNextTeam);
		}
	}
}

public function StartTurn_For(ETeams aNewTeam)
{
	TeamInTurn = aNewTeam;

	//Обновляем видимость для всех игроков

	switch (aNewTeam)
	{
		case ET_HUMAN_Player_1: // для игрока 1:
		case ET_HUMAN_Player_2: // и для 2го игрока, если мультиплеер:
			if (GetPlayerController(aNewTeam)!= none ) xcT_PlayerController(GetPlayerController(aNewTeam)).ServerStartTurn();
			else EndTurn_For(aNewTeam); // просто пропуск хода
		break;

		case ET_ALIEN: 
			Alien_AI.StartTurn();
		break;

		case ET_CIVILIAN:
		break;

		case ET_ANIMAL:
		break;
	}
}

public function ShowEnemyTurnScreen(bool bShow, optional ETeams aForTeam)
{
	local xcT_PlayerController lPC;

	if (aForTeam != ET_None) lPC = xcT_PlayerController(GetPlayerController(aForTeam));
	else lPC = xcT_PlayerController(GetPlayerController());

	if (lPC != none) lPC.ShowEnemyTurnScreen(bShow);
}

//=============================================================================
// Functions: EndGame
//=============================================================================
public function bool Check_MissionEnd_For(ETeams aTeam)
{
	if ( Alien_AI.GetAllFriends().Length <= 0 )
	{
		EndTacticsMission(true);
		return true;
	}
	else
	{
		`log(" xcT_PlayerController(GetPlayerController()).AllUnits.Length : "$xcT_PlayerController(GetPlayerController(aTeam)).GetAllUnits().Length);
		if ( xcT_PlayerController(GetPlayerController(aTeam)).GetAllUnits().Length <= 0 )
		{
			EndTacticsMission(false);
			return true;
		}
	}
	return false;
}

public function EndTacticsMission(bool bPlayerWin)
{
	local xcT_Hud lHUD;
	local int lScore, lTime;
	local string lRating;

	// закончить тактическую битву, показать эран миссии, и выйти в гео

	lHUD = xcT_Hud(GetPlayerController().myHUD);
	lHUD.ShowEndMissionScreen(bPlayerWin);

	lHUD.Screen_EndMission.Set_Aliens_Killed(Game_Statistics.Get_AliensKilled());
	lHUD.Screen_EndMission.Set_Aliens_Score(Game_Statistics.Get_AliensScore());
	lHUD.Screen_EndMission.Set_Humans_Killed(Game_Statistics.Get_HumansKilled());
	lHUD.Screen_EndMission.Set_Humans_Score(Game_Statistics.Get_HumansScore());

	Game_Statistics.Get_Result_Rating_and_Score(UfoCrash, lRating, lScore);

	lHUD.Screen_EndMission.Set_Score(lScore);
	lHUD.Screen_EndMission.Set_Rating(lRating);

	lTime = Worldinfo.TimeSeconds - Game_Statistics.Get_MissionStartTime();
	lHUD.Screen_EndMission.Set_MissionTime(lTime);

	if (bPlayerWin)
	{
		`log("-----!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --- HUMAN WIN --- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!-----");
	}
	else
	{
		`log("-----!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --- ALIENS WIN --- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!-----");
	}
	`log("Game_Statistics.Get_AliensKilled() = "$Game_Statistics.Get_AliensKilled());
	`log("Game_Statistics.Get_AliensScore() = "$Game_Statistics.Get_AliensScore());
	`log("Game_Statistics.Get_HumansKilled() = "$Game_Statistics.Get_HumansKilled());
	`log("Game_Statistics.Get_HumansScore() = "$Game_Statistics.Get_HumansScore());
	`log(" lScore = "$lScore);
	`log(" lRating = "$lRating);
	`log(" Mission time = "$lTime);
}

defaultproperties
{
    PlayerControllerClass=class'X-COM_Tactics.xcT_PlayerController'	
	HUDType=class'X-COM_Tactics.xcT_Hud'
	//HUDType = class'UTGFxHudWrapper'

    Name="Default__xcT_GameInfo"
}