class X_COM_Weapon extends X_COM_Inventory
	nativereplication
	abstract;
	
//=============================================================================
// Aim
//=============================================================================
/** Location where weapon should fire at */
var protectedwrite vector AimLocation; 

//=============================================================================
// Variables
//=============================================================================
/** projectile class which is used when weapon fires */
var(XCOM_Weapon_Projectile) const X_COM_Projectile ProjectileTemplate;

var EFiringModes FireMode;

var(XCOM_Weapon) const EWeaponTypes WeaponType;
var(XCOM_Weapon) const EWeaponHoldTypes WeaponHoldType; 
var const EWeaponFireType FireType;
var(XCOM_Weapon) const int Damage;
var(XCOM_Weapon) const class<DamageType> MyDamageType;

/** range of the weapon can fire, in meters */
var(XCOM_Weapon) const float WeaponRange;

var(XCOM_Weapon) const int MaxAmmoCount;
var protected int AmmoCount;

var protectedwrite bool bReadyForFire; // Готово ли оружие к стрельбе (выполнены все подготовления и анимации и оружие активировано)

//=============================================================================
// Characteristics
//=============================================================================
var(XCOM_Weapon) const protected int      WeaponConvenience; // Удобность
var(XCOM_Weapon) const protected int      WeaponRecoil; // Отдача

//=============================================================================
// Weapon Constants Defines
//=============================================================================
const                   A_Aimed = 1.3;
const                   A_Burst = 1.0;
const                   A_Quick = 1.1;
const                   A_Throw = 0.8;

//=============================================================================
//  Muzzle Flash
//=============================================================================
/** Holds the name of the socket to attach a muzzle flash too */
var(XCOM_Weapon) const name	FireEffectSocket;

/** Muzzle flash PSC and Templates*/
var protected ParticleSystemComponent	MuzzleFlashPSC;

/** Particle Systems for our firemodes */
var(XCOM_Weapon) const ParticleSystem			MuzzleFlashPSCTemplate;

/** How long the Muzzle Flash should be there */
var(XCOM_Weapon) const float					MuzzleFlashDuration;

/** Whether muzzleflash has been initialized */
var bool					bMuzzleFlashAttached;

//=============================================================================
// Animations
//=============================================================================
/** Animation to play when the weapon is fired */
var(XCOM_Weapon_Animations)	const name	WeaponFireAnim;

/** Animation to play when the weapon is Put Down */
var(XCOM_Weapon_Animations) const name	WeaponPutDownAnim;

/** Animation to play when the weapon is Equipped */
var(XCOM_Weapon_Animations) const name	WeaponEquipAnim;

/** Animation to play when the weapon is Idle */
var(XCOM_Weapon_Animations) const name    WeaponIdleAnim;

/** Time for weapon animation before it will be ready to fire */
var(XCOM_Weapon_Animations)	const float    DelayBeforeFireForAnim;

var(XCOM_Weapon_Animations)	const float    FireInterval;

/** Ignore Fire Interval. This will ignore time to sleep to finish any weapon animation. As result the weapon will be ready to fire again immidiately. Needs most for GEO weapons*/
var(XCOM_Weapon_Animations)	const bool     bIgnoreFireInterval;

var(XCOM_Weapon_Animations)	const float    IdleAnimTime;


//=============================================================================
// Sounds
//=============================================================================
/** Sound to play when the weapon is fired */
var(XCOM_Weapon_Sounds)	SoundCue	WeaponFireSnd;

/** Sound to play when the weapon is Put Down */
var(XCOM_Weapon_Sounds) SoundCue 	WeaponPutDownSnd;

/** Sound to play when the weapon is Equipped */
var(XCOM_Weapon_Sounds) SoundCue 	WeaponEquipSnd;

//=============================================================================
// State and flobal variables
//=============================================================================
/** FireInterval sleep timer value */
var private float SleepTime;


//=============================================================================
// Replication
//=============================================================================
//replication
//{
//	// Replicate if client
//	if ( (Role < ROLE_Authority) || (Role == ROLE_Authority) )

//	FireMode;
//}

//simulated event ReplicatedEvent(name VarName)
//{
//	if (VarName == 'bShieldsActive')
//	{
//		if (bShieldsActive) ActivateShield(ShieldType);
//		else DeActivateShield();
//	}
//	else if (VarName == 'ActiveWeapon')
//	{
//		CreateInventoryFromTemplate(ActiveWeapon);
//	}
//	else
//	{
//		super.ReplicatedEvent(VarName);
//	}
//}

//=============================================================================
// Functions main
//=============================================================================
simulated public function bool ActivateItem(optional name aSocketName)
{
	local X_COM_Unit P;
	local bool bSuccess;

	if (bActive) return true; 

	P = X_COM_Unit(Instigator);

	if (aSocketName != '') bSuccess = AttachItemTo(aSocketName);
	else bSuccess = AttachItemTo(P.WeaponSocket);

	if (bSuccess)
	{
		P.ActiveWeapon = self;
	}

	return bSuccess;
}

/** Deactivate current weapon */
simulated public function bool DeactivateItem()
{
	return super.DeactivateItem();
}

simulated function ReattachWeaponMesh()
{
	DetachComponent(Mesh);
	AttachComponent(Mesh);
}

//=============================================================================
// Set | GET
//=============================================================================
/**
 * Returns the type of projectile to spawn.  We use a function so subclasses can
 * override it if needed (case in point, homing rockets).
 */
protected function class<Projectile> GetProjectileClass()
{
	return ProjectileTemplate.Class;
}

simulated public function SetFireMode(EFiringModes aNewFireMode)
{
	FireMode = aNewFireMode;
	bForceNetUpdate = true;
}

//=============================================================================
// Ammunition / Inventory
//=============================================================================
function int GetAmmoCount()
{
	return AmmoCount;
}

 /** Consumes some of the ammo */
function ConsumeAmmo()
{
	AddAmmo(-1); // Subtract the Ammo
}

/** This function is used to add ammo back to a weapon.  It's called from the Inventory Manager */
function int AddAmmo( int Amount )
{
	AmmoCount = Clamp(AmmoCount + Amount, 0, MaxAmmoCount);
	return AmmoCount;
}


/** Returns true if the ammo is maxed out */
function bool AmmoMaxed(int mode)
{
	return (AmmoCount >= MaxAmmoCount);
}

/** returns true if this weapon has any ammo  */
simulated function bool HasAmmo()
{
	return ( AmmoCount > 0 );
}

/** This function retuns how much of the clip is empty. */
function float DesireAmmo()
{
	return (1.f - float(AmmoCount)/MaxAmmoCount);
}

/** Returns true if the current ammo count is less than the default ammo count */
function bool NeedAmmo()
{
	return ( AmmoCount < Default.MaxAmmoCount );
}

/**
 * Cheat Help function the loads out the weapon
 *
 * @param 	bUseWeaponMax 	- [Optional] If true, this function will load out the weapon
 *							  with the actual maximum, not 999
 */
function LoadAmmo()
{
	AmmoCount = MaxAmmoCount;
}

/**
 * Called when the weapon runs out of ammo during firing
 */
simulated function WeaponEmpty()
{

}

function bool CanAttack(Actor Other)
{
	return ( HasAmmo() && (abs(Vsize(Other.Location - Location)) < WeaponRange) );
}

//=============================================================================
// Firing
//=============================================================================
/**
 * Called on the LocalPlayer, Fire sends the shoot request to the server (ServerStartFire)
 * and them simulates the firing effects locally.
 * Call path: PlayerController::StartFire -> Pawn::StartFire -> InventoryManager::StartFire
 * Network: LocalPlayer
 */
simulated function StartFire(vector aAtLocation)
{
	if( !bDeleteMe && Instigator != None )
	{
		if( Role < Role_Authority )
		{
			// if we're a client, synchronize server
			ServerStartFire(aAtLocation);
		}

		// Start fire locally
		BeginFire(aAtLocation);
	}
}

/**
 * When StartFire() is called on a client, it replicates the start by calling ServerStartFire.  This
 * begins the event on server.  Server side actors (such as bots) should not call ServerStartFire directly and should
 * instead call StartFire().
 *
 * Network: Dedicated Server only, or Listen Server for remote clients.
 */
reliable server function ServerStartFire(vector aAtLocation)
{
	// A client has fired, so the server needs to
	// begin to fire as well
	BeginFire(aAtLocation);
}


/**
 * BeginFire is the point at which the server and client sync up their code path.  It's job is to set
 * the weapon in to the firing state.
 * Network: LocalPlayer and Server
 */
simulated function BeginFire(vector aAtLocation)
{
	AimLocation = aAtLocation;
	if ( IsInState('ACTIVE') ) GoToState('WEAPONFIRING');
}

simulated function FireAmmunition()
{
	switch( FireType )
	{
		case EWFT_InstantHit:
			InstantFire();
			break;

		case EWFT_Projectile:
			X_COM_Unit(instigator).Fired_Projectile = X_COM_Projectile(ProjectileFire());
			break;

		case EWFT_Custom:
			CustomFire();
			break;
	}

	// Use ammunition to fire
	ConsumeAmmo();

	// if this is the local player, play the firing effects
	PlayFiringSound();
	PlayFireEffects();
}

protected function vector GetAimPoint()
{
	return AimLocation;
}

/** Fires a projectile. */
simulated function Projectile ProjectileFire()
{
	local Rotator       ProjectileStartrot;
	local vector        ProjectileStartLoc;
	local Projectile    SpawnedProjectile;
	local vector        ProjectileDirection;
	local int           NewDamage;
	local int           MinDamage;
	local vector        lSocketLocation;
	local Rotator       lSocketRotation;      

    if( Role == ROLE_Authority )
    {
		if ( Mesh.GetSocketWorldLocationAndRotation(FireEffectSocket, lSocketLocation, lSocketRotation) )
		{
			ProjectileStartLoc = lSocketLocation;
			ProjectileStartrot = lSocketRotation;
		}
		else
		{
			ProjectileStartLoc = Location;
			ProjectileStartrot = Rotation;
		}

		ProjectileDirection =  GetAimPoint() - ProjectileStartLoc;

  		SpawnedProjectile = Spawn(ProjectileTemplate.Class, self, , ProjectileStartLoc, ProjectileStartrot, ProjectileTemplate, true);

  		if ((SpawnedProjectile != None) && (!SpawnedProjectile.bDeleteMe))
  		{
			MinDamage = Damage/10; // min damage  = 10% of Damage
			NewDamage = int(RandRange(MinDamage, Damage));
			X_COM_Projectile(SpawnedProjectile).SetDamageParams(NewDamage, MyDamageType);
  			SpawnedProjectile.Init(normal(ProjectileDirection) );   //this is where you decide the projectile's direction of travel
  		}

  		return SpawnedProjectile;
     }
     return None;
}
/**
 * If the weapon isn't an instant hit, or a simple projectile, it should use the tyoe EWFT_Custom.  In those cases
 * this function will be called.  It should be subclassed by the custom weapon.
 */
simulated function CustomFire();

/**
 * CalcWeaponFire: Simulate an instant hit shot.
 * This doesn't deal any damage nor trigger any effect. It just simulates a shot and returns
 * the hit information, to be post-processed later.
 *
 * ImpactList returns a list of ImpactInfo containing all listed impacts during the simulation.
 * CalcWeaponFire however returns one impact (return variable) being the first geometry impact
 * straight, with no direction change. If you were to do refraction, reflection, bullet penetration
 * or something like that, this would return exactly when the crosshair sees:
 * The first 'real geometry' impact, skipping invisible triggers and volumes.
 *
 * @param	StartTrace	world location to start trace from
 * @param	EndTrace	world location to end trace at
 * @param	ImpactList	list of all impacts that occured during simulation
 * @param	Extent		extent of trace performed
 * @return	first 'real geometry' impact that occured.
 *
 * @note if an impact didn't occur, and impact is still returned, with its HitLocation being the EndTrace value.
 */
simulated function ImpactInfo CalcWeaponFire(vector StartTrace, vector EndTrace, optional out array<ImpactInfo> ImpactList, optional vector Extent)
{
	local vector			HitLocation, HitNormal, Dir;
	local Actor				HitActor;
	local TraceHitInfo		HitInfo;
	local ImpactInfo		CurrentImpact;
	local PortalTeleporter	Portal;
	local float				HitDist;
	local bool				bOldBlockActors, bOldCollideActors;

	// Perform trace to retrieve hit info
	HitActor = Instigator.Trace(HitLocation, HitNormal, EndTrace, StartTrace, TRUE, Extent, HitInfo, TRACEFLAG_Bullet);

	// If we didn't hit anything, then set the HitLocation as being the EndTrace location
	if( HitActor == None )
	{
		HitLocation	= EndTrace;
	}

	// Convert Trace Information to ImpactInfo type.
	CurrentImpact.HitActor		= HitActor;
	CurrentImpact.HitLocation	= HitLocation;
	CurrentImpact.HitNormal		= HitNormal;
	CurrentImpact.RayDir		= Normal(EndTrace-StartTrace);
	CurrentImpact.StartTrace	= StartTrace;
	CurrentImpact.HitInfo		= HitInfo;

	// Add this hit to the ImpactList
	ImpactList[ImpactList.Length] = CurrentImpact;

	// check to see if we've hit a trigger.
	// In this case, we want to add this actor to the list so we can give it damage, and then continue tracing through.
	if( HitActor != None )
	{
		if (PassThroughDamage(HitActor))
		{
			// disable collision temporarily for the actor we can pass-through
			HitActor.bProjTarget = false;
			bOldCollideActors = HitActor.bCollideActors;
			bOldBlockActors = HitActor.bBlockActors;
			if (HitActor.IsA('Pawn'))
			{
				// For pawns, we need to disable bCollideActors as well
				HitActor.SetCollision(false, false);

				// recurse another trace
				CalcWeaponFire(HitLocation, EndTrace, ImpactList, Extent);
			}
			else
			{
				if( bOldBlockActors )
				{
					HitActor.SetCollision(bOldCollideActors, false);
				}
				// recurse another trace and override CurrentImpact
				CurrentImpact = CalcWeaponFire(HitLocation, EndTrace, ImpactList, Extent);
			}

			// and reenable collision for the trigger
			HitActor.bProjTarget = true;
			HitActor.SetCollision(bOldCollideActors, bOldBlockActors);
		}
		else
		{
			// if we hit a PortalTeleporter, recurse through
			Portal = PortalTeleporter(HitActor);
			if( Portal != None && Portal.SisterPortal != None )
			{
				Dir = EndTrace - StartTrace;
				HitDist = VSize(HitLocation - StartTrace);
				// calculate new start and end points on the other side of the portal
				StartTrace = Portal.TransformHitLocation(HitLocation);
				EndTrace = StartTrace + Portal.TransformVectorDir(Normal(Dir) * (VSize(Dir) - HitDist));
				//@note: intentionally ignoring return value so our hit of the portal is used for effects
				//@todo: need to figure out how to replicate that there should be effects on the other side as well
				CalcWeaponFire(StartTrace, EndTrace, ImpactList, Extent);
			}
		}
	}

	return CurrentImpact;
}

/**
  * returns true if should pass trace through this hitactor
  */
simulated function bool PassThroughDamage(Actor HitActor)
{
	//return (!HitActor.bBlockActors && (HitActor.IsA('Trigger') || HitActor.IsA('TriggerVolume')))
	//	|| HitActor.IsA('InteractiveFoliageActor');
	return ( HitActor.IsA('Trigger') || HitActor.IsA('TriggerVolume') || HitActor.IsA('Pawn') ) || HitActor.IsA('InteractiveFoliageActor');
}

/**
 * Performs an 'Instant Hit' shot.
 * Also, sets up replication for remote clients,
 * and processes all the impacts to deal proper damage and play effects.
 *
 * Network: Local Player and Server
 */
simulated function InstantFire()
{
	local vector			StartTrace, EndTrace;
	local Array<ImpactInfo>	ImpactList;
	local int				Idx;
	local vector        lSocketLocation;

	if ( Mesh.GetSocketWorldLocationAndRotation(FireEffectSocket, lSocketLocation) )
	{
		StartTrace = lSocketLocation;
	}
	else
	{
		StartTrace = Instigator.GetWeaponStartTraceLocation();
	}

	// define range to use for CalcWeaponFire()
	EndTrace = StartTrace + Normal(AimLocation-StartTrace) * WeaponRange;

	// Perform shot
	CalcWeaponFire(StartTrace, EndTrace, ImpactList);

	// Process all Instant Hits on local player and server (gives damage, spawns any effects).
	for (Idx = 0; Idx < ImpactList.Length; Idx++)
	{
		ProcessInstantHit(ImpactList[Idx]);
	}
}

/**
 * Processes a successful 'Instant Hit' trace and eventually spawns any effects.
 * Network: LocalPlayer and Server
 * @param Impact: hit information
 * @param NumHits (opt): number of hits to apply using this impact
 * 			this is useful for handling multiple nearby impacts of multihit weapons (e.g. shotguns)
 *			without having to execute the entire damage code path for each one
 *			an omitted or <= 0 value indicates a single hit
 */
simulated function ProcessInstantHit(ImpactInfo Impact, optional int NumHits)
{
	local int TotalDamage;
	local KActorFromStatic NewKActor;
	local StaticMeshComponent HitStaticMesh;

	if (Impact.HitActor != None)
	{
		// default damage model is just hits * base damage
		NumHits = Max(NumHits, 1);
		TotalDamage = Damage * NumHits;

		if ( Impact.HitActor.bWorldGeometry )
		{
			HitStaticMesh = StaticMeshComponent(Impact.HitInfo.HitComponent);
			if ( (HitStaticMesh != None) && HitStaticMesh.CanBecomeDynamic() )
			{
				NewKActor = class'KActorFromStatic'.Static.MakeDynamic(HitStaticMesh);
				if ( NewKActor != None )
				{
					Impact.HitActor = NewKActor;
				}
			}
		}
		Impact.HitActor.TakeDamage( TotalDamage, Instigator.Controller,
						Impact.HitLocation, Impact.RayDir,
						MyDamageType, Impact.HitInfo, self );
	}
}

simulated event bool IsFiring()
{
    return IsInState('WEAPONFIRING');
}

//=============================================================================
// STATES
//=============================================================================
simulated STATE ACTIVE
{
	/** Initialize the weapon as being active and ready to go. */
	simulated function BeginState( Name PreviousStateName )
	{
		super.BeginState(PreviousStateName);
		StopWeaponAnimation();
		PlayWeaponAnimation(WeaponIdleAnim, IdleAnimTime, true);
		bReadyForFire = true;
	}

	simulated function EndState( Name NextStateName )
	{
		super.EndState(NextStateName);
		bReadyForFire = false;
	}
}

simulated STATE WEAPONFIRING
{
	ignores StartFire;

	simulated function BeginState( Name PreviousStateName )
	{
		`log(" STATE WEAPONFIRING BeginState "$self);
	}

Begin:
	`log(" STATE WEAPONFIRING label Begin started.... ");
	StopWeaponAnimation();
	if ( WeaponFireAnim != '' )
	{
		PlayWeaponAnimation( WeaponFireAnim, FireInterval, false);
		Sleep(DelayBeforeFireForAnim);                                  // start fire anim
	}
	FireAmmunition();                                                   // do fire
	if (!bIgnoreFireInterval)
	{
		SleepTime = FireInterval - DelayBeforeFireForAnim;
		if (SleepTime > 0 )	Sleep(FireInterval - DelayBeforeFireForAnim);   // end fire anim
	}
	GoToState('ACTIVE');
}

//=============================================================================
// Weapon Sounds
//=============================================================================
/** Tells the weapon to play a firing sound (uses CurrentFireMode) */
simulated function PlayFiringSound()
{
	if ( WeaponFireSnd != None )
	{
		MakeNoise(1.0);
		WeaponPlaySound( WeaponFireSnd );
	}
}

/** This function handles playing sounds for weapons. */
simulated function WeaponPlaySound(SoundCue Sound, optional float NoiseLoudness)
{
	if( (Sound != None) && (Instigator != None) )
	{
		Instigator.PlaySound(Sound, false, true);
	}
}

//=============================================================================
// Weapon Anims
//=============================================================================
/** Returns the AnimNodeSequence the weapon is using to play animations. */
simulated function AnimNodeSequence GetWeaponAnimNodeSeq()
{
	local AnimTree Tree;
	local AnimNodeSequence AnimSeq;

	if(Mesh != None)
	{
		//Try getting an animtree first
		Tree = AnimTree(Mesh.Animations);
		if (Tree != None)
		{
			AnimSeq = AnimNodeSequence(Tree.Children[0].Anim);
		}
		else
		{
			//Old legacy way without an animtree
			AnimSeq = AnimNodeSequence(Mesh.Animations);
		}

		return AnimSeq;
	}

	return None;
}

/**
 * Play an animation on the weapon mesh
 * Network: Local Player and clients
 *
 * @param	[Sequence] AnimSequence to play on weapon skeletal mesh
 * @param	[fDesiredDuration] duration, in seconds, animation should be played
 */
simulated function PlayWeaponAnimation( Name Sequence, float fDesiredDuration, optional bool bLoop, optional SkeletalMeshComponent SkelMesh)
{
	local AnimNodeSequence WeapNode;

	// do not play on a dedicated server
	if( WorldInfo.NetMode == NM_DedicatedServer )
	{
		return;
	}

	if ( SkelMesh == None )
	{
		SkelMesh = Mesh;
	}

	WeapNode = GetWeaponAnimNodeSeq();

	// Check we have access to mesh and animations
	if( SkelMesh == None ||  WeapNode == None )
	{
		return;
	}

	if(fDesiredDuration > 0.0)
	{
		// @todo - this should call GetWeaponAnimNodeSeq, move 'duration' code into AnimNodeSequence and use that.
		SkelMesh.PlayAnim(Sequence, fDesiredDuration, bLoop, true, 0, false);
	}
	else
	{
		WeapNode.SetAnim(Sequence);
		WeapNode.PlayAnim(bLoop, 1.0f, 0);
	}
}

/**
 * Stops an animation on the weapon mesh */
simulated function StopWeaponAnimation()
{
	local AnimNodeSequence AnimSeq;

	// do not play on a dedicated server
	if( WorldInfo.NetMode == NM_DedicatedServer )
	{
		return;
	}

	AnimSeq = GetWeaponAnimNodeSeq();
	if( AnimSeq != None )
	{
		AnimSeq.StopAnim();
	}
}

//=============================================================================
// Effects
//=============================================================================
/**
 * PlayFireEffects Is the root function that handles all of the effects associated with
 * a weapon.  This function creates the 1st person effects.  It should only be called
 * on a locally controlled player.
 */
simulated function PlayFireEffects()
{
	// Start muzzle flash effect
	CauseMuzzleFlash();
} 

/** StopFireEffects. Main function to stop any active effects */
simulated function StopFireEffects(byte FireModeNum);

//=============================================================================
// Muzzle Flash Methods
//=============================================================================
/** Called on a client, this function Attaches the MuzzleFlashParticleSystemComponent */
function AttachMuzzleFlash()
{
	// Attach the Muzzle Flash
	bMuzzleFlashAttached = true;
	if (  Mesh != none )
	{
	    //if our weapon has at least one muzzle flash
	    //lets attach our muzzle flash particle system component
		if ( MuzzleFlashPSCTemplate!=none)
		{
			MuzzleFlashPSC = new(Outer)class'ParticleSystemComponent';
			MuzzleFlashPSC.bAutoActivate = false;
			//MuzzleFlashPSC.SetDepthPriorityGroup(SDPG_Foreground);
			MuzzleFlashPSC.SetOwnerNoSee(true);
			//MuzzleFlashPSC.SetFOV(UDKSkeletalMeshComponent(SKMesh).FOV);
			if ( FireEffectSocket != '' ) Mesh.AttachComponentToSocket(MuzzleFlashPSC, FireEffectSocket);
			else Mesh.AttachComponentToSocket(MuzzleFlashPSC, AttachedToSocket);
			MuzzleFlashPSC.SetRotation(Instigator.Rotation);
		}
	}
}

/** Causes the muzzle flash to turn on and setup a time to turn it back off again. */
event CauseMuzzleFlash()
{
	local ParticleSystem MuzzleTemplate;

    //Only proceed if our firing mode has a muzzle flash
	if (MuzzleFlashPSCTemplate != none)
	{
		if ( !bMuzzleFlashAttached )
		{
			AttachMuzzleFlash();
		}
		if (!MuzzleFlashPSC.bIsActive || MuzzleFlashPSC.bWasDeactivated)
		{
			MuzzleTemplate = MuzzleFlashPSCTemplate;

			//If our current PSC is using a different muzzle flash particle
			//Lets go ahead and swap it with the one we need
			if (MuzzleTemplate != MuzzleFlashPSC.Template)
			{
				MuzzleFlashPSC.SetTemplate(MuzzleTemplate);
			}
			SetMuzzleFlashParams(MuzzleFlashPSC);
			MuzzleFlashPSC.ActivateSystem();
		}
		// Set when to turn it off.
		SetTimer(MuzzleFlashDuration,false,'MuzzleFlashTimer');
	}
}

/** Turns the MuzzleFlashPSC off */
event MuzzleFlashTimer()
{
	if (MuzzleFlashPSC != none)
	{
		MuzzleFlashPSC.DeactivateSystem();
	}
}

event StopMuzzleFlash()
{
	ClearTimer('MuzzleFlashTimer');
	MuzzleFlashTimer();

	if ( MuzzleFlashPSC != none )
	{
		MuzzleFlashPSC.DeactivateSystem();
	}
}

/** Allows a child to setup custom parameters on the muzzle flash */
function SetMuzzleFlashParams(ParticleSystemComponent PSC)
{
	return;
}

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
	Mesh=SkeletalMeshComponent0

	FireEffectSocket=FireEffect

	WeaponPutDownAnim=WeaponPutDown
	WeaponEquipAnim=WeaponEquip
	WeaponIdleAnim=WeaponIdle
	WeaponFireAnim=WeaponFire

	bIgnoreFireInterval = FALSE

	MyDamageType=class'X_COM_DamageType'

	TickGroup=TG_PreAsyncWork

	bOnlyRelevantToOwner = FALSE // Set true because weapon replication is only relevant for the owning player. Other players don't often need to know the status of other player's weapons.
	bOnlyDirtyReplication = FALSE // Set false as the weapon needs to update everything, changed or not.
	bAlwaysRelevant=true
}
