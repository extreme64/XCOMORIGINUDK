/**
 * X-COM Settings class. 
 */
class X_COM_Defines extends Object;

//=============================================================================
// Global game
//=============================================================================
enum EGameDifficult
{
	EGD_None,
	EGD_Easy,
	EGD_Normal,
	EGD_Hard,
};

//=============================================================================
// Effects and sounds
//=============================================================================
/** copy of struct native DistanceBasedParticleTemplate based in UDKPawn, just to make it editable in archetype */
struct native DistanceBasedParticleEffects
{
	/** the template to use */
	var() ParticleSystem Template;
	/** the minimum distance all local players must be from the spawn location for this template to be used */
	var() float MinDistance;
};

struct FootstepSoundInfo
{
	var() name MaterialType;
	var() SoundCue Sound;
};

//=============================================================================
// Weapons
//=============================================================================
enum EWeaponHoldTypes
{
	EWHT_None,
	EWHT_OneHanded,
	EWHT_TwoHanded,
	EWHT_Shoulder,
	EWHT_VehicleWeapon,
};

enum EWeaponTypes
{
	EWT_None,
	EWT_Pistol,
	EWT_Riffle,
	EWT_Launcher,
	EWT_Grenade,
	EWT_Melee,
};

enum EFiringModes
{
	EFM_None,
	EFM_Sniper,
	EFM_Burst,
	EFM_Snap,
};

enum EWeapon
{
	EW_None,
	EW_Human_Pistol_Military,
	EW_Human_Riffle_Military,
	EW_Human_Riffle_Heavy,
    EW_Human_Riffle_Laser,
	EW_Human_Grenade_HE,
	EW_Alien_Plasma_Riffle,
};

enum EAirWeapon
{
	EAVW_None,
	EAVW_CicadaMissile,
	EAVW_LaserBeam,
};

enum EVehicleWeapon
{
	EVW_None,

};

enum EHumanAirVehicle
{
	EHAV_None,
	EHAV_Buran,

};


enum EAlienAirVehicle
{
	EAAV_None,
	EAAV_UFO,
};

enum EAlienEventType
{
	EAET_None,
	EAET_CrashSite,
	EAET_Terror,
	EAET_Base,
};

//=============================================================================
// Enums: global
//=============================================================================
/** Two teams for know who is enemy/friend */
enum ETeams
{
	ET_None,
	ET_HUMAN_Player_1,
	ET_HUMAN_Player_2,
	ET_ALIEN,
	ET_CIVILIAN,
	ET_ANIMAL,
};

enum EGlobalEvents
{
	EGE_None,
	EGE_TimeSync,
};

enum Ecell_type 
{
	ct_none, //не определено

	ct_passable,  // клетка проходима
	ct_obstacle,  // в клетке препятствие - клетка непроходима

	// возможно, что следующие значения избыточны
	ct_ladder,  // лестница
	ct_NA,
	// сюда же могут быть добавлены препятствия с круглыми углами, всякие лифты и лестницы
	// здесь же может быть отмечен и туман войны
};

enum EPosition
{
	EP_None,
	EP_Standing,
	EP_Sitting,
	EP_Howering,
};

//=============================================================================
// Defence, Shields, Zone Damage
//=============================================================================
enum EDamageTypes
{
	EDT_None,
	EDT_Mechanical,
	EDT_Energy,
	EDT_Bio,
	EDT_Thermal,
};

struct ArmorDefenceParameters
{
	var() int Head;
	var() int Torso;
	var() int Arms;
	var() int Legs;
	var() int Other;
	var() EDamageTypes DefenceFrom;
};

enum EArmorDefenceTypes
{
	EXADT_None,
	EXADT_Standart,      //Recruting soldier have this default type of armor
	EXADT_Light,         //Light armor
	EXADT_Heavy,         //Heavy armor I
	EXADT_Space          //Space armor
};

enum EShieldTypes
{
	EST_None,
	EST_Laser,
	EST_Plasma,
	EST_Particle
};

//=============================================================================
// Soldier status. Aliens use less states (only active/died)
//=============================================================================
enum EUnitState
{
	ESS_None,
	ESS_Active,         //Alive and active soldier/alien and not wounded
	ESS_Wounded,        //Wounded but alive and active
	ESS_Critical,	    //Critically wounded and out of consciousness but alive and not active
	ESS_Died,           //Died soldier/alien
	ESS_AtRessurection, //Died soldier can be ressurected at base. Need to think about ressurection time characteristic. Or maybe we will not use it
	ESS_AtHospital		//Wounded soldier can be healed at hospital
};

//=============================================================================
// Human and alien ranks
//=============================================================================
enum EHumanSoldierRanks
{
	EXSR_None,
	EXSR_Recruit,
	EXSR_Soldier,
	EXSR_Sergeant,
	EXSR_Lieutenant,
	EXSR_Captain,
	EXSR_Commander
};

enum EAlienSoldierRanks
{
	EASR_None,
	EASR_Soldier,
	EASR_Leader,
	EASR_Commander,
	EASR_Medic,
	EASR_Navigator,
	EASR_Scientist
};

//=============================================================================
// Human and alien races
//=============================================================================
enum ECreatureRace
{
	ECT_None,
	ECT_Human,
	ECT_Alien
};

enum ECreatureSex
{
	EHCK_None,
	EHCK_Male, 
	EHCK_Female
};

enum EAliens
{
	EA_None,
	EA_Sectoid, 
	EA_High,
	EA_Dog,
};

//=============================================================================
// Structures: main
//=============================================================================

struct GameDate 
{
	var int     Year;
	var int     Month;
	var int     Day;
};

struct GameTime
{
	var int     Hours;
	var int     Minutes;
	var int     Seconds;
};

struct GameDateTime
{
	var GameDate	Date;
	var GameTime	Time;
};

//=============================================================================
// Functions: static main.
//=============================================================================
/** Gives max property of vector without sign **/
static function float MaxOfVector( vector V)                                                       
{
	if ( (abs(V.X)>abs(V.Y)) || (abs(V.X)>abs(V.Z)) ) return  V.X;
	else if( abs(V.Y)>(abs(V.Z)) ) return  V.Y;
	else return  V.Z;
}

/** Checks almost equality of vector **/
static function bool VectorsAlmostEqual( vector A, vector B, float aEqualityNumber)                                                       
{
	if ( abs(Vsize(A - B)) > abs(aEqualityNumber) ) return false;
	else return true;
}

/** Checks almost equality of float numbers **/
static function bool NumbersAlmostEqual( float A, float B, float aEqualityNumber)                                                       
{
	if ( abs(A-B) > abs(aEqualityNumber) ) return false;
	else return true;
}

/**
* Static method to create an empty string object with given length.
* Used in conjunction with DLLBind functions, because memory has to be allocated before assign any data.
* 
* @param aStrLen [int]
* 
* @return string
*/
static function string initString(int aStrLen)
{
	local int il;
	local string aResult;
	for(il=0; il<aStrLen; ++il){
		aResult $= " ";
	}
	return aResult;
}

/** 
 * String a vector from an input string like: X.X,Y.Y,Z.Z 
 *  
 * @param [in] aStr [string] 
 *  
 * @return Vector 
 */ 
static function Vector string2Vec(string aStr) 
{ 
	local Vector lVector; 
	local array<string> lStringSplitted; 
 
    lStringSplitted = SplitString(aStr); 
	if(lStringSplitted.Length == 3)
	{ 
		lVector.X = float(lStringSplitted[0]); 
		lVector.Y = float(lStringSplitted[1]); 
		lVector.Z = float(lStringSplitted[2]); 
	} 
    return lVector; 
}

/** 
 * String a rotator from an input string like: X.X,Y.Y,Z.Z 
 *  
 * @param [in] aStr [string] 
 *  
 * @return Rotator 
 */ 
static function Rotator string2Rot(string aStr) 
{ 
	local Rotator lRotator; 
	local array<string> lStringSplitted; 
 
    lStringSplitted = SplitString(aStr); 
	if(lStringSplitted.Length == 3)
	{ 
		lRotator.Pitch = float(lStringSplitted[0]); 
		lRotator.Yaw = float(lStringSplitted[1]); 
		lRotator.Roll = float(lStringSplitted[2]); 
	} 
    return lRotator; 
}

//=============================================================================
// Functions: static datetime. Conversion
//=============================================================================
static function GameDateTime String2DateTime(string aDate, string aTime)
{ 
    local GameDateTime lDateTime; 
	lDateTime.Date = String2Date(aDate);
	lDateTime.Time = String2Time(aTime);
    return lDateTime; 
}

static function GameDate String2Date(string aDate)
{ 
    local GameDate lDate; 
	local array<string> lStringSplitted; 
 
    lStringSplitted = SplitString(aDate); 
	if(lStringSplitted.Length == 3)
	{ 
		lDate.Year = float(lStringSplitted[0]); 
		lDate.Month = float(lStringSplitted[1]); 
		lDate.Day = float(lStringSplitted[2]); 
	} 
    return lDate; 
}

static function GameTime String2Time(string aTime)
{ 
    local GameTime lTime; 
	local array<string> lStringSplitted; 
 
    lStringSplitted = SplitString(aTime); 
	if(lStringSplitted.Length == 3)
	{ 
		lTime.Hours = float(lStringSplitted[0]); 
		lTime.Minutes = float(lStringSplitted[1]); 
		lTime.Seconds = float(lStringSplitted[2]); 
	} 
    return lTime; 
}

//=============================================================================
// DefaultProperties
//=============================================================================
DefaultProperties
{
}
