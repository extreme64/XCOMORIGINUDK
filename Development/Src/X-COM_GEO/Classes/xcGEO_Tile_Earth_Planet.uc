/**
 * Planet tile class
 * 
 */
class xcGEO_Tile_Earth_Planet extends xcGEO_Tile_Earth;

var array<MaterialInstanceConstant>         EarthMats;

public function MakeInstancedEarth()
{
	local MaterialInstanceConstant lMatInst;
	local int lCount, il;

	lCount = StaticMeshComponent.GetNumElements();

	for(il=0; il<lCount; il++)
	{
		lMatInst = new(None) Class'MaterialInstanceConstant';
		lMatInst.SetParent(StaticMeshComponent.GetMaterial(il));
		StaticMeshComponent.SetMaterial(il, lMatInst);
		EarthMats.AddItem(lMatInst);
	}
}

event Tick(float aDeltaTime)
{
	super.Tick(aDeltaTime);
	SetEarthLightVector(GetLightVector());
}

function Vector GetLightVector()
{
	local vector lSunLoc, lLightVec;

	lSunLoc = Vector(xcGEO_Factory_SolarSystem(Owner).SunPL.Rotation);
	lLightVec = Normal(Location - lSunLoc);

	return lLightVec;
}

function SetEarthLightVector(Vector aLightVec)
{
	local int il;
	local LinearColor lParam;

	lParam.R = aLightVec.X;
	lParam.G = aLightVec.Y;
	lParam.B = aLightVec.Z;
	lParam.A = 1.0;

	for(il=0; il < EarthMats.Length; il++)
	{
		EarthMats[il].SetVectorParameterValue('LightVector', lParam);
	}
}

//=============================================================================
// DefaultProperties
//=============================================================================
defaultproperties
{
	Begin Object Name=xcTileMesh    
		bAcceptsLights = FALSE // for our custom light
		bAcceptsDynamicLights = FALSE // for our custom light
		bForceDirectLightMap = FALSE // for our custom light

		bAcceptsDecals = TRUE
		bAcceptsDynamicDecals = TRUE
		bAcceptsStaticDecals = TRUE
		bAcceptsDecalsDuringGameplay = TRUE
		bAllowDecalAutomaticReAttach = TRUE  

		bAllowAmbientOcclusion = TRUE
		bAllowApproximateOcclusion = TRUE
		bAllowCullDistanceVolume = TRUE   
	 
		bForceMipStreaming = TRUE	

		CastShadow = FALSE // for our custom light
		bCastDynamicShadow = FALSE // for our custom light
		bCastHiddenShadow = FALSE // for our custom light
		bUsePrecomputedShadows = FALSE // for our custom light
		bAllowShadowFade = FALSE // for our custom light
		bAcceptsDynamicDominantLightShadows = FALSE // for our custom light
		
		RBCollideWithChannels=(Default=TRUE, BlockingVolume=TRUE, GameplayPhysics=TRUE, EffectPhysics=TRUE, Vehicle=TRUE,Untitled3=TRUE, Pawn=TRUE, DeadPawn=TRUE)
    End Object
}
