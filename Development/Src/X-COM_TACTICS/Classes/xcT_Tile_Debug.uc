/**
 * X-COM Tactics functions and variables class. 
 * Uses to store functions and variables for tactics classes.
 */
class xcT_Tile_Debug extends X_COM_Tile;

var MaterialInstanceConstant mMainMaterial;
var MaterialInstanceConstant mCustomMaterial;
var string mDebugParamName;

event PreBeginPlay()
{
	AddStaticMesh(StaticMesh'FX_TacticalDebug.Meshes.TacticalDebug_Cell');

	mMainMaterial = new(None) Class'MaterialInstanceConstant';
	mMainMaterial.SetParent(StaticMeshComponent.GetMaterial(0));

	mCustomMaterial = new(None) Class'MaterialInstanceConstant';
	mCustomMaterial.SetParent(mMainMaterial);
	StaticMeshComponent.SetMaterial(0, mCustomMaterial);
}

//=============================================================================
// Default properties
//=============================================================================
defaultproperties
{
	mDebugParamName = 'TacticalDebugColor_'
    Name="Default__xcT_Tile_Debug"
}