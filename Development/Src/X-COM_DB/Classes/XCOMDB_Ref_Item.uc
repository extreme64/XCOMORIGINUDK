/**
 * X-Com database item reference.
 */
class XCOMDB_Ref_Item extends XCOMDB_Object;


//=============================================================================
// Variables
//=============================================================================
var string mIdent; // identfier
var int mLocaID;    // localization id

var string mName;  // localized

var XCOMDB_Ref_IMDetailInfo mIMDetailInfo;  // Item information
var XCOMDB_Ref_Location mLocation;

var int mPrice;
var int mWeight;
var int mUses;
var bool mIsStackable;
var int mStacksize;


DefaultProperties
{
	Name="Default__XCOMDB_Ref_Item"
}
