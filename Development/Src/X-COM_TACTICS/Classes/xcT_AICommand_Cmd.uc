class xcT_AICommand_Cmd extends xcT_AICommand;

var protected bool bCanContinueAction; // to stop pawn action while got some events
var public bool bShouldStopAction; // to stop pawn action while another command got

//=============================================================================
// Events
//=============================================================================
event PrePushed(GameAIController AI)
{
	super.PrePushed(AI);
	xcT_AIController(Outer).bisDoingAction = true;
	bCanContinueAction = true;
	//`log("PrePushed called by "$pawn$" in command : "$self);
}

event PostPopped()
{
	super.PostPopped();
	xcT_AIController(Outer).bisDoingAction = false;
	//`log("PostPopped called by "$pawn$" in command : "$self);
}

//=============================================================================
// Reaction on sensors
//=============================================================================
public function Reaction_SeeEnemy(X_COM_Unit aEnemy)
{
	super.Reaction_SeeEnemy(aEnemy);

	//`log("Reaction_SeeEnemy, EnemyAim = "$X_COM_Unit(X_COM_AIController(Outer).Enemy)$" | aEnemy = "$aEnemy);

	if (X_COM_Unit(X_COM_AIController(Outer).Enemy) != none)
	{
		//`log("1");
		if (aEnemy == X_COM_Unit(X_COM_AIController(Outer).Enemy)) return;
		else
		{
			//`log("2");
			X_COM_AIController(Outer).Enemy = none;
			Reaction_SeeEnemy(aEnemy);
		}
	}
	else
	{
		//`log("5");
		bCanContinueAction = false;
		X_COM_AIController(Outer).RegisterEnemy(aEnemy);
		if ( (Pawn.IsA('X_COM_Pawn_Alien')) || (Pawn.IsA('X_COM_Vehicle_Alien')) ) SendEventToAi(EN_EnemySeen); // only for aliens
		//PopCommand(self);
	}
}

//=============================================================================
// Functions
//=============================================================================
protected function SendEventToAi(EEventNames aNewEventName)
{
	xcT_Gameinfo(worldinfo.Game).Alien_AI.RecieveAIEvent(aNewEventName);
}

//=============================================================================
// DefaultProperties
//=============================================================================
defaultproperties
{
}
