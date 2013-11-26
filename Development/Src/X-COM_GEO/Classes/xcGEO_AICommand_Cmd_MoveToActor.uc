class xcGEO_AICommand_Cmd_MoveToActor extends xcGEO_AICommand_Cmd_Move;

//=============================================================================
// Variables: Movement
//=============================================================================
var private Actor                       DestActor;

//=============================================================================
// Events
//=============================================================================
event Popped()
{
	StopLatentExecution();
	Pawn.ZeroMovementVariables();
}

//=============================================================================
// State
//=============================================================================
AUTO state MoveToActor
{
Begin:
	//`log("xT_AICommand_MoveToActor  executed");

	if (DestActor == none)
	{
		Sleep(WorldInfo.DeltaSeconds);
		Goto('Begin');
	}

	ScriptedMoveTarget = DestActor;

Moveing:
    if( GeneratePathToActor(DestActor) )
	{
		NavigationHandle.SetFinalDestination(ScriptedMoveTarget.Location);

		while( Pawn != None && ScriptedMoveTarget != None && !Pawn.ReachedDestination(ScriptedMoveTarget) )
		{				
			if( NavigationHandle.ActorReachable( ScriptedMoveTarget) )
			{
				// then move directly to the actor
				MoveToward( ScriptedMoveTarget, ScriptedFocus, 150, true, false );
			}
			else
			{
				// move to the first node on the path
				if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
				{
					// suggest move preparation will return TRUE when the edge's
				    // logic is getting the bot to the edge point
						// FALSE if we should run there ourselves
					if (!NavigationHandle.SuggestMovePreparation( TempDest, Outer))
					{
						MoveTo( TempDest, ScriptedFocus, 150, false );						
					}
				}
			}
		}
	}
	else
	{
		//give up because the nav mesh failed to find a path
		`warn("FindNavMeshPath failed to find a path to"@ScriptedMoveTarget);
		ScriptedMoveTarget = None;
	}   
	Pawn.ZeroMovementVariables();
	PopCommand(Self);
}

//=============================================================================
// Setting up Leader unit
//=============================================================================
function SetDestinationActor(X_COM_Unit aActor)
{
	DestActor = aActor;
}

//=============================================================================
// DefaultProperties
//=============================================================================
defaultproperties
{
}
