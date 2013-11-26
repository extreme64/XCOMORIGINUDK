/**
 * X-Com database object wrapper.
 * Base class for all objects need to be synchronised with database during runtime.
 */
class XCOMDB_Object extends Actor;


//=============================================================================
// Variables
//=============================================================================
var int mDBId; /// @warning (!!!) DEPRECATED

var string mDBTable; // referenced database table ... Why do we need it?

/** @brief Flag indicates that content for this object is loaded
 *  
 *  For ability of lazy loading we assume that we can only load 
 *  an Id of the object and then we will load the content (other fields)
 *  only on the first time user call getSomething().
 *  
 *  Lazy loading will not be implemented in the beginning, but 
 *  this flag will be working
 */
var bool mIsLoaded; 

/** @brief Flag indicates that the content was changed
 * 
 * Flag indicates that the content (fields loaded from the DB) was changed
 * and differs from the original data loaded from the DB. 
 * 
 * This flag we use to  Update commands and ets. 
 */
var bool mIsChanged;

/** @brief Provider that provided this object...
 */
var XCOMDB_Provider mProvider; 


//=============================================================================
// Functions
//=============================================================================


/** 
 *  @brief gets Provider that provided this object...
 */
function XCOMDB_Provider GetProvider() 
{
	return mProvider; 
}

/** 
 *  @brief Sets provider that provided this object... @warning (!) Function is not for regular users
 */
function SetProvider(XCOMDB_Provider aProvider)
{
	mProvider = aProvider;
}

/** Gets flag which indicates that content for this object is loaded
 *  @see mIsLoaded
 */
function bool IsLoaded()
{
	return mIsLoaded;
}

/** Sets IsLoaded and IsChanged flags as the object contents was loaded from the DB.
 * Provider call this function when contents of the object is loaded from the db. 
 */
function SetContentsLoadedFromDb()
{
	mIsLoaded = TRUE;
	mIsChanged = FALSE;
}

/** 
 *  Submits changes to the DB. 
 *  
 *  Calling of SetXXX, SetYYY of the "Info" classes does not automatically submit changes to the DB. 
 *  Call this function to save changes to the database;
 */
function bool SubmitChanges()
{
	return true; //just empty function in the base class

}
/** @brief Flag indicates that the content was changed from the 
 *  moment it was loaded or last time commited to the DB.
 * 
 * Flag indicates that the content (fields loaded from the DB) was changed
 * and differs from the moment it was loaded or last time commited to the DB.
 */
function bool IsChanged()
{
	return mIsChanged;
}

DefaultProperties
{
  TickGroup=TG_DuringAsyncWork

	bHidden=TRUE
	Physics=PHYS_None
	bReplicateMovement=FALSE
	bStatic=FALSE
	bNoDelete=FALSE
	mIsChanged = FALSE

	Name="Default__XCOMDB_Object"
}
