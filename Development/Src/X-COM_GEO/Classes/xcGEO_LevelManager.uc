/**
 * 
 * 
 */
class xcGEO_LevelManager extends Actor notplaceable;

//=============================================================================
// Variables: References
//=============================================================================
var xcGEO_Factory_SolarSystem	SolarSystem;
var xcGEO_GameInfo              mGameInfo;
var private XCOMDB_Manager	                        mDatabaseMgr;
var private XCOMDB_DLLAPI                                mDLLAPI;

//var Vector                      newGEO_Location;
//var Rotator                     newGEO_Rotation;

//=============================================================================
// Functions
//=============================================================================
/** init references */
function initLevelManager(GameInfo aGameInfo)
{
	mGameInfo = xcGEO_GameInfo(aGameInfo);
	mDatabaseMgr = mGameInfo.getDBMgr();
	mDLLAPI = mDatabaseMgr.getDLLAPI();
}

/** Start to build world */
function BuildWorld()
{
	BuildSolarSystem();
	SetUpWorldProperties();
	PlaceBases();
}

/** Build solar system with planets and sun */
function BuildSolarSystem()
{
	SolarSystem =  Spawn(class'xcGEO_Factory_SolarSystem',Self);
	SolarSystem.CreateSun();
	SolarSystem.CreateEarth();
	SolarSystem.CreateMoon();
}

/** Load world properties (Default from template DB or from saved gameplay DB)*/
function SetUpWorldProperties()
{
	local string lQuery;
	local xcGEO_PlayerController lxcPC;
	local string lDATE;
	local string lTIME;
	local string Str2VR; //temp for convert string to vector/rotator
	local int lFOUNDS;
	local Vector lGEO_LOCATION;
	local Rotator lGEO_ROTATION;	
	local Rotator lSUN_ROTATION;
	local Rotator lMOON_ROTATION;

	lxcPC = xcGEO_PlayerController(mGameInfo.GetPlayerController());
	mDLLAPI.SQL_selectDatabase(mDatabaseMgr.mGameplayDatabaseIdx);
	lQuery = "SELECT * FROM GEO_DATA WHERE ID = 0;";
	if (mDLLAPI.SQL_queryDatabase(lQuery))
	{
		while(mDLLAPI.SQL_nextResult())
		{
			`XCOM_InitString(lDATE,10);
			mDLLAPI.SQL_getStringVal("Date", lDATE);
			`XCOM_InitString(lTIME,8);
			mDLLAPI.SQL_getStringVal("Time", lTIME);
			mDLLAPI.SQL_getIntVal("Founds", lFOUNDS);
			`XCOM_InitString(Str2VR,30);
			mDLLAPI.SQL_getStringVal("Location", Str2VR);
			lGEO_LOCATION = class'X_COM_Defines'.static.string2Vec(Str2VR);
			`XCOM_InitString(Str2VR,20);
			mDLLAPI.SQL_getStringVal("Rotation", Str2VR);
			lGEO_ROTATION = class'X_COM_Defines'.static.string2Rot(Str2VR);
			`XCOM_InitString(Str2VR,20);
			mDLLAPI.SQL_getStringVal("Sun_Rotation", Str2VR);
			lSUN_ROTATION = class'X_COM_Defines'.static.string2Rot(Str2VR);
			`XCOM_InitString(Str2VR,20);
			mDLLAPI.SQL_getStringVal("Moon_Rotation", Str2VR);
			lMOON_ROTATION = class'X_COM_Defines'.static.string2Rot(Str2VR);
		}
	}
	lxcPC.SetLocation(lGEO_LOCATION); // set playercontroller location
	lxcPC.SetRotation(lGEO_ROTATION); // set playercontroller rotation
	// сцуко блядъ! не получается загрузить сохраненный зум!!! :( GeoDistanceFromPlanet если не равен мах значению то зум сбивается внутрь планеты и я ХЗ почему!
	// TODO :  load saved distance... or maybe wait while camera will be instead this type.
	lxcPC.GeoDistanceFromPlanet = class'X_COM_Settings'.default.GEO_MaxZoomLocationOffset; //distance from Earth
	SolarSystem.SunPL.SetRotation(lSUN_ROTATION);
	SolarSystem.MoonPL.SetRotation(lMOON_ROTATION);
}

/** place user bases on planets */
function PlaceBases()
{
	local string lQuery;
	local xcGEO_Base_Manager lBaseManager;
	local int lID;
	local string lBaseName;
	local int lRegion;
	local String lVectStr, lRotStr;
	local Vector lLOCATION;
	local Rotator lROTATION;
	local xcGEO_Tile_Bases_GeoBase	lNewBase;

	lBaseManager = Spawn(Class'xcGEO_Base_Manager',,,Class'X_COM_Settings'.Default.Base_Location);
	mDLLAPI.SQL_selectDatabase(mDatabaseMgr.mGameplayDatabaseIdx);
	lQuery = "SELECT * FROM BASES;";
	if (mDLLAPI.SQL_queryDatabase(lQuery))
	{
		while(mDLLAPI.SQL_nextResult())
		{
			mDLLAPI.SQL_getIntVal("ID", lID);

			lBaseName = class'X_COM_Defines'.static.initString(35);
			mDLLAPI.SQL_getStringVal("ROTATION", lBaseName);

			lVectStr = class'X_COM_Defines'.static.initString(25);
			mDLLAPI.SQL_getStringVal("LOCATION", lVectStr);
			lLOCATION = class'X_COM_Defines'.static.string2Vec(lVectStr);

			lRotStr = class'X_COM_Defines'.static.initString(25);
			mDLLAPI.SQL_getStringVal("ROTATION", lRotStr);
			lROTATION = class'X_COM_Defines'.static.string2Rot(lRotStr);

			mDLLAPI.SQL_getIntVal("REGION", lRegion);

			lNewBase = lBaseManager.PlaceBaseOnPlanet(lLOCATION, lROTATION);
			lNewBase.BaseID = lID;
			lNewBase.BaseName = lBaseName;
			lNewBase.Region = ERegions(lRegion);
		}
	}
}

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
}