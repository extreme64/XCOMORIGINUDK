/**
 * X-Com database base module reference.
 */
class XCOMDB_Ref_Module extends XCOMDB_Object;


//=============================================================================
// Variables
//=============================================================================
var string mIdent; // identifier
var int mLocaID;    // localization id

var string mName;  // localized

var XCOMDB_Ref_IMDetailInfo mIMDetailInfo;  // Item information

var int   mGridSize[3];
var int   mPrice;

DefaultProperties
{
	Name="Default__XCOMDB_Ref_Module"
}
