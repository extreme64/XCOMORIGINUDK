/**
 * X-COM Vehicle weapon class.
 */
class X_COM_Weapon_Pawn extends X_COM_Weapon
	abstract
	dependson(X_COM_Pawn);


protected function vector GetAimPoint()
{
	local float         AimAccuracy;
	local vector		AimedFireLocation;

	AimAccuracy = GetAccuracy();
	
	//AimedFireLocation = FireAtLocation + Vector((RotRand(true) * (1 - GetAccuracy()))*VRand()*;
	//AimedFireLocation = FireAtLocation + (Vsize(FireAtLocation-Location) * VRandCone(FireAtLocation-Location, 0.5) * (1 - GetAccuracy())); 
	AimedFireLocation = AimLocation + (Vsize(AimLocation-Location) * VRandCone(((AimLocation-Location)*(1-AimAccuracy)), (1-AimAccuracy) * PI/2) * (1 - AimAccuracy)); //best result but need to correct cone angle!
	//`log(" FireAtLocation : "$FireAtLocation);
	//`log(" AimedFireLocation : "$AimedFireLocation);

	return AimedFireLocation;
}

protected function float GetAccuracy() 
{
	local float         lAccuracy;
	local X_COM_Pawn	P;
	local float         lPawnAccuracy;
	local float         lPositionAccuracyBonus;
	local float         lWeaponAccuracy;
	local float         lWoundsPenalty;

	/*
	% Chance to Hit = a * b * c * d * e * f, where 
	a = % Accuracy Stat of soldier 
	b = % Accuracy of weapon/shot 
	c = Kneeling bonus (115% if kneeling, 100% if standing) 
	d = One-handed penalty (80% if firing a two-handed weapon without a free hand, 100% otherwise) 
	e = Wounds penalty (% Health remaining) 
	f = Critical wounds penalty (100% - (10% for each critical wound to head or arms, up to 90%))
	*/
	P = X_COM_Pawn(Instigator);
	
	switch (WeaponType)
	{
		case	EWT_Riffle	:	lPawnAccuracy = P.FiringAccuracy/100.;
		break;
		case	EWT_Grenade	:	lPawnAccuracy = P.ThrowingAccuracy/100.;
		break;
		case	EWT_Melee  :	lPawnAccuracy = P.HitAccuracy/100.;
		break;
	}

	switch (FireMode)
	{
		case	EFM_Sniper  :	lWeaponAccuracy = ((Abs(WeaponConvenience-WeaponRecoil) + WeaponConvenience) * A_Aimed)/100.;
		break;
		case	EFM_Burst  :	lWeaponAccuracy = ((Abs(WeaponConvenience-WeaponRecoil) + WeaponConvenience) * A_Burst)/100.;
		break;
		case	EFM_Snap  :	lWeaponAccuracy = ((Abs(WeaponConvenience-WeaponRecoil) + WeaponConvenience) * A_Quick)/100.;
		break;
	}

	switch (P.Position)
	{
		case EP_Standing	:   lPositionAccuracyBonus = 1.00;
		break;
		case EP_Sitting	    :   if (WeaponType == EWT_Riffle) lPositionAccuracyBonus = 1.15;
									else lPositionAccuracyBonus = 0.80; //if grenade or stun-pod
		break;
	}	

	lWoundsPenalty = ((P.HealthUnitsRemain*100.)/P.HealthUnits)/100.;

	lAccuracy = (lPawnAccuracy * lWeaponAccuracy * lPositionAccuracyBonus * lWoundsPenalty);
	if (lAccuracy > 100.0) lAccuracy = 100.0;
	//`log(" lAccuracy : "$lAccuracy);
	//`log(" lPawnAccuracy : "$lPawnAccuracy$" lWeaponAccuracy : "$lWeaponAccuracy$" lPositionAccuracyBonus : "$lPositionAccuracyBonus$" lWoundsPenalty : "$lWoundsPenalty);
	return lAccuracy;
}

DefaultProperties
{

}