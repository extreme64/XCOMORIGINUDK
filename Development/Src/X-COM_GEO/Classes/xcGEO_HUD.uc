class xcGEO_HUD extends X_COM_HUD;

//=============================================================================
// Variables: HUD
//=============================================================================
var xcGEO_GFx_HUD_Planet		            HUD_Planet;
var xcGEO_GFx_HUD_inBase		            HUD_inBase;
var xcGEO_GFx_HUD_inBase_Aircrafts		    HUD_inBase_Aircrafts;

//=============================================================================
// Variables: HUD: Прямоугольное выделение
//=============================================================================
var bool                                bDragging; // Разрешает рисование прямоугольника выделения в худе
var bool								bWasDragged; //Определение, тянули ли мы прямоугольник выделения
var float								DraggDeltaTime; //Время которое мы тянули прямоугольник выделения
var Vector2D							StartOfDragg, EndOfDragg; //Координаты начала и конца прямоугольника выделения
var bool								bDoAircraftSelection; //Разрешает делать проекцию из 3Д в 2Д в кадре HUD для выбора выделенных самолетов

//=============================================================================
// PostRender
//=============================================================================
event PostRender()
{
	super.PostRender();
	DrawDragBox();
	DrawDebugMessages();
}

//=============================================================================
// Functions: Main menu
//=============================================================================
/** Shows/hides menu by pressing ESC*/
exec function ShowMainMenu()
{   
	if (MainMenuMovie == none)
	{
		MainMenuMovie = new class'X_COM_GFx_MainMenu';
		MainMenuMovie.InitUI(self);
		MainMenuMovie.SetViewScaleMode( SM_ExactFit );
		MainMenuMovie.SetAlignment( Align_Center );
		X_COM_GFx_MainMenu(MainMenuMovie).OpenGameMenu();
		Worldinfo.game.SetPause(xcPC);
	} 
	else 
	{
		MainMenuMovie.Close();
		MainMenuMovie = none;
		Worldinfo.game.ClearPause();
	}
}

//=============================================================================
// Functions: interfaces
//=============================================================================
protected function ShowMainUserInterface()
{
	ShowUserInterface_Planet();
}

public function ShowUserInterface_Planet()
{   
	CloseAllUserInterfaces();
	if (HUD_Planet == none)
	{
		HUD_Planet = new class'xcGEO_GFx_HUD_Planet';
		HUD_Planet.InitUI(self);
		HUD_Planet.SetViewScaleMode( SM_ExactFit );
		HUD_Planet.SetAlignment( Align_Center );
	}
	Main_HUD = HUD_Planet;
}

public function ShowUserInterface_inBase()
{
	CloseAllUserInterfaces();
	if (HUD_inBase == none)
	{
		HUD_inBase = new class'xcGEO_GFx_HUD_inBase';
		HUD_inBase.InitUI(self);
		HUD_inBase.SetViewScaleMode( SM_ExactFit );
		HUD_inBase.SetAlignment( Align_Center );	
	}
	Main_HUD = HUD_inBase;
}

public function ShowUserInterface_inBase_Aircrafts()
{
	CloseAllUserInterfaces();
	if (HUD_inBase_Aircrafts == none)
	{
		HUD_inBase_Aircrafts = new class'xcGEO_GFx_HUD_inBase_Aircrafts';
		HUD_inBase_Aircrafts.InitUI(self);
		HUD_inBase_Aircrafts.SetViewScaleMode( SM_ExactFit );
		HUD_inBase_Aircrafts.SetAlignment( Align_Center );
	}
	Main_HUD = HUD_inBase_Aircrafts;
}

private function CloseAllUserInterfaces()
{
	if (HUD_Planet != none)
	{
		HUD_Planet.Close();
		HUD_Planet = none;
	}
	if (HUD_inBase != none)
	{
		HUD_inBase.Close();
		HUD_inBase = none;
	}
	if (HUD_inBase_Aircrafts != none)
	{
		HUD_inBase_Aircrafts.Close();
		HUD_inBase_Aircrafts = none;
	}
}


//=============================================================================
// Multi selection
//=============================================================================
function DrawDragBox()
{
	local Vector2D lRectDimensions;
	local Vector2D lTmpPos;
	if (bDragging)
	{
		Canvas.Reset(false);

		if ((WorldInfo.TimeSeconds - DraggDeltaTime)>0.2)
		{
			EndOfDragg = GetMouseCoordinates();
			Canvas.SetDrawColor(220, 220, 240, 150); //MakeColor(0.9, 0.8, 0.8, 0.7);
			
			lTmpPos.X = Min(StartOfDragg.X, EndOfDragg.X);
			lTmpPos.Y = Min(StartOfDragg.Y, EndOfDragg.Y);

			Canvas.SetPos(lTmpPos.X, lTmpPos.Y);
			lRectDimensions.X = abs(EndOfDragg.X - StartOfDragg.X);
			lRectDimensions.Y = abs(EndOfDragg.Y - StartOfDragg.Y);
			Canvas.DrawRect(lRectDimensions.X, lRectDimensions.Y);
			//Canvas.DrawBox(lRectDimensions.X, lRectDimensions.Y);
		}	 
	}
	DoAircraftSelection();
}

function CheckDragDirection()
{
	local Vector2D lTmpPos;
	if ((StartOfDragg.X)>(EndOfDragg.X))
	{
		lTmpPos.X = StartOfDragg.X;
		StartOfDragg.X = EndOfDragg.X;
		EndOfDragg.X = lTmpPos.X;
	}
	if ((StartOfDragg.Y)>(EndOfDragg.Y))
	{
		lTmpPos.Y = StartOfDragg.Y;
		StartOfDragg.Y = EndOfDragg.Y;
		EndOfDragg.Y = lTmpPos.Y;
	}
}


function StartDrawSelectionRange()
{
	bDragging = true;
	bWasDragged = false;
	StartOfDragg = GetMouseCoordinates();
	DraggDeltaTime = WorldInfo.TimeSeconds;
}


function StopDrawSelectionRange()
{
	local Vector2D lDraggResult;
	local float     lDraggDeltaTime;
	bDragging = false;
	lDraggDeltaTime = WorldInfo.TimeSeconds - DraggDeltaTime;
	CheckDragDirection();
	lDraggResult.X = abs(EndOfDragg.X - StartOfDragg.X);
	lDraggResult.Y = abs(EndOfDragg.Y - StartOfDragg.Y);
	if ((lDraggDeltaTime>0.2) && (lDraggResult.X > 15) && (lDraggResult.Y > 15)) bWasDragged = true;
}


function DoAircraftSelection()
{
	local xcGEO_PlayerController lxcPC;
	local X_COM_Vehicle_AirVehicle_Human lVehicle;
	local Vector lScreenLocation;

	if (bDoAircraftSelection)
	{
		lxcPC = xcGEO_PlayerController(xcPC);
		lxcPC.SelectedUnitsClear();
		//foreach lxcPC.PlayerCamera.VisibleCollidingActors(class'X_COM_Vehicle_AirVehicle', lVehicle, lxcPC.GeoDistanceFromPlanet, , true)
		foreach lxcPC.VisibleCollidingActors(class'X_COM_Vehicle_AirVehicle_Human', lVehicle, lxcPC.GeoDistanceFromPlanet, , true)
		{
			if (lVehicle != none)
			{
				lScreenLocation = Canvas.Project(lVehicle.Location);
				if ((lScreenLocation.X>=StartOfDragg.X) && (lScreenLocation.X<=EndOfDragg.X) &&
					(lScreenLocation.Y>=StartOfDragg.Y) && (lScreenLocation.Y<=EndOfDragg.Y))
						lxcPC.SelectPlayerUnit(lVehicle);
			}
		}
		bDoAircraftSelection = false;
	}
}

/** @brief Draws debug message that was set in xcGEO_GameInfo.HudDebugMessages */
function DrawDebugMessages()
{
	
	local string lText;
	local xcGEO_GameInfo lGameInfo;
	local int lIter;
	local int lTextY;
	local int lStringsLength; //length of strings (to print) array

	Canvas.SetDrawColor(10, 255, 10, 255);
	Canvas.Font = class'Engine'.Static.GetSmallFont();

	lTextY = 100; //first string will be on this height

	lGameInfo = xcGEO_GameInfo(WorldInfo.Game);

	//Iterate through strings
	lStringsLength = lGameInfo.HudDebugMessages.Length;
	for(lIter=0; lIter<lStringsLength; lIter++)
	{
		lText = lGameInfo.HudDebugMessages[lIter].Key @ lGameInfo.HudDebugMessages[lIter].Value;
		Canvas.SetPos(Canvas.ClipX/1.4, lTextY + lIter*25);
		Canvas.DrawText(lText);
	}
}

DefaultProperties
{
	Name="Default__xcGEO_HUD"
}