/**
 * X-COM Geosphere game type.. 
 * Uses for GEO-game rules.
 */
class xcGEO_GameInfo extends X_COM_GameInfo;

//=============================================================================
// Variables
//=============================================================================
//var vector                      PlayerStartLocation; // Location of player when he entered game
//var rotator                     PlayerStartRotation; // Rotation of player when he entered game
var float                       DefaultGameSpeed; // Game starts with this game speed. it is default speed = 1.0 seconds
                               
                                /** Game speed for time functions */
var private float               mTimeSpeed;

                                /** World properties and world build functions */
var xcGEO_LevelManager          LevelManager; 

                                /**ufo brain. Brainishe moguchee!!! */
var xcGEO_UFO_Manager           UFOManager; 
                                

var xcGEO_2DMap_Manager         Geo2DMap;

                                /** each spawned air unit comes with its own unique number. This is the counter*/
var int                         LastVehicleNumericalId;

/** Key Value pair that is used in @see DisplayHudDebug @see RemoveHudDebug and HUD DEBUG section of this file*/
struct SHudDebugMessage
{
    /** Identification. key is also used as a title*/
    var string Key;    
    /** value */
    var string Value;
};
/** list of Debug messages (key-values) that will be shown in the hud*/
var array<SHudDebugMessage>       HudDebugMessages; 

//=============================================================================
// Events
//=============================================================================
event InitGame( string Options, out string ErrorMessage )
{
    

    Super.InitGame(Options, ErrorMessage);	
    LevelManager =  Spawn(class'xcGEO_LevelManager',Self); // Create LevelManager
    LevelManager.initLevelManager(self); // Send GameInfo reference to it and init LevelManager
    Geo2DMap = Spawn(class'xcGEO_2DMap_Manager', self);   `log("xcGEO_GameInfo::InitGame:Geo2DMap = "$Geo2DMap);
    
    
}

event PlayerController Login(string Portal, string Options, const UniqueNetID UniqueID, out string ErrorMessage)
{
    local PlayerController NewPlayer;
    // Spawn controller in default location
    NewPlayer = SpawnPlayerController(Vect(0,0,0), Rot(0,0,0)); //spawn without playerstart in map. and set new place in level manager

    if( NewPlayer == None ) // Handle Controller spawn failure.
    {
        `log("Couldn't spawn player controller of class "$PlayerControllerClass);
        ErrorMessage = PathName(WorldInfo.Game.GameMessageClass) $ ".FailedSpawnMessage";
        return None;
    }
    //NewPlayer.GotoState('Geosphere');
    return NewPlayer;
}

event SetGlobalTime(int aNewTime)
{   
    local Actor lActor;
    local X_COM_SeqEvent_GlobalEvent lEvent;

    //local float lScale;

    //lScale = class'X_COM_Settings'.default.GEO_EarthScale;

    //// planets rotation
    //LevelManager.SolarSystem.SunPL.RotationRate.Yaw = 182 * aNewTime * lScale; //182*360=65536
    //LevelManager.SolarSystem.MoonPL.RotationRate.Yaw = -6 * aNewTime * lScale;
    //LevelManager.SolarSystem.EarthClouds.RotationRate.Yaw = 91 * aNewTime * lScale;

    // game timers speed
    mTimeSpeed = aNewTime;

    lEvent = new(self)class'X_COM_SeqEvent_GlobalEvent';
    lEvent.GlobalEventName = EGE_TimeSync;

    foreach Worldinfo.AllActors(class'Actor', lActor)
    {
        if (lActor != none) lActor.ReceivedNewEvent(lEvent);
    }
}


/** put X,Y,Z level coordinates as aPointVect and get latitude, longitude and elevation of earth */
function DecartToGeographic(Vector aPointVect, out float aLatitude, out float aLongitude, out float aElevation)
{	
    local Vector lMeridian;      // Parallel of a point vector
    local Vector lXAxis;         // X axis of geodesian frame
    local Vector lYAxis;         // Y axis of geodesian frame
    local Vector lZAxis;         // Z axis of geodesian frame
    local float  lCosZV;         // Cos between aPointVect and earth lZAxis
    local float  lCosXM;         // Cos between lMeridian  and earth lXAxis
    
    GetAxes(LevelManager.SolarSystem.EarthPL.Rotation, lXAxis, lYAxis, lZAxis);

    //Elevation
    aElevation = VSize(aPointVect);

    //Latitude
    lCosZV = Normal(lZAxis) Dot Normal(aPointVect);
    aLatitude = (Pi/2.0) - Acos(lCosZV);

    //Longitude
    lMeridian = aPointVect Cross lZAxis;
    //lCosXM = Normal(lXAxis) Dot Normal(lMeridian Cross lZAxis);
	lCosXM = Normal(lXAxis) Dot Normal(lZAxis Cross lMeridian);
    aLongitude = Acos(lCosXM);

    //we know aLongitude but we don't knot longitude sign. To know it we have to look at the angle between OY and our vector
	lCosXM =  Acos(Normal(lYAxis) Dot Normal(aPointVect));
    if(lCosXM<Pi/2.0) aLongitude = -aLongitude;
}


/** Put latitude, longitude and elevation of earth and obtain X,Y,Z level coordinates through out Vector aPointVect */
function GeographicToDecart(float aLatitude, float aLongitude, float aElevation, out Vector aPointVect)
{	
    local Vector lGuidline;      // Guidline vector
    local Vector lMeridian;      // Parallel of a point vector
    local Vector lLatitudeAxis;  // Axis that is perpendicular to Meridian and OZ
    local Vector lXAxis;         // X axis of geodesian frame
    local Vector lYAxis;         // Y axis of geodesian frame
    local Vector lZAxis;         // Z axis of geodesian frame
    
    GetAxes(LevelManager.SolarSystem.EarthPL.Rotation, lXAxis, lYAxis, lZAxis);
	

    //Find longitude rotation
    lMeridian = lXAxis >> QuatToRotator(QuatFromAxisAndAngle(lZAxis, -aLongitude));

    //Find latitude axis
    lLatitudeAxis = lMeridian Cross lZAxis;
        
    //latitude rotation
    lGuidline = lMeridian >> QuatToRotator(QuatFromAxisAndAngle(lLatitudeAxis, aLatitude));

    //use length
    aPointVect = Normal(lGuidline)*aElevation;
}

//=============================================================================
// Functions: Global
//=============================================================================
function float GetGameSpeed()
{
    return mTimeSpeed;
}

//=============================================================================
// Functions
//=============================================================================
function StartMatch()
{
    LevelManager.BuildWorld(); // Build game world
    UFOManager = Spawn(class'xcGEO_UFO_Manager',Self); // Create UFOManager
    SetGameSpeed(DefaultGameSpeed);
    super.StartMatch();
	RunTests();
}



//=============================================================================
// HUD DEBUG MESSAGES
//=============================================================================

/** Add persistant(!) green message to the hood
 *  
 *  The idea of this functionality is that sometimes it is 
 *  extreemly usefull to visualize some parameters in the hud. 
 *  To remove message use @see HudRemoveDebugMessage with the same title
 *  
 *  @example.
 *  If you put somewere in your code:
 *  
 *  lGameInfo.HudDebugMessage("Speed", "341")
 *  lGameInfo.HudDebugMessage("Speed", "7500")
 *  
 *  lGameInfo.HudDebugMessage("Sound", "Great")
 *  
 *  You will get in the hood:
 *     Speed 7500
 *     Sound Great
 *     
 *  @relates  HudRemoveDebugMessage 
 *  @see   
 **/
function DisplayHudDebug(string aTitle, string aMessage)
{
    local int il;
    local SHudDebugMessage lKeyValue;  //Our message that is actually key-value pair

    //search a key in the array 
    il = HudDebugMessages.Find('Key', aTitle);

    if (il == -1) //didnt find this key-title string
    {
        //So add it to the array
        lKeyValue.Key = aTitle;
        lKeyValue.Value = aMessage;
        HudDebugMessages.AddItem(lKeyValue);
    }
    else 
    {
        // found a message, change its containts 
        HudDebugMessages[il].Value = aMessage;
    }
}

/** Removes debug message added by @see HudDebugMessage from the hud 
 *  
**/
function RemoveHudDebug(string aTitle)
{
    local int il;

    //search a key in the array 
    il = HudDebugMessages.Find('Key', aTitle);

    if (il != -1) //find this key-title message
    {
        HudDebugMessages.Remove(il,1);
    }
}

/** Removes all debug messages*/
function ClearHudDebug()
{
    HudDebugMessages.Length = 0;
}


//=============================================================================
// SAVE GAME FUNCTION: world properties should be saved in gameplay DB
//=============================================================================
/** Flush main world properties in game play DB in memory */ 
function SaveWorldProperties()
{ 
    local string lQuery;
    local xcGEO_PlayerController lxcPC;
    local string lDATE;
    local string lTIME;
    local int lFOUNDS;
    local Vector lGEO_LOCATION;
    local Rotator lGEO_ROTATION;	
    local Rotator lSUN_ROTATION;
    local XCOMDB_Manager lDatabaseMgr;
    local XCOMDB_DLLAPI lDLLAPI;

    lDatabaseMgr = getDBMgr();
    lDLLAPI = lDatabaseMgr.getDLLAPI();

    lxcPC = xcGEO_PlayerController(GetPlayerController());

    lDATE = "2010-10-10"; // UI. in-game date
    lTIME = "20:20:20"; // UI. in-game time
    lFOUNDS = 1000; // UI. in-game money
    lGEO_LOCATION = lxcPC.Location;
    lGEO_ROTATION = lxcPC.Rotation;

    lSUN_ROTATION = LevelManager.SolarSystem.SunPL.Rotation;

    lDLLAPI.SQL_selectDatabase(lDatabaseMgr.mGameplayDatabaseIdx);
    lQuery = "UPDATE GEO_DATA SET Date = '"$lDATE$"', Time = '"$lTIME$"', Founds = '"$lFOUNDS$"', Location = '"$lGEO_LOCATION$"', Rotation = '"$lGEO_ROTATION$"', Sun_Rotation = '"$lSUN_ROTATION$"' WHERE ID = 0;";
    if (!lDLLAPI.SQL_queryDatabase(lQuery)) `warn(" Something goes wrong when saving world properties");
}


//=============================================================================
// unit tests
//=============================================================================

function RunTests()
{
	local float  lLength;        // Guidline length
	local Vector lPointVect;
	local Vector lVerifyVect;
	local float  lLatitude;        // Guidline length
	local float  lLongitude;        // Guidline length
	local float  lElevation;        // Guidline length

	lLength = class'X_COM_Settings'.default.GEO_FlyingDistanceFromPlanet + 200;
	

	`utAssertTrue(True, "This is sample true/false assertion");
    //Melbourne
	GeographicToDecart(-37.796763*DegToRad,  144.9645996*DegToRad, lLength, lPointVect);
	lVerifyVect = vect( -0.647213, -0.172137, -0.742620);
	`utAssertVectorAlmostEqual(lPointVect, lLength*lVerifyVect, 0.001, "GeographicToDecart test 1 Melbourne	");

	DecartToGeographic(lPointVect, lLatitude, lLongitude, lElevation);

	`utAssertAlmostEqual(lLatitude, -37.796763*DegToRad, 0.001, "DecartToGeographic test 1  Melbourne Latitude");
	`utAssertAlmostEqual(lLongitude, 144.9645996*DegToRad, 0.001, "DecartToGeographic test 1 Melbourne Longitude");
	`utAssertAlmostEqual(lElevation, lLength, 0.001, "DecartToGeographic test 1 Melbourne Elevation");

     //Tokio
	 GeographicToDecart(35.68225890670*DegToRad,  139.7620582580*DegToRad, lLength, lPointVect);
	lVerifyVect = vect(  -0.620233, -0.713354, 0.326248);
	`utAssertVectorAlmostEqual(lPointVect, lLength*lVerifyVect, 0.001, "GeographicToDecart test 2 Newport News");

	DecartToGeographic(lPointVect, lLatitude, lLongitude, lElevation);

	`utAssertAlmostEqual(lLatitude, 35.68225890670*DegToRad, 0.001, "DecartToGeographic test 2 Newport News Latitude");
	`utAssertAlmostEqual(lLongitude, 139.7620582580*DegToRad, 0.001, "DecartToGeographic test 2 Newport News Longitude");
	

    //DrawEarthGuidline(35.68225890670*DegToRad,  139.7620582580*DegToRad,    255, 255, 0);
    //lGameInfo.DisplayHudDebug("Yellow", "Lat:35.7  Lng:139.8  Tokio");
    //X = -0.620233
    //Y = -0.713354
    //Z = 0.326248


	//Newport News
    GeographicToDecart(37.08941820666*DegToRad,  -76.4730834960*DegToRad, lLength, lPointVect);
	lVerifyVect = vect(  0.186934, 0.471635, 0.861751);
	`utAssertVectorAlmostEqual(lPointVect, lLength*lVerifyVect, 0.001, "GeographicToDecart test 2 Newport News");

	DecartToGeographic(lPointVect, lLatitude, lLongitude, lElevation);

	`utAssertAlmostEqual(lLatitude, 37.08941820666*DegToRad, 0.001, "DecartToGeographic test 2 Newport News Latitude");
	`utAssertAlmostEqual(lLongitude, -76.4730834960*DegToRad, 0.001, "DecartToGeographic test 2 Newport News Longitude");
	


    //lGameInfo.DisplayHudDebug("Purple", "Lat:37.1  Lng:-76.5  Newport News");
    //X = 0.186934
    //Y = 0.471635
    //Z = 0.861751


}   
//=============================================================================
// Default properties
//=============================================================================
defaultproperties
{
    DefaultGameSpeed=1.0; //0 = 1 seconds time i think. it needs to be tested when we will have UI scene gameplay interface.
    //PlayerStartLocation = (X=4000,Y=0,Z=0)  //camera location from center. Earth is center. Earth Radius=2000 //now get from DB
    //PlayerStartRotation = (Pitch=0,Yaw=32768,Roll=0) //camera rotation. turn camera to earth //now get from DB

    PlayerControllerClass=class'X-COM_Geo.xcGEO_PlayerController'
    HUDType = class'X-COM_Geo.xcGEO_HUD'

    Name="Default__xcGEO_GameInfo"
}