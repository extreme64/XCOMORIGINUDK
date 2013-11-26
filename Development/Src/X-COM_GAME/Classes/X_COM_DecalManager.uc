/**
 * Decal Manager class
 * 
 */
class X_COM_DecalManager extends DecalManager;

//=============================================================================
// Functions:
//=============================================================================
/** Can we spawn decal or not **/
function bool CanSpawnDecals()
{
	return (!class'Engine'.static.IsSplitScreen() && Super.CanSpawnDecals());
}

//=============================================================================
// DefaultProperties
//=============================================================================
defaultproperties
{
	DecalDepthBias=-0.00012
}