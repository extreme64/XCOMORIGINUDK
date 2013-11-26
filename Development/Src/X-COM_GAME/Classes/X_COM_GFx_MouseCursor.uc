/**
 * X-COM mouse class
 */
class X_COM_GFx_MouseCursor extends GFxMoviePlayer;

//=============================================================================
// Variables
//=============================================================================
var private vector2D ViewportSize;
var private float RealScaleX, RealScaleY;

//=============================================================================
// Functions: General
//=============================================================================
function Init(optional LocalPlayer LocPlay)
{
	super.Init(LocPlay);
	Start();
	Advance(0.f);
	GetScreenParams();
	SetMouseCursorToScreenCenter();
}

//=============================================================================
// Functions: General
//=============================================================================
public function vector2D GetViewportSize()
{
	return ViewportSize;
}

private function GetScreenParams()
{
	local float lx0, lx1, ly0, ly1;

	GetGameViewportClient().GetViewportSize(ViewportSize);
	GetVisibleFrameRect(lx0, ly0, lx1, ly1);

	lx0 = abs(lx0);
	ly0 = abs(ly0);
	lx1 = abs(lx1);
	ly1 = abs(ly1);

	RealScaleX = ViewportSize.X / (lx1 - lx0);
	RealScaleY = ViewportSize.Y / (ly1 - ly0);
}

//=============================================================================
// Functions: ActionScript functions calls
//=============================================================================
private function UpdateCursorPosition(float X, float Y)
{
	ActionScriptVoid("UpdateCursorPosition");
}

public function DrawRotatedCursor(bool bRotating)
{
	SetMouseCursorToScreenCenter();
	ActionScriptVoid("DrawRotatedCursor");
}

public function ShowMouseCursor(bool bShow)
{
	SetMouseCursorToScreenCenter();
	ActionScriptVoid("ShowMouseCursor");
}

//=============================================================================
// Functions: Mouse set
//=============================================================================
public function SetMousePosition(float X, float Y)
{
	GetGameViewportClient().SetMouse(X, Y);
	GetGameViewportClient().ForceUpdateMouseCursor(TRUE);
}

public function SetFlashMousePosition(float X, float Y)
{
	local Vector2D lMousePos;
	lMousePos.X = X/RealScaleX;
	lMousePos.Y = Y/RealScaleY;
	UpdateCursorPosition(lMousePos.X, lMousePos.Y);
}

public function SetMouseCursorToScreenCenter()
{
	SetMousePosition(ViewportSize.X/2, ViewportSize.Y/2);
	SetFlashMousePosition(ViewportSize.X/2, ViewportSize.Y/2);
}

//=============================================================================
// Default Properties:
//=============================================================================
DefaultProperties
{
	// The path to the swf asset
	MovieInfo = SwfMovie'X-COM_UI.MouseCursor'

	bIgnoreMouseInput = FALSE // this determines whether the mouse is captured or not
    bCaptureInput = FALSE

	bPauseGameWhileActive = FALSE // do you want your game paused when this is open? //overriden in menu type selection

    bDisplayWithHudOff = FALSE // do you want the HUD displayed while this is open?

    TimingMode=TM_Real
}