/**
 * X-COM Save Game Manager. Store functions to save and load saved games
 */
class X_COM_SaveLoadMgr extends Actor
	dependson(XCOMDB_DLLAPI)
	config(XCom);

//=============================================================================
// Variables:
//=============================================================================
var private XCOMDB_DLLAPI       mDLLAPI;

//=============================================================================
// Init
//=============================================================================
/**
 * Initialise the filemanager and assign database and DLLAPI references for later usage.
 */
function PostBeginPlay()
{
  super.PostBeginPlay();

	mDLLAPI = XCOMDB_Manager(Owner).getDLLAPI();
}

//=============================================================================
// Functions
//=============================================================================
function RunGame()
{
	X_COM_GameInfo(Owner.Owner).performServerTravel(class'X_COM_Settings'.default.GEOmap);
}

/** UI function. Called when player select "Start new game" in main menu. It loads empty game world from template DB file */
function LoadNewGame()
{
	local XCOMDB_Manager lDatabaseMgr;
	lDatabaseMgr = X_COM_GameInfo(Owner.Owner).getDBMgr();
	lDatabaseMgr.loadDefaultGameplayDatabase();
	RunGame();
}

/** TACTICS TEST!!!! delete it after tactics test will be removed from main menu */
function RunTacticsTest()
{
	local XCOMDB_Manager lDatabaseMgr;
	local X_COM_FileMgr lFileMgr;
	lDatabaseMgr = X_COM_GameInfo(Owner.Owner).getDBMgr();
	lDatabaseMgr.loadDefaultGameplayDatabase();
	lFileMgr = X_COM_GameInfo(Owner.Owner).getFileMgr();
	lFileMgr.saveTransition();
	X_COM_GameInfo(Owner.Owner).performServerTravel(class'X_COM_Settings'.default.TacticsMap);
}

/** UI function. Called when player select "load game" in main menu. It loads game world from player saved DB file */
function bool LoadSavedGame(string aSaveTitle)
{
	//local XCOMDB_Manager lDatabaseMgr;
	//lDatabaseMgr = X_COM_GameInfo(Owner.Owner).getDBMgr();

	local X_COM_Savegame lSavegame;
	local int lGameType;
	local XCOMDB_Manager lDatabaseMgr;

	lDatabaseMgr = X_COM_GameInfo(Owner.Owner).getDBMgr();

	lSavegame = Spawn(class'X_COM_Savegame');
	//lSavegame.mSaveFileName = aSaveFileName;

	mDLLAPI.SQL_selectDatabase(lDatabaseMgr.mSavedGamesDatabaseIdx);
	if (mDLLAPI.SQL_queryDatabase("SELECT * FROM SAVED_GAMES WHERE Title="$aSaveTitle$";"))
	{
		while(mDLLAPI.SQL_nextResult())
		{
			`XCOM_InitString(lSavegame.mSaveFileName,100);
			mDLLAPI.SQL_getStringVal("File", lSavegame.mSaveFileName);
			mDLLAPI.SQL_getIntVal("GameType", lGameType);
		}
	}

	//lSaveFile = lDatabaseMgr.mUserCodeRelPathUDKGame $ mDatabaseMgr.mSaveGameRootPath $ aSaveFileName$".s3db"; //get full path+save name
	if (mDLLAPI.IO_fileExists(lSavegame.mSaveFileName)) lDatabaseMgr.LoadSavedGameplayDatabase(lSavegame.mSaveFileName); // if exists then load it
		else 
		{
			X_COM_GameInfo(Owner.Owner).Broadcast(self, "Error loading saved game file!");
			FixSavedGamesList(aSaveTitle);
			return false;
		}

	RunGame();

	return true;
}

/** Delete record of non-exist save file from saved files list */
function FixSavedGamesList(string aSaveTitle)
{	
	local string lSaveTitle;
	local int lID;
	local XCOMDB_Manager lDatabaseMgr;
	local X_COM_FileMgr lFileMgr;

	lDatabaseMgr = X_COM_GameInfo(Owner.Owner).getDBMgr();
	lFileMgr = X_COM_GameInfo(Owner.Owner).getFileMgr();

	mDLLAPI.SQL_selectDatabase(lDatabaseMgr.mSavedGamesDatabaseIdx);
	if (mDLLAPI.SQL_queryDatabase("SELECT * FROM SAVED_GAMES;"))
	{
		while(mDLLAPI.SQL_nextResult())
		{
			`XCOM_InitString(lSaveTitle,50);
			mDLLAPI.SQL_getStringVal("Title", lSaveTitle);
			if (lSaveTitle == aSaveTitle)
			{
				mDLLAPI.SQL_getIntVal("ID", lID); //save ID of non-exist file
			}
		}
	}
    mDLLAPI.SQL_queryDatabase("DELETE FROM SAVED_GAMES WHERE ID="$lID$";"); // delete record with saved ID
	lFileMgr.Save_SavedGamesDB(); // save modified list
}

/** UI function. Delete save file from HDD and it's record from saved files list */
function bool DeleteSaveFile(string aSaveTitle)
{
	local string lSaveFile;
	local int lID;
	local XCOMDB_Manager lDatabaseMgr;
	local X_COM_FileMgr lFileMgr;

	lDatabaseMgr = X_COM_GameInfo(Owner.Owner).getDBMgr();
	lFileMgr = X_COM_GameInfo(Owner.Owner).getFileMgr();

	mDLLAPI.SQL_selectDatabase(lDatabaseMgr.mSavedGamesDatabaseIdx);
	if (mDLLAPI.SQL_queryDatabase("SELECT * FROM SAVED_GAMES WHERE Title="$aSaveTitle$";"))
	{
		while(mDLLAPI.SQL_nextResult())
		{
			`XCOM_InitString(lSaveFile,100);
			mDLLAPI.SQL_getStringVal("File", lSaveFile);
			mDLLAPI.SQL_getIntVal("ID", lID);		
		}
	}
	else `warn("Can't get data of saved game : "$aSaveTitle);

	if (mDLLAPI.IO_fileExists(lSaveFile))
	{
		if (mDLLAPI.IO_deleteFile(lSaveFile))
		{
			if (!mDLLAPI.SQL_queryDatabase("DELETE FROM SAVED_GAMES WHERE ID="$lID$";")) `warn("Can't delete data of saved game from SavedGames DB"); // delete record with saved ID
			lFileMgr.Save_SavedGamesDB(); // save modified list
			return true;
		}
	}
	else `warn("Can't delete save file : "$lSaveFile);

	return false;
}

/** This function gets records of files and it's dates from savegame DB in 2 separate arrays. Then those arrays will be loaded in save or load menu */
function bool GetSavedGamesList(out array<string> SaveName, out array<string> SaveDate)
{	
  
	local string lSaveName, lSaveDateTime;
	local XCOMDB_Manager lDatabaseMgr;

	lDatabaseMgr = X_COM_GameInfo(Owner.Owner).getDBMgr();

	mDLLAPI.SQL_selectDatabase(lDatabaseMgr.mSavedGamesDatabaseIdx);
	if (mDLLAPI.SQL_queryDatabase("SELECT * FROM SAVED_GAMES;"))
	{
		while(mDLLAPI.SQL_nextResult())
		{
			`XCOM_InitString(lSaveName,50);
			mDLLAPI.SQL_getStringVal("Title", lSaveName);
			SaveName.AddItem(lSaveName);
			`XCOM_InitString(lSaveDateTime,20);
			mDLLAPI.SQL_getStringVal("DateTime", lSaveDateTime);
			SaveDate.AddItem(lSaveDateTime);
		}
		return true;
	}
	return false;
}

/** UI function. Save game */
function bool NewSaveGame(string aSaveFileName)
{
	local X_COM_Savegame lSavegame;
  
	lSavegame = Spawn(class'X_COM_Savegame');
	lSavegame.mTitle = aSaveFileName;
	lSavegame.mSaveFileName = aSaveFileName$".s3db";
  
	SaveWorldProperties();

	if (!SaveGameToDBandHDD(lSavegame))	return false;
	else return true;
}

/** Save main world properties in save file */ 
function SaveWorldProperties()
{ 
	X_COM_GameInfo(Owner.Owner).SaveWorldProperties();
}

/** Save game to saves-list and HDD */
function bool SaveGameToDBandHDD(X_COM_Savegame aSavegame)
{
	local string lQuery;
	local string lFullPathToSaveFile;
	local XCOMDB_Manager lDatabaseMgr;
	local X_COM_FileMgr lFileMgr;

	lDatabaseMgr = X_COM_GameInfo(Owner.Owner).getDBMgr();
	lFileMgr = X_COM_GameInfo(Owner.Owner).getFileMgr();

	lFullPathToSaveFile = lDatabaseMgr.mUserCodeRelPathUDKGame $ lDatabaseMgr.mSaveGameRootPath $ aSavegame.mSaveFileName;

	if ((!mDLLAPI.IO_fileExists(lFullPathToSaveFile)) && (!IfIsInList(aSavegame.mTitle))) lFileMgr.Save_GameToFile(aSavegame.mSaveFileName); 
		else 
		{
			//mGameInfo.Broadcast(mGameInfo, "Error! Such save file exists! Write enother name!");
			`warn("Error! Such save file exists! Write enother name!");
			return false;
		}
		
	mDLLAPI.SQL_selectDatabase(lDatabaseMgr.mSavedGamesDatabaseIdx);
	lQuery = "INSERT INTO SAVED_GAMES (GameType, Title, File, DateTime) VALUES ('"$(1)$"','"$aSavegame.mTitle$"','"$lFullPathToSaveFile$"',datetime('now','localtime'));";
	if (!mDLLAPI.SQL_queryDatabase(lQuery))
	{
		`warn(" Something goes wrong when saving db with savedgames");
		if (mDLLAPI.IO_fileExists(lFullPathToSaveFile)) mDLLAPI.IO_deleteFile(lFullPathToSaveFile);
		return false;
	}
	lFileMgr.Save_SavedGamesDB();
	return true;
}

/** true if new save file name already in list */
function bool IfIsInList(string aSaveName)
{
	local string lSaveName;
	local XCOMDB_Manager lDatabaseMgr;

	lDatabaseMgr = X_COM_GameInfo(Owner.Owner).getDBMgr();
	mDLLAPI.SQL_selectDatabase(lDatabaseMgr.mSavedGamesDatabaseIdx);
	if (mDLLAPI.SQL_queryDatabase("SELECT * FROM SAVED_GAMES;"))
	{
		while(mDLLAPI.SQL_nextResult())
		{
			//lSaveName = class'X_COM_Defines'.static.initString(50);
			`XCOM_InitString(lSaveName,50);
			mDLLAPI.SQL_getStringVal("TITLE", lSaveName);
			if (lSaveName == aSaveName) return true;
		}
	}
	return false;
}

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
  TickGroup=TG_DuringAsyncWork

	bHidden=TRUE
	Physics=PHYS_None
	bReplicateMovement=FALSE
	bStatic=FALSE
	bNoDelete=FALSE

	Name="Default__X_COM_SaveLoadMgr"
}

/* ============================================================================= */
/* SAVE GAME logics */ 
/* 
1. Main menu
for main menu loaded Loca DB for localisation menu titles
for main menu loaded Saved games DB for where list of saved files with paths and titles stored, so you can choose new game or load game

We dont load content and gameplay DB for main menu.. because it is not used and without it loading of game is faster

2. Start new game
When in UI "start new game" is clicked then "LoadNewGame()" in "X_COM_SaveLoadMgr" is called. This function loads default 
game play DB and call "performServerTravel()". "performServerTravel()" saves loaded default gameplay DB as transition file and run map.
After map loaded and game initialized then "performServerTravelDone()" which restore gameplay DB from transition file.
Function "StartGame()" in GameInfo calls "BuildWorld()" in "LevelManager class". "LevelManager" doing next things: gets all world properties 
from gameplay DB, place bases, sun, moon, camera view on Earth, time, interceptors in Air and etc. And it builds world with data which is in 
gameplay DB stored.

3. Load saved game
When in UI "load game" is clicked then opens new UI menu "Load menu". In this menu is grid list. At open "Load menu" calls "GetSavedGamesList()"
from "X_COM_SaveLoadMgr" which gets list of saved files from Saved games DB. Player selects saved file by a title in menu and clicks on
"Load button" which calls "LoadSavedGame()" in "X_COM_SaveLoadMgr". "LoadSavedGame()" doing next things:
a) Gets saved file name with its path from Saved games DB by selected title.
b) Loads saved file: saved file loads as game play db and it will be used instead default gameplay db.
c) Calls "performServerTravel()".
Others actions same as when you starting new game (same from starts "performServerTravel()")

Good things:
We dont need to use separate DB files and separate functions for new game or load game. We use same fnctions, but what to load in map is defined
in tables in gameplay DB. Like in example in "2.Start new game"
So: if new game and we have no bases - bases are not places in map, if load game and we have bases, then bases will be placed in map where it was
when game was saved. It means: in default gameplay DB is table Bases and it has no data, so no bases will be placed in map. In saved game in Bases 
table we have 3 bases - all those bases will be placed in map.
and etc...

4. Save game
When in UI "save game" is clicked then opens new UI menu "save menu". In this menu is grid list. At open "save menu" calls "GetSavedGamesList()"
from "X_COM_SaveLoadMgr" which gets list of saved files from Saved games DB. Player can not rewrite exist save file. Player should click on text 
field to write  new save title and press "save button". Save file will has same name as player typed title in text field.
"save button" calls "NewSaveGame()" in "X_COM_SaveLoadMgr". "NewSaveGame()" doing next things:
a) Saves all world properties to gameplay Db in memory. It saves Bases on planets, sun and moon locations, camera view on Earth, time, interceptors in Air and etc.
b) Saves gameplay DB from memory to save file
c) Saves Saved games DB to HDD with updated list of saved files (where new save game inserted)

*/
/* ============================================================================= */