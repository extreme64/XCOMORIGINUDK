/**
 * HUD class 
 * 
 */
class xcT_Hud extends X_COM_HUD;

//=============================================================================
// Variables: References
//=============================================================================
var X_COM_Unit                          xcUnit;

var private bool                        bDoDebug;

var public xcT_GFx_Screen_EndMission	Screen_EndMission;

var public xcT_GFx_Screen_EnemyTurn	    Screen_EnemyTurn;

//=============================================================================
// Variables: Minimap
//=============================================================================
var X_COM_SceneCapture2DActor           MinimapCapture;
var public xcT_GFx_MiniMap				MiniMap;
var ScriptedTexture					    MiniMapTexture;
var Vector2D                            MapSize;
var int                                 MiniMapSize;
var int                                 MarkerSize;
var int                                 CameraTextureSize;
var Material                            RenderMaterial, xcomMarker, alienMarker, civilianMarker, cameraMarker;
var MaterialInstanceConstant            MiniMapMaterial; // instanced RenderMaterial

//=============================================================================
// Fog of War
//=============================================================================
var ScriptedTexture					    FOWMaskTexture;
var ScriptedTexture					    FOWLightTexture; // Renders current units location and sight direction to make propertly sub-light illumination
var private int                         STexRunCount;
var Material                            SightMaterial;
var int                                 FOWMaskTextureSize;
var bool                                bFirstRun;

//=============================================================================
// Functions
//=============================================================================
simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	GetMapParameters();
	CreateFogMask();
	CreateMinimap();
}

function GetMapParameters()
{
	// Assign all base variables - these could be moved into when the function is called for simplicity.
	MapSize.X = class'X_COM_Settings'.default.T_LevelSize.X; //These probably need to be either grabbed from a world info property or from a volume wrapping around the entire playable area.(Keep in mind this half the radius)
	MapSize.Y = class'X_COM_Settings'.default.T_LevelSize.Y; //These probably need to be either grabbed from a world info property or from a volume wrapping around the entire playable area.(Keep in mind this half the radius)
}

protected function ShowMainUserInterface()
{
	Main_HUD = new class'xcT_GFx_HUD';
	Main_HUD.InitUI(self);
	Main_HUD.SetViewScaleMode( SM_ExactFit );
	Main_HUD.SetAlignment( Align_Center );
}


/** Shows/hides menu by pressing ESC*/
exec function ShowMainMenu()
{   
	if (MainMenuMovie == none)
	{
		MainMenuMovie = new class'X_COM_GFx_MainMenu';
		MainMenuMovie.InitUI(self);
		MainMenuMovie.SetViewScaleMode( SM_ExactFit );
		MainMenuMovie.SetAlignment( Align_Center );
		Worldinfo.game.SetPause(xcPC);
		X_COM_GFx_MainMenu(MainMenuMovie).OpenGameMenu();
	} 
	else 
	{
		MainMenuMovie.Close();
		MainMenuMovie = none;
		Worldinfo.game.ClearPause();
	}
}

/** Shows/hides Enemy Turn Screen */
public function ShowEnemyTurnScreen(bool bShow)
{   
	//return;
	if (bShow)
	{
		if (Screen_EnemyTurn == none)
		{
			Screen_EnemyTurn = new class'xcT_GFx_Screen_EnemyTurn';
			Screen_EnemyTurn.InitUI(self);
			Screen_EnemyTurn.SetViewScaleMode( SM_ExactFit );
			Screen_EnemyTurn.SetAlignment( Align_Center );
		} 
		else 
		{
			Screen_EnemyTurn.Close();
			Screen_EnemyTurn = none;
			ShowEnemyTurnScreen(bShow);
		}
	}
	else 
	{
		if (Screen_EnemyTurn != none)
		{
			Screen_EnemyTurn.Close();
			Screen_EnemyTurn = none;
		}
	}
	
}

/** Shows EndMission screen */
public function ShowEndMissionScreen(bool bShow_Mission_Win)
{   
	if (Screen_EndMission == none)
	{
		Screen_EndMission = new class'xcT_GFx_Screen_EndMission';
		Screen_EndMission.InitUI(self);
		Screen_EndMission.SetViewScaleMode( SM_ExactFit );
		Screen_EndMission.SetAlignment( Align_Center );
		Screen_EndMission.ShowWindowType(bShow_Mission_Win);
		//Worldinfo.game.SetPause(xcPC);
	} 
	else 
	{
		Screen_EndMission.Close();
		Screen_EndMission = none;
		//Worldinfo.game.ClearPause();
	}
}

event PostRender()
{
	super.PostRender();

	UpdateFogMasks();

	Minimap.UpdateMiniMap(MiniMapTexture);

	DrawUnitBars();

	// Debug : 
	DrawDebug();
}


function DrawDebug()
{ 
	super.DrawDebug();

	if (bDoDebug)
	{
		//DrawHotKeys();

		//DrawFogMaskUpdate();

		//DrawMinimapUpdate();

		//DrawPawnSightRadius();
	}
}

//=============================================================================
// FOG of war
//=============================================================================
function CreateFogMask()
{
	bFirstRun = true;
	FOWMaskTexture = ScriptedTexture(class'ScriptedTexture'.static.Create(FOWMaskTextureSize, FOWMaskTextureSize,, MakeLinearColor(0, 0, 0, 255), false));
	FOWLightTexture = ScriptedTexture(class'ScriptedTexture'.static.Create(FOWMaskTextureSize, FOWMaskTextureSize,, MakeLinearColor(0, 0, 0, 255), false));
	FOWMaskTexture.Render = FogMaskRender;
	FOWLightTexture.Render = FogLightRender;
}

function FogMaskRender(Canvas aCanvas)
{
	local vector2D lUnitLocation;
	local X_COM_Unit lUnit;
	local int lMaskSightRadius;
	local Rotator lSightMaterialRotation;

	aCanvas.Reset(false);
	aCanvas.SetPos(0,0);
	aCanvas.SetDrawColor(255,255,255,255);

	foreach WorldInfo.AllPawns( class 'X_COM_Unit', lUnit )
	{
		if ( ( (!lUnit.bIsDied) && ((!IsZero(lUnit.Velocity) || (xcT_AIController(lUnit.Controller).bisDoingAction)) || (bFirstRun)) ) && (self.Owner.GetTeamNum() == lUnit.GetTeamNum()) )
		{
			// Reset initial data
			lUnitLocation.X = 0;
			lUnitLocation.Y = 0;
			lSightMaterialRotation.YAW = 0;

			lMaskSightRadius = Convert_SightRadius_Size_Map_To_MiniMap(lUnit.SightRadius);
		
			lUnitLocation = Convert_Units_Size_Map_To_MiniMap(lUnit.Location, lMaskSightRadius);

			lSightMaterialRotation.YAW = lUnit.Rotation.Yaw;

			aCanvas.SetPos(lUnitLocation.X, lUnitLocation.Y);
			aCanvas.DrawRotatedMaterialTile(SightMaterial, lSightMaterialRotation, lMaskSightRadius, lMaskSightRadius); //correct radius
		}
	}

	if (bFirstRun)
	{
		STexRunCount++;
		if ( STexRunCount == 10 ) bFirstRun = false;
	}

	FOWMaskTexture.bNeedsUpdate = true;
	FOWMaskTexture.bSkipNextClear = true;
}

function FogLightRender(Canvas aCanvas)
{
	local vector2D lUnitLocation;
	local X_COM_Unit lUnit;
	local int lMaskSightRadius;
	local Rotator lSightMaterialRotation;

	aCanvas.Reset(false);
	aCanvas.SetPos(0,0);
	aCanvas.SetDrawColor(255,255,255,255);

	foreach WorldInfo.AllPawns( class 'X_COM_Unit', lUnit )
	{
		if ( (!lUnit.bIsDied) && (self.Owner.GetTeamNum() == lUnit.GetTeamNum()) )
		{
			// Reset initial data
			lUnitLocation.X = 0;
			lUnitLocation.Y = 0;
			lSightMaterialRotation.YAW = 0;

			lMaskSightRadius = Convert_SightRadius_Size_Map_To_MiniMap(lUnit.SightRadius);
		
			lUnitLocation = Convert_Units_Size_Map_To_MiniMap(lUnit.Location, lMaskSightRadius);

			lSightMaterialRotation.YAW = lUnit.Rotation.Yaw;

			aCanvas.SetPos(lUnitLocation.X, lUnitLocation.Y);
			aCanvas.DrawRotatedMaterialTile(SightMaterial, lSightMaterialRotation, lMaskSightRadius, lMaskSightRadius); //correct radius
		}
	}

	FOWLightTexture.bNeedsUpdate = true;
	FOWLightTexture.bSkipNextClear = false;
}

function int Convert_SightRadius_Size_Map_To_MiniMap(float aSightRadius)
{
	local int lSightRadius;
	lSightRadius = (((aSightRadius / MapSize.X) * FOWMaskTextureSize) + ((aSightRadius / MapSize.Y) * FOWMaskTextureSize)); 
	return lSightRadius;
}

function vector2d Convert_Units_Size_Map_To_MiniMap(Vector aLocation, int aTextureSize)
{
	local Vector2D lMiniMapLocation;
	lMiniMapLocation.X = (aLocation.X / MapSize.X) * FOWMaskTextureSize - aTextureSize/2; 
	lMiniMapLocation.Y = (aLocation.Y / MapSize.Y) * FOWMaskTextureSize - aTextureSize/2;
	return lMiniMapLocation;
}

function UpdateFogMasks()
{
	// in light function:
	xcT_GameInfo(WorldInfo.Game).TLevelManager.UpdateFog(FOWMaskTexture);
	xcT_GameInfo(WorldInfo.Game).TLevelManager.UpdateLight(FOWLightTexture);

	// in hud minimap:
	MiniMapMaterial.SetTextureParameterValue('FogMask', FOWMaskTexture);
}

//=============================================================================
// Mini map
//=============================================================================
function CreateMinimap()
{
	CreateMiniMapMovie();
	GetMapImageForMinimap();
	CreateMiniMapMaterial();
	CreateMiniMapTexture();
}

function CreateMiniMapMovie()
{
	MiniMap = new class'xcT_GFx_MiniMap';
	MiniMap.InitUI(self);
	MiniMap.SetViewScaleMode( SM_NoScale );
	MiniMap.SetAlignment( Align_TopLeft );
}

/** Updates minimap image */
function GetMapImageForMinimap()
{
	if (MinimapCapture == none)
	{
		MinimapCapture = spawn(class'X_COM_SceneCapture2DActor',self, , class'X_Com_SceneCapture2DActor'.default.Location, class'X_Com_SceneCapture2DActor'.default.Rotation, , true);
		//MinimapCapture.ForceUpdateComponents();
	}
	else
	{
		MinimapCapture.Destroy();
		MinimapCapture = none;
		GetMapImageForMinimap();
	}
}

function CreateMiniMapMaterial()
{
	MiniMapMaterial = new()Class'MaterialInstanceConstant';
	MiniMapMaterial.SetParent(RenderMaterial);
}

function CreateMiniMapTexture()
{
	MiniMapTexture = ScriptedTexture(class'ScriptedTexture'.static.Create(MiniMapSize, MiniMapSize,, MakeLinearColor(0, 0, 0, 255), false));
	MiniMapTexture.Render = MiniMapTextureRender;
}

function MiniMapTextureRender(Canvas aCanvas)
{
	// MiniMap base variables
	local vector2D UnitLocation, CameraLocation; 
	//local ETeams UnitTeam;
	local Rotator CameraMarkerRotation;
	local X_COM_Unit lUnit;

	aCanvas.Reset(false);
	aCanvas.SetPos(0, 0);
	aCanvas.SetDrawColor(255,255,255,255);
	
	//MiniMapMaterial.SetTextureParameterValue('FogMask', FOWMaskTexture);

	// Draw Map Texture
	aCanvas.DrawMaterialTile(MiniMapMaterial, MiniMapSize, MiniMapSize);
	
	// Draw creatures markers
	foreach WorldInfo.AllPawns( class 'X_COM_Unit', lUnit )
	{
		if (!lUnit.bIsDied && !lUnit.bIsInvisibleForAI) 
		{
			// Reset Unit Pos to 0;
			UnitLocation.X = 0;
			UnitLocation.Y = 0;

			UnitLocation = Convert_Size_Map_To_MiniMap(lUnit.Location, MarkerSize);
		
			// Draw Canvas at position, create marker at material depending on team.
			aCanvas.SetPos(UnitLocation.X, UnitLocation.Y);	

			if ( (lUnit.isA('X_COM_Pawn_Human')) || (lUnit.isA('X_COM_Vehicle_Human')) ) aCanvas.drawmaterialtile(xcomMarker, MarkerSize, MarkerSize);
			else 
				if ( (lUnit.isA('X_COM_Pawn_Alien')) || (lUnit.isA('X_COM_Vehicle_Alien')) ) aCanvas.drawmaterialtile(alienMarker, MarkerSize, MarkerSize);
				//else 
					//if (lUnit.isA('xcT_Pawn_Civilian')) aCanvas.drawmaterialtile(civilianMarker, MarkerSize, MarkerSize);
		}
	}

	/** Draw camera marker: */
	// Create a 0 to 1 for each axis, this makes it easier to work with any minimap size and X/Y according to mip map size
	CameraLocation = Convert_Size_Map_To_MiniMap(xcPC.Location, CameraTextureSize);

	CameraMarkerRotation.YAW = -8192; // initial rotation
	CameraMarkerRotation.YAW += xcPC.Rotation.Yaw;

	//!!!!!!!!!!!!!!!!!!!!!!!!!! TODO: Camera marker correction to not going out minimap bounds:

	aCanvas.SetPos(CameraLocation.X, CameraLocation.Y);
	aCanvas.DrawRotatedMaterialTile(cameraMarker, CameraMarkerRotation, CameraTextureSize, CameraTextureSize);

	MiniMapTexture.bNeedsUpdate = true;
}

function vector2d Convert_Size_Map_To_MiniMap(Vector aLocation, int aTextureSize)
{
	local Vector2D lMiniMapLocation;
	lMiniMapLocation.X = (aLocation.X / MapSize.X) * float(MiniMapSize) - aTextureSize/2; 
	lMiniMapLocation.Y = (aLocation.Y / MapSize.Y) * float(MiniMapSize) - aTextureSize/2;
	return lMiniMapLocation;
}

function vector Convert_Size_MiniMap_To_Map(vector2d aMiniMapLocation) //used from controller to place camera in clicked location
{
	local Vector lLocation;
	lLocation.X = (aMiniMapLocation.X * MapSize.X) / float(MiniMapSize);
	lLocation.Y = (aMiniMapLocation.Y * MapSize.Y) / float(MiniMapSize);
	return lLocation;
}

//=============================================================================
// Units Health Bars
//=============================================================================
function DrawUnitBars()
{
	local X_COM_Unit lUnit;
	local Vector lScreenLocation;
	local float lHealthPct, lEnergyPct;

	Canvas.Reset(false);

	foreach xcPC.PlayerCamera.VisibleCollidingActors(class'X_COM_Unit', lUnit, 32768, , true)
	{
		if (!lUnit.bIsDied && !lUnit.bIsInvisibleForAI)
		{
			//life bars
			lScreenLocation = Canvas.Project(lUnit.Location + vect(0.000000, 0.000000, 1.000000) * lUnit.GetCollisionHeight() * 1.5000000);
			lHealthPct = float(lUnit.Health) / float(lUnit.HealthMax);
			Canvas.SetPos(lScreenLocation.X - 25, lScreenLocation.Y + 2);
			Canvas.SetDrawColor(0,255,0);
			Canvas.DrawTile(Texture2D'WhiteSquareTexture',50.00000000 * lHealthPct,4.00000000,0.00000000,0.00000000,2.00000000,2.00000000);
			Canvas.SetDrawColor(255,0,0);
			Canvas.DrawTile(Texture2D'WhiteSquareTexture',50.00000000 * (1.00000000 - lHealthPct),4.00000000,0.00000000,0.00000000,2.00000000,2.00000000);

			//time units bar for human
			if (lUnit.IsA('X_COM_Pawn_Human'))
			{
				lScreenLocation = Canvas.Project(lUnit.Location + vect(0.000000, 0.000000, 1.000000) * lUnit.GetCollisionHeight() * 1.250000);
				lEnergyPct = float(X_COM_Pawn_Human(lUnit).TimeUnitsRemain) / float(X_COM_Pawn_Human(lUnit).TimeUnits);
				Canvas.SetPos(lScreenLocation.X - 25, lScreenLocation.Y + 2);
				Canvas.SetDrawColor(255,255,0);
				Canvas.DrawTile(Texture2D'WhiteSquareTexture',50.00000000 * lEnergyPct,4.00000000,0.00000000,0.00000000,2.00000000,2.00000000);
				Canvas.SetDrawColor(255,0,255);
				Canvas.DrawTile(Texture2D'WhiteSquareTexture',50.00000000 * (1.00000000 - lEnergyPct),4.00000000,0.00000000,0.00000000,2.00000000,2.00000000);				
			}
		}
	}
}

//=============================================================================
// Debug functions
//=============================================================================
function DrawPawnInfo(Actor aActor)
{
	local string lText;
	local X_COM_Unit lUnit;

	lUnit = X_COM_Unit(aActor);

	Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.Font = class'Engine'.Static.GetSmallFont();

		//Canvas.SetPos(170, 30);
		//Canvas.DrawTile(lUnit.Photo, 128, 128, 0, 0, 128, 128);


	lText = "playerowner.GetTeamNum(): "$playerowner.GetTeamNum()$" | Unit.GetTeamNum(): "$lUnit.GetTeamNum()$" | Controller.GetTeamNum(): "$lUnit.Controller.GetTeamNum();
	Canvas.SetPos(10, 10);
	Canvas.DrawText(lText);

	lText = "Unit.controller active command: "$xcT_AIController(lUnit.controller).GetActiveCommand();
	Canvas.SetPos(10, 25);
	Canvas.DrawText(lText);

	lText = "InvManager "$lUnit.InvManager$" | ActiveWeapon = "$lUnit.ActiveWeapon$" | Shield = "$lUnit.Shield;
	Canvas.SetPos(10, 40);
	Canvas.DrawText(lText);

	lText = "Shield = "$lUnit.Shield;
	Canvas.SetPos(10, 55);
	Canvas.DrawText(lText);


	lText = "UnitState: "$lUnit.UnitState;
	Canvas.SetPos(10, 80);
	Canvas.DrawText(lText);

	lText = "UnitName: "$lUnit.UnitName;
	Canvas.SetPos(10, 100);
	Canvas.DrawText(lText);

	lText = "Race: "$lUnit.Race;
	Canvas.SetPos(10, 120);
	Canvas.DrawText(lText);

	lText = "Level: "$lUnit.Level;
	Canvas.SetPos(10, 140);
	Canvas.DrawText(lText);

	lText = "Experience: "$lUnit.Experience;
	Canvas.SetPos(10, 160);
	Canvas.DrawText(lText);

	lText = "UnitsKilled: "$lUnit.UnitsKilled;
	Canvas.SetPos(10, 180);
	Canvas.DrawText(lText);



	lText = "Head: "$lUnit.Armor.Head;
		Canvas.SetPos(20, 240);
		Canvas.DrawText(lText);

		lText = "Torso: "$lUnit.Armor.Torso;
		Canvas.SetPos(20, 260);
		Canvas.DrawText(lText);

		lText = "Arms: "$lUnit.Armor.Arms;
		Canvas.SetPos(20, 280);
		Canvas.DrawText(lText);

		lText = "Legs: "$lUnit.Armor.Legs;
		Canvas.SetPos(20, 300);
		Canvas.DrawText(lText);

		lText = "Other: "$lUnit.Armor.Other;
		Canvas.SetPos(20, 320);
		Canvas.DrawText(lText);

		lText = "DefenceFrom: "$lUnit.Armor.DefenceFrom;
		Canvas.SetPos(20, 340);
		Canvas.DrawText(lText);



	lText = "ShieldType: "$lUnit.ShieldType;
	Canvas.SetPos(10, 380);
	Canvas.DrawText(lText);

	//lText = "Shield: "$lUnit.Shield;
	//Canvas.SetPos(10, 400);
	//Canvas.DrawText(lText);



	lText = "Dexterity: "$lUnit.Dexterity;
	Canvas.SetPos(10, 440);
	Canvas.DrawText(lText);

	lText = "Energy: "$lUnit.Energy;
	Canvas.SetPos(10, 460);
	Canvas.DrawText(lText);

	lText = "Vitality: "$lUnit.Vitality;
	Canvas.SetPos(10, 480);
	Canvas.DrawText(lText);

	lText = "Bravery: "$lUnit.Bravery;
	Canvas.SetPos(10, 500);
	Canvas.DrawText(lText);


	lText = "Strength: "$lUnit.Strength;
	Canvas.SetPos(10, 520);
	Canvas.DrawText(lText);

	lText = "Reaction: "$lUnit.Reaction;
	Canvas.SetPos(10, 540);
	Canvas.DrawText(lText);

	lText = "FiringAccuracy: "$lUnit.FiringAccuracy;
	Canvas.SetPos(10, 560);
	Canvas.DrawText(lText);

	lText = "ThrowingAccuracy: "$lUnit.ThrowingAccuracy;
	Canvas.SetPos(10, 580);
	Canvas.DrawText(lText);



	lText = "TimeUnits: "$lUnit.TimeUnits;
	Canvas.SetPos(20, 620);
	Canvas.DrawText(lText);

	lText = "TimeUnitsRemain: "$lUnit.TimeUnitsRemain;
	Canvas.SetPos(20, 640);
	Canvas.DrawText(lText);

	lText = "HealthUnits: "$lUnit.HealthUnits;
	Canvas.SetPos(20, 660);
	Canvas.DrawText(lText);

	lText = "HealthMax: "$lUnit.HealthMax;
	Canvas.SetPos(220, 660);
	Canvas.DrawText(lText);

	lText = "HealthUnitsRemain: "$lUnit.HealthUnitsRemain;
	Canvas.SetPos(20, 680);
	Canvas.DrawText(lText);

	lText = "Health: "$lUnit.Health;
	Canvas.SetPos(220, 680);
	Canvas.DrawText(lText);

	lText = "FearUnits: "$lUnit.FearUnits;
	Canvas.SetPos(20, 700);
	Canvas.DrawText(lText);

	lText = "FearUnitsRemain: "$lUnit.FearUnitsRemain;
	Canvas.SetPos(20, 720);
	Canvas.DrawText(lText);



	lText = "ActiveWeapon: "$lUnit.ActiveWeapon;
	Canvas.SetPos(10, 740);
	Canvas.DrawText(lText);
}

function DrawHotKeys()
{
	local string lText;

	Canvas.SetDrawColor(255, 255, 255, 200);
	Canvas.Font = class'Engine'.Static.GetSmallFont();

	lText = " HOT KEYS in keyboard:";
	Canvas.SetPos(Canvas.ClipX/1.5, 30);
	Canvas.DrawText(lText);

	lText = " SPACE: Tactical Pause";
	Canvas.SetPos(Canvas.ClipX/1.5, 60);
	Canvas.DrawText(lText);

	lText = " E: Deselect all units | Free camera";
	Canvas.SetPos(Canvas.ClipX/1.5, 90);
	Canvas.DrawText(lText);

	lText = " Q: HOLD to show selection ring";
	Canvas.SetPos(Canvas.ClipX/1.5, 120);
	Canvas.DrawText(lText);

	lText = " F: Follow leader unit";
	Canvas.SetPos(Canvas.ClipX/1.5, 180);
	Canvas.DrawText(lText);

	lText = " TAB: Select next unit";
	Canvas.SetPos(Canvas.ClipX/1.5, 210);
	Canvas.DrawText(lText);

	lText = " I: Open inventory";
	Canvas.SetPos(Canvas.ClipX/1.5, 240);
	Canvas.DrawText(lText);

	lText = " Z: Invisibility";
	Canvas.SetPos(Canvas.ClipX/1.5, 270);
	Canvas.DrawText(lText);

	lText = " T: Teleportation";
	Canvas.SetPos(Canvas.ClipX/1.5, 300);
	Canvas.DrawText(lText);

	lText = " X: Shields";
	Canvas.SetPos(Canvas.ClipX/1.5, 330);
	Canvas.DrawText(lText);

	lText = " B: Plant bomb";
	Canvas.SetPos(Canvas.ClipX/1.5, 360);
	Canvas.DrawText(lText);
}

function DrawPawnSightRadius()
{
	local X_COM_Unit lUnit;
	local Vector lScreenLocation;
	local vector lSightEdge;

	foreach WorldInfo.AllPawns( class 'X_COM_Unit', lUnit )
	{
		if ( (lUnit.isA('X_COM_Pawn_Human')) || (lUnit.isA('X_COM_Vehicle_Human')) )
		{
			lScreenLocation = Canvas.Project(lUnit.Location);
			lSightEdge = Canvas.Project( lUnit.Location + Normal(vector(lUnit.Rotation)) * lUnit.SightRadius );
			Canvas.Draw2DLine(lScreenLocation.X, lScreenLocation.Y, lSightEdge.X, lSightEdge.Y, MakeColor(255, 0, 0, 150) );
			lUnit.DrawDebugSphere(lUnit.Location, lUnit.SightRadius, 8, 255, 0, 0, false);
		}
	}
}

function DrawMinimapUpdate()
{
	Canvas.Reset(false);
	Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.SetPos(Canvas.ClipX-(MiniMapSize*2), Canvas.ClipY-MiniMapSize);
	Canvas.DrawTexture(MiniMapTexture, 1.0f);
}

function DrawFogMaskUpdate()
{
	Canvas.Reset(false);
	Canvas.SetDrawColor(255, 255, 255, 255);

	// FOW mask
	Canvas.SetPos(Canvas.ClipX-MiniMapSize, Canvas.ClipY-MiniMapSize);
	Canvas.DrawTexture(FOWMaskTexture, float(MiniMapSize)/float(FOWMaskTextureSize));

	//FOW light
	Canvas.SetPos(0, Canvas.ClipY-MiniMapSize);
	Canvas.DrawTexture(FOWLightTexture, float(MiniMapSize)/float(FOWMaskTextureSize));
}

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
	MiniMapSize = 256
	MarkerSize = 4 // Size of the minimap markers
	CameraTextureSize = 64 //32x32 texture size
	RenderMaterial = Material'MiniMap.Materials.MM_Rendered_Texture_Mat'// Material of above map from render target 2d.
	xcomMarker = Material'MiniMap.Materials.MM_GreenPoint' // green material
	alienMarker = Material'MiniMap.Materials.MM_RedPoint' // red material
	civilianMarker = Material'MiniMap.Materials.MM_YellowPoint' // yellow material
	cameraMarker = Material'MiniMap.Materials.MM_CameraPoint' // material camera blue marker

	SightMaterial = Material'FogOfWar.sight_halfcircle_Mat'
	FOWMaskTextureSize = 4096

	Name="Default__xcT_Hud"

	bDoDebug = TRUE
}