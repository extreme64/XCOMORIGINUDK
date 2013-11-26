/**
 * Factory creatures class
 * Uses to get data of Aliens and Humans from DB
 * Uses to place humans and aliens to map
 */
class xcT_Factory_Units extends Actor notplaceable;

//=============================================================================
// Variables
//=============================================================================
var xcT_GameInfo                        mGameInfo;
//var X_COM_DatabaseMgr                   mDBmgr;
//var X_COM_DLLAPI                        mDLLAPI;
var Rotator                             SpawnRotation; //Rotation of creature.
var array<int>                          AlienAutoIncrementLevel; //TEST!!!!!
var array<int>                          HumanPawnID; //Pawn characteristics

var class<X_COM_Unit>                   DefaultPawnClass;

//=============================================================================
// Events
//=============================================================================
event PreBeginPlay()
{
	Super.PreBeginPlay();
}

event PostBeginPlay()
{
	Super.PostBeginPlay();	
	mGameInfo = xcT_GameInfo(WorldInfo.Game);
}

//=============================================================================
// Functions: Spawn correction
//=============================================================================
/** Trace Actor under location */
function Actor ActorUnderTraceLocation(vector aTraceLocation)
{
	local Vector lTraceLocation,lHitLocation, lHitNormal;
	local Vector lTraceStart, lTraceEnd;	
	local Actor lActor;
	lActor = none;	
	lTraceLocation = aTraceLocation;
	lTraceLocation.z = -32;
	lTraceStart = lTraceLocation+vect(0,0,780);
	lTraceEnd = lTraceLocation;
	lActor=Trace(lHitLocation, lHitNormal, lTraceEnd, lTraceStart, true);
	return lActor;
}

/** If under creature is not ground then we need location correction */
function bool CheckCorrectionNeeded(Actor aActorUnder)
{
	local bool  lResult;
  if(aActorUnder==none) return false;
	lResult = true;
	//if ((aActorUnder.isA('Terrain')) || (aActorUnder.isA('X_COM_Tile'))) lResult = false; 
	if (aActorUnder.isA('X_COM_Tile')) lResult = false; 
	return lResult;
}


function vector GetNewGridLocationX(vector aOLDLocation)
{
	local vector lNewGridLocation;
	lNewGridLocation = aOLDLocation;
	lNewGridLocation.x = aOLDLocation.x + class'X_COM_Settings'.default.T_GridSize.x/2;
	return lNewGridLocation;
}

function vector GetNewGridLocationY(vector aOLDLocation)
{
	local vector lNewGridLocation;
	lNewGridLocation = aOLDLocation;
	lNewGridLocation.y = aOLDLocation.y + class'X_COM_Settings'.default.T_GridSize.y/2;
	return lNewGridLocation;
}

function vector CorrectSpawnLocation(vector aSpawnLocation)
{
	local bool  bDoCorrection;
	local vector lCorrectedLocation;

	bDoCorrection=TRUE;
	
	lCorrectedLocation = aSpawnLocation; 
	bDoCorrection = CheckCorrectionNeeded(ActorUnderTraceLocation(lCorrectedLocation));
	while (bDoCorrection)
	{
		lCorrectedLocation = GetNewGridLocationX(lCorrectedLocation);
		bDoCorrection = CheckCorrectionNeeded(ActorUnderTraceLocation(lCorrectedLocation));
		if (bDoCorrection)
		{
			lCorrectedLocation = GetNewGridLocationY(lCorrectedLocation);
			bDoCorrection = CheckCorrectionNeeded(ActorUnderTraceLocation(lCorrectedLocation));
		}
		`log("Spawn Location Corrected from : "$aSpawnLocation$" to "$lCorrectedLocation);
	}
	return lCorrectedLocation;
}

//=============================================================================
// Functions: Add creatures to map
//=============================================================================
public function AddUnitsFor(X_COM_PlayerController aPC)
{
	AddXCOM(aPC, aPC.Location+vect(100,0,0), aPC.Rotation, 0, EXADT_Standart); // test
	AddXCOM(aPC, aPC.Location+vect(0,100,0), aPC.Rotation, 1, EXADT_Light); // test
}

public function AddAliens(EAliens aAliens, int AliensQuantity, int aTeam)
{
	local int il;

	for(il=0; il<AliensQuantity; ++il)
	{
		AddUFOs(aAliens, aTeam); // Add aliens to map
	}
}

//function AddUnits(vector aSpawnLocation, rotator aSpawnRotation, EAliens aAliens, int AliensQuantity, int aTeam)
//{
//	local int il;
//	local XCOMDB_Manager lDBMgr;
//	local XCOMDB_DLLAPI lDLLAPI;
//	local string lQuery;
//	local int lPawnID;

//	local string lLocation;
//	local string lRotation;
//	local array<Vector> lHumanLocation;
//	local array<Rotator> lHumanRotation;

//	lDBMgr = mGameInfo.getDBMgr();
//	lDLLAPI = lDBMgr.getDLLAPI();

//	lDLLAPI.SQL_selectDatabase(lDBMgr.mGameplayDatabaseIdx);

//	HumanPawnID.remove(0,HumanPawnID.Length);

//	lQuery = "SELECT P.ID, PD.Location, PD.Rotation " $
//           "FROM PAWNS AS P "$
//           "LEFT JOIN PAWN_DATA AS PD ON P.ID = PD.PawnID;";

//	if(lDLLAPI.SQL_queryDatabase(lQuery))
//	{
//		while(lDLLAPI.SQL_nextResult())
//		{
//			lDLLAPI.SQL_getIntVal("ID", lPawnID);
	      
//			`XCOM_InitString(lLocation,255);
//			`XCOM_InitString(lRotation,255);
//			lDLLAPI.SQL_getStringVal("Location", lLocation);
//			lDLLAPI.SQL_getStringVal("Rotation", lRotation);
	      
//			HumanPawnID[HumanPawnID.Length] = lPawnID;
//			`XCOM_String2Vec(lLocation,lHumanLocation[lHumanLocation.Length]);
//			`XCOM_String2Rot(lRotation,lHumanRotation[lHumanRotation.Length]);
//		}
//	}

//	// Get rest of human data from content DB
//	for(il=0; il<HumanPawnID.Length; ++il)
//	{
//		//AddXCOM(aSpawnLocation+lHumanLocation[il], aSpawnRotation+lHumanRotation[il], il); // Add soldier to map
//		//`log("--------AddXCOM-----------");
//	}
//	AddXCOM(aTeam, aSpawnLocation+vect(50,0,0), aSpawnRotation, 0, EXADT_Standart); // test
//	AddXCOM(aTeam, aSpawnLocation+vect(0,50,0), aSpawnRotation, 1, EXADT_Light); // test

//	/** Aliens **/
//	for(il=0; il<AliensQuantity; ++il)
//	{
//		//AddUFOs(aAliens); // Add aliens to map
//	}

//}

/* // NOT NEEDED???
/** Fill Data array from gameplay DB */
function GetHumanData()
{
	local X_COM_Pawn_Data Data;
	local int lPhotoID, tmpINT;
		
	Data = new()class'X_COM_PawnData';
	Data.InitStrings();

	//Data.Race.CreatureType = ECT_Human;
	//mDLLAPI.SQL_getValueString(3, Data.DisplayName);
	//mDLLAPI.SQL_getValueInt(4, tmpINT);
	//Data.Race.HumanCreatureKind = EHumanCreatureKinds((tmpINT));
	//mDLLAPI.SQL_getValueInt(5, lPhotoID);
	//if (Data.Race.HumanCreatureKind == EHCK_Male)
	//	Data.Photo = (Texture2D(DynamicLoadObject("xc_Faces.Human.Male.Textures.Face0"$lPhotoID,class'Texture2D')));
	//else
	//	Data.Photo = (Texture2D(DynamicLoadObject("xc_Faces.Human.Female.Textures.Face0"$lPhotoID,class'Texture2D')));
	//mDLLAPI.SQL_getValueInt(6, tmpINT);
	//Data.Rank.HumanRankType = EHumanSoldierRanks((tmpINT));
	//mDLLAPI.SQL_getValueInt(7, Data.Experience);
	//mDLLAPI.SQL_getValueInt(8, Data.Level);
	//mDLLAPI.SQL_getValueInt(9, tmpINT);
	//Data.Armor.HumanDefenceType = EHumanArmorDefenceTypes((tmpINT));
	//mDLLAPI.SQL_getValueInt(10, Data.Dexterity);
	//mDLLAPI.SQL_getValueInt(11, Data.Vitality);
	//mDLLAPI.SQL_getValueInt(12, Data.Bravery);
	//mDLLAPI.SQL_getValueInt(13, Data.PainfulThreshold);
	//mDLLAPI.SQL_getValueInt(14, Data.Strength);
	//mDLLAPI.SQL_getValueInt(15, Data.Reaction);
	//mDLLAPI.SQL_getValueInt(16, Data.FiringAccuracy);
	//mDLLAPI.SQL_getValueInt(17, Data.ThrowingAccuracy);
	//mDLLAPI.SQL_getValueInt(18, Data.PsionicPower);
	//mDLLAPI.SQL_getValueInt(19, tmpINT);
	//Data.Shield.ShieldType = EShieldTypes(tmpINT);

	HumanData.AddItem(Data);

	//For increment alien level. See CreateUFOsSoldier()
	//AlienAutoIncrementLevel.AddItem(Data.Level); // CreateXComSoldier????
}
*/
/** Add soldiers to map */
function AddXCOM(X_COM_PlayerController aPC, vector aSpawnLocation, rotator aSpawnRotation, int Index, EArmorDefenceTypes aArmor)
{
	local X_COM_Pawn_Human lNewPawn;

	aSpawnLocation = class'xcT_Defines'.static.GetGridCoord(aSpawnLocation);
	aSpawnRotation.Pitch = 0;
	aSpawnRotation.Roll = 0;

	lNewPawn = WorldInfo.Spawn(class'X_COM_Settings'.default.Humans[aArmor].Class, aPC,,aSpawnLocation,aSpawnRotation, class'X_COM_Settings'.default.Humans[aArmor], true);
	if(lNewPawn != None)
	{
		lNewPawn.Dexterity += 1000;
		lNewPawn.InitUnitData();
		lNewPawn.ChangeController(lNewPawn.DefaultAiClass);
		lNewPawn.SetTeam(Eteams(aPC.GetTeamNum()));
		lNewPawn.SetMasterController(aPC);
		aPC.AllUnitsAddUnit(lNewPawn);

		//lNewPawn.mStats.mPawnID = HumanPawnID[Index];
		//lNewPawn.mStats.update(); // internal Location/Rotation update...maybe applay replacement after his again!!
		//CreateXCOMSoldier(lNewPawn, Index);


		//lNewPawn.GiveWeapon(EW_Human_Riffle_Laser, true); //дать в инвентарь и не активировать
		lNewPawn.GiveWeapon(EW_Alien_Plasma_Riffle); //дать в инвентарь и активировать, при активации оружие встанет в руки	
	}
	else `log("ERROR: Pawn Spawn Failure");
}

function CreateXCOMSoldier(X_COM_Pawn_Human aPawn, int Index)
{
	//local X_COM_Weapons WeaponTemplate; //????????
	///local X_COM_Data_Pawn lData;

	//aPawn.Level = 1;
	//aPawn.Vitality = 100;
	//aPawn.Dexterity = 1000;
	//aPawn.FiringAccuracy = 100;

	//aPawn.InitUnitData();

	//Life - Should be updated on PawnData.update before!
	//aPawn.Health = aPawn.Data.HealthUnitsRemain;
	//aPawn.HealthMax = aPawn.Data.HealthUnits;

	//Weapon:
	//aPawn.CreateInventory(class'xcT_Weapon_Pawn_Riffle');
	//aPawn.CreateInventory(class'xcT_Weapon_Pawn_Grenade');
	//aPawn.CreateInventory(class'xcT_Weapon_Pawn_Alien_Plasma_Riffle');
	//aPawn.CreateInventory(class'xcT_Weapon_Pawn_Beam_Human_LaserRiffle');

	//X_COM_InventoryManager(aPawn.InvManager).InventoryChainLast.ActivateItem();
}

/*
function CreateXCOMSoldier(X_COM_Pawn_Human aPawn, int Index)
{
	local xcT_Weapons WeaponTemplate; //????????
	local X_COM_Data_Pawn lData;

	lData = X_COM_Data_Pawn(aPawn.mData);

	/*
	aPawn.Data = HumanData[Index]; //get pawn data from array with index
	aPawn.Data.InitUnitsData();
	*/

	AlienAutoIncrementLevel.AddItem(lData.Level);

	//Mesh:
	switch (aPawn.mStats.mDefense.mIdent)
	{
		case "armor_standard"     :	aPawn.Mesh.SetSkeletalMesh(CreateCreatureMesh("xc_M_sol_LA.Mesh.xc_M_sol_LA"));
									//aPawn.CylinderComponent.SetCylinderSize(25,5);
									aPawn.Mesh.SetPhysicsAsset(CreateCreaturePhysAsset("CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics"), true);						
		break;
		case "armor_light"        :	aPawn.Mesh.SetSkeletalMesh(CreateCreatureMesh("xc_M_sol_MA.Mesh.xc_M_sol_Armor1"));
									aPawn.Mesh.SetPhysicsAsset(CreateCreaturePhysAsset("CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics"), true);						
		break;
		case "armor_heavy"        :	aPawn.Mesh.SetSkeletalMesh(CreateCreatureMesh("CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA"));
									aPawn.Mesh.SetPhysicsAsset(CreateCreaturePhysAsset("CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics"), true);						
		break;
		case "armor_heavyfly"     :	aPawn.Mesh.SetSkeletalMesh(CreateCreatureMesh("CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA"));
									aPawn.Mesh.SetPhysicsAsset(CreateCreaturePhysAsset("CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics"), true);						
		break;
		case "armor_exoskeleton"	:	aPawn.Mesh.SetSkeletalMesh(CreateCreatureMesh("CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA"));
									aPawn.Mesh.SetPhysicsAsset(CreateCreaturePhysAsset("CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics"), true);						
		break;
		case "armor_space"        :	aPawn.Mesh.SetSkeletalMesh(CreateCreatureMesh("CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA"));
									aPawn.Mesh.SetPhysicsAsset(CreateCreaturePhysAsset("CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics"), true);						
		break;
	}
	
	//Life - Should be updated on PawnData.update before!
	//aPawn.Health = aPawn.Data.HealthUnitsRemain;
	//aPawn.HealthMax = aPawn.Data.HealthUnits;

	//Weapon:
	WeaponTemplate = spawn(class'xcT_Weapons_Riffle');
	//WeaponTemplate=spawn(class'xcT_Weapons_Grenade');
  WeaponTemplate.GivenTo(aPawn);
	//aPawn.CreateInventoryFromTemplate(WeaponTemplate); //give it weapon 
}
*/

/** Add aliens to map */
function AddUFOs(EAliens aAlien, int aTeam)
{
	local X_COM_Pawn_Alien lNewPawn;
	local vector lNewLocation;
	local rotator lNewRotation;

	lNewLocation = vect(0,0,0);
	lNewRotation = rot(0,0,0);

	lNewLocation.x=float(rand(class'X_COM_Settings'.default.T_LevelSize.X));
	lNewLocation.y=float(rand(class'X_COM_Settings'.default.T_LevelSize.Y));
	lNewLocation=CorrectSpawnLocation(class'xcT_Defines'.static.GetGridCoord(lNewLocation));
	lNewLocation.z=64;
	lNewRotation.YAW=Rand(65536);

	lNewPawn = WorldInfo.Spawn(class'X_COM_Settings'.default.Aliens[aAlien].Class, ,,lNewLocation,lNewRotation, class'X_COM_Settings'.default.Aliens[aAlien], true);
	if(lNewPawn != None)
	{
		CreateUFOsSoldier(lNewPawn, aAlien);
		lNewPawn.InitUnitData();
		lNewPawn.ChangeController(lNewPawn.DefaultAiClass); //or defaultAicontroller if it set in archetype
		lNewPawn.SetTeam(ETeams(aTeam));
		mGameInfo.Alien_AI.RegisterSquadUnit(lNewPawn);
		

		lNewPawn.GiveWeapon(EW_Alien_Plasma_Riffle); //дать в инвентарь и активировать, при активации оружие встанет в руки


		lNewPawn.SetInvisible(true);
	}
	else `log("ERROR: Pawn Spawn Failure");
}

function CreateUFOsSoldier(X_COM_Pawn_Alien aPawn, EAliens aAliens)
{
	//local xcT_Weapons WeaponTemplate; //????????
	local int il;
	local float AlienLevelModifier; //Level Modifier depends on x-com higher soldier level.
	local float RaceModifier; //Race Modifier depends on alien race
	local float RankModifier; //Rank Modifier
	local int NewAlienLevel;

	aPawn.Race = ECT_Alien;

//	mDLLAPI.SQL_selectDatabase(mDBmgr.mContentDatabaseIdx);

	switch (aAliens)
	{
		case EA_Sectoid	    :  	aPawn.UnitName = "Sectoid"; //should be get from localization DB
								RaceModifier = 1 + (RandRange(1,2)/10);
		break;
	}
	
	//Status
	aPawn.UnitState = ESS_Active; 

	//EAlienSoldierRanks
	//NEED to think about preority for soldiers! because soldiers should be most of alien team
	switch (Rand(6)+1)
	{
		case EASR_Soldier	    :   aPawn.Rank = EASR_Soldier;
									RankModifier=1.05;
		break;
		case EASR_Leader	    :   aPawn.Rank = EASR_Leader;
									RankModifier=1.10;  
		break;
		case EASR_Commander	    :   aPawn.Rank = EASR_Commander;
									RankModifier=1.15;
		break;
		case EASR_Medic	        :   aPawn.Rank = EASR_Medic;
									RankModifier=0.85;
		break;
		case EASR_Navigator	    :   aPawn.Rank = EASR_Navigator;
									RankModifier=0.95;
		break;
		case EASR_Scientist	    :   aPawn.Rank = EASR_Scientist;
									RankModifier=0.90;
		break;
	}

	aPawn.Experience = 0; //not used for aliens

	//Set up level modifier:
	AlienLevelModifier = 0;
	for(il=0;il<AlienAutoIncrementLevel.Length; ++il) //looking for the highest x-com level
	{
		if (AlienLevelModifier < AlienAutoIncrementLevel[il]) NewAlienLevel = AlienAutoIncrementLevel[il]; 
	}
	
	AlienLevelModifier = 1 + (NewAlienLevel)/50; // EXAMPLE : if x-com soldier level = 10 then alien Data multiplyed on 1.2 (20%)

	aPawn.Level = NewAlienLevel + Rand(5);

	//Set up Data with modifier:
	aPawn.Dexterity += int(AlienLevelModifier * RaceModifier * RankModifier * RandRange(50,60));
	aPawn.Vitality += int(AlienLevelModifier * RaceModifier * RankModifier * RandRange(50,60));
	aPawn.Bravery += int(AlienLevelModifier * RaceModifier * RankModifier * RandRange(50,60));
	aPawn.Strength += int(AlienLevelModifier * RaceModifier * RankModifier * RandRange(50,60));
	aPawn.Reaction += int(AlienLevelModifier * RaceModifier * RankModifier * RandRange(50,60));
	aPawn.FiringAccuracy += int(AlienLevelModifier * RaceModifier * RankModifier * RandRange(50,60));
	aPawn.ThrowingAccuracy += int(AlienLevelModifier * RaceModifier * RankModifier * RandRange(50,60));

	aPawn.InitUnitData();

	//Life
	aPawn.Health = aPawn.HealthUnitsRemain;
	aPawn.HealthMax = aPawn.HealthUnits;

	//Weapon:
	//aPawn.CreateInventory(class'xcT_Weapon_Pawn_Gun_Alien_Plasma_Riffle');
	//X_COM_Inventory(aPawn.InvManager.InventoryChain).ActivateItem();

	aPawn.SetFireMode(EFM_Burst);
}

//=============================================================================
// Functions: Dynamically load objects
//=============================================================================
function SkeletalMesh CreateCreatureMesh(string aObjectName)
{
	return SkeletalMesh(DynamicLoadObject(aObjectName,class'SkeletalMesh'));
}

function PhysicsAsset CreateCreaturePhysAsset(string aObjectName)
{
	return PhysicsAsset(DynamicLoadObject(aObjectName,class'PhysicsAsset'));
}

function AnimSet CreateCreatureAnimSet(string aObjectName)
{
	return AnimSet(DynamicLoadObject(aObjectName,class'AnimSet'));
}

function AnimTree CreateCreatureAnimTree(string aObjectName)
{
	return AnimTree(DynamicLoadObject(aObjectName,class'AnimTree'));
}

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
	DefaultPawnClass = class'X_COM_Pawn'
}
