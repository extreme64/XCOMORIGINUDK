/**
 * Класс погодных эффектов.
 * Туман стелящийся по земле
 */
class xcT_Weather_Fog_Linear extends FogVolumeLinearHalfspaceDensityInfo
	notplaceable;

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{  
	Components.Remove(FogVolumeComponent0)

	Begin Object Name=FogVolumeComponent0
		DefaultFogVolumeMaterial = Material'FX_Weather.Fog.Materials.Fog_Master'
		//FogMaterial = MaterialInstanceTimeVarying'xcT_Weather.Fog.Materials.Fog_Master_INST'
		SimpleLightColor=(R=1,G=1,B=1,A=1.0)
	End Object
	DensityComponent=FogVolumeComponent0
	Components.Add(FogVolumeComponent0)
	
	bStatic=False
	bNoDelete=FALSE

	DrawScale3D = (x=40,y=40,z=1)

	Name="Default__xcT_Weather_Fog_Linear"
}