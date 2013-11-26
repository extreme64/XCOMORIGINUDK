/**
 * Tactics AI controller. 
 * Uses for x-com and ufo controllers
 */
class xcT_AIController extends X_COM_AIController;

//=============================================================================
// Variables: Turn-based
//=============================================================================
var public bool                 bisDoingAction; // AI computer, for whait while pawn is doing some action
var public bool                 bSetTurnAsAction; // AI computer, if true then turning is the whole action, if false it is only part of action

//=============================================================================
// Functions: Orders
//=============================================================================
public function StartAttackLocation(Vector aLocation, optional bool bDoNotAbbortPreviousCommand)
{
	AttackLocation = aLocation;
	SetCommand(EC_AttackLocation, bDoNotAbbortPreviousCommand);
}

public function MoveToPosition(Vector aPosition, optional bool bShouldWalk, optional bool bDoNotAbbortPreviousCommand )
{	
	local GameAICommand lCommand;

	// прерывание движения если юнит движется
	lCommand = GetActiveCommand();
	if ( lCommand != none )
	{
		if ( lCommand.Class == class'xcT_AICommand_Cmd_MoveToPosition' )
		{
			xcT_AICommand_Cmd(lCommand).bShouldStopAction = true;
			return;
		}
	}
	else `warn("ERROR: you should set first active command state to unit");
	
	NewDestination = aPosition;
	SetCommand(EC_MoveToPosition, bDoNotAbbortPreviousCommand);
}

public function TurnToPosition(vector aTurnToNewLocation, optional bool bDoNotAbbortPreviousCommand, optional bool bSetAsAction)
{
	NewDestination = aTurnToNewLocation;
	bSetTurnAsAction = bSetAsAction;
	SetCommand(EC_Turn, bDoNotAbbortPreviousCommand);
}

public function CrouchOrStandUp()
{
	SetCommand(EC_Crouch);
}

public function StopAction()
{
	local xcT_AICommand_Cmd lCommand;

	lCommand = xcT_AICommand_Cmd(GetActiveCommand());
	if ( lCommand != none )
	{
		lCommand.bShouldStopAction = true;
	}
}

//=============================================================================
// Functions: Helpers
//=============================================================================
public function vector GetRundomDestination()
{
	local vector lvec;
	lvec.X = RandRange(0, class'X_COM_Settings'.default.T_LevelSize.X);
	lvec.Y = RandRange(0, class'X_COM_Settings'.default.T_LevelSize.Y);
	lvec.Z = Pawn.Location.Z; //RandRange(0, class'X_COM_Settings'.default.T_LevelSize.Z);

	return class'xcT_Defines'.static.GetGridCoord(lvec);
}

//=============================================================================
// DefaultProperties
//=============================================================================
DefaultProperties
{
	AICommandStates[1] = (AICommandState = ECS_Idle, AICommandStateClass = class'xcT_AICommand_Act_Idle')

	AICommands[1] = (AICommandName = EC_MoveToPosition, AICommandClass = class'xcT_AICommand_Cmd_MoveToPosition')
	AICommands[2] = (AICommandName = EC_Turn, AICommandClass = class'xcT_AICommand_Cmd_Turn')
	AICommands[3] = (AICommandName = EC_Crouch, AICommandClass = class'xcT_AICommand_Cmd_Crouch')
	AICommands[4] = (AICommandName = EC_AttackLocation, AICommandClass = class'xcT_AICommand_Cmd_AttackLocation')

	Role = ROLE_Authority
	//RemoteRole = ROLE_SimulatedProxy
	RemoteRole = ROLE_AutonomousProxy; // This is necessary because otherwise using SimulatedProxy issuing MoveOrders doesn't work anymore if a 2nd client joins the game (on all client!)
	bAlwaysRelevant = true; // this is necessary in order to replicate HWAIController and its Unit variable to all clients	

	Name="Default__xcT_AIController"
}
