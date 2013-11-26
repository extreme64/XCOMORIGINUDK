/**
 * X-COM Tactical PlayerController. 
 * Uses for Tactics-game.
 */
class xcT_PlayerController extends X_COM_PlayerController;

//=============================================================================
// Variables: General
//=============================================================================
var X_COM_Tile                              MouseCursorAttachment; //General var for SelectBOX, AimBox
var ParticleSystemComponent                 SelectBOX, AimBox;  //Selection box and Aim with grid coordinates. 
var xcT_GFx_Inventory                       InventoryMovie;

var vector                                  MouseTickLocation; //mouse locaton every frame

var xcT_PlayerCamera_OrbitCamera	     	MainCamera;

var private float                           RMBPressedTime; // time right mouse button was pressed. for unit turn
var private bool                            bUnitWasRotated; // define if unit was turned to any location

var private bool                            bIsMyTurn; // defines that now is my turn

var private  bool                           bTrackForEnemy;
var private X_COM_Unit                      TrackedEnemy;

var private float                           ActualNoEnemyTurnScreenStartTime;
var private float                           DesiredNoEnemyTurnScreenTime;
var private bool                            bCachedToShowEnemyTurnScreen;

var string mNames[12];                  // DEBUG: Names of soldiers

//=============================================================================
// Functions: General
//=============================================================================
simulated function PostBeginPlay()
{
	super.PostBeginPlay();
}

event SpawnPlayerCamera()
{
	super.SpawnPlayerCamera();

	MainCamera = xcT_PlayerCamera_OrbitCamera(GamePlayerCamera(PlayerCamera).CurrentCamera);

	IgnoreLookInput(true);
}

function PlayMusic()
{
	MusicManager.ChangeTrack(EMST_music_Tactics_MainTheme);
}

//=============================================================================
// Functions: Zoom
//=============================================================================
function ZoomIn() //Zoom in
{
	MainCamera.ZoomIn();
}

function ZoomOut() //Zoom out
{
	MainCamera.ZoomOut();
}

//=============================================================================
// Functions: 
//=============================================================================
/** UI-function. Присесть. Сказать выбраному солдату сесть на корточки */
function SitDown()
{
	if ( (SelectedUnits.Length > 0) && (SelectedUnits[0] != none) && (SelectedUnits[0].Physics != PHYS_Falling) && (SelectedUnits[0].bCanCrouch))
	{
		xcT_AIController_Human(SelectedUnits[0].Controller).CrouchOrStandUp();
	}
}

exec function ThrowWeapon()
{

    ServerThrowWeapon();
}

reliable server function ServerThrowWeapon()
{

}

function BoxLevelUp()
{

}

function BoxLevelDown()
{

}

/** Установить и прикрепить к мышке ящик выбора/движения */
function SpawnSelectBox()
{
	DestroyAllBoxesAttachments();
	MouseCursorAttachment = spawn(class'X_COM_Tile', self, , MouseTickLocation, rot(0,0,0), , true);
	SelectBOX = WorldInfo.MyEmitterPool.SpawnEmitter(class'X_COM_Settings'.default.SelectBOX, MouseTickLocation, rot(0,0,0), MouseCursorAttachment);
}

/** Установить и прикрепить к мышке указатель цели для стрельбы */
function SpawnAimBox(EFiringModes aNewFireMode)
{	
		`log(" "$self$" "$String(Role)$" SpawnAimBox():: aNewFireMode="$aNewFireMode);
		`log(" "$self$" "$String(Role)$" SpawnAimBox():: SelectedUnits[0]="$SelectedUnits[0]);
	if ( (SelectedUnits.Length > 0) && (SelectedUnits[0] != none) )
	{
		DestroyAllBoxesAttachments();
		//SelectedUnits[0].SetFireMode(aNewFireMode);
		ServerSetUnitFireMode(SelectedUnits[0], aNewFireMode);
		MouseCursorAttachment = spawn(class'X_COM_Tile', self, , MouseTickLocation, rot(0,0,0), , true);
		AimBox = WorldInfo.MyEmitterPool.SpawnEmitter(class'X_COM_Settings'.default.AimBox, MouseTickLocation - vect(0,0,20.0), rot(0,0,0), MouseCursorAttachment);
	}
}

reliable server function ServerSetUnitFireMode(X_COM_Unit aNewUnit, EFiringModes aNewFireMode)
{	
	aNewUnit.SetFireMode(aNewFireMode);	
}

/** Select clicked unit (pawn or vehicle) */
function SelectPlayerUnit(X_COM_Unit aNewUnit)
{
	SelectedUnitsClear();
	super.SelectPlayerUnit(aNewUnit);
	SpawnSelectBox();
}

function DestroyAllBoxesAttachments()
{
	if (SelectBOX != none)
	{
		SelectBOX.DeactivateSystem();//Убираем ящик выбора/движения если он есть
		SelectBOX = none;
	}
	if (AimBox != none)
	{
		AimBox.DeactivateSystem(); // Убираем целеуказатель если он есть
		AimBox = none;
	}
	if (MouseCursorAttachment != none)
	{
		MouseCursorAttachment.Destroy(); // Убираем целеуказатель или ящик выбора от мышки если он есть
		MouseCursorAttachment = none;
	}
}

/** Остановить управление персонажем и перейти в режим свободной камеры */
function SelectedUnitsClear()
{
	super.SelectedUnitsClear();
	DestroyAllBoxesAttachments();
}

/** When pawn is firing, player cannot controll camera and it sticks to projectile **/
function AttachCameraTo(Actor ThisActor)
{
	local vector lControllerFireLocation;
	//local rotator lControllerFireRotation;

	//lControllerFireRotation = Rotation;
	//lControllerFireRotation.YAW = ThisActor.Rotation.YAW;
	//SetRotation(lControllerFireRotation);

	lControllerFireLocation = ThisActor.Location - ((normal(vector(Rotation)))*((X_COM_HUD(myHud).ScreenCenter.X + X_COM_HUD(myHud).ScreenCenter.Y)/2));
	lControllerFireLocation.z = Location.z;
	SetLocation(lControllerFireLocation);
}

function UpdateInventoryMenu(optional X_COM_Unit aPawn = none)
{
	local X_COM_Unit lPawn;
	local Inventory lItem;
	local int il;//, ui;

	if(aPawn != none)
	{
		for(lItem = aPawn.InvManager.InventoryChain; lItem != None; lItem = lItem.Inventory)
		//foreach aSelectedUnit.InvManager.InventoryChain (class'Inventory', lInvItem)
		{
			if( lItem.isA('X_COM_Weapon'))
			{
				InventoryMovie.CallAddToInventory(mNames[0], "item_weapon", 1);
				`log(mNames[0]$" loading item "$lItem.Name);
			}
		}
	}
	else
	{
		foreach AllUnits(lPawn, il)
		{
			//il = 0;
			for(lItem = lPawn.InvManager.InventoryChain; lItem != None; lItem = lItem.Inventory)
			//foreach aSelectedUnit.InvManager.InventoryChain (class'Inventory', lInvItem)
			{
			
				if( lItem.isA('X_COM_Weapon'))
				{
					InventoryMovie.CallAddToInventory(mNames[il], string('item_weapon'), 1);
					`log(mNames[il]$' loading item '$lItem.Name);
				}
				il++;
			}
		}
	}
}

function ShowInventory()
{
	local X_COM_Unit lPawn;
	//local Inventory lItem;
	//local int il;
	
	mNames[0] = "makaron marihuanovich";
	mNames[1] = "prosto ivan";
	mNames[2] = "juriy nikolaevich";
	mNames[3] = "homer simpson";
	mNames[4] = "spanch bob";
	mNames[5] = "terminator";
	mNames[6] = "cyrex";
	mNames[7] = "silvester stallone";
	mNames[8] = "predator";
	mNames[9] = "space marine";
	mNames[10] = "bender";
	mNames[11] = "mr hate";

	if (InventoryMovie == none)
	{
		InventoryMovie = new class'xcT_GFx_Inventory';
		InventoryMovie.InitUI(X_COM_HUD(myHud));
		InventoryMovie.SetViewScaleMode( SM_ExactFit );
		InventoryMovie.SetAlignment( Align_Center );
		`log('Creating inventory');

		/*foreach AllUnits (lPawn, ui)
		{
			il = 0;
			
			for(lItem = lPawn.InvManager.InventoryChain; lItem != None; lItem = lItem.Inventory)
			//foreach aSelectedUnit.InvManager.InventoryChain (class'Inventory', lInvItem)
			{
			
				if( lItem.isA('X_COM_Weapon'))
				{
					InventoryMovie.CallAddToInventory(mNames[ui], string('item_weapon'), 1);
					`log(mNames[ui]$' loading item '$lItem.Name);
				}
				il++;
			}
		}*/
		lPawn = none;
		if (SelectedUnits.Length == 1)
		{
			lPawn = SelectedUnits[0];
			// загружаем  и показываем его инвентарь
		}
		UpdateInventoryMenu(lPawn);
	} 
	else 
	{
		InventoryMovie.Close();
		InventoryMovie = none;
	}
}

//=============================================================================
// Orders
//=============================================================================
/** Выстрелить выбраным персонажем в точку целеуказателя*/
reliable server function UnitFireAt(Controller aController, optional X_COM_Unit aUnit, optional vector aAimLocation) // приоритет выстрела в юнита если оба аргумента заданы
{
	local vector lFireLocation;
	local X_COM_Pawn lPawn;

	if (aUnit != none)
	{
		switch (X_COM_Unit(aController.Pawn).ActiveWeapon.FireMode)
		{
			case	EFM_Sniper  :	lPawn = X_COM_Pawn(aUnit);
									if (lPawn != none)
									{
										lFireLocation = lPawn.Mesh.GetBoneLocation(lPawn.HeadBone); // переделать на получение положения сокета который как-бы является слабой точкой
										if ( !isZero(lFireLocation) ) lFireLocation = aUnit.Location; // нет головы
									}
									else lFireLocation = aUnit.Location; // не павн а техника значит
			break;
			case	EFM_Burst   :	lFireLocation = aUnit.Location; // выстрел в центр юнита
			break;
			case	EFM_Snap    :	lFireLocation = aUnit.Location; // выстрел в центр юнита
			break;
		}
	}
	else if ( !isZero(aAimLocation) ) lFireLocation = aAimLocation;

	if ( !isZero(lFireLocation) ) xcT_AIController_Human(aController).StartAttackLocation(lFireLocation);
		
}

/** Бежать выбраным персонажем в указанное место */
reliable server function UnitMoveToLocation(Controller aController, vector aLocation)
{	
	//xcT_AIController_Human(SelectedUnits[0].Controller).MoveToPosition(aLocation);
	xcT_AIController_Human(aController).MoveToPosition(aLocation);		
}

/** Повернуть выбраного персонажа в указанное положение */
reliable server function UnitTurnTo(Controller aController, vector aLocation)
{	
	xcT_AIController_Human(aController).TurnToPosition(aLocation,,true); //тут раньше был поворот без указания как действие. переделано для тумана войны, открывается туман при повороте юнита
}

//=============================================================================
// States: FiringState
//=============================================================================
/** State used when pawn is firing **/
STATE FiringState extends XCOMEmptyState
{
	event EndState(Name NextStateName)
	{
		if (AimBox != none) SpawnSelectBox();
		super.EndState(NextStateName);
	}
}

//=============================================================================
// States: TacticsControllerState
//=============================================================================
/** Main state to controll soldiers and UI **/
AUTO STATE TacticsControllerState extends XCOMGame//XCOMEmptyState
{
	event BeginState(Name PreviousStateName)
	{	
	}

	event EndState(Name NextStateName)
	{
	}

	/** Trace actor with his class under box **/
	function Actor DoTraceActorUnderBOX()
	{
		local Vector lTraceLocation, lHitLocation, lHitNormal, lTraceExtent;
		local Vector lTraceStart, lTraceEnd;//, lTraceDir;	
		local Actor lActor;

		lTraceExtent = class'X_COM_Settings'.default.T_GridSize / 2; // half than grid

		lTraceLocation = MouseCursorAttachment.location;
		lTraceStart = lTraceLocation;
		lTraceStart.Z += class'X_COM_Settings'.default.T_GridSize.Z / 2;
		lTraceEnd = lTraceLocation;
		lTraceEnd.Z -= class'X_COM_Settings'.default.T_GridSize.Z / 2;

		lActor = Trace( lHitLocation, lHitNormal, lTraceEnd, lTraceStart, true, lTraceExtent);

		return lActor;
	}

	/** Trace mouse location in 3D world. Uses For SelectBOX, AimBox location set */
	function vector DoTraceMouseLocationForBoxes()
	{
		local Vector lHitLocation, lHitNormal;
		local Vector lTraceStart, lTraceEnd, lTraceDir;	
		//local Actor lActor;
		local Actor lActor;
	
		lActor = none;
	
		lTraceStart = X_COM_Hud(myHud).MouseLocation;
		lTraceDir = X_COM_Hud(myHud).MouseDirection;
		lTraceEnd = lTraceStart + 32768*lTraceDir;

		//ForEach TraceActors(class'Actor', lActor, lHitLocation, lHitNormal, lTraceEnd, lTraceStart) 
		ForEach TraceActors(class'Actor', lActor, lHitLocation, lHitNormal, lTraceEnd, lTraceStart) 
		{
			if(lActor != none)
			{
				//if ((lActor.isA('Terrain')) || (lActor.isA('WorldInfo')) || (lActor.isA('X_COM_Tile'))) return lHitLocation;
				if ((lActor.isA('X_COM_Tile_SM'))  || (lActor.isA('X_COM_Tile_Apex'))) break;
			}
		}
		return lHitLocation;
	}

	/** Проверка - бежит ли сейчас выбраный персонаж или стоит */
	function bool AIisStanding()
	{
		return (xcT_AIController_Human(SelectedUnits[0].Controller).bisDoingAction);
	}

	/** Нажатие левой кнопки мыши */
    function bool LeftMousePressed()
    {
		if (!super.LeftMousePressed()) return false; // check if other mouse button already pressed
		if (bBlockedMouseInput) return false; // check if mouse under scaleform button
		return true;
    }
	
	/** Отжатие левой кнопки мыши */
    function bool LeftMouseReleased()
    {	
		local X_COM_Unit lNewPawnSelection;

		if (!bLeftMousePressed) return false; // check if mouse press was not executed	
		super.LeftMouseReleased();
		if (bBlockedMouseInput) return false;
		if (bScaleformButtonClicked) // don't process click further if Scaleform GFx GUI already did
		{
			bScaleformButtonClicked = false;
			return false;
		}

		if ((SelectBOX != none) || (AimBOX != none) ) lNewPawnSelection = X_COM_Unit(DoTraceActorUnderBOX());
		else lNewPawnSelection = X_COM_Unit(DoTraceActorUnderMouse(class'X_COM_Unit'));

		if (lNewPawnSelection != none)
		{
			//if ((lNewPawnSelection.Class == class'X_COM_Pawn_Human') || (lNewPawnSelection.Class == class'X_COM_Vehicle_Human'))
			if ( lNewPawnSelection.GetTeamNum() == self.GetTeamNum() )
			{
				SelectPlayerUnit(lNewPawnSelection);
			}
		}
		else SelectedUnitsClear(); // Снять выделение с выбраного персонажа

		return true;
    }

	/** Нажатие правой кнопки мыши */
	function bool RightMousePressed()
    {
		if (!super.RightMousePressed()) return false; // check if other mouse button already pressed
		if (bBlockedMouseInput) return false; // check if mouse under scaleform button

		// init: unit turning:
		bUnitWasRotated = false;
		RMBPressedTime = WorldInfo.TimeSeconds;
		settimer(worldinfo.DeltaSeconds, true, 'RightMouseHolded');

		return true;
    }

	/** Проверка на удержание кнопки */
	function RightMouseHolded()
    {
		local float lHoldOnTime;
		if (!bRightMousePressed)
		{
			ClearTimer('RightMouseHolded');
		}
		else
		{
			lHoldOnTime = Worldinfo.TimeSeconds;
			if ((lHoldOnTime - RMBPressedTime) > 0.5)
			{
				ClearTimer('RightMouseHolded');
				bUnitWasRotated = true;
				if ( (SelectedUnits.Length > 0) && (SelectedUnits[0] != none) && (selectedUnits[0].Controller != none)) UnitTurnTo(selectedUnits[0].Controller, MouseTickLocation);
			}
		}
    }

	/** Отжатие правой кнопки мыши */
	function bool RightMouseReleased()
    {
		local X_COM_Unit lTracedActor;

		if (!bRightMousePressed) return false; // check if mouse press was not executed
		super.RightMouseReleased();
		if (bBlockedMouseInput) return false;	
		if (bScaleformButtonClicked) // don't process click further if Scaleform GFx GUI already did
		{
			bScaleformButtonClicked = false;
			return false;
		}

		if (selectedUnits[0].IsFiring()) return false;

		if (MouseCursorAttachment != none)
		{
			lTracedActor = X_COM_Unit(DoTraceActorUnderBOX());

			if ((SelectedUnits.Length > 0) && (SelectedUnits[0] != none) && (selectedUnits[0].Controller != none))
			{
				if (SelectBOX != none)
				{
					if (!bUnitWasRotated)
					{
						if (lTracedActor == none)
						{
							if ( (MouseCursorAttachment.location != vect(0,0,0)) && (MouseCursorAttachment.location != class'xcT_Defines'.static.GetGridCoord(SelectedUnits[0].Location)) )
							{
								// if mouse cursor is not out of world (out map bounds) and if not this unit location
								UnitMoveToLocation(selectedUnits[0].Controller, MouseCursorAttachment.location);
								SpawnClickToTerrainEffect(MouseCursorAttachment.location);
							}
						}
						else SelectedUnits[0].JumpOffPawn(); // TODO: show 
					}
					else
					{
						// deinit unit turning:
						bUnitWasRotated = false;
						RMBPressedTime = 0;
					}
				}
				else
					if (AimBox != none)
					{
						if (lTracedActor != none) UnitFireAt(selectedUnits[0].Controller, lTracedActor, );
						else UnitFireAt(selectedUnits[0].Controller, none, MouseCursorAttachment.location);
						DestroyAllBoxesAttachments();
						SpawnSelectBox();
					}

			}
		}
		return true;
    }

	/** Нажатие средней кнопки мыши */
	function bool MiddleMousePressed()
    {
		if (!super.MiddleMousePressed()) return false; // check if other mouse button already pressed
		if (bBlockedMouseInput) return false; // check if mouse under scaleform button
		IgnoreLookInput(false);
		return true;

    }

	/** Отжатие средней кнопки мыши */
	function bool MiddleMouseReleased()
    {
		if (!bMiddleMousePressed) return false; // check if mouse press was not executed
		super.MiddleMouseReleased();
		if (bBlockedMouseInput) return false;
		if (bScaleformButtonClicked) // don't process click further if Scaleform GFx GUI already did
		{
			bScaleformButtonClicked = false;
			return false;
		}
		IgnoreLookInput(true);	
		return true;
    }


	/** Функция выполняется каждый кадр.
	 *  Служит для установки целеуказателя или ящика выделения/движения в место где находится мышка с использованием виртуальной сетки.
	*/
	event PlayerTick(float DeltaTime)
	{
		local Actor     lActorUnder;
		//local Vector    lCheckedLocation;

		super.PlayerTick(DeltaTime);
		if ((SelectedUnits.Length > 0) && (MouseCursorAttachment != none))
		{
			MouseTickLocation = class'xcT_Defines'.static.GetGridCoord(DoTraceMouseLocationForBoxes());
			lActorUnder = DoTraceActorUnderMouse(class'Actor');
			if (lActorUnder != none) MouseCursorAttachment.setlocation(MouseTickLocation);
		}

		//if (class'xcT_Defines'.static.CheckLocationLimit(Location, lCheckedLocation)) SetLocation(lCheckedLocation);
	}

	/** Движение камеры */
	function PlayerMove(float aDeltaTime)
	{
		local vector			X,Y,Z, NewAccel;
		local float             Forward, Strafe;   
		local Vector    lCheckedLocation;
		
		GetAxes(Rotation,X,Y,Z);

		//update movement
		Forward = PlayerInput.aForward;
		Strafe = PlayerInput.aStrafe;
		ProcessBorderMovement(Forward, Strafe);

		// Update acceleration.
		NewAccel = Forward * X + Strafe * Y;
		NewAccel.Z	= 0;
		Velocity = SpectatorCameraSpeed * Normal(NewAccel);

		LimitSpectatorVelocity();
		if( VSize(Velocity) > 0 )
		{
			MoveSmooth( (1+bRun) * Velocity * aDeltaTime );
			// correct if out of bounds after move
			if ( LimitSpectatorVelocity() )
			{
				MoveSmooth( Velocity.Z * vect(0,0,1) * aDeltaTime );
			}
		}

		UpdateRotation(aDeltaTime);


		if (class'xcT_Defines'.static.CheckLocationLimit(Location, lCheckedLocation)) SetLocation(lCheckedLocation);
	}

	function bool LimitSpectatorVelocity()
	{
		if ( Location.Z > WorldInfo.StallZ )
		{
			Velocity.Z = FMin(SpectatorCameraSpeed, WorldInfo.StallZ - Location.Z - 2.0);
			return true;
		}
		else if ( Location.Z < WorldInfo.KillZ )
		{
			Velocity.Z = FMin(SpectatorCameraSpeed, WorldInfo.KillZ - Location.Z + 2.0);
			return true;
		}
		return false;
	}

	function ProcessBorderMovement(out float Forward, out float Strafe)
	{
		local vector2d lMousePosition;

		lMousePosition = xcT_Hud(myHud).GetMouseCoordinates();

		if(!bRotateAround)
		{
			if(lMousePosition.Y == 0.0f)
			{
				Forward = 1.0f;
			}
			else if(lMousePosition.Y == xcT_Hud(myHud).ViewportSize.Y - 1)
			{
				Forward = -1.0f;
			}
			
			if(lMousePosition.X == 0.0f)
			{
				Strafe = -1.0f;
			}
			else if(lMousePosition.X == xcT_Hud(myHud).ViewportSize.X - 1)
			{
				Strafe = 1.0f;
			}
		}
	}
}

// Переделать на получение данных координат из флеша
function CameraChangeLocationInMinimap()
{
	local Vector2D lMouseLocation;
	local Vector lNewLocation;

	lMouseLocation = xcT_Hud(myHud).GetMouseCoordinates();
	lNewLocation = xcT_Hud(myHud).Convert_Size_MiniMap_To_Map(lMouseLocation);
	SetLocation(lNewLocation);
}

//=============================================================================
// Turn-based
//=============================================================================
/** UI-function. Конец хода */
public function EndPlayerTurn()
{
	`log(" EndPlayerTurn() --- start enemy turn ");

	DestroyAllBoxesAttachments();
	SelectedUnitsClear();

	bIsMyTurn = false;

	GoToState('EnemyTurn');

	`log(" Team = "$GetTeamNum());
	`log(" Team Eteams = "$Eteams(GetTeamNum()));
	ServerEndTurn();	
}

reliable server function ServerEndTurn()
{
	xcT_GameInfo(worldinfo.Game).EndTurn_For(Eteams(GetTeamNum()));
}

reliable client function ServerStartTurn()
{
	StartPlayerTurn();
}

/** Начало хода игрока */
protected function StartPlayerTurn()
{
	`log("-------------------------------PLAYER "$GetTeamNum()$" turn start-----------------------");

	bIsMyTurn = true;

	GoToState('TacticsControllerState');
}

public function StartCameraTrackForEnemy(X_COM_Unit aEnemy)
{
	bTrackForEnemy = true;
	TrackedEnemy = aEnemy;
}

public function StopCameraTrackForEnemy()
{
	bTrackForEnemy = false;
}

state EnemyTurn
{
	event BeginState(Name PreviousStateName)
	{
		local X_COM_Unit lUnit;

		ShowEnemyTurnScreen(true);

		foreach AllUnits(lUnit)
		{
			if ( (lUnit != none) && (lUnit.Controller != none) ) lUnit.SetInvisible(true);
			else
			{
				AllUnits.RemoveItem(lUnit);
				lUnit.Controller.Destroy();
				lUnit.Destroy();
			}
		}
	}

	event EndState(Name NextStateName)
	{
		local X_COM_Unit lUnit;

		ShowEnemyTurnScreen(false);

		bTrackForEnemy = false;

		foreach AllUnits(lUnit)
		{
			if ( (lUnit != none) && (lUnit.Controller != none) )
			{
				lUnit.SetInvisible(false);
				lUnit.TimeUnitsRemain = lUnit.TimeUnits;
			}
			else
			{
				AllUnits.RemoveItem(lUnit);
				lUnit.Controller.Destroy();
				lUnit.Destroy();
			}
		}
	}

	/** Слежение камеры за ходом пришельца */
	event PlayerTick(float DeltaTime)
	{
		super.PlayerTick(DeltaTime);

		if (bTrackForEnemy)
		{
			self.AttachCameraTo(TrackedEnemy);
		}
	}
}
//=============================================================================
// Turn screen controlls
//=============================================================================
public function ShowEnemyTurnScreen(bool bShow)
{
	local bool bDoShow;

	if (bShow)
	{
		if (CanShowEnemyTurnScreen()) bDoShow = true;
		else
		{
			CacheShowEnemyTurnScreenCall();
			return;
		}
	}
	else
	{
		ActualNoEnemyTurnScreenStartTime = worldinfo.TimeSeconds;
		bDoShow = false;
	}


	xcT_Hud(myHud).ShowEnemyTurnScreen(bDoShow);
}

/** Кэширование запроса на повторный показ экрана хода пришельцев */
private function CacheShowEnemyTurnScreenCall()
{
	if (!bCachedToShowEnemyTurnScreen)
	{
		bCachedToShowEnemyTurnScreen = true;
		SetTimer( (worldinfo.DeltaSeconds * 30.0f), true,'CheckTimerCanShowEnemyTurnScreen');
	}
}

/** Функция таймера, проверяет - наступило ли время повторного показа экрана хода пришельцев, и если да то показывает экран */
private function CheckTimerCanShowEnemyTurnScreen()
{
	if (bIsMyTurn)
	{
		if (CanShowEnemyTurnScreen())
		{
			ClearTimer('CheckCanShowEnemyTurnScreen');
			bCachedToShowEnemyTurnScreen = false;
			ShowEnemyTurnScreen(true);	
		}
	}
	else
	{
		ClearTimer('CheckCanShowEnemyTurnScreen');
		bCachedToShowEnemyTurnScreen = false;
		ShowEnemyTurnScreen(false);	
	}
}

/** Наступило ли время повторного показа экрана хода пришельцев */
private function bool CanShowEnemyTurnScreen()
{
	return ( (abs(worldinfo.TimeSeconds - ActualNoEnemyTurnScreenStartTime)) > DesiredNoEnemyTurnScreenTime );
}

//=============================================================================
// Default Properties
//=============================================================================
defaultproperties
{
	SpectatorCameraSpeed=1000

	ActualNoEnemyTurnScreenStartTime = 0.0f
	DesiredNoEnemyTurnScreenTime = 1.99f

    Name="Default__xcT_PlayerController"	

	CameraClass=class'X-COM_Tactics.xcT_PlayerCamera'
	InputClass=class'X-COM_Tactics.xcT_PlayerInput'

	RemoteRole = ROLE_AutonomousProxy;
	Role = ROLE_Authority
}