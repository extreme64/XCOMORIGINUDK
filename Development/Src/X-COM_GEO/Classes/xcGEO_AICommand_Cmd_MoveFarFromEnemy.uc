class xcGEO_AICommand_Cmd_MoveFarFromEnemy extends xcGEO_AICommand_Cmd_Move;

//=============================================================================
// Variables: Movement
//=============================================================================
var private Rotator                     DesiredRotation;
var private bool                        bShouldWalk;

//=============================================================================
// Events
//=============================================================================
event Popped()
{
	StopLatentExecution();
	Pawn.ZeroMovementVariables();
}

event Pushed()
{
}

/*
//=============================================================================
// State
//=============================================================================
AUTO state MoveFarFromEnemy
{
	function vector GetOppositeMoveDestination()
	{
		local vector lDir, lOppositDir, lOppositPoint;
		local rotator lRotDir;
		lDir = Normal(Pawn.Location - X_COM_AIController(Outer).GetEnemy(0).Location);
		lDir.z = 0;
		lRotDir.Yaw = int(RandRange(4096, 12288));
		lOppositDir = lDir + Normal(Vector(lRotDir));
		lOppositPoint = Pawn.Location + lOppositDir * 960;
		lOppositPoint.Z = Pawn.Location.Z;
		return lOppositPoint;
	}

	function vector GetAnyMoveDestination()
	{
		local vector lDir, lOppositDir, lOppositPoint;
		local rotator lRotDir;
		lDir = Normal(Pawn.Location - X_COM_AIController(Outer).GetEnemy(0).Location);
		lDir.z = 0;
		lRotDir.Yaw = Rand(65536);
		lOppositDir = lDir + Normal(Vector(lRotDir));
		lOppositPoint = Pawn.Location + lOppositDir * 960;
		lOppositPoint.Z = Pawn.Location.Z;
		return lOppositPoint;
	}

Begin:
	//`log("xT_AICommand_MoveToPosition  executed");
	MoveDestination = GetOppositeMoveDestination();

Correction: 
	//final destination correction
	MoveDestination = MoveDestination + (Normal(MoveDestination - Pawn.Location) * Pawn.GetCollisionRadius());

	if (!NavigationHandle.PointReachable(MoveDestination, ,false))
	{
		MoveDestination = GetAnyMoveDestination();
		sleep(worldinfo.deltaseconds);
		goto('Correction');
	}

Turning:
	DesiredRotation = Rotator(MoveDestination-Pawn.Location);
	DesiredRotation.Pitch = 0;
	DesiredRotation.Roll = 0;
	Pawn.SetDesiredRotation(DesiredRotation);

Moveing:
	if (NavigationHandle.PointReachable(MoveDestination, ,false))
	{
		TempDest = MoveDestination;
		MoveToDirectNonPathPos(TempDest, none, 0.0f, bShouldWalk);
	}
	else
	{
		if (GeneratePathToLocation(MoveDestination))
		{
			// Pathcache contains a list of NavMesh edges only;
			// the actor needs to know where to go after it has passed the last edge
			NavigationHandle.SetFinalDestination(MoveDestination);
			Pawn.SetDesiredRotation(DesiredRotation);

			// keep moving until we reached destination
			while (Pawn != None && !Pawn.ReachedPoint(MoveDestination, none))
			{
				if (NavigationHandle.PointReachable(MoveDestination, ,false))
				{
					// then move directly to the destination
					TempDest = MoveDestination;
					MoveToDirectNonPathPos(TempDest, none, 0.0f, bShouldWalk);
					//break; //???
				}
				else
				{
					// move to the next node on the path
					if (NavigationHandle.GetNextMoveLocation(TempDest, 0.0f))
					{
						// SuggestMovePreparation returns true when the edge's logic will move the actor, and
						// false if we should run there ourselves
						if (!NavigationHandle.SuggestMovePreparation(TempDest, Outer))
						{
							MoveTo(TempDest, none, 0.0f, bShouldWalk);
						}
					}
					else
					{
						//give up because the nav mesh did not have anything for you in the path
						`warn("NavigationHandle.GetNextMoveLocation failed to find a destination for "@MoveDestination);
						break;
					}
				}
			}
		}
		else
		{
			//give up because the nav mesh failed to find a path
			`warn("FindNavMeshPath failed to find a path to"@MoveDestination);
		}
	}

Ending:
	if ( (!Pawn.ReachedPoint(MoveDestination, none)) && (NavigationHandle.PointReachable(MoveDestination, ,false)) ) GoTo('Moveing');

	X_COM_AIController(Outer).UnRegisterEnemy(X_COM_AIController(Outer).GetEnemy(0));

	PopCommand(Self);
}

*/

//=============================================================================
// DefaultProperties
//=============================================================================
defaultproperties
{
}
