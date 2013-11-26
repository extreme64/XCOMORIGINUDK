/**
 * Solar system tile class
 * Uses for planets, sun and etc.
 */
class xcGEO_Tile_SolarSystem_Sun extends X_COM_Tile;

//var LensFlareComponent sLens;

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
	PrePivot = (X=13500,Y=0,Z=0)
    Physics = PHYS_Rotating
    RotationRate = (Pitch=0, Yaw=182, Roll=0) //1 degrees = DegToUnrRot = 182.0444
	//Rotation = (Pitch=0, Yaw=32768, Roll=0)
	//Location = (X=0,Y=0,Z=0)

	bHardAttach = TRUE

	//Begin Object Class=DominantDirectionalLightComponent Name=SunLights
	//	//radius = 15000
	//	//LightBrightness
	//	//LightColor=(R=255,G=255,B=255)
	//	CastDynamicShadows = true
	//	//InnerConeAngle = 8
	//	//OuterConeAngle = 10
	//	//FalloffExponent = 1
 //   End Object
 //   Components.Add(SunLights)
	
	Begin Object Class=LensFlareComponent Name=SunLens
		Template=LensFlare'xcSun.Lensflares.Flare.xcSun_LFE'
		DepthPriorityGroup=SDPG_Foreground
		Radius=13500.0
		LightingChannels=(bInitialized=True,Dynamic=True)
    End Object
	//sLens = SunLens
    Components.Add(SunLens)
}
