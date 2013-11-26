/**
 * X-COM Vehicle weapon class.
 */
class X_COM_Weapon_Vehicle extends X_COM_Weapon
	abstract
	notplaceable
	dependson(X_COM_Vehicle);

///** Holds a link to the parent vehicle */
//var RepNotify X_COM_Vehicle	MyVehicle;

///** impact effects by material type */
//var array<MaterialImpactEffect> ImpactEffects, AltImpactEffects;

///** default impact effect to use if a material specific one isn't found */
//var MaterialImpactEffect DefaultImpactEffect, DefaultAltImpactEffect;

//simulated function PostBeginplay()
//{
//	super.PostBeginplay();
//	MyVehicle = X_COM_Vehicle(Instigator);
//}

///** GetDesiredAimPoint - Returns the desired aim given the current controller
// * @param TargetActor (out) - if specified, set to the actor being aimed at
// * @return The location the controller is aiming at
// */
//simulated event vector GetDesiredAimPoint(optional out Actor TargetActor)
//{
//	local vector DesiredAimPoint;
//	local Controller C;

//	C = MyVehicle.Controller;

//	if ( C != None )
//	{
//		DesiredAimPoint = C.GetFocalPoint();
//		TargetActor = C.Focus;
//	}
//	return DesiredAimPoint;
//}

///** returns the location and rotation that the weapon's fire starts at */
//simulated function GetFireStartLocationAndRotation(out vector StartLocation, out rotator StartRotation)
//{
//	if ( MyVehicle == None )
//	{
//		return;
//	}

//	MyVehicle.Mesh.GetSocketWorldLocationAndRotation(MyVehicle.GunFiredSocketName, StartLocation, StartRotation);
	
//	if ((StartLocation == Vect(0,0,0)) || (StartRotation == Rot(0,0,0)))
//	{
//		StartLocation = MyVehicle.Location;
//		StartRotation = MyVehicle.Rotation;
//	}
//}

///** returns the impact effect that should be used for hits on the given actor and physical material */
//simulated static function MaterialImpactEffect GetImpactEffect(Actor HitActor, PhysicalMaterial HitMaterial, byte FireModeNum)
//{
//	local int i;
//	local X_COM_PhysicalMaterialProperty PhysicalProperty;

//	if (HitMaterial != None)
//	{
//		PhysicalProperty = X_COM_PhysicalMaterialProperty(HitMaterial.GetPhysicalMaterialProperty(class'X_COM_PhysicalMaterialProperty'));
//	}
//	if (FireModeNum > 0)
//	{
//		if (PhysicalProperty != None && PhysicalProperty.MaterialType != 'None')
//		{
//			i = default.AltImpactEffects.Find('MaterialType', PhysicalProperty.MaterialType);
//			if (i != -1)
//			{
//				return default.AltImpactEffects[i];
//			}

//		}
//		return default.DefaultAltImpactEffect;
//	}
//	else
//	{
//		if (PhysicalProperty != None && PhysicalProperty.MaterialType != 'None')
//		{
//			i = default.ImpactEffects.Find('MaterialType', PhysicalProperty.MaterialType);
//			if (i != -1)
//			{
//				return default.ImpactEffects[i];
//			}
//		}
//		return default.DefaultImpactEffect;
//	}
//}

simulated function Projectile ProjectileFire()
{
	local Rotator       ProjectileStartrot;
	local vector        ProjectileStartLoc;
	local Projectile    SpawnedProjectile;
	local vector        ProjectileDirection;
	local X_COM_Vehicle	lVehicle;
	local vector	    lFireAtLocation; //PC.FireLocation value
	
    lVehicle = X_COM_Vehicle(Instigator);

    if( Role == ROLE_Authority )
    {
		ProjectileStartrot = lVehicle.rotation;
		ProjectileStartLoc = Location;

		lFireAtLocation = AimLocation;

		ProjectileDirection = lFireAtLocation - ProjectileStartLoc;

		SpawnedProjectile = Spawn(ProjectileTemplate.Class, self, , ProjectileStartLoc, ProjectileStartrot, ProjectileTemplate, true);

  		if ((SpawnedProjectile != None) && (!SpawnedProjectile.bDeleteMe))
  		{
			X_COM_Projectile(SpawnedProjectile).SetDamageParams(Damage, MyDamageType);
  			SpawnedProjectile.Init(normal(ProjectileDirection) );   //this is where you decide the projectile's direction of travel
  		}

  		return SpawnedProjectile;
     }
     return None;
}



defaultproperties
{

}
