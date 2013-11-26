class xcGEO_2DMap_Manager  extends Actor
	dependson(xcGEO_2DMap_DLLAPI);

//=============================================================================
// Variables
//=============================================================================
var private xcGEO_2DMap_DLLAPI mDLLAPI;
var private int mStandardMapId;
var private int mLandOrSeaMapId;

//=============================================================================
// Functions
//=============================================================================
/**
 * Initialise the map 
 */
function PostBeginPlay()
{
	local string lFilePath;
	local int lRetTest;
	local bool lBoolResult	;

	super.PostBeginPlay();
	
	//TODO move maps names to configs
	lFilePath = "..\\..\\..\\UDKGame\\Content\\X-COM\\Geo2DMaps\\wgs84.world.200406.3x5400x2700.jpg";
	`log("<<< 2DMap_Manager loading 2D map 'StandardWorld': " $ lFilePath);
	mStandardMapId = mDLLAPI.LoadPlateCarreeMap(lFilePath, 0.0);	
	`log("<<< 2DMap_Manager 'StandardWorld' map loaded with id: "$mStandardMapId);	

	lFilePath = "..\\..\\..\\UDKGame\\Content\\X-COM\\Geo2DMaps\\gebco_bathy.5400x2700.jpg";
	`log("<<< 2DMap_Manager loading 2D map 'Sea and Earth': " $ lFilePath);
	mLandOrSeaMapId = mDLLAPI.LoadPlateCarreeMap(lFilePath, 0.0);
	`log("<<< 2DMap_Manager 'Sea and Earth' map loaded with id: "$mLandOrSeaMapId);

	lRetTest = mDLLAPI.GetColorCode(mLandOrSeaMapId, DegToRad*37.08941820666, DegToRad*-76.4730834960);
	`log("<<< 2DMap_Manager map returned color for 37.08941820666, -76.4730834960 (Newport News, US) = "$lRetTest);
	
	lRetTest = mDLLAPI.GetColorCode(mLandOrSeaMapId, DegToRad*37.08941820666, DegToRad*-66.4730834960);
	`log("<<< 2DMap_Manager map returned color for 37.08941820666, -66.4730834960 (Ocean western to Newport News, US) = "$lRetTest);
	
	lBoolResult = IsLand(DegToRad*37.08941820666, DegToRad*-76.4730834960);
	`log("<<< 2DMap_Manager IsLand 37.08941820666, -76.4730834960 (Newport News, US) = "$lBoolResult);

	`utAssertTrue(lBoolResult, "IsLand 37.08941820666, -76.4730834960 (Newport News, US)");

	lBoolResult = IsLand(DegToRad*37.08941820666, DegToRad*-66.4730834960);
	`log("<<< 2DMap_Manager IsLand 37.08941820666, -66.4730834960 (Ocean western to Newport News, US) = "$lBoolResult);

	`utAssertFalse(lBoolResult, "IsLand 37.08941820666, -66.4730834960 (Ocean western to Newport News, US)");	

	//GetPackageName()$"______"
}


/** Returns true if the coordinates corresponds to land. False if coordinates corresponds to sea*/
function bool IsLand(float aLatitude, float aLongitude)
{
	local int lResult;
	lResult = mDLLAPI.GetColorCode(mLandOrSeaMapId, aLatitude, aLongitude);
    if(lResult == 0) return true; //0 is black. Earth is total black on the map
	return false;                 //any other color code means water
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

	Begin Object Class=xcGEO_2DMap_DLLAPI Name=DllApiInstance
	End Object
	mDLLAPI=DllApiInstance

	Name="Default__XCOMDB_xcGEO_2DMap_Manager"
}
