/**
 * X-COM main settings class. Stores main settings and values for all game types
 */
class X_COM_Settings extends Object
	config (XComSettings);

//=============================================================================
// Weapons, pawns and other references
//=============================================================================
var array<X_COM_Weapon_Pawn> Weapons;
var array<X_COM_Weapon_Vehicle> WeaponVehicles;
var array<X_COM_Weapon_Vehicle_Air> WeaponAirVehicles;

var array<X_COM_Pawn_Alien> Aliens;
var array<X_COM_Vehicle_Alien> AlienVehicles;
var array<X_COM_Vehicle_AirVehicle_Alien> AlienAirVehicles;

var array<X_COM_Tile_AlienEvent> AlienEvents;

var array<X_COM_Pawn_Human> Humans;
var array<X_COM_Vehicle_Human> HumanVehicles;
var array<X_COM_Vehicle_AirVehicle_Human> HumanAirVehicles;

var array<X_COM_Equipment> Equipments;
var array<X_COM_Equipment_Shields> Shields;

//=============================================================================
// Music:
//=============================================================================
var SoundCue                    music_MainMenu;
var SoundCue                    music_Geo_MainTheme;
var SoundCue                    music_Geo_Fight;
var SoundCue                    music_Geo_inBase;
var SoundCue                    music_Geo_inUfopaedia;
var SoundCue                    music_Tactics_MainTheme;
var SoundCue                    music_Tactics_Action;
var SoundCue                    music_Tactics_Mission_Win;
var SoundCue                    music_Tactics_Mission_Fail;

var  float music_Tempo;
var  int CrossfadeToMeNumMeasuresDuration;

//=============================================================================
// Maps:
//=============================================================================
var  String                      GEOmap;
var  String                      TacticsMap;
var  String                      MenuMap;
var  String                      MultiplayerMap;

//=============================================================================
// GEO:
//=============================================================================
var  float                       GEO_EarthScale; // Масштаб земли, в переводе с реального на игровой.
var  float                       GEO_RealEarthRadius; // Радиус настоящей планеты Земля
var  float                       GEO_EarthPlanetRadius; // Радиус планеты в игре
var  float                       GEO_FlyingDistanceFromPlanet; // Distance from GEO_WorldCenter to aircraft in air. Orbital height.
var  float                       GEO_CrashedDistanceFromPlanet; // Distance from GEO_WorldCenter to crashed aircraft in earth. Orbital height.
var  Vector                      GEO_WorldCenter; // Center of the worls. Rotation center.
var  int                         GEO_MinZoomLocationOffset, GEO_MaxZoomLocationOffset; //Zoom limits on axes
var  int				         GEO_ZoomDistance; //Zooming distance adjuster
var  int                         GEO_ZoomStep; // zooming step per tick
var  String                      GEO_Base_Mesh; // Path to mesh used in GEO mode
var  Float                       GEO_ScreenCameraRotationSpeedWithMouse;

var string                       EarthStaticMesh; //path to planet mesh
var string                       EarthCloudsMesh; //path to clouds mesh

//=============================================================================
// GEO: in Base mode
//=============================================================================
var  int                         Base_BaseAndMapRelativeSize; // Set of number of map parts (6x6)(8x8)(10x10)
var  Vector                      Base_GridSize; // size of grid is 256x256x128
var  Vector					     Base_Size; //Base dimensions
var  Vector                      Base_Location; //Base location in world
var  String                      Base_GroundTile; // Path to mesh used for ground in base mode

//=============================================================================
// GEO: in Base mode: Aircrafts Management
//=============================================================================
var  float                       Hangar_Radius;
var  Vector                      Hangar_Location; // Hangar location in world
var  Vector						 Hangar_Camera_Location; // Hangar_Camera_Translation from Hangar Location in Map
var  Rotator                     Hangar_Camera_Rotation;
var  String                      Hangar_Tile;
var  String                      Interceptor_Buran_Mesh;
var  float                       Aircraft_Height_Buran;

//=============================================================================
// Tactics:
//=============================================================================
var  Vector                      T_GridSize; // Grid bounds
var  Vector						 T_LevelSize; // Level ground bounds
var  int                         T_CellSize; // Size of map cell
var  float                       T_MinZoomLocationOffset, T_MaxZoomLocationOffset; //Zoom limits on z axes
var  float				         T_ZoomDistance; //Zooming distance adjuster
var StaticMesh                   GroundStaticMesh; //Mesh of tactics ground

//var MaterialInstanceConstant     T_LightFunctionMaterial;

//=============================================================================
// Effects:
//=============================================================================
var ParticleSystem			                ClickToTerrainEffect; //Shows location effect where player cliked to terrain to move pawn there
var ParticleSystem			                ClickOnEarthEffect; //Shows location effect where player cliked to terrain to move pawn there
var ParticleSystem			                SelectBox, AimBox; // particles of boxes

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
	Weapons(EW_Human_Riffle_Laser) = X_COM_Weapon_Pawn'Weapons.Rifle_Laser'
	Weapons(EW_Alien_Plasma_Riffle) = X_COM_Weapon_Pawn'Weapons.Rifle_Plasma'

	Humans(EXADT_Standart) = X_COM_Pawn_Human'Humans.Soldier'
	Humans(EXADT_Light) = X_COM_Pawn_Human'Humans.MediumSoldier'

	Aliens(EA_Sectoid) = X_COM_Pawn_Alien'Aliens.Sectoid'
	Aliens(EA_High) = X_COM_Pawn_Alien'Aliens.High'
	Aliens(EA_Dog) = X_COM_Pawn_Alien'Aliens.Dog'

	HumanAirVehicles(EHAV_Buran) = X_COM_Vehicle_AirVehicle_Human'AirVehicles.Buran'

	AlienAirVehicles(EAAV_UFO) = X_COM_Vehicle_AirVehicle_Alien'AirVehicles.UFOtest'

	WeaponAirVehicles(EAVW_CicadaMissile) = X_COM_Weapon_Vehicle_Air'AirWeapons.CicadaMissle'
	WeaponAirVehicles(EAVW_LaserBeam) = X_COM_Weapon_Vehicle_Air'AirWeapons.LaserBeam'

	Shields(EST_Laser) = X_COM_Equipment_Shields'Shields.Shield_Laser_Pawn'

	AlienEvents(EAET_CrashSite) = X_COM_Tile_AlienEvent'AlienEvents.CrashSite'
	//AlienEvents(EAET_Terror) =
	//AlienEvents(EAET_Base) =

	music_MainMenu = SoundCue'xcMusic.GEO_Earth_view_Cue'
	music_Geo_MainTheme = SoundCue'xcMusic.GEO_Earth_view_Cue'
	music_Geo_Fight = SoundCue'xcMusic.GEO_interception_Cue'
	music_Geo_inBase = SoundCue'xcMusic.GEO_Earth_view_Cue'
	music_Geo_inUfopaedia = SoundCue'xcMusic.GEO_Earth_view_Cue'
	music_Tactics_MainTheme = SoundCue'xcMusic.GEO_Earth_view_Cue'
	music_Tactics_Action = SoundCue'xcMusic.GEO_Earth_view_Cue'
	music_Tactics_Mission_Win = SoundCue'xcMusic.GEO_Earth_view_Cue'
	music_Tactics_Mission_Fail = SoundCue'xcMusic.GEO_Earth_view_Cue'
	music_Tempo = 100.0
	CrossfadeToMeNumMeasuresDuration = 2

	//Maps:
	GEOmap = "x-com_xcEarth.udk?Game=X-COM_Geo.xcGEO_GameInfo"
	//TacticsMap = "x-com_tactics_empty.udk?Game=x-com.xcT_GameInfo"
	TacticsMap = "x-com_tactics_nav_apex_2.udk?Game=X-COM_Tactics.xcT_GameInfo"
	MenuMap = "x-com_FrontEnd.udk?game=X-COM.X_COM_GameInfo"
	MultiplayerMap = "x-com_multiplayer.udk"

	GEO_EarthScale = 0.000642 // GEO_EarthPlanetRadius / GEO_RealEarthRadius = 4000/6371000 = 0,000642 но с этим значением что то вообще все капец медленно. поэтому возьмем без перевода км в метры = 0,006
	GEO_RealEarthRadius = 6371000 // в метрах. Радиус настоящей планеты Земля 6 371,0 км
	GEO_EarthPlanetRadius = 2048 // 2000 uu = 20 uu м. 1uu = 2 cm в переводе на реальную величину, значит 20uu = 40 метров
	GEO_FlyingDistanceFromPlanet = 2096
	GEO_CrashedDistanceFromPlanet = 2048

	GEO_WorldCenter = (X=0, Y=0, Z=0)
	GEO_MinZoomLocationOffset = 2500
	GEO_MaxZoomLocationOffset = 4000 //4000
	GEO_ZoomDistance = 500
	GEO_ZoomStep = 50
	//GEO_Base_Mesh = "HU_Deco3.SM.Mesh.S_HU_Deco_SM_StorageTanks03"
	GEO_Base_Mesh = "xc_GeoBase.geoBase"
	GEO_ScreenCameraRotationSpeedWithMouse = 500

	EarthStaticMesh = "Earth.Mesh.Earth_Mesh" //"xcEarth.SMesh.GeoEarth_Planet" //path to planet mesh
	EarthCloudsMesh = "Clouds.Mesh.Clouds_Mesh" //"xcEarth.SMesh.GeoEarth_Clouds" //path to clouds mesh

	//Base mode:
	Base_BaseAndMapRelativeSize = 8
	Base_GridSize = (x=240,y=240,z=76)
	Base_Size = (x=1920,y=1920,z=0)
	Base_Location = (x=0,y=24720,z=0)
	Base_GroundTile = "xc_Ground.Meshes.Base_tile"

	//Base mode: Hangar
	Hangar_Radius = 1920
	Hangar_Location = (x=24720,y=0,z=0)
	Hangar_Camera_Location = (x=24294,y=-320,z=300) //24259 //-388 //280
	Hangar_Camera_Rotation = (Pitch=-40, Yaw=36, Roll=0) //in degree
	Hangar_Tile = "xc_Hangar.Mesh.Hangar_TACTICS"
	Interceptor_Buran_Mesh = "VH_Interceptor.Meshs.vh_interceptor_tactic"
	Aircraft_Height_Buran = 70;

	//Tactics:
	T_GridSize = (x=96,y=96,z=128)
	T_LevelSize = (x=7680,y=7680,z=640)
	T_CellSize = 1920

	T_MinZoomLocationOffset = 256.0 //2nd floor
	T_MaxZoomLocationOffset = 1024.0 //6th floor
	T_ZoomDistance = 128.0

	//T_LightFunctionMaterial = MaterialInstanceConstant'xcT_WarFog.LightFunction_INST'
	//T_LightFunctionMaterial = MaterialInstanceConstant'xcT_WarFog_oldversion.LightFunction_INST'

	GroundStaticMesh = StaticMesh'TacticsGround.Meshes.TacticsGround'

	ClickToTerrainEffect = ParticleSystem'FX_SelectEffect.Effects.Click_Tactical'
	ClickOnEarthEffect = ParticleSystem'FX_SelectEffect.Effects.Click_GEO'
	SelectBox = ParticleSystem'FX_SelectEffect.Effects.Unit_Selected_1'
	AimBox = ParticleSystem'FX_SelectEffect.Effects.Attack_Cursor'

}
