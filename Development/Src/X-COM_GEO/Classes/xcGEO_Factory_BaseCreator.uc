/**
 * Factory: Base Creator
 * Uses for creating bases
 */
class xcGEO_Factory_BaseCreator extends Actor notplaceable;

//=============================================================================
// Variables
//=============================================================================
//var Vector                          GroundLocationStart;
//var Int                             GroundTileSize;
//var int                             TilesCount; //in row/column

var X_COM_Tile                      BaseLight; // PointLightMovable
//=============================================================================
// Functions
//=============================================================================
/** Place base on planet and load it's staticmesh */
function xcGEO_Tile_Bases_GeoBase PlaceBaseOnPlanet(Vector aBaseLocation, Rotator aBaseRotation, optional name aTag)
{
	local xcGEO_Tile_Bases_GeoBase	lNewBase;
	lNewBase = Spawn(Class'xcGEO_Tile_Bases_GeoBase', , aTag, aBaseLocation, aBaseRotation,,false);
	lNewBase.StaticMeshComponent.SetStaticMesh(StaticMesh(DynamicLoadObject(Class'X_COM_Settings'.Default.GEO_Base_Mesh, class'StaticMesh')));
	lNewBase.SetPhysics(PHYS_None);
	return lNewBase;
}

/** Create ground for base modules placement */
function CreateGround()
{
	local int ix, iy, lTilesCount;
	local Vector lGroundSpawnLocation; // Holds coordinates for ground tiles placement
	local Vector lGroundLocation;
	local xcGEO_Tile_Bases_BuildGround lGroundTile;

	lTilesCount = Class'X_COM_Settings'.Default.Base_BaseAndMapRelativeSize;
	lGroundSpawnLocation = Class'X_COM_Settings'.Default.Base_Location + Class'X_COM_Settings'.Default.Base_GridSize/2;
	lGroundLocation = lGroundSpawnLocation;
	for(ix=0; ix<lTilesCount; ++ix)
	{
		for(iy=0; iy<lTilesCount; ++iy)
		{	
			lGroundTile = Spawn(Class'xcGEO_Tile_Bases_BuildGround',self,'GroundTile',lGroundLocation,rot(0,0,0));
			lGroundTile.StaticMeshComponent.SetStaticMesh(StaticMesh(DynamicLoadObject(Class'X_COM_Settings'.Default.Base_GroundTile, class'StaticMesh')));
			lGroundLocation.Y += Class'X_COM_Settings'.Default.Base_GridSize.Y;
		}
		lGroundLocation.X += Class'X_COM_Settings'.Default.Base_GridSize.X;
		lGroundLocation.Y = lGroundSpawnLocation.Y;
	}
}

/** Create light for base. maybe temporary??? */
function CreateBaseLight()
{
	local Vector lBaseCenterLocation;
	local Rotator lLightRotation;
	local SkyLightComponent lSkyLightComponent;

	lBaseCenterLocation = Class'X_COM_Settings'.Default.Base_Location + Class'X_COM_Settings'.Default.Base_Size/2;
	lBaseCenterLocation.Z = 256;
	lLightRotation = rot(0,0,0);
	BaseLight = spawn(class'X_COM_Tile',,, lBaseCenterLocation, lLightRotation);
	lSkyLightComponent = new(BaseLight)class'SkyLightComponent';
	if ( BaseLight != None ) BaseLight.AttachComponent(lSkyLightComponent);
}

/** Create light for base. maybe temporary??? */
function DestroyBaseLight()
{
	BaseLight.Destroy();
}

/** Build selected module in GEO base managment */
function BuildBaseModule(xcGEO_Tile_Bases_Modules aModule)
{
	local Vector lModuleLocation;
	lModuleLocation = aModule.location;
	lModuleLocation.Z = aModule.location.Z/2;
	PlaceBaseModule(aModule.Class, lModuleLocation, aModule.Rotation, aModule.ModuleType, aModule.Tag);
}

/** Place base module in cell on base ground */
function xcGEO_Tile_Bases_Modules PlaceBaseModule(class<xcGEO_Tile_Bases_Modules> aModuleClass, Vector aModuleLocation, Rotator aModuleRotation, EModulesTypes aModuleType, optional name aTag)
{
	local xcGEO_Tile_Bases_Modules lModule;
	lModule = Spawn(aModuleClass,, aTag, aModuleLocation, aModuleRotation, , true);
	lModule.ModuleType = aModuleType;
	lModule.AddStaticMeshFromType(); //call to set mesh from module type
	return lModule;
}

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
	//GroundLocationStart = (X=0, Y=32768, Z=-32)
	//GroundTileSize = 256
	//TilesCount = 8
}