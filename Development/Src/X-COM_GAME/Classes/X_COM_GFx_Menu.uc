class X_COM_GFx_Menu extends GFxMoviePlayer;

//=============================================================================
// Variables
//=============================================================================
var protected X_COM_HUD					myHUD;
var protected X_COM_GameInfo			myGameInfo;
var protected X_COM_PlayerController	myPlayerController;

//=============================================================================
// Functions: init
//=============================================================================
public function InitUI(X_COM_HUD amyHUD)
{
	myHUD = amyHUD;
	myGameInfo = X_COM_GameInfo(amyHUD.WorldInfo.game);
	myPlayerController = X_COM_PlayerController(amyHUD.PlayerOwner);
	Start();
	Advance(0.f);
}

// if started from kismet then find gameinfo reference
function bool Start(optional bool startpaused)
{
	if (myGameInfo == none) myGameInfo = X_COM_GameInfo(GetPC().WorldInfo.Game);
	if (myPlayerController == none) myPlayerController = X_COM_PlayerController(GetPC());
	return super.Start(startpaused);
}

//=============================================================================
// Functions: Buttons
//=============================================================================
function CallMouseDown(int button) {ActionScriptVoid("_root.MouseDown");}
function CallMouseUp(int button) {ActionScriptVoid("_root.MouseUp");}

protected function BTN_RollOver(string aButtonName)
{
	myPlayerController.SetBlockMouseInput(true);
}

protected function BTN_RollOut(string aButtonName)
{
	myPlayerController.SetBlockMouseInput(false);
}

protected function BTN_Pressed(string aButtonName)
{
	myPlayerController.NotifyScaleformButtonClicked(true);
}

protected function BTN_Released(string aButtonName)
{
	myPlayerController.NotifyScaleformButtonClicked(false);
}

//=============================================================================
// Default Properties:
//=============================================================================
DefaultProperties
{
	bIgnoreMouseInput = TRUE // this determines whether the mouse is captured or not
    bCaptureInput = TRUE

	bPauseGameWhileActive = FALSE // do you want your game paused when this is open? //overriden in menu type selection

    bDisplayWithHudOff = FALSE // do you want the HUD displayed while this is open?

    TimingMode=TM_Real

    // Sound Mapping
    SoundThemes(0)=(ThemeName=default,Theme=UISoundTheme'UDKFrontEnd.Sound.SoundTheme')
}