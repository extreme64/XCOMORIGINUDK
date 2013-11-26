/**
 * X-COM main AI controller class
 */
class X_COM_AIController extends GameAIController dependson(X_COM_Defines);

//=============================================================================
// Variables: General
//=============================================================================
var repnotify protected bool bPossessed;

//=============================================================================
// Variables: Firing
//=============================================================================
var public Vector				    AttackLocation; // Location where pawn will firing
/** A list of enemies */
var private array<X_COM_Unit>       Enemies;

var public Vector                   LastKnownEnemyLocation;

//=============================================================================
// Variables: Move
//=============================================================================
/** point where to go */
var public vector               NewDestination;
var public Actor                ActorNewDestination;

//=============================================================================
// Variables: Command
//=============================================================================
enum ECommandNames
{
	EC_None,

	EC_MoveToPosition,
	EC_MoveToActor,
	EC_Turn,
	EC_Crouch,

	EC_AttackEnemy,
	EC_AttackLocation,
};

struct SAICommands
{
	var ECommandNames AICommandName;
	var class<X_COM_AICommand> AICommandClass;
};
var private array<SAICommands>          AICommands;

enum ECommandStates
{
	ECS_None,

	ECS_Idle,
};

struct SAICommandStates
{
	var ECommandStates AICommandState;
	var class<X_COM_AICommand> AICommandStateClass;
};
var private array<SAICommandStates>          AICommandStates;

//=============================================================================
// Replication
//=============================================================================
replication
{
	// Replicate if server
	if(Role == ROLE_Authority && (bNetInitial || bNetDirty))
		bPossessed;
}

simulated event ReplicatedEvent( name VarName )
{
	if( VarName == 'bPossessed' )	
	{
		if(Role < ROLE_Authority)
		{
			// On all clients set the Units controller to this HWAIController instance if the replicated Unit was changed (likely by the initial replication).
			// This is how replicated HWPawns on clients have their Controllers set (the default Unreal logic only replicates Pawn.Controller to the owning client).
			// If ReplicatedEvent() was called for Unit == None, it was destroyed on server.
			if(Pawn != none)
			{
				Pawn.Controller = self;
			}
		}
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

//=============================================================================
// Functions: Main
//=============================================================================
/** This function is seting parameters when controller possess to pawn. Used only to set physics*/
function Possess(Pawn aPawn, bool bVehicleTransition)
{
    if (aPawn.bDeleteMe)
	{
		`Warn(self @ GetHumanReadableName() @ "attempted to possess destroyed Pawn" @ aPawn);
		 ScriptTrace();
		 GotoState('Dead');
    }
	else
	{
		Super.Possess(aPawn, bVehicleTransition);
		SetCommandState(X_COM_Unit(aPawn).DefaultAiCommandState); 
		if ( (aPawn.GetTeamNum() == ET_ALIEN) || (aPawn.GetTeamNum() == ET_CIVILIAN) ) SetSkill(X_COM_Gameinfo(worldinfo.game).GameDifficult);
		bPossessed = true;
    }
}

//=============================================================================
// Functions: DEBUG
//=============================================================================
event Tick(float aDeltaTime)
{
	if (X_COM_Gameinfo(worldinfo.game).bDoDebug) 
		if (X_COM_Unit(Pawn).bIsSelected)
		{
			`log(" CommandList : "$CommandList$" Active command : "$GetActiveCommand());
		}
}

//=============================================================================
// Functions: Enemies
//=============================================================================
public function RegisterEnemy(X_COM_Unit aNewEnemy)
{
	local X_COM_Unit ltmpPawn;
	local bool lbAlreadyRegistered;

	foreach Enemies(ltmpPawn)
	{
		if (ltmpPawn == aNewEnemy) lbAlreadyRegistered = true;
	}

	if (!lbAlreadyRegistered)
	{
		Enemies.AddItem(aNewEnemy);
	}
	Enemy = aNewEnemy;
}

public function UnRegisterEnemy(X_COM_Unit aOldEnemy)
{
	if (aOldEnemy != none)
	{
		Enemies.RemoveItem(aOldEnemy);
		if (aOldEnemy == X_COM_Unit(Enemy))
		{
			Enemy = none;
		}
	}
}

public function LostEnemy(X_COM_Unit aOldEnemy)
{
	if (aOldEnemy != none)
	{
		LastKnownEnemyLocation = aOldEnemy.Location;
		UnRegisterEnemy(aOldEnemy);
	}
}

public function int GetEnemiesCount()
{
	return Enemies.Length;
}

public function X_COM_Unit GetEnemy(int aNumberInArray)
{
	return Enemies[aNumberInArray];
}

public function X_COM_Unit GetClosestEnemy()
{
	local X_COM_Unit ltmpPawn;
	local int il, jl;

	if (Enemies.Length > 0)
	{
		for (il=0; il < Enemies.Length; ++il)
		{
			if (Enemies[il] == none)
			{
				Enemies.RemoveItem(Enemies[il]);
				break;
			}
			for (jl=0; jl < Enemies.Length; ++jl)
			{
				if (Enemies[jl] == none)
				{
					Enemies.RemoveItem(Enemies[jl]);
					break;
				}
				if (abs(Vsize(Enemies[il].location - pawn.location)) < abs(Vsize(Enemies[jl].location - pawn.location)))
				{
					ltmpPawn = Enemies[il];
					Enemies[il] = Enemies[jl];
					Enemies[jl] = ltmpPawn;
				}
			}
		}
		return Enemies[0]; //return first element as closer enemy
	}
	else return none;
}


//=============================================================================
// Functions: Commands
//=============================================================================
/** Set and execute new command to controller
 * @param aCommandStateName ECommandStates. Name of the command state to be executed.
 */ 
protected function SetCommandState(ECommandStates aCommandStateName)
{
	local int il;

	il = AICommandStates.Find('AICommandState', aCommandStateName);

	if (il != -1) 
	{
		AICommandStates[il].AICommandStateClass.static.InitCommand(self);
	}
	else `warn("Wrong AI Command State: "$aCommandStateName);
}

//=============================================================================
// Functions: Commands
//=============================================================================
/** Set and execute new command to controller
 * @param aCommandName ECommandNames. Name of the command to be executed.
 * @param bDoNotAbortPreviousCommand Bool. Set to TRUE if you do not want to abort present command from stack.
 */ 
protected function SetCommand(ECommandNames aCommandName, optional bool bDoNotAbortPreviousCommand)
{
	local int il;

	il = AICommands.Find('AICommandName', aCommandName);

	if (il != -1) 
	{	
		//wtf in 1 string?
		if (!bDoNotAbortPreviousCommand) //We need to save the command
		{
			if (CommandList != GetActiveCommand()) 
				AbortCommand(GetActiveCommand()); //protect initial command from abort, so all others commands will be aborted and pushed to stack			
		}
		AICommands[il].AICommandClass.static.InitCommand(self);
	}
	else `warn("Wrong AI Command : "$aCommandName);
}


//=============================================================================
// Functions: Orders
//=============================================================================
//public function StartAttackEnemy(X_COM_Unit aEnemy, optional bool bDoNotAbbortPreviousCommand);
//public function StartAttackLocation(Vector aLocation, optional bool bDoNotAbbortPreviousCommand);
//public function MoveToPosition(Vector aPosition, optional bool bShouldWalk, optional bool bDoNotAbbortPreviousCommand );
//public function MoveToActor(Actor aActor, optional bool bDoNotAbbortPreviousCommand );

//=============================================================================
// Sensors events
//=============================================================================
event HearNoise( float Loudness, Actor NoiseMaker, optional Name NoiseType )
{
	local GameAICommand lActiveCmd;
	lActiveCmd = GetActiveCommand();
	if ( (lActiveCmd != none) && (X_COM_AICommand(lActiveCmd) != none) ) X_COM_AICommand(lActiveCmd).Reaction_HearNoise(Loudness, NoiseMaker, NoiseType);
}

event SeePlayer( Pawn Seen )
{
	local GameAICommand lActiveCmd;
	lActiveCmd = GetActiveCommand();
	//if (self.GetTeamNum() != Seen.GetTeamNum()) 
		if ( (lActiveCmd != none) && (X_COM_AICommand(lActiveCmd) != none) ) X_COM_AICommand(GetActiveCommand()).Reaction_SeeEnemy(X_COM_Unit(Seen));
}

event SeeMonster( Pawn Seen )
{
	local GameAICommand lActiveCmd;
	lActiveCmd = GetActiveCommand();
	if ( (lActiveCmd != none) && (X_COM_AICommand(lActiveCmd) != none) ) X_COM_AICommand(GetActiveCommand()).Reaction_SeeEnemy(X_COM_Unit(Seen));
}

event EnemyNotVisible() // do not use it! write your own event|function
{
	`log("---------------------------------- "$Pawn$"  ---  EnemyNotVisible()");
}

function EnemyLost(X_COM_Unit aEnemy)
{
	local GameAICommand lActiveCmd;
	lActiveCmd = GetActiveCommand();
	if ( (lActiveCmd != none) && (X_COM_AICommand(lActiveCmd) != none) ) X_COM_AICommand(GetActiveCommand()).Reaction_EnemyLost(aEnemy);
}

function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	local GameAICommand lActiveCmd;
	lActiveCmd = GetActiveCommand();
	if ( (lActiveCmd != none) && (X_COM_AICommand(lActiveCmd) != none) ) X_COM_AICommand(GetActiveCommand()).Reaction_UnderEnemyFire(X_COM_Unit(InstigatedBy.Pawn));
}

//=============================================================================
// States: Основные состояния контроллера
//=============================================================================
/** This state is automatically called after "function Possess()" */ 
auto state Idle
{}

//=============================================================================
// AI Skills
//=============================================================================
private simulated function SetSkill(EGameDifficult aDifficultLevel)
{
	Skill = int(aDifficultLevel);
	ResetSkills();
}

private function ResetSkills()
{
	Pawn.HearingThreshold = Pawn.HearingThreshold * FClamp(Skill/6.0, 0.0, 1.0);
	SetRotationRate();
	SetMaxDesiredSpeed();
	SetPeripheralVision();
	SetAlertness(Skill); //???????
}

private function SetRotationRate()
{
	if ( WorldInfo.IsConsoleBuild() )
	{
		RotationRate.Yaw = Min(30000 + 4000*(skill), 60000);
	}
	else
	{
		if ( Skill >= 3 )
		{
			SightCounterInterval = 0.2;
			RotationRate.Yaw = 110000;
		}
		else if ( Skill >= 2 )
		{
			RotationRate.Yaw = 7000 + 10000 * (skill);
			SightCounterInterval = 0.3;
		}
		else
		{
			RotationRate.Yaw = 35000 + 3000 * (skill);
			SightCounterInterval = 0.4;
		}
	}
	RotationRate.Pitch = RotationRate.Yaw;
}

private function SetMaxDesiredSpeed()
{
	if ( Skill >= 4 ) Pawn.MaxDesiredSpeed = 1;
}

private function SetPeripheralVision()
{
	if ( Pawn == None ) return;

	if ( Pawn.bStationary || (Pawn.Physics == PHYS_Flying) )
	{
		bSlowerZAcquire = false;
		Pawn.PeripheralVision = -0.7;
		return;
	}

	bSlowerZAcquire = true;
	if ( Skill < 2 ) Pawn.PeripheralVision = 0.7;
	else
	{
		if ( Skill > 6 )
		{
			bSlowerZAcquire = false;
			Pawn.PeripheralVision = -0.2;
		}
		else Pawn.PeripheralVision = 1.0 - 0.2 * skill;
	}

	Pawn.PeripheralVision = FMin(Pawn.PeripheralVision - Pawn.Alertness, 0.8);
}

/*
SetAlertness()
Change creature's alertness, and appropriately modify attributes used by engine for determining
seeing and hearing.
SeePlayer() is affected by PeripheralVision, and also by SightRadius and the target's visibility
HearNoise() is affected by HearingThreshold
*/
private function SetAlertness(float NewAlertness)
{
	if ( Pawn.Alertness != NewAlertness )
	{
		Pawn.PeripheralVision += 0.707 * (Pawn.Alertness - NewAlertness); //Used by engine for SeePlayer()
		Pawn.Alertness = NewAlertness;
	}
}

//=============================================================================
// DefaultProperties
//=============================================================================
DefaultProperties
{
	AICommandStates[0] = (AICommandState = ECS_None, AICommandStateClass = none)

	AICommands[0] = (AICommandName = EC_None, AICommandClass = none)



	Name="Default__X_COM_AIController"

	Skill = 1
}
