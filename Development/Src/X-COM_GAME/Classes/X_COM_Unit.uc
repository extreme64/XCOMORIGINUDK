class X_COM_Unit extends UDKPawn
	abstract
	dependson(X_COM_InventoryManager)
	dependson(X_COM_Weapon)
	dependson(X_COM_Defines)
	dependson(X_COM_PhysicalMaterialProperty)
	hidecategories(TeamBeacon, Swimming, UDKPawn, Movement, Debug, Display, Attachment, Collision, Physics, Advanced, Object)
	ClassGroup(XCOM);

//=============================================================================
// Basic
//=============================================================================
/** Weapon and items which will be given to unit at spawn time */
var(XCOM_Inventory) protected array<X_COM_Inventory>    InventoryItems;
/** Default physics state */
var(XCOM_Unit) EPhysics                                 DefaultPhysics; 
/** Main weapon socket where weapon will be attached */
var(XCOM_Unit) const public name				        WeaponSocket;
/** Default AI controller class to control this unit */
var(AI) const public class<X_COM_AIController>	        DefaultAiClass;
/** Default AI controller command state to use at init */
var(AI) const public ECommandStates		                DefaultAiCommandState;

//=============================================================================
// Sounds
//=============================================================================
/** Sound played when unit is dying, for example - scream before die */
var(XCOM_Sounds) const SoundCue  DyingSound;
/** Sound played when unit falling from sky to ground and kick of ground (maybe when flying unit is killed) */
var(XCOM_Sounds) const SoundCue  FallingDamageLandSound;
/** Voice sound when unit get bullet. Maybe some pain scream */
var(XCOM_Sounds) const SoundCue  HitSound;
/** VSound played when unit was exploded. This is body explode sound for pawn and metal sound  for vehicle */
var(XCOM_Sounds) const SoundCue  BodyExplosionSound;
var(XCOM_Sounds) const int       MaxRadiusWhereSoundCanBeHeard;

//=============================================================================
// Blood
//=============================================================================
var(XCOM_Effects) const LinearColor             BloodColor;
var const class<Emitter>                        BloodEmitterClass;

var(XCOM_Effects) const array<DistanceBasedParticleEffects>	BloodEffects; // Hit impact effects. Sprays when you get shot

var(XCOM_Effects) const ParticleSystem          DisplayDamageEffectTemplate; // displays damage given for pawn
var(XCOM_Effects) const MaterialInterface       DisplayDamageMaterialTemplate;
var(XCOM_Effects) const LinearColor             DisplayDamageColor;

/** This is the blood splatter effect to use on the walls when this pawn is shot @see LeaveABloodSplatterDecal **/
var(XCOM_Effects) protected const  DecalMaterial	BloodSplatterDecalMaterial;
var(XCOM_Effects) protected const  DecalMaterial    BloodPoolDecalMaterial;

//=============================================================================
// Experience
//=============================================================================
/** Amount of experience should be given to killer  */
var(XCOM_Alien) const protected int				ExpirienceForKill;

//=============================================================================
// Variables:  Effects
//=============================================================================
var(XCOM_Human) protected ParticleSystem		UnitSelectionEffectTemplate; // Template of effect being played when player is selecting unit

var protected ParticleSystemComponent			UnitSelectedEffect; // Effect is shown when unit is selected by player
var(XCOM_Human) protected const ParticleSystem	UnitSelectedEffectTemplate; // Template of effect

var protected ParticleSystemComponent			StaticUnitEffect; // Effect is shown persisten at player units
var(XCOM_Human) protected const ParticleSystem	StaticUnitEffectTemplate; // Template of effect

//=============================================================================
// Additional gameplay characteristics calculated from main characteristics
//=============================================================================
var EUnitState					    UnitState;              // Soldier/Alien status

var(XCOM_Data) string                           UnitName;               // Human/Vehicle name or alien race name
var(XCOM_Data) ECreatureRace                    Race;                   // Race - human|alien

var int                               Experience;             // Soldier experience, not used for aliens and vehicles
var int                               Level;                  // Creature level
var int                               UnitsKilled;            // Amount of alliens killed

/** Modifying percent for every level */
const			                                ModifierPercent = 4.55; // % for level modifier

var(XCOM_Data) ArmorDefenceParameters	        Armor;              //Dressed armor
var(XCOM_Data) EShieldTypes                     ShieldType;			    //protective shield type
var  X_COM_Equipment_Shields	Shield;
var repnotify protected bool            bShieldsActive;

var(XCOM_Data) int                              Dexterity;              //Dexterity influence on Time units
var(XCOM_Data) int                              Energy;                 //Stamina|persistence| выносливость influence on Energy units
var(XCOM_Data) int                              Vitality;               //Vitality influence on Life units
var(XCOM_Data) int                              Bravery;                //Bravery and battle spirit influence on Fear units

var(XCOM_Data) int                              Strength;               //Strength influence on Weapon and Suit usage
var(XCOM_Data) int                              Reaction;               //Auto-shot reaction
var(XCOM_Data) int                              FiringAccuracy;         //Firing Accuracy
var(XCOM_Data) int                              ThrowingAccuracy;       //Throwing Accuracy
const                                           HitAccuracy = 100;      //Hit Accuracy

var int 		                    TimeUnits;
var int 		                    TimeUnitsRemain;
var int 		                    EnergyUnits;
var int 		                    EnergyUnitsRemain;
var int 		                    HealthUnits;
var int 		                    HealthUnitsRemain;
var int 		                    FearUnits;
var int 		                    FearUnitsRemain;

//=============================================================================
// Turn-based
//=============================================================================
/** X-COM invisibility in map */
var public bool bIsInvisibleForAI;

/** Ai should know who's turn now */
var public bool  bIsMyTurn;

//=============================================================================
// stats
//=============================================================================
var X_COM_Stats           mStats; //x-com and aliens stats
var class<X_COM_Stats>    mStatsClass;

//=============================================================================
// All others variables
//=============================================================================
var public X_COM_Weapon	ActiveWeapon;

/** ID of soldier in DB */
var public int					    mId; //id in DB
var public int                      mShipID;             //Ship ID in DB where this soldier is (0 = no ship / on base)

/** These values are used for determining headshots */
var protected bool                  bWasHeadShot;
var protected int                   HeadshotDamageScale;

var public bool                     bIsDied;
var public bool						bIsSelected;

var public DynamicLightEnvironmentComponent    LightEnvironment;

var public X_COM_Projectile         Fired_Projectile; // Last fired projectile

/** Array of bodies that should not have joint drive applied. */
var array<name> NoDriveBodies;

/** bones to set fixed when doing the physics take hit effects */
var array<name> TakeHitPhysicsFixedBones;

/** Time at which this pawn entered the dying state */
var float DeathTime;

/** Accrued Fire Damage */
var float AccruedFireDamage;

var AnimNodeSlot                                        FullBodyAnimSlot; //Slot node used for playing full body anims.
var AnimNodeSlot                                        TopHalfAnimSlot; // Slot node used for playing animations only on the top half.

var repnotify InventoryManager myInvManager; // for replication of invManager
var protected X_COM_PlayerController MasterController;

//=============================================================================
// Replication
//=============================================================================
replication
{
	// Replicate if server
	if (Role == ROLE_Authority && (bNetInitial || bNetDirty))

	// main characteristics:
	TimeUnits, TimeUnitsRemain, EnergyUnits, EnergyUnitsRemain, HealthUnits, HealthUnitsRemain, FearUnits, FearUnitsRemain,

	// inventory and weapons:
	myInvManager, ActiveWeapon, Shield, bShieldsActive;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'myInvManager')
	{
		if (myInvManager != none)
		{
			invManager = myInvManager;
			invManager.SetOwner(self);
			ReplicatedEvent('bShieldsActive');
			ReplicatedEvent('ActiveWeapon');
		}
	}
	else if (VarName == 'bShieldsActive')
	{
		if (invManager != none)
		{
			if (bShieldsActive) ActivateShield(ShieldType);
			else DeActivateShield();
		}
	}
	else if (VarName == 'ActiveWeapon')
	{
		if (invManager != none)
		{
			ActiveWeapon.ActivateItem(ActiveWeapon.AttachedToSocket);
		}
	}
	//else if (VarName == 'HealthUnitsRemain')
	//{
	//	`log(" !!!!!!!! ReplicatedEvent - "$String(Role)$" "$self$" HealthUnitsRemain = "$HealthUnitsRemain);
	//	Health = HealthUnitsRemain;
	//}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

//=============================================================================
// Functions main
//=============================================================================
simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	//mStats = Spawn(mStatsClass, self);
	//DB_InitStrings();

	//AddDefaultInventory(); // not work in lan game
	//ActivateWeapon(); // not work in lan game

	SetCharacterClassFromInfo();
	SetPhysics(DefaultPhysics);
	
	if (Role == ROLE_Authority) // if server
	{
		myInvManager = invManager; // replicate invManager
		ActivateShield(ShieldType);
	}
	
	ShowStaticUnitEffect();
	SpawnDefaultController();
}

function SpawnDefaultController()
{
	ChangeController(DefaultAiClass);
}

public function ChangeController(class<X_COM_AIController> aClass)
{
	local controller lcontroller;

	if (controller != none)
	{
		lcontroller = controller;
		lcontroller.UnPossess();
		lcontroller.Destroy();
	}

	if(aClass != none)
	{
		Controller = Spawn(aClass,,,Location,Rotation,,false);
		Controller.Possess(self, false);
		SetOwner(Controller);
	}
}

simulated public function SetTeam(ETeams aNewTeam)
{
	if (X_COM_AIController(controller) != none) X_COM_AIController(controller).SetTeam(aNewTeam);
}

/** Set weapon fire mode : aimed, semi, one-shot */
simulated public function SetFireMode(EFiringModes aNewFireMode)
{
	if (ActiveWeapon != none) ActiveWeapon.SetFireMode(aNewFireMode);
}

/** Set reference to PC who owns this pawn */
simulated public function SetMasterController(X_COM_PlayerController aPC)
{
	MasterController = aPC;
}

//=============================================================================
// Init
//=============================================================================
/** initial */
public function DB_InitStrings()
{
	UnitName = class'X_COM_Defines'.static.initString(50);
}

/** final */
public function InitUnitData()
{
	local float LevelModifier;
	LevelModifier = (1.10 + ((Level*ModifierPercent)/100));
	TimeUnits = 1000000;//int(Dexterity * LevelModifier);
	TimeUnitsRemain = TimeUnits;
	HealthUnits = int(Vitality * LevelModifier);
	HealthUnitsRemain = HealthUnits;
	Health = HealthUnitsRemain;
	HealthMax = HealthUnits;
	FearUnits = int(Bravery * LevelModifier);
	FearUnitsRemain = FearUnits;
}

simulated function int getId()
{
	return mId;
}

simulated function setId(int aId)
{
	mId = aId;
}

/**
 * Notification function to adjust pawn variables after attributes might be changed.
 * e.g. Walking Speed, weight capacity etc.
 */
function notifyAttributesChanged();

//=============================================================================
// Level and Experience
//=============================================================================
simulated public function GiveExperience(int aExpQuantity)
{
	Experience += aExpQuantity;
	CheckLevelIncreased();
}

private function CheckLevelIncreased()
{
	local int lExpForNextLevel;
	local int lNextLevel;
	
	lNextLevel = Level + 1;

	lExpForNextLevel = (lNextLevel * ModifierPercent * abs(1-lNextLevel)) * 100;

	if (Experience >= lExpForNextLevel) IncreaseLevel();
}

simulated private function IncreaseLevel()
{
	Level++;
	InitUnitData();
}

//=============================================================================
// Stats
//=============================================================================
public function UpdateStat_AliensKilled()
{
	UnitsKilled++;
}

//=============================================================================
// Functions Inventory
//=============================================================================
/** Create an inventory item from Archetype rather than direct class reference */
simulated public final function X_COM_Inventory CreateInventoryFromTemplate( X_COM_Inventory InventoryActorTemplate, optional bool bDoNotActivate )
{
	if ( InvManager != None )
		return X_COM_InventoryManager(InvManager).CreateInventoryFromTemplate( InventoryActorTemplate, bDoNotActivate );

	return None;
}

simulated public final function X_COM_Weapon GiveWeapon( EWeapon aWeaponType, optional bool bDoNotActivate)
{
	if ( InvManager != None )
	{
		return X_COM_Weapon(CreateInventoryFromTemplate( class'X_COM_Settings'.default.Weapons[aWeaponType], bDoNotActivate ));
	}
	return None;
}

/** Adds InventoryItems from archetype */
simulated function AddDefaultInventory()
{
	local int il;

	if (InventoryItems.Length >= 0)
	{
		for(il=0; il<InventoryItems.Length; ++il)
		{
			if (InventoryItems[il] != none) CreateInventoryFromTemplate(InventoryItems[il], true);
		}
	}
}

/** Find best or any weapon in inventory and activate it */
simulated public function ActivateWeapon()
{
	local X_COM_Weapon lWeapon;
	lWeapon = X_COM_InventoryManager(InvManager).FindBestWeapon();
	if (lWeapon != none) CreateInventoryFromTemplate( lWeapon );
}

//=============================================================================
// Shields
//=============================================================================
simulated protected function final ActivateShield(EShieldTypes aType)
{
	if (aType == EST_None) return;

	Shield = X_COM_Equipment_Shields(CreateInventoryFromTemplate(class'X_COM_Settings'.default.Shields[aType]));

	if (OverlayMesh != None)
	{
		OverlayMesh.SetSkeletalMesh(Mesh.SkeletalMesh);
		OverlayMesh.SetParentAnimComponent(Mesh);
		SetOverlayMaterial(Shield.ShieldMaterialTemplate);
	}
	bShieldsActive = Shield.ActivateItem();
}

simulated protected function DeActivateShield()
{
	if ( (!bShieldsActive) || (Shield == none) ) return;
	bShieldsActive = false;
	Shield.DeactivateItem();
	Shield.Destroy();
	Shield = none;
	SetOverlayMaterial(none);
}

/**
 * Apply a given overlay material to the overlay mesh.
 */
simulated protected function SetOverlayMaterial(MaterialInterface aNewOverlay)
{
	local int i;

	// If we are authoritative, then set up replication of the new overlay
	if (Role == ROLE_Authority)
	{
		OverlayMaterialInstance = aNewOverlay;
	}

	if (Mesh.SkeletalMesh != None)
	{
		if (aNewOverlay != None)
		{
			// pawn overlay mesh
			for (i = 0; i < OverlayMesh.SkeletalMesh.Materials.Length; i++)
			{
				OverlayMesh.SetMaterial(i, aNewOverlay);
			}

			if (!OverlayMesh.bAttached)
			{
				AttachComponent(OverlayMesh);
			}
		}
		else
		{
			if (OverlayMesh.bAttached)
			{
				DetachComponent(OverlayMesh);
			}
		}
	}
}

public function MaterialInterface GetOverlayMaterial()
{
	return OverlayMaterialInstance;
}

//=============================================================================
// AI hints
//=============================================================================
simulated function SetInvisible(bool bNewInvisibility)
{
	bIsInvisibleForAI = bNewInvisibility;

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (bIsInvisibleForAI)
		{
			Mesh.CastShadow = false;
			Mesh.bCastDynamicShadow = false;
			UpdateShadowSettings(false);
			if (ActiveWeapon != none) ActiveWeapon.Mesh.SetHidden(true);
			Mesh.SetHidden(true);
			ReattachMesh();
		}
		else
		{
			UpdateShadowSettings(true);
			if (ActiveWeapon != none) ActiveWeapon.Mesh.SetHidden(false);
			Mesh.SetHidden(false);
			ReattachMesh();
		}
	}
}

/** reattaches the mesh component, because settings were updated */
simulated function ReattachMesh()
{
	DetachComponent(OverlayMesh);
	DetachComponent(Mesh);
	AttachComponent(Mesh);
	AttachComponent(OverlayMesh);
	if (ActiveWeapon != none) ActiveWeapon.ReattachWeaponMesh();
}

//=============================================================================
// Effects
//=============================================================================
/** Show shine decal/particle when pawn is being selected **/
public simulated function ShowSelectedEffect(bool aShowSelection)
{
	`log(" ShowSelectedEffect called ");
	if(aShowSelection)
	{
		if (UnitSelectedEffect == none) ShowUnitSelectedEffect();
	}
	else
	{
		if (UnitSelectedEffect != none)
		{
			UnitSelectedEffect.DeactivateSystem();
			UnitSelectedEffect = none;
		}
	}
}

/** Show particle effect when pawn is selecting by the player **/
public simulated function ShowUnitSelectingEffect();

/** Show particle effect when pawn was being selected by the player **/
protected function ShowUnitSelectedEffect();

/** Show static particle effect player unit**/
public simulated function ShowStaticUnitEffect();

//=============================================================================
// Functions: Damage
//=============================================================================
/** adjust damage based on inventory, other attributes */
function AdjustDamage(out int InDamage, out vector Momentum, Controller InstigatedBy, vector HitLocation, class<DamageType> aDamageType, TraceHitInfo HitInfo, Actor DamageCauser)
{
	local int PreDamage;

	if( aDamageType.default.bArmorStops && (inDamage > 0) )
	{
		PreDamage = inDamage;
		inDamage = ShieldAbsorb(inDamage, aDamageType, HitInfo, Momentum, HitLocation);
		inDamage = ArmorAbsorb(inDamage, aDamageType, HitInfo, Momentum, HitLocation);

		// still show damage effect on HUD if damage completely absorbed
		if ( (PreDamage > 0) && (Controller != None) )
		{
			Controller.NotifyTakeHit(InstigatedBy, HitLocation, PreDamage, aDamageType, Momentum);
		}
	}
} 

/** returns the resultant amount of damage after shield have absorbed what they can */
protected function int ShieldAbsorb(int aDamage, class<DamageType> aDamageType, TraceHitInfo HitInfo, vector Momentum, vector HitLocation)
{
	local class<X_COM_DamageType> lDmgType;

	if ( Shield == none ) return aDamage;
	if ( Health <= 0 ) return aDamage;

	if (class<X_COM_DamageType>(aDamageType) != None)
	{
		lDmgType = class<X_COM_DamageType>(aDamageType);
		if ( (lDmgType != none) && (lDmgType.default.TypeOfDamage != Shield.DefenceFrom) ) return aDamage; // if shield do not stop this type of damage then return
	}

	// shield absorbs a part of damage
	if ( Shield.Defence > 0 )
	{
		Shield.Defence = AbsorbDamage(aDamage, Shield.Defence, 1.0);
		if (Shield.Defence == 0)
		{
			//SetOverlayMaterial(None);
		}
		if ( aDamage == 0 )
		{
			//SetBodyMatColor(SpawnProtectionColor, 1.0);
			//PlaySound(ArmorHitSound);
			return 0;
		}
	}
	
	Shield.StartRegeneration();

	return aDamage;
}

/** returns the resultant amount of damage after armor have absorbed what they can */
protected function int ArmorAbsorb(int aDamage, class<DamageType> aDamageType, TraceHitInfo HitInfo, vector Momentum, vector HitLocation); // override for child classes


/** AbsorbDamage()
reduce damage and remove shields based on the absorption rate.
returns the remaining armor strength.
*/
protected function int AbsorbDamage(out int Damage, int CurrentShieldStrength, float AbsorptionRate)
{
	local int MaxAbsorbedDamage;

	MaxAbsorbedDamage = Min(Damage * AbsorptionRate, CurrentShieldStrength);
	Damage -= MaxAbsorbedDamage;
	return CurrentShieldStrength - MaxAbsorbedDamage;
}

/** We override TakeDamage and allow the weapon to modify it */
event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	`log(" TakeDamage ");
	// reduce rocket jumping
	if (EventInstigator == Controller)
	{
		momentum *= 0.6;
	}
	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	UpdateHealthUnits();	

	DisplayTakeDamage(Damage, HitLocation, Momentum);

	PlayHitSound();
}

function UpdateHealthUnits()
{
	HealthUnitsRemain = Health;
}

function DisplayTakeDamage(int aDamage, vector aHitLocation, vector aMomentum)
{
	local vector FXMomentum;
	local MaterialInstanceConstant lFXMaterial;
	local ParticleSystemComponent DisplayEffect;
	local Color lColor;
	
	if (DisplayDamageEffectTemplate != None)
	{
		FXMomentum = Normal(-1.0 * aMomentum) + (0.5 * VRand());

		DisplayEffect = WorldInfo.MyEmitterPool.SpawnEmitter(DisplayDamageEffectTemplate, aHitLocation, rotator(FXMomentum), self);
		lFXMaterial = new()Class'MaterialInstanceConstant';
		lFXMaterial.SetParent(DisplayDamageMaterialTemplate);

		lColor.A = DisplayDamageColor.A;
		lColor.B = DisplayDamageColor.B;
		lColor.G = DisplayDamageColor.G;
		lColor.R = DisplayDamageColor.R;

		DisplayEffect.SetColorParameter('CountColor', lColor);
		
		lFXMaterial.SetScalarParameterValue('NewDamage', aDamage);
		
		DisplayEffect.SetMaterialParameter('DamageMat', lFXMaterial);
	}
}

/** Set various basic properties for this Pawn based on the character class metadata */
simulated function SetCharacterClassFromInfo()
{
	local int i;

	// Make sure bEnableFullAnimWeightBodies is only TRUE if it needs to be (PhysicsAsset has flappy bits)
	Mesh.bEnableFullAnimWeightBodies = FALSE;
	for(i=0; i<Mesh.PhysicsAsset.BodySetup.length && !Mesh.bEnableFullAnimWeightBodies; i++)
	{
		// See if a bone has bAlwaysFullAnimWeight set and also
		if( Mesh.PhysicsAsset.BodySetup[i].bAlwaysFullAnimWeight &&
			Mesh.MatchRefBone(Mesh.PhysicsAsset.BodySetup[i].BoneName) != INDEX_NONE)
		{
			Mesh.bEnableFullAnimWeightBodies = TRUE;
		}
	}

	CrouchTranslationOffset = BaseTranslationOffset + CylinderComponent.Default.CollisionHeight - CrouchHeight;

	// Make sure physics is in the correct state.
	// Rebuild array of bodies to not apply joint drive to.
	NoDriveBodies.length = 0;
	for( i=0; i<Mesh.PhysicsAsset.BodySetup.Length; i++)
	{
		if(Mesh.PhysicsAsset.BodySetup[i].bAlwaysFullAnimWeight)
		{
			NoDriveBodies.AddItem(Mesh.PhysicsAsset.BodySetup[i].BoneName);
		}
	}

	// Reset physics state.
	bIsHoverboardAnimPawn = FALSE;
	ResetCharPhysState();
}

simulated function ResetCharPhysState()
{
	if(Mesh.PhysicsAssetInstance != None)
	{
		// Now set up the physics based on what we are currently doing.
		if(Physics == PHYS_RigidBody)
		{
			// Ragdoll case
			Mesh.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);
			SetPawnRBChannels(TRUE);
			SetHandIKEnabled(FALSE);
		}
		else
		{
			// Normal case
			Mesh.PhysicsAssetInstance.SetAllBodiesFixed(TRUE);
			Mesh.PhysicsAssetInstance.SetFullAnimWeightBonesFixed(FALSE, Mesh);
			SetPawnRBChannels(FALSE);
			SetHandIKEnabled(TRUE);
		}
	}
}

function bool CheckForSpawnCourpse()
{
	if (UnitState == ESS_Died)
	{
		GotoState('Dying'); 
		return true;
	}
	return false;
}

function float GetEyeHeight()
{
	if ( !IsLocallyControlled() )
		return BaseEyeHeight;
	else
		return EyeHeight;
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	if (SkelComp == Mesh)
	{
		LeftLegControl = SkelControlFootPlacement(Mesh.FindSkelControl(LeftFootControlName));
		RightLegControl = SkelControlFootPlacement(Mesh.FindSkelControl(RightFootControlName));
		FullBodyAnimSlot = AnimNodeSlot(Mesh.FindAnimNode('FullBodySlot'));
		TopHalfAnimSlot = AnimNodeSlot(Mesh.FindAnimNode('TopHalfSlot'));

		LeftHandIK = SkelControlLimb( mesh.FindSkelControl('LeftHandIK') );

		RightHandIK = SkelControlLimb( mesh.FindSkelControl('RightHandIK') );

		RootRotControl = SkelControlSingleBone( mesh.FindSkelControl('RootRot') );
		AimNode = AnimNodeAimOffset( mesh.FindAnimNode('AimNode') );
		GunRecoilNode = GameSkelCtrl_Recoil( mesh.FindSkelControl('GunRecoilNode') );
		LeftRecoilNode = GameSkelCtrl_Recoil( mesh.FindSkelControl('LeftRecoilNode') );
		RightRecoilNode = GameSkelCtrl_Recoil( mesh.FindSkelControl('RightRecoilNode') );

		FlyingDirOffset = AnimNodeAimOffset( mesh.FindAnimNode('FlyingDirOffset') );
	}
}

function PlayHit(float Damage, Controller InstigatedBy, vector HitLocation, class<DamageType> aDamageType, vector Momentum, TraceHitInfo HitInfo)
{
	local X_COM_PlayerController Hearer;
	local class<X_COM_DamageType> lDamage;

	if ( InstigatedBy != None && (class<X_COM_DamageType>(aDamageType) != None) )
	{
		Hearer = X_COM_PlayerController(InstigatedBy);
		if (Hearer != None)
		{
			Hearer.bAcuteHearing = true;
		}
	}

	if ( Health <= 0 && PhysicsVolume.bDestructive && (WaterVolume(PhysicsVolume) != None) && (WaterVolume(PhysicsVolume).ExitActor != None) )
	{
		Spawn(WaterVolume(PhysicsVolume).ExitActor);
	}

	Super.PlayHit(Damage, InstigatedBy, HitLocation, aDamageType, Momentum, HitInfo);

	if (Hearer != None)
	{
		Hearer.bAcuteHearing = false;
	}

	lDamage = class<X_COM_DamageType>(aDamageType);

	if (Damage > 0 || (Controller != None && Controller.bGodMode))
	{
		CheckHitInfo( HitInfo, Mesh, Normal(Momentum), HitLocation );

		LastTakeHitInfo.Damage = Damage;
		LastTakeHitInfo.HitLocation = HitLocation;
		LastTakeHitInfo.Momentum = Momentum;
		LastTakeHitInfo.DamageType = aDamageType;
		LastTakeHitInfo.HitBone = HitInfo.BoneName;
		LastTakeHitTimeout = WorldInfo.TimeSeconds + ( (lDamage != None) ? lDamage.static.GetHitEffectDuration(self, Damage)
									: class'X_COM_DamageType'.static.GetHitEffectDuration(self, Damage) );

		// play clientside effects
		PlayTakeHitEffects();
	}
}

/** plays clientside hit effects using the data in LastTakeHitInfo */
simulated function PlayTakeHitEffects()
{
	local class<X_COM_DamageType> lDamage;
	local vector BloodMomentum;
	local Emitter HitEffect;
	local ParticleSystem BloodTemplate;

	if (EffectIsRelevant(Location, false))
	{
		lDamage = class<X_COM_DamageType>(LastTakeHitInfo.DamageType);
		if (lDamage != None && lDamage.default.bCausesBloodSplatterDecals && !IsZero(LastTakeHitInfo.Momentum))
		{
			LeaveABloodSplatterDecal(LastTakeHitInfo.HitLocation, LastTakeHitInfo.Momentum);
		}

		if (!IsFirstPerson() || class'Engine'.static.IsSplitScreen())
		{
			if ( lDamage.default.bCausesBlood)
			{
				BloodTemplate = class'X_COM_Emitter'.static.GetTemplateForDistance(BloodEffects, LastTakeHitInfo.HitLocation, WorldInfo);
				if (BloodTemplate != None)
				{
					BloodMomentum = Normal(-1.0 * LastTakeHitInfo.Momentum) + (0.5 * VRand());
					HitEffect = Spawn(BloodEmitterClass, self,, LastTakeHitInfo.HitLocation, rotator(BloodMomentum));
					HitEffect.SetTemplate(BloodTemplate, true);
					X_COM_Emitter(HitEffect).AttachTo(self, LastTakeHitInfo.HitBone);
				}
			}

			if ( !Mesh.bNotUpdatingKinematicDueToDistance )
			{
				// physics based takehit animations
				if (lDamage != None)
				{
					//@todo: apply impulse when in full ragdoll too (that also needs to happen on the server)
					if ( !class'Engine'.static.IsSplitScreen() && Health > 0 && DrivenVehicle == None && Physics != PHYS_RigidBody &&
						VSize(LastTakeHitInfo.Momentum) > lDamage.default.PhysicsTakeHitMomentumThreshold )
					{
						if (Mesh.PhysicsAssetInstance != None)
						{
							// just add an impulse to the asset that's already there
							Mesh.AddImpulse(LastTakeHitInfo.Momentum, LastTakeHitInfo.HitLocation);
							// if we were already playing a take hit effect, restart it
							if (bBlendOutTakeHitPhysics)
							{
								Mesh.PhysicsWeight = 0.5;
							}
						}
						else if (Mesh.PhysicsAsset != None)
						{
							Mesh.PhysicsWeight = 0.5;
							Mesh.PhysicsAssetInstance.SetNamedBodiesFixed(true, TakeHitPhysicsFixedBones, Mesh, true);
							Mesh.AddImpulse(LastTakeHitInfo.Momentum, LastTakeHitInfo.HitLocation);
							bBlendOutTakeHitPhysics = true;
						}
					}
					lDamage.static.SpawnHitEffect(self, LastTakeHitInfo.Damage, LastTakeHitInfo.Momentum, LastTakeHitInfo.HitBone, LastTakeHitInfo.HitLocation);
				}
			}
		}
	}
}

/**
 * This will trace against the world and leave a blood splatter decal.
 * This is used for having a back spray / exit wound blood effect on the wall behind us.
 **/
simulated function LeaveABloodSplatterDecal(vector HitLoc, vector HitNorm)
{   //http://udn.epicgames.com/Three/DecalsTechnicalGuide.html
	local Actor TraceActor;
	local vector out_HitLocation;
	local vector out_HitNormal;
	local vector TraceDest;
	local vector TraceStart;
	local vector TraceExtent;
	local TraceHitInfo HitInfo;
	local MaterialInstanceTimeVarying MITV_Decal;

	TraceStart = HitLoc;
	HitNorm.Z = 0;
	TraceDest =  HitLoc  + ( HitNorm * 105 );

	TraceActor = Trace( out_HitLocation, out_HitNormal, TraceDest, TraceStart, false, TraceExtent, HitInfo, TRACEFLAG_PhysicsVolumes );

	if (TraceActor != None && Pawn(TraceActor) == None)
	{
		MITV_Decal = new(Outer) class'MaterialInstanceTimeVarying';
		MITV_Decal.SetParent(BloodSplatterDecalMaterial);

		MITV_Decal.SetVectorParameterValue('Blood_Color', BloodColor);
		WorldInfo.MyDecalManager.SpawnDecal(MITV_Decal, out_HitLocation, rotator(-out_HitNormal), 100, 100, 50, false, (FRand() * 360), HitInfo.HitComponent, true, false, HitInfo.BoneName, HitInfo.Item, HitInfo.LevelIndex);
	}
	
}

simulated function LeaveABloodPoolWhenKilled()
{
	local MaterialInstanceTimeVarying MITV_Decal;

	MITV_Decal = new(Outer) class'MaterialInstanceTimeVarying';
	MITV_Decal.SetParent(BloodPoolDecalMaterial);
	MITV_Decal.SetVectorParameterValue('Blood_Color', BloodColor);
	WorldInfo.MyDecalManager.SpawnDecal(MITV_Decal,	// UMaterialInstance used for this decal.
                              location,				// Decal spawned at the hit location.
                              Rot(0,0,0),			// Orient decal into the surface. rotation
                              100,					// Decal size in tangent/binormal directions. Width
                              100,					// Decal size in tangent/binormal directions. Height                                         
                              50,					// Decal size in normal direction. Thickness
                              true,					// If TRUE, use "NoClip" codepath.
                              FRand() * 360,		// random rotation
                              );                    // If non-NULL, consider this component only.

}


//=============================================================================
// Functions: Death
//=============================================================================
/**
 * Responsible for playing any death effects, animations, etc.
 *
 * @param 	aDamageType - type of damage responsible for this pawn's death
 *
 * @param	HitLoc - location of the final shot
 */
simulated function PlayDying(class<DamageType> aDamageType, vector HitLoc)
{
	local vector ApplyImpulse, ShotDir;
	local TraceHitInfo HitInfo;
	//local bool bUseHipSpring;
	//local class<X_COM_DamageType> lDmgType;
	//local RB_BodyInstance HipBodyInst;
	//local int HipBoneIndex;
	//local matrix HipMatrix;
	//local name HeadShotSocketName;
	//local SkeletalMeshSocket SMS;

	bCanTeleport = false;
	bReplicateMovement = false;
	bTearOff = true;
	bPlayedDeath = true;
	bPlayingFeignDeathRecovery = false;

	HitDamageType = aDamageType; // these are replicated to other clients
	TakeHitLocation = HitLoc;

	if ( WorldInfo.NetMode == NM_DedicatedServer )
	{
		// tell clients whether to gib
		GotoState('Dying');
		return;
	}

	if ( (WorldInfo.TimeSeconds - LastRenderTime > 3))
	{
		if (WorldInfo.NetMode == NM_ListenServer || WorldInfo.IsRecordingDemo())
		{
			if (WorldInfo.Game.NumPlayers + WorldInfo.Game.NumSpectators < 2 && !WorldInfo.IsRecordingDemo())
			{
				Destroy();
				return;
			}

			TurnOffPawn();
			return;
		}
		else
		{
			// if we were not just controlling this pawn,
			// and it has not been rendered in 3 seconds, just destroy it.
			Destroy();
			return;
		}
	}

	CheckHitInfo( HitInfo, Mesh, Normal(TearOffMomentum), TakeHitLocation );

	bBlendOutTakeHitPhysics = false;

	// Turn off hand IK when dead.
	SetHandIKEnabled(false);

	// if we had some other rigid body thing going on, cancel it
	if (Physics == PHYS_RigidBody)
	{
		//@note: Falling instead of None so Velocity/Acceleration don't get cleared
		setPhysics(PHYS_Falling);
	}

	PreRagdollCollisionComponent = CollisionComponent;
	CollisionComponent = Mesh;

	Mesh.MinDistFactorForKinematicUpdate = 0.f;

	// If we had stopped updating kinematic bodies on this character due to distance from camera, force an update of bones now.
	if( Mesh.bNotUpdatingKinematicDueToDistance )
	{
		Mesh.ForceSkelUpdate();
		Mesh.UpdateRBBonesFromSpaceBases(TRUE, TRUE);
	}

	Mesh.PhysicsWeight = 1.0;

	SetPhysics(PHYS_RigidBody);
	Mesh.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);
	SetPawnRBChannels(TRUE);

	if( TearOffMomentum != vect(0,0,0) )
	{
		ShotDir = normal(TearOffMomentum);
		ApplyImpulse = ShotDir * aDamageType.default.KDamageImpulse;

		// If not moving downwards - give extra upward kick
		if ( Velocity.Z > -10 )
		{
			ApplyImpulse += Vect(0,0,1)*aDamageType.default.KDeathUpKick;
		}
		Mesh.AddImpulse(ApplyImpulse, TakeHitLocation, HitInfo.BoneName, true);
	}
	GotoState('Dying');
}

simulated function SetPawnRBChannels(bool bRagdollMode)
{
	if(bRagdollMode)
	{
		Mesh.SetRBChannel(RBCC_Pawn);
		Mesh.SetRBCollidesWithChannel(RBCC_Default,TRUE);
		Mesh.SetRBCollidesWithChannel(RBCC_Pawn,TRUE);
		Mesh.SetRBCollidesWithChannel(RBCC_Vehicle,TRUE);
		Mesh.SetRBCollidesWithChannel(RBCC_Untitled3,FALSE);
		Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume,TRUE);
	}
	else
	{
		Mesh.SetRBChannel(RBCC_Untitled3);
		Mesh.SetRBCollidesWithChannel(RBCC_Default,FALSE);
		Mesh.SetRBCollidesWithChannel(RBCC_Pawn,FALSE);
		Mesh.SetRBCollidesWithChannel(RBCC_Vehicle,FALSE);
		Mesh.SetRBCollidesWithChannel(RBCC_Untitled3,TRUE);
		Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume,FALSE);
	}
}

/** here should be things while pawn is dying */
simulated protected function OnDying()
{
	local PlayerReplicationInfo lPRI;
	lPRI = self.PlayerReplicationInfo;
	X_COM_GameInfo(lPRI.WorldInfo.Game).NotifyUnitDied(self);
}

State Dying
{
	ignores OnAnimEnd, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer, StartFeignDeathRecoveryAnim;

	simulated function BeginState(Name PreviousStateName)
	{
		bIsDied = TRUE;

		Super.BeginState(PreviousStateName);

		PlayDyingSound();

		OnDying(); // Do custom things when pawn is dying

		LeaveABloodPoolWhenKilled(); // оставить лужу крови где лег, тока не работает чето

		if ((self.isA('X_COM_Pawn_Human')) || (self.isA('X_COM_Vehicle_Human')))
		{
			if (self.bIsSelected) MasterController.SelectedUnitsRemoveUnit(self);
			MasterController.AllUnitsRemoveUnit(self);
		}

		if (StaticUnitEffect != none)
		{
			StaticUnitEffect.DeactivateSystem();
			StaticUnitEffect = none;
			ShowSelectedEffect(false);
		}

		if (ActiveWeapon != none) ActiveWeapon.StopWeaponAnimation();

		DeActivateShield();

		CustomGravityScaling = 1.0;
		DeathTime = WorldInfo.TimeSeconds;
		CylinderComponent.SetActorCollision(false, false);

		if ( Mesh != None )
		{
			Mesh.SetTraceBlocking(true, true);
			Mesh.SetActorCollision(true, false);
			Mesh.SetTickGroup(TG_PostAsyncWork); // Move into post so that we are hitting physics from last frame, rather than animated from this
		}
		SetTimer(2.0, false);
		LifeSpan = 0;
	}

	simulated event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> aDamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
	{
		local Vector shotDir, ApplyImpulse,BloodMomentum;
		local class<X_COM_DamageType> lDamage;
		local Emitter HitEffect;

		if (InstigatedBy != None || EffectIsRelevant(Location, true, 0))
		{
			lDamage = class<X_COM_DamageType>(aDamageType);

			Health -= Damage;

			if (WorldInfo.NetMode != NM_DedicatedServer)
			{
				CheckHitInfo( HitInfo, Mesh, Normal(Momentum), HitLocation );
				if ( lDamage != None )
				{
					lDamage.Static.SpawnHitEffect(self, Damage, Momentum, HitInfo.BoneName, HitLocation);
				}
				if (class<X_COM_DamageType>(aDamageType).default.bCausesBlood && ((PlayerController(Controller) == None) || (WorldInfo.NetMode != NM_Standalone)) )
				{
					BloodMomentum = Momentum;
					if ( BloodMomentum.Z > 0 ) BloodMomentum.Z *= 0.5;
					HitEffect = Spawn(BloodEmitterClass, self, , HitLocation, rotator(BloodMomentum));
					X_COM_Emitter(HitEffect).AttachTo(Self, HitInfo.BoneName);
				}

				if( (Physics != PHYS_RigidBody) || (Momentum == vect(0,0,0)) || (HitInfo.BoneName == '') )
					return;

				shotDir = Normal(Momentum);
				ApplyImpulse = (aDamageType.Default.KDamageImpulse * shotDir);

				if( (lDamage != None) && lDamage.Default.bThrowRagdoll && (Velocity.Z > -10) )
				{
					ApplyImpulse += Vect(0,0,1)*aDamageType.default.KDeathUpKick;
				}
				// AddImpulse() will only wake up the body for the bone we hit, so force the others to wake up
				Mesh.WakeRigidBody();
				Mesh.AddImpulse(ApplyImpulse, HitLocation, HitInfo.BoneName, true);
			}
		}
	}
}

/**
 * Set Pawns rotation after loading without noticable rotation.
 * 
 * @param [in] aRotator [Rotator]
 */
function setInstantRotation(Rotator aRotator)
{
  RotationRate.Pitch = 200000;
  RotationRate.Yaw = 200000;
  RotationRate.Roll = 200000;
  SetRotation(aRotator);
  SetViewRotation(aRotator);
}

simulated function TurnOffPawn()
{
	// hide everything, turn off collision
	if (Physics == PHYS_RigidBody)
	{
		Mesh.SetHasPhysicsAssetInstance(FALSE);
		Mesh.PhysicsWeight = 0.f;
		SetPhysics(PHYS_None);
	}
	if (!IsInState('Dying')) // so we don't restart Begin label and possibly play dying sound again
	{
		GotoState('Dying');
	}
	SetPhysics(PHYS_None);
	SetCollision(false, false);
	//@warning: can't set bHidden - that will make us lose net relevancy to everyone
	Mesh.SetHidden(true);
	if (OverlayMesh != None)
	{
		OverlayMesh.SetHidden(true);
	}
}

/**
 * This event occurs when the physics determines the vehicle is upside down or empty and on fire.  Called from AUTVehicle::TickSpecial()
 */
simulated event TakeFireDamage()
{
	local int CurrentDamage;

	CurrentDamage = int(AccruedFireDamage);
	AccruedFireDamage -= CurrentDamage;
	TakeDamage(CurrentDamage, Controller, Location, vect(0,0,0), class'X_COM_DamageType');
}

//=============================================================================
// Experience
//=============================================================================
simulated public function UpdateExperience(optional int aExpQuantity)
{
	if (aExpQuantity != 0) GiveExperience(aExpQuantity);
	UpdateStat_AliensKilled();
}

function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	X_COM_Unit(Killer.Pawn).UpdateExperience(Self.ExpirienceForKill);
	return Super.Died(Killer, DamageType, HitLocation);
}

//=============================================================================
// Own Firing system
//=============================================================================
simulated function startFire(byte FireModeNum);
simulated function stopFire(byte FireModeNum);

/** Pawn starts firing!
 * @param	aAtLocation - location where pawn should fire. It can be enemy location, and can be just a location
 */
simulated function ProcessFire(vector aAtLocation)
{
	`log(" "$String(Role)$" "$self$" ProcessFire ActiveWeapon = "$ActiveWeapon$" | aAtLocation "$aAtLocation);
	if ( (ActiveWeapon != None) && (!isZero(aAtLocation)) )
	{
		ActiveWeapon.StartFire(aAtLocation);
	}

}

simulated public function bool CanAttack(Actor Other)
{
	if ( ActiveWeapon == None ) return false;
	else return true;
}

function bool IsFiring()
{
	if (ActiveWeapon != None)
		return ActiveWeapon.IsFiring();

	return false;
}

//=============================================================================
// Sounds
//=============================================================================
simulated function PlayDyingSound()
{
	local PlayerController PC;

	ForEach LocalPlayerControllers(class'PlayerController', PC)
	{
		if ( (PC.ViewTarget != None) && (VSizeSq(PC.ViewTarget.Location - Location) < MaxRadiusWhereSoundCanBeHeard) )
		{
			PlaySound(DyingSound);
			return;
		}
	}
}

simulated function PlayFallingDamageLandSound()
{
	local PlayerController PC;

	ForEach LocalPlayerControllers(class'PlayerController', PC)
	{
		if ( (PC.ViewTarget != None) && (VSizeSq(PC.ViewTarget.Location - Location) < MaxRadiusWhereSoundCanBeHeard) )
		{
			PlaySound(FallingDamageLandSound);
			return;
		}
	}
}

simulated function PlayHitSound()
{
	local PlayerController PC;

	ForEach LocalPlayerControllers(class'PlayerController', PC)
	{
		if ( (PC.ViewTarget != None) && (VSizeSq(PC.ViewTarget.Location - Location) < MaxRadiusWhereSoundCanBeHeard) )
		{
			if (HitSound != none) PlaySound(HitSound);
		}
	}
}

simulated function PlayBodyExplosionSound()
{
	local PlayerController PC;

	ForEach LocalPlayerControllers(class'PlayerController', PC)
	{
		if ( (PC.ViewTarget != None) && (VSizeSq(PC.ViewTarget.Location - Location) < MaxRadiusWhereSoundCanBeHeard) )
		{
			PlaySound(BodyExplosionSound);
			return;
		}
	}
}

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
	Components.Remove(Sprite)

	mStatsClass = class'X_COM_Stats'

	InventoryManagerClass=class'X_COM_InventoryManager'

	BloodEmitterClass = class'X_COM_Emitter'
	
	Begin Object Class=DynamicLightEnvironmentComponent Name=PawnLightEnvironment
         AmbientGlow=(R=0.1,G=0.1,B=0.1,A=1.0)
         AmbientShadowColor=(R=0.0,G=0.0,B=0.0)
         bSynthesizeSHLight=FALSE
         LightDistance=48
         ShadowDistance=0
         ModShadowFadeoutExponent=1
         bCastShadows=FALSE
		 MinTimeBetweenFullUpdates = 0.3
		 bCompositeShadowsFromDynamicLights=FALSE
         bDynamic=TRUE
         MinShadowAngle=0
    End Object
    Components.Add(PawnLightEnvironment)
	LightEnvironment=PawnLightEnvironment

	Begin Object Class=SkeletalMeshComponent Name=PawnSkeletalMeshComponent		
		AlwaysLoadOnClient=TRUE
		AlwaysLoadOnServer=TRUE	
		BlockRigidBody=TRUE
		BlockActors=TRUE
		BlockZeroExtent=TRUE
		BlockNonZeroExtent=TRUE
		bAllowApproximateOcclusion=TRUE
		bForceDirectLightMap=TRUE	
		bCacheAnimSequenceNodes=FALSE
		bIgnoreControllersWhenNotRendered=FALSE
		bUpdateKinematicBonesFromAnimation=TRUE
		bCastDynamicShadow=TRUE
		bOwnerNoSee=FALSE	
		bChartDistanceFactor=TRUE
		bOverrideAttachmentOwnerVisibility=TRUE
		bAcceptsDecals=FALSE
		bAcceptsDynamicDecals=FALSE
		bHasPhysicsAssetInstance=TRUE
		bEnableFullAnimWeightBodies=TRUE
		bUpdateSkelWhenNotRendered=TRUE
		bUseAsOccluder=FALSE
		bUsePrecomputedShadows=FALSE
		CastShadow=TRUE
		CollideActors=TRUE
		LightEnvironment=PawnLightEnvironment
		LightingChannels=(Dynamic=TRUE,CompositeDynamic=TRUE)
		MinDistFactorForKinematicUpdate=0.2
		Translation=(X=0.0000000,Y=0.00000000,Z=0)		
		TickGroup=TG_PreAsyncWork
		RBChannel=RBCC_Pawn
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE,Untitled3=TRUE, Pawn=TRUE)
		Scale=1.0		
	End Object
	Mesh=PawnSkeletalMeshComponent
	Components.Add(PawnSkeletalMeshComponent)

	Begin Object Class=SkeletalMeshComponent Name=OverlayMeshComponent0
		Scale3d = (x=1.05, y=1.05, z=1.005)
		bAcceptsDynamicDecals=FALSE
		CastShadow=false
		bOwnerNoSee=true
		bUpdateSkelWhenNotRendered=false
		bOverrideAttachmentOwnerVisibility=true
		TickGroup=TG_PostAsyncWork
		bAllowAmbientOcclusion=false
		bPerBoneMotionBlur=true
	End Object
	OverlayMesh=OverlayMeshComponent0

	bRunPhysicsWithNoController = TRUE
	bNoEncroachCheck = TRUE

	ControllerClass = none
	Controller = none
	bDontPossess = TRUE

	bCollideWorld = TRUE

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0024.000000
		CollisionHeight=+0048.000000
		BlockZeroExtent=FALSE
	End Object
	CylinderComponent=CollisionCylinder
	CollisionComponent=CollisionCylinder
	CollisionType=COLLIDE_BlockAll

	Role = ROLE_Authority
	RemoteRole = ROLE_SimulatedProxy
	bAlwaysRelevant=true
	AlwaysRelevantDistanceSquared=+1960000.0
	bReplicateHealthToAll = TRUE

	GroundSpeed=250.0
	RotationRate=(Pitch=0,Yaw=32768,Roll=0)

	SightRadius=960
	PeripheralVision = 0.707; // 90 degree
	HearingThreshold = 1152

	MaxRadiusWhereSoundCanBeHeard = 9000000

	bIsDied = FALSE

	DefaultPhysics = PHYS_None

	DisplayDamageEffectTemplate=ParticleSystem'FX_Damage.DamageParticle'
	DisplayDamageMaterialTemplate=MaterialInstanceConstant'FX_Damage.Materials.Count_INST'
}