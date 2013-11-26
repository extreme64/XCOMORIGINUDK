/**
 * X-COM game. Main game class. 
 * Uses only for main menu in FrontEnd and as parent class for other x-com classes.
 */
class X_COM_GameInfo extends GameInfo
	dependson(X_COM_Defines)
	config(XCOM);

//=============================================================================
// Переменные которые могут быть установлены через меню. Настраиваемые параметры игры
//=============================================================================
var globalconfig bool                       bCameraShouldFollowForProjectile;
var	array<TeamInfo>                         Teams;

var globalconfig public const EGameDifficult GameDifficult;

//=============================================================================
// Variables
//=============================================================================
var private X_COM_PlayerController		    lastPlayerController; // Private reference to player controller. Can be "GET" from function

var private XCOMDB_Manager                  mDatabase;
var private XCOMDB_Provider                 mDbProvider;    //database stored objects provider
var private X_COM_FileMgr                   mFilemanager;
var private X_COM_SaveLoadMgr               mSaveLoadMgr; 
var private XCOMDB_ExamplesAndTests         mDbTests;

//var X_COM_GFx_MainMenu					    MainMenuMovie; // Reference to X_COM_GFx_MainMenu. Main Menu.

var public bool                             bDoDebug; //if true then log debug info from all classes

//=============================================================================
// Functions: Overrided or non-used from Engine|UT code
//=============================================================================
function SaveWorldProperties(); // Should be overrided in child classes for save game
public function NotifyUnitDied(X_COM_Unit aUnit); // Should be overrided in child classes

// Overrided from gameinfo because we do not need pawn possessed to our Playercontroller.
function RestartPlayer(Controller NewPlayer)
{
	local LocalPlayer LP; 
	local PlayerController PC;
	local int Idx;
	local array<SequenceObject> Events;
	local SeqEvent_PlayerSpawned SpawnedEvent;

	// To fix custom post processing chain when not running in editor or PIE.
	PC = PlayerController(NewPlayer);
	if (PC != none)
	{
		LP = LocalPlayer(PC.Player); 
		if(LP != None) 
		{ 
			LP.RemoveAllPostProcessingChains(); 
			LP.InsertPostProcessingChain(LP.Outer.GetWorldPostProcessChain(),INDEX_NONE,true); 
			if(PC.myHUD != None)
			{
				PC.myHUD.NotifyBindPostProcessEffects();
			}
		} 
	}

	// activate spawned events
	if (WorldInfo.GetGameSequence() != None)
	{
		WorldInfo.GetGameSequence().FindSeqObjectsByClass(class'SeqEvent_PlayerSpawned',TRUE, Events);
		for (Idx = 0; Idx < Events.Length; Idx++)
		{
			SpawnedEvent = SeqEvent_PlayerSpawned(Events[Idx]);
			if (SpawnedEvent != None &&
				SpawnedEvent.CheckActivate(NewPlayer,NewPlayer))
			{
				SpawnedEvent.SpawnPoint = NewPlayer.StartSpot;
				SpawnedEvent.PopulateLinkedVariableValues();
			}
		}
	}
}

/** Start the game - inform all actors that the match is starting, and spawn player pawns */
function StartMatch()
{
	local Actor A;
	local PlayerController P;

	if ( MyAutoTestManager != None )
	{
		MyAutoTestManager.StartMatch();
	}

	// tell all actors the game is starting
	ForEach AllActors(class'Actor', A)
	{
		A.MatchStarting();
	}

	foreach WorldInfo.AllControllers(class'PlayerController', P)
	{
		if ( (!bGameEnded)  && (P.CanRestartPlayer()) )
		{
			RestartPlayer(P);
		}
	}

	bWaitingToStartMatch = false;

	StartOnlineGame();

	// fire off any level startup events
	WorldInfo.NotifyMatchStarted();
}

//=============================================================================
// Functions: Get references
//=============================================================================
/**
 * Get the created database manager object.
 * 
 * @return Allocated XCOMDB_Manager object
 */
final function XCOMDB_Manager getDBMgr()
{
	return mDatabase;
}

/**
 * Get database provider of stored objects
 * 
 * @return Allocated XCOMDB_Manager object
 */
final function XCOMDB_Provider getDbProvider()
{
	return mDbProvider;
}


/**
 * Get the created file manager object.
 * 
 * @return Allocated X_COM_FileMgr object
 */
final function X_COM_FileMgr getFileMgr()
{
	return mFilemanager;
}

/**
 * Get the created savegame manager object.
 * 
 * @return Allocated X_COM_SaveLoadMgr object
 */
final function X_COM_SaveLoadMgr getSaveLoadMgr()
{
	return mSaveLoadMgr;
}

/** For NET game you must specify team number of controller, otherwise it wil be NONE */
function X_COM_PlayerController GetPlayerController(optional int aTeam)
{   
	local X_COM_PlayerController lC;

	if ( worldinfo.NetMode != NM_Standalone ) 
	{
		foreach Worldinfo.AllControllers(class'X_COM_PlayerController', lC)
		{
			if (lC != none)
			{
				if (lC.GetTeamNum() == aTeam) return lC;
			}
		}
		return none;
	}
    else return lastPlayerController;
}

//=============================================================================
// Events: 
//=============================================================================
/** First called event at game startup. */ 
event InitGame( string Options, out string ErrorMessage )
{	
	local string lLang;
	
// DLL Binding test related
////////////////////////////////////////////////

	//local int count;
	//local Array<CellStructure> lArr;
	//local Array<Vector> lChangedArray;
	//local int lArr2[2000];
	//local Vector lVect;
	//local Vector lVect2;
	
	//local int li;
	//local int result;
	//local X_COM_DllTest lTest;
	//local float lClockTime;
	//local CellStructure lCell;
//////////////////////////////////////////////
	local X_COM_SusaninPF_Interface lPathFinderInterface;
	local X_COM_SusaninPF_Grid lGrid;
	local Rotator lRot;

	
	//local IntDynamicArrayStruct lStruct;

	Super.InitGame(Options, ErrorMessage);

	Worldinfo.NetMode = NM_Standalone;

	mDatabase = Spawn(class'XCOMDB_Manager', self);               `log("X_COM_GameInfo::InitGame:mDatabase = "$mDatabase);
	mFilemanager = Spawn(class'X_COM_FileMgr', mDatabase);        `log("X_COM_GameInfo::InitGame:mFilemanager = "$mFilemanager);
	mSaveLoadMgr = Spawn(class'X_COM_SaveLoadMgr', mDatabase);    `log("X_COM_GameInfo::InitGame:mSaveLoadMgr = "$mSaveLoadMgr);
	mDbProvider = Spawn(class'XCOMDB_Provider', mDatabase);       `log("X_COM_GameInfo::InitGame:XCOMDB_Provider = "$mDbProvider);
	mDbTests = Spawn(class'XCOMDB_ExamplesAndTests', self);       `log("X_COM_GameInfo::InitGame:XCOMDB_ExamplesAndTests = "$mDbTests);

	performServerTravelDone(Options); // call to load DB files into memory

	lLang = mDbProvider.GetPhrase("Language");
	`log("Current language is "$lLang);

	//TODO move this under if with the config flag "Run database tests" 
	mDbTests.RunTests();

	lPathFinderInterface = new class'X_COM_SusaninPF_Interface';

	lGrid = lPathFinderInterface.CreateGrid(3, 3, 1, class'X_COM_Settings'.default.T_GridSize);

	lRot.Pitch = 90 * DegToUnrRot;
	/////////////////////////////////////////////////
	// Активный Тест
	/////////////////////////////////////////////////

	//lGrid.mCells.SetCellType(0, 0, 0, Passable);
	//lGrid.mCells.SetCellType(1, 0, 0, Passable);
	//lGrid.mCells.SetCellType(2, 0, 0, Passable);
	//lGrid.mCells.SetCellType(0, 1, 0, Impassable);
	//lGrid.mCells.SetCell(1, 1, 0, Ladder, lRot);
	//lGrid.mCells.SetCell(2, 1, 0, Impassable, lRot);
	//lGrid.mCells.SetCellType(0, 2, 0, Passable);
	//lGrid.mCells.SetCellType(0, 2, 0, Impassable);
	//lGrid.mCells.SetCellType(1, 2, 0, Passable);
	//lGrid.mCells.SetCellType(2, 2, 0, Passable);

	//lGrid.mEdges.SetEdge(lGrid.mCells.GetCell(0, 0, 0), lGrid.mCells.GetCell(1, 0, 0), Impassable);
	//lGrid.mEdges.SetEdge(lGrid.mCells.GetCell(0, 0, 0), lGrid.mCells.GetCell(1, 1, 0), Impassable);

	lGrid.mEdges.CommitEdges();



	//// Testing dll input
 //	lTest = new class'X_COM_DllTest';
	//lTest.TestSendValue(1);

	//lCell.Point.X = 2;
	//lCell.Point.Y = 3;
	//lCell.Point.Z = 4;
	//lCell.Direction = 34;

	//count = 1000;
	//for(li = 0; li<count; li++)
	//{
	//	lCell.Type = li;
	//	lCell.direction = count - li;
	//	lArr.AddItem(lCell);
	//}
	//lVect.X = 1;
	//lVect.Y = 1;
	//lVect.Z = 1;
	////lTest.ChangeVector(lVect);
	//lVect2 = lVect;

	//lTest.TestSendCellsArray(lArr);
	////`log("Vector changed in C# : "$lVect.X$" "$lVect.Y$" "$lVect.Z$" "$lVect);(
	//lChangedArray.AddItem(lVect);
	//lChangedArray.AddItem(lVect2);

	


 //	lChangedArray = lTest.TestGetPath(lTest.TestFindPath(lVect, lVect2));
	//`log("lChangedArray Length: "$lChangedArray.Length);
	//`log("Vector 1: "$lChangedArray[0]);
	//`log("Vector 2: "$lChangedArray[1]);
	//`log("Vector 3: "$lChangedArray[2]);
	////`log("lChangedArray X2: "$lChangedArray[0].Y);
	////`log("lChangedArray X3: "$lChangedArray[0].Z);
	////`log("lChangedArray X4: "$lChangedArray[1].X);
	////`log("lChangedArray X5: "$lChangedArray[1].Y);
	////`log("lChangedArray X6: "$lChangedArray[1].Z);



	


	//Clock( lClockTime );
	//result = lTest.TestSendCellsArray(lArr);
	//UnClock( lClockTime );
	//`log("DLLBind array casting test: "$lClockTime);

	


	//Clock( lClockTime );
	//for(li = 0; li<count; li++)
	//{
	//	lTest.TestSendValue(li);
	//}
	
	//UnClock( lClockTime );
	//`log("DLLBind value casting test: "$lClockTime);
	//result = lTest.TestSendValue(5);

}

event PreBeginPlay()
{
	super.PreBeginPlay();
	CreateTeam(ET_HUMAN_Player_1);
	CreateTeam(ET_ALIEN);
}

/** Placing controller into start point in FrontEnd map */
event PlayerController Login(string Portal, string Options, const UniqueNetID UniqueID, out string ErrorMessage)
{
	local PlayerController NewPlayer;
	NewPlayer = super.Login(Portal, Options, UniqueID, ErrorMessage);
	return NewPlayer;
}

event PostLogin( PlayerController NewPlayer )
{
 	lastPlayerController = X_COM_PlayerController(NewPlayer); // Save reference of player controller which can be get in GET-function
	super.PostLogin(NewPlayer);
}

//=============================================================================
// Functions: map loading
//=============================================================================
function performServerTravel(string aURL)
{
	// We do not need to save gameplay DB to disk if we are exiting to main menu
	if (((Class == class'X_COM_GameInfo') && (aURL == class'X_COM_Settings'.default.GEOmap)) || // if new game or load game
		((Class != class'X_COM_GameInfo') && ( (aURL == class'X_COM_Settings'.default.TacticsMap) || (aURL == class'X_COM_Settings'.default.GEOmap) ) ) ) // transition db if we are going from GEO->Tactics->GEO
	{
		mFilemanager.saveTransition(); // Save temporary DB
	}
	WorldInfo.ServerTravel(aURL);
}

function performServerTravelDone(string aOptions)
{
	if(Class == class'X_COM_GameInfo') // We do not need to load gameplay DB from disk if we are exiting to main menu
	{
		mDatabase.loadLocalizationDatabase();
		mDatabase.loadSavedGamesDatabase();
	}
	else
	{
		mDatabase.loadGameContentDatabases();
		mDatabase.loadLocalizationDatabase();
		mDatabase.loadSavedGamesDatabase();
		mFilemanager.loadTransition();
		mFilemanager.DeleteTransition(); // delete temp transition db file
	}
}

//=============================================================================
// Teams
//=============================================================================
function bool ChangeTeam(Controller Other, int aNewTeam, bool bNewTeam)
{
	if ( (Other != none) && (Teams[aNewTeam]!= none) ) return Teams[aNewTeam].AddToTeam(Other);
	return false;
}

/* create a player team, and fill from the team roster
*/
function CreateTeam(int aTeamIndex)
{
	Teams[aTeamIndex] = spawn(class'TeamInfo');
	Teams[aTeamIndex].TeamIndex = aTeamIndex;
	GameReplicationInfo.SetTeam(aTeamIndex, Teams[aTeamIndex]);
}

exec function XH()
{
	ConsoleCommand("open x-com_fastT.udk?game=X-COM_H.xcH_GameInfo");

}

//=============================================================================
// Functions: Global
//=============================================================================
function float GetGameSpeed()
{
	return GameSpeed;
}

//=============================================================================
// Default Properties: 
//=============================================================================
defaultproperties
{
	bTeamGame = TRUE
	bDelayedStart = FALSE
	bWaitingToStartMatch = TRUE
	PlayerControllerClass=class'X-COM_GAME.X_COM_PlayerController'
	HUDType=class'X-COM_GAME.X_COM_HUD'

	Name="Default__X_COM_GameInfo"
}