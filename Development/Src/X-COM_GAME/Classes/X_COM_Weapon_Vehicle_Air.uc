/**
 * X-COM Vehicle weapon class.
 */
class X_COM_Weapon_Vehicle_Air extends X_COM_Weapon_Vehicle
	placeable;


simulated public function bool ActivateItem(optional name aSocketName)
{
	local X_COM_Vehicle_AirVehicle lVehicle;

	if (super.ActivateItem(aSocketName))
	{
		lVehicle = X_COM_Vehicle_AirVehicle(Instigator);
		if (lVehicle != none)
		{
			switch(aSocketName)
			{
				case 'Weapon_L': lVehicle.WeaponGuns.AddItem(self);
				break;
				case 'Weapon_R': lVehicle.WeaponGuns.AddItem(self);
				break;
				case 'Rocket_L': lVehicle.WeaponRockets.AddItem(self);
				break;
				case 'Rocket_R': lVehicle.WeaponRockets.AddItem(self);
				break;
				case 'Special': lVehicle.WeaponSpecials.AddItem(self);
				break;
			}
		}
		return true;
	}
	return false;
}

simulated function Projectile ProjectileFire()
{
	local Projectile    SpawnedProjectile;

	SpawnedProjectile = super.ProjectileFire();

  	if ((SpawnedProjectile != None) && (!SpawnedProjectile.bDeleteMe) && (X_COM_Projectile_Air(SpawnedProjectile)!= none) )
  	{
		X_COM_Projectile_Air(SpawnedProjectile).SetTarget(Instigator.Controller.Enemy);
  	}
}

//simulated STATE WEAPONFIRING
//{


//Begin:
//	FireAmmunition();                                                   // do fire
//	Sleep(FireInterval - DelayBeforeFireForAnim);                       // end fire anim
//	GoToState('ACTIVE');
//}

//simulated event ReceivedNewEvent(SequenceEvent Evt)
//{
//	super.ReceivedNewEvent(Evt);
//	if ( (X_COM_SeqEvent_GlobalEvent(EVT) != none) && (X_COM_SeqEvent_GlobalEvent(EVT).GlobalEventName == EGE_TimeSync) ) SyncGlobalTime();
//}

//protected function SyncGlobalTime()
//{
//	`log(" SyncGlobalTime called in "$self);
//}

DefaultProperties
{
	FireType = EWFT_Projectile
}
