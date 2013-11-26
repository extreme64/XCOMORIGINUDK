class xcT_AICommand_Cmd_Crouch extends xcT_AICommand_Cmd;

//=============================================================================
// State
//=============================================================================
AUTO state Crouch
{
	function CrouchOrStandUpWithTU()
	{
		local int lTUremain;
		local int lTUperCrouching;
		
		if(Pawn != None)
		{	
			if (X_COM_Vehicle(Pawn) != none) return;

			lTUremain = X_COM_Pawn(Pawn).TimeUnitsRemain;
			if (X_COM_Pawn(Pawn).Position == EP_Sitting)
			{			
				lTUperCrouching = class'xcT_Defines'.const.TUperStandUp;
				if (lTUremain < lTUperCrouching ) 
				{
					StopLatentExecution();
				}
				else
				{
					Pawn.ShouldCrouch(false);
					Pawn.GroundSpeed = Pawn.Default.GroundSpeed;
					X_COM_Pawn(Pawn).TimeUnitsRemain = lTUremain - lTUperCrouching;
					X_COM_Pawn(Pawn).Position = EP_Standing;
				}
			}
			else
			{
				if (X_COM_Pawn(Pawn).Position == EP_Standing)
				{
					lTUperCrouching = class'xcT_Defines'.const.TUperCrouch;
					if (lTUremain < lTUperCrouching ) 
					{
						StopLatentExecution();
					}
					else
					{
						Pawn.ShouldCrouch(true);
						Pawn.GroundSpeed = Pawn.Default.GroundSpeed / 2;
						X_COM_Pawn(Pawn).TimeUnitsRemain = lTUremain - lTUperCrouching;
						X_COM_Pawn(Pawn).Position = EP_Sitting;
					}
				}
			}
		}
	}

Begin:
	//`log("xT_AICommand_Crouch executed");

Crouching:
	CrouchOrStandUpWithTU();
	sleep(WorldInfo.DeltaSeconds); // Little delay while wait for crouching or standing

Ending:
	PopCommand(Self);
}

//=============================================================================
// DefaultProperties
//=============================================================================
defaultproperties
{
}
