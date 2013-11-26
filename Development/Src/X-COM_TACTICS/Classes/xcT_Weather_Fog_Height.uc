/**
 * Класс погодных эффектов.
 * Высотный туман
 */
class xcT_Weather_Fog_Height extends HeightFog
	notplaceable;

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
	Components.Remove(HeightFogComponent0)

	Begin Object Name=HeightFogComponent0
		Height=640
		Density = 0.0005
		ExtinctionDistance = 4800
		LightBrightness = 0.2
		LightColor = (R=150,G=160,B=180)
	End Object
	Component=HeightFogComponent0
	Components.Add(HeightFogComponent0)

	bStatic=False
	bNoDelete=FALSE

	Name="Default__xcT_Weather_Fog_Height"
}