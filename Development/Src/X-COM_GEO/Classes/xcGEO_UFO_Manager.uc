/**
 * GEO UFO controller. 
 * Uses for UFO brain
 */
class xcGEO_UFO_Manager extends Actor;

//=============================================================================
// Variables: General
//=============================================================================
var array<X_COM_Vehicle_AirVehicle_Alien>           UFOsInAir;
var array<X_COM_Tile_AlienEvent>      AlienEvents; //crashes, terrors, bases
var int Index;
var int UFOSpawnQuantity;

//=============================================================================
// Functions: General
//=============================================================================
simulated function PostBeginPlay()
{
	super.PostBeginPlay();	
}

//=============================================================================
// Functions: Gameplay
//=============================================================================
function X_COM_Vehicle_AirVehicle_Alien SpawnUfo(vector aSpawnLocation, rotator aSpawnRotation)
{
	local X_COM_Vehicle_AirVehicle_Alien	lVehicle;

	lVehicle = Spawn(class'X_COM_Settings'.default.AlienAirVehicles[EAAV_UFO].Class, self, ,aSpawnLocation, aSpawnRotation, class'X_COM_Settings'.default.AlienAirVehicles[EAAV_UFO],false);

	lVehicle.Mesh.SetScale(0.5);
	lVehicle.NumericalId = ++xcGEO_GameInfo(WorldInfo.Game).LastVehicleNumericalId; //Add last ID
	return lVehicle;
}

function NotifyUfoDetected() //TODO: make notification in scaleform menu
{
	local xcGEO_GameInfo lGameInfo;
	local xcGEO_PlayerController lPC;
	lGameInfo = xcGEO_GameInfo(WorldInfo.Game);
	lPC = xcGEO_PlayerController(lGameInfo.GetPlayerController());
	xcGEO_HUD(lPC.myHud).HUD_Planet.AddNewEvent("UFO DETECTED!");
//	lPC.HUD_Planet.mOBJ_UFO_Lite.SetPosition(100, 500);
}

function NotifyUfoLost() //TODO: make notification in scaleform menu
{
	local xcGEO_GameInfo lGameInfo;
	local xcGEO_PlayerController lPC;
	lGameInfo = xcGEO_GameInfo(WorldInfo.Game);
	lPC = xcGEO_PlayerController(lGameInfo.GetPlayerController());
	xcGEO_HUD(lPC.myHud).HUD_Planet.AddNewEvent("UFO LOST!");
}

//=============================================================================
// States: 
//=============================================================================
/** Main game state. **/
AUTO state MainGeoGame
{
	function AddUfoToMap(int Quantity)
	{
		local Vector            lLocation;
		local Rotator           lRotation;
		local X_COM_Vehicle_AirVehicle_Alien  lUfo;
		local int li;

		for (li=0; li<Quantity; li++)
		{
			lLocation = class'xcGEO_Defines'.static.GetOrbitalLocation(Vrand());
			lRotation = class'xcGEO_Defines'.static.GetOrbitalRotation(lLocation);
			lUfo = SpawnUfo(lLocation, lRotation);
			lUfo.StartEngine();
			lUfo.controller.GotoState('Discovering');
			UFOsInAir.AddItem(lUfo);
			xcGEO_AIController_Alien(lUfo.controller).SetUFOManager(self);
			//NotifyUfoDetected();
		}
	}

	function RemoveUfoFromMap()
	{
		if ( (UFOsInAir[0] != none) && (UFOsInAir[0].Controller != none) )
		{
			UFOsInAir[0].Controller.Destroy();
			UFOsInAir[0].Destroy();
			UFOsInAir.Remove(0, UFOsInAir.Length);
		}
	}

Begin:
	Sleep(5);

	UFOSpawnQuantity = 5; //Rand(50);

	AddUfoToMap(UFOSpawnQuantity);

	Sleep(30);

	for (Index=0; Index<UFOSpawnQuantity; Index++)
	{
		if ( (UFOsInAir[Index] != none) && (UFOsInAir[Index].Controller != none) )
		{
			xcGEO_AIController(UFOsInAir[Index].controller).MoveToPosition(class'xcGEO_Defines'.static.GetOrbitalLocation(Vrand()));
			Sleep(Frand());
			//while( (UFOsInAir[Index] != none) && (UFOsInAir[Index].Controller != none) && (!xcGEO_AICommand_Cmd_MoveToPosition(xcGEO_AIController(UFOsInAir[Index].controller).GetActiveCommand()).DestinationIsReached)) Sleep(WorldInfo.DeltaSeconds);
		}
	}

	//NotifyUfoLost();
	//RemoveUfoFromMap();
	Sleep(60);
	goto('Begin');

End:
}

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
	Name="Default__xcGeo_UFO_Manager"
}
