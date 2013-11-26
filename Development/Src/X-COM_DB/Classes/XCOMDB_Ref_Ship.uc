/**
 * X-Com database ship reference.
 */
class XCOMDB_Ref_Ship extends XCOMDB_Object;


//=============================================================================
// Variables
//=============================================================================
var string mIdent; // identifier
var int mLocaID;    // localization id

var string mName;  // localized

var XCOMDB_Ref_IMDetailInfo mIMDetailInfo;

var int mSpeed;
var int mRange;
var int mAcceleration;
var int mFuel;
var int mWeaponSlots;
var int mHull;
var int mCapacity;
var int mHWPSlots;
var int mPrice;


DefaultProperties
{
	Name="Default__XCOMDB_Ref_Ship"
}
