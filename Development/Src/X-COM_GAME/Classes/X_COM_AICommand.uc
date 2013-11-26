class X_COM_AICommand extends GameAICommand;

//=============================================================================
// Main state
//=============================================================================
AUTO state Idle
{
}

//=============================================================================
// Reaction on sensors
//=============================================================================


public function Reaction_HearNoise( float Loudness, Actor NoiseMaker, optional Name NoiseType );

public function Reaction_SeeEnemy(X_COM_Unit aEnemy);

public function Reaction_UnderEnemyFire(X_COM_Unit aEnemy);

public function Reaction_EnemyLost(X_COM_Unit aEnemy)
{
	X_COM_AIController(Outer).LostEnemy(X_COM_Unit(X_COM_AIController(Outer).Enemy));
}

////=============================================================================
//// Report
////=============================================================================
//protected function Report_EnemyDetected(X_COM_Unit aEnemy) // also overrided for command states
//{
//	X_COM_AIController(Outer).RegisterEnemy(aEnemy);
//}

//protected function Report_TeamAboutEnemy(X_COM_Unit aEnemy)
//{
//	local X_COM_Unit ltmpPawn;
//	local float lReportRaduis;
//	local X_COM_AIController lController;
//	local X_COM_AICommand lCommand;

//	lReportRaduis = 2048; // radius from pawn. pawn will report all other pawns in this radius about enemy

//	foreach OverlappingActors(class'X_COM_Unit', ltmpPawn, lReportRaduis)
//	{
//		if (ltmpPawn != none)
//		{
//			if (X_COM_Unit(Pawn).Team == ltmpPawn.Team)
//			{
//				if (ltmpPawn.controller != none) 
//				{
//					lController = X_COM_AIController(ltmpPawn.controller);
//					lCommand = X_COM_AICommand(lController.GetActiveCommand());
//					if (lCommand != none) lCommand.Report_EnemyDetected(aEnemy);
//				}
//			}
//		}
//	}
//}

//=============================================================================
// Default Properties
//=============================================================================
defaultproperties
{
}
