/**
 * Base Manager
 * Uses for managing bases and creating bases
 */
class xcGEO_Base_Manager extends Actor notplaceable;

//=============================================================================
// Variables: General
//=============================================================================
var xcGEO_Factory_BaseCreator							BaseCreator; //reference
var Name                                                BaseTag; //Tag of current base
var xcGEO_GameInfo                                      mGameInfo;
var private XCOMDB_Manager	                        mDatabaseMgr;
var private XCOMDB_DLLAPI                                mDLLAPI;

//=============================================================================
// Functions: General
//=============================================================================
/** Creation of Base creator and getting references*/
function PostBeginPlay()
{
	super.PostBeginPlay();
	mGameInfo = xcGEO_GameInfo(WorldInfo.Game);//xcGEO_GameInfo(aGameInfo);
	mDatabaseMgr = mGameInfo.getDBMgr();
	mDLLAPI = mDatabaseMgr.getDLLAPI();
	BaseCreator = Spawn(class'xcGEO_Factory_BaseCreator');
}

/** UI Function. Place x-com base on planet.*/
function xcGEO_Tile_Bases_GeoBase PlaceBaseOnPlanet(Vector aBaseLocation, Rotator aBaseRotation, optional name aTag)
{
	return BaseCreator.PlaceBaseOnPlanet(aBaseLocation, aBaseRotation, aTag);
}
/*
/** Get next base number for ID */
function int GetNewBaseID()
{
	local string lQuery;
	local int lNewID;
	lNewID = 1;
	mDLLAPI.SQL_selectDatabase(mDatabaseMgr.mGameplayDatabaseIdx);
	lQuery = "SELECT * FROM BASES;";
	if (mDLLAPI.SQL_queryDatabase(lQuery))
	{
		while(mDLLAPI.SQL_nextResult())
		{
			lNewID += 1;
		}
	}
	return lNewID;
}
*/
//=============================================================================
// Functions: New Base Creation
//=============================================================================
/** UI Function. Start to build new x-com base*/
function BuildNewBase(xcGEO_Tile_Bases_GeoBase aBase)
{
	BaseCreator.CreateGround();
	BaseCreator.CreateBaseLight();
	//aBase.BaseID = GetNewBaseID();
	SaveNewBaseToDB(aBase);
	aBase.BaseID = mDLLAPI.SQL_lastInsertID();
}

/** Save just created base to gameplay DB */
function SaveNewBaseToDB(xcGEO_Tile_Bases_GeoBase aBase)
{
	local string lQuery;
	local int lRegion;
	local Vector lLOCATION;
	local Rotator lROTATION;	
	lRegion = aBase.Region;
	lLOCATION = aBase.Location;
	lROTATION = aBase.Rotation;
	mDLLAPI.SQL_selectDatabase(mDatabaseMgr.mGameplayDatabaseIdx);
	lQuery = "INSERT INTO BASES (TITLE, REGION, LOCATION, ROTATION) VALUES ('"$aBase.BaseName$"', '"$lRegion$"', '"$lLOCATION$"', '"$lROTATION$"');";
	mDLLAPI.SQL_queryDatabase(lQuery);
}

//=============================================================================
// Functions: Load exist base
//=============================================================================
/** UI Function. Enter in exist base.*/
function LoadExistBase(xcGEO_Tile_Bases_GeoBase aBase)
{
	BaseCreator.CreateGround();
	BaseCreator.CreateBaseLight();
	LoadBaseFromDB(aBase);
}

/** Load exist base from gameplay DB*/
function LoadBaseFromDB(xcGEO_Tile_Bases_GeoBase aBase)
{
	local string lQuery;
	local String lVectStr, lRotStr;
	local int lModuleType;
	local Vector lLOCATION;
	local Rotator lROTATION;	

	mDLLAPI.SQL_selectDatabase(mDatabaseMgr.mGameplayDatabaseIdx);
	lQuery = "SELECT * FROM BASES_MODULES WHERE BaseID="$aBase.BaseID$";";
	if (mDLLAPI.SQL_queryDatabase(lQuery))
	{
		while(mDLLAPI.SQL_nextResult())
		{
			//lVectStr = class'X_COM_Defines'.static.initString(25);
			`XCOM_InitString(lVectStr,25);
			mDLLAPI.SQL_getStringVal("GridPos", lVectStr);
			//lLOCATION = class'X_COM_Defines'.static.string2Vec(lVectStr);
			`XCOM_String2Vec(lVectStr,lLOCATION);

			//lRotStr = class'X_COM_Defines'.static.initString(25);
			`XCOM_InitString(lRotStr,25);
			mDLLAPI.SQL_getStringVal("ROTATION", lRotStr);
			//lROTATION = class'X_COM_Defines'.static.string2Rot(lRotStr);
			`XCOM_String2Rot(lRotStr,lROTATION);

			mDLLAPI.SQL_getIntVal("ModuleRef", lModuleType);

			BaseCreator.PlaceBaseModule(class'xcGEO_Tile_Bases_Modules',lLOCATION, lROTATION, EModulesTypes(lModuleType));
		}
	}
}

//=============================================================================
// Functions: On exit from Base to GEO
//=============================================================================
/** Destroy all in base location to clear it for another base load*/
function DestroyAll()
{
	local X_COM_Tile lActor;

	ForEach DynamicActors(Class'X_COM_Tile', lActor)
	{
		if(lActor != none)
		{
			if ((lActor.IsA('xcGEO_Tile_Bases_BuildGround')) || (lActor.IsA('xcGEO_Tile_Bases_Modules')))
				lActor.Destroy();
		}
	}
	BaseCreator.DestroyBaseLight();
	self.Destroy();
}
//=============================================================================
// Functions: Base: Place Module
//=============================================================================
/** UI Function. Build selected module in GEO base managment */
function BuildBaseModule(xcGEO_Tile_Bases_Modules aModule, int aBaseID)
{
	BaseCreator.BuildBaseModule(aModule);
	SaveBaseModuleToDB(aModule, aBaseID);
}

/** Save built base module to gameplay DB for this base */
function SaveBaseModuleToDB(xcGEO_Tile_Bases_Modules aModule, int aBaseID)
{
	local string lQuery;
	local int lMODULE_ID, lBASE_ID;
	local Vector lLOCATION;
	local Rotator lROTATION;
	lMODULE_ID = int(aModule.ModuleType);
	lBASE_ID = aBaseID;
	lLOCATION = aModule.Location;
	lROTATION = aModule.Rotation;
	mDLLAPI.SQL_selectDatabase(mDatabaseMgr.mGameplayDatabaseIdx);
	lQuery = "INSERT INTO BASES_MODULES (ModuleRef, BaseID, GridPos, ROTATION) VALUES ('"$lMODULE_ID$"', '"$lBASE_ID$"', '"$lLOCATION$"', '"$lROTATION$"');";
	mDLLAPI.SQL_queryDatabase(lQuery);
}

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{

}