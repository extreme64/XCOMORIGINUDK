/**
 * X-COM PlayerController. Main PlayerController class.
 * Uses as parent class for other PlayerControllers and has public functions.
 */
class X_COM_PlayerController extends UDKPlayerController
	config(XCOM);

//=============================================================================
// Variables: General
//=============================================================================
var bool                        bRotateAround; // Camera YAW rotation permission
var bool 	                    bZoomIn, bZoomOut; // Camera Zoom in and Zoom out permissions

var X_COM_GFx_MainMenu          MainMenuMovie; // Main menu.

var X_COM_MusicManager          MusicManager;

/** Vibration  */
var ForceFeedbackWaveform       CameraShakeShortWaveForm, CameraShakeLongWaveForm;

var protected array<X_COM_Unit>           SelectedUnits;
var protected array<X_COM_Unit>           AllUnits;

var protected bool              bBlockedMouseInput; //if mouse if over HUD button them world mouse click is blocked\

/** Whether the left mouse button is currently being pressed or not. */
var bool bLeftMousePressed;

/** Whether the middle mouse button is currently being pressed or not. */
var bool bMiddleMousePressed;

/** Whether the right mouse button is currently being pressed or not. */
var bool bRightMousePressed;

/** Whether the last mouse click has been processed by the Scaleform GFx GUI and should not be passed to the engine. */
var bool bScaleformButtonClicked;

//=============================================================================
// Functions: General
//=============================================================================
simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	saveconfig(); //replace with load config later

	if (MusicManager == None) 
	{
		MusicManager = Spawn(class'X_COM_MusicManager', self);
		//if (MusicManager != None) PlayMusic();
	}
}

simulated event Destroyed()
{
	Super.Destroyed();

	if (MusicManager != None)
	{
		MusicManager.Destroy();
	}
}

event InitInputSystem()
{
	Super.InitInputSystem();
	CharacterProcessingComplete(); //stop loading movie, which is playing while level is loading
}

/** stop the loading movie that was up during precaching */
function CharacterProcessingComplete()
{
	local string LastMovie;

	LastMovie = class'Engine'.Static.GetLastMovieName();

	if(InStr(LastMovie, "UT_loadmovie") != -1)
	{
		class'Engine'.static.StopMovie(true);
	}
}

/** Start to play main level music*/
function PlayMusic()
{
	MusicManager.ChangeTrack(EMST_music_MainMenu);
}

/** Trace mouse location in 3D world.  */
function vector DoTraceMouseLocation(optional class<Actor> aBaseClass, optional class<Actor> aIgnoreClass)
{
	local Vector lHitLocation, lHitNormal;
	local Vector lTraceStart, lTraceEnd, lTraceDir, lTraceExtent;
	local Actor lActor;

	lTraceExtent = vect(1,1,1);

	lTraceStart = X_COM_Hud(myHud).MouseLocation;
	lTraceDir = X_COM_Hud(myHud).MouseDirection;
	lTraceEnd = lTraceStart + 32768*lTraceDir;

	if (aBaseClass != none)
	{
		ForEach TraceActors(aBaseClass, lActor, lHitLocation, lHitNormal, lTraceEnd, lTraceStart) 
		{
			if ((lActor != none) && (lActor.Class != aIgnoreClass))
			{
				break;	
			}
		}
	}
	else Trace( lHitLocation, lHitNormal, lTraceEnd, lTraceStart, true, lTraceExtent);

	return lHitLocation;
}

function Actor DoTraceActorUnderMouse(class<Actor> aBaseClass)
{
	local Vector lHitLocation, lHitNormal;
	local Vector lTraceStart, lTraceEnd, lTraceDir;	
	local Actor lActor;

	lTraceStart = X_COM_Hud(myHud).MouseLocation;
	lTraceDir = X_COM_Hud(myHud).MouseDirection;
	lTraceEnd = lTraceStart + 32768*lTraceDir;

	ForEach TraceActors(aBaseClass, lActor, lHitLocation, lHitNormal, lTraceEnd, lTraceStart) 
	{
		if(lActor != none)
		{
			return lActor;			
		}
	}
	return none;
}

/** Empty sate**/
AUTO STATE XCOMEmptyState
{
	ignores SeePlayer, SeeMonster, HearNoise, NotifyBump, TakeDamage, PhysicsVolumeChange, SwitchToBestWeapon;
}

/** Public functions for child states in GEO and Tactics controllers**/
STATE XCOMGame extends XCOMEmptyState
{
	function bool MiddleMousePressed() //Rotate around earth in GEO and aroud self in Tactics
    {
		ProcessCameraRotateAround(true);
		return global.MiddleMousePressed();
    }

    function bool MiddleMouseReleased() //Stop rotation around
    {	
		ProcessCameraRotateAround(false);
		return global.MiddleMouseReleased();
    }

	protected function ProcessCameraRotateAround(bool bRotate)
	{
		if (bRotate)
		{
			bRotateAround=true;
			X_COM_Hud(myHud).MouseCursor.DrawRotatedCursor(true);
		}
		else
		{
			bRotateAround=false;
			X_COM_Hud(myHud).MouseCursor.DrawRotatedCursor(false);
			//playerinput.ResetInput();
		}
	}
}

//=============================================================================
// Functions: Mouse blocking click throught user interface to world
//=============================================================================
simulated public function SetBlockMouseInput(bool bBlock)
{
	bBlockedMouseInput = bBlock;
}

/** Notifies this player controller that the last mouse click has been processed by the Scaleform GFx GUI and should not be processed by the engine. */
simulated public function NotifyScaleformButtonClicked(bool bClicked)
{
	bScaleformButtonClicked = bClicked;
}

//=============================================================================
// Functions: Keyboard buttons
//=============================================================================
function SpaceBar();

public function ZoomIn(); //Zoom in
public function ZoomOut(); //Zoom out


//=============================================================================
// Functions: Mouse buttons interaction
//=============================================================================
function bool LeftMousePressed()
{
	if (bRightMousePressed || bMiddleMousePressed) return false;
	else
	{
		bLeftMousePressed = true;
		return true;
	}
}

function bool LeftMouseReleased()
{
	bLeftMousePressed = false;
	return true;
}

function bool RightMousePressed()
{
	if (bLeftMousePressed || bMiddleMousePressed) return false;
	else
	{
		bRightMousePressed = true;
		return true;
	}
}

function bool RightMouseReleased()
{
	bRightMousePressed = false;
	return true;
}

function bool MiddleMousePressed()
{
	if (bRightMousePressed || bLeftMousePressed) return false;
	else
	{
		bMiddleMousePressed = true;
		return true;
	}
}

function bool MiddleMouseReleased()
{
	bMiddleMousePressed = false;
	return true;
}

//=============================================================================
// Functions: Camera
//=============================================================================
/** plays the specified camera animation with the specified weight (0 to 1)
 * local client only
 */
function PlayCameraAnim( CameraAnim AnimToPlay, optional float Scale=1.f, optional float Rate=1.f,
			optional float BlendInTime, optional float BlendOutTime, optional bool bLoop, optional bool bIsDamageShake )
{
	local Camera MatineeAnimatedCam;

	//bCurrentCamAnimAffectsFOV = false;

	// if we have a real camera, e.g we're watching through a matinee camera,
	// send the CameraAnim to be played there
	MatineeAnimatedCam = PlayerCamera;
	if (MatineeAnimatedCam != None)
	{
		MatineeAnimatedCam.PlayCameraAnim(AnimToPlay, Rate, Scale, BlendInTime, BlendOutTime, bLoop, FALSE);
	}
	else if (CameraAnimPlayer != None)
	{
		// play through normal UT camera
		CamOverridePostProcess = class'CameraActor'.default.CamOverridePostProcess;
		CameraAnimPlayer.Play(AnimToPlay, self, Rate, Scale, BlendInTime, BlendOutTime, bLoop, false);
	}

	// Play controller vibration - don't do this if damage, as that has its own handling
	if( !bIsDamageShake && !bLoop && WorldInfo.NetMode != NM_DedicatedServer )
	{
		if( AnimToPlay.AnimLength <= 1 )
		{
			ClientPlayForceFeedbackWaveform(CameraShakeShortWaveForm);
		}
		else
		{
			ClientPlayForceFeedbackWaveform(CameraShakeLongWaveForm);
		}
	}

	//bCurrentCamAnimIsDamageShake = bIsDamageShake;
}

/** Stops the currently playing camera animation. */
function StopCameraAnim(optional bool bImmediate)
{
	if (CameraAnimPlayer != None)
	{
		CameraAnimPlayer.Stop(bImmediate);
	}
}

/** Allows changing camera anim strength on the fly */
function SetCameraAnimStrength(float NewStrength)
{
	if ( CameraAnimPlayer != None )
	{
		CameraAnimPlayer.BasePlayScale = NewStrength;
	}
}

unreliable client event ClientPlayCameraAnim( CameraAnim AnimToPlay, optional float Scale=1.f, optional float Rate=1.f,
											 optional float BlendInTime, optional float BlendOutTime, optional bool bLoop,
											 optional bool bRandomStartTime, optional ECameraAnimPlaySpace Space=CAPS_CameraLocal, optional rotator CustomPlaySpace )
{
	PlayCameraAnim(AnimToPlay, Scale, Rate, BlendInTime, BlendOutTime, bLoop);
}

reliable client event ClientStopCameraAnim(CameraAnim AnimToStop, optional bool bImmediate)
{
	StopCameraAnim(bImmediate);
}

function OnPlayCameraAnim(X_COM_SeqAct_PlayCameraAnim InAction)
{
	ClientPlayCameraAnim(InAction.AnimToPlay, InAction.IntensityScale, InAction.Rate, InAction.BlendInTime, InAction.BlendOutTime);
}

function OnStopCameraAnim(X_COM_SeqAct_StopCameraAnim InAction)
{
	ClientStopCameraAnim(CameraAnimPlayer.CamAnim);
}


/** Sets ShakeOffset and ShakeRot to the current view shake that should be applied to the camera */
function ViewShake(float DeltaTime)
{
	if (CameraAnimPlayer != None && !CameraAnimPlayer.bFinished)
	{
		// advance the camera anim - the native code will set ShakeOffset/ShakeRot appropriately
		CamOverridePostProcess = class'CameraActor'.default.CamOverridePostProcess;
		CameraAnimPlayer.AdvanceAnim(DeltaTime, false);
	}
	else
	{
		ShakeOffset = vect(0,0,0);
		ShakeRot = rot(0,0,0);
	}
}

/** Эффект указания точки в которую кликнул мышкой и в которую начал двигаться персонаж. В ГЕО переопределено! */
function SpawnClickToTerrainEffect(Vector aLocation)
{
	WorldInfo.MyEmitterPool.SpawnEmitter(class'X_COM_Settings'.default.ClickToTerrainEffect, aLocation, rot(0,0,0));
}

//=============================================================================
// Functions: Units tasks
//=============================================================================
/** UI-function. Select all player units in map */
function SelectAllUnits()
{
	local int il;

	if (AllUnits.Length <= 0) return;
	SelectedUnitsClear();
	for (il=0; il < AllUnits.Length; ++il)
	{
		SelectPlayerUnit(AllUnits[il]);
	}
}

/** Input-function. Select next friend unit */
function SelectNextUnit()
{
	local int lNextIndex, il;

	if (AllUnits.Length <= 1) return;
	if (SelectedUnits.Length == 1)
	{
		for (il=0; il < AllUnits.Length; ++il)
		{
			if (AllUnits[il] == SelectedUnits[0]) 
			{
				lNextIndex = il + 1;
				if (lNextIndex >= AllUnits.Length)
				{
					lNextIndex = 0;
				}
				break;
			}
		}
	}
	else
	{
		lNextIndex = 0;
	}
	SelectedUnitsClear();

	SelectPlayerUnit(AllUnits[lNextIndex]);
	AttachCameraTo(AllUnits[lNextIndex]);
}

function SelectedUnitsClear()
{
	local int il;

	if (SelectedUnits.Length > 0)
	{
		for (il=0; il < SelectedUnits.Length; ++il)
		{		
			SelectedUnits[il].ShowSelectedEffect(false);
			SelectedUnits[il].bIsSelected = false;
		}
		SelectedUnits.Remove(0, SelectedUnits.Length);
		//if (ClicktoTerrainEffect != none) ClicktoTerrainEffect.Destroy(); // Убираем эффект показа точки куда движется персонаж если он есть
	}
}

function SelectedUnitsRemoveUnit(X_COM_Unit aSelectedUnit)
{
	SelectedUnits.RemoveItem(aSelectedUnit);
	aSelectedUnit.ShowSelectedEffect(false);
	aSelectedUnit.bIsSelected = false;
	//if (SelectedUnits.Length <= 0) if (ClicktoTerrainEffect != none) ClicktoTerrainEffect.Destroy();
}

/** Select clicked unit (pawn or vehicle) */
function SelectPlayerUnit(X_COM_Unit aNewUnit)
{
	SelectedUnits.AddItem(aNewUnit);
	aNewUnit.bIsSelected = true;
	aNewUnit.ShowUnitSelectingEffect();
	aNewUnit.ShowSelectedEffect(true);
}

public function array<X_COM_Unit> GetSelectedUnits()
{
	return SelectedUnits;
}

public function array<X_COM_Unit> GetAllUnits()
{
	return AllUnits;
}

public function AllUnitsRemoveUnit(X_COM_Unit aUnit)
{
	AllUnits.RemoveItem(aUnit);
}

public function AllUnitsAddUnit(X_COM_Unit aUnit)
{
	AllUnits.AddItem(aUnit);
}

function AttachCameraTo(Actor ThisActor);

//=============================================================================
// Default Properties
//=============================================================================
defaultproperties
{
	bKillDuringLevelTransition = TRUE
	bRotateAround = FALSE
	bZoomIn = FALSE
    bZoomOut = FALSE

	bGodMode = TRUE

    Name="Default__X_COM_PlayerController"

	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveform7
		Samples(0)=(LeftAmplitude=60,RightAmplitude=50,LeftFunction=WF_LinearDecreasing,RightFunction=WF_LinearDecreasing,Duration=0.200)
	End Object
	CameraShakeShortWaveForm=ForceFeedbackWaveform7

	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveform8
		Samples(0)=(LeftAmplitude=60,RightAmplitude=50,LeftFunction=WF_LinearDecreasing,RightFunction=WF_LinearDecreasing,Duration=0.400)
	End Object
	CameraShakeLongWaveForm=ForceFeedbackWaveform8
}
