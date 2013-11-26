/**
 * X-COM Tactics map genetration class
 * Places map all map content to map with generation algorithms
 */
class xcT_Factory_MapGenerator extends Actor notplaceable;

//=============================================================================
// Variables
//=============================================================================
/** Map location type */
enum ELocationType
{
	Field,
	Forest,
	Village,
    City
};

/** Map surface type */
enum ESurfaceType
{
	LittleGrass,
	Dirt,
	Ice,
    Sand,
	UBase,
	XBase
};

/** Time of the day */
enum EDayTime
{
	Morning,
	Day,
	Evening,
    Night
};

/** Weather kinds possible in map */
enum EWeather
{
	Sunny,
	Rainy,
	Snowy,
	Foggy,
	Sandy
};

/** Mission types */
enum EMissionType
{
	UfoCrash,
	Terror,
	UFOBase,
	XcomBase
};

/** X-com ships kinds */
enum EXcomShips
{
	Buran,
	BigBuran
};

/** Ufo ships kinds */
enum EUfoShips
{
	Explorer,
	Interceptor,
	SmallBattle
};

/** House and Buildings kinds */
enum EHouses
{
	HSmall,
	HBig,
	HWare,
	HSnow,
	HSand
};

/** Walls kinds */
enum EWalls
{
	WSmall,
	WBig
};

/** Sun parameters, based on DayTime */
struct SunParameters
{
	var Color   LightColor;
	var float   LightBrightness;
	var vector  LightLocation;
	var rotator LightRotation;
	var float   DayLight_Brightness;
	var float   DayLight_LowerBrightness;
	var Color   DayLight_Color;
	var Color   DayLight_LowerColor;
	var float   LightFunction_Translation;
	var float   LightFunction_Scale;
};
var SunParameters							    SunParams;

var public DirectionalLightComponent    SunLights;
var public DirectionalLightComponent    SubLights;

var Rotator                                     SpawnRotation;
var class<X_COM_Tile_SM>                      TileGroundClass;
var class<X_COM_Tile_SM>                      TileObjectClass;
//var xcT_Defines                                 _F; //Reference to xcT_Defines class

//=============================================================================
// Functions
//=============================================================================
event PreBeginPlay()
{
	Super.PreBeginPlay();
	//_F = new()class'xcT_Defines';
}

function GenerateMap(EMissionType aMissionType, ESurfaceType aSurfaceType, vector aSpawnLocation, rotator aSpawnRotation, optional int aXcomQuater, optional ELocationType aLocationType, optional EDayTime aDayTime, optional EWeather aWeather, optional EXcomShips aXcomShip, optional EUfoShips aUfoShip)
{
	//local rotator lMapRotation;
	//local vector lMapLocation;
	local MaterialInstance lGroundMaterial;
	local X_COM_Tile_SM  lTileGround;
	local X_COM_Tile_SM lTileGroundTmp;
	//local xcT_NavMeshObstacle lNavMeshObstacleTile;
	//local Box Bounds; //ground box
	//local Vector BoxBounds; //ground bounds
	/*
	// Add Ground to Map
	lTileGround = Spawn(TileGroundClass);
	lTileGround.AddStaticMesh(class'X_COM_Settings'.default.GroundStaticMesh);
	lTileGround.GetComponentsBoundingBox(Bounds);
	BoxBounds = Bounds.Max - Bounds.Min - vect(2,2,2);	

	// Fixed ground static mesh location
	lMapLocation = class'X_COM_Settings'.default.T_LevelSize/2;
	lMapLocation.Z = - BoxBounds.Z;

	// Random map rotation
	lMapRotation = GenerateMapRotation();	
	
	// Set ground location and rotation
	lTileGround.SetLocation(lMapLocation);
	lTileGround.SetRotation(lMapRotation);
	*/
	/*
	foreach AllActors(TileGroundClass, lTileGroundTmp )
    {
      if( lTileGroundTmp != None )
      {
			if (lTileGroundTmp.isA('xcT_Tile_Ground')) 
			{
				if (lTileGroundTmp.Tag == 'xcT_Tile_Ground_Level_1') lTileGround = xcT_Tile_Ground(lTileGroundTmp);
				//else lTileGroundTmp.Destroy();
			//}
				else
					if ((lTileGroundTmp.Tag == 'xcT_Tile_Ground_Level_2')  || (lTileGroundTmp.Tag == 'xcT_Tile_Ground_Level_3') || (lTileGroundTmp.Tag == 'xcT_Tile_Ground_Level_4') || (lTileGroundTmp.Tag == 'xcT_Tile_Ground_Level_5'))
					{
						lTileGroundTmp.Destroy();
						`log("lTileGroundTmp.Destroy();");
						//lTileGroundTmp.SetCollisionType(COLLIDE_NoCollision);
						//lTileGroundTmp.SetHidden(true);
					}
			}
      }
    }
		local StaticMeshActor lRampa;

	foreach AllActors(class'StaticMeshActor', lRampa )
    {
      if( lRampa != None )
      {
			if (lRampa.Tag == 'Rampa')
			{
				lRampa.destroy();
				`log("lRampa.Destroy();");
				//lRampa.SetCollisionType(COLLIDE_NoCollision);
				//lRampa.SetHidden(true);
			}
      }
    }

	//for map: tactics_nav3
	foreach AllActors(class'Actor', lTileGroundTmp )
    {
		`log("lTileGroundTmp : "$lTileGroundTmp);
      if( lTileGroundTmp != None )
      {
			if (lTileGroundTmp.isA('xcT_Tile_Ground')) 
			{
				if (lTileGroundTmp.Tag == 'xcT_Tile_Ground_Level_1') 
					lTileGround = xcT_Tile_Ground(lTileGroundTmp); // we found main ground
				else //delete others
					if ((lTileGroundTmp.Tag == 'xcT_Tile_Ground_Level_2')  || (lTileGroundTmp.Tag == 'xcT_Tile_Ground_Level_3') || 
						(lTileGroundTmp.Tag == 'xcT_Tile_Ground_Level_4') || (lTileGroundTmp.Tag == 'xcT_Tile_Ground_Level_5'))
					{
						lTileGroundTmp.Destroy();
					}
					else
						if (lTileGroundTmp.Tag == 'Rampa')
						{
							lNavMeshObstacleTile = spawn(class'xcT_NavMeshObstacle', , , lTileGroundTmp.Location, lTileGroundTmp.Rotation);
							lNavMeshObstacleTile.SetEnabled(true);
							lTileGroundTmp.Destroy();
						}
			}
      }
    }
	*/

	//for map: tactics_nav
	foreach AllActors(class'X_COM_Tile_SM', lTileGroundTmp )
    {
      if( lTileGroundTmp != None )
      {
			if (lTileGroundTmp.Tag == 'TacticsGround') lTileGround = lTileGroundTmp; // we found main ground
      }
    }

	//Setup surface textures
	switch (aSurfaceType)
	{
		case LittleGrass    :   lGroundMaterial=GenerateGrassMaterial(); 						
		break;
		case Dirt           :   lGroundMaterial=GenerateGrassMaterial();
		break;
		case Ice            :   lGroundMaterial=GenerateGrassMaterial();
		break;
		case Sand           :   lGroundMaterial=GenerateGrassMaterial(); 								
		break;
		case UBase		    :   lGroundMaterial = LoadMaterial("TacticsGround.Materials.UfoBase_Mat");
		break;
		case XBase		    :   lGroundMaterial = LoadMaterial("TacticsGround.Materials.XCOMBase_Mat");
		break;	
	}

	//landscape
	SetLandscape(lGroundMaterial);
	//mask
	SetSurfaceMask(lGroundMaterial);
	//weather
	SetWeather(aWeather, lGroundMaterial);

	// Add Material to ground
	lTileGround.SetInstancedMaterial(0,lGroundMaterial);

	switch (aMissionType)
	{
		case UfoCrash   :   GenerateMapUfoCrash(aXcomQuater, aSpawnLocation, aSpawnRotation, aLocationType, aXcomShip, aUfoShip);
							//AddLight(aDayTime);
		break;
		case Terror     :   //GenerateMapTerror(lXcomQuater, aSpawnLocation, aSpawnRotation, aLocationType);
							//AddLight(aDayTime);
		break;
		case UFOBase    :   //GenerateMapUFOBase(aSpawnLocation, aSpawnRotation);
		break;
		case XcomBase   :   //GenerateMapXcomBase(aSpawnLocation, aSpawnRotation);
		break;
	}
}

function rotator GenerateMapRotation() // Random ground static mesh Rotation
{
	local rotator lMapRotation;
	switch ((1+Rand(4)))
	{
		case 1	:   lMapRotation=rot(0,0,0);
		break;
		case 2	:   lMapRotation=rot(0,16384,0);
		break;
		case 3	:   lMapRotation=rot(0,32768,0);
		break;
		case 4	:   lMapRotation=rot(0,49152,0);
		break;
	}
	return lMapRotation;
}

function MaterialInstance GenerateGrassMaterial() // New Ground Material instanced.
{
	local MaterialInstance lGroundMaterial;
	local array<string>    Params;
	local array<Texture2D> Textures, Normals;
	local int il,index;
	//new material
	lGroundMaterial= new(None)Class'MaterialInstanceConstant';
	lGroundMaterial.SetParent(MaterialInstanceConstant'TacticsGround.Materials.Ground_instance');
	//textures and normal maps	
	Textures.AddItem(Texture2D(DynamicLoadObject("TacticsGround.Textures.Grass.Grass01",class'Texture2D')));
	Normals.AddItem(Texture2D(DynamicLoadObject("TacticsGround.Textures.Grass.Grass01_nrm",class'Texture2D')));
	Textures.AddItem(Texture2D(DynamicLoadObject("TacticsGround.Textures.Grass.Grass02",class'Texture2D')));
	Normals.AddItem(Texture2D(DynamicLoadObject("TacticsGround.Textures.Grass.Grass02_nrm",class'Texture2D')));
	Textures.AddItem(Texture2D(DynamicLoadObject("TacticsGround.Textures.Grass.Grass03",class'Texture2D')));
	Normals.AddItem(Texture2D(DynamicLoadObject("TacticsGround.Textures.Grass.Grass03_nrm",class'Texture2D')));
	Textures.AddItem(Texture2D(DynamicLoadObject("TacticsGround.Textures.Grass.Grass04",class'Texture2D')));
	Normals.AddItem(Texture2D(DynamicLoadObject("TacticsGround.Textures.Grass.Grass04_nrm",class'Texture2D')));
	Textures.AddItem(Texture2D(DynamicLoadObject("TacticsGround.Textures.Grass.Grass05",class'Texture2D')));
	Normals.AddItem(Texture2D(DynamicLoadObject("TacticsGround.Textures.Grass.Grass05_nrm",class'Texture2D')));
	//Set Params inputs
	Params.AddItem("Black"); Params.AddItem("Red"); Params.AddItem("Green"); Params.AddItem("Blue");
	//set ground textures
	for(il=0; il<Params.Length; ++il)
	{
		index=rand(Textures.Length);
		lGroundMaterial.SetScalarParameterValue(Name(Params[il]$"_Scale"), (32+Rand(8)));
		lGroundMaterial.SetTextureParameterValue(Name(Params[il]$"_D"), Textures[index]);
		lGroundMaterial.SetTextureParameterValue(Name(Params[il]$"_N"), Normals[index]);
		Textures.RemoveItem(Textures[index]);
		Normals.RemoveItem(Normals[index]);		
	}	
	return lGroundMaterial;
}

function SetLandscape(MaterialInstance aMaterial)
{
	local int index;
	local array<Texture2D> Landscapes;
	Landscapes.AddItem(Texture2D(DynamicLoadObject("TacticsGround.Textures.Grass.Grass01_nrm",class'Texture2D'))); // we need several landscapes normal maps
	index=rand(Landscapes.Length);
	aMaterial.SetScalarParameterValue('Landscape_Scale',RandRange(0.5,5));
	aMaterial.SetTextureParameterValue('Landscape_Mask_N',Landscapes[index]);	
}

function SetSurfaceMask(MaterialInstance aMaterial)
{
	local Texture2D MaskTexture;
	MaskTexture = Texture2D'TacticsGround.Textures.RGB_test2'; //we need to get it from somewhere
	aMaterial.SetTextureParameterValue('Mask',MaskTexture);
}

function SetWeather(EWeather aWeather, MaterialInstance aMaterial)
{
	local xcT_Weather_Precipitations lPrecipitations;
	local int ix,iy,lnum;
	local vector lLocation, lHeightFogLocation, lLinearFogLocation;
	local rotator lRotation;
	local StaticMesh lStaticMesh;

	if (aWeather != -1)
	{
		switch (aWeather)
		{
			case Sunny	:	aMaterial.SetScalarParameterValue('Weather_is',RandRange(0.05,0.1));
							return;
							//nothing should be added
			break;
			case Rainy	:   aMaterial.SetScalarParameterValue('Weather_is',RandRange(0.4,0.5));
							lStaticMesh = StaticMesh(DynamicLoadObject("xcT_Weather.Rain.Meshes.Rain",class'StaticMesh'));
			break;
			case Snowy	:	aMaterial.SetScalarParameterValue('Weather_is',RandRange(0.3,0.4));
							lStaticMesh = StaticMesh(DynamicLoadObject("xcT_Weather.Snow.Meshes.Snow",class'StaticMesh'));
			break;
			case Foggy	:	aMaterial.SetScalarParameterValue('Weather_is',RandRange(0.1,0.2));
							lHeightFogLocation = class'X_COM_Settings'.default.T_LevelSize/2;
							lHeightFogLocation.Z = class'X_COM_Settings'.default.T_MaxZoomLocationOffset;
							lLinearFogLocation = class'X_COM_Settings'.default.T_LevelSize/2;
							lLinearFogLocation.Z = class'X_COM_Settings'.default.T_MinZoomLocationOffset/2;

							Spawn(class'xcT_Weather_Fog_Height',,,lHeightFogLocation);
							Spawn(class'xcT_Weather_Fog_Linear',,,lLinearFogLocation);
							return;
			break;
			case Sandy	:	aMaterial.SetScalarParameterValue('Weather_is',RandRange(0.1,0.2));
							lStaticMesh = StaticMesh(DynamicLoadObject("xcT_Weather.Snow.Meshs.Snow",class'StaticMesh'));
			break;
		}

		lnum=0;
		for(ix=96; ix<class'X_COM_Settings'.default.T_LevelSize.x; ix+=96)
		{
			lLocation.x=ix;
			for(iy=0; iy<class'X_COM_Settings'.default.T_LevelSize.y; iy+=(192-5))
			{		
				switch ((1+Rand(4)))
				{
					case 1	:   lRotation=rot(0,0,0);
					break;
					case 2	:   lRotation=rot(0,16384,0);
					break;
					case 3	:   lRotation=rot(0,32768,0);
					break;
					case 4	:   lRotation=rot(0,49152,0);
					break;
				}			
				lPrecipitations = spawn(class'xcT_Weather_Precipitations',,,lLocation, lRotation);
				lPrecipitations.SetStaticMesh(lStaticMesh);
				lLocation.y=iy;
				lnum+=1;
			}
		}
		`log("Weather Tiles: "$lnum);
	}
}

function GenerateMapUfoCrash(int aXcomQuater, vector aSpawnLocation, rotator aSpawnRotation, ELocationType aLocationType, EXcomShips aXcomShip, EUfoShips aUfoShip)
{
	local string lXCOMShip, lUFOSHip;
	local vector lXCOMShipSize, lUFOSHipSize;
	local int lUfoQuater, lSpawnTranslation;
	local Vector lUFOSpawnLocation, lXCOMSpawnLocation;
	local rotator lXCOMRotation, lUFORotation;
	local vector JustForTestForOffWarnings;
	local Vector lLevelSize;

	lLevelSize = class'X_COM_Settings'.default.T_LevelSize;
	
	// translation from edge of map
	lSpawnTranslation = lLevelSize.X/10;

	// get position for ufo crash
	lUfoQuater=1+Rand(4); 
	while(lUfoQuater == aXcomQuater)
	{
		lUfoQuater=1+Rand(4);
	}

	switch (aUfoShip)
	{
		case Explorer		:   lUFOSHip="xc_Tile_TestMeshes.Meshes.ufo960x128";
								lUFOSHipSize=vect(960,960,0);
		break;
		case Interceptor	:   lUFOSHip="xc_Tile_TestMeshes.Meshes.ufo1440x128";
								lUFOSHipSize=vect(1440,1440,0);
		break;

		case SmallBattle    :   lUFOSHip="xc_Tile_TestMeshes.Meshes.ufo3840x480";
								lUFOSHipSize=vect(3840,3840,0);
		break;
	}

	switch (lUfoQuater)
	{
		case 1	:	lUFOSpawnLocation.x=(lLevelSize.X/10)+(lUFOSHipSize.x+lSpawnTranslation);
					lUFOSpawnLocation.y=(lLevelSize.Y/10)+(lUFOSHipSize.y+lSpawnTranslation);
		break;
		case 2	:   lUFOSpawnLocation.x=lLevelSize.X-(lUFOSHipSize.x+lSpawnTranslation);
					lUFOSpawnLocation.y=(lLevelSize.Y/10)+(lUFOSHipSize.y+lSpawnTranslation);
		break;
		case 3	:   lUFOSpawnLocation.x=(lLevelSize.X/10)+(lUFOSHipSize.x+lSpawnTranslation);
					lUFOSpawnLocation.y=lLevelSize.Y-(lUFOSHipSize.y+lSpawnTranslation);
		break;
		case 4	:   lUFOSpawnLocation.x=lLevelSize.X-(lUFOSHipSize.x+lSpawnTranslation);
					lUFOSpawnLocation.y=lLevelSize.Y-(lUFOSHipSize.y+lSpawnTranslation);
		break;
	}
	
	switch (aXcomShip)
	{
		case Buran          :   lXCOMShip="xc_Tile_TestMeshes.Meshes.xcomship";
								lXCOMShipSize=vect(760,760,0);
		break;
		case BigBuran       :   lXCOMShip="xc_Tile_TestMeshes.Meshes.xcomship";
								lXCOMShipSize=vect(1440,760,0);
		break;
	}

	lXCOMSpawnLocation=aSpawnLocation;
	lXCOMRotation=aSpawnRotation;
	lUFORotation=lXCOMRotation+(((180/pi)*RadToUnrRot)*rot(0,1,0));
	//add x-com ship and ufo plate
	//AddTile(TileObjectClass,lXCOMSpawnLocation, lXCOMRotation, lXCOMShip);
	//AddTile(TileObjectClass,lUFOSpawnLocation, lUFORotation, lUFOSHip);

	//DELETE IT WHEN WILL BE DOING LEVEL GENERATION
	//----start---//
	JustForTestForOffWarnings=lXCOMShipSize;
	JustForTestForOffWarnings=JustForTestForOffWarnings;
	lXCOMSpawnLocation = lUFOSpawnLocation;
	lXCOMShip = lUFOSHip;
	lUFOSpawnLocation = lXCOMSpawnLocation;
	lUFOSHip = lXCOMShip;
	lXCOMRotation = lUFORotation;

	//----end---//


	//here should be main Level Content Generation : houses, trees, etc..
	switch (aLocationType)
	{
		case Field      :  
		break;
		case Forest     : 
		break;
		case Village    :   //TEST_PREFABS();
							//ERASE_NAVMESH();
							//TEST_DYNAMIC_PYLON();   
							//TEST_PREFABS_TEST2();
		break;
		case City       :
		break;
	}
}

/*
function TEST_PREFABS_TEST2()
{
	local xcT_Tile_Prefab lNewPrefab;
	local DynamicPylon lPylon;
	local Vector lNewLocation;

	lNewPrefab = Spawn(class'xcT_Tile_Prefab',,,vect(5760,5760,0),);
	lNewPrefab.BuildPrefab(1);

   foreach AllActors( class 'DynamicPylon', lPylon)
   {
		if (lPylon.Tag == 'DynamicPylon_Level2')
		{
			lNewLocation = class'X_COM_Settings'.default.T_LevelSize/2;
			lNewLocation.Z = lPylon.Location.Z;
			lPylon.ExpansionRadius = class'X_COM_Settings'.default.T_LevelSize.x/2;
      		lPylon.SetLocation(lNewLocation);
			lPylon.FlushDynamicEdges();
			lPylon.RebuildDynamicEdges();
			break;
		}
   }

   lNewPrefab.BuildPrefab(2);
   lPylon.FlushDynamicEdges();
   lPylon.RebuildDynamicEdges();

   foreach AllActors( class 'DynamicPylon', lPylon)
   {
		if (lPylon.Tag == 'DynamicPylon_Level3')
		{
			lNewLocation = class'X_COM_Settings'.default.T_LevelSize/2;
			lNewLocation.Z = lPylon.Location.Z;
			lPylon.ExpansionRadius = class'X_COM_Settings'.default.T_LevelSize.x/2;
      		lPylon.SetLocation(lNewLocation);
			lPylon.FlushDynamicEdges();
			lPylon.RebuildDynamicEdges();
			break;
		}
   }

   lNewPrefab.BuildPrefab(3);
   lPylon.FlushDynamicEdges();
   lPylon.RebuildDynamicEdges();
}

function TEST_DYNAMIC_PYLON()
{
	//DynamicPylon_Level1
   local DynamicPylon lPylon;
   local Vector lNewLocation;
 
   // Go through all actors in the level.
   foreach AllActors( class 'DynamicPylon', lPylon)
   {
		lNewLocation = class'X_COM_Settings'.default.T_LevelSize/2;
		lNewLocation.Z = lPylon.Location.Z;
		lPylon.ExpansionRadius = class'X_COM_Settings'.default.T_LevelSize.x/2;
      	lPylon.SetLocation(lNewLocation);
		lPylon.FlushDynamicEdges();
		lPylon.RebuildDynamicEdges();
   }
}
*/
/*
function TEST_PREFABS()
{
	local X_COM_Tile_Prefab lNewPrefab;
	local int ix, iy;
	local Vector lLocation;

	for(ix=1; ix<5; ix+=1)
	{
		for(iy=1; iy<5; iy+=1)
		{
			lLocation.X = 1920 * ix;
			lLocation.Y = 1920 * iy;
			lNewPrefab = Spawn(class'X_COM_Tile_Prefab',,,lLocation, Rot(0,0,0));
			lNewPrefab.BuildPrefab();
		}
	}
}


function AddHouses(EHouses aHouse, string aMaterial, vector aHouseLocation, rotator aHouseRotation)
{
	local int il, floors, FloorHeight;
	local string  HouseBase, HouseFloor, HouseRoof;

	FloorHeight = class'X_COM_Settings'.default.T_GridSize.Z;

	switch (aHouse)
	{
		case HSmall  :	
		break;
		case HBig    :	
		break;
		case HWare   :
		break;
		case HSnow   :
		break;
		case HSand  :
		break;
	}

	//making house with random floors
	//1st floor
	AddTileWithMaterial(TileObjectClass, aHouseLocation, aHouseRotation, HouseBase, aMaterial, 0);
	aHouseLocation.z += FloorHeight;
	//other floors
	if ((aHouse != Hsnow) || (aHouse != Hsand))
	{
		floors=Rand(3)+1;
		for(il=0; il<floors; ++il)
		{
			AddTileWithMaterial(TileObjectClass, aHouseLocation, aHouseRotation, HouseFloor, aMaterial, 0);
			aHouseLocation.z += FloorHeight;
		}
	}
	//roof
	AddTileWithMaterial(TileObjectClass, aHouseLocation, aHouseRotation, HouseRoof, aMaterial, 0);
}

function AddWall(vector aHouseLocation, rotator aHouseRotation)
{
	local int ix,iy,iz;
	local vector lTileLocation;
	local string  Wall, Corner;

	Wall="xcT_Walls.Meshes.Wall_480x16x64"; //wall
	Corner="xcT_Walls.Meshes.Wall_corner96x16x64"; //corner

	//StaticMesh'xcT_Walls.Meshes.Wall_480x16x64'
	//StaticMesh'xcT_Walls.Meshes.Wall_corner96x16x64'
/*
	for(iz=1; iz<=aHouseSize.z; iz+=1) //generating floors
	{
		for(ix=0; ix<=aHouseSize.x; ix+=96)
		{
			lTileLocation.x=aHouseLocation.x+ix;
			for(iy=0; iy<=aHouseSize.y; iy+=96)
			{		

				//AddTile(lTileLocation);
				lTileLocation.y=aHouseLocation.y+iy;
			}
		}	
	}
*/
}
*/
function AddTile(class<X_COM_Tile> aBaseClass, vector aTileLocation, rotator aTileRotation, string aTileMeshName)
{
	local X_COM_Tile lNewTile;
	lNewTile=Spawn(aBaseClass,,,aTileLocation,aTileRotation);
	lNewTile.AddStaticMesh(LoadMesh(aTileMeshName));
}

function AddTileWithMaterial(class<X_COM_Tile> aBaseClass, vector aTileLocation, rotator aTileRotation, string aTileMeshName, string aNewMaterial, int aMaterialIndex )
{
	local X_COM_Tile lNewTile;
	lNewTile=Spawn(aBaseClass,,,aTileLocation,aTileRotation);
	lNewTile.AddStaticMeshWithMaterial(LoadMesh(aTileMeshName), LoadMaterial(aNewMaterial), aMaterialIndex);
}

function StaticMesh LoadMesh(string aObjectName)
{
	return StaticMesh(DynamicLoadObject(aObjectName,class'StaticMesh'));
}

function MaterialInstance LoadMaterial(string aObjectName)
{
	return MaterialInstance(DynamicLoadObject(aObjectName,class'MaterialInstance'));
}

function AddLight(EDayTime aDayTime)
{
	/*
	Cascaded Shadow Maps and DominantDirectionalLightMovable 
		There's also a new light type called DominantDirectionalLightMovable, which can be rotated in-game for dynamic time of day. 
		No precomputed shadowing is calculated for this light and all per-object shadows are disabled. 
		With the existing DominantDirectionalLight, static shadows are computed and faded out to be replaced by dynamic shadows based on WholeSceneDynamicShadowRadius. 
		Per-object shadows are still enabled, so you can have a higher resolution shadow on characters while the dynamic shadows on the world are somewhat lower res. 
	*/
	SetSunProperties(aDayTime);
	SunLights = new(self)class'DirectionalLightComponent';
	SunLights.SetLightProperties(SunParams.LightBrightness, SunParams.LightColor);
	//SunLights.LightComponent.WholeSceneDynamicShadowRadius = 4800; //Determines the distance that the dynamic shadows will fade out.
	//SunLights.NumWholeSceneDynamicShadowCascades = 3; //Determines how many parts the view frustum will be split into, called cascades. Each cascade gets its own shadow map, so increasing the number of cascades improves shadow resolution and allows larger view ranges, but takes longer to render.
	//SunLights.CascadeDistributionExponent = 3; //Higher values bring the cascade transitions closer to the camera, values less than 1 push the transitions further away.
	SunLights.CastDynamicShadows = true;
    SunLights.MaxShadowResolution = 100;
    SunLights.MinShadowResolution = 1;
	SunLights.ShadowFilterQuality = SFQ_High;
	SunLights.ShadowProjectionTechnique = ShadowProjTech_BPCF_High;
	SetLocation(SunParams.LightLocation);
	SetRotation(SunParams.LightRotation);
	if ( SunLights != None ) self.AttachComponent(SunLights);

	//SunLights.Function = new(SunLights)class'LightFunction';
	//SetLightProperties( , , lFogLightFunction);


	//AddDayLight();
}

/** DayLight */
function AddDayLight()
{
	//local SkyLightComponent MapSkyLight;
	//MapSkyLight = new(self)class'SkyLightComponent';
	//MapSkyLight.SetLightProperties(SunParams.DayLight_Brightness, SunParams.DayLight_Color);
	////MapSkyLight.LowerBrightness = SunParams.DayLight_LowerBrightness;
	////MapSkyLight.LowerColor = SunParams.DayLight_LowerColor;
	//if ( MapSkyLight != None ) self.AttachComponent(MapSkyLight);

	SubLights = new(self)class'DirectionalLightComponent';
	SubLights.SetLightProperties(SunParams.LightBrightness, SunParams.LightColor);
	SubLights.CastDynamicShadows = false;
	SubLights.bCastCompositeShadow = false;
    SubLights.MaxShadowResolution = 0;
    SubLights.MinShadowResolution = 0;
	SubLights.ShadowFilterQuality = SFQ_High;
	SubLights.ShadowProjectionTechnique = ShadowProjTech_BPCF_High;
	SetLocation(SunParams.LightLocation);
	SetRotation(SunParams.LightRotation);
	if ( SubLights != None ) self.AttachComponent(SubLights);

}

function SetSunProperties(EDayTime aDayTime)
{
	SunParams.LightLocation = class'X_COM_Settings'.default.T_LevelSize/2;
	SunParams.LightLocation.Z = SunParams.LightLocation.X;
	if (aDayTime==Morning)
	{
		SunParams.LightColor=MakeColor(245,220,210);
		SunParams.LightBrightness=1.0;
		SunParams.LightRotation=rot(-4096,28672,0);
	}
	if (aDayTime==Day)
	{
		/*
		SunParams.LightColor = MakeColor(200,240,255);
		SunParams.LightBrightness=1.4;
		SunParams.LightRotation=rot(-10240,-20480,0);
		SunParams.DayLight_Brightness = 0.8;
		SunParams.DayLight_LowerBrightness = 0.4;
		SunParams.DayLight_Color = MakeColor(255,250,250);
		SunParams.DayLight_LowerColor = MakeColor(255,250,240);
		*/
		//FOG OF WAR TEST
		SunParams.LightColor = MakeColor(200,240,255);
		SunParams.LightBrightness=1.4;
		SunParams.LightRotation=rot(-16384,0,0);
		SunParams.DayLight_Brightness = 0.8;
		SunParams.DayLight_LowerBrightness = 0.4;
		SunParams.DayLight_Color = MakeColor(255,250,250);
		SunParams.DayLight_LowerColor = MakeColor(255,250,240);
	}
	if (aDayTime==Evening)
	{
		SunParams.LightColor=MakeColor(240,225,215);
		SunParams.LightBrightness=0.8;
		SunParams.LightRotation=rot(-6144,4096,0);
	}
	if (aDayTime==Night)
	{
		SunParams.LightColor=MakeColor(150,150,170);
		SunParams.LightBrightness=0.5;	
		SunParams.LightRotation=rot(8192,12288,0);
	}
}

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
	TileObjectClass=class'X_COM_Tile_SM' // Object tile class
	TileGroundClass=class'X_COM_Tile_SM'; // Ground tile class
}