class X_COM_HUD extends UDKHUD;

//=============================================================================
// Variables:
//=============================================================================
var protected X_COM_PlayerController                  xcPC;
var protected X_COM_GameInfo                          xcGameinfo;
var protected X_COM_GFx_Menu		                  Main_HUD;
var protected X_COM_GFx_Menu				          MainMenuMovie; // Main menu.

var public X_COM_GFx_MouseCursor		    MouseCursor; // Mouse Cursor
var public vector                           MouseLocation, MouseDirection; //Deprojection
var public Vector2D                         ViewportSize, ScreenCenter; // Screen size and Screen Center coordinates

//=============================================================================
// Functions
//=============================================================================
simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	xcPC = X_COM_PlayerController(PlayerOwner);
	xcGameinfo = X_COM_GameInfo(WorldInfo.Game);

	CreateMouseCursor();
	ShowMainUserInterface();
	GetViewportSizeAndCenter();
}

/** Shows main user interface. will be used in child classes */
protected function ShowMainUserInterface()
{
	MainMenuMovie = new class'X_COM_GFx_MainMenu';
	MainMenuMovie.InitUI(self);
	MainMenuMovie.SetViewScaleMode( SM_ExactFit );
	MainMenuMovie.SetAlignment( Align_Center );
	X_COM_GFx_MainMenu(MainMenuMovie).OpenGameMenu();
}

/** Shows/hides menu by pressing ESC. will be used in child classes */
exec function ShowMainMenu();

event PostRender()
{
	super.PostRender();
	Cursor_Deprojection();
	UpdateMouseCursor();
	
	// Debug : 
	DrawDebug();
}

function DrawDebug()
{ 
	local Actor lActor;

	lActor = xcPC.DoTraceActorUnderMouse(class'Actor');
	
	if (lActor != none) 
	{
			DrawSurfaceInfo(lActor);
			if (lActor.isA('X_COM_Unit')) DrawPawnInfo(lActor);
	}
}

function DrawPawnInfo(Actor aActor);

function DrawSurfaceInfo(Actor aActor)
{
	local string lText;

	Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.Font = class'Engine'.Static.GetSmallFont();

	lText = " Actor: "$aActor;
	Canvas.SetPos(Canvas.ClipX/1.5, 30);
	Canvas.DrawText(lText);

	lText = " Actor.Class : "$aActor.Class;
	Canvas.SetPos(Canvas.ClipX/1.5, 50);
	Canvas.DrawText(lText);

	lText = " Actor.Location : "$aActor.Location;
	Canvas.SetPos(Canvas.ClipX/1.5, 70);
	Canvas.DrawText(lText);
}

protected function UpdateMouseCursor()
{
	local Vector2d lmousePos;
	
	lmousePos = GetMouseCoordinates();
	MouseCursor.SetFlashMousePosition(lmousePos.X, lmousePos.Y);
}

private function Cursor_Deprojection()
{
	if (MouseCursor != none) Canvas.DeProject(GetMouseCoordinates(), MouseLocation, MouseDirection); 
}

private function CreateMouseCursor()
{
	MouseCursor = new class'X_COM_GFx_MouseCursor';
	MouseCursor.Init( LocalPlayer(xcPC.Player) );
	MouseCursor.SetViewScaleMode( SM_ExactFit );
	MouseCursor.SetAlignment( Align_Center );
	MouseCursor.SetPriority(100); //highest layer
}

/** Used for get Screen size and Screen Center coordinates */
function GetViewportSizeAndCenter()
{
	local Vector2D lViewportSize;
	lViewportSize = MouseCursor.GetViewportSize();
	ViewportSize = lViewportSize;
	ScreenCenter = lViewportSize/2;
}

/** Absolute mouse coordinates from UDK engine viewport */
function Vector2d GetMouseCoordinates()
{
  local Vector2d lMousePos;

  lMousePos = LocalPlayer(PlayerOwner.Player).ViewportClient.GetMousePosition();

  return lMousePos;
}

simulated event Destroyed()
{
	Super.Destroyed();

	if( MouseCursor != none )
	{
		MouseCursor.Close( true );
		MouseCursor = none;
	}
}

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
	Name="Default__X_COM__HUD"
}