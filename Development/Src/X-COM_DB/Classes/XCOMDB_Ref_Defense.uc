/**
 * X-Com database defense reference.
 */
class XCOMDB_Ref_Defense extends XCOMDB_Object;


//=============================================================================
// Variables
//=============================================================================
var string mIdent; // identifier
var int mLocaID;    // localization id

var string mName;  // localized

var int   mPenetrating;
var int   mThermal;
var int   mChemical;
var int   mShock;
var int   mSpecial;
var int   mEmp;

DefaultProperties
{
	Name="Default__XCOMDB_Ref_Defense"
}
