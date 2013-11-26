/**
 * X-Com database manager.
 * Used to initialize and set up all game databases.
 * Used to save and load savegame databases.
 */
class XCOMDB_Manager extends Actor
	dependson(XCOMDB_DLLAPI)
	config(XComDB);


//=============================================================================
// Variables
//=============================================================================
var private XCOMDB_Cache mDBCache;
var private XCOMDB_DLLAPI mDLLAPI;

var config ESQLDriver mDatabaseDriver;
var config string mUserCodeRelPathUDKGame;
var config string mDataRootPath;
var config string mSaveGameRootPath;

var config array<string> mContentDBs;
var config string mDefaultGameplayDB;
var config string mLocalizationDB;
var config string mSavedGamesDB; // Save DB file. Stored in config file. This file has records about saved files and them dates.

var config string mLanguage;

var int mContentDatabaseIdx;
var int mGameplayDatabaseIdx;
var int mLocalizationDatabaseIdx;
var int mLocaDatabaseIdx; //delete it
var int mSavedGamesDatabaseIdx; //saved games database index

//=============================================================================
// Functions
//=============================================================================
final function XCOMDB_Cache getDBCache()
{
	return mDBCache;
}

/**
 * Get the created DLLAPI object to gain access of all the API functions.
 * 
 * \return Allocated DLLAPI object
 */
final function XCOMDB_DLLAPI getDLLAPI()
{
	return mDLLAPI;
}

/**
 * Initialise the databasedriver and creat/load the default databases
 */
function PostBeginPlay()
{
  super.PostBeginPlay();

	mDLLAPI.SQL_initSQLDriver(mDatabaseDriver); // automatically create one empty DB

	mDBCache = Spawn(class'XCOMDB_Cache', self);

	//loadLocalizationDatabase();
	//loadSavedGamesDatabase();
	//loadGameContentDatabases();
	//createGameplayDatabase();
}

/**
 * Load all per default properties set game content databases into memory
*/
final function loadGameContentDatabases()
{
	local int il;
	local int lNewDatabase;
	local string lFilePath;

	if(mContentDBs.Length > 0)
	{
		lFilePath = mUserCodeRelPathUDKGame $ mDataRootPath;

		if(mDLLAPI.IO_fileExists(lFilePath $ mContentDBs[0]))
		{
			if(mDLLAPI.SQL_loadDatabase(lFilePath $ mContentDBs[0]))
			{
				`log("<<< GameContentDatabase loaded: " $ lFilePath $ mContentDBs[0]);
			}
		}

		for(il=1; il<mContentDBs.Length; ++il)
		{
			if(mDLLAPI.IO_fileExists(lFilePath $ mContentDBs[il]))
			{
				lNewDatabase = mDLLAPI.SQL_createDatabase();
				if(lNewDatabase >= 0)
				{
					mDLLAPI.SQL_selectDatabase(lNewDatabase);
					if(mDLLAPI.SQL_loadDatabase(lFilePath $ mContentDBs[il]))
					{
						`log("<<< GameContentDatabase loaded: " $ lFilePath $ mContentDBs[il]);
					}
				}
			}
		}
	}
}

/**
 * Load the saved games database
*/
function loadSavedGamesDatabase()
{
	local int lNewDatabase;
	local string lFilePath;

	lFilePath = mUserCodeRelPathUDKGame $ mDataRootPath;
	if(mDLLAPI.IO_fileExists(lFilePath $ mSavedGamesDB))
	{
		lNewDatabase = mDLLAPI.SQL_createDatabase();
		if(lNewDatabase >= 0)
		{
			mDLLAPI.SQL_selectDatabase(lNewDatabase);
			if (mDLLAPI.SQL_loadDatabase(lFilePath $ mSavedGamesDB))
			{
				`log("<<< Saved Games Database loaded: " $ lFilePath $ mSavedGamesDB);
			}
			mSavedGamesDatabaseIdx = lNewDatabase;
		}
	}
}

/**
 * Load localization databases into memory
*/
final function loadLocalizationDatabase()
{
	local int lNewDatabase;
	local string lFilePath;

	lFilePath = mUserCodeRelPathUDKGame $ mDataRootPath;
	if(mDLLAPI.IO_fileExists(lFilePath $ mLocalizationDB))
	{
		lNewDatabase = mDLLAPI.SQL_createDatabase();
		if(lNewDatabase >= 0)
		{			
			mDLLAPI.SQL_selectDatabase(lNewDatabase);
			if(mDLLAPI.SQL_loadDatabase(lFilePath $ mLocalizationDB))
			{
				`log("<<< Localization Database loaded: " $ lFilePath $ mLocalizationDB);
			}
			mLocaDatabaseIdx = lNewDatabase;
		}
	}
}

/**
 * Create empty DB for gameplay DB and save its index.
 */
function createGameplayDatabaseIndex()
{
	local int lNewDatabase;

	lNewDatabase = mDLLAPI.SQL_createDatabase();
	if(lNewDatabase >= 0) mGameplayDatabaseIdx = lNewDatabase;
}

/**
 * Load the default database for gamplay and load the basic database structure into memory.
*/
function loadDefaultGameplayDatabase()
{
	local int lNewDatabase;
	local string lFilePath;

	if (mDefaultGameplayDB != "")
	{
		lFilePath = mUserCodeRelPathUDKGame $ mDataRootPath;
		if(mDLLAPI.IO_fileExists(lFilePath $ mDefaultGameplayDB))
		{
			lNewDatabase = mDLLAPI.SQL_createDatabase();
			if(lNewDatabase >= 0) 
			{
				mDLLAPI.SQL_selectDatabase(lNewDatabase);
				if(mDLLAPI.SQL_loadDatabase(lFilePath $ mDefaultGameplayDB))
				{
					`log("<<< Default Gameplay Database loaded: " $ lFilePath $ mDefaultGameplayDB);
				}
				mGameplayDatabaseIdx = lNewDatabase;
			}		
		}
	}
	else `warn("DB config file is wrong");
}

/**
 * Load the saved database for gamplay and setting it in mGameplayDatabaseIdx
*/
/*
function loadSavedGameplayDatabase(string aSaveFile)
{
	local int lNewDatabase;
	local string lFilePath;

	lNewDatabase = mDLLAPI.SQL_createDatabase();
	if(lNewDatabase >= 0 && aSaveFile != "")
	{
		lFilePath = mUserCodeRelPathUDKGame $ mSaveGameRootPath;
		mDLLAPI.SQL_selectDatabase(lNewDatabase);
		mDLLAPI.SQL_loadDatabase(lFilePath $ aSaveFile);
		mGameplayDatabaseIdx = lNewDatabase;
	}
}
*/
function loadSavedGameplayDatabase(string aSaveFile)
{
	local int lNewDatabase;

	lNewDatabase = mDLLAPI.SQL_createDatabase();
	if(lNewDatabase >= 0 && aSaveFile != "")
	{
		mDLLAPI.SQL_selectDatabase(lNewDatabase);
		if(mDLLAPI.SQL_loadDatabase(aSaveFile))
		{
			`log("<<< Saved Gameplay Database loaded: " $ aSaveFile $ " | and its index is: " $ lNewDatabase);
		}
		mGameplayDatabaseIdx = lNewDatabase;
	}
}

//=============================================================================
// Default Properties: 
//=============================================================================
DefaultProperties
{
  TickGroup=TG_DuringAsyncWork

	bHidden=TRUE
	Physics=PHYS_None
	bReplicateMovement=FALSE
	bStatic=FALSE
	bNoDelete=FALSE

	Begin Object Class=XCOMDB_DLLAPI Name=DllApiInstance
	End Object
	mDLLAPI=DllApiInstance

	Name="Default__XCOMDB_Manager"
}
