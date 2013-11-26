/**
 * X-COM Geosphere PlayerController. 
 * Uses for GEO-game.
 */
class xcGEO_PlayerController extends X_COM_PlayerController;

//=============================================================================
// Variables: General
//=============================================================================
var xcGEO_GameInfo                          mGameInfo;
var xcGEO_Defines                           _F; //Reference to xcGEO_Defines class

//=============================================================================
// Variables: GEO
//=============================================================================
var public int                              GeoDistanceFromPlanet; // Расстояние от центра планеты до места в котором сейчас находится камера. Для Зума и вращения вокруг планеты
var private int                             DesiredDistanceFromPlanet; // для плавного перемещения камеры
var private bool                            bCameraShouldDoZoom; // для активации зума в тике для плавного перемещения камеры

//=============================================================================
// Variables: GEO Camera Rotation with right mouse button
//=============================================================================
var private float                           RMBPressedTime; // time right mouse button was pressed. for camera turn
var private bool                            bCameraWasRotated; // define if unit was turned to any location

//=============================================================================
// Variables: GEO: HUD: Прямоугольное выделение
//=============================================================================
var bool                                    bDragging; // Разрешает рисование прямоугольника выделения в худе
var bool                                    bWasDragged; //Определение, тянули ли мы прямоугольник выделения
var float                                   DraggDeltaTime; //Время которое мы тянули прямоугольник выделения
var Vector2D                                StartOfDragg, EndOfDragg; //Координаты начала и конца прямоугольника выделения
var bool                                    bDoAircraftSelection; //Разрешает делать проекцию из 3Д в 2Д в кадре HUD для выбора выделенных самолетов

//=============================================================================
// Variables: Bases
//=============================================================================
var xcGEO_Base_Manager                      BaseManager; //reference to xcGEO_Base_Manager class

var vector                                  preBaseCameraLocation; //Saved camera location before going in to the x-com Base
var Rotator                                 preBaseCameraRotation; //Saved camera rotation before going in to the x-com Base

var xcGEO_Tile_Bases_Modules                MouseCursorAttachment; //General var for Base modules moving
var Vector                                  AttachmentTickLocation; //Mouse locaton every frame for Base modules location
var Vector                                  AttachmentDimensions;
var EBaseModuleSizeType                     ModuleSizeType;
var xcGEO_Tile_Bases_GeoBase                NowInCurrentBase; //указатель на базу в которой находится игрок

var xcGEO_Base_Aircrafts_Manager            AircraftsManager; // Aircrafts manager

//=============================================================================
// Variables: Alein Events
//=============================================================================
var private X_COM_Tile_AlienEvent           ActiveAlienEvent; // Event Player selected and looked at

var private vector                          AutoScrollLocation; //Location for auto scroll
var private float                           RotateStep;
var private bool                            bCanAutoScroll;

//=============================================================================
// Functions: General
//=============================================================================
simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	mGameInfo = xcGEO_GameInfo(WorldInfo.Game);    //should go prior other functions
	_F = new()class'xcGEO_Defines';                //make a reference to public functions class
	DateTimeRuning();
	GeoDistanceFromPlanet = class'X_COM_Settings'.default.GEO_MaxZoomLocationOffset; //distance from Earth
}

function PlayMusic()
{
	MusicManager.ChangeTrack(EMST_music_Geo_MainTheme);
}

//=============================================================================
// Functions: Zoom
//=============================================================================
public function ZoomIn() //Zoom in
{
    bZoomIn = true;
    bZoomOut = false;
	DesiredDistanceFromPlanet = Clamp((GeoDistanceFromPlanet - class'X_COM_Settings'.default.GEO_ZoomDistance), class'X_COM_Settings'.default.GEO_MinZoomLocationOffset, class'X_COM_Settings'.default.GEO_MaxZoomLocationOffset);
	bCameraShouldDoZoom = true;
}

public function ZoomOut() //Zoom out
{
    bZoomIn = false;
    bZoomOut = true;
	DesiredDistanceFromPlanet = Clamp((GeoDistanceFromPlanet + class'X_COM_Settings'.default.GEO_ZoomDistance), class'X_COM_Settings'.default.GEO_MinZoomLocationOffset, class'X_COM_Settings'.default.GEO_MaxZoomLocationOffset);
	bCameraShouldDoZoom = true;
}

private function StopZooming() //Stop zoom in or zoom out
{
    bZoomIn = false;
    bZoomOut = false;
	bCameraShouldDoZoom = false;
}

//=============================================================================
// Functions: HUD Date and Time
//=============================================================================
function DateTimeRuning()
{
     SetTimer(1.0, true, 'UpdateTime');
}

function UpdateTime()
{
	//local float lTime;
	//lTime = Worldinfo.TimeSeconds;
    //if (HUD_Planet != none) HUD_Planet.mOBJ_Time.SetString("text", String(lTime));
}

//=============================================================================
// Functions: State: main geo-game state
//=============================================================================
function EnterState_Geosphere()
{   
	GoToState('Geosphere');
}

auto state Geosphere extends XCOMGame
{
	event BeginState(Name PreviousStateName)
	{
	}

	event EndState(Name NextStateName)
	{
	}

    function bool LeftMousePressed()
    {
		if (!super.LeftMousePressed()) return false;  // check if other mouse button already pressed
		if (bBlockedMouseInput) return false;         // check if mouse under scaleform button
		xcGEO_Hud(myHUD).StartDrawSelectionRange();
		return true;
    }

    function bool LeftMouseReleased()
    {
		local Vector lClickedLocation;
		local Actor lActor;

		if (!bLeftMousePressed) return false; // check if mouse press was not executed
		xcGEO_Hud(myHUD).StopDrawSelectionRange();

		super.LeftMouseReleased();
		if (bBlockedMouseInput) return false;
		if (bScaleformButtonClicked) // don't process click further if Scaleform GFx GUI already did
		{
			bScaleformButtonClicked = false;
			return false;
		}

		if (!xcGEO_Hud(myHUD).bWasDragged) //Detection: click or rectangle selection
		{	//click
			lActor = DoTraceActorUnderMouse(class'Actor');

			if (lActor == none) return true;

			if (lActor.IsA('X_COM_Tile_AlienEvent'))
			{
				SelectAlienEvent(X_COM_Tile_AlienEvent(lActor));
				return true;
			}

			if (lActor.IsA('xcGEO_Tile_Bases_GeoBase'))
			{
				EnterInExistBase(xcGEO_Tile_Bases_GeoBase(lActor));
				return true;
			}

			if (lActor.IsA('X_COM_Vehicle_AirVehicle_Human'))
			{
				SelectedUnitsClear();
				SelectPlayerUnit(X_COM_Vehicle_AirVehicle(lActor));
				return true;
			}

			if (lActor.IsA('X_COM_Vehicle_AirVehicle_Alien'))
			{
				UnitsAttackEnemy(X_COM_Vehicle_AirVehicle(lActor));
				return true;
			}

			lClickedLocation = DoTraceMouseLocation();
			
			if ( (SelectedUnits.Length > 0) && (lActor.IsA('xcGEO_Tile_Earth_Planet')) )
			{
				UnitsMoveToLocation(lClickedLocation);
			}
		}
		else //rectangle selection
		{
			xcGEO_Hud(myHUD).bDoAircraftSelection = true; //permission to execute rectangle selection in DrawHUD().
		}
		return true;
    }

	/** Нажатие правой кнопки мыши */
	function bool RightMousePressed()
    {
		if (!super.RightMousePressed()) return false; // check if other mouse button already pressed
		if (bBlockedMouseInput) return false; // check if mouse under scaleform button

		// init: turning:
		bCameraWasRotated = false;
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
			if ((lHoldOnTime - RMBPressedTime) > 0.25)
			{
				ClearTimer('RightMouseHolded');
				bCameraWasRotated = true;
				ProcessCameraRotateAround(true); // determine that we are rotating camera
			}
		}
    }

	/** Отжатие правой кнопки мыши */
	function bool RightMouseReleased()
    {
		local Vector lClickedLocation;
		local Actor lActor;

		if (!bRightMousePressed) return false; // check if mouse press was not executed
		super.RightMouseReleased();	
		if (bBlockedMouseInput) return false;
		if (bScaleformButtonClicked) // don't process click further if Scaleform GFx GUI already did
		{
			bScaleformButtonClicked = false;
			return false;
		}

		if (bCameraWasRotated)
		{
			// deinit unit turning:
			ProcessCameraRotateAround(false);
			bCameraWasRotated = false;
			RMBPressedTime = 0;
		}
		else
		{
			lActor = DoTraceActorUnderMouse(class'Actor');

			if (lActor == none) return true;

			if (lActor.IsA('xcGEO_Tile_Bases_GeoBase'))
			{
				//AircraftsReturnToBase(lActor); //  а нет это не покатит тк может быть база не этих перехватчиков! так что надо игнорить правый клик по базе. левый клик - выберет базу
				return true;
			}

			if (lActor.IsA('xcGEO_AirVehicle_Human'))
			{
				UnitsMoveToLocation(lActor.Location);
				return true;
			}

			if (lActor.IsA('X_COM_Vehicle_AirVehicle_Alien'))
			{
				UnitsAttackEnemy(X_COM_Vehicle_AirVehicle(lActor));
				return true;
			}

			lClickedLocation = DoTraceMouseLocation(class'X_COM_Tile');
			
			//if ( (SelectedUnits.Length > 0) && ((lActor.IsA('xcGEO_Tile_SolarSystem')) && (lActor.Tag == 'Planet')) || (lActor.IsA('xcGEO_Tile_Earth_Region')))
			if ( (SelectedUnits.Length > 0) && ( (lActor.IsA('xcGEO_Tile_Earth_Planet'))) )
			{
				UnitsMoveToLocation(lClickedLocation);
			}
		}
		return true;
    }

	/** Эффект указания точки в которую кликнул мышкой и в которую начал двигаться персонаж */
	function SpawnClickToTerrainEffect(Vector aLocation)
	{
		local Rotator lRotation;
		lRotation = Rotator(class'X_COM_Settings'.default.GEO_WorldCenter-aLocation);
		lRotation.Pitch += 90.0f * DegToRad * RadToUnrRot; 
		WorldInfo.MyEmitterPool.SpawnEmitter(class'X_COM_Settings'.default.ClickOnEarthEffect, aLocation, lRotation);
	}

	/** Units attacking */
	function UnitsAttackEnemy(X_COM_Unit aEnemy)
	{
		local int il;

		if (SelectedUnits.Length > 0)
		{
			for (il=0; il < SelectedUnits.Length; ++il)
			{
				xcGeo_AIController(SelectedUnits[il].Controller).StartAttackEnemy(aEnemy);		
			}
			MusicManager.ChangeTrack(EMST_music_Tactics_Action);
		}
	}

	/** Units moving */
	function UnitsMoveToLocation(Vector aLocation)
	{
		local int il;
		local Vector lMoveLocation;
		local Rotator lInitialRotation, lSingleRot;

		if (SelectedUnits.Length > 0)
		{
			lInitialRotation.Yaw = Rand(361) * DegToUnrRot; //randomize group coord within circle
			lSingleRot.Yaw = 65536 / SelectedUnits.Length; //single degree within circle for unit

			for (il=0; il < SelectedUnits.Length; ++il)
			{
				if (SelectedUnits.Length > 1)
					lMoveLocation = aLocation + Normal(Vector( lInitialRotation + (lSingleRot * (il+1)) )) * SelectedUnits[il].GetCollisionRadius() * (SelectedUnits.Length - 1);
						else lMoveLocation = aLocation;

				//lMoveLocation = lMoveLocation * (class'X_COM_Settings'.default.GEO_WorldCenter - aLocation);

				xcGeo_AIController(SelectedUnits[il].Controller).MoveToPosition(lMoveLocation);
				SpawnClickToTerrainEffect(lMoveLocation); // for every pawn
			}
		}
	}

	function UpdateRotation( float DeltaTime )
	{
		local rotator DeltaRot, ViewRotation;

		if (bRotateAround)
		{
			super.UpdateRotation(DeltaTime);
			//playerinput.ResetInput();
		}
		else
		{			
			ViewRotation=Rotation;
			DeltaRot.Yaw	= PlayerInput.aTurn;
			DeltaRot.Pitch	= PlayerInput.aLookUp;
			ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );		
		}
	}

	function PlayerMove(float DeltaTime)
	{
		local vector lViewDirection,lCenterOfRotation,lNewLocation;

		if (bCameraShouldDoZoom)
		{
			//if ( GeoDistanceFromPlanet != DesiredDistanceFromPlanet)
			if ( !class'X_COM_Defines'.static.NumbersAlmostEqual(GeoDistanceFromPlanet, DesiredDistanceFromPlanet, 10) )
			{
				if (bZoomIn)
				{		
					GeoDistanceFromPlanet -= class'X_COM_Settings'.default.GEO_ZoomStep;
				}
				if (bZoomOut)
				{
					GeoDistanceFromPlanet += class'X_COM_Settings'.default.GEO_ZoomStep;
				}
			}
			else StopZooming();
		}
		
		// main camera turning around
		UpdateRotation(DeltaTime);
		lCenterOfRotation = class'X_COM_Settings'.default.GEO_WorldCenter; // roation around center of world, maybe you can use center of your world staticmesh		
		lViewDirection=Normal(vector(Rotation)); // no create a vector from your rotation, its your View Direction...normalize it
		lNewLocation = lCenterOfRotation - (lViewDirection*GeoDistanceFromPlanet); // multiply with a distance factor, use negative viewdir (so we will look at our center point)	
		SetLocation(lNewLocation);
	}
}

//=============================================================================
// Functions: UserInterface: Time changing
//=============================================================================
function TimeChange_Pause()
{   
	//SetNewTime(1*60*60*24);
	SetNewTime(0);
}

function TimeChange_1s() // realtime
{   
	//SetNewTime(1);
	SetNewTime(1);
}

function TimeChange_1m() // 5 cek
{   
	//SetNewTime(1*60);
	SetNewTime(1*5);
}

function TimeChange_1h() // 1 min
{   
	//SetNewTime(1*60*60);
	SetNewTime(1*60);
}

function SetNewTime(int aNewTime)
{   
	mGameInfo.SetGlobalTime(aNewTime);
}

//=============================================================================
// States: state parent when selectiong something in geo
//=============================================================================
state GeoSelect extends XCOMGame
{
	ignores LeftMousePressed, LeftMouseReleased;

	function bool RightMousePressed()
    {
		if (!super.RightMousePressed()) return false; // check if other mouse button already pressed
		if (bBlockedMouseInput) return false; // check if mouse under scaleform button
		return true;
    }
}

//=============================================================================
// Functions: UserInterface: Base buttons
//=============================================================================
function CreateNewBase()
{   
	TimeChange_1s();
	EnterState_NewBaseCreation();
}

function EnterState_NewBaseCreation()
{   
	SelectedUnitsClear();
	GoToState('NewBaseCreation');
}

state NewBaseCreation extends GeoSelect
{
	function bool RightMouseReleased()
	{
		local Vector            lNewBaseLocation;
		local Rotator           lNewBaseRotation;
		local xcGEO_Tile_Bases_GeoBase	lNewBase;
		local String            lNewBaseName;

		if (!bRightMousePressed) return false; // check if mouse press was not executed
		if (bBlockedMouseInput) return false;
		super.RightMouseReleased();
		// don't process click further if Scaleform GFx GUI already did
		if (bScaleformButtonClicked)
		{
			bScaleformButtonClicked = false;
			return false;
		}

		lNewBaseLocation = DoTraceMouseLocation();	
		if (CheckNewBaseIsLocatedOnGround(lNewBaseLocation))
		{
			lNewBaseName = "NewBase"; // ToDo: window with input base name
			lNewBaseRotation = Rotator(class'X_COM_Settings'.default.GEO_WorldCenter-lNewBaseLocation);
			lNewBaseRotation.Pitch += 90.0f * DegToRad * RadToUnrRot; 
			if (BaseManager != none) BaseManager.Destroy();
			BaseManager = Spawn(Class'xcGEO_Base_Manager',,,Class'X_COM_Settings'.Default.Base_Location);
			lNewBase = BaseManager.PlaceBaseOnPlanet(lNewBaseLocation, lNewBaseRotation);
			lNewBase.BaseName = lNewBaseName;
			lNewBase.Region = ER_Russia;
			EnterInNewBase(lNewBase);
		}
		else
		{
			EnterState_Geosphere();
		}

		return true;
	}
	
	/** ToDo: checking that where we are trying to place base in sea/ocean on in earth */
	function bool CheckNewBaseIsLocatedOnGround(Vector aNewBaseLocation)
	{
		local Actor lActor;
		if (aNewBaseLocation == vect(0,0,0))
		{
			`warn(" CheckNewBaseIsLocatedOnGround() new location error ");
			return false;
		}
		lActor = DoTraceActorUnderMouse(class'X_COM_Tile');
		`log(" CheckNewBaseIsLocatedOnGround : "$lActor);
		if (lActor != none)
		{
			if (lActor.Class == class'xcGEO_Tile_Earth_Planet') return true;
		}
		else
		{
			`warn(" CheckNewBaseIsLocatedOnGround() trace error ");
			return false;
		}
	}

}

//=============================================================================
// Functions: Enter in Base functions
//=============================================================================
function EnterInNewBase(xcGEO_Tile_Bases_GeoBase aBase)
{
	BaseManager.BuildNewBase(aBase);	
	PlaceLiftAndEnergyCore();
	EnterInToBase(aBase);
}

function EnterInExistBase(xcGEO_Tile_Bases_GeoBase aBase)
{
	TimeChange_1s();
	if (BaseManager != none) BaseManager.Destroy();
	BaseManager = Spawn(Class'xcGEO_Base_Manager',self,,Class'X_COM_Settings'.Default.Base_Location);
	BaseManager.LoadExistBase(aBase);
	EnterInToBase(aBase);
}

function EnterInToBase(xcGEO_Tile_Bases_GeoBase aBase)
{
	NowInCurrentBase = aBase;
	preBaseCameraLocation = Location;
	preBaseCameraRotation = Rotation;

	GoToBaseScreen();
	xcGEO_HUD(myHud).ShowUserInterface_inBase();
	EnterState_InBase();
}

function EnterState_InBase()
{
	GoToState('inBase');
}

function GoToBaseScreen()
{
	local Vector linBaseCameraLocation; //Camera location in the x-com Base
	local Rotator linBaseCameraRotation; //Camera rotation in the x-com Base

	linBaseCameraLocation.X = Class'X_COM_Settings'.Default.Base_Size.X/2;
	linBaseCameraLocation.Z = Class'X_COM_Settings'.Default.Base_Size.X;
	linBaseCameraLocation += Class'X_COM_Settings'.Default.Base_Location;
	linBaseCameraRotation.YAW = 90.0f * DegToRad * RadToUnrRot; 
	linBaseCameraRotation.Pitch = -65.0f * DegToRad * RadToUnrRot; 

	SetLocation(linBaseCameraLocation);
	SetRotation(linBaseCameraRotation);
}

STATE inBase extends XCOMGame
{
	function bool LeftMouseReleased()
	{
		if (MouseCursorAttachment != none) 
			if (MouseCursorAttachment.bCanBePlaced) BuildBaseModule();
		return true;
	}

	function SpaceBar() //when SpaceBar pressed
	{
		if (MouseCursorAttachment != none) RotateBaseModule();
	}

	event PlayerTick(float DeltaTime)
	{
		super.PlayerTick(DeltaTime);		
		if (MouseCursorAttachment != none) ModuleMove();
	}

	/** Module movement above build ground when base cunstruction active */
	/*
	function ModuleMove()
	{
		local bool  bCanChangeLocation;
		local Vector lMouseLocation;
		lMouseLocation = DoTraceMouseLocation();
		if (lMouseLocation != vect(0,0,0))
		{
			bCanChangeLocation = _F.GetBaseGridCoord(lMouseLocation, AttachmentDimensions, ModuleSizeType, AttachmentTickLocation);
			if (bCanChangeLocation) 
				//MouseCursorAttachment.setlocation(AttachmentTickLocation);
				MouseCursorAttachment.setlocation(AttachmentTickLocation+Vect(0,0,1)*AttachmentDimensions/2); //to move new module a little upper above other placed modules
		}
	}
	*/
	/** Module movement above build ground when base cunstruction active */ //v2
	function ModuleMove()
	{		
		local Vector lMouseLocation, lOldLocation;
		lMouseLocation = DoTraceMouseLocation();
		if (lMouseLocation != vect(0,0,0))
		{
			AttachmentTickLocation = MouseCursorAttachment.GetBaseGridCoord(lMouseLocation, AttachmentDimensions);
			lOldLocation = MouseCursorAttachment.Location;
			MouseCursorAttachment.setlocation(AttachmentTickLocation+Vect(0,0,1)*AttachmentDimensions/2); //to move new module a little upper above other placed modules
			if (!MouseCursorAttachment.CheckCorrectPlacing(AttachmentDimensions, ModuleSizeType)) MouseCursorAttachment.setlocation(lOldLocation);
		}
	}
	
	/** Build base module in selected place */
	function BuildBaseModule()
	{
		MouseCursorAttachment.SetModuleState(EBMS_UnderConstruction);
		BaseManager.BuildBaseModule(MouseCursorAttachment, NowInCurrentBase.BaseID);
		MouseCursorAttachment.Destroy();
		MouseCursorAttachment = none;
	}

	/** Повернуть модуль на 90 градусов во круг его центральной оси */
	function RotateBaseModule()
	{
		local Vector lNewDimensions;
		local vector lNewLocation;
		MouseCursorAttachment.SetRotation(MouseCursorAttachment.Rotation + Rot(0,1,0)*(90.0f * DegToRad * RadToUnrRot));
		lNewDimensions.x = AttachmentDimensions.Y;
		lNewDimensions.y = AttachmentDimensions.X;
		lNewDimensions.z = AttachmentDimensions.Z;
		AttachmentDimensions = lNewDimensions;
		if (ModuleSizeType == EBMST_1x2)
		{
			lNewLocation = MouseCursorAttachment.GetBaseGridCoord(MouseCursorAttachment.Location, AttachmentDimensions);
			MouseCursorAttachment.setlocation(lNewLocation);
		}
	}

	function UpdateRotation( float DeltaTime )
	{
		local rotator DeltaRot, ViewRotation;

		if (bRotateAround)
		{
			ViewRotation=Rotation;
			DeltaRot.Yaw	= PlayerInput.aTurn;
			DeltaRot.Pitch	= 0;
			DeltaRot.Roll   = 0;
			ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
			SetRotation(ViewRotation);
		}
	}

	function PlayerMove(float aDeltaTime)
	{
		local vector lViewDirection,lCenterOfRotation,lNewLocation;

		UpdateRotation(aDeltaTime);
		
		lCenterOfRotation = class'X_COM_Settings'.default.Base_Location + class'X_COM_Settings'.default.Base_Size/2;
		lViewDirection = Normal(vector(Rotation));
		lNewLocation = lCenterOfRotation - (lViewDirection*class'X_COM_Settings'.default.Base_Size.X);
		SetLocation(lNewLocation);
	}
}

function ExitFromBase()
{
	SetLocation(preBaseCameraLocation);
	SetRotation(preBaseCameraRotation);
	
	xcGEO_HUD(myHud).ShowUserInterface_Planet();
	
	if (BaseManager != none)
	{
		BaseManager.DestroyAll();
		BaseManager = none;
	}
	NowInCurrentBase = none;
	TimeChange_1s();
	EnterState_Geosphere();
}

//=============================================================================
// Functions: UserInterface: inBase: Placing modules
//=============================================================================
function PlaceLiftAndEnergyCore()
{
	MouseCursorAttachment = Spawn(class'xcGEO_Tile_Bases_Modules',,,,Rot(0,0,0),,false);
	//MouseCursorAttachment.SetStaticMesh(StaticMesh(DynamicLoadObject("Base_xc_Modules.Meshes.xcmLaboratory_Big",class'StaticMesh')));
	MouseCursorAttachment.ModuleType = EMT_ScienceLab;
	MouseCursorAttachment.AddStaticMeshFromType();
	SetAttachmentModuleBounds();
	ModuleSizeType = EBMST_1x2;
	MouseCursorAttachment.bCanBePlaced = true;
	MouseCursorAttachment.SetModuleState(EBMS_MouseHolding);
}

function Place1tilemodule()
{
	MouseCursorAttachment = Spawn(class'xcGEO_Tile_Bases_Modules',,,,Rot(0,0,0),,false);
	MouseCursorAttachment.ModuleType = EMT_Lift;
	MouseCursorAttachment.AddStaticMeshFromType();
	SetAttachmentModuleBounds();
	ModuleSizeType = EBMST_1x1;
	MouseCursorAttachment.SetModuleState(EBMS_MouseHolding);
}

function Place2tilemodule()
{
	MouseCursorAttachment = Spawn(class'xcGEO_Tile_Bases_Modules',,,,Rot(0,0,0),,false);
	MouseCursorAttachment.ModuleType = EMT_ScienceLab;
	MouseCursorAttachment.AddStaticMeshFromType();
	SetAttachmentModuleBounds();
	ModuleSizeType = EBMST_1x2;
	MouseCursorAttachment.SetModuleState(EBMS_MouseHolding);
	
}

function Place4tilemodule()
{
	MouseCursorAttachment = Spawn(class'xcGEO_Tile_Bases_Modules',,,,Rot(0,0,0),,false);
	MouseCursorAttachment.ModuleType = EMT_Angar;
	MouseCursorAttachment.AddStaticMeshFromType();
	SetAttachmentModuleBounds();
	ModuleSizeType = EBMST_2x2;	
	MouseCursorAttachment.SetModuleState(EBMS_MouseHolding);
}

function SetAttachmentModuleBounds()
{
	local Box Bounds;
	MouseCursorAttachment.GetComponentsBoundingBox(Bounds);
	AttachmentDimensions = Bounds.Max - Bounds.Min - vect(2,2,2);	
}

//=============================================================================
// Functions: UserInterface: inBase : Aircrafts screen
//=============================================================================
function Open_AircraftsManagement()
{   
	if (AircraftsManager != none) AircraftsManager.Destroy();
	AircraftsManager = Spawn(class'xcGEO_Base_Aircrafts_Manager', self, 'HangarManager', Class'X_COM_Settings'.Default.Hangar_Location);
	AircraftsManager.InitAircraftsManager();

	GoToAircraftsManagementScreen();
	xcGEO_HUD(myHud).ShowUserInterface_inBase_Aircrafts();
	EnterState_AircraftsManagements();
}

function GoToAircraftsManagementScreen()
{
	local Vector lAircraftsManagementCameraLocation; //Camera location in the x-com Base AircraftsManagement
	local Rotator lAircraftsManagementCameraRotation; //Camera rotation in the x-com Base AircraftsManagement

	lAircraftsManagementCameraLocation = Class'X_COM_Settings'.Default.Hangar_Camera_Location;
	lAircraftsManagementCameraRotation.Pitch = Class'X_COM_Settings'.Default.Hangar_Camera_Rotation.Pitch * DegToRad * RadToUnrRot; 
	lAircraftsManagementCameraRotation.YAW = Class'X_COM_Settings'.Default.Hangar_Camera_Rotation.Yaw * DegToRad * RadToUnrRot; 

	SetLocation(lAircraftsManagementCameraLocation);
	SetRotation(lAircraftsManagementCameraRotation);
}

function EnterState_AircraftsManagements()
{   
	GoToState('AircraftsManagements');
}

state AircraftsManagements extends Spectating //XCOMGame //Spectating //XCOMEmptyState
{

}

function ExitFromAircraftsManagement()
{
	if (AircraftsManager != none) 
	{
		AircraftsManager.DestroyAll();
		AircraftsManager = none;
	}
	xcGEO_HUD(myHud).ShowUserInterface_inBase();
	GoToBaseScreen(); //return to base mode
	EnterState_InBase();
}

//=============================================================================
// Functions: UserInterface: Interceprors
//=============================================================================
function ShowInterceptors()
{   
	TimeChange_1s();
	EnterState_Interception();
}

function EnterState_Interception()
{   
	GoToState('Interception');
}

state Interception extends GeoSelect
{
    function bool RightMouseReleased()
	{
		local Vector            lLocation;
		local Rotator           lRotation;
		local Vector            lWorldCenter;
		local X_COM_Vehicle_AirVehicle	lVehicle;
		local xcGEO_GameInfo    lGameInfo;



		if (!bRightMousePressed) return false; // check if mouse press was not executed
		super.RightMouseReleased();
		if (bBlockedMouseInput) return false;
		// don't process click further if Scaleform GFx GUI already did
		if (bScaleformButtonClicked)
		{
			bScaleformButtonClicked = false;
			return false;
		}

		lGameInfo = xcGEO_GameInfo(WorldInfo.Game);
		lWorldCenter = class'X_COM_Settings'.default.GEO_WorldCenter;

		lLocation = DoTraceMouseLocation(class'X_COM_Tile');	
		lLocation = lWorldCenter - Normal(lWorldCenter - lLocation) * class'X_COM_Settings'.default.GEO_FlyingDistanceFromPlanet;
		lRotation = Rotator(class'X_COM_Settings'.default.GEO_WorldCenter-lLocation);
		lRotation.Pitch += 90.0f * DegToRad * RadToUnrRot;

		lVehicle = Spawn(class'X_COM_Settings'.default.HumanAirVehicles[EHAV_Buran].Class,,,lLocation,lRotation,class'X_COM_Settings'.default.HumanAirVehicles[EHAV_Buran], false); //нужно переделать на передачу типа самолета и количества их
		
		if (lVehicle!=none)
		{
			//lVehicle.ChangeController(class'xcGEO_AIController_Human');

			lVehicle.StartEngine();

			lVehicle.CreateInventoryFromTemplate(class'X_COM_Settings'.default.WeaponAirVehicles[EAVW_CicadaMissile]);
			X_COM_InventoryManager(lVehicle.InvManager).InventoryChainLast.ActivateItem('Rocket_L');
			lVehicle.CreateInventoryFromTemplate(class'X_COM_Settings'.default.WeaponAirVehicles[EAVW_CicadaMissile]);
			X_COM_InventoryManager(lVehicle.InvManager).InventoryChainLast.ActivateItem('Rocket_R');
			lVehicle.CreateInventoryFromTemplate(class'X_COM_Settings'.default.WeaponAirVehicles[EAVW_LaserBeam]);
			X_COM_InventoryManager(lVehicle.InvManager).InventoryChainLast.ActivateItem('Weapon_L');
			lVehicle.CreateInventoryFromTemplate(class'X_COM_Settings'.default.WeaponAirVehicles[EAVW_LaserBeam]);
			X_COM_InventoryManager(lVehicle.InvManager).InventoryChainLast.ActivateItem('Weapon_R');
		
			lVehicle.NumericalId = ++lGameInfo.LastVehicleNumericalId; //Add last ID

			SelectPlayerUnit(lVehicle);
		}
		else `warn("ERROR::in spawn air vehicle");

		TimeChange_1s();
		EnterState_Geosphere();

		return true;
	}
}

function InterceptorsFire()
{   
	TimeChange_1s();
	GoToState('InterceptorsAttacking');
}

state InterceptorsAttacking extends GeoSelect
{
	function bool RightMouseReleased()
    {
		local Actor lActor;
		local int   il;

		if (!bRightMousePressed) return false; // check if mouse press was not executed
		super.RightMouseReleased();
		if (bBlockedMouseInput) return false;
		// don't process click further if Scaleform GFx GUI already did
		if (bScaleformButtonClicked)
		{
			bScaleformButtonClicked = false;
			return false;
		}

		lActor = DoTraceActorUnderMouse(class'Actor');

		if (lActor.IsA('X_COM_Vehicle_AirVehicle'))
		{
			if (SelectedUnits.Length > 0)
			{
				for (il=0; il < SelectedUnits.Length; ++il)
				{
					xcGEO_AIController_Human(SelectedUnits[il].Controller).StartAttackEnemy(X_COM_Unit(lActor));			
				}
			}		
		}

		MusicManager.ChangeTrack(EMST_music_Geo_Fight);

		TimeChange_1s();
		EnterState_Geosphere();

		return true;
	}
}

//=============================================================================
// Alien Events Controlls
//=============================================================================
protected function SelectAlienEvent(X_COM_Tile_AlienEvent aEvent)
{
	TimeChange_1s();
	ActiveAlienEvent = aEvent;
	GoToState('ScrollingToAlienEvent');
}

state ScrollingToAlienEvent extends Geosphere
{
	//function PlayerMove(float DeltaTime)
 //   {
 //       local vector X,Y,Z;
	//	local vector lViewDirection, lCenterOfRotation, lNewLocation;
      
 //       GetAxes(Rotation,X,Y,Z);

	//	UpdateRotation(DeltaTime);
	//	lCenterOfRotation = class'X_COM_Settings'.default.GEO_WorldCenter; // roation around center of world, maybe you can use center of your world staticmesh		
	//	lViewDirection=Normal(vector(Rotation)); // no create a vector from your rotation, its your View Direction...normalize it
	//	lNewLocation = lCenterOfRotation - (lViewDirection*GeoDistanceFromPlanet); // multiply with a distance factor, use negative viewdir (so we will look at our center point)	
	//	SetLocation(lNewLocation);
	//}

	function UpdateRotation( float DeltaTime )
	{
		local Rotator	DeltaRot, newRotation, ViewRotation;

		if (!bCanAutoScroll) return;

		ViewRotation = Rotation;

		// Calculate Delta to be applied on ViewRotation


		//DeltaRot = rlerp(Rotator(Location), Rotator(AutoScrollLocation), RotateStep, true);

		DeltaRot = Rotator(Normal(Location + Normal(Location-AutoScrollLocation)*300)* class'X_COM_Settings'.default.GEO_FlyingDistanceFromPlanet);

		//ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
		SetRotation(DeltaRot);

		///ViewShake( deltaTime );

		//NewRotation = ViewRotation;
		//NewRotation.Roll = Rotation.Roll;
	}

	function bool LocationReached(vector aLoc)
	{
		return class'X_COM_Defines'.static.VectorsAlmostEqual(Location, aLoc, 100);
	}

	function vector CalcFinalLocation()
	{
		local vector lWorldCenter;
		
		lWorldCenter = class'X_COM_Settings'.default.GEO_WorldCenter;

		return lWorldCenter - Normal(lWorldCenter - ActiveAlienEvent.Location) * GeoDistanceFromPlanet;
	}

begin:
	AutoScrollLocation = CalcFinalLocation();
	RotateStep = 0.0;
	bCanAutoScroll = true;

scroling: // 1. Scroll screen to center of event
	if ( !LocationReached(AutoScrollLocation) )
	{
		RotateStep += 0.1;
		bCanAutoScroll = true;
		sleep(worldinfo.DeltaSeconds);
		goto('scroling');
	}
	else bCanAutoScroll = false;

message: // 2. Show info screen about alien event. TODO LATER
	
end:
	TimeChange_1s();
	EnterState_Geosphere();
}

//=============================================================================
// Defaultproperties
//=============================================================================
defaultproperties
{
	bDoAircraftSelection = FALSE
	bDragging = FALSE
	bWasDragged = FALSE

	InputClass=class'X-COM_GEO.xcGEO_PlayerInput'
    Name="Default__xcGEO_PlayerController"
}
