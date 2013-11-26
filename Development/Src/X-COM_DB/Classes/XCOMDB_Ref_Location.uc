/**
 * X-Com database location reference.
 */
class XCOMDB_Ref_Location extends XCOMDB_Object;


//=============================================================================
// Variables
//=============================================================================
var string mIdent; // identifier
var int mLocaID;    // localization id

var string mName;  // localized

var string mSocketName;


function name GetSocketName()
{
  return name(mSocketName);
}


DefaultProperties
{
}
