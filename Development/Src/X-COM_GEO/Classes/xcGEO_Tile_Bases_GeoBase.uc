/**
 * GEO X-com base tile class  
 * Uses for x-com bases placed on planet
 */
class xcGEO_Tile_Bases_GeoBase extends X_COM_Tile;

//=============================================================================
// Variables: General
//=============================================================================
var int BaseID; // ID in DB
var string BaseName; // UI base name
var ERegions Region; // Region in Earth map. If planet is not earht then none

//=============================================================================
// DefaultProperties
//=============================================================================
defaultproperties
{
	CollisionType=COLLIDE_BlockAll

	bCollideActors = TRUE

	Begin Object Name=xcTileMesh    
		AlwaysCheckCollision = TRUE

		bAcceptsLights = TRUE
		bAcceptsDynamicLights = TRUE
		bForceDirectLightMap = TRUE

		bAcceptsDecals = TRUE
		bAcceptsDynamicDecals = TRUE
		bAcceptsStaticDecals = TRUE
		bAcceptsDecalsDuringGameplay = TRUE
		bAllowDecalAutomaticReAttach = TRUE  

		bAllowAmbientOcclusion = TRUE
		bAllowApproximateOcclusion = TRUE
		bAllowCullDistanceVolume = TRUE   
	 
		bForceMipStreaming = TRUE	

		BlockZeroExtent=TRUE
		BlockNonZeroExtent=TRUE

		CollideActors = TRUE
    End Object
}
