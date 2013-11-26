class xcGEO_Base_Aircrafts_Manager extends Actor notplaceable;

//=============================================================================
// Variables: General
//=============================================================================
var xcGEO_GameInfo                                      mGameInfo;
var private XCOMDB_Manager	                            mDatabaseMgr;
var private XCOMDB_DLLAPI                               mDLLAPI;

var xcGEO_Tile_Bases_Modules                Hangar; //Hangar for Aircrafts Management
var X_COM_Tile                              HangarLight;
var X_COM_Vehicle                           HangarAircraft;

//=============================================================================
// Functions: General
//=============================================================================
/** Creation of Base creator and getting references*/
function PostBeginPlay()
{
	super.PostBeginPlay();
	mGameInfo = xcGEO_GameInfo(WorldInfo.Game);//xcGEO_GameInfo(aGameInfo);
	mDatabaseMgr = mGameInfo.getDBMgr();
	mDLLAPI = mDatabaseMgr.getDLLAPI();
}

function InitAircraftsManager()
{
	BuildHangar();
	CreateHangarLight();
	PlaceAircraft();
}

function BuildHangar()
{
	// Create Hangar in map
	Hangar = Spawn(class'xcGEO_Tile_Bases_Modules', self, 'Hangar', Class'X_COM_Settings'.Default.Hangar_Location, Rot(0,0,0));
	Hangar.SetStaticMesh(StaticMesh(DynamicLoadObject(Class'X_COM_Settings'.Default.Hangar_Tile,class'StaticMesh')));
}

/** Create light for base. maybe temporary??? */
function CreateHangarLight()
{
	local Vector lLightLocation;
	local Rotator lLightRotation;
	local PointLightComponent lPointLightComponent;

	lLightLocation = Class'X_COM_Settings'.Default.Hangar_Location;
	lLightLocation.Z = Class'X_COM_Settings'.Default.Hangar_Radius;
	lLightRotation = rot(0,0,0);
	HangarLight = spawn(class'X_COM_Tile',,, lLightLocation, lLightRotation);
	lPointLightComponent = new(HangarLight)class'PointLightComponent';
	lPointLightComponent.Radius = Class'X_COM_Settings'.Default.Hangar_Radius;
	if ( HangarLight != None ) HangarLight.AttachComponent(lPointLightComponent);
}

function PlaceAircraft()
{
	local Vector lAircraftLocation;

	lAircraftLocation = Class'X_COM_Settings'.Default.Hangar_Location;
	lAircraftLocation.Z = Class'X_COM_Settings'.Default.Aircraft_Height_Buran;

	HangarAircraft = Spawn(class'X_COM_Vehicle', self, 'HangarAircraft', lAircraftLocation, Rot(0,-16384,0),,false);
	HangarAircraft.Mesh.SetSkeletalMesh(SkeletalMesh(DynamicLoadObject(Class'X_COM_Settings'.Default.Interceptor_Buran_Mesh,class'SkeletalMesh')));
	HangarAircraft.SetDrawScale(2.0);
}

function DestroyAll()
{
	Hangar.Destroy();
	HangarLight.Destroy();
	HangarAircraft.Destroy();
	self.Destroy();
}

//=============================================================================
// Functions: General
//=============================================================================
function CreateWeapon(string aWeaponName)
{
	//local xcGeo_Weapon_Vehicle lWeapon;
	local name lSocketName;
	local vector lWeaponLoc;
	local rotator lWeaponRot;

	lSocketName = 'Mount_Weapon';

	//lWeapon = spawn(class'xcGeo_Weapon_Vehicle_LaserBeam');

	HangarAircraft.Mesh.GetSocketWorldLocationAndRotation(lSocketName, lWeaponLoc, lWeaponRot);

	//lWeapon.SetBase(HangarAircraft,,HangarAircraft.Mesh, lSocketName);
	//HangarAircraft.Mesh.AttachComponentToSocket(lWeapon.Mesh, lSocketName);
}

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{

}