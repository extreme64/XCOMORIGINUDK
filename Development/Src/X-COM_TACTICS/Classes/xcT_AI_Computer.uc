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

	index = 0;                                                                                                                              // берем первого пришельца из списка.
	goto('alien_turn_start');                                                                                                               // идем на начало хода пришельцами

//----------------------------------------------------------------------------------------------------------------------------------------- alien_turn_start
alien_turn_start:
	if (bDoDebug) `log("alien_turn_start:");
	if (bDoDebug) `log("alien_turn_start: "$Friends[index]$" starting to turn");

	CurrentAlien = Friends[index];                                                                                                          // берем пришельца из списка пришельцев по индексу. индек пришельца увеличивается в конце хода этого пришельца
	if (CurrentAlien != none)
	{
		CurrentAlien.bIsMyTurn = true;
		goto('alien_check_weapon');                                                                                                         // идем на проверку наличия оружия в руках и в рюкзаке
	}
	else                                                                                                                                    // если пришелец с индексом = несуществует, то выдаем ошибку и заканчиваем ход
	{
		`warn("xcT_AI_Computer -> alien_turn_start -> CurrentAlien = NONE!");
		goto('END');
	}

//----------------------------------------------------------------------------------------------------------------------------------------- alien_check_weapon
alien_check_weapon:
	if (bDoDebug) `log("alien_check_weapon:");
	if (CurrentAlien.ActiveWeapon == none)                                                                                                  // Проверка оружия в руках
	{
		/* TODO:
		 *  1. проверка наличия оружия в рюкзаке
		 *  2. если нет в рюкзаке то - попытаться найти оружие вокруг и если оно есть то побежать и взять его
		 *  3. если оружие не найдено то тогда бежать куда попало, но определить чтобы там  небыло солдат игрока
		*/
	}
	else goto('alien_check_weapon_ammo');                                                                                                   // если оружие есть в руках то идем на проверку патронов в оружии

//----------------------------------------------------------------------------------------------------------------------------------------- alien_check_weapon_ammo
alien_check_weapon_ammo:
	if (bDoDebug) `log("alien_check_weapon_ammo:");
	if (CurrentAlien.ActiveWeapon.HasAmmo()) goto('alien_get_enemy');                                                                       // если оружие есть в руках и у него есть патроны, то идем дальше на получение цели
	else
	{
		CurrentAlien.ActiveWeapon.LoadAmmo();                                                                                               // если нет патронов то сначала перезарядить оружие. Перезарядка у пришельцев по полной
		if (CurrentAlien.ActiveWeapon.HasAmmo()) goto('alien_get_enemy');									                                // если перезарядили и у оружия уже есть патроны, то идем дальше на получение цели
		else goto('alien_move_random');                                                                                                     // если патронов все равно нет, значит пытаемся побежать кудато в надежде что там есть оружие
	}

//----------------------------------------------------------------------------------------------------------------------------------------- alien_get_enemy
alien_get_enemy:
	if (bDoDebug) `log("alien_get_enemy:");

	CurrentEnemy = GetBestEnemy();                                                                                                          // получить лучшую цель

	xcT_AiController(CurrentAlien.Controller).Enemy = CurrentEnemy;

	if (bDoDebug) `log("alien_get_enemy: EnemyAim = "$CurrentEnemy);

	if (CurrentEnemy == none)
	{
		if ( !isZero(xcT_AiController(CurrentAlien.Controller).LastKnownEnemyLocation) ) goto('alien_look_at');                             // Если известно последнее место нахождения врага то посмотреть в ту сторону
		goto('alien_look_around');                                                                                                          // нет врага  и неизвестно его последнее местоположение - значит пробуем оглядеться вокруг
	}
	else goto('alien_fire');                                                                                                                // если есть видимый враг то атакуем его

//----------------------------------------------------------------------------------------------------------------------------------------- alien_fire
alien_fire:
	if (bDoDebug) `log("alien_fire:");
	
	if (CurrentAlien.ActiveWeapon.CanAttack(CurrentEnemy))                                                                                   // Проверка возможности атаки цели оружием в руках
	{
		if (bDoDebug) `log("alien_fire: CurrentAlien.Weapon.CanAttack TRUE!!!");

		if (CheckEnoughtTUs(class'xcT_Defines'.const.TUperFire_Quick))                                                                      // если ТУ достаточно для минимального выстрела
		{
			CurrentAlien.SetFireMode(GetBestFireMode());                                                                                    // выбрать лучший режим стрельбы

			if (bDoDebug) `log("alien_fire: TU = "$CurrentAlien.TimeUnitsRemain);
			if (bDoDebug) `log("alien_fire: FireMode = "$CurrentAlien.ActiveWeapon.FireMode);

			if (!CurrentEnemy.controller.CanSee(CurrentAlien)) ShowAttackingLocation();                                                     // Если атакуемый враг не видит атакующего, то открываем место положения врага и показываем атаку
			sleep(0.1);

			xcT_Aicontroller(CurrentAlien.Controller).StartAttackLocation(CurrentEnemy.Location);                                           // Атакуем цель
			Goto('alien_check_IfIsInAction');                                                                                               // идем на проверку выполнения комманды и ожидание её завершения
		}
		else                                                                                                                                // ТУ не достаточно для выстрела:
		{
			if (bDoDebug) `log("alien_fire: Not enought TU for FIRE, go to GetSafeMoveDestination()");

			MoveDestination = GetSafeMoveDestination();                                                                                     // находим безопасную точку
			goto('alien_move_destination');                                                                                                 // отходим в безопасную точку или просто подальше
		}
	}
	else                                                                                                                                    // Атаковать невозможно:
	{
		if (bDoDebug) `log("alien_fire: CurrentAlien.Weapon.CanAttack FALSE!!!");

		MoveDestination = GetBestFirePosition();                                                                                            // найти лучшую позицию для атаки и подойти туда
		goto('alien_move_destination');
	}

//----------------------------------------------------------------------------------------------------------------------------------------- alien_look_at
alien_look_at:
	if (bDoDebug) `log("alien_look_at:");

	if (CheckEnoughtTUs(class'xcT_Defines'.const.TUperTurn * 2))                                                                            // проверка ТУ минимально достаточного для поворота. ТУ достаточно:
	{
		if (bDoDebug) `log("alien_look_at: TU = "$CurrentAlien.TimeUnitsRemain);
                                                           
		xcT_Aicontroller(CurrentAlien.Controller).TurnToPosition((xcT_AiController(CurrentAlien.Controller).LastKnownEnemyLocation) , , true);   // поворачиваемся в сторону врага предположительно

		Goto('alien_check_IfIsInAction');                                                                                                   // идем на проверку выполнения комманды и ожидание её завершения
	}
	else Goto('alien_turn_end'); 

//----------------------------------------------------------------------------------------------------------------------------------------- alien_look_around
alien_look_around:
	if (bDoDebug) `log("alien_look_around:");

	if (CheckEnoughtTUs(class'xcT_Defines'.const.TUperTurn * 2))                                                                            // проверка ТУ минимально достаточного для поворота. ТУ достаточно:
	{
		if (bDoDebug) `log("alien_look_around: TU = "$CurrentAlien.TimeUnitsRemain);
                                                           
		xcT_Aicontroller(CurrentAlien.Controller).TurnToPosition(GetOppositePosition(), , true);                                            // поворачиваемся на 180 градусов вокруг оси

		if (bDoDebug) `log("alien_look_around: Turn to = "$GetOppositePosition());

		Goto('alien_check_IfIsInAction');                                                                                                   // идем на проверку выполнения комманды и ожидание её завершения
	}
	else Goto('alien_turn_end'); 

//----------------------------------------------------------------------------------------------------------------------------------------- alien_move_random
alien_move_random:
	if (bDoDebug) `log("alien_move_random:");

	if (CheckEnoughtTUs(class'xcT_Defines'.const.TUperStep * 2))                                                                            // проверка ТУ минимально достаточного для шага. ТУ достаточно:
	{
		if (bDoDebug) `log("alien_move_random: TU = "$CurrentAlien.TimeUnitsRemain);

		MoveDestination = xcT_Aicontroller(CurrentAlien.Controller).GetRundomDestination();

		xcT_Aicontroller(CurrentAlien.Controller).MoveToPosition(MoveDestination);                                                          // двигаемся в заданое место

		if (bDoDebug) `log("alien_move_random: MoveDestination = "$MoveDestination);

		Goto('alien_check_IfIsInAction');                                                                                                   // идем на проверку выполнения комманды и ожидание её завершения
	}
	else Goto('alien_turn_end');                                                                                                            // ТУ не достаточно: заканчиваем ход этим пришельцем

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
			Goto('alien_check_IfIsInAction'); // идем на проверку выполнения комманды и ожидание её завершения
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
		Goto('alien_turn_end'); //TEMP! пока не сделал другое
	}
	else
	{
		// Можно ещё тут попробовать получать event Touch от CurrentAlien  и определять чего он там касается  foreach (Touching)

		if (bDoDebug) `log("alien_move_around_object: ERROR!!! Unit stucked with unknown reason, check map in location = "$CurrentAlien.Location);
		Goto('alien_turn_end');                                                                                                            // Пришелец застрял хз по какой причине то заканчиваем его ход
	}

//----------------------------------------------------------------------------------------------------------------------------------------- alien_explore_location
alien_explore_location:
	if (bDoDebug) `log("alien_explore_location:");
	
	MoveDestination = xcT_AiController(CurrentAlien.Controller).LastKnownEnemyLocation;

	if (bDoDebug) `log("alien_explore_location: MoveDestination = "$MoveDestination);

	xcT_AiController(CurrentAlien.Controller).LastKnownEnemyLocation = vect(0,0,0);
	goto('alien_move_destination');    

//----------------------------------------------------------------------------------------------------------------------------------------- alien_turn_end
alien_turn_end:                                                                                                                             // обнуление всего
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
	index++;                                                                                                                                //увеличение индекса. для выбора следующего пришельца в списке пришельцев
	if (index == Friends.Length) GoTo('END');
	else goto('alien_turn_start');                                                                                                          // начать ход другим пришельцем

//----------------------------------------------------------------------------------------------------------------------------------------- alien_check_IfIsInAction
alien_check_IfIsInAction:
	if (bDoDebug) `log("alien_check_IfIsInAction: Start sleeping while "$CurrentAlien$" bisDoingAction");

	while (xcT_Aicontroller(CurrentAlien.Controller).bisDoingAction)
	{
		if ( CheckAlienWasStucked() )
		{
			if (bDoDebug) `log("alien_check_IfIsInAction: CheckAlienWasStucked = TRUE, bSecondaryStuck = "$bSecondaryStuck);

			if (bSecondaryStuck) Goto('alien_move_around_object');                                                                         // Если павн застрял то пробуем обойти препятствие
			else
			{
				CurrentAlien.DoJump(true);                                                                                                     // Пробуем разок прыгнуть/перепрыгнуть
				AlienStucksCounter = 0;
				StuckList.Remove(0, StuckList.Length -1 );
				bSecondaryStuck = true;	
			}
		}

		sleep(0.3333);                                                                                                                      // Пока bisDoingAction то спим

		CheckAlienIsNoMoreSeenByPlayerUnits();                                                                                        // Проверим, вдруг пришелец уже не видим юнитами игрока то включим экран хода пришельцев
	}

	if (bDoDebug) `log("alien_check_IfIsInAction: Finished sleeping while "$CurrentAlien$" bisDoingAction");

	Goto('alien_check_event');                                                                                                              // Проверка полученных событий во время того как пришелец выполнял какие то действия

//----------------------------------------------------------------------------------------------------------------------------------------- alien_check_event
alien_check_event:
	if (bDoDebug) `log("alien_check_event: NewRecievedEvent = "$NewRecievedEvent$" | ExecutedEvent = "$ExecutedEvent);

	if ( (NewRecievedEvent != ExecutedEvent) || (ExecutedEvent == EN_None) )                                                                // если новое событие не равно уже обработаному событию:
	{
		switch (NewRecievedEvent)                                                                                                           // выбираем действие исходя из типа полученного события
		{
			case EN_None:                                                                                                                   // Событие: никаких событий не произошло:          
									if (xcT_Aicontroller(CurrentAlien.Controller).Enemy == none)                                            // если нет действительной цели
									{
										ExecutedEvent = EN_None;
										if (!isZero(xcT_AiController(CurrentAlien.Controller).LastKnownEnemyLocation) ) Goto('alien_explore_location');   // Исследуем последнее место нахождение
										else Goto('alien_move_random');                                                                     // Исследуем территорию
									}
									else                                                                                                    // Цель есть, переходим на атаку цели
									{
										ExecutedEvent = EN_None;
										goto('alien_check_weapon');
									}
			break;

			case EN_EnemySeen:                                                                                                              // Событие: был замечен враг
									ExecutedEvent = EN_EnemySeen;
									Goto('alien_check_weapon');                                                                             // надо его атаковать
			break;

			default:                                                                                                                        // по умолчанию ничего не делать
			break;
		}
	}
	Goto('alien_turn_end');

//----------------------------------------------------------------------------------------------------------------------------------------- END
END:
	if (bDoDebug) `log("END");
	EndTurn();                                                                                                                              // Сообщаем о том что ход законцен и передаем ход игроку
	PopState();                                                                                                                             // закрываем текущее состояние хода мозга пришельцев и переводим его в бездействие
}

//=============================================================================
// Events
//=============================================================================
public event RecieveAIEvent(EEventNames aNewEventName)
{
	if (bDoDebug) `log(" RecieveAIEvent : aNewEventName = "$aNewEventName$" , LastRecievedEvent = "$LastRecievedEvent);
	if (aNewEventName != LastRecievedEvent) // если новое событие НЕ такое же как и последнее полученно
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
	// тут надо проверить всех врагов и определить кого  лучше атаковать.
	// параметры выбора: шанс попадания, дистанция до врага, НР врага
	return xcT_AiController(CurrentAlien.controller).GetClosestEnemy(); // временно!!!
	
}

private function EFiringModes GetBestFireMode()
{
	local EFiringModes lMode;
	local float lDistance;

	// сначала определяем для какого максимально-затратного режима стрельбы у нас хватает ТУ
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

	// TODO: добавить критерием выбора - точность персонажа!!!!!!!!!!!

	// Выбираем режим стрельбы исходя из дистанции до цели
	switch (lMode)
	{
		// EFM_Sniper - значит что можно использовать любой режим стрельбы
		case EFM_Sniper :    if ( abs(CurrentAlien.ActiveWeapon.WeaponRange - lDistance) > (CurrentAlien.ActiveWeapon.WeaponRange / 3) ) return EFM_Sniper;
							 else 
								if ( (abs(CurrentAlien.ActiveWeapon.WeaponRange - lDistance) > (CurrentAlien.ActiveWeapon.WeaponRange / 2)) && abs(CurrentAlien.ActiveWeapon.WeaponRange - lDistance) < (CurrentAlien.ActiveWeapon.WeaponRange / 3) ) return EFM_Snap;
								else return EFM_Burst;
		break;

		// EFM_Burst - значит что можно использовать EFM_Burst и EFM_Snap режим стрельбы
		case EFM_Burst :    if ( abs(CurrentAlien.ActiveWeapon.WeaponRange - lDistance) > (CurrentAlien.ActiveWeapon.WeaponRange / 2) ) return EFM_Snap;
							else return EFM_Burst;
		break;

		// EFM_Snap - только EFM_Snap
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
	return xcT_Aicontroller(CurrentAlien.Controller).GetRundomDestination(); // нужно переделать на номальный поиск по карте проходимости	
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
				if ( ltmpUnit.Controller.CanSee(CurrentAlien) ) lbSeen = true;                                  // проверка что если хотя бы один юнит игрока видит пришельца
				else X_COM_AIController(ltmpUnit.Controller).EnemyLost(CurrentAlien);                           // не видит - значит вряг для юнита потерян
			}
		}

		if (lbSeen)
		{
			if (CurrentAlien.bIsInvisibleForAI) CurrentAlien.SetInvisible(false);                               // если хотя бы один юнит игрока видит пришельца и пришелец скрыт - то отображаем пришельца
		}
		else 
		{
			CurrentAlien.SetInvisible(true);
			ShowEnemyTurnScreen(true, ETeams(lPC.GetTeamNum()));
		}
	}                                                                                                           
	
	// TODO: Тут получается косяк при сетевой игре, если 1 игрок видит а второй не видит пришельца то он отображается для обоих. И походу это не исправить. Это бы исправлялось туманом войны

	return lbSeen;
}

private function bool CheckAlienWasStucked()
{
	if (AlienStucksCounter > 5) return true;

	StuckList.AddItem(CurrentAlien.Location);

	if ( StuckList.Length > 3 )
	{
		if ( class'X_COM_Defines'.static.VectorsAlmostEqual(StuckList[StuckList.Length -3], StuckList[StuckList.Length -1], class'X_COM_Settings'.default.T_GridSize.X) ) //сравнение -2 и последнего елементов списка в пределах клетки
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
	xcT_PlayerController(xcT_GameInfo(Worldinfo.Game).GetPlayerController(CurrentEnemy.GetTeamNum())).StartCameraTrackForEnemy(CurrentEnemy); // ставим камеру к павну
	ShowEnemyTurnScreen(false, Eteams(CurrentEnemy.GetTeamNum())); // открываем экран
}

//=============================================================================
// DefaultProperties
//=============================================================================
defaultproperties
{
	bDoDebug = true
}
