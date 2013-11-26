/**
 * X-Com pawn data container.
 * Special subclasses version used for creature and human characters.
 */
class X_COM_Stats extends Actor
  dependson(X_COM_Defines)
  //abstract
  implements(X_COM_Interface_Database);

//=============================================================================
// Variables
//=============================================================================
var int mPawnID;
var string mPawnName;
var X_COM_Attributes mAttributes;

var int mPhotoID;
var XCOMDB_Ref_Rank mRank;
var XCOMDB_Ref_Defense mDefense;
var XCOMDB_Ref_Shield mShield;
var XCOMDB_Ref_Status mStatus;
var EXCOMGender mGender;

/**
 * Sync with database => Write values to database
 */
function sync();

/**
 * Sync with database => Read value from database
 */
function update();

DefaultProperties
{
  TickGroup=TG_DuringAsyncWork

	bHidden=TRUE
	Physics=PHYS_None
	bReplicateMovement=FALSE
	bStatic=FALSE
	bNoDelete=FALSE

	Name="Default__X_COM_Stats"
}
