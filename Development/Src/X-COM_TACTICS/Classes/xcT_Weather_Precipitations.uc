/**
 * Класс погодных эффектов - осадков.
 * Дождь, снег... и т.д.
 */
class xcT_Weather_Precipitations extends DynamicSMActor
	notplaceable;

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
	Components.Remove(StaticMeshComponent0)

    Begin Object Class=StaticMeshComponent Name=xcPrecipitations
        //StaticMesh=StaticMesh'xcT_Weather.Rain.Meshs.Rain'	
		//StaticMesh=StaticMesh'xcT_Weather.Snow.Meshs.Snow'

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
	 
		bForceMipStreaming = TRUE	

		CastShadow = FALSE;
		bCastDynamicShadow = FALSE
		bCastHiddenShadow = FALSE
		bUsePrecomputedShadows = FALSE
		bAllowShadowFade = FALSE
		bAcceptsDynamicDominantLightShadows = FALSE
		
		bDisableAllRigidBody = TRUE
		BlockRigidBody = FALSE
		BlockActors = FALSE
		CollideActors = FALSE

		DepthPriorityGroup=SDPG_World
    End Object
	CollisionComponent=xcPrecipitations
	StaticMeshComponent=xcPrecipitations
    Components.Add(xcPrecipitations)

	CollisionType=COLLIDE_NoCollision

	bStatic=FALSE
	bNoDelete=FALSE
	bCollideActors=FALSE
	bBlockActors=FALSE

	Name="Default__xcT_Weather_Precipitations"
}