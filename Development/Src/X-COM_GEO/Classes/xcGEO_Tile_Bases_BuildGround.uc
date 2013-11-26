/**
 * Ground tile class
 * Uses to build bases on this ground in GEO
 */
class xcGEO_Tile_Bases_BuildGround extends X_COM_Tile;

//=============================================================================
// DefaultProperties
//=============================================================================
defaultproperties
{
	CollisionType=COLLIDE_BlockAll

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
}
