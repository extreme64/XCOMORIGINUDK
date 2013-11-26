/**
 * X-Com creatures: humans and aliens.
 */
class X_COM_Pawn extends X_COM_Unit
	abstract;

//=============================================================================
// Sounds
//=============================================================================
/** footstep sound effect to play per material type */
var(XCOM_Sound) const array<FootstepSoundInfo> FootstepSounds;

/** default footstep sound used when a given material type is not found in the list */
var(XCOM_Sound) const SoundCue DefaultFootstepSound;

var(XCOM_Sound) const SoundCue LandingSound;

var(XCOM_Sound) const SoundCue JumpingSound;

//=============================================================================
// Defence and Zone Damage
//=============================================================================
/** Bones for zone damage */
var(XCOM_Data) const name			            HeadBone;
var(XCOM_Data) const name						NeckBone;
var(XCOM_Data) const name					    TorsoBone;
var(XCOM_Data) const name						LeftArmBone;
var(XCOM_Data) const name						RightArmBone;
var(XCOM_Data) const name						LeftLegBone;
var(XCOM_Data) const name						RightLegBone;

var ECreatureSex                                Sex;        // Sex - mail|female

var public EPosition                            Position;

/** The visual effect to play when a headshot gibs a head. */
var ParticleSystem HeadShotEffect;

/** Max distance from listener to play footstep sounds */
var float MaxFootstepDistSq;

/** Max distance from listener to play jump/land sounds */
var float MaxJumpSoundDistSq;

//=============================================================================
// Functions: General
//=============================================================================
/** returns the resultant amount of damage after armor have absorbed what they can */
protected function int ArmorAbsorb(int aDamage, class<DamageType> aDamageType, TraceHitInfo HitInfo, vector Momentum, vector HitLocation)
{
	local int lCurrentArmorDefence;
	local name lClosesBone;

	if ( Health <= 0 )
	{
		return aDamage;
	}

	Mesh.ForceSkelUpdate();

	CheckHitInfo(HitInfo, Mesh, Normal(Momentum), HitLocation );

	if (HitInfo.BoneName == '')
	{
		`warn("ArmorAbsorb() HitInfo.BoneName = none");
		lClosesBone = Mesh.FindClosestBone(HitLocation);
		HitInfo.BoneName = lClosesBone;
		if (HitInfo.BoneName == '') CheckHitInfo(HitInfo, Mesh, vect(0,0,0), HitLocation );  // if bone stil is none then last chance to get closest bone names
	}

	Switch (HitInfo.BoneName)
	{
		case LeftArmBone    :   lCurrentArmorDefence = Armor.Arms; 
		break;
		case RightArmBone   :   lCurrentArmorDefence = Armor.Arms; 
		break;
		case TorsoBone      :   lCurrentArmorDefence = Armor.Torso; 
		break;
		case HeadBone       :   //same as NeckBone
		case NeckBone       :   lCurrentArmorDefence = Armor.Head; 
								bWasHeadShot = true;
		break;
		case LeftLegBone    :   lCurrentArmorDefence = Armor.Legs; 
		break;
		case RightLegBone   :   lCurrentArmorDefence = Armor.Legs; 
		break;
		case ''             :   lCurrentArmorDefence = Armor.Other;
		break;
	}

	if ( bWasHeadShot )
	{
		if (self.IsA('X_COM_Pawn'))
		{
			aDamage += HeadshotDamageScale;
			AbsorbDamage(aDamage, lCurrentArmorDefence, 1.0);
			if ((!bIsDied) && (aDamage>0) && (Health<aDamage))
			{
				WorldInfo.MyEmitterPool.SpawnEmitter(HeadShotEffect, HitLocation);
			}
		}
		bWasHeadShot = false;
	}
	else AbsorbDamage(aDamage, lCurrentArmorDefence, 1.0);

	return aDamage;
}

/** We override TakeDamage and allow the weapon to modify it */
simulated event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	//TearOffParts(Damage, HitLocation, Momentum, HitInfo); //отрывание частей тела
}

/** Отрывание частей тела. При попадании по части тела, и получении значительного урона, можно например отстрелить руку или ногу */
function TearOffParts(int Damage, vector HitLocation, vector Momentum, TraceHitInfo HitInfo)
{
	CheckHitInfo(HitInfo, Mesh, Normal(Momentum), HitLocation );	
	if (HitInfo.BoneName != '')
	{
		`log(HitInfo.BoneName);
		//Mesh.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);
		Mesh.HideBoneByName(HitInfo.BoneName,PBO_Disable);
	}
}

//=============================================================================
// Sounds
//=============================================================================
simulated event PlayFootStepSound(int FootDown)
{
	local PlayerController PC;

	if ( !IsFirstPerson() )
	{
		ForEach LocalPlayerControllers(class'PlayerController', PC)
		{
			if ( (PC.ViewTarget != None) && (VSizeSq(PC.ViewTarget.Location - Location) < MaxFootstepDistSq) )
			{
				ActuallyPlayFootstepSound(FootDown);
				return;
			}
		}
	}
}

/**
 * Handles actual playing of sound.  Separated from PlayFootstepSound so we can
 * ignore footstep sound notifies in first person.
 */
simulated function ActuallyPlayFootstepSound(int FootDown)
{
	local SoundCue FootSound;

	FootSound = GetFootstepSound(FootDown, GetMaterialBelowFeet());
	if (FootSound != None)
	{
		PlaySound(FootSound, false, true,,, true);
	}
}

public function SoundCue GetFootstepSound(int FootDown, name MaterialType)
{
	local int i;

	i = FootstepSounds.Find('MaterialType', MaterialType);
	return (i == -1 || MaterialType=='') ? DefaultFootstepSound : FootstepSounds[i].Sound; // checking for a '' material in case of empty array elements
}

simulated function name GetMaterialBelowFeet()
{
	local vector HitLocation, HitNormal;
	local TraceHitInfo HitInfo;
	local X_COM_PhysicalMaterialProperty PhysicalProperty;
	local actor HitActor;
	local float TraceDist;

	TraceDist = 1.5 * GetCollisionHeight();

	HitActor = Trace(HitLocation, HitNormal, Location - TraceDist*vect(0,0,1), Location, false,, HitInfo, TRACEFLAG_PhysicsVolumes);
	if ( WaterVolume(HitActor) != None )
	{
		return (Location.Z - HitLocation.Z < 0.33*TraceDist) ? 'Water' : 'ShallowWater';
	}
	if (HitInfo.PhysMaterial != None)
	{
		PhysicalProperty = X_COM_PhysicalMaterialProperty(HitInfo.PhysMaterial.GetPhysicalMaterialProperty(class'X_COM_PhysicalMaterialProperty'));
		if (PhysicalProperty != None)
		{
			return PhysicalProperty.MaterialType;
		}
	}
	return '';

}

function PlayLandingSound()
{
	local PlayerController PC;

	ForEach LocalPlayerControllers(class'PlayerController', PC)
	{
		if ( (PC.ViewTarget != None) && (VSizeSq(PC.ViewTarget.Location - Location) < MaxJumpSoundDistSq) )
		{
			PlaySound(LandingSound);
			return;
		}
	}
}

function PlayJumpingSound()
{
	local PlayerController PC;

	ForEach LocalPlayerControllers(class'PlayerController', PC)
	{
		if ( (PC.ViewTarget != None) && (VSizeSq(PC.ViewTarget.Location - Location) < MaxJumpSoundDistSq) )
		{
			PlaySound(JumpingSound);
			return;
		}
	}
}

//=============================================================================
// Anims
//=============================================================================
/** Change the type of weapon animation we are playing. */
simulated function SetWeapAnimType(EWeaponHoldTypes aHoldType)
{
	if (AimNode != None)
	{
		switch(aHoldType)
		{
			case EWHT_None:
				AimNode.SetActiveProfileByName('Default');
				break;
			case EWHT_OneHanded:
				AimNode.SetActiveProfileByName('SinglePistol');
				break;
			case EWHT_TwoHanded:
				AimNode.SetActiveProfileByName('DualPistols');
				break;
			case EWHT_Shoulder:
				AimNode.SetActiveProfileByName('ShoulderRocket');
				break;
			case EWHT_VehicleWeapon:
				AimNode.SetActiveProfileByName('Stinger');
				break;
		}
	}
}

//=============================================================================
// Selecting effects
//=============================================================================
/** Show particle effect when pawn is selecting by the player **/
public simulated function ShowUnitSelectingEffect()
{
	local ParticleSystemComponent lPSC;
	`log(" ShowUnitSelectingEffect called ");
	if ( (WorldInfo != none) && (WorldInfo.NetMode == NM_Standalone) )
	{
		WorldInfo.MyEmitterPool.SpawnEmitter(UnitSelectionEffectTemplate, Location, rot(0,0,0)); // не работает в сетевой игре
	}
	else
	{
		if ( UnitSelectionEffectTemplate!=none)
		{
			lPSC = new(Outer)class'ParticleSystemComponent';
			lPSC.SetRotation(rot(0,0,0));
			lPSC.SetTemplate(UnitSelectionEffectTemplate);
			AttachComponent(lPSC);
			lPSC.ActivateSystem();
		}
	}
}

/** Show particle effect when pawn was being selected by the player **/
protected function ShowUnitSelectedEffect()
{
	`log(" ShowUnitSelectedEffect called ");
	//UnitSelectedEffect = WorldInfo.MyEmitterPool.SpawnEmitter(UnitSelectedEffectTemplate, self.Location, self.Rotation, self); // не работает в сетевой игре
	if ( (WorldInfo != none) && (WorldInfo.NetMode == NM_Standalone) )
	{
		UnitSelectedEffect = WorldInfo.MyEmitterPool.SpawnEmitter(UnitSelectedEffectTemplate, Location, rot(0,0,0), self); // не работает в сетевой игре
	}
	else
	{
		if ( UnitSelectedEffectTemplate!=none)
		{
			UnitSelectedEffect = new(Outer)class'ParticleSystemComponent';
			UnitSelectedEffect.SetRotation(rot(0,0,0));
			UnitSelectedEffect.SetTemplate(UnitSelectedEffectTemplate);
			AttachComponent(UnitSelectedEffect);
			UnitSelectedEffect.ActivateSystem();
		}
	}
}

/** Show static particle effect player unit**/
public simulated function ShowStaticUnitEffect()
{
	`log(" ShowStaticUnitEffect called ");
	//StaticUnitEffect = WorldInfo.MyEmitterPool.SpawnEmitter(StaticUnitEffectTemplate, self.Location, self.Rotation, self); // не работает в сетевой игре
	if ( (WorldInfo != none) && (WorldInfo.NetMode == NM_Standalone) )
	{
		StaticUnitEffect = WorldInfo.MyEmitterPool.SpawnEmitter(StaticUnitEffectTemplate, Location, rot(0,0,0), self); // не работает в сетевой игре
	}
	else
	{
		if ( StaticUnitEffectTemplate!=none)
		{
			StaticUnitEffect = new(Outer)class'ParticleSystemComponent';
			StaticUnitEffect.SetRotation(rot(0,0,0));
			StaticUnitEffect.SetTemplate(StaticUnitEffectTemplate);
			AttachComponent(StaticUnitEffect);
			StaticUnitEffect.ActivateSystem();
		}
	}
}

//=============================================================================
// DefaultProperties
//=============================================================================
DefaultProperties
{
	mStatsClass = class'X_COM_Stats_Pawn'

	Position = EP_Standing

	LeftFootControlName=LeftFootControl
	RightFootControlName=RightFootControl

	bEnableFootPlacement=TRUE
	MaxFootPlacementDistSquared=56250000.0 // 7500 squared

	bCanPickupInventory=TRUE

	bCanCrouch = true

	MaxFootstepDistSq=9000000.0
	MaxJumpSoundDistSq=16000000.0

	LeftFootBone=b_LeftAnkle
	RightFootBone=b_RightAnkle
	TakeHitPhysicsFixedBones[0]=b_LeftAnkle
	TakeHitPhysicsFixedBones[1]=b_RightAnkle

	HeadshotDamageScale = 90
	HeadBone = b_Head
	NeckBone = b_Neck 
	TorsoBone = b_Spine1
	LeftArmBone = b_LeftForeArm
	RightArmBone = b_RightForeArm
	LeftLegBone = b_LeftLegUpper
	RightLegBone = b_RightLegUpper

	DefaultPhysics = PHYS_Walking

	FootstepSounds[0]=(MaterialType=Stone,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_StoneCue')
	FootstepSounds[1]=(MaterialType=Dirt,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtCue')
	FootstepSounds[2]=(MaterialType=Energy,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_EnergyCue')
	FootstepSounds[3]=(MaterialType=Flesh_Human,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_FleshCue')
	FootstepSounds[4]=(MaterialType=Foliage,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_FoliageCue')
	FootstepSounds[5]=(MaterialType=Glass,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GlassPlateCue')
	FootstepSounds[6]=(MaterialType=Water,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterDeepCue')
	FootstepSounds[7]=(MaterialType=ShallowWater,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterShallowCue')
	FootstepSounds[8]=(MaterialType=Metal,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_MetalCue')
	FootstepSounds[9]=(MaterialType=Snow,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_SnowCue')
	FootstepSounds[10]=(MaterialType=Wood,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WoodCue')

	Name="Default__X_COM_Pawn"
}