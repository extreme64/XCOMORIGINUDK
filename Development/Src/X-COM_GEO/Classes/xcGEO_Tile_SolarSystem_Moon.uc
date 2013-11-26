/**
 * Moon tile class
 * Uses for moon planet in GEO
 */
class xcGEO_Tile_SolarSystem_Moon extends X_COM_Tile;

var xcGEO_GameInfo mGameInfo;

function PostBeginPlay()
{
	super.PostBeginPlay();
	mGameInfo = xcGEO_GameInfo(Worldinfo.Game);
}

event Tick(float aDeltaTime)
{
	super.Tick(aDeltaTime);
	RotationRate.Yaw = default.RotationRate.Yaw * mGameInfo.GetGameSpeed();
}

//=============================================================================
// DefaultProperties
//=============================================================================
defaultproperties
{
	PrePivot = (X=7688,Y=0,Z=-250)
    Physics = PHYS_Rotating
    RotationRate = (Pitch=0, Yaw=-6, Roll=0) //1 degrees = DegToUnrRot = 182.0444
	//Rotation = (Pitch=0, Yaw=11265, Roll=1216) //Yaw=61.88° = 11264,91022222216
	//Location = (X=0,Y=0,Z=0)

	bHardAttach = TRUE

	CollisionType=COLLIDE_BlockAll

	bCollideActors = TRUE
	bBlockActors = TRUE
	//bCollideWorld = TRUE
	BlockRigidBody = TRUE
	bWorldGeometry = TRUE

	Begin Object Name=xcTileMesh
		StaticMesh = StaticMesh'xcMoon.Meshes.xcMoon'
		AlwaysCheckCollision = TRUE

		bAcceptsLights = FALSE // for our custom light
		bAcceptsDynamicLights = FALSE // for our custom light
		bForceDirectLightMap = FALSE // for our custom light

		bAllowAmbientOcclusion = TRUE
		bAllowApproximateOcclusion = TRUE
 	 
		bForceMipStreaming = TRUE	

		CastShadow = FALSE // for our custom light
		bCastDynamicShadow = FALSE // for our custom light
		bCastHiddenShadow = FALSE // for our custom light
		bUsePrecomputedShadows = FALSE // for our custom light
		bAllowShadowFade = FALSE // for our custom light
		bAcceptsDynamicDominantLightShadows = FALSE // for our custom light
		
		BlockRigidBody=TRUE
		BlockActors=TRUE
		BlockZeroExtent=TRUE
		BlockNonZeroExtent=TRUE
		CollideActors = TRUE

		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE,Untitled3=TRUE, Pawn=TRUE)
    End Object
}
