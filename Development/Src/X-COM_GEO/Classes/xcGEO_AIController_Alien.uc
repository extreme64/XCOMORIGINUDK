/**
 * GEO AI controller. 
 * Uses for aircrafts
 */
class xcGEO_AIController_Alien extends xcGEO_AIController;

//=============================================================================
// Variables
//=============================================================================
var xcGEO_UFO_Manager UFOManager;

//=============================================================================
// Functions
//=============================================================================
public function SetUFOManager(xcGEO_UFO_Manager aManager)
{
	UFOManager = aManager;
}

function PawnDied(Pawn inPawn)
{
	super.PawnDied(inPawn);

	UFOManager.UFOsInAir.RemoveItem(inPawn);

	if (!IsItSeaAt(inPawn.Location))
	{
		//SetTimer(1.0, false, 'MakeCrashEvent');
		MakeCrashEvent();
	}
}

private function MakeCrashEvent() // ”становить место крушени€ на поверхность планеты
{
	local X_COM_Tile_AlienEvent  lCrashSiteTile;
	local Vector            lLocation;
	local Rotator           lRotation;
	local Vector            lWorldCenter;

	lWorldCenter = class'X_COM_Settings'.default.GEO_WorldCenter;
	lLocation = lWorldCenter - Normal(lWorldCenter - Location) * class'X_COM_Settings'.default.GEO_EarthPlanetRadius;
	lRotation = Rotator(lWorldCenter-Location);
	lRotation.Pitch += 90.0f * DegToRad * RadToUnrRot;
	lCrashSiteTile = spawn(class'X_COM_Settings'.default.AlienEvents[EAET_CrashSite].Class, UFOManager, 'CrashSite', lLocation, lRotation, class'X_COM_Settings'.default.AlienEvents[EAET_CrashSite], true);
	UFOManager.AlienEvents.AddItem(lCrashSiteTile);	
}

private function bool IsItSeaAt(vector aLocation)
{
	return false; //class'xcGEO_2DMap_Manager'.static.IsItSea(aLocation);
}

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
	Name="Default__xcGeo_AIController_Alien"
}
