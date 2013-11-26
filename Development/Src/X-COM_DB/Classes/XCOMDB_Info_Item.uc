/**
 * X-Com database item records info.
 */
class XCOMDB_Info_Item extends XCOMDB_Object;

//=============================================================================
// Private variables
//=============================================================================
/**You can change this variable directly, but dont do it (unless you know...)*/
var int mId;
/**You can change this variable directly, but dont do it (unless you know...)*/
var string mName;
/**You can change this variable directly, but dont do it (unless you know...)*/
var int mPrice;
/**You can change this variable directly, but dont do it (unless you know...)*/
var int mWeight;
/**You can change this variable directly, but dont do it (unless you know...)*/
var int mMaxLoad;
/**You can change this variable directly, but dont do it (unless you know...)*/
var int mHeight;
/**You can change this variable directly, but dont do it (unless you know...)*/
var int mWidth;
/**You can change this variable directly, but dont do it (unless you know...)*/
var string mSmallPicName;
/**You can change this variable directly, but dont do it (unless you know...)*/
var string mMediumPicName;
/**You can change this variable directly, but dont do it (unless you know...)*/
var string mFullPicName;
/**You can change this variable directly, but dont do it (unless you know...)*/
var string mMesh;


//=============================================================================
// Setters and Getters functions for fields
//=============================================================================

/* (we assume we not changing items from game, so no setters for database fields) */

/** 
 * database unique id
 */
function int GetId()
{
	return mId;	
}

/** 
 * Set DB record unique id. @warning This function is only to fill items by provider
 */
function SetId(int aId)
{
	mId = aId;
	mIsChanged = TRUE;
}

/**
 * Unique item name
 */
function string GetName()
{
	return mName;	
}

/**
 * Set unique name. @warning (!) Items may ONLY be READ from DB. This function is for provider, not for users
 */
function SetName(string aName)
{
	mName = aName;
	mIsChanged = TRUE;
}

/**
 * price of the item
 */
function int GetPrice() 
{
	return mPrice;	
}

/**
 * Set price of the item. @warning (!) Items may ONLY be READ from DB. This function is for provider, not for users
 */
function SetPrice(int aPrice) 
{
	mPrice = aPrice;
	mIsChanged = TRUE;
}

/**
 * Maximum load of item. This 'maximum load' is like maximum ammo in ammo clip;
 */
function int GetMaxLoad() 
{
	return mMaxLoad;
}

/**
 * Set weight of the item. @warning (!) Items may ONLY be READ from DB. This function is for provider, not for users
 */
function SetMaxLoad(int aMaxLoad) 
{
	mMaxLoad = aMaxLoad;
	mIsChanged = TRUE;
}

/**
 * Weight of the item
 */
function int GetWeight() 
{
	return mWeight;
}

/**
 * Set weight of the item. @warning (!) Items may ONLY be READ from DB. This function is for provider, not for users
 */
function SetWeight(int aWeight) 
{
	mWeight = aWeight;
	mIsChanged = TRUE;
}

/**
 * Item height in inventory cells. 
 */
function int GetHeight() 
{
	return mHeight;
}

/**
 * Set Height in inventory cells. @warning (!) Items may ONLY be READ from DB. This function is for provider, not for users
 */
function SetHeight(int aHeight) 
{
	mHeight = aHeight;
	mIsChanged = TRUE;
}

/**
 * File name of smallPic
 */
function string GetSmallPicName()	  
{
	return mSmallPicName;
}

/**
 * Set file name of smallPic. @warning (!) Items may ONLY be READ from DB. This function is for provider, not for users
 */
function SetSmallPicName(string aName)	  
{
	mSmallPicName = aName;
	mIsChanged = TRUE;
}

/**
 * name of file of medium Pic
 */
function string GetMediumPicName()  
{
	return mMediumPicName;
}

/**
 * set file name of medium Pic. @warning (!) Items may ONLY be READ from DB. This function is for provider, not for users
 */
function  SetMediumPicName(string aName)  
{
	mMediumPicName = aName;
	mIsChanged = TRUE;
}

/**
 * name of file of full Pic
 */
function string GetFullPicName()  
{
	return mFullPicName;
}

/**
 * Set file name of full Pic. @warning (!) Items may ONLY be READ from DB. This function is for provider, not for users
 */
function SetFullPicName(string aName)  
{
	mFullPicName = aName;
	mIsChanged = TRUE;
}

/**
 * name of file of mesh
 */
function string GetMesh() 
{
	return mMesh;
}

/**
 * Set file name of mesh. @warning (!) Items may ONLY be READ from DB. This function is for provider, not for users
 */
function SetMesh(string aName) 
{
	mMesh = aName;
	mIsChanged = TRUE;
}

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
	Name="Default__XCOMDB_Info_Item"
}
