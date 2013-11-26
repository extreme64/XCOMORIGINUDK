/**
 * X-Com attribute container class.
 * Keep informations about all attributes used by a character.
 */
class X_COM_Attributes extends Actor
	implements(X_COM_Interface_Database);

//=============================================================================
// Variables
//=============================================================================
var array<X_COM_Attribute> mAttributes;


function update(); //delete
function sync(); //delete

/*
//=============================================================================
// Functions
//=============================================================================
/**
 * Set initial values.
 */
event PostBeginPlay()
{
  super.PostBeginPlay();
}

/**
 * Get the assigned attribute by given identifier.
 * 
 * @param[in] aAttributeIdent [string]
 * 
 * @return X_COM_Attribute
 */
function X_COM_Attribute findAttribute(string aAttributeIdent)
{
  local int il;

  for(il=0; il<mAttributes.Length; ++il){
    if(mAttributes[il].mReference.mIdent == aAttributeIdent){
      return mAttributes[il];
    }
  }

  return none;
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
  local int il;

  lGameInfo = X_COM_GameInfo(WorldInfo.Game);
  lDBMgr = lGameInfo.getDBMgr();  
  lDLLAPI = lDBMgr.getDLLAPI();
  
  lDLLAPI.SQL_selectDatabase(lDBMgr.mGameplayDatabaseIdx);
  
  lQuery = "UPDATE PAWN_ATTRIBUTES SET Value=@SyncValue WHERE ID=@ID";
  lDLLAPI.SQL_prepareStatement(lQuery);
  for(il=0; il<mAttributes.Length; ++il){
    lDLLAPI.SQL_bindNamedValueInt("@SyncValue", mAttributes[il].mValue);
    lDLLAPI.SQL_bindNamedValueInt("@ID", mAttributes[il].mDBID);
    lDLLAPI.SQL_executeStatement();
  }
}

/**
 * Sync with database => Read value from database
 */
function update()
{
  local X_COM_GameInfo lGameInfo;
  local XCOMDB_Manager lDBMgr;
  local XCOMDB_DLLAPI lDLLAPI;
  local array<XCOMDB_Ref_Attribute> lDBAttributes;
  local int lAttribID;
  local int lAttribRef;
  local int lAttribValue;
  local int il;
  local X_COM_Attribute lNewAttribute;
  local string lQuery;
  local bool lAttribAvailable;

  lGameInfo = X_COM_GameInfo(WorldInfo.Game);

  lDBMgr = lGameInfo.getDBMgr();
  lDBMgr.getDBCache().getDBRefAttributes(0, lDBAttributes);

  lDLLAPI = lDBMgr.getDLLAPI();  
  lDLLAPI.SQL_selectDatabase(lDBMgr.mGameplayDatabaseIdx);
  
  lQuery = "SELECT ID, AttributeRef, Value FROM PAWN_ATTRIBUTES WHERE PawnID=@ID ORDER BY AttributeRef";
  lDLLAPI.SQL_prepareStatement(lQuery);
  lDLLAPI.SQL_bindNamedValueInt("@ID", X_COM_Stats_Pawn(Owner).mPawnID);
  if(lDLLAPI.SQL_executeStatement()){
    while(lDLLAPI.SQL_nextResult()){
      lDLLAPI.SQL_getIntVal("ID", lAttribID);
      lDLLAPI.SQL_getIntVal("AttributeRef", lAttribRef);
      lDLLAPI.SQL_getIntVal("Value", lAttribValue);

      lAttribAvailable = false;
      for(il=0; il<mAttributes.Length; ++il){
        if(mAttributes[il].mReference.mDBId == lAttribRef){
          mAttributes[il].mValue = lAttribValue;
          lAttribAvailable = true;
        }
      }
      if(!lAttribAvailable){
        for(il=0; il<lDBAttributes.Length; ++il){
          if(lDBAttributes[il].mDBId == lAttribRef){
            lNewAttribute = Spawn(class'X_COM_Attribute');
            lNewAttribute.mDBId = lAttribID;
            lNewAttribute.mReference = lDBAttributes[il];
            lNewAttribute.mValue = lAttribValue;
            mAttributes[mAttributes.Length] = lNewAttribute;
          }
        }
      }
    }
  }
}

*/

DefaultProperties
{
  TickGroup=TG_DuringAsyncWork

	bHidden=TRUE
	Physics=PHYS_None
	bReplicateMovement=FALSE
	bStatic=FALSE
	bNoDelete=FALSE

	Name="Default__X_COM_Attributes"
}
