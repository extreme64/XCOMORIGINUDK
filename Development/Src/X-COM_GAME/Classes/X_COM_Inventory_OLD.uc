class X_COM_Inventory_OLD extends Inventory;
  //implements(X_COM_Interface_Database);



/*
//=============================================================================
// Variables
//=============================================================================
var XCOMDB_Object mDBObject;                // ID
var XCOMDB_Ref_Item mReference;             // ItemRef
var Actor mContainer;                       // Container (Type & ID)
var XCOMDB_Ref_Location mContainerLocation; // ContainerLocation
var int mHealth;                            // Current item health
var int mUses;                              // Uses left
var string mName;                           // Custom item name

//var StaticMeshComponent mStaticMeshComponent; // Inventory mesh for 3rd Person
var SkeletalMeshComponent mSkeletalMeshComponent; // Inventory mesh for 3rd Person


//=============================================================================
// Functions
//=============================================================================
/**
 * Cleanup database entry if item is completely destroyed!!
 */
simulated function Destroyed()
{
	super.Destroyed();
  removeFromDatabase();
}

/**
 * Spawns a new UG_Inventory actor of a given ident, and adds it to the Inventory Manager.
 * @param [in]	aInventoryIdent [string]
 * @return X_COM_Inventory
 */
static function X_COM_Inventory CreateXCOMInventory(WorldInfo aWorldInfo, string aInventoryIdent, optional int aDbID=0)
{
  local X_COM_Inventory lNewInventory;
  local class<X_COM_Inventory> lInventoryClass;
  local XCOMDB_Ref_Item lItemReference;

  lInventoryClass = getInventoryClass(aWorldInfo, aInventoryIdent, lItemReference);
  
  if(lInventoryClass != None){
    lNewInventory = aWorldInfo.Spawn(lInventoryClass);
    if(lNewInventory != None){
      lNewInventory.setItemReference(lItemReference);
    }
    else{
      `warn("X_COM_Inventory::CreateUGInventory - Couldn't spawn inventory" @ lInventoryClass);
    }
  }
  if(aDbID != 0){
    lNewInventory.mDBObject = lNewInventory.Spawn(class'XCOMDB_Object', lNewInventory);
    lNewInventory.mDBObject.mDBId = aDbID;
  }else {
    if(!lNewInventory.addToDatabase()){
      lNewInventory.Destroy();
      return none;
    } 
    lNewInventory.setContainer(aWorldInfo);
  }
  
  return lNewInventory;
}


static function class<X_COM_Inventory> getInventoryClass(WorldInfo aWorldInfo, string aInventoryIdent, out XCOMDB_Ref_Item aInventoryRef)
{
  local XCOMDB_Cache lDBCache;
  local array<XCOMDB_Ref_Item> lItems;
  local int il;

  local class<X_COM_Inventory> lInventoryClass;

  lDBCache = X_COM_GameInfo(aWorldInfo.Game).getDBMgr().getDBCache();
  lDBCache.getDBRefItems(0,lItems);
  
  aInventoryRef = none;
  for(il=0; il<lItems.Length; il++){
    if(lItems[il].mIdent == aInventoryIdent){
      aInventoryRef = lItems[il];
      lInventoryClass = class<X_COM_Inventory>(DynamicLoadObject(lItems[il].mIMDetailInfo.mScript, class'class'));
      break;
    }
  }

  return lInventoryClass;
}

/**
 * Set the items refernce.
 * 
 * @param [in] aRefItem [XCOMDB_Ref_Item]
 */
function setItemReference(XCOMDB_Ref_Item aRefItem)
{
  mReference = aRefItem;
  updateVisual();
}

/**
 * Drops an item at the given location on the ground.
 * 
 * @param[in] aDropLocation [Vector]
 */
function dropToGround(Vector aDropLocation)
{
  if(Instigator != none){
    Instigator.InvManager.RemoveFromInventory(Self);
  }

  setContainer(WorldInfo);

  SetLocation(aDropLocation);
  SetPhysics(PHYS_Falling);
  GotoState('Dropped');
}


//=============================================================================
// Database routines
//=============================================================================
/**
 * Try to add a new item to the database, and return the new dbID to calling function.
 * Return false if item couldn't add to database.
 * 
 * @return bool
 */
function bool addToDatabase()
{
  local X_COM_GameInfo lGameInfo;
  local XCOMDB_Manager lDBMgr;
  local XCOMDB_DLLAPI lDLLAPI;
  local string lQuery;

  lGameInfo = X_COM_GameInfo(WorldInfo.Game);
  if(lGameInfo == none){
    `log("X_COM_Inventory::addItemToDatabase() : GameInfo == None");
    return false;
  }

  lDBMgr = lGameInfo.getDBMgr();
  lDLLAPI = lDBMgr.getDLLAPI();
  lDLLAPI.SQL_selectDatabase(lDBMgr.mGameplayDatabaseIdx);

  lQuery = "INSERT INTO ITEMS (ItemRef) VALUES ("$mReference.mDBId$");";
  if(!lDLLAPI.SQL_queryDatabase(lQuery)){
    return false;
  }
  
  mDBObject = Spawn(class'XCOMDB_Object', self);
  mDBObject.mDBId = lDLLAPI.SQL_lastInsertID();

  return true;
}

/**
 * Try to remove a item from the database.
 * Return false if item couldn't remove from database.
 *  
 * @return bool
 */
function bool removeFromDatabase()
{
  local X_COM_GameInfo lGameInfo;
  local XCOMDB_Manager lDBMgr;
  local XCOMDB_DLLAPI lDLLAPI;
  local string lQuery;

  lGameInfo = X_COM_GameInfo(WorldInfo.Game);
  if(lGameInfo == none){
    `log("X_COM_Inventory::addItemToDatabase() :  GameInfo == None");
    return false;
  }

  if(mDBObject == none){
    `log("X_COM_Inventory::addItemToDatabase() :  mDBObject == None");
    return false;
  }

  lDBMgr = lGameInfo.getDBMgr();
  lDLLAPI = lDBMgr.getDLLAPI();
  lDLLAPI.SQL_selectDatabase(lDBMgr.mGameplayDatabaseIdx);

  lQuery = "DELETE FROM ITEMS WHERE ID="$mDBObject.mDBId$";";
  if(!lDLLAPI.SQL_queryDatabase(lQuery)){
    return false;
  }
  return true;
}

function bool setContainer(Actor aNewContainer, optional XCOMDB_Ref_Location aLocation)
{
  local X_COM_GameInfo lGameInfo;
  local XCOMDB_Manager lDBMgr;
  local XCOMDB_Cache lDBCache;

  lGameInfo = X_COM_GameInfo(WorldInfo.Game);
  if(lGameInfo == none){
    `log("X_COM_Inventory::setItemContainer() : GameInfo == None");
    return false;
  }

  lDBMgr = lGameInfo.getDBMgr();
  lDBCache = lDBMgr.getDBCache();

  mContainer = aNewContainer;
  if(aLocation != none){
    mContainerLocation = aLocation;
  }else{
    mContainerLocation = lDBCache.getDBRefLocation(0, "loc_undefined");
  }

  sync();

  return true;
}


//=============================================================================
// Database handling (Interface implementation)
//=============================================================================
/**
 * Sync with database => Write values to database
 */
function sync()
{
  local X_COM_GameInfo lGameInfo;
  local XCOMDB_Manager lDBMgr;
  local XCOMDB_DLLAPI lDLLAPI;
  local string lQuery;

  lGameInfo = X_COM_GameInfo(WorldInfo.Game);
  lDBMgr = lGameInfo.getDBMgr();  
  lDLLAPI = lDBMgr.getDLLAPI();
  
  lDLLAPI.SQL_selectDatabase(lDBMgr.mGameplayDatabaseIdx);

  lQuery = "UPDATE ITEMS SET ContainerType=@SyncConType, ContainerID=@SyncConID, ContainerLocation=@SyncConLoc, " $
           "Health=@SyncHealth, Uses=@SyncUses, Name=@SyncName, " $
           "Location=@SyncLoc, Rotation=@SyncRot " $
           "WHERE ID=@ID;";
  lDLLAPI.SQL_prepareStatement(lQuery);
  lDLLAPI.SQL_bindNamedValueInt("@ID", mDBObject.mDBId);

  if(mContainer == WorldInfo){
    lDLLAPI.SQL_bindNamedValueString("@SyncConType", "world");
    lDLLAPI.SQL_bindNamedValueInt("@SyncConID", 0);
  }else if(X_COM_Pawn(mContainer) != none){
    lDLLAPI.SQL_bindNamedValueString("@SyncConType", "pawn");
    lDLLAPI.SQL_bindNamedValueInt("@SyncConID", X_COM_Pawn(mContainer).mStats.mPawnID);
  }
  lDLLAPI.SQL_bindNamedValueString("@SyncConLoc", mContainerLocation.mIdent);
  
  lDLLAPI.SQL_bindNamedValueInt("@SyncHealth", mHealth);
  lDLLAPI.SQL_bindNamedValueInt("@SyncUses", mUses);
  lDLLAPI.SQL_bindNamedValueString("@SyncName", mName);
  lDLLAPI.SQL_bindNamedValueString("@SyncLoc", Location.X$","$Location.Y$","$Location.Z);
  lDLLAPI.SQL_bindNamedValueString("@SyncRot", Rotation.Pitch$","$Rotation.Yaw$","$Rotation.Roll);

  lDLLAPI.SQL_executeStatement();
}

/**
 * Sync with database => Read value from database
 */
function update()
{
  local X_COM_GameInfo lGameInfo;
  local XCOMDB_Manager lDBMgr;
  local XCOMDB_DLLAPI lDLLAPI;
  local string lQuery;
  local string lLocation;
  local string lRotation;
  local Vector lVecLocation;
  local Rotator lRotRotation;

  lGameInfo = X_COM_GameInfo(WorldInfo.Game);
  lDBMgr = lGameInfo.getDBMgr();  
  lDLLAPI = lDBMgr.getDLLAPI();
  
  lDLLAPI.SQL_selectDatabase(lDBMgr.mGameplayDatabaseIdx);
  
  lQuery = "SELECT Name, Location, Rotation FROM ITEMS WHERE ID=@ID";
  lDLLAPI.SQL_prepareStatement(lQuery);
  lDLLAPI.SQL_bindNamedValueInt("@ID", mDBObject.mDBId);
  if(lDLLAPI.SQL_executeStatement()){
    while(lDLLAPI.SQL_nextResult()){
      `XCOM_InitString(mName,60);
      `XCOM_InitString(lLocation,255);
      `XCOM_InitString(lRotation,255);
      lDLLAPI.SQL_getStringVal("Name", mName);
      lDLLAPI.SQL_getStringVal("Location", lLocation);
      lDLLAPI.SQL_getStringVal("Rotation", lRotation);
    }
  }
  if(lLocation != ""){
    `XCOM_String2Vec(lLocation,lVecLocation);
    SetLocation( lVecLocation );
  }
  
  if(lRotation != ""){
    `XCOM_String2Rot(lRotation,lRotRotation);
    setRotation( lRotRotation );
  }
}

/**
 * This Inventory Item has just been given to this Pawn
 * (server only)
 *
 * @param [in]	thisPawn [Pawn]
 * @param[in]	bDoNotActivate [bool]
 */
function GivenTo( Pawn thisPawn, optional bool bDoNotActivate )
{
  Super.GivenTo(thisPawn, bDoNotActivate);  
  //setContainer(thisPawn);
 // GotoState('Backpack');
}

/**
 * Update visuals for PickupMeshes
 */
function updateVisual()
{
  local SkeletalMesh lSkeletalMesh;
  local PhysicsAsset lPhysAsset;

  `log("updateVisual()");

  lSkeletalMesh = SkeletalMesh(DynamicLoadObject(mReference.mIMDetailInfo.mSkeletalMesh, class'SkeletalMesh'));
  lPhysAsset = PhysicsAsset(DynamicLoadObject(mReference.mIMDetailInfo.mPhysAsset, class'PhysicsAsset'));

  mSkeletalMeshComponent.SetSkeletalMesh(lSkeletalMesh);
  mSkeletalMeshComponent.SetPhysicsAsset(lPhysAsset, true);
/*
  lStaticMesh = StaticMesh(DynamicLoadObject(mReference.mItemInfo.mSkeletalMesh, class'StaticMesh'));
  mStaticMeshComponent.SetStaticMesh(lStaticMesh);
*/
}

/**
 * Put item into backpack.
 * 
 * @return bool
 */
function bool unEquipItem()
{
  local XCOMDB_Cache lDBCache;

  lDBCache = X_COM_GameInfo(WorldInfo.Game).getDBMgr().getDBCache();
  mContainerLocation = lDBCache.getDBRefLocation(0, "loc_undefined");  
  setContainer(Instigator, mContainerLocation);

  GotoState('Backpack');
  return true;
}

/**
 * Equip an item to its only allowed position.
 * TODO: Special handling for loc_single weapons.
 * 
 * @return bool
 */
function bool equipItem()
{
  local X_COM_Inventory lEquippedItem;
  if(mContainerLocation.mIdent == "loc_undefined")
  {
    lEquippedItem = X_COM_InventoryManager_OLD(Instigator.InvManager).findEquippedItem(mReference.mLocation);
    if(lEquippedItem != none){
      lEquippedItem.unEquipItem();
    }
    mContainerLocation = mReference.mLocation;
    setContainer(Instigator, mContainerLocation);

    GotoState('Equipped');
    return true;
  }

  return false;
}

/**
 * Update and make an item attachment visible or remove attachment on equip/unequip.
 * 
 * @param [in] aEquipped [bool]
 */
function showAttachment(bool aEquipped)
{
  `log("X_COM_Inventory::showAttachment: " $ string(mContainerLocation.GetSocketName()));

  if(aEquipped){
    Instigator.Mesh.AttachComponentToSocket(mSkeletalMeshComponent, mContainerLocation.GetSocketName());
  }else{
    Instigator.Mesh.DetachComponent(mSkeletalMeshComponent);
  }

  `log("X_COM_Inventory::showAttachment : "$aEquipped);
  mSkeletalMeshComponent.SetHidden( !aEquipped );
}

/**
 * Apply or remove a special equip bonus caused by the item itself.
 * 
 * @params[in] aEquipped [bool]
 */
function applyEquipBonus(bool aEquipped)
{
}


//=============================================================================
// Inventory States
//=============================================================================
state Dropped
{
  function BeginState(Name aPreviousStateName)
  {
    `log("state Dropped :: BeginState");
    SetCollision(true,false);
    mSkeletalMeshComponent.SetHidden(false);
    AttachComponent(mSkeletalMeshComponent);
  }

  function EndState(Name aNextStateName)
  {
    `log("state Dropped :: EndState");
    DetachComponent(mSkeletalMeshComponent);
  }

  event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
	{
		`log("state Dropped :: Touch");
	}

  event Landed( vector HitNormal, actor FloorActor )
  {
		`log("state Dropped :: Landed");
    sync();
  }
}

state Backpack
{
  function BeginState(Name aPreviousStateName)
  {
    `log("state Backpack :: BeginState");
    SetCollision(false,false);
  }

  function EndState(Name aNextStateName)
  {
    `log("state Backpack :: EndState");
  }
}

state Equipped
{
  function BeginState(Name aPreviousStateName)
  {
    `log("state Equipped :: BeginState");
    showAttachment(true);
    applyEquipBonus(true);
  }

  function EndState(Name aNextStateName)
  {
    `log("state Equipped :: EndState");
    showAttachment(false);
    applyEquipBonus(false);
  }
}


DefaultProperties
{
  Begin Object Class=AnimNodeSequence Name=AnimNodeSequenceObj
	End Object

  Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponentObj
		bOwnerNoSee=false
		bOnlyOwnerSee=false
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		MaxDrawDistance=4000
		bForceRefPose=1
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=FALSE
		Animations=AnimNodeSequenceObj
		CastShadow=true
		bCastDynamicShadow=true
	End Object
	mSkeletalMeshComponent=SkeletalMeshComponentObj

  Begin Object Class=CylinderComponent NAME=CollisionCylinder
		CollisionRadius=+00030.000000
		CollisionHeight=+00020.000000
		CollideActors=true
	End Object
	CollisionComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

  bCollideComplex=true
  bCollideActors=true
	bCollideWorld=true
  CollisionType=COLLIDE_TouchAll

	bOrientOnSlope=true
	bShouldBaseAtStartup=true
	bIgnoreRigidBodyPawns=true
  bHidden=false

	Name="Default__X_COM_Inventory"
}
*/