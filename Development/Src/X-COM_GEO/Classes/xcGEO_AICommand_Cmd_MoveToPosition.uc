class xcGEO_AICommand_Cmd_MoveToPosition extends xcGEO_AICommand_Cmd_Move;


//=============================================================================
// State
//=============================================================================
AUTO state MoveToPosition
{
	function SetMoveDestination()
	{
		if(Pawn != None)
		{						
			UpdateDestination();
		}
		else PopState();
	}

begin:	
	SetMoveDestination();

moving:
	ProcessMovementStep(WorldInfo.DeltaSeconds);
	Sleep(WorldInfo.DeltaSeconds);
	if (!DestinationIsReached) goto('moving');

Ending:
	PopCommand(Self);
}

//=============================================================================
// DefaultProperties
//=============================================================================
defaultproperties
{
}
