class xcGEO_Factory_SolarSystem extends Actor;

//=============================================================================
// Variables: Sun
//=============================================================================
var xcGEO_Tile_SolarSystem_Sun      SunPL; //Sun planet

//=============================================================================
// Variables: Planets: Earth
//=============================================================================
var xcGEO_Tile_Earth_Planet         EarthPL; //Earth object
var xcGEO_Tile_Earth_Clouds         EarthClouds; //Cloud object

//=============================================================================
// Variables: Planets: Moon
//=============================================================================
var xcGEO_Tile_SolarSystem_Moon     MoonPL; //Moon

//=============================================================================
// Functions: Sun
//=============================================================================
function CreateSun()
{
	if (SunPL==none) SunPL = Spawn(class'xcGEO_Tile_SolarSystem_Sun',Self,'Sun', class'X_COM_Settings'.default.GEO_WorldCenter);
}

//=============================================================================
// Functions: Earth
//=============================================================================
function CreateEarth()
{
	local Rotator lRotation;

	lRotation.Roll -= 23.44 * DegToRad * RadToUnrRot;

	// Earth planet
	if (EarthPL==none)
	{
		EarthPL = Spawn(class'xcGEO_Tile_Earth_Planet',Self, 'Planet', class'X_COM_Settings'.default.GEO_WorldCenter, lRotation);
		EarthPL.AddStaticMesh(StaticMesh(DynamicLoadObject(class'X_COM_Settings'.default.EarthStaticMesh, class'StaticMesh')));
		EarthPL.MakeInstancedEarth();
	}

	// Earth's Clouds
	if (EarthClouds==none)
	{
		EarthClouds = Spawn(class'xcGEO_Tile_Earth_Clouds',Self, 'Clouds', class'X_COM_Settings'.default.GEO_WorldCenter, lRotation);
		EarthClouds.AddStaticMesh(StaticMesh(DynamicLoadObject(class'X_COM_Settings'.default.EarthCloudsMesh, class'StaticMesh')));
		//EarthClouds.SetDrawScale(1.07); //FIX: need to remake earth mesh and cloud mesh to right bouds
	}

	ShowEarthReferenceGuidlines();
}

function ShowEarthReferenceGuidlines()
{
	local xcGEO_GameInfo lGameInfo;
	lGameInfo = xcGEO_GameInfo(WorldInfo.Game);    //should go prior

	DrawEarthGuidline(0 , 0 ,    255,0,0);
	lGameInfo.DisplayHudDebug("Red   ", "Lat:0     Lng:0      Zero");

    DrawEarthGuidline(90*DegToRad,  0,    0,255,0);
	lGameInfo.DisplayHudDebug("Green ", "Lat:90    Lng:0      North pole");

	DrawEarthGuidline(-37.796763*DegToRad,  144.9645996*DegToRad,    0, 0, 255);
	lGameInfo.DisplayHudDebug("Blue  ", "Lat:-37.8 Lng:144.9  Melbourne");

	DrawEarthGuidline(35.68225890670*DegToRad,  139.7620582580*DegToRad,    255, 255, 0);
	lGameInfo.DisplayHudDebug("Yellow", "Lat:35.7  Lng:139.8  Tokio");

	DrawEarthGuidline(37.08941820666*DegToRad,  -76.4730834960*DegToRad,    255, 0, 255);
	lGameInfo.DisplayHudDebug("Purple", "Lat:37.1  Lng:-76.5  Newport News");

	DrawEarthGuidline(48.86652153850*DegToRad,  2.340087890625*DegToRad,    0, 255, 255);
	lGameInfo.DisplayHudDebug("Cyan  ", "Lat:48.9  Lng:2.3    Paris");

	DrawEarthGuidline(59.94950917225*DegToRad,  30.38818359375*DegToRad,    255, 255, 255);
	lGameInfo.DisplayHudDebug("White ", "Lat:59.94 Lng:30.4   St. Petersburg");

	DrawEarthGuidline(75.92955002493*DegToRad,  -79.3212890625*DegToRad,    100, 100, 100);
	lGameInfo.DisplayHudDebug("Gray  ", "Lat:75.92 Lng:-79.32 Coburg island");
}

function DrawEarthGuidline(float aLatitude, float aLongitude, byte R, byte G, byte B)
{
	//
	// signs are here
	// http://www.csgnetwork.com/latlongrid.gif
	//
	local Vector lWorldCenter;   // Reference frame center
	local float  lLength;        // Guidline length
	local Vector lGuidline;      // Guidline vector
	local Vector lMeridian;      // Parallel of a point vector
	local Vector lLatitudeAxis;  // Axis that is perpendicular to Meridian and OZ
	local Vector lXAxis;         // X axis of geodesian frame
	local Vector lYAxis;         // Y axis of geodesian frame
	local Vector lZAxis;         // Z axis of geodesian frame
	//local xcGEO_Tile_Earth_Planet  lEarthPL; //Earth object

	//lEarthPL = EarthPL;

	
	GetAxes(EarthPL.Rotation,lXAxis, lYAxis, lZAxis);

	lWorldCenter = class'X_COM_Settings'.default.GEO_WorldCenter;
	lLength = class'X_COM_Settings'.default.GEO_FlyingDistanceFromPlanet + 200;

	//Find longitude rotation
	lMeridian = lXAxis >> QuatToRotator(QuatFromAxisAndAngle(lZAxis, -aLongitude));

	//Find latitude axis
	lLatitudeAxis = lMeridian Cross lZAxis;
		
	//latitude rotation
	lGuidline = lMeridian >> QuatToRotator(QuatFromAxisAndAngle(lLatitudeAxis, aLatitude));

	DrawDebugLine(lWorldCenter, lLength * lGuidline, R,G,B, True);

	//DrawDebugLine(lWorldCenter, lLength * lXAxis, 0,255,0, True);
	//DrawDebugLine(lWorldCenter, lLength * lYAxis, 255,0,0, True);
	//DrawDebugLine(lWorldCenter, lLength * lZAxis, 0,0,255, True);
}

//=============================================================================
// Functions: Moon
//=============================================================================
function CreateMoon()
{
	if (MoonPL == none)
	{
		MoonPL = Spawn(class'xcGEO_Tile_SolarSystem_Moon', Self,'Moon', class'X_COM_Settings'.default.GEO_WorldCenter);
	}
}

//=============================================================================
// Defaultproperties
//=============================================================================
defaultproperties
{
    Name="Default__xcGEO_SolarSystem"
}
