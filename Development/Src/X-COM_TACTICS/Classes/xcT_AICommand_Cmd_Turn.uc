class xcT_AICommand_Cmd_Turn extends xcT_AICommand_Cmd;

event PrePushed(GameAIController AI)
{
	if (xcT_AIController(Outer).bSetTurnAsAction) super.PrePushed(AI);
}

event PostPopped()
{
	if (xcT_AIController(Outer).bSetTurnAsAction)  super.PostPopped();
	xcT_AIController(Outer).bSetTurnAsAction = false;
}

//=============================================================================
// State
//=============================================================================
AUTO state Turn
{
	function StartTurnPawnWithTU()
	{
		local int lTUremain;
		local int lTUperTurn;
		local int lNewTUperTurn;
		local float lRotationAngle;
		local Rotator lNewPawnRotation;
		local Rotator lOldPawnRotation;
		
		if(Pawn != None)
		{	
			lTUremain = X_COM_Unit(Pawn).TimeUnitsRemain;
			lTUperTurn = class'xcT_Defines'.const.TUperTurn;
			if (lTUremain < lTUperTurn ) 
			{
				StopLatentExecution();
			}
			else
			{
				lNewPawnRotation = Rotator(X_COM_AIController(Outer).NewDestination-Pawn.Location); lNewPawnRotation.Pitch = 0; lNewPawnRotation.Roll = 0;
				lOldPawnRotation = Pawn.Rotation; lOldPawnRotation.Pitch = 0; lOldPawnRotation.Roll = 0; // Save old rotation
				lRotationAngle = Abs(RDiff(lNewPawnRotation, lOldPawnRotation));
				if ((lRotationAngle > 0) && (lRotationAngle < 90)) lNewTUperTurn = lTUperTurn;
					else
						if ((lRotationAngle > 90) && (lRotationAngle < 180)) lNewTUperTurn = 2*lTUperTurn;
							else
								if ((lRotationAngle > 180) && (lRotationAngle < 270)) lNewTUperTurn = 3*lTUperTurn;
									else
										if ((lRotationAngle > 270) && (lRotationAngle < 360)) lNewTUperTurn = 4*lTUperTurn;
				if (lTUremain < lNewTUperTurn ) 
				{
					StopLatentExecution();
				}
				else
				{
					X_COM_Unit(Pawn).TimeUnitsRemain = lTUremain - lNewTUperTurn;
					SetFocalPoint(X_COM_AIController(Outer).NewDestination); // First turn to target location		
				}
			}
		}
	}

Begin:
	//`log("xT_AICommand_Turn executed");
	if (IsZero(X_COM_AIController(Outer).NewDestination))
	{
		Sleep(WorldInfo.DeltaSeconds);
		Goto('Ending');
	}

Turning:
	StartTurnPawnWithTU();
	FinishRotation(); // Wait while turning

Ending:
	PopCommand(Self);
}

//=============================================================================
// DefaultProperties
//=============================================================================
defaultproperties
{
}
