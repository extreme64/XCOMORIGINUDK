/**
 * Класс тайлов
 * Класс динамических обьектов, которые загружаются в игру
 */
class X_COM_Tile extends DynamicSMActor
	ClassGroup(XCOM)
	notplaceable;

//=============================================================================
// Functions
//=============================================================================
/** Установка нового обьекта для этого класса */
function AddStaticMesh(StaticMesh aNewStaticMesh)
{
	StaticMeshComponent.SetStaticMesh(aNewStaticMesh);
}

/** Установка материала для обьекта этого класса */
function AddStaticMeshWithMaterial(StaticMesh aNewStaticMesh, MaterialInstance aNewMaterial, int aMaterialIndex)
{
	StaticMeshComponent.SetStaticMesh(aNewStaticMesh);
	StaticMeshComponent.SetMaterial(aMaterialIndex,aNewMaterial);
}

//=============================================================================
// Default Properties
//=============================================================================
defaultproperties
{
	Components.Remove(MyLightEnvironment)
	Components.Remove(StaticMeshComponent0)

	bStatic=FALSE
	bNoDelete=FALSE

	CollisionType=COLLIDE_NoCollision
	TickGroup=TG_PostAsyncWork
	Physics=PHYS_None

	bCollideActors = FALSE
	bBlockActors = FALSE
	bAlwaysTick = FALSE
	bCollideWorld = FALSE
	BlockRigidBody = FALSE
	bCanStepUpOn = FALSE
	bWorldGeometry = FALSE

	Begin Object Class=DynamicLightEnvironmentComponent Name=TileLightEnvironment
		bEnabled=TRUE
		AmbientGlow=(R=0.5,G=0.5,B=0.5,A=1.0)
		AmbientShadowColor=(R=0.0,G=0.0,B=0.0)
		//ShadowFadeResolution=16
		//MinShadowResolution=8
		//BouncedLightingFactor=0.0
		bSynthesizeSHLight=FALSE
		LightDistance=48
		ShadowDistance=0
		ModShadowFadeoutExponent=1
		bCastShadows=FALSE
		//ShadowFilterQuality=SFQ_Low
		MinTimeBetweenFullUpdates = 0.3
		bCompositeShadowsFromDynamicLights=TRUE
		bDynamic=TRUE
		MinShadowAngle=0
    End Object
    Components.Add(TileLightEnvironment)
	LightEnvironment=TileLightEnvironment

	Begin Object Class=StaticMeshComponent Name=xcTileMesh    
		LightEnvironment=TileLightEnvironment
		LightingChannels=(Dynamic=TRUE,CompositeDynamic=TRUE)

		AlwaysCheckCollision = FALSE

		bAcceptsLights = FALSE
		bAcceptsDynamicLights = FALSE
		bForceDirectLightMap = FALSE

		bAcceptsDecals = FALSE
		bAcceptsDynamicDecals = FALSE
		bAcceptsStaticDecals = FALSE
		bAcceptsDecalsDuringGameplay = FALSE
		bAllowDecalAutomaticReAttach = FALSE  

		bAllowAmbientOcclusion = FALSE
		bAllowApproximateOcclusion = FALSE
		bAllowCullDistanceVolume = FALSE   
	 
		bForceMipStreaming = FALSE	

		CastShadow = FALSE
		bCastDynamicShadow = FALSE
		bCastHiddenShadow = FALSE
		bUsePrecomputedShadows = FALSE
		bAllowShadowFade = FALSE
		bAcceptsDynamicDominantLightShadows = FALSE
		
		bDisableAllRigidBody = FALSE
		BlockRigidBody = FALSE
		BlockActors = FALSE
		BlockZeroExtent = FALSE
		BlockNonZeroExtent = FALSE
		CollideActors = FALSE

		DepthPriorityGroup=SDPG_World

		RBCollideWithChannels=(Default=FALSE,BlockingVolume=FALSE,GameplayPhysics=FALSE,EffectPhysics=FALSE,Vehicle=FALSE,Untitled3=FALSE, Pawn=FALSE)
    End Object
	CollisionComponent=xcTileMesh
	StaticMeshComponent=xcTileMesh
    Components.Add(xcTileMesh)

	bCanBeDamaged = FALSE
}
