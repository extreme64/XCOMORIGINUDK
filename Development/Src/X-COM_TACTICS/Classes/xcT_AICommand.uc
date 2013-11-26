class xcT_AICommand extends X_COM_AICommand dependson(xcT_Defines);

public function Reaction_SeeEnemy(X_COM_Unit aEnemy)
{
	if (!CanSeeThisEnemy(aEnemy)) return;

	super.Reaction_SeeEnemy(aEnemy);

	//`log(" ");
	//`log("------------------");
	//`log(Pawn$" has seen "$aEnemy);
	//`log(" xcT_Gameinfo(worldinfo.Game).TeamInTurn = "$xcT_Gameinfo(worldinfo.Game).TeamInTurn);
	//`log("------------------");
	//`log(" ");

	if ( xcT_Gameinfo(worldinfo.Game).TeamInTurn != Eteams(GetTeamNum()) ) // Если сейчас ход чужой комманды
	{
		if (!aEnemy.bIsMyTurn) return; // если событие произошло не во время хода этого врага то прерываем, тк не нужно чтобы экран открывался когда солдат видит  просто стоящего врага который не ходит

		if ( (Pawn.IsA('X_COM_Pawn_Human')) || (Pawn.IsA('X_COM_Vehicle_Human')) ) //если игрок = человек
		{
			ShowEnemyTurnScreen(false);
			StartCameraTrackForEnemy(aEnemy);
			return;
		}
	}

	if (aEnemy.bIsInvisibleForAI) aEnemy.SetInvisible(false);
}

public function Reaction_EnemyLost(X_COM_Unit aEnemy)
{
	if ( xcT_Gameinfo(worldinfo.Game).TeamInTurn != Eteams(GetTeamNum()) ) // Если сейчас ход чужой комманды
	{
		if ( (Pawn.IsA('X_COM_Pawn_Human')) || (Pawn.IsA('X_COM_Vehicle_Human')) ) //если игрок = человек
		{
			//ShowEnemyTurnScreen(true);
			StopCameraTrackForEnemy();
		}
	}

	if  (aEnemy != none) //&& (!aEnemy.bIsInvisibleForAI) )
	{
		//aEnemy.SetInvisible(true); 
		super.Reaction_EnemyLost(aEnemy);
	}
}

public function Reaction_HearNoise( float Loudness, Actor NoiseMaker, optional Name NoiseType )
{
	local X_COM_Unit lEnemy;

	if (Loudness > 0.1)
	{
		lEnemy = X_COM_Unit(NoiseMaker);
		if ( (lEnemy != none) && (lEnemy.GetTeamNum() != Pawn.GetTeamNum()) )
		{
			X_COM_AIController(Outer).LastKnownEnemyLocation = lEnemy.Location;
		}
	}
}

public function Reaction_UnderEnemyFire(X_COM_Unit aEnemy)
{
	if ( (aEnemy != none) && (aEnemy.GetTeamNum() != Pawn.GetTeamNum()) )
	{
		X_COM_AIController(Outer).LastKnownEnemyLocation = aEnemy.Location;
	}
}

//=============================================================================
// Helpers
//=============================================================================
protected function ShowEnemyTurnScreen(bool bShow)
{
	xcT_GameInfo(Worldinfo.Game).ShowEnemyTurnScreen(bShow, Eteams(GetTeamNum()));
}

protected function StartCameraTrackForEnemy(X_COM_Unit aEnemy)
{
	xcT_PlayerController(xcT_GameInfo(Worldinfo.Game).GetPlayerController(GetTeamNum())).StartCameraTrackForEnemy(aEnemy);
}

protected function StopCameraTrackForEnemy()
{
	xcT_PlayerController(xcT_GameInfo(Worldinfo.Game).GetPlayerController(GetTeamNum())).StopCameraTrackForEnemy();
}

private function bool CanSeeThisEnemy(X_COM_Unit aEnemy)
{
	local Actor lActor;
	local vector lHitLoc, lHitNorm, lStart, lEnd;

	lStart = Pawn.Location;
	lStart.Z += Pawn.BaseEyeHeight - Pawn.FullHeight/2; // start from eyes

	lEnd = aEnemy.Location;

	lActor = Pawn.Trace(lHitLoc, lHitNorm, lEnd, lStart, true);
	if (lActor != none)
	{
		if ( lActor.isA('X_COM_Tile_Apex') ) return false;
	}

	return true;
}

//=============================================================================
// Default Properties
//=============================================================================
defaultproperties
{
}
