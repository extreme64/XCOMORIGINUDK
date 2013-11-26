/**
 * Solar system tile class
 * Uses for planets, earth and etc.
 */
class xcGEO_Tile_SolarSystem extends X_COM_Tile;

//=============================================================================
// DefaultProperties
//=============================================================================
defaultproperties
{
	CollisionType=COLLIDE_BlockAll

	bCollideActors = TRUE
	bBlockActors = TRUE
	BlockRigidBody = TRUE
	bWorldGeometry = TRUE

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
