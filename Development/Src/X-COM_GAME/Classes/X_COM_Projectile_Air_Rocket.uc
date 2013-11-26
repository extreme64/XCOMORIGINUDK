class X_COM_Projectile_Air_Rocket extends X_COM_Projectile_Air
	placeable;

simulated function Landed(vector HitNormal, Actor FloorActor)
{
	Explode(Location, HitNormal);
}

simulated function ProcessTouch(Actor Other, vector HitLocation, vector HitNormal)
{
	if (Other != Instigator)
	{
		Explode(HitLocation, vect(0,0,0));
	}
}

defaultproperties
{
}
