/**
 * Base modules tile class 
 * Uses for all base modules in GEO mode.
 */
class xcGEO_Tile_Bases_Modules extends X_COM_Tile;

//=============================================================================
// Variables:
//=============================================================================
var bool bCanBePlaced; // can module be placed and build in this place
var bool bCanBeMoved;

var private EBaseModuleState ModuleState;

var EModulesTypes ModuleType;

//=============================================================================
// Functions: setup
//=============================================================================
function public SetModuleState(EBaseModuleState aModuleState)
{
	ModuleState = aModuleState;
}

/** Add static mesh based on module type */
function public AddStaticMeshFromType()
{
	local String lStaticMeshPath;

	switch (ModuleType)
	{
		case EMT_Lift           :   lStaticMeshPath = "xc_Test_Modules.Meshes.xcmLift";
		break;
		case EMT_ScienceLab     :   lStaticMeshPath = "xc_Test_Modules.Meshes.xcmLaboratory_Big";
		break;
		case EMT_Angar          :   lStaticMeshPath = "xc_Test_Modules.Meshes.xcmHangar";
		break;

	}	
	SetStaticMesh(StaticMesh(DynamicLoadObject(lStaticMeshPath,class'StaticMesh')));
}
//=============================================================================
// Events: when placing 
//=============================================================================
/** Module can be placed only if it is near to another built and active module. */
event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	super.Touch(Other, OtherComp, HitLocation, HitNormal);
	if (ModuleState == EBMS_MouseHolding) bCanBePlaced = true;
}

/** Module can not be placed only if it is not near to another built and active module. */
event UnTouch( Actor Other )
{
	super.UnTouch(Other);
	if (ModuleState == EBMS_MouseHolding) bCanBePlaced = false;
}

//=============================================================================
// Functions: Placing functions
//=============================================================================
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

//=============================================================================
// Functions: Correction functions
//=============================================================================
function public  bool CheckCorrectPlacing(Vector aAttachmentDimensions, EBaseModuleSizeType aModuleSizeType)
{
	return FixModuleLocation(Location, aAttachmentDimensions, aModuleSizeType);
}

/** Modules location should be within base bounds and module can be near another module and cannot be above. This function six all of it */
private function bool FixModuleLocation(vector aNewLocation, Vector aAttachmentDimensions, EBaseModuleSizeType aModuleSizeType)
{
	local bool bCanChangeLocation;
	local Vector lGridLocationX, lGridLocationY;
	bCanChangeLocation = true;
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
	lActorUnder = DoTraceActorUnderLocation(aLocation);
	if (lActorUnder.IsA('xcGEO_Tile_Bases_BuildGround')) return true;
		else if (lActorUnder.IsA('xcGEO_Tile_Bases_Modules')) return false;
}

/** Trace actor with his class under location **/
function Actor DoTraceActorUnderLocation(vector aTraceLocation)
{
	local Vector lHitLocation, lHitNormal;
	local Vector lTraceStart, lTraceEnd;//, lTraceDir;	
	local Actor lActor;

	lTraceStart = aTraceLocation;
	lTraceStart.Z = class'X_COM_Settings'.default.Base_GridSize.Z*2;
	lTraceEnd = aTraceLocation;
	lTraceEnd.z = -32;

	lActor = Trace(lHitLocation, lHitNormal, lTraceEnd, lTraceStart); 

	if(lActor != none)
	{
		return lActor;
	}
	return none;
}

//=============================================================================
// DefaultProperties
//=============================================================================
defaultproperties
{
	//CollisionType=COLLIDE_BlockAll
	CollisionType=COLLIDE_TouchAll

	bCollideActors = TRUE
	bBlockActors = TRUE
	//bCollideWorld = TRUE
	BlockRigidBody = TRUE
	bWorldGeometry = TRUE

	Begin Object Name=xcTileMesh    
		AlwaysCheckCollision = TRUE

		bAcceptsLights = TRUE
		bAcceptsDynamicLights = TRUE
		bForceDirectLightMap = TRUE

		bAllowAmbientOcclusion = TRUE
		bAllowApproximateOcclusion = TRUE
 	 
		bForceMipStreaming = TRUE	

		CastShadow = TRUE
		bCastDynamicShadow = TRUE
		bCastHiddenShadow = TRUE
		bUsePrecomputedShadows = TRUE
		bAllowShadowFade = TRUE
		bAcceptsDynamicDominantLightShadows = TRUE
		
		BlockRigidBody=TRUE
		BlockActors=TRUE
		BlockZeroExtent=TRUE
		BlockNonZeroExtent=TRUE
		CollideActors = TRUE

		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE,Untitled3=TRUE, Pawn=TRUE)
    End Object

	bCanBePlaced = false
	bCanBeMoved = false
	ModuleState = EBMS_None
}
