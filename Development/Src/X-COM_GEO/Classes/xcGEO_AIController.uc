/**
 * Tactics AI controller. 
 * Uses for x-com and ufo controllers
 */
class xcGEO_AIController extends X_COM_AIController;

//=============================================================================
// Functions: Orders
//=============================================================================
public function StartAttackEnemy(X_COM_Unit aEnemy, optional bool bDoNotAbbortPreviousCommand)
{
	Enemy = aEnemy;
	SetCommand(EC_AttackEnemy, bDoNotAbbortPreviousCommand);
}

public function MoveToPosition(Vector aPosition, optional bool bShouldWalk, optional bool bDoNotAbortPreviousCommand )
{	
	NewDestination = aPosition;
	SetCommand(EC_MoveToPosition, bDoNotAbortPreviousCommand);
}

public function MoveToActor(Actor aActor, optional bool bDoNotAbortPreviousCommand )
{	
	ActorNewDestination = aActor;
	SetCommand(EC_MoveToActor, bDoNotAbortPreviousCommand);
}

//=============================================================================
// DefaultProperties
//=============================================================================
DefaultProperties
{
	AICommandStates[1] = (AICommandState = ECS_Idle, AICommandStateClass = class'xcGEO_AICommand_Act_Idle')

	AICommands[1] = (AICommandName = EC_MoveToPosition, AICommandClass = class'xcGEO_AICommand_Cmd_MoveToPosition')
	AICommands[2] = (AICommandName = EC_MoveToActor, AICommandClass = class'xcGEO_AICommand_Cmd_MoveToActor')
	AICommands[3] = (AICommandName = EC_AttackEnemy, AICommandClass = class'xcGEO_AICommand_Cmd_AttackEnemy')

	Name="Default__xcGEO_AIController"
}
