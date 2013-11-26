class X_COM_DamageType_Explosion extends X_COM_DamageType;

static function float GetHitEffectDuration(Pawn P, float Damage)
{
	return (P.Health <= 0) ? 5.0 : 5.0 * FClamp(Damage * 0.01, 0.5, 1.0);
}

/** SpawnHitEffect()
 * Possibly spawn a custom hit effect
 */
static function SpawnHitEffect(Pawn P, float Damage, vector Momentum, name BoneName, vector HitLocation)
{
	local X_COM_Emitter BF;

	if ( Vehicle(P) != None )
	{
		BF = P.spawn(class'X_COM_Emitter',P,, HitLocation, rotator(Momentum));
		BF.AttachTo(P, BoneName); 
	}
	else
	{
		Super.SpawnHitEffect(P, Damage, Momentum, BoneName, HitLocation);
	}
}

defaultproperties
{
	TypeOfDamage = EDT_Thermal;

	KDamageImpulse=1000
	KDeathUpKick=200
	VehicleMomentumScaling=4.0
	VehicleDamageScaling=0.8
	bThrowRagdoll=true
}
