class xcT_AICommand_Cmd_AttackLocation extends xcT_AICommand_Cmd;

//=============================================================================
// Variables: Firing
//=============================================================================
var int                         FireCounter; //Counter for burst fire times
var vector                      FireLocation; // Location where pawn will firing
var bool                        bShouldAttachToCamera; //Attaching camera when pawn fires
var int                         TURequired;
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
	}
}

//=============================================================================
// State
//=============================================================================
AUTO state AttackEnemy
{
	event PushedState()
	{
		if ( (xcT_GameInfo(worldinfo.game).bCameraShouldFollowForProjectile)  && ((Pawn.isA('X_COM_Pawn_Human')) || (Pawn.isA('X_COM_Vehicle_Human'))) )
			if (!(xcT_PlayerController(xcT_GameInfo(Worldinfo.Game).GetPlayerController()).IsInState('FiringState'))) 
				xcT_PlayerController(xcT_GameInfo(Worldinfo.Game).GetPlayerController()).GotoState('FiringState');
	}

	event PoppedState()
	{	
		if ( (xcT_GameInfo(worldinfo.game).bCameraShouldFollowForProjectile)  && ((Pawn.isA('X_COM_Pawn_Human')) || (Pawn.isA('X_COM_Vehicle_Human'))) )
			if (!(xcT_PlayerController(xcT_GameInfo(Worldinfo.Game).GetPlayerController()).IsInState('TacticsControllerState'))) 
				xcT_PlayerController(xcT_GameInfo(Worldinfo.Game).GetPlayerController()).GotoState('TacticsControllerState');
	}

	function bool CheckEnoughtTUs(int aTUperFire)
	{
		local int lTU;
		local int lTUremain;
		
		lTU = X_COM_Unit(Pawn).TimeUnits;
		lTUremain = X_COM_Unit(Pawn).TimeUnitsRemain;
		//TURequired = 1;//(lTU * aTUperFire)/100;

		if (lTUremain < TURequired ) 
		{
			StopLatentExecution();
			return false;
		}
		else return true;
	}

	function FiringWithTU(int aTUperFire)
	{
		local int lTU;
		local int lTUremain;
		local int TURequired;
		
		lTU = X_COM_Unit(Pawn).TimeUnits;
		lTUremain = X_COM_Unit(Pawn).TimeUnitsRemain;
		//TURequired = (lTU * aTUperFire)/100;

		X_COM_Unit(Pawn).TimeUnitsRemain = lTUremain - TURequired;
	}

	event Tick(float DeltaTime)
	{
		local X_COM_Unit xcT_Unit;

		super.Tick(DeltaTime);	
		if (Pawn.IsA('X_COM_Pawn_Human'))
		{
			if (xcT_GameInfo(worldinfo.game).bCameraShouldFollowForProjectile && bShouldAttachToCamera) 
			{
				xcT_Unit = X_COM_Unit(Pawn);
				if (xcT_Unit.Fired_Projectile != none) xcT_PlayerController(xcT_GameInfo(Worldinfo.Game).GetPlayerController()).AttachCameraTo(xcT_Unit.Fired_Projectile);
			}
		}
	}

Begin:
	//`log("xT_AICommand_AttackLocation executed");

Attacking:
	`log(" "$self$" "$String(Role)$" Attacking: 1");

	if ((Pawn != None) && (X_COM_Unit(Pawn).ActiveWeapon != none) )
	{	
		if (pawn.NeedToTurn(X_COM_AIController(Outer).AttackLocation))
		{
			xcT_AIController(Outer).TurnToPosition(X_COM_AIController(Outer).AttackLocation, true, false);
		}
		`log(" "$self$" "$String(Role)$" Attacking: 2");
		`log(" "$self$" "$String(Role)$" FireMode="$X_COM_Unit(Pawn).ActiveWeapon.FireMode);
		switch(X_COM_Unit(Pawn).ActiveWeapon.FireMode) 
		{
			case EFM_Sniper  :   if (CheckEnoughtTUs(class'xcT_Defines'.const.TUperFire_Aimed))
								{
									FiringWithTU(class'xcT_Defines'.const.TUperFire_Aimed);									
									X_COM_Unit(Pawn).ProcessFire(X_COM_AIController(Outer).AttackLocation);

									if ( (X_COM_Unit(Pawn).ActiveWeapon.FireType == EWFT_Projectile) && (X_COM_Unit(Pawn).Fired_Projectile != none) )
									{
										bShouldAttachToCamera = true;
										while (!(X_COM_Unit(Pawn).Fired_Projectile.bDeleteMe)) sleep(WorldInfo.DeltaSeconds);
										bShouldAttachToCamera = false;
										X_COM_Unit(Pawn).Fired_Projectile = none;
									}
								}
								else break;
			break;
			case EFM_Burst  :   `log(" "$self$" "$String(Role)$" Attacking: 3"); 
								if (CheckEnoughtTUs(class'xcT_Defines'.const.TUperFire_Burst * 3))
								{
									for (FireCounter=0; FireCounter<3; ++FireCounter)
									{
										FiringWithTU(class'xcT_Defines'.const.TUperFire_Burst);
										X_COM_Unit(Pawn).ProcessFire(X_COM_AIController(Outer).AttackLocation);
										if ( (X_COM_Unit(Pawn).ActiveWeapon.FireType == EWFT_Projectile) && (X_COM_Unit(Pawn).Fired_Projectile != none) )
										{
											bShouldAttachToCamera = true;
											while (!(X_COM_Unit(Pawn).Fired_Projectile.bDeleteMe)) sleep(0.1);
											bShouldAttachToCamera = false;
											X_COM_Unit(Pawn).Fired_Projectile = none;									
										}
										if (FireCounter<2) while (!(X_COM_Unit(Pawn).ActiveWeapon.bReadyForFire)) sleep(0.1); //delay before new shot for 1st and 2nd shots
									}
								}
								else break;
			break;
			case EFM_Snap  :   if (CheckEnoughtTUs(class'xcT_Defines'.const.TUperFire_Quick))
								{
									FiringWithTU(class'xcT_Defines'.const.TUperFire_Quick);									
									X_COM_Unit(Pawn).ProcessFire(X_COM_AIController(Outer).AttackLocation);
									if ( (X_COM_Unit(Pawn).ActiveWeapon.FireType == EWFT_Projectile) && (X_COM_Unit(Pawn).Fired_Projectile != none) )
									{
										bShouldAttachToCamera = true;
										while (!(X_COM_Unit(Pawn).Fired_Projectile.bDeleteMe)) sleep(WorldInfo.DeltaSeconds);
										bShouldAttachToCamera = false;
										X_COM_Unit(Pawn).Fired_Projectile = none;
									}
								}
								else break;
			break;
			//case EFM_Throw  :    if (CheckEnoughtTUs(class'xcT_Defines'.const.TUperFire_Throw))
			//					{
			//						FiringWithTU(class'xcT_Defines'.const.TUperFire_Throw);									
			//						Pawn.StartFire(0);
			//						if ((X_COM_Unit(Pawn).Fired_Projectile != none))// && (instigator.isA('xcT_Pawn_XCOM')))
			//						{
			//							bShouldAttachToCamera = true;
			//							while (!(X_COM_Unit(Pawn).Fired_Projectile.bDeleteMe)) sleep(WorldInfo.DeltaSeconds);
			//							bShouldAttachToCamera = false;
			//							X_COM_Unit(Pawn).Fired_Projectile = none;
			//						}
			//					} 
			//					else break;
			//break;
		}
		sleep(0.5); //delay before camera goes from attacked location to pawn location 
		if ( xcT_GameInfo(worldinfo.game).bCameraShouldFollowForProjectile && ( (Pawn.isA('X_COM_Pawn_Human')) || (Pawn.isA('X_COM_Vehicle_Human')) ) ) xcT_PlayerController(xcT_GameInfo(Worldinfo.Game).GetPlayerController()).AttachCameraTo(Pawn);
	}	

End:
	PopCommand(Self);
}

//=============================================================================
// DefaultProperties
//=============================================================================
defaultproperties
{
	TURequired=1
}
