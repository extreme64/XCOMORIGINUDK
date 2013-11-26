class XCOMDB_Cache extends Actor
  dependson(XCOMDB_Manager);

//=============================================================================
// Variables
//=============================================================================
var private XCOMDB_DLLAPI mDLLAPI; // backreference to XCOMDB_Manager


//=============================================================================
// Caching
//=============================================================================
var array<XCOMDB_Ref_Alien> mRefAliens;
var array<XCOMDB_Ref_Attribute> mRefAttributes;
var array<XCOMDB_Ref_Defense> mRefDefenses;
var array<XCOMDB_Ref_IMDetailInfo> mRefIMDetailInfos;
var array<XCOMDB_Ref_Item> mRefItems;
var array<XCOMDB_Ref_Location> mRefLocations;
var array<XCOMDB_Ref_Module> mRefModules;
var array<XCOMDB_Ref_Rank> mRefRanks;
var array<XCOMDB_Ref_Shield> mRefShields;
var array<XCOMDB_Ref_Status> mRefStatuses;
var array<XCOMDB_Ref_Ship> mRefShips;


//=============================================================================
// Functions
//=============================================================================
/**
 * Initialise the databasedriver and creat/load the default databases
 */
function PostBeginPlay()
{
  super.PostBeginPlay();

  mDLLAPI = XCOMDB_Manager(Owner).getDLLAPI();
}


//=============================================================================
// DBRef Filler functions
//=============================================================================
/**
 * Quick getter function for a specific alien needed
 * 
 * @param[in] aDatabaseIdx [int]
 * @param[in] aIdent [string]
 * 
 * @return XCOMDB_Ref_Alien
 */
function XCOMDB_Ref_Alien getDBRefAlien(int aDatabaseIdx, string aIdent)
{
  local array<XCOMDB_Ref_Alien> lAliens;
  local int il;

  getDBRefAliens(aDatabaseIdx, lAliens);
  for(il=0; il<lAliens.Length; il++){
    if(lAliens[il].mIdent == aIdent){
      return lAliens[il];
    }
  }
  return none;
}

/**
 * Load all Aliens from content database and fill up array with readed data.
 * 
 * @param[in] aDatabaseIdx [int]
 * @param[out] aAliens [array<XCOMDB_Ref_Alien>]
 */
function getDBRefAliens(int aDatabaseIdx, out array<XCOMDB_Ref_Alien> aAliens)
{
  local string lQuery;
  local XCOMDB_Ref_Alien lNewAlien;
  local array<XCOMDB_Ref_Alien> lAliens;
//	local int lResIdx;
  local int il;

  aAliens.Length = 0;

  if(mRefAliens.Length > 0){
    aAliens = mRefAliens;
    return;
  }

  lQuery = "SELECT ID, LocaID, Ident FROM XCOM_ALIENS;";

  mDLLAPI.SQL_selectDatabase(aDatabaseIdx);
  if(mDLLAPI.SQL_queryDatabase(lQuery)){
    while(mDLLAPI.SQL_nextResult()){
      lNewAlien = Spawn(class'XCOMDB_Ref_Alien');
      lNewAlien.mDBTable = "XCOM_ALIENS";

      `XCOMDB_InitString(lNewAlien.mIdent,30);

      mDLLAPI.SQL_getIntVal("ID", lNewAlien.mDBId);
      mDLLAPI.SQL_getIntVal("LocaID", lNewAlien.mLocaID);
      mDLLAPI.SQL_getStringVal("Ident", lNewAlien.mIdent);

      lAliens[lAliens.Length] = lNewAlien;      
    }
  }
  
  for(il=0; il<lAliens.Length; ++il)
  {
    lAliens[il].mName = getLocalization(lAliens[il].mLocaID, 50);
  }

  mRefAliens = lAliens;
  aAliens = lAliens;
}

/**
 * Quick getter function for a specific attribute needed
 * 
 * @param[in] aDatabaseIdx [int]
 * @param[in] aIdent [string]
 * 
 * @return XCOMDB_Ref_Attribute
 */
function XCOMDB_Ref_Attribute getDBRefAttribute(int aDatabaseIdx, string aIdent)
{
  local array<XCOMDB_Ref_Attribute> lAttributes;
  local int il;

  getDBRefAttributes(aDatabaseIdx, lAttributes);
  for(il=0; il<lAttributes.Length; il++){
    if(lAttributes[il].mIdent == aIdent){
      return lAttributes[il];
    }
  }
  return none;
}

/**
 * Load all Attributes from content database and fill up array with readed data.
 * 
 * @param[in] aDatabaseIdx [int]
 * @param[out] aAttributes [array<UGDB_Ref_Attribute>]
 */
function getDBRefAttributes(int aDatabaseIdx, out array<XCOMDB_Ref_Attribute> aAttributes)
{
  local string lQuery;
  local XCOMDB_Ref_Attribute lNewAttribute;
  local array<XCOMDB_Ref_Attribute> lAttributes;
//	local int lResIdx;
  local int il;

  aAttributes.Length = 0;

  if(mRefAttributes.Length > 0){
    aAttributes = mRefAttributes;
    return;
  }

  lQuery = "SELECT ID, LocaID, Ident FROM XCOM_ATTRIBUTES;";

  mDLLAPI.SQL_selectDatabase(aDatabaseIdx);
  if(mDLLAPI.SQL_queryDatabase(lQuery)){
    while(mDLLAPI.SQL_nextResult()){
      lNewAttribute = Spawn(class'XCOMDB_Ref_Attribute');
      lNewAttribute.mDBTable = "XCOM_ATTRIBUTES";

      `XCOMDB_InitString(lNewAttribute.mIdent,30);

      mDLLAPI.SQL_getIntVal("ID", lNewAttribute.mDBId);
      mDLLAPI.SQL_getIntVal("LocaID", lNewAttribute.mLocaID);
      mDLLAPI.SQL_getStringVal("Ident", lNewAttribute.mIdent);

      lAttributes[lAttributes.Length] = lNewAttribute;
    }
  }
  
  for(il=0; il<lAttributes.Length; ++il)
  {
    lAttributes[il].mName = getLocalization(lAttributes[il].mLocaID, 50);
  }

  mRefAttributes = lAttributes;
  aAttributes = lAttributes;
}

/**
 * Quick getter function for a specific defense needed
 * 
 * @param[in] aDatabaseIdx [int]
 * @param[in] aIdent [string]
 * 
 * @return XCOMDB_Ref_Defense
 */
function XCOMDB_Ref_Defense getDBRefDefense(int aDatabaseIdx, string aIdent)
{
  local array<XCOMDB_Ref_Defense> lDefenses;
  local int il;

  getDBRefDefenses(aDatabaseIdx, lDefenses);
  for(il=0; il<lDefenses.Length; il++){
    if(lDefenses[il].mIdent == aIdent){
      return lDefenses[il];
    }
  }
  return none;
}

/**
 * Load all Defenses from content database and fill up array with readed data.
 * 
 * @param[in] aDatabaseIdx [int]
 * @param[out] aDefenses [array<XCOMDB_Ref_Defense>]
 */
function getDBRefDefenses(int aDatabaseIdx, out array<XCOMDB_Ref_Defense> aDefenses)
{
  local string lQuery;
  local XCOMDB_Ref_Defense lNewDefense;
  local array<XCOMDB_Ref_Defense> lDefenses;
//	local int lResIdx;
  local int il;

  aDefenses.Length = 0;

  if(mRefDefenses.Length > 0){
    aDefenses = mRefDefenses;
    return;
  }

  lQuery = "SELECT ID, LocaID, Ident, Penetrating, Thermal, Chemical, Shock, Special, Emp FROM XCOM_DEFENSE;";

  mDLLAPI.SQL_selectDatabase(aDatabaseIdx);
  if(mDLLAPI.SQL_queryDatabase(lQuery)){
    while(mDLLAPI.SQL_nextResult()){
      lNewDefense = Spawn(class'XCOMDB_Ref_Defense');
      lNewDefense.mDBTable = "XCOM_DEFENSE";

      `XCOMDB_InitString(lNewDefense.mIdent,30);

      mDLLAPI.SQL_getIntVal("ID", lNewDefense.mDBId);
      mDLLAPI.SQL_getIntVal("LocaID", lNewDefense.mLocaID);
      mDLLAPI.SQL_getStringVal("Ident", lNewDefense.mIdent);
      
      mDLLAPI.SQL_getIntVal("Penetrating", lNewDefense.mPenetrating);
      mDLLAPI.SQL_getIntVal("Thermal", lNewDefense.mThermal);
      mDLLAPI.SQL_getIntVal("Chemical", lNewDefense.mChemical);
      mDLLAPI.SQL_getIntVal("Shock", lNewDefense.mShock);
      mDLLAPI.SQL_getIntVal("Special", lNewDefense.mSpecial);
      mDLLAPI.SQL_getIntVal("Emp ", lNewDefense.mEmp);

      lDefenses[lDefenses.Length] = lNewDefense;
    }
  }
  
  for(il=0; il<lDefenses.Length; ++il)
  {
    lDefenses[il].mName = getLocalization(lDefenses[il].mLocaID, 50);
  }

  mRefDefenses = lDefenses;
  aDefenses = lDefenses;
}

/**
 * Quick getter function for a specific iteminfo needed
 * 
 * @param[in] aDatabaseIdx [int]
 * @param[in] aIdent [string]
 * 
 * @return XCOMDB_Ref_IMDetailInfo
 */
function XCOMDB_Ref_IMDetailInfo getDBRefItemInfo(int aDatabaseIdx, string aIdent)
{
  local array<XCOMDB_Ref_IMDetailInfo> lItemInfos;
  local int il;

  getDBRefIMDetailInfos(aDatabaseIdx, lItemInfos);
  for(il=0; il<lItemInfos.Length; il++){
    if(lItemInfos[il].mIdent == aIdent){
      return lItemInfos[il];
    }
  }
  return none;
}

/**
 * Load all IMDetailInfos from content database and fill up array with readed data.
 * 
 * @param[in] aDatabaseIdx [int]
 * @param[out] aIMDetailInfos [array<XCOMDB_Ref_IMDetailInfo>]
 */
function getDBRefIMDetailInfos(int aDatabaseIdx, out array<XCOMDB_Ref_IMDetailInfo> aIMDetailInfos)
{
  local string lQuery;
  local XCOMDB_Ref_IMDetailInfo lNewIMDetailInfo;
  local array<XCOMDB_Ref_IMDetailInfo> lIMDetailInfos;
//	local int lResIdx;
  //local int il;

  aIMDetailInfos.Length = 0;

  if(mRefIMDetailInfos.Length > 0){
    aIMDetailInfos = mRefIMDetailInfos;
    return;
  }

  lQuery = "SELECT ID, Ident, Icon, StaticMesh, SkeletalMesh, PhysAsset, AnimSets, Script, AutoState FROM XCOM_IMDETAILINFOS;";

  mDLLAPI.SQL_selectDatabase(aDatabaseIdx);
  if(mDLLAPI.SQL_queryDatabase(lQuery)){
    while(mDLLAPI.SQL_nextResult()){
      lNewIMDetailInfo = Spawn(class'XCOMDB_Ref_IMDetailInfo');
      lNewIMDetailInfo.mDBTable = "XCOM_IMDETAILINFOS";

      `XCOMDB_InitString(lNewIMDetailInfo.mIdent,50);
      `XCOMDB_InitString(lNewIMDetailInfo.mIcon,255);
      `XCOMDB_InitString(lNewIMDetailInfo.mStaticMesh,255);
      `XCOMDB_InitString(lNewIMDetailInfo.mSkeletalMesh,255);
      `XCOMDB_InitString(lNewIMDetailInfo.mPhysAsset,255);
      `XCOMDB_InitString(lNewIMDetailInfo.mAnimSets,255);
      `XCOMDB_InitString(lNewIMDetailInfo.mScript,255);
      `XCOMDB_InitString(lNewIMDetailInfo.mAutoState,255);

      mDLLAPI.SQL_getStringVal("Ident", lNewIMDetailInfo.mIdent);
      mDLLAPI.SQL_getStringVal("Icon", lNewIMDetailInfo.mIcon);
      mDLLAPI.SQL_getStringVal("StaticMesh", lNewIMDetailInfo.mStaticMesh);
      mDLLAPI.SQL_getStringVal("SkeletalMesh", lNewIMDetailInfo.mSkeletalMesh);
      mDLLAPI.SQL_getStringVal("PhysAsset", lNewIMDetailInfo.mPhysAsset);
      mDLLAPI.SQL_getStringVal("AnimSets", lNewIMDetailInfo.mAnimSets);
      mDLLAPI.SQL_getStringVal("Script", lNewIMDetailInfo.mScript);
      mDLLAPI.SQL_getStringVal("AutoState", lNewIMDetailInfo.mAutoState);

      lIMDetailInfos[lIMDetailInfos.Length] = lNewIMDetailInfo;
    }
  }
  mRefIMDetailInfos = lIMDetailInfos;
  aIMDetailInfos = lIMDetailInfos;
}

/**
 * Quick getter function for a specific item needed
 * 
 * @param[in] aDatabaseIdx [int]
 * @param[in] aIdent [string]
 * 
 * @return XCOMDB_Ref_Item
 */
function XCOMDB_Ref_Item getDBRefItem(int aDatabaseIdx, string aIdent)
{
  local array<XCOMDB_Ref_Item> lItems;
  local int il;

  getDBRefItems(aDatabaseIdx, lItems);
  for(il=0; il<lItems.Length; il++){
    if(lItems[il].mIdent == aIdent){
      return lItems[il];
    }
  }
  return none;
}

/**
 * Load all Items from content database and fill up array with readed data.
 * 
 * @param[in] aDatabaseIdx [int]
 * @param[out] aItems [array<UGDB_Ref_Item>]
 */
function getDBRefItems(int aDatabaseIdx, out array<XCOMDB_Ref_Item> aItems)
{
  local string lQuery;
  local XCOMDB_Ref_Item lNewItem;
  local array<XCOMDB_Ref_Item> lItems;
  local array<XCOMDB_Ref_IMDetailInfo> lRefIMDetailInfos;
  local array<XCOMDB_Ref_Location> lRefLocations;

  local int il;
  local int lStackable;
  local string lIMDetailID;
  local string lLocationID;
//	local int lResIdx;
  aItems.Length = 0;

  if(mRefItems.Length > 0){
    aItems = mRefItems;
    return;
  }

  getDBRefIMDetailInfos(aDatabaseIdx, lRefIMDetailInfos);
  getDBRefLocations(aDatabaseIdx, lRefLocations);

  lQuery = "SELECT ID, LocaID, Ident, IMDetailInfoID, LocationID, Price, Weight, Uses, Stackable, Stacksize FROM XCOMOLD_ITEMS;";

  mDLLAPI.SQL_selectDatabase(aDatabaseIdx);
  if(mDLLAPI.SQL_queryDatabase(lQuery)){
    while(mDLLAPI.SQL_nextResult()){
      lNewItem = Spawn(class'XCOMDB_Ref_Item');
      lNewItem.mDBTable = "XCOM_ITEMS";

      `XCOMDB_InitString(lNewItem.mIdent,50);
      `XCOMDB_InitString(lIMDetailID,50);
      `XCOMDB_InitString(lLocationID,50);

      mDLLAPI.SQL_getIntVal("ID", lNewItem.mDBId);
      mDLLAPI.SQL_getIntVal("LocaID", lNewItem.mLocaID);
      mDLLAPI.SQL_getStringVal("Ident", lNewItem.mIdent);
      mDLLAPI.SQL_getStringVal("IMDetailInfoID", lIMDetailID);
      mDLLAPI.SQL_getStringVal("IMDetailInfoID", lLocationID);

      mDLLAPI.SQL_getIntVal("Price", lNewItem.mPrice);
      mDLLAPI.SQL_getIntVal("Weight", lNewItem.mWeight);
      mDLLAPI.SQL_getIntVal("Uses", lNewItem.mUses);
      mDLLAPI.SQL_getIntVal("Stacksize", lNewItem.mStacksize);
      mDLLAPI.SQL_getIntVal("Stackable", lStackable);
      lNewItem.mIsStackable = (lStackable==1);

      for(il=0; il<lRefIMDetailInfos.Length; ++il){
        if(lRefIMDetailInfos[il].mIdent == lIMDetailID){
          lNewItem.mIMDetailInfo = lRefIMDetailInfos[il];
          break;
        }
      }

      for(il=0; il<lRefLocations.Length; ++il){
        if(lRefLocations[il].mIdent == lLocationID){
          lNewItem.mLocation = lRefLocations[il];
          break;
        }
      }

      lItems[lItems.Length] = lNewItem;
    }
  }
  
  for(il=0; il<lItems.Length; ++il)
  {
    lItems[il].mName = getLocalization(lItems[il].mLocaID, 50);
  }

  mRefItems = lItems;
  aItems = lItems;

}

/**
 * Quick getter function for a specific location needed
 * 
 * @param[in] aDatabaseIdx [int]
 * @param[in] aIdent [string]
 * 
 * @return XCOMDB_Ref_Location
 */
function XCOMDB_Ref_Location getDBRefLocation(int aDatabaseIdx, string aIdent)
{
  local array<XCOMDB_Ref_Location> lLocations;
  local int il;

  getDBRefLocations(aDatabaseIdx, lLocations);
  for(il=0; il<lLocations.Length; il++){
    if(lLocations[il].mIdent == aIdent){
      return lLocations[il];
    }
  }
  return none;
}

/**
 * Load all item locations from content database and fill up array with readed data.
 * 
 * @param[in] aDatabaseIdx [int]
 * @param[out] aLocations [array<XCOMDB_Ref_Location>]
 */
function getDBRefLocations(int aDatabaseIdx, out array<XCOMDB_Ref_Location> aLocations)
{
  local string lQuery;
  local XCOMDB_Ref_Location lNewLocation;
  local array<XCOMDB_Ref_Location> lLocations;
//	local int lResIdx;
  local int il;

  aLocations.Length = 0;

  if(mRefLocations.Length > 0){
    aLocations = mRefLocations;
    return;
  }

  lQuery = "SELECT ID, LocaID, Ident, SocketName FROM XCOM_LOCATIONS;";

  mDLLAPI.SQL_selectDatabase(aDatabaseIdx);
  if(mDLLAPI.SQL_queryDatabase(lQuery)){
    while(mDLLAPI.SQL_nextResult()){
      lNewLocation = Spawn(class'XCOMDB_Ref_Location');
      lNewLocation.mDBTable = "XCOM_LOCATIONS";

      `XCOMDB_InitString(lNewLocation.mIdent,50);
      `XCOMDB_InitString(lNewLocation.mSocketName,30);

      mDLLAPI.SQL_getIntVal("ID", lNewLocation.mDBId);
      mDLLAPI.SQL_getIntVal("LocaID", lNewLocation.mLocaID);
      mDLLAPI.SQL_getStringVal("Ident", lNewLocation.mIdent);
      mDLLAPI.SQL_getStringVal("SocketName", lNewLocation.mSocketName);

      lLocations[lLocations.Length] = lNewLocation;      
    }
  }
  
  for(il=0; il<lLocations.Length; ++il)
  {
    lLocations[il].mName = getLocalization(lLocations[il].mLocaID, 50);
  }

  mRefLocations = lLocations;
  aLocations = lLocations;
}

/**
 * Quick getter function for a specific modules needed
 * 
 * @param[in] aDatabaseIdx [int]
 * @param[in] aIdent [string]
 * 
 * @return XCOMDB_Ref_Module
 */
function XCOMDB_Ref_Module getDBRefModule(int aDatabaseIdx, string aIdent)
{
  local array<XCOMDB_Ref_Module> lModules;
  local int il;

  getDBRefModules(aDatabaseIdx, lModules);
  for(il=0; il<lModules.Length; il++){
    if(lModules[il].mIdent == aIdent){
      return lModules[il];
    }
  }
  return none;
}

/**
 * Load all modules from content database and fill up array with readed data.
 * 
 * @param[in] aDatabaseIdx [int]
 * @param[out] aModules [array<XCOMDB_Ref_Module>]
 */
function getDBRefModules(int aDatabaseIdx, out array<XCOMDB_Ref_Module> aModules)
{
  local string lQuery;
  local XCOMDB_Ref_Module lNewModule;
  local array<XCOMDB_Ref_Module> lModules;
  local array<XCOMDB_Ref_IMDetailInfo> lRefIMDetailInfos;
//	local int lResIdx;
  local int il;
  local string lIMDetailID;
  local string lGridSize;
  local array<string> lStringSplitted;

  aModules.Length = 0;

  if(mRefModules.Length > 0){
    aModules = mRefModules;
    return;
  }

  getDBRefIMDetailInfos(aDatabaseIdx, lRefIMDetailInfos);

  lQuery = "SELECT ID, Ident, LocaID, IMDetailInfoID, GridSize, Price FROM XCOM_MODULES;";

  mDLLAPI.SQL_selectDatabase(aDatabaseIdx);
  if(mDLLAPI.SQL_queryDatabase(lQuery)){
    while(mDLLAPI.SQL_nextResult()){
      lNewModule = Spawn(class'XCOMDB_Ref_Module');
      lNewModule.mDBTable = "XCOM_MODULES";

      `XCOMDB_InitString(lNewModule.mIdent,50);
      `XCOMDB_InitString(lIMDetailID,50);
      `XCOMDB_InitString(lGridSize,20);

      mDLLAPI.SQL_getIntVal("ID", lNewModule.mDBId);
      mDLLAPI.SQL_getStringVal("Ident", lNewModule.mIdent);
      mDLLAPI.SQL_getIntVal("LocaID", lNewModule.mLocaID);
      mDLLAPI.SQL_getStringVal("IMDetailInfoID", lIMDetailID);
      mDLLAPI.SQL_getStringVal("GridSize", lGridSize);
      mDLLAPI.SQL_getIntVal("Price", lNewModule.mPrice);

      lStringSplitted = SplitString(lGridSize);
      if(lStringSplitted.Length == 3){
        lNewModule.mGridSize[0] = int(lStringSplitted[0]);
        lNewModule.mGridSize[1] = int(lStringSplitted[1]);
        lNewModule.mGridSize[2] = int(lStringSplitted[2]);
      }

      for(il=0; il<lRefIMDetailInfos.Length; ++il){
        if(lRefIMDetailInfos[il].mIdent == lIMDetailID){
          lNewModule.mIMDetailInfo = lRefIMDetailInfos[il];
          break;
        }
      }

      lModules[lModules.Length] = lNewModule;      
    }
  }
  
  for(il=0; il<lModules.Length; ++il)
  {
    lModules[il].mName = getLocalization(lModules[il].mLocaID, 50);
  }

  mRefModules = lModules;
  aModules = lModules;
}

/**
 * Load all ranks from content database and fill up array with readed data.
 * 
 * @param[in] aDatabaseIdx [int]
 * @param[out] aRanks [array<XCOMDB_Ref_Rank>]
 */
function getDBRefRanks(int aDatabaseIdx, out array<XCOMDB_Ref_Rank> aRanks)
{
  local string lQuery;
  local XCOMDB_Ref_Rank lNewRank;
  local array<XCOMDB_Ref_Rank> lRanks;
//	local int lResIdx;
  local int il;

  aRanks.Length = 0;

  if(mRefRanks.Length > 0){
    aRanks = mRefRanks;
    return;
  }

  lQuery = "SELECT ID, LocaID, Ident FROM XCOM_RANKS;";

  mDLLAPI.SQL_selectDatabase(aDatabaseIdx);
  if(mDLLAPI.SQL_queryDatabase(lQuery)){
    while(mDLLAPI.SQL_nextResult()){
      lNewRank = Spawn(class'XCOMDB_Ref_Rank');
      lNewRank.mDBTable = "XCOM_RANKS";

      `XCOMDB_InitString(lNewRank.mIdent,30);

      mDLLAPI.SQL_getIntVal("ID", lNewRank.mDBId);
      mDLLAPI.SQL_getIntVal("LocaID", lNewRank.mLocaID);
      mDLLAPI.SQL_getStringVal("Ident", lNewRank.mIdent);

      lRanks[lRanks.Length] = lNewRank;      
    }
  }
  
  for(il=0; il<lRanks.Length; ++il)
  {
    lRanks[il].mName = getLocalization(lRanks[il].mLocaID, 50);
  }

  mRefRanks = lRanks;
  aRanks = lRanks;
}

/**
 * Load all shields from content database and fill up array with readed data.
 * 
 * @param[in] aDatabaseIdx [int]
 * @param[out] aShields [array<XCOMDB_Ref_Shield>]
 */
function getDBRefShields(int aDatabaseIdx, out array<XCOMDB_Ref_Shield> aShields)
{
  local string lQuery;
  local XCOMDB_Ref_Shield lNewShield;
  local array<XCOMDB_Ref_Shield> lShields;
//	local int lResIdx;
  local int il;

  aShields.Length = 0;

  if(mRefShields.Length > 0){
    aShields = mRefShields;
    return;
  }

  lQuery = "SELECT ID, LocaID, Ident, Power FROM XCOM_SHIELDS;";

  mDLLAPI.SQL_selectDatabase(aDatabaseIdx);
  if(mDLLAPI.SQL_queryDatabase(lQuery)){
    while(mDLLAPI.SQL_nextResult()){
      lNewShield = Spawn(class'XCOMDB_Ref_Shield');
      lNewShield.mDBTable = "XCOM_SHIELDS";

      `XCOMDB_InitString(lNewShield.mName,30);
      `XCOMDB_InitString(lNewShield.mIdent,30);

      mDLLAPI.SQL_getIntVal("ID", lNewShield.mDBId);
      mDLLAPI.SQL_getIntVal("LocaID", lNewShield.mLocaID);
      mDLLAPI.SQL_getStringVal("Ident", lNewShield.mIdent);
      mDLLAPI.SQL_getIntVal("Power", lNewShield.mPower);

      lShields[lShields.Length] = lNewShield;      
    }
  }
  
  for(il=0; il<lShields.Length; ++il)
  {
    lShields[il].mName = getLocalization(lShields[il].mLocaID, 50);
  }

  mRefShields = lShields;
  aShields = lShields;
}

/**
 * Load all ships from content database and fill up array with readed data.
 * 
 * @param[in] aDatabaseIdx [int]
 * @param[out] aShips [array<XCOMDB_Ref_Ship>]
 */
function getDBRefShips(int aDatabaseIdx, out array<XCOMDB_Ref_Ship> aShips)
{
  local string lQuery;
  local XCOMDB_Ref_Ship lNewShip;
  local array<XCOMDB_Ref_Ship> lShips;
  local array<XCOMDB_Ref_IMDetailInfo> lRefIMDetailInfos;
  local string lIMDetailID;
//	local int lResIdx;
  local int il;

  aShips.Length = 0;

  if(mRefShips.Length > 0){
    aShips = mRefShips;
    return;
  }

  getDBRefIMDetailInfos(aDatabaseIdx, lRefIMDetailInfos);

  lQuery = "SELECT ID, LocaID, Ident, IMDetailInfoID, Speed, Range, Acceleration, Fuel, WeaponSlots, Hull, Capacity, HWPSlots, Price FROM XCOM_SHIPS;";

  mDLLAPI.SQL_selectDatabase(aDatabaseIdx);
  if(mDLLAPI.SQL_queryDatabase(lQuery)){
    while(mDLLAPI.SQL_nextResult()){
      lNewShip = Spawn(class'XCOMDB_Ref_Ship');
      lNewShip.mDBTable = "XCOM_SHIPS";

      `XCOMDB_InitString(lNewShip.mIdent,30);
      `XCOMDB_InitString(lIMDetailID,50);

      mDLLAPI.SQL_getIntVal("ID", lNewShip.mDBId);
      mDLLAPI.SQL_getIntVal("LocaID", lNewShip.mLocaID);
      mDLLAPI.SQL_getStringVal("Ident", lNewShip.mIdent);
      mDLLAPI.SQL_getStringVal("IMDetailInfoID", lIMDetailID);
      mDLLAPI.SQL_getIntVal("Speed", lNewShip.mSpeed);
      mDLLAPI.SQL_getIntVal("Range", lNewShip.mRange);
      mDLLAPI.SQL_getIntVal("Acceleration", lNewShip.mAcceleration);
      mDLLAPI.SQL_getIntVal("Fuel", lNewShip.mFuel);
      mDLLAPI.SQL_getIntVal("WeaponSlots", lNewShip.mWeaponSlots);
      mDLLAPI.SQL_getIntVal("Hull", lNewShip.mHull);
      mDLLAPI.SQL_getIntVal("Capacity", lNewShip.mCapacity);
      mDLLAPI.SQL_getIntVal("HWPSlots", lNewShip.mHWPSlots);
      mDLLAPI.SQL_getIntVal("Price", lNewShip.mPrice);

      for(il=0; il<lRefIMDetailInfos.Length; ++il){
        if(lRefIMDetailInfos[il].mIdent == lIMDetailID){
          lNewShip.mIMDetailInfo = lRefIMDetailInfos[il];
          break;
        }
      }

      lShips[lShips.Length] = lNewShip;      
    }
  }
  
  for(il=0; il<lShips.Length; ++il)
  {
    lShips[il].mName = getLocalization(lShips[il].mLocaID, 50);
  }

  mRefShips = lShips;
  aShips = lShips;
}

/**
 * Quick getter function for a specific status needed
 * 
 * @param[in] aDatabaseIdx [int]
 * @param[in] aIdent [string]
 * 
 * @return XCOMDB_Ref_Status
 */
function XCOMDB_Ref_Status getDBRefStatus(int aDatabaseIdx, string aIdent)
{
  local array<XCOMDB_Ref_Status> lStatuses;
  local int il;

  getDBRefStatuses(aDatabaseIdx, lStatuses);
  for(il=0; il<lStatuses.Length; il++){
    if(lStatuses[il].mIdent == aIdent){
      return lStatuses[il];
    }
  }
  return none;
}

/**
 * Load all statuses from content database and fill up array with readed data.
 * 
 * @param[in] aDatabaseIdx [int]
 * @param[out] aStatuses [array<XCOMDB_Ref_Status>]
 */
function getDBRefStatuses(int aDatabaseIdx, out array<XCOMDB_Ref_Status> aStatuses)
{
  local string lQuery;
  local XCOMDB_Ref_Status lNewStatus;
  local array<XCOMDB_Ref_Status> lStatuses;
	//local int lResIdx;
  local int il;

  aStatuses.Length = 0;

  if(mRefStatuses.Length > 0){
    aStatuses = mRefStatuses;
    return;
  }

  lQuery = "SELECT ID, LocaID, Name FROM XCOM_STATUS;";

  mDLLAPI.SQL_selectDatabase(aDatabaseIdx);
  if(mDLLAPI.SQL_queryDatabase(lQuery)){
    while(mDLLAPI.SQL_nextResult()){
      lNewStatus = Spawn(class'XCOMDB_Ref_Status');
      lNewStatus.mDBTable = "XCOM_STATUS";

      `XCOMDB_InitString(lNewStatus.mIdent,50);

      mDLLAPI.SQL_getIntVal("ID", lNewStatus.mDBId);
      mDLLAPI.SQL_getIntVal("LocaID", lNewStatus.mLocaID);
      mDLLAPI.SQL_getStringVal("Ident", lNewStatus.mIdent);

      lStatuses[lStatuses.Length] = lNewStatus;      
    }
  }

  for(il=0; il<lStatuses.Length; ++il)
  {
    lStatuses[il].mName = getLocalization(lStatuses[il].mLocaID, 50);
  }

  mRefStatuses = lStatuses;
  aStatuses = lStatuses;
}

function string getLocalization(int aLocaId, int aMaxStringLen)
{
  local string lQuery;
  local string lResult;

  if(XCOMDB_Manager(Owner).mLanguage != "INT")
  {
    lQuery = "SELECT INT, "$XCOMDB_Manager(Owner).mLanguage$" FROM LOCALIZATION WHERE ID=@ID;";
  }
  else
  {
    lQuery = "SELECT INT FROM LOCALIZATION WHERE ID=@ID;";
  }

  mDLLAPI.SQL_prepareStatement(lQuery);
  mDLLAPI.SQL_bindNamedValueInt("@ID", aLocaId);

  mDLLAPI.SQL_selectDatabase(XCOMDB_Manager(Owner).mLocaDatabaseIdx);

	if(mDLLAPI.SQL_queryDatabase(lQuery))
	{
		while(mDLLAPI.SQL_nextResult())
		{
			  `XCOMDB_InitString(lResult,aMaxStringLen);

			  if(XCOMDB_Manager(Owner).mLanguage != "INT")
			  {
				mDLLAPI.SQL_getStringVal(XCOMDB_Manager(Owner).mLanguage, lResult);
				if(lResult == "")
				{
				  mDLLAPI.SQL_getStringVal("INT", lResult);
				}
			  }
			  else
			  {
				mDLLAPI.SQL_getStringVal("INT", lResult);
			  }
		}
	}

  return lResult;
}

DefaultProperties
{
  TickGroup=TG_DuringAsyncWork

	bHidden=TRUE
	Physics=PHYS_None
	bReplicateMovement=FALSE
	bStatic=FALSE
	bNoDelete=FALSE

	Name="Default__XCOMDB_Cache"
}
