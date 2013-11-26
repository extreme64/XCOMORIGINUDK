/**
 * X-Com pawn data container.
 * Special subclasses version used for creature and human characters.
 */
class X_COM_Stats_Pawn extends X_COM_Stats;


//=============================================================================
// Variables
//=============================================================================
var int mExperience;
var int mLevel;

var Vector mLocation;
var Rotator mRotation;


//=============================================================================
// Functions
//=============================================================================
/**
 * Set initial values and spawn data storage classes.
 */
event PostBeginPlay()
{
  super.PostBeginPlay();

  mPawnName = "";
  mAttributes = Spawn(class'X_COM_Attributes_Pawn', self);
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

  mLocation = X_COM_Pawn(Owner).Location;
  mRotation = X_COM_Pawn(Owner).GetViewRotation();

  lGameInfo = X_COM_GameInfo(WorldInfo.Game);
  lDBMgr = lGameInfo.getDBMgr();  
  lDLLAPI = lDBMgr.getDLLAPI();
  
  lDLLAPI.SQL_selectDatabase(lDBMgr.mGameplayDatabaseIdx);
  
  lQuery = "UPDATE PAWN_DATA SET PhotoID=@SyncPhotoID, Name=@SyncName, RankRef=@SyncRank, DefenseRef=@SyncDef, ShieldRef=@SyncShield, StatusRef=@SyncStatus, Gender=@SyncGender, Experience=@SyncExp, Level=@SyncLevel, Location=@SyncLoc, Rotation=@SyncRot WHERE PawnID=@ID";
  lDLLAPI.SQL_prepareStatement(lQuery);
  lDLLAPI.SQL_bindNamedValueInt("@SyncPhotoID", mPhotoID);
  lDLLAPI.SQL_bindNamedValueString("@SyncName", mPawnName);
  lDLLAPI.SQL_bindNamedValueInt("@SyncRank", mRank.mDBId);
  lDLLAPI.SQL_bindNamedValueInt("@SyncDef", mDefense.mDBId);
  lDLLAPI.SQL_bindNamedValueInt("@SyncShield", mShield.mDBId);
  lDLLAPI.SQL_bindNamedValueInt("@SyncStatus", mStatus.mDBId);
  lDLLAPI.SQL_bindNamedValueInt("@SyncGender", mGender);
  lDLLAPI.SQL_bindNamedValueInt("@SyncExp", mExperience);
  lDLLAPI.SQL_bindNamedValueInt("@SyncLevel", mLevel);
  lDLLAPI.SQL_bindNamedValueString("@SyncLoc", mLocation.X$","$mLocation.Y$","$mLocation.Z);
  lDLLAPI.SQL_bindNamedValueString("@SyncRot", mRotation.Pitch$","$mRotation.Yaw$","$mRotation.Roll);

  lDLLAPI.SQL_bindNamedValueInt("@ID", mPawnID);
  lDLLAPI.SQL_executeStatement();
  
  mAttributes.sync();
  
  X_COM_Pawn(Owner).notifyAttributesChanged();
}

/**
 * Sync with database => Read value from database
 */
function update()
{
  local int il;

  local X_COM_GameInfo lGameInfo;
  local XCOMDB_Manager lDBMgr;
  local XCOMDB_DLLAPI lDLLAPI;
  local array<XCOMDB_Ref_Rank> lDBRanks;
  local array<XCOMDB_Ref_Defense> lDBDefenses;
  local array<XCOMDB_Ref_Shield> lDBShields;
  local array<XCOMDB_Ref_Status> lDBStatuses;

  local int lRankRef;
  local int lDefenseRef;
  local int lShieldRef;
  local int lStatusRef;
  local int lGender;

  local string lQuery;
  local string lLocation;
  local string lRotation;
  local Vector lVecLocation;
  local Rotator lRotRotation;

  lGameInfo = X_COM_GameInfo(WorldInfo.Game);

  lDBMgr = lGameInfo.getDBMgr();
  lDBMgr.getDBCache().getDBRefRanks(0, lDBRanks);
  lDBMgr.getDBCache().getDBRefDefenses(0, lDBDefenses);
  lDBMgr.getDBCache().getDBRefShields(0, lDBShields);
  lDBMgr.getDBCache().getDBRefStatuses(0, lDBStatuses);

  lDLLAPI = lDBMgr.getDLLAPI();  
  lDLLAPI.SQL_selectDatabase(lDBMgr.mGameplayDatabaseIdx);
  
  lQuery = "SELECT PhotoID, Name, RankRef, DefenseRef, ShieldRef, StatusRef, Gender, Experience, Level, Location, Rotation FROM PAWN_DATA WHERE PawnID=@ID";
  lDLLAPI.SQL_prepareStatement(lQuery);
  lDLLAPI.SQL_bindNamedValueInt("@ID", mPawnID);
  if(lDLLAPI.SQL_executeStatement()){
    while(lDLLAPI.SQL_nextResult()){
      lDLLAPI.SQL_getIntVal("PhotoID", mPhotoID);

      `XCOM_InitString(mPawnName,60);
      lDLLAPI.SQL_getStringVal("Name", mPawnName);
      
      lDLLAPI.SQL_getIntVal("RankRef", lRankRef);
      lDLLAPI.SQL_getIntVal("DefenseRef", lDefenseRef);
      lDLLAPI.SQL_getIntVal("ShieldRef", lShieldRef);
      lDLLAPI.SQL_getIntVal("StatusRef", lStatusRef);

      for(il=0; il<lDBRanks.Length; il++){
        if(lDBRanks[il].mDBId == lRankRef){
          mRank = lDBRanks[il];
        }
      }
      for(il=0; il<lDBDefenses.Length; il++){
        if(lDBDefenses[il].mDBId == lDefenseRef){
          mDefense = lDBDefenses[il];
        }
      }
      for(il=0; il<lDBShields.Length; il++){
        if(lDBShields[il].mDBId == lShieldRef){
          mShield = lDBShields[il];
        }
      }
      for(il=0; il<lDBStatuses.Length; il++){
        if(lDBStatuses[il].mDBId == lStatusRef){
          mStatus = lDBStatuses[il];
        }
      }

      lDLLAPI.SQL_getIntVal("Gender", lGender);
      mGender = EXCOMGender(lGender);
      lDLLAPI.SQL_getIntVal("Experience", mExperience);
      lDLLAPI.SQL_getIntVal("Level", mLevel);

      `XCOM_InitString(lLocation,255);
      `XCOM_InitString(lRotation,255);
      lDLLAPI.SQL_getStringVal("Location", lLocation);
      lDLLAPI.SQL_getStringVal("Rotation", lRotation);
    }
  }
  if(lLocation != ""){
    `XCOM_String2Vec(lLocation,lVecLocation);
    X_COM_Pawn(Owner).SetLocation( lVecLocation );
  }
  
  if(lRotation != ""){
    `XCOM_String2Rot(lRotation,lRotRotation);
    X_COM_Pawn(Owner).setInstantRotation( lRotRotation );
  }
  
  mAttributes.update();
  
  X_COM_Pawn(Owner).notifyAttributesChanged();
}


DefaultProperties
{
	Name="Default__X_COM_Stats_Pawn"
}
