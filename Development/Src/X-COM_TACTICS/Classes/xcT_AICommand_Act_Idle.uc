class xcT_AICommand_Act_Idle extends xcT_AICommand_Act;

//=============================================================================
// State
//=============================================================================
AUTO state Idle
{
Begin:
	//`log("xT_AICommand_Idle executed");

Idleing:
	//Sleep(WorldInfo.DeltaSeconds * 5);
	//CheckForEnemyReported();
	//Goto('Idleing');
}

//=============================================================================
// DefaultProperties
//=============================================================================
defaultproperties
{
}
