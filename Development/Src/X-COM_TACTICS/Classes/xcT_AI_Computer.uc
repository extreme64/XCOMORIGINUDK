/** for alien only */

class xcT_AI_Computer extends Actor dependson(xcT_Defines);

//=============================================================================
// Variables
//=============================================================================
var private array<X_COM_Unit>           Friends;
var private array<X_COM_Unit>           Enemies;
var private int                         index;

var private X_COM_Unit                  CurrentAlien;
var private X_COM_Unit                  CurrentEnemy;
var private vector                      MoveDestination;



var private EEventNames ExecutedEvent;
var private EEventNames LastRecievedEvent;
var private EEventNames NewRecievedEvent;

// stucks check
var private int AlienStucksCounter;
var private array<vector> StuckList;
var private bool bSecondaryStuck;
var private Actor ObstacleInFront;

/** DEBUG */
var private bool        bDoDebug;

//=============================================================================
// Start|End turn
//=============================================================================
public function StartTurn()
{
	UpdateUnits();
	PushState('NewTurn');
}

public function EndTurn()
{
	xcT_GameInfo(worldinfo.Game).EndTurn_For(Eteams(GetTeamNum()));
}

private function UpdateUnits()
{
	local X_COM_Unit lUnit;

	foreach Friends(lUnit)
	{
		if ( (lUnit != none) && (lUnit.Controller != none) )
		{
			lUnit.SetInvisible(true);
			lUnit.TimeUnitsRemain = lUnit.TimeUnits;
		}
		else
		{
			Friends.RemoveItem(lUnit);
			lUnit.Controller.Destroy();
			lUnit.Destroy();
		}
	}
}

//=============================================================================
// Functions: Friends
//=============================================================================
public function RegisterSquadUnit(X_COM_Unit aNewFriends)
{
	Friends.AddItem(aNewFriends);
}

public function UnRegisterSquadUnit(X_COM_Unit aOldFriends)
{
	Friends.RemoveItem(aOldFriends);
}

//=============================================================================
// Functions: Enemies
//=============================================================================
public function RegisterEnemy(X_COM_Unit aNewEnemy)
{
	Enemies.AddItem(aNewEnemy);
}

public function UnRegisterEnemy(X_COM_Unit aOldEnemy)
{
	Enemies.RemoveItem(aOldEnemy);
}

//=============================================================================
// Functions: Getters
//=============================================================================
public function array<X_COM_Unit>  GetAllEnemies()
{
	return Enemies;
}

public function array<X_COM_Unit>  GetAllFriends()
{
	return Friends;
}

//=============================================================================
// State: main AI turn state
//=============================================================================
state NewTurn
{
//----------------------------------------------------------------------------------------------------------------------------------------- begin
begin:
	if (bDoDebug) `log("-------------------------------AI turn start-----------------------");

	index = 0;                                                                                                                              // ����� ������� ��������� �� ������.
	goto('alien_turn_start');                                                                                                               // ���� �� ������ ���� �����������

//----------------------------------------------------------------------------------------------------------------------------------------- alien_turn_start
alien_turn_start:
	if (bDoDebug) `log("alien_turn_start:");
	if (bDoDebug) `log("alien_turn_start: "$Friends[index]$" starting to turn");

	CurrentAlien = Friends[index];                                                                                                          // ����� ��������� �� ������ ���������� �� �������. ����� ��������� ������������� � ����� ���� ����� ���������
	if (CurrentAlien != none)
	{
		CurrentAlien.bIsMyTurn = true;
		goto('alien_check_weapon');                                                                                                         // ���� �� �������� ������� ������ � ����� � � �������
	}
	else                                                                                                                                    // ���� �������� � �������� = ������������, �� ������ ������ � ����������� ���
	{
		`warn("xcT_AI_Computer -> alien_turn_start -> CurrentAlien = NONE!");
		goto('END');
	}

//----------------------------------------------------------------------------------------------------------------------------------------- alien_check_weapon
alien_check_weapon:
	if (bDoDebug) `log("alien_check_weapon:");
	if (CurrentAlien.ActiveWeapon == none)                                                                                                  // �������� ������ � �����
	{
		/* TODO:
		 *  1. �������� ������� ������ � �������
		 *  2. ���� ��� � ������� �� - ���������� ����� ������ ������ � ���� ��� ���� �� �������� � ����� ���
		 *  3. ���� ������ �� ������� �� ����� ������ ���� ������, �� ���������� ����� ���  ������ ������ ������
		*/
	}
	else goto('alien_check_weapon_ammo');                                                                                                   // ���� ������ ���� � ����� �� ���� �� �������� �������� � ������

//----------------------------------------------------------------------------------------------------------------------------------------- alien_check_weapon_ammo
alien_check_weapon_ammo:
	if (bDoDebug) `log("alien_check_weapon_ammo:");
	if (CurrentAlien.ActiveWeapon.HasAmmo()) goto('alien_get_enemy');                                                                       // ���� ������ ���� � ����� � � ���� ���� �������, �� ���� ������ �� ��������� ����
	else
	{
		CurrentAlien.ActiveWeapon.LoadAmmo();                                                                                               // ���� ��� �������� �� ������� ������������ ������. ����������� � ���������� �� ������
		if (CurrentAlien.ActiveWeapon.HasAmmo()) goto('alien_get_enemy');									                                // ���� ������������ � � ������ ��� ���� �������, �� ���� ������ �� ��������� ����
		else goto('alien_move_random');                                                                                                     // ���� �������� ��� ����� ���, ������ �������� �������� ������ � ������� ��� ��� ���� ������
	}

//----------------------------------------------------------------------------------------------------------------------------------------- alien_get_enemy
alien_get_enemy:
	if (bDoDebug) `log("alien_get_enemy:");

	CurrentEnemy = GetBestEnemy();                                                                                                          // �������� ������ ����

	xcT_AiController(CurrentAlien.Controller).Enemy = CurrentEnemy;

	if (bDoDebug) `log("alien_get_enemy: EnemyAim = "$CurrentEnemy);

	if (CurrentEnemy == none)
	{
		if ( !isZero(xcT_AiController(CurrentAlien.Controller).LastKnownEnemyLocation) ) goto('alien_look_at');                             // ���� �������� ��������� ����� ���������� ����� �� ���������� � �� �������
		goto('alien_look_around');                                                                                                          // ��� �����  � ���������� ��� ��������� �������������� - ������ ������� ���������� ������
	}
	else goto('alien_fire');                                                                                                                // ���� ���� ������� ���� �� ������� ���

//----------------------------------------------------------------------------------------------------------------------------------------- alien_fire
alien_fire:
	if (bDoDebug) `log("alien_fire:");
	
	if (CurrentAlien.ActiveWeapon.CanAttack(CurrentEnemy))                                                                                   // �������� ����������� ����� ���� ������� � �����
	{
		if (bDoDebug) `log("alien_fire: CurrentAlien.Weapon.CanAttack TRUE!!!");

		if (CheckEnoughtTUs(class'xcT_Defines'.const.TUperFire_Quick))                                                                      // ���� �� ���������� ��� ������������ ��������
		{
			CurrentAlien.SetFireMode(GetBestFireMode());                                                                                    // ������� ������ ����� ��������

			if (bDoDebug) `log("alien_fire: TU = "$CurrentAlien.TimeUnitsRemain);
			if (bDoDebug) `log("alien_fire: FireMode = "$CurrentAlien.ActiveWeapon.FireMode);

			if (!CurrentEnemy.controller.CanSee(CurrentAlien)) ShowAttackingLocation();                                                     // ���� ��������� ���� �� ����� ����������, �� ��������� ����� ��������� ����� � ���������� �����
			sleep(0.1);

			xcT_Aicontroller(CurrentAlien.Controller).StartAttackLocation(CurrentEnemy.Location);                                           // ������� ����
			Goto('alien_check_IfIsInAction');                                                                                               // ���� �� �������� ���������� �������� � �������� � ����������
		}
		else                                                                                                                                // �� �� ���������� ��� ��������:
		{
			if (bDoDebug) `log("alien_fire: Not enought TU for FIRE, go to GetSafeMoveDestination()");

			MoveDestination = GetSafeMoveDestination();                                                                                     // ������� ���������� �����
			goto('alien_move_destination');                                                                                                 // ������� � ���������� ����� ��� ������ ��������
		}
	}
	else                                                                                                                                    // ��������� ����������:
	{
		if (bDoDebug) `log("alien_fire: CurrentAlien.Weapon.CanAttack FALSE!!!");

		MoveDestination = GetBestFirePosition();                                                                                            // ����� ������ ������� ��� ����� � ������� ����
		goto('alien_move_destination');
	}

//----------------------------------------------------------------------------------------------------------------------------------------- alien_look_at
alien_look_at:
	if (bDoDebug) `log("alien_look_at:");

	if (CheckEnoughtTUs(class'xcT_Defines'.const.TUperTurn * 2))                                                                            // �������� �� ���������� ������������ ��� ��������. �� ����������:
	{
		if (bDoDebug) `log("alien_look_at: TU = "$CurrentAlien.TimeUnitsRemain);
                                                           
		xcT_Aicontroller(CurrentAlien.Controller).TurnToPosition((xcT_AiController(CurrentAlien.Controller).LastKnownEnemyLocation) , , true);   // �������������� � ������� ����� ����������������

		Goto('alien_check_IfIsInAction');                                                                                                   // ���� �� �������� ���������� �������� � �������� � ����������
	}
	else Goto('alien_turn_end'); 

//----------------------------------------------------------------------------------------------------------------------------------------- alien_look_around
alien_look_around:
	if (bDoDebug) `log("alien_look_around:");

	if (CheckEnoughtTUs(class'xcT_Defines'.const.TUperTurn * 2))                                                                            // �������� �� ���������� ������������ ��� ��������. �� ����������:
	{
		if (bDoDebug) `log("alien_look_around: TU = "$CurrentAlien.TimeUnitsRemain);
                                                           
		xcT_Aicontroller(CurrentAlien.Controller).TurnToPosition(GetOppositePosition(), , true);                                            // �������������� �� 180 �������� ������ ���

		if (bDoDebug) `log("alien_look_around: Turn to = "$GetOppositePosition());

		Goto('alien_check_IfIsInAction');                                                                                                   // ���� �� �������� ���������� �������� � �������� � ����������
	}
	else Goto('alien_turn_end'); 

//----------------------------------------------------------------------------------------------------------------------------------------- alien_move_random
alien_move_random:
	if (bDoDebug) `log("alien_move_random:");

	if (CheckEnoughtTUs(class'xcT_Defines'.const.TUperStep * 2))                                                                            // �������� �� ���������� ������������ ��� ����. �� ����������:
	{
		if (bDoDebug) `log("alien_move_random: TU = "$CurrentAlien.TimeUnitsRemain);

		MoveDestination = xcT_Aicontroller(CurrentAlien.Controller).GetRundomDestination();

		xcT_Aicontroller(CurrentAlien.Controller).MoveToPosition(MoveDestination);                                                          // ��������� � ������� �����

		if (bDoDebug) `log("alien_move_random: MoveDestination = "$MoveDestination);

		Goto('alien_check_IfIsInAction');                                                                                                   // ���� �� �������� ���������� �������� � �������� � ����������
	}
	else Goto('alien_turn_end');                                                                                                            // �� �� ����������: ����������� ��� ���� ����������

//----------------------------------------------------------------------------------------------------------------------------------------- alien_move_destination
alien_move_destination:
	if (bDoDebug) `log("alien_move_destination:");
	if (CheckEnoughtTUs(class'xcT_Defines'.const.TUperStep * 2))
	{
		if (bDoDebug) `log("alien_move_destination: TU = "$CurrentAlien.TimeUnitsRemain);
		if (bDoDebug) `log("alien_move_destination: MoveDestination = "$MoveDestination);
		if (!isZero(MoveDestination))
		{
			xcT_Aicontroller(CurrentAlien.Controller).MoveToPosition(MoveDestination);
			Goto('alien_check_IfIsInAction'); // ���� �� �������� ���������� �������� � �������� � ����������
		}
		else Goto('alien_turn_end');
	}
	else Goto('alien_turn_end');

//----------------------------------------------------------------------------------------------------------------------------------------- alien_move_around_object
alien_move_around_object:
	if (bDoDebug) `log("alien_move_around_object:");

	ObstacleInFront = GetFrontActor();

	if (bDoDebug) `log("alien_move_around_object: ObstacleInFront = "$ObstacleInFront);

	if ( ObstacleInFront != none)
	{
		//ObstacleInFront.CollisionComponent.Bounds.BoxExtent;
		Goto('alien_turn_end'); //TEMP! ���� �� ������ ������
	}
	else
	{
		// ����� ��� ��� ����������� �������� event Touch �� CurrentAlien  � ���������� ���� �� ��� ��������  foreach (Touching)

		if (bDoDebug) `log("alien_move_around_object: ERROR!!! Unit stucked with unknown reason, check map in location = "$CurrentAlien.Location);
		Goto('alien_turn_end');                                                                                                            // �������� ������� �� �� ����� ������� �� ����������� ��� ���
	}

//----------------------------------------------------------------------------------------------------------------------------------------- alien_explore_location
alien_explore_location:
	if (bDoDebug) `log("alien_explore_location:");
	
	MoveDestination = xcT_AiController(CurrentAlien.Controller).LastKnownEnemyLocation;

	if (bDoDebug) `log("alien_explore_location: MoveDestination = "$MoveDestination);

	xcT_AiController(CurrentAlien.Controller).LastKnownEnemyLocation = vect(0,0,0);
	goto('alien_move_destination');    

//----------------------------------------------------------------------------------------------------------------------------------------- alien_turn_end
alien_turn_end:                                                                                                                             // ��������� �����
	if (bDoDebug) `log("alien_turn_end:");
	CheckAlienIsNoMoreSeenByPlayerUnits();
	xcT_Aicontroller(CurrentAlien.Controller).StopAction();
	CurrentAlien.bIsMyTurn = false;
	CurrentAlien = none;
	ExecutedEvent = EN_None;
	LastRecievedEvent = EN_None;
	NewRecievedEvent = EN_None;
	MoveDestination = vect(0,0,0);
	AlienStucksCounter = 0;
	StuckList.Remove(0, StuckList.Length -1 );
	bSecondaryStuck = false;
	index++;                                                                                                                                //���������� �������. ��� ������ ���������� ��������� � ������ ����������
	if (index == Friends.Length) GoTo('END');
	else goto('alien_turn_start');                                                                                                          // ������ ��� ������ ����������

//----------------------------------------------------------------------------------------------------------------------------------------- alien_check_IfIsInAction
alien_check_IfIsInAction:
	if (bDoDebug) `log("alien_check_IfIsInAction: Start sleeping while "$CurrentAlien$" bisDoingAction");

	while (xcT_Aicontroller(CurrentAlien.Controller).bisDoingAction)
	{
		if ( CheckAlienWasStucked() )
		{
			if (bDoDebug) `log("alien_check_IfIsInAction: CheckAlienWasStucked = TRUE, bSecondaryStuck = "$bSecondaryStuck);

			if (bSecondaryStuck) Goto('alien_move_around_object');                                                                         // ���� ���� ������� �� ������� ������ �����������
			else
			{
				CurrentAlien.DoJump(true);                                                                                                     // ������� ����� ��������/������������
				AlienStucksCounter = 0;
				StuckList.Remove(0, StuckList.Length -1 );
				bSecondaryStuck = true;	
			}
		}

		sleep(0.3333);                                                                                                                      // ���� bisDoingAction �� ����

		CheckAlienIsNoMoreSeenByPlayerUnits();                                                                                        // ��������, ����� �������� ��� �� ����� ������� ������ �� ������� ����� ���� ����������
	}

	if (bDoDebug) `log("alien_check_IfIsInAction: Finished sleeping while "$CurrentAlien$" bisDoingAction");

	Goto('alien_check_event');                                                                                                              // �������� ���������� ������� �� ����� ���� ��� �������� �������� ����� �� ��������

//----------------------------------------------------------------------------------------------------------------------------------------- alien_check_event
alien_check_event:
	if (bDoDebug) `log("alien_check_event: NewRecievedEvent = "$NewRecievedEvent$" | ExecutedEvent = "$ExecutedEvent);

	if ( (NewRecievedEvent != ExecutedEvent) || (ExecutedEvent == EN_None) )                                                                // ���� ����� ������� �� ����� ��� ������������ �������:
	{
		switch (NewRecievedEvent)                                                                                                           // �������� �������� ������ �� ���� ����������� �������
		{
			case EN_None:                                                                                                                   // �������: ������� ������� �� ���������:          
									if (xcT_Aicontroller(CurrentAlien.Controller).Enemy == none)                                            // ���� ��� �������������� ����
									{
										ExecutedEvent = EN_None;
										if (!isZero(xcT_AiController(CurrentAlien.Controller).LastKnownEnemyLocation) ) Goto('alien_explore_location');   // ��������� ��������� ����� ����������
										else Goto('alien_move_random');                                                                     // ��������� ����������
									}
									else                                                                                                    // ���� ����, ��������� �� ����� ����
									{
										ExecutedEvent = EN_None;
										goto('alien_check_weapon');
									}
			break;

			case EN_EnemySeen:                                                                                                              // �������: ��� ������� ����
									ExecutedEvent = EN_EnemySeen;
									Goto('alien_check_weapon');                                                                             // ���� ��� ���������
			break;

			default:                                                                                                                        // �� ��������� ������ �� ������
			break;
		}
	}
	Goto('alien_turn_end');

//----------------------------------------------------------------------------------------------------------------------------------------- END
END:
	if (bDoDebug) `log("END");
	EndTurn();                                                                                                                              // �������� � ��� ��� ��� �������� � �������� ��� ������
	PopState();                                                                                                                             // ��������� ������� ��������� ���� ����� ���������� � ��������� ��� � �����������
}

//=============================================================================
// Events
//=============================================================================
public event RecieveAIEvent(EEventNames aNewEventName)
{
	if (bDoDebug) `log(" RecieveAIEvent : aNewEventName = "$aNewEventName$" , LastRecievedEvent = "$LastRecievedEvent);
	if (aNewEventName != LastRecievedEvent) // ���� ����� ������� �� ����� �� ��� � ��������� ���������
	{
		NewRecievedEvent = aNewEventName;
		LastRecievedEvent = aNewEventName;
	}
}

//=============================================================================
// Functions
//=============================================================================
private function X_COM_Unit GetBestEnemy()
{
	// ��� ���� ��������� ���� ������ � ���������� ����  ����� ���������.
	// ��������� ������: ���� ���������, ��������� �� �����, �� �����
	return xcT_AiController(CurrentAlien.controller).GetClosestEnemy(); // ��������!!!
	
}

private function EFiringModes GetBestFireMode()
{
	local EFiringModes lMode;
	local float lDistance;

	// ������� ���������� ��� ������ �����������-���������� ������ �������� � ��� ������� ��
	if (CheckEnoughtTUs(class'xcT_Defines'.const.TUperFire_Aimed))
	{
		lMode = EFM_Sniper;
	}
	else
		if (CheckEnoughtTUs(class'xcT_Defines'.const.TUperFire_Burst*3))
		{
			lMode = EFM_Burst;
		}
		else
			if (CheckEnoughtTUs(class'xcT_Defines'.const.TUperFire_Quick))
			{
				lMode = EFM_Snap;
			}

	lDistance = abs(Vsize(xcT_Aicontroller(CurrentAlien.Controller).Enemy.Location - CurrentAlien.Location));

	// TODO: �������� ��������� ������ - �������� ���������!!!!!!!!!!!

	// �������� ����� �������� ������ �� ��������� �� ����
	switch (lMode)
	{
		// EFM_Sniper - ������ ��� ����� ������������ ����� ����� ��������
		case EFM_Sniper :    if ( abs(CurrentAlien.ActiveWeapon.WeaponRange - lDistance) > (CurrentAlien.ActiveWeapon.WeaponRange / 3) ) return EFM_Sniper;
							 else 
								if ( (abs(CurrentAlien.ActiveWeapon.WeaponRange - lDistance) > (CurrentAlien.ActiveWeapon.WeaponRange / 2)) && abs(CurrentAlien.ActiveWeapon.WeaponRange - lDistance) < (CurrentAlien.ActiveWeapon.WeaponRange / 3) ) return EFM_Snap;
								else return EFM_Burst;
		break;

		// EFM_Burst - ������ ��� ����� ������������ EFM_Burst � EFM_Snap ����� ��������
		case EFM_Burst :    if ( abs(CurrentAlien.ActiveWeapon.WeaponRange - lDistance) > (CurrentAlien.ActiveWeapon.WeaponRange / 2) ) return EFM_Snap;
							else return EFM_Burst;
		break;

		// EFM_Snap - ������ EFM_Snap
		case EFM_Snap :     return EFM_Snap;
		break;

		default :	        return EFM_None;
		break;
	}
}

private function vector GetOppositePosition()
{
	local vector lDir, lOppositDir, lOppositPoint;
	local rotator lRotDir;
	lDir = Normal(Vector(CurrentAlien.Rotation));
	lRotDir.Yaw = 180 * DegToUnrRot;
	lOppositDir = lDir + Normal(Vector(lRotDir));
	lOppositPoint = CurrentAlien.Location + lOppositDir * class'X_COM_Settings'.default.T_GridSize.X;
	lOppositPoint.Z = CurrentAlien.Location.Z;
	return lOppositPoint;
}


private function Actor GetFrontActor()
{
	local vector lHit, lNorm, lStart, lEnd, lExt;

	lStart = CurrentAlien.Location;
	lEnd = CurrentAlien.Location + Normal(Vector(CurrentAlien.Rotation)) * class'X_COM_Settings'.default.T_GridSize.X;
	lExt = class'X_COM_Settings'.default.T_GridSize / 2;
	return CurrentAlien.Trace(lHit, lNorm, lEnd, lStart, TRUE, lExt);
}

private function vector GetSafeMoveDestination()
{
	return xcT_Aicontroller(CurrentAlien.Controller).GetRundomDestination(); // ����� ���������� �� ��������� ����� �� ����� ������������	
}

private function vector GetBestFirePosition()
{
	local float lDistance;
	local float lDistDifference;
	local vector lMovePoint;

	lDistance = abs(Vsize(xcT_Aicontroller(CurrentAlien.Controller).Enemy.Location - CurrentAlien.Location));
	if (lDistance > CurrentAlien.ActiveWeapon.WeaponRange)
	{
		lDistDifference = lDistance - CurrentAlien.ActiveWeapon.WeaponRange;
		lMovePoint = CurrentAlien.Location + (lDistDifference + class'X_COM_Settings'.default.T_GridSize.X) * Normal(xcT_Aicontroller(CurrentAlien.Controller).Enemy.Location - CurrentAlien.Location);
		return class'xcT_Defines'.static.GetGridCoord(lMovePoint);
	}
	else return class'xcT_Defines'.static.GetGridCoord(CurrentAlien.Location); 
}

private function bool CheckEnoughtTUs(int aTUperAction)
{
	local int lTU;
	local int lTUremain;
	local int lTUperAction;
		
	lTU = CurrentAlien.TimeUnits;
	lTUremain = CurrentAlien.TimeUnitsRemain;
	lTUperAction = (lTU * aTUperAction)/100;

	if (lTUremain < lTUperAction ) 
	{
		return false;
	}
	else return true;
}

private function bool CheckAlienIsNoMoreSeenByPlayerUnits()
{
	local X_COM_Unit ltmpUnit;
	local X_COM_PlayerController lPC;
	local array<X_COM_Unit> lAllUnits;
	local bool lbSeen;

	foreach Worldinfo.AllControllers(class'X_COM_PlayerController', lPC)
	{
		if (lPC == none) continue;
			
		lAllUnits = lPC.GetAllUnits();
		lbSeen = false; 

		foreach lAllUnits(ltmpUnit)
		{
			if ( (ltmpUnit != none) && (ltmpUnit.Controller != none) )
			{
				if ( ltmpUnit.Controller.CanSee(CurrentAlien) ) lbSeen = true;                                  // �������� ��� ���� ���� �� ���� ���� ������ ����� ���������
				else X_COM_AIController(ltmpUnit.Controller).EnemyLost(CurrentAlien);                           // �� ����� - ������ ���� ��� ����� �������
			}
		}

		if (lbSeen)
		{
			if (CurrentAlien.bIsInvisibleForAI) CurrentAlien.SetInvisible(false);                               // ���� ���� �� ���� ���� ������ ����� ��������� � �������� ����� - �� ���������� ���������
		}
		else 
		{
			CurrentAlien.SetInvisible(true);
			ShowEnemyTurnScreen(true, ETeams(lPC.GetTeamNum()));
		}
	}                                                                                                           
	
	// TODO: ��� ���������� ����� ��� ������� ����, ���� 1 ����� ����� � ������ �� ����� ��������� �� �� ������������ ��� �����. � ������ ��� �� ���������. ��� �� ������������ ������� �����

	return lbSeen;
}

private function bool CheckAlienWasStucked()
{
	if (AlienStucksCounter > 5) return true;

	StuckList.AddItem(CurrentAlien.Location);

	if ( StuckList.Length > 3 )
	{
		if ( class'X_COM_Defines'.static.VectorsAlmostEqual(StuckList[StuckList.Length -3], StuckList[StuckList.Length -1], class'X_COM_Settings'.default.T_GridSize.X) ) //��������� -2 � ���������� ��������� ������ � �������� ������
			AlienStucksCounter++;
	}

	return false;
}

//=============================================================================
// Enemy Turn screen
//=============================================================================
function ShowEnemyTurnScreen(bool bShow, optional ETeams aForTeam)
{
	xcT_GameInfo(Worldinfo.Game).ShowEnemyTurnScreen(bShow, aForTeam); 
}

function ShowAttackingLocation()
{
	xcT_PlayerController(xcT_GameInfo(Worldinfo.Game).GetPlayerController(CurrentEnemy.GetTeamNum())).StartCameraTrackForEnemy(CurrentEnemy); // ������ ������ � �����
	ShowEnemyTurnScreen(false, Eteams(CurrentEnemy.GetTeamNum())); // ��������� �����
}

//=============================================================================
// DefaultProperties
//=============================================================================
defaultproperties
{
	bDoDebug = true
}
