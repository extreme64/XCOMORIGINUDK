/**
 * X-Com special alien pawn class.
 */
class X_COM_Vehicle extends X_COM_Unit;

var(XCOM_Unit) const public array<name> GunSocketName;
var(XCOM_Unit) const public array<name> RocketSocketName;
//var const public name GunFiredSocketName;

var(XCOM_Effects) protected const MaterialInterface BurnOutMaterial;

/** The material instances and their data used when showing the burning hulk */
var array<BurnOutDatum> BurnOutMaterialInstances;

/** Holds the Vehicle Effects data */
var(XCOM_Effects) protected array<VehicleEffect>	VehicleEffects;
/** Templates used for explosions */
var(XCOM_Effects) protected const ParticleSystem ExplosionTemplate;
//var array<DistanceBasedParticleEffects> BigExplosionTemplates;
/** Secondary explosions from vehicles.  (usually just dust when they are impacting something) **/
var(XCOM_Effects) protected const ParticleSystem SecondaryExplosion;

/** Class of ExplosionLight */
var class<UDKExplosionLight> ExplosionLightClass;

/**
 * How long to wait after the InitialVehicleExplosion before doing the Secondary VehicleExplosion (if it already has not happened)
 * (e.g. due to the vehicle falling from the air and hitting the ground and doing it's secondary explosion that way).
 **/
var float TimeTilSecondaryVehicleExplosion;

/** Max distance to create ExplosionLight */
var float	MaxExplosionLightDistance;

/** Damage/Radius/Momentum parameters for dying explosions */
var(XCOM_Damage) protected const float ExplosionDamage, ExplosionRadius, ExplosionMomentum;

/** The Damage Type of the explosion when the vehicle is upside down */
var class<DamageType> ExplosionDamageType;

/** socket to attach big explosion to (if 'None' it won't be attached at all) */
//var(XCOM_Effects) protected const name BigExplosionSocket;

/** How long does it take to burn out */
var(XCOM_Effects) protected const float BurnOutTime;

/** How long should the vehicle should last after being destroyed */
var(XCOM_Effects) protected const float DeadVehicleLifeSpan;

/** Ambient engine-running sound.  Pitch modulated based on RPMS.	*/
var(XCOM_Sounds) editconst const AudioComponent EngineSound;

/** Time delay between the engine startup sound and the engine idling sound.						*/
var(XCOM_Sounds) const float	EngineStartOffsetSecs;

/** Time delay between the engine shutdown sound and the deactivation of the engine idling sound.	*/
var(XCOM_Sounds) const float	EngineStopOffsetSecs;

/** Played when the vehicle slams into things.						*/
var(XCOM_Sounds) const SoundCue CollisionSound;

/** Minimum time passed between the triggering collision sounds; generally set to longest collision sound. */
var float CollisionIntervalSecs;

/** Internal variable; prevents collision sounds from being triggered too frequently.	*/
var float LastCollisionSoundTime;

/** sound for dying explosion */
var(XCOM_Sounds) const SoundCue ExplosionSound;

/** Sound to play when spawning in */
var(XCOM_Sounds) const SoundCue SpawnInSound;

/** Sound to play when despawning */
var(XCOM_Sounds) const SoundCue SpawnOutSound;

/** The health ratio threshold at which the vehicle will begin smoking */
var float DamageSmokeThreshold;

/** The health ratio threshold at which the vehicle will catch on fire (and begin to take continuous damage if empty) */
var float FireDamageThreshold;

/**
 * This is a reference to the Emitter we spawn on death.  We need to keep a ref to it (briefly) so we can
 * turn off the particle system when the vehicle decided to burnout.
 **/
var Emitter DeathExplosion;

struct native VehicleAnim
{
	/** Used to look up the animation */
	var() name AnimTag;

	/** Animation Sequence sets to play */
	var() array<name> AnimSeqs;

	/** Rate to play it at */
	var() float AnimRate;

	/** Does it loop */
	var() bool bAnimLoopLastSeq;

	/**  The name of the AnimNodeSequence to use */
	var() name AnimPlayerName;
};

/** Holds a list of vehicle animations */
var(XCOM_Effects) array<VehicleAnim>	VehicleAnims;

struct native VehicleSound
{
	var() name SoundStartTag;
	var() name SoundEndTag;
	var() SoundCue SoundTemplate;
	var AudioComponent SoundRef;
};

var(XCOM_Effects) array<VehicleSound> VehicleSounds;

/** If vehicle dies in the air, this is how much spin is given to it. */
var float ExplosionInAirAngVel;

/** PhysicalMaterial to use while driving */
var transient PhysicalMaterial DrivingPhysicalMaterial;

/** socket to attach big explosion to (if 'None' it won't be attached at all) */
var(XCOM_Unit) const name MeshCenterSocket;

//=============================================================================
// Functions:
//=============================================================================
function gibbedBy(actor Other); // should not be used

/**
 * Initialization
 */
simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	SetTimer(0.01, false, 'InitializeEffects');		// Setup any effects for this vehicle

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		UpdateShadowSettings(!class'Engine'.static.IsSplitScreen());
	}

	if ( DrivingPhysicalMaterial != None )
	{
		Mesh.SetPhysMaterialOverride(DrivingPhysicalMaterial);
	}

	if( EngineSound != None )
	{
		EngineSound.bShouldRemainActiveIfDropped = TRUE;
	}
	if (CollisionSound != None)
	{
		CollisionIntervalSecs = CollisionSound.GetCueDuration() / WorldInfo.TimeDilation;
	}

	VehicleEvent('Created');

	StartEngineSound();
}

/** turns on the engine sound */
simulated function StartEngineSound()
{
	if (EngineSound != None)
	{
		EngineSound.Play();
	}
}

/** turns off the engine sound */
simulated function StopEngineSound()
{
	if (EngineSound != None)
	{
		EngineSound.Stop();
	}
}

/************************************************************************************
 * Effects
 ***********************************************************************************/
simulated function CreateVehicleEffect(int EffectIndex)
{
	VehicleEffects[EffectIndex].EffectRef = new(self) class'ParticleSystemComponent';
	if (VehicleEffects[EffectIndex].EffectStartTag != 'BeginPlay')
	{
		VehicleEffects[EffectIndex].EffectRef.bAutoActivate = false;
	}

	VehicleEffects[EffectIndex].EffectRef.SetTemplate(VehicleEffects[EffectIndex].EffectTemplate);

	Mesh.AttachComponentToSocket(VehicleEffects[EffectIndex].EffectRef, VehicleEffects[EffectIndex].EffectSocket);
}

/**
 * Initialize the effects system.  Create all the needed PSCs and set their templates
 */
simulated function InitializeEffects()
{
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		TriggerVehicleEffect('BeginPlay');
	}
}

/**
 * Whenever a vehicle effect is triggered, this function is called (after activation) to allow for the
 * setting of any parameters associated with the effect.
 *
 * @param	TriggerName		The effect tag that describes the effect that was activated
 * @param	PSC				The Particle System component associated with the effect
 */
simulated function SetVehicleEffectParms(name TriggerName, ParticleSystemComponent PSC)
{
	local float Pct;

	if (TriggerName == 'DamageSmoke')
	{
		Pct = float(Health) / float(HealthMax);
		PSC.SetFloatParameter('smokeamount', (Pct < DamageSmokeThreshold) ? (1.0 - Pct) : 0.0);
		PSC.SetFloatParameter('fireamount', (Pct < FireDamageThreshold) ? (1.0 - Pct) : 0.0);
	}
}

/**
 * Trigger or untrigger a vehicle effect
 *
 * @param	EventTag	The tag that describes the effect
 *
 */
simulated function TriggerVehicleEffect(name EventTag)
{
	local int i;

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		for (i = 0; i < VehicleEffects.length; i++)
		{
			if (VehicleEffects[i].EffectStartTag == EventTag)
			{
				if ( !VehicleEffects[i].bHighDetailOnly || (WorldInfo.GetDetailMode() == DM_High) )
				{
					if (VehicleEffects[i].EffectRef == None)
					{
						CreateVehicleEffect(i);
					}
					if (VehicleEffects[i].bRestartRunning)
					{
						VehicleEffects[i].EffectRef.KillParticlesForced();
						VehicleEffects[i].EffectRef.ActivateSystem();
					}
					else if (!VehicleEffects[i].EffectRef.bIsActive)
					{
						VehicleEffects[i].EffectRef.ActivateSystem();
					}

					SetVehicleEffectParms(EventTag, VehicleEffects[i].EffectRef);
				}
			}
			else if (VehicleEffects[i].EffectRef != None && VehicleEffects[i].EffectEndTag == EventTag)
			{
				VehicleEffects[i].EffectRef.DeActivateSystem();
			}
		}
	}
}

/**
 * Trigger or untrigger a vehicle sound
 *
 * @param	SoundTag	The tag that describes the effect
 *
 */
simulated function PlayVehicleSound(name SoundTag)
{
	local int i;
	for(i=0;i<VehicleSounds.Length;++i)
	{
		if(VehicleSounds[i].SoundEndTag == SoundTag)
		{
			if(VehicleSounds[i].SoundRef != none)
			{
				VehicleSounds[i].SoundRef.Stop();
				VehicleSounds[i].SoundRef = none;
			}
		}
		if(VehicleSounds[i].SoundStartTag == SoundTag)
		{
			if(VehicleSounds[i].SoundRef == none)
			{
				VehicleSounds[i].SoundRef = CreateAudioComponent(VehicleSounds[i].SoundTemplate, false, true);
			}
			if(VehicleSounds[i].SoundRef != none && (!VehicleSounds[i].SoundRef.bWasPlaying || VehicleSounds[i].SoundRef.bFinished))
			{
				VehicleSounds[i].SoundRef.Play();
			}
		}
	}
}

simulated function StopVehicleSounds()
{
	local int i;
	for (i=0; i < VehicleSounds.Length; i++)
	{
		VehicleSounds[i].SoundRef.Stop();
	}
}

/**
 * Plays a Vehicle Animation
 */
simulated function PlayVehicleAnimation(name EventTag)
{
	local int i;
	local UDKAnimNodeSequence Player;

	if ( Mesh != none && mesh.Animations != none && VehicleAnims.Length > 0 )
	{
		for (i=0;i<VehicleAnims.Length;i++)
		{
			if (VehicleAnims[i].AnimTag == EventTag)
			{
				Player = UDKAnimNodeSequence(Mesh.Animations.FindAnimNode(VehicleAnims[i].AnimPlayerName));
				if ( Player != none )
				{
					Player.PlayAnimationSet( VehicleAnims[i].AnimSeqs,
												VehicleAnims[i].AnimRate,
												VehicleAnims[i].bAnimLoopLastSeq );
				}
			}
		}
	}
}

/**
 * An interface for causing various events on the vehicle.
 */
simulated function VehicleEvent(name EventTag)
{
	// Cause/kill any effects
	TriggerVehicleEffect(EventTag);

	// Play any animations
	PlayVehicleAnimation(EventTag);

	PlayVehicleSound(EventTag);
}

function StartEngine()
{
	VehicleEvent('EngineStart');
}

function StopEngine()
{
	VehicleEvent('EngineStop');
}

//=============================================================================
// Anims
//=============================================================================
event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
	super.OnAnimEnd(SeqNode,PlayedTime,ExcessTime);
	VehicleEvent('Fly');
}

simulated event OnDestroy(SeqAct_Destroy Action)
{
	super.OnDestroy(Action);
	if (StaticUnitEffect != none)
	{
		StaticUnitEffect.DeactivateSystem();
		StaticUnitEffect = none;
		ShowSelectedEffect(false);
	}	
}

//=============================================================================
// Dying
//=============================================================================
simulated state DyingVehicle
{
	ignores Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer, FellOutOfWorld;

	simulated function PlayWeaponSwitch(Weapon OldWeapon, Weapon NewWeapon) {}
	simulated function PlayNextAnimation() {}
	singular event BaseChange() {}
	event Landed(vector HitNormal, Actor FloorActor) {}

	function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation);

	simulated event PostRenderFor(PlayerController PC, Canvas Canvas, vector CameraPosition, vector CameraDir) {}

	simulated function BlowupVehicle() {}

	simulated function CheckDamageSmoke();

	/** spawn an explosion effect and damage nearby actors */
	simulated function DoVehicleExplosion(bool bDoingSecondaryExplosion)
	{
		local ParticleSystem Template;
		local bool bIsVisible;

		if ( WorldInfo.NetMode != NM_DedicatedServer )
		{
			if ( bDoingSecondaryExplosion )
			{
				// already checked visibility
				bIsVisible = true;
			}
			else
			{
				bIsVisible = bIsVisible || (WorldInfo.TimeSeconds - LastRenderTime < 3.0);
			}

			// determine which explosion to use
			if ( bIsVisible )
			{
				if( !bDoingSecondaryExplosion )
				{
					Template = ExplosionTemplate;

					//if( BigExplosionTemplates.length > 0 )
					//{
					//	Template = class'X_COM_Emitter'.static.GetTemplateForDistance(BigExplosionTemplates, Location, WorldInfo);
					//}
				}
				else
				{
					Template = SecondaryExplosion;
				}

				PlayVehicleExplosionEffect( Template, !bDoingSecondaryExplosion );
			}

			if (ExplosionSound != None)
			{
				PlaySound(ExplosionSound, true);
			}
		}
		HurtRadius(ExplosionDamage, ExplosionRadius, class'X_COM_DamageType_Vehicle_Explosion', ExplosionMomentum, Location,);
		AddVelocity((ExplosionMomentum / Mass) * vect(0,0,1), Location, class'X_COM_DamageType_Vehicle_Explosion');

		// If in air, add some anglar spin.
		if(Role == ROLE_Authority)
		{
			Mesh.SetRBAngularVelocity(VRand() * ExplosionInAirAngVel, TRUE);
		}
	}

	/** This will spawn the actual explosion particle system.  It could be a fiery death or just dust when the vehicle hits the ground **/
	simulated function PlayVehicleExplosionEffect( ParticleSystem TheExplosionTemplate, bool bSpawnLight )
	{
		local UDKExplosionLight L;

		if (TheExplosionTemplate != None)
		{
			DeathExplosion = Spawn(class'X_COM_Emitter', self);
			if (MeshCenterSocket != 'None')
			{
				DeathExplosion.SetBase(self,, Mesh, MeshCenterSocket);
			}
			DeathExplosion.SetTemplate(TheExplosionTemplate, true);
			DeathExplosion.ParticleSystemComponent.SetFloatParameter('Velocity', VSize(Velocity) / GroundSpeed);

			if (bSpawnLight && ExplosionLightClass != None && !WorldInfo.bDropDetail && ShouldSpawnExplosionLight(Location, vect(0,0,1)))
			{
				L = new(DeathExplosion) ExplosionLightClass;
				DeathExplosion.AttachComponent(L);
			}
		}
	}

	/** This does the secondary explosion of the vehicle (e.g. from reserve fuel tanks finally blowing / ammo blowing up )**/
	simulated function SecondaryVehicleExplosion()
	{
		// here we need to check to see if we are a vehicle which is falling down from the sky!
		// if we are then we want to push the actual burn out til after we have hit the ground (and don secondary explosion)
		if( Velocity.Z < -100.0f )
		{
			SetTimer( 1.0f, false, 'SecondaryVehicleExplosion' );
			LifeSpan += 1.0f;

			return;
		}
		// we are just going to have vehicles do a "secondary explosion" of dust and rock based on RigidBodyCollision
		//PerformSecondaryVehicleExplosion();
	}

	simulated function PerformSecondaryVehicleExplosion()
	{
		local X_COM_PlayerController xcPC;
		local bool bIsVisible;

		Mesh.SetNotifyRigidBodyCollision( FALSE );

		// only actually do secondary explosion if being rendered
		foreach LocalPlayerControllers(class'X_COM_PlayerController', xcPC)
		{
			if ( (LocalPlayer(xcPC.Player) != None) && LocalPlayer(xcPC.Player).GetActorVisibility(self)
				&& (xcPC.ViewTarget != None) )
			{
				bIsVisible = (VSizeSq(xcPC.ViewTarget.Location - Location) < 25000000.0);
				break;
			}
		}
		if ( bIsVisible )
		{
			DoVehicleExplosion(true);
		}
	}

	simulated event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent, const out CollisionImpactData Collision, int ContactIndex )
	{
		Super.RigidBodyCollision(HitComponent, OtherComponent, Collision, ContactIndex);

		if( IsTimerActive( 'SecondaryVehicleExplosion' ) )
		{
			ClearTimer( 'SecondaryVehicleExplosion' );
			PerformSecondaryVehicleExplosion();
		}
	}


	simulated event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> aDamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
	{
		if (aDamageType != None)
		{
			Health -= Damage;
			AddVelocity(Momentum, HitLocation, aDamageType, HitInfo);

			if (aDamageType == class'X_COM_DamageType_Vehicle_Collision')
			{
				if ( EffectIsRelevant(Location, false) )
				{
					WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionTemplate, HitLocation, rotator(vect(0,0,1)));
				}
				if (ExplosionSound != None)
				{
					PlaySound(ExplosionSound, true);
				}
			}
		}
	}

	simulated function BeginState(name PreviousStateName)
	{
		local int i;

		StopVehicleSounds();

		// make sure smoke/fire are on
		DamageSmokeThreshold = 0.0; //VehicleEvent('DamageSmoke');
		CheckDamageSmoke();

		DoVehicleExplosion(false);

		if( TimeTilSecondaryVehicleExplosion > 0.0f )
		{
			SetTimer( TimeTilSecondaryVehicleExplosion, FALSE, 'SecondaryVehicleExplosion' );
		}

		SetBurnOut();

		if (Controller != None)
		{
			Controller.Destroy();
		}

		for (i = 0; i < Attached.length; i++)
		{
			if (Attached[i] != None)
			{
				Attached[i].PawnBaseDied();
			}
		}
	}
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	if ( Super.Died(Killer, DamageType, HitLocation) )
	{
		HitDamageType = DamageType; // these are replicated to other clients
		TakeHitLocation = HitLocation;

		StopEngineSound();

		BlowupVehicle();
		return true;
	}
	return false;
}

simulated function SetBurnOut()
{
	local int i, NumElements;
	local BurnOutDatum BOD;

	if ( LifeSpan > 0.0 ) return;

	// burn out immediately if parked on flag
	LifeSpan = DeadVehicleLifeSpan;

	// set up material instance (for burnout effects)
	if (BurnOutMaterial != None) Mesh.SetMaterial(0,BurnOutMaterial);

	NumElements = Mesh.GetNumElements();
	for (i = 0; i < NumElements; i++)
	{
		BOD.MITV = Mesh.CreateAndSetMaterialInstanceTimeVarying(i);
		BurnOutMaterialInstances[BurnOutMaterialInstances.length] = BOD;

		//Set the time here to arbitrary amount to stall effect until StartBurnOut is called
		BOD.MITV.SetScalarStartTime('BurnTime', LifeSpan - BurnOutTime);
	}
	SetTimer(LifeSpan - BurnOutTime, false, 'StartBurnOut');
}

/** turns off collision on the vehicle when it's almost fully burned out */
simulated function DisableCollision()
{
	SetCollision(false);
	Mesh.SetBlockRigidBody(false);
}

/** deactivates smoke/fire emitter when vehicle is mostly burned out */
simulated function DisableDamageSmoke()
{
	VehicleEvent('NoDamageSmoke');
}

simulated function StartBurnOut()
{
	local int i;
	local int NumBurnOutMaterials;

	if (SpawnOutSound != none)
	{
		PlaySound( SpawnOutSound, TRUE );
	}

	SetTimer( 0.500, FALSE, 'DisableCollision' ); // turn off collision quicker rather than slower for when vehicles are burning out
	DisableDamageSmoke();
	StopVehicleSounds();

	NumBurnOutMaterials = BurnOutMaterialInstances.length;
	for( i = 0; i < NumBurnOutMaterials; ++i )
	{
		if( BurnOutMaterialInstances[i].MITV != None )
		{
			//`log( NumBurnOutMaterials $ " starting burnout on: " $ BurnOutMaterialInstances[i].MITV $ " " $ self );
			 BurnOutMaterialInstances[i].MITV.SetScalarStartTime( 'BurnTime', 0.0f );
		}
	}

	// these will turn off the damage Particle Effects (smoke/fire/sparks)
	VehicleEvent( 'NoDamageSmoke' );
	if( DeathExplosion != none )
	{
		DeathExplosion.ParticleSystemComponent.DeactivateSystem();
	}

	// wait a few before turning off shadows (this reduces the jarring pop that you see if everything happens all at once)
	SetTimer( 0.5f, FALSE, 'TurnOffShadows' );
}

/** This will turn off the shadow casting of the vehicle **/
simulated function TurnOffShadows()
{
	// turn off any shadows we have
	UpdateShadowSettings( FALSE );
	//Mesh.CastShadow = FALSE;
	//DynamicLightEnvironmentComponent(Mesh.LightEnvironment).bCastShadows = FALSE;
}

/**
 * Call this function to blow up the vehicle
 */
simulated function BlowupVehicle()
{
	VehicleEvent('EngineStop');

	bCanBeBaseForPawns = false;
	GotoState('DyingVehicle');
	AddVelocity(TearOffMomentum, TakeHitLocation, HitDamageType);
}

/** ShouldSpawnExplosionLight()
Decide whether or not to create an explosion light for this explosion
*/
simulated function bool ShouldSpawnExplosionLight(vector HitLocation, vector HitNormal)
{
	local PlayerController P;
	local float Dist;

	// decide whether to spawn explosion light
	ForEach LocalPlayerControllers(class'PlayerController', P)
	{
		Dist = VSize(P.ViewTarget.Location - Location);
		if ( (P.Pawn == Instigator) || (Dist < ExplosionLightClass.Default.Radius) || ((Dist < MaxExplosionLightDistance) && ((vector(P.Rotation) dot (Location - P.ViewTarget.Location)) > 0)) )
		{
			return true;
		}
	}
	return false;
}

/**
 * This event occurs when the physics determines the vehicle is upside down or empty and on fire.  Called from AUTVehicle::TickSpecial()
 */
simulated event TakeFireDamage()
{
	local int CurrentDamage;

	CurrentDamage = int(AccruedFireDamage);
	AccruedFireDamage -= CurrentDamage;
	TakeDamage(CurrentDamage, Controller, Location, vect(0,0,0), ExplosionDamageType);
}

simulated event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent,
					const out CollisionImpactData RigidCollisionData, int ContactIndex )
{
	if( CollisionSound != None && WorldInfo.TimeSeconds - LastCollisionSoundTime > CollisionIntervalSecs )
	{
		PlaySound(CollisionSound, true);
		LastCollisionSoundTime = WorldInfo.TimeSeconds;
	}
}

/** UNIT override: returns the resultant amount of damage after armor have absorbed what they can */
protected function int ArmorAbsorb(int aDamage, class<DamageType> aDamageType, TraceHitInfo HitInfo, vector Momentum, vector HitLocation)
{
	local int lCurrentArmorDefence;

	if ( Health <= 0 )
	{
		return aDamage;
	}

	Mesh.ForceSkelUpdate();

	CheckHitInfo(HitInfo, Mesh, Normal(Momentum), HitLocation );

	lCurrentArmorDefence = Armor.Other; //TODO : REDO переделать на единое получение брони

	//`log("HitInfo.BoneName : "$HitInfo.BoneName);

	AbsorbDamage(aDamage, lCurrentArmorDefence, 1.0);

	return aDamage;
}


//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
	mStatsClass = class'X_COM_Stats_Vehicle'

	BurnOutTime=5.5
	DeadVehicleLifeSpan=0.0

	ExplosionLightClass=class'X-COM_GAME.X_COM_ExplosionLight'
	MaxExplosionLightDistance=+4000.0

	DamageSmokeThreshold=0.65
	FireDamageThreshold=0.40

	TimeTilSecondaryVehicleExplosion=2.0f

	ExplosionInAirAngVel=1.5

	Begin Object Class=AudioComponent Name=EngineSound
		SoundCue = SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_EngineLoop'
	End Object
	EngineSound=EngineSound
	Components.Add(EngineSound);

  
	Name="Default__X_COM_Vehicle"
}
