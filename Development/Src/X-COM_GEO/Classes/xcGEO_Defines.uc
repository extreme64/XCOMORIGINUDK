/**
 * X-COM GEO functions and variables class. 
 * Uses to store functions and variables for GEO classes.
 */
class xcGEO_Defines extends X_COM_Defines;

//=============================================================================
// Variables
//=============================================================================
/** Base modules size type */
enum EBaseModuleSizeType
{
	EBMST_1x1,
	EBMST_1x2,
	EBMST_2x2
};

/** Base modules type */
enum EModulesTypes
{
	EMT_None,
	EMT_Lift,
	EMT_ScienceLab,
	EMT_Angar,
    EMT_LiveQuater,
	EMT_Radar,
};

/** Base modules state */
enum EBaseModuleState
{
	EBMS_None,
	EBMS_MouseHolding, // Holded by mouse 
	EBMS_UnderConstruction, 
	EBMS_AtWork 
};

/** Base is located in region on planet Earth */
enum ERegions
{
	ER_None,
	ER_America,
	ER_Russia,
	ER_Egypt,
};

static final function vector GetOrbitalLocation(Vector aLocation)
{
	local Vector            lWorldCenter;
	local Vector            lLocation;
	local float             lDistance;

	lWorldCenter = class'X_COM_Settings'.default.GEO_WorldCenter;
	lDistance = class'X_COM_Settings'.default.GEO_FlyingDistanceFromPlanet;

	lLocation = ClampLength(aLocation, lDistance); //ClampLength( vector V, float MaxLength );
		
	return lWorldCenter - Normal(lWorldCenter - lLocation) * lDistance;
}

static final function Rotator GetOrbitalRotation(Vector aLocation)
{
	local Rotator           lRotation;
	local Vector            lWorldCenter;
	
	lWorldCenter = class'X_COM_Settings'.default.GEO_WorldCenter;
	lRotation = Rotator(lWorldCenter-aLocation);
	lRotation.Pitch += 90.0f * DegToRad * RadToUnrRot;
	return lRotation;
}

static final function vector GetCrashedLocation(Vector aAirLocation)
{
	local Vector            lWorldCenter;
	local float             lDistance;

	lWorldCenter = class'X_COM_Settings'.default.GEO_WorldCenter;
	lDistance = class'X_COM_Settings'.default.GEO_CrashedDistanceFromPlanet;
	
	return lWorldCenter - Normal(lWorldCenter - aAirLocation) * lDistance;
}

//=============================================================================
// Functions
//=============================================================================
/*
final function vector GetBaseGridCoord(vector aLocation, Vector aAttachmentDimensions)
{
	local   vector  lNewLocation;
	local   vector  lBaseGridSize;
	lBaseGridSize = class'X_COM_Settings'.default.Base_GridSize;
	lNewLocation.X = int(aLocation.X / lBaseGridSize.x) * lBaseGridSize.x + aAttachmentDimensions.x/2;
	lNewLocation.Y = int(aLocation.Y / lBaseGridSize.y) * lBaseGridSize.y + aAttachmentDimensions.y/2;
	lNewLocation.Z = lBaseGridSize.z;
	return ChangeLocationInBaseBounds(lNewLocation, aAttachmentDimensions);
}

private function vector ChangeLocationInBaseBounds(vector aNowLocation, Vector aAttachmentDimensions)
{
	local Vector lNewLocation;
	local vector lBaseLocation, lBaseSize;
	lBaseLocation = class'X_COM_Settings'.default.Base_Location;
	lBaseSize = class'X_COM_Settings'.default.Base_Size;
	lNewLocation = aNowLocation;
	if (aNowLocation.x < (lBaseLocation.x + (aAttachmentDimensions.X/2)))     lNewLocation.x = lBaseLocation.x + (aAttachmentDimensions.X/2);
	if (aNowLocation.x > (lBaseLocation.x + lBaseSize.x - (aAttachmentDimensions.X/2)))    lNewLocation.x = lBaseLocation.x + lBaseSize.x - (aAttachmentDimensions.X/2);
	if (aNowLocation.y < (lBaseLocation.y + (aAttachmentDimensions.y/2)))     lNewLocation.y = lBaseLocation.Y + (aAttachmentDimensions.y/2);
	if (aNowLocation.y > (lBaseLocation.y + lBaseSize.y - (aAttachmentDimensions.Y/2)))    lNewLocation.y = lBaseLocation.y + lBaseSize.y - (aAttachmentDimensions.Y/2);
	return lNewLocation;
}

/** Get grid coordinate for module location */
function bool GetBaseGridCoord(vector aLocation, Vector aAttachmentDimensions, EBaseModuleSizeType aModuleSizeType, out vector aGridLocation)
{
	local vector lNewLocation;
	local vector lBaseGridSize;
	lBaseGridSize = class'X_COM_Settings'.default.Base_GridSize;
	lNewLocation.X = int(aLocation.X / lBaseGridSize.x) * lBaseGridSize.x + aAttachmentDimensions.x/2;
	lNewLocation.Y = int(aLocation.Y / lBaseGridSize.y) * lBaseGridSize.y + aAttachmentDimensions.y/2;
	lNewLocation.Z = lBaseGridSize.z;
	return FixModuleLocation(lNewLocation, aAttachmentDimensions, aModuleSizeType, aGridLocation);
}

/** Modules location should be within base bounds and module can be near another module and cannot be above. This function six all of it */
private function bool FixModuleLocation(vector aNowLocation, Vector aAttachmentDimensions, EBaseModuleSizeType aModuleSizeType, out vector aNewLocation)
{
	local bool bCanChangeLocation;
	local Vector lGridLocationX, lGridLocationY;
	bCanChangeLocation = true;
	aNewLocation = ChangeLocationInBaseBounds(aNowLocation, aAttachmentDimensions);
	switch (aModuleSizeType)
	{
		case EBMST_1x1	:   bCanChangeLocation = CheckModuleIsAboveGround(aNewLocation);
		break;
		case EBMST_1x2	:   if (aAttachmentDimensions.X > aAttachmentDimensions.Y)
							{
								lGridLocationX.X = aAttachmentDimensions.X / 4;
								if ((!CheckModuleIsAboveGround(aNewLocation - lGridLocationX)) || (!CheckModuleIsAboveGround(aNewLocation + lGridLocationX))) bCanChangeLocation = false;
							}
							else
							{
								lGridLocationY.Y = aAttachmentDimensions.Y / 4;
								if ((!CheckModuleIsAboveGround(aNewLocation - lGridLocationY)) || (!CheckModuleIsAboveGround(aNewLocation + lGridLocationY))) bCanChangeLocation = false;
							}
		break;
		case EBMST_2x2	:   lGridLocationX.X = aAttachmentDimensions.X / 4;
							lGridLocationY.Y = aAttachmentDimensions.Y / 4;
							if ((!CheckModuleIsAboveGround(aNewLocation - lGridLocationX - lGridLocationY )) || 
								(!CheckModuleIsAboveGround(aNewLocation - lGridLocationX + lGridLocationY )) ||
								(!CheckModuleIsAboveGround(aNewLocation + lGridLocationX + lGridLocationY )) ||
								(!CheckModuleIsAboveGround(aNewLocation + lGridLocationX - lGridLocationY ))) bCanChangeLocation = false;
		break;
	}	
	return bCanChangeLocation;
}

/** Checks if module is above ground and not above another module. */
private function bool CheckModuleIsAboveGround(vector aLocation)
{
	local Actor lActorUnder;
	if (xcGEOPC != none) 
	{
		lActorUnder = xcGEOPC.DoTraceActorUnderLocation(aLocation);
		if (lActorUnder.IsA('xcGEO_Tile_Bases_BuildGround')) return true;
			else if (lActorUnder.IsA('xcGEO_Tile_Bases_Modules')) return false;
	}
}

/** Fix module location within base bounds */
private function vector ChangeLocationInBaseBounds(vector aNowLocation, Vector aAttachmentDimensions)
{
	local Vector lNewLocation;
	local vector lBaseLocation, lBaseSize;
	lBaseLocation = class'X_COM_Settings'.default.Base_Location;
	lBaseSize = class'X_COM_Settings'.default.Base_Size;
	lNewLocation = aNowLocation;
	if (aNowLocation.x < (lBaseLocation.x + (aAttachmentDimensions.X/2)))     lNewLocation.x = lBaseLocation.x + (aAttachmentDimensions.X/2);
	if (aNowLocation.x > (lBaseLocation.x + lBaseSize.x - (aAttachmentDimensions.X/2)))    lNewLocation.x = lBaseLocation.x + lBaseSize.x - (aAttachmentDimensions.X/2);
	if (aNowLocation.y < (lBaseLocation.y + (aAttachmentDimensions.y/2)))     lNewLocation.y = lBaseLocation.Y + (aAttachmentDimensions.y/2);
	if (aNowLocation.y > (lBaseLocation.y + lBaseSize.y - (aAttachmentDimensions.Y/2)))    lNewLocation.y = lBaseLocation.y + lBaseSize.y - (aAttachmentDimensions.Y/2);
	return lNewLocation;
}
*/

//=============================================================================
// Default properties
//=============================================================================
defaultproperties
{
    Name="Default__xcT_Defines"	
}