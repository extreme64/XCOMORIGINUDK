/**
 * X-Com database item info reference.
 */
class XCOMDB_Ref_IMDetailInfo extends XCOMDB_Object;


//=============================================================================
// Variables
//=============================================================================
var string mIdent; // identfier

var string mIcon; // for ScaleformGFx

var string mStaticMesh;

var string mSkeletalMesh; // used in 3rd person/1st person (same like third, with different cam location)
var string mPhysAsset;
var string mAnimSets;

var string mScript; // parent script file (UG_InvArmor, UG_InvImplant, etc.)
var string mAutoState; // auto state in script file


DefaultProperties
{
	Name="Default__XCOMDB_Ref_IMDetailInfo"
}
