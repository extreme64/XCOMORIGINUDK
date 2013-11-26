/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class X_COM_Projectile_Grenade extends X_COM_Projectile
	placeable;

/**
 * Set the initial velocity and cook time
 */
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(2.5+FRand()*0.5,false);                  //Grenade begins unarmed
	RandSpin(100000);
}

function Init(vector Direction)
{
	SetRotation(Rotator(Direction));

	Velocity = Speed * Direction;
	TossZ = TossZ + (FRand() * TossZ / 2.0) - (TossZ / 4.0);
	Velocity.Z += TossZ;
	Acceleration = AccelRate * Normal(Velocity);
}

/**
 * Explode
 */
simulated function Timer()
{
	Explode(Location, vect(0,0,1));
}

/**
 * Give a little bounce
 */
simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	bBlockedByInstigator = true;

	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		PlaySound(ImpactSound, true);
	}

	// check to make sure we didn't hit a pawn

	if ( Pawn(Wall) == none )
	{
		Velocity = 0.75*(( Velocity dot HitNormal ) * HitNormal * -2.0 + Velocity);   // Reflect off Wall w/damping
		Speed = VSize(Velocity);

		if (Velocity.Z > 400)
		{
			Velocity.Z = 0.5 * (400 + Velocity.Z);
		}
		// If we hit a pawn or we are moving too slowly, explod

		if ( Speed < 20 || Pawn(Wall) != none )
		{
			ImpactedActor = Wall;
			SetPhysics(PHYS_None);
		}
	}
	else if ( Wall != Instigator ) 	// Hit a different pawn, just explode
	{
		Explode(Location, HitNormal);
	}
}

/**
 * When a grenade enters the water, kill effects/velocity and let it sink
 */
simulated function PhysicsVolumeChange( PhysicsVolume NewVolume )
{
	if ( WaterVolume(NewVolume) != none )
	{
		Velocity *= 0.25;
	}

	Super.PhysicsVolumeChange(NewVolume);
}


defaultproperties
{
}