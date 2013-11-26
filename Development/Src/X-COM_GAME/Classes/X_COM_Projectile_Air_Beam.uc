/**
 * Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
 */

class X_COM_Projectile_Air_Beam extends X_COM_Projectile_Air
	placeable;

simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal)
{
	local vector x;
	if ( WorldInfo.NetMode != NM_DedicatedServer && EffectIsRelevant(Location,false,MaxEffectDistance) )
	{
		x = normal(Velocity cross HitNormal);
		x = normal(HitNormal cross x);

		WorldInfo.MyEmitterPool.SpawnEmitter(ProjExplosionTemplate, HitLocation, rotator(x));
		bSuppressExplosionFX = true;
	}

	if (ExplosionSound!=None)
	{
		PlaySound(ExplosionSound);
	}
}


defaultproperties
{
}
