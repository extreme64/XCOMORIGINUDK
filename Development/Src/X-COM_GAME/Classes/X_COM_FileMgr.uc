/**
 * X-Com file manager.
 * Used to handle file management for loading and saving.
 * Includes creation of new directories, savegame directories and savegame database management
 */
class X_COM_FileMgr extends Actor
	dependson(XCOMDB_DLLAPI)
	config(XCom);


//=============================================================================
// Variables
//=============================================================================
var private XCOMDB_DLLAPI mDLLAPI;

//var config string mSavegameRootPath;
//var config string mSavegameDB;
//var int mSavegameDatabaseIdx;


//=============================================================================
// Functions
//=============================================================================
/**
 * Initialise the filemanager and assign database and DLLAPI references for later usage.
 */
function PostBeginPlay()
{
  super.PostBeginPlay();

	mDLLAPI = XCOMDB_Manager(Owner).getDLLAPI();
}

/**
 * Load transition database from disc into gamedatabase (within menory)
 * <UDK_ROOT> $ mDataRootPathData $ transition.s3db
 */
function loadTransition()
{
	local string lFilePath;

	lFilePath = XCOMDB_Manager(Owner).mUserCodeRelPathUDKGame $ XCOMDB_Manager(Owner).mDataRootPath;
	if(mDLLAPI.IO_fileExists(lFilePath $ "transition.s3db"))
	{
		XCOMDB_Manager(Owner).createGameplayDatabaseIndex(); // should be created empty db first
		mDLLAPI.SQL_selectDatabase(XCOMDB_Manager(Owner).mGameplayDatabaseIdx);
		if(mDLLAPI.SQL_loadDatabase(lFilePath $ "transition.s3db")){
			`log("<<< GameDatabase restored from Transition: " $ lFilePath $ "transition.s3db");
		}
	}
}

/**
 * Save gamedatabase (in memory) to transition database on disc
 * <UDK_ROOT> $ mDataRootPathData $ transition.s3db
 */
function saveTransition()
{
	local string lFilePath;

	lFilePath = XCOMDB_Manager(Owner).mUserCodeRelPathUDKGame $ XCOMDB_Manager(Owner).mDataRootPath;

	mDLLAPI.SQL_selectDatabase(XCOMDB_Manager(Owner).mGameplayDatabaseIdx);
	if(mDLLAPI.SQL_saveDatabase(lFilePath $ "transition.s3db"))
	{
		`log("<<< GameDatabase saved to Transition: " $ lFilePath $ "transition.s3db");
	}
}

/**
 * Delete old transition database from disc ( should be executed ONLY after it was loaded into memory)
*/
function DeleteTransition()
{
	local string lFilePath;

	lFilePath = XCOMDB_Manager(Owner).mUserCodeRelPathUDKGame $ XCOMDB_Manager(Owner).mDataRootPath;

	if(mDLLAPI.IO_fileExists(lFilePath $ "transition.s3db"))
	{
		mDLLAPI.IO_deleteFile(lFilePath $ "transition.s3db");
	}
}

//=============================================================================
// Saving functions
//=============================================================================
/**
 * Save gamedatabase (in memory) to save file on disc
 * <UDK_ROOT> $ mSaveGameRootPath $ "savename".s3db
*/
function Save_GameToFile(String aNewSaveName)
{
	local string lFilePath;
	local XCOMDB_Manager lDBMgr;
  
	lDBMgr = X_COM_GameInfo(Owner.Owner).getDBMgr();

	lFilePath = lDBMgr.mUserCodeRelPathUDKGame $ lDBMgr.mSaveGameRootPath;

	mDLLAPI.SQL_selectDatabase(lDBMgr.mGameplayDatabaseIdx);
	mDLLAPI.SQL_saveDatabase(lFilePath $ aNewSaveName);
}

/**
 * Save saved games list to SaveGamesDatabase on disc
 * <UDK_ROOT> $ mDataRootPathData $ savedgames.s3db
*/
function Save_SavedGamesDB()
{
	local string lFilePath;
	local XCOMDB_Manager lDBMgr;
  
	lDBMgr = X_COM_GameInfo(Owner.Owner).getDBMgr();

	lFilePath = lDBMgr.mUserCodeRelPathUDKGame $ lDBMgr.mDataRootPath;

	mDLLAPI.SQL_selectDatabase(lDBMgr.mSavedGamesDatabaseIdx);
	mDLLAPI.SQL_saveDatabase(lFilePath $ lDBMgr.mSavedGamesDB);
}

DefaultProperties
{
  TickGroup=TG_DuringAsyncWork

	bHidden=TRUE
	Physics=PHYS_None
	bReplicateMovement=FALSE
	bStatic=FALSE
	bNoDelete=FALSE

	Name="Default__X_COM_FileMgr"
}
