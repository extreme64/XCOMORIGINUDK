/**
 * Pawn Decals  class
 * Uses for pawn decals
 */
class X_COM_Effects_Units_Decals extends DecalActorMovable
	notplaceable;

//=============================================================================
// Functions
//=============================================================================
function SetNewDecalMaterial(string aNewMaterial)
{
	Decal.SetDecalMaterial(MaterialInterface(DynamicLoadObject(aNewMaterial,class'MaterialInterface')));
}

//=============================================================================
// Default properties
//=============================================================================
DefaultProperties
{
	Begin Object Name=NewDecalComponent
		//DecalMaterial = DecalMaterial'xcT_Decals.Materials.DefaultDecalMaterial'
		DecalTransform=DecalTransform_OwnerRelative
		bStaticDecal=FALSE
		bMovableDecal=TRUE
		NearPlane=0
		FarPlane=500
		ParentRelativeOrientation=(Roll=0x0000,Yaw=0x0000,Pitch=0xC000)
	end Object

	bNoDelete=FALSE
	bIgnoreBaseRotation=TRUE
}
