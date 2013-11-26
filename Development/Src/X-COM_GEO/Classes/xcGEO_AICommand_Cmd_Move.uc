class xcGEO_AICommand_Cmd_Move extends xcGEO_AICommand_Cmd;

//=============================================================================
// Variables: Movement
//=============================================================================
var protected int                         UnitsInMove;
var protected Vector                      TempDest; // for scripted move

										 /** If the object is closer to destination than this value
										  *  it is assumed that the destination is reached
										  *  @remarks (for x1 game speed)*/
//var protected float                       DestinationReachedDistance;     
//=============================================================================
// Events
//=============================================================================
event PostPopped()
{
	super.PostPopped();
	StopLatentExecution();
	if (Pawn != none) Pawn.ZeroMovementVariables();
}

//=============================================================================
// DefaultProperties
//=============================================================================
defaultproperties
{
	DestinationReachedDistance = 40;
}
