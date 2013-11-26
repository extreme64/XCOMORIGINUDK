class xcGEO_AICommand_Cmd_AttackEnemy extends xcGEO_AICommand_Cmd;

//=============================================================================
// Variables for time firing
//=============================================================================
var float LastFiredTime_Guns;
var float LastFiredTime_Rockets;
var float LastFiredTime_Specials;

//=============================================================================
// Events
//=============================================================================
function PostPopped()
{
	super.PostPopped();
	StopLatentExecution();
	if (Pawn != none)
	{
		Pawn.ZeroMovementVariables();
		Pawn.StopFire(0);
		if (X_COM_AIController(Outer).Enemy.Health <= 0) Reaction_EnemyLost(X_COM_Unit(X_COM_AIController(Outer).Enemy));
	}
}

//=============================================================================
// State
//=============================================================================
AUTO state AttackEnemy
{
	function vector GetSightDistanceDifference()
	{
		local vector lshotpoint;
		lshotpoint = Pawn.Location + normal(X_COM_AIController(Outer).Enemy.Location - Pawn.Location) * ( abs(Vsize(X_COM_Unit(X_COM_AIController(Outer).Enemy).Location - Pawn.Location) - Pawn.SightRadius + (Pawn.SightRadius * 0.1)));
		lshotpoint.Z = Pawn.Location.Z;
		return lshotpoint;
	}

	function vector GetEnemyDistanceDifference()
	{
		local vector lshotpoint;
		lshotpoint = Pawn.Location + normal(X_COM_AIController(Outer).Enemy.Location - Pawn.Location) * ( abs(Vsize(X_COM_Unit(X_COM_AIController(Outer).Enemy).Location - Pawn.Location) - Pawn.Weapon.WeaponRange + (Pawn.Weapon.WeaponRange * 0.1)));
		lshotpoint.Z = Pawn.Location.Z;
		return lshotpoint;
	}

	function bool CanFireGuns()
	{
		local float lTimeToRefire, lNewAttackTime;

		if (X_COM_Vehicle_AirVehicle(Pawn).WeaponGuns.Length <= 0) return false;
		if (xcGEO_Gameinfo(Worldinfo.game).GetGameSpeed() == 0.0) return false;

		lTimeToRefire = (X_COM_Vehicle_AirVehicle(Pawn).WeaponGuns[0].FireInterval)/(xcGEO_Gameinfo(Worldinfo.game).GetGameSpeed());
		lNewAttackTime = Worldinfo.TimeSeconds - LastFiredTime_Guns; 
		if (lNewAttackTime > lTimeToRefire) return true;
		else return false;
	}

	function bool CanFireRockets()
	{
		local float lTimeToRefire, lNewAttackTime;

		if (X_COM_Vehicle_AirVehicle(Pawn).WeaponRockets.Length <= 0) return false;
		if (xcGEO_Gameinfo(Worldinfo.game).GetGameSpeed() == 0.0) return false;

		lTimeToRefire = (X_COM_Vehicle_AirVehicle(Pawn).WeaponRockets[0].FireInterval)/(xcGEO_Gameinfo(Worldinfo.game).GetGameSpeed());
		lNewAttackTime = Worldinfo.TimeSeconds - LastFiredTime_Rockets; 
		if (lNewAttackTime > lTimeToRefire) return true;
		else return false;
	}

	function bool CanFireSpecials()
	{
		local float lTimeToRefire, lNewAttackTime;

		if (X_COM_Vehicle_AirVehicle(Pawn).WeaponSpecials.Length <= 0) return false;
		if (xcGEO_Gameinfo(Worldinfo.game).GetGameSpeed() == 0.0) return false;

		lTimeToRefire = (X_COM_Vehicle_AirVehicle(Pawn).WeaponSpecials[0].FireInterval)/(xcGEO_Gameinfo(Worldinfo.game).GetGameSpeed());
		lNewAttackTime = Worldinfo.TimeSeconds - LastFiredTime_Specials; 
		if (lNewAttackTime > lTimeToRefire) return true;
		else return false;
	}

Begin:
	//`log("xT_AICommand_Attack executed");

Attacking:
	if ( (Pawn != None) && (X_COM_AIController(Outer).Enemy != None) )
	{	
		// try to see enemy if behind
		if (pawn.NeedToTurn(X_COM_AIController(Outer).Enemy.Location))
		{
			SetFocalPoint(X_COM_AIController(Outer).Enemy.Location); // фокус на цель
			// TODO: Вызвать комманду поворота
		}

		// HUMAN ORDER: try to see enemy in turned place. Note: Aliens not uses it
		//if (Pawn.GetTeamNum() != ET_ALIEN)
		//{
		//	if (!CanSee(X_COM_Unit(X_COM_AIController(Outer).Enemy)))
		//	{
		//		// if enemy is out of sight radius then go closer to enemy
		//		if (Vsize(Pawn.Location - X_COM_Unit(X_COM_AIController(Outer).Enemy).Location) > Pawn.SightRadius)
		//		{
		//			xcGeo_AIController(Outer).MoveToPosition(GetSightDistanceDifference(), false, true);
		//		}
		//	}
		//}

		while(true && (X_COM_AIController(Outer).Enemy.Health > 0) && (CanSee(X_COM_AIController(Outer).Enemy)) && (!X_COM_Unit(X_COM_AIController(Outer).Enemy).bFeigningDeath))
		{  
			//turn to enemy
			if (pawn.NeedToTurn(X_COM_AIController(Outer).Enemy.Location))
			{
				SetFocalPoint(X_COM_AIController(Outer).Enemy.Location);
				// TODO: Вызвать комманду поворота
			}


			if (CanFireGuns())
			{
				LastFiredTime_Guns = Worldinfo.TimeSeconds;
				X_COM_Vehicle_AirVehicle(Pawn).ProcessFireGuns(Enemy.Location);
			}

			if (CanFireRockets())
			{
				LastFiredTime_Rockets = Worldinfo.TimeSeconds;
				X_COM_Vehicle_AirVehicle(Pawn).ProcessFireRockets(Enemy.Location);
			}

			if (CanFireSpecials())
			{
				LastFiredTime_Specials = Worldinfo.TimeSeconds;
				X_COM_Vehicle_AirVehicle(Pawn).ProcessFireSpecials(Enemy.Location);
			}

			//Sleep(Pawn.Weapon.GetFireInterval(0)/xcGEO_Gameinfo(Worldinfo.game).mTimeSpeed);
			//Sleep(5/xcGEO_Gameinfo(Worldinfo.game).mTimeSpeed);
			sleep(WorldInfo.DeltaSeconds); // Тут нужна всего лишь небольшая задержка, после которой снова пойдут все проверки и ProcessFire(Enemy.Location); будет выполнен. Но выстрела не произойдет если ещё не истекло время ожидания для повторного выстрела у оружия

			//// if distance > weapon range then chase target
			//if ((X_COM_AIController(Outer).Enemy != None) && (pawn != none) && (Vsize(Pawn.Location - X_COM_AIController(Outer).Enemy.Location) > Pawn.Weapon.WeaponRange)) // тут нужно взять все оружия и получить максимальный рендж
			//{
			//	goto('Attacking');
			//}
		}

		if (X_COM_AIController(Outer).Enemy.Health <= 0) X_COM_AIController(Outer).UnRegisterEnemy((X_COM_Unit(X_COM_AIController(Outer).Enemy)));
	}

End:
	PopCommand(Self);
}

//=============================================================================
// DefaultProperties
//=============================================================================
defaultproperties
{
}
