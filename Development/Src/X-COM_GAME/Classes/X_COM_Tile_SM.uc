/**
 * xcT_Tile_StaticMeshTile
 * Denamic objects for Tactics
 */
class X_COM_Tile_SM extends X_COM_Tile
	placeable;

//=============================================================================
// Functions
//=============================================================================
/** Установка материала для обьекта этого класса */
function SetInstancedMaterial(int aMaterialIndex, MaterialInstance aNewMaterial)
{
	StaticMeshComponent.SetMaterial(aMaterialIndex, aNewMaterial);	
}

/** Установка обьекта для этого класса */
function AddStaticMesh(StaticMesh aNewStaticMesh)
{
	StaticMeshComponent.SetStaticMesh(aNewStaticMesh);
}

//=============================================================================
// Default Properties
//=============================================================================
defaultproperties
{
	CollisionType=COLLIDE_BlockAll

	bCollideActors = TRUE
	bBlockActors = TRUE
	//bCollideWorld = TRUE
	BlockRigidBody = TRUE
	bCanStepUpOn = TRUE
	//bWorldGeometry = TRUE

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
		bUsePrecomputedShadows = TRUE
		bAllowShadowFade = TRUE
		bAcceptsDynamicDominantLightShadows = TRUE
		
		BlockRigidBody = TRUE
		BlockActors = TRUE
		BlockZeroExtent = TRUE
		BlockNonZeroExtent = TRUE
		CollideActors = TRUE

		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE,Untitled3=TRUE, Pawn=TRUE)
    End Object
}
