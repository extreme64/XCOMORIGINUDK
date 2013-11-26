class X_COM_Weapon_Pawn_Beam extends X_COM_Weapon_Pawn
	hidecategories(XCOM_Weapon_Projectile)
	placeable;

var(XCOM_Weapon) const bool bCanHitMultiTargets;

var protected vector ImpactLocation; // location where impact after atack should be

simulated function PlayFireEffects()
{
	super.PlayFireEffects();
	MuzzleFlashPSC.SetVectorParameter('ShockBeamEnd', ImpactLocation);	
}

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
	EndTrace = StartTrace + Normal(GetAimPoint() - StartTrace) * WeaponRange;

	// Perform shot
	CalcWeaponFire(StartTrace, EndTrace, ImpactList);

	// Process all Instant Hits on local player and server (gives damage, spawns any effects).
	if (ImpactList.Length >0)
	{
		if (bCanHitMultiTargets)
		{
			for (Idx = 0; Idx < ImpactList.Length; Idx++)
			{
				ProcessInstantHit(ImpactList[Idx]); //process all targets in list
			}
			ImpactLocation = ImpactList[ImpactList.Length-1].HitLocation;
		}
		else
		{
			ProcessInstantHit(ImpactList[0]); // process only 1st taret in list
			ImpactLocation = ImpactList[0].HitLocation;
		}
	}
}

/**
  * returns true if should pass trace through this hitactor
  */
simulated function bool PassThroughDamage(Actor HitActor)
{
	local bool bRes;
	bRes = super.PassThroughDamage(HitActor);
	return ( (!HitActor.bBlockActors || bCanHitMultiTargets) && bRes);
}

DefaultProperties
{
	WeaponRange = 10000

	FireType = EWFT_InstantHit

	MuzzleFlashPSCTemplate=none
	MuzzleFlashDuration=0;
}