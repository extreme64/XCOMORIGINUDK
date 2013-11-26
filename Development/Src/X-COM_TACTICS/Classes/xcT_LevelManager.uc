/**
 * Tactical Level Manager
 * Uses for generating maps and for spawn x-com and alien pawns
 */
class xcT_LevelManager extends Actor notplaceable;// dependson(X_COM_System_Pawn_Data);

//=============================================================================
// Variables
//=============================================================================
var xcT_Factory_Units							        Factory_Units;
var xcT_Factory_MapGenerator                            FactoryMapGenerator;

var private MaterialInstanceConstant                    FogMaterial;
var private MaterialInstanceConstant                    LightMaterial;

var private DominantDirectionalLightComponent           SunLights;
var string                                              mCellClassName;
var array<X_COM_Tile> TEST_TEMP_OBJECTS;
//
// Path finding information

var X_COM_TacticalMap mMap;

var X_COM_SusaninPF_Grid mMap2;
var X_COM_SusaninPF_Interface mSusaninInterface;

var int DEBUG_EDGE_WALLS_SCANING_COUNTER;
//=============================================================================
// Functions
//=============================================================================
event PreBeginPlay()
{
	Super.PreBeginPlay();
	Factory_Units = Spawn(class'xcT_Factory_Units');
	FactoryMapGenerator = Spawn(class'xcT_Factory_MapGenerator');
	mSusaninInterface = new class'X_COM_SusaninPF_Interface';
	SetupFogOfWar();
}

public function AddUnitsFor(X_COM_PlayerController aPC)
{
	Factory_Units.AddUnitsFor(aPC);
}

public function AddAliens(EAliens aAlien, int AliensQuantity, int aTeam)
{
	Factory_Units.AddAliens(aAlien, AliensQuantity, aTeam);
}

public function GenerateMap(EMissionType aMissionType, ESurfaceType aSurfaceType, vector aSpawnLocation, rotator aSpawnRotation, optional int aXcomQuater, optional ELocationType aLocationType, optional EDayTime aDayTime, optional EWeather aWeather, optional EXcomShips aXcomShip, optional EUfoShips aUfoShip)
{
	//FactoryMapGenerator.GenerateMap(aMissionType, aSurfaceType, aSpawnLocation, aSpawnRotation, aXcomQuater, aLocationType, aDayTime, aWeather, aXcomShip, aUfoShip);
}

//========================================================
// Fog Of War
//========================================================
function SetupFogOfWar()
{
	local DominantDirectionalLightMovable lMainLight;
	local DirectionalLightToggleable lSubLight;
	local DirectionalLight lTmpLight;
	local LightFunction lFogLightFunctionMain, lFogLightFunctionSub;

	foreach AllActors( class 'DirectionalLight', lTmpLight )
	{
		if (lTmpLight.Tag == 'DominantDirectionalLightMovable') lMainLight = DominantDirectionalLightMovable(lTmpLight);
		if (lTmpLight.Tag == 'DirectionalLightToggleable') lSubLight = DirectionalLightToggleable(lTmpLight);
	}
	if ((lMainLight == none) || (lSubLight == none)) `warn("ERROR: One or more Lights not found in map!");

	//FogMaterial = new()Class'MaterialInstanceConstant';
	//FogMaterial.SetParent(lMainLight.LightComponent.Function.SourceMaterial);
	FogMaterial = MaterialInstanceConstant'FogOfWar.LightFunction_INST';
	//lFogLightFunctionMain = new class'LightFunction'();
	//lFogLightFunctionMain.SourceMaterial = FogMaterial;
	//lFogLightFunctionMain.Scale = lMainLight.LightComponent.Function.Scale;


	LightMaterial = new()Class'MaterialInstanceConstant';
	LightMaterial.SetParent(lSubLight.LightComponent.Function.SourceMaterial);
	lFogLightFunctionSub = new()class'LightFunction';
	lFogLightFunctionSub.SourceMaterial = LightMaterial;
	lFogLightFunctionSub.Scale = lSubLight.LightComponent.Function.Scale;


	//lMainLight.LightComponent.SetLightProperties( , , lFogLightFunctionMain);
	lSubLight.LightComponent.SetLightProperties( , , lFogLightFunctionSub);
}

function UpdateFog(ScriptedTexture aMaskTexture)
{
	FogMaterial.SetTextureParameterValue('FogMask', aMaskTexture);

}

function UpdateLight(ScriptedTexture aMaskTexture)
{
	//LightMaterial.SetTextureParameterValue('FogMask', aMaskTexture);
}


// Path finding relied functions

// Функция преобразования трёхмерных координат в одномерные
/*function int IdFromCrd(int x, int y, int z)
{
	//`log("Getting cell ID by X="$x$" Y="$y$" Z="$z$" :: Z("$tz$")+Y("$ty$")+X("$x$"), ID="$result);
	return (z*(mMapSize.y*mMapSize.x))+(y*mMapSize.x)+x;
}

function int IdFromVector(Vector aV)
{
	//`log("Getting cell ID by X="$x$" Y="$y$" Z="$z$" :: Z("$tz$")+Y("$ty$")+X("$x$"), ID="$result);
	return (aV.z*(mMapSize.y*mMapSize.x))+(aV.y*mMapSize.x)+aV.x;
}*/
//========================================================
// Coordinates manipulation
//========================================================

static function vector GetGridCoord(vector aLocation)
{
	local   vector  lNewLocation, lGridLocation, lGridSize;
	CheckLocationLimit(aLocation, lNewLocation);
	lGridSize = class'X_COM_Settings'.default.T_GridSize;
	lGridLocation.X = int(lNewLocation.X / lGridSize.x) * lGridSize.x + lGridSize.x/2; // half grid size added
	lGridLocation.Y = int(lNewLocation.Y / lGridSize.y) * lGridSize.y + lGridSize.y/2; // half grid size added
	lGridLocation.Z = int(lNewLocation.Z / lGridSize.z) * lGridSize.z + lGridSize.z/2; // keep it little upper on the ground
	return lGridLocation;
}

/** Check if location is out of location limits and correct it*/
static function bool CheckLocationLimit(vector NowLocation, optional out vector NewLocation)
{
	local bool bIsInLimit;
	local Vector lLevelSize, lGridSize;
	lLevelSize = class'X_COM_Settings'.default.T_LevelSize;
	lGridSize = class'X_COM_Settings'.default.T_GridSize;
	bIsInLimit=false;
	NewLocation=NowLocation;
	if (nowLocation.x<0) { NewLocation.x=0; bIsInLimit=true; }
	if (nowLocation.x>(lLevelSize.x-lGridSize.x)) { NewLocation.x=lLevelSize.x-lGridSize.x; bIsInLimit=true; }
	if (nowLocation.y<0) { NewLocation.y=0; bIsInLimit=true; }
	if (nowLocation.y>(lLevelSize.y-lGridSize.x)) { NewLocation.y=lLevelSize.y-lGridSize.y; bIsInLimit=true; }
	return bIsInLimit;  // вернёт true, если производилась коррекция
}

/** Returns grid number for all axes for location*/
// Надо по вещественным координатам на поле, получать номера (т.е. индексы) в массиве поля.
static function vector GetGridNumbersFromLocation(vector aLocation)
{
	local vector lGridSize;
	local vector lGridNumbers;

	aLocation = GetGridCoord(aLocation);

	lGridSize = class'X_COM_Settings'.default.T_GridSize;
	lGridNumbers.X = int((aLocation.X - lGridSize.X/2) / lGridSize.X);
	lGridNumbers.Y = int((aLocation.Y - lGridSize.Y/2) / lGridSize.Y);
	lGridNumbers.Z = int((aLocation.Z - lGridSize.Z/2) / lGridSize.Z);
	return lGridNumbers;
}

// по индексам получить координаты-world центра ячейки
static function vector GetLocationFromGridNumbers(vector aGridNumber)
{
	local   vector lGridSize, lLocation;
	lGridSize = class'X_COM_Settings'.default.T_GridSize;
	lLocation.X = (aGridNumber.X+1./2)*lGridSize.X;
	lLocation.Y = (aGridNumber.Y+1./2)*lGridSize.Y;
	lLocation.Z = (aGridNumber.Z+1./2)*lGridSize.Z;
	return lLocation;
}

static function Cells VectToCell(vector aVector)
{
	local Cells lCell;
	lCell.X = aVector.X;
	lCell.Y = aVector.Y;
	lCell.Z = aVector.Z;
	return lCell;
}

static function vector CellToVect(Cells aCell)
{
	local vector lVect;
	lVect.X = aCell.X;
	lVect.Y = aCell.Y;
	lVect.Z = aCell.Z;
	return lVect;
}

static function bool IsWithinMapBounds(Vector aCell)
{
	local Vector lLevelSize;

	lLevelSize.X = class'X_COM_Settings'.default.T_LevelSize.X / class'X_COM_Settings'.default.T_GridSize.X;
	lLevelSize.Y = class'X_COM_Settings'.default.T_LevelSize.Y / class'X_COM_Settings'.default.T_GridSize.Y;
	lLevelSize.Z = class'X_COM_Settings'.default.T_LevelSize.Z / class'X_COM_Settings'.default.T_GridSize.Z;

	if(aCell.X < 0 || aCell.X >= lLevelSize.X
		|| aCell.Y < 0 || aCell.Y >= lLevelSize.Y
		|| aCell.Z < 0 || aCell.Z >= lLevelSize.Z)
		return false;

	return true;
}
//==================================================================================
function vector MapSize()
{
	return mMap.mMapSize;
}
// Функция чтения по трёхмерным координатам
function X_COM_MapCell GetCell(int x, int y, int z)
{
	return mMap.GetCell(x, y, z);//mMapGrid[IdFromCrd(x, y, z)];
}

function X_COM_MapCell GetCellFromVector(Vector aV)
{
	return mMap.GetCellFromVector(aV);//mMapGrid[IdFromVector(aV)];
}

function vector VfC(X_COM_MapCell aCell)
{
	local Vector r;
	r.X = aCell.x();
	r.Y = aCell.y();
	r.Z = aCell.z();

	return r;
}
// Функция записи в трёхмерные координаты
/*function SetCell(int x, int y, int z, Ecell_type aType)
{
	mMap.SetCell(x, y, z, aType);
	/*local int lid;
	local Vector lLocation;
	local X_COM_Tile lTile;

	lid = IdFromCrd(x, y, z);
	if(mMapGrid[lid] == none)
		mMapGrid[lid] = new class'X_COM_MapCell';

	mMapGrid[lid].x = x;
	mMapGrid[lid].y = y;
	mMapGrid[lid].z = z;
	mMapGrid[lid].id(lid);
	mMapGrid[lid].CellType = aType;


	if(aType == ct_obstacle)
	{
		if(mMapGrid[lid].DEBUG_TILE == none)
		{
			lLocation = class'xcT_Defines'.static.GetLocationFromGridNumbers(VfC(mMapGrid[lid]));
			lLocation.Z -= 64;
			lTile = spawn(class'X_COM_Tile', , , lLocation, rot(0,0,0), , true);
			lTile.AddStaticMesh(StaticMesh'TEST_TEMP.Meshes.obstacle');
			mMapGrid[lid].DEBUG_TILE = lTile;
		}
	}
	else if(mMapGrid[lid].DEBUG_TILE != none)
	{
		mMapGrid[lid].DEBUG_TILE.Destroy();
	}*/

}*/
// vector from MapCell


/**
	X_COM_MapCell ScanCell
	Сканирует координаты на карте, возвращает объект клетки
*/
function CellType ScanCell(vector aCell, optional out array<EdgeStructure> aEdges, optional out float aFloorHeight, optional out rotator aEnterDirection)
{
	local Actor lTraceActor;
	local vector lTraceStart, lTraceEnd, lHitLocation, lHitNormal, lWorldLocation, lTraceExtent, lGridSize;
	local CellType lType, lEdgeType;
	local float lHeight;
	local Vector lCellThatChacked;
	local int i, j;
	local bool lIsScanForEdgeWallsNeeded;
	local array<EdgeStructure> lEdges;

	lIsScanForEdgeWallsNeeded = false;

	lGridSize = class'X_COM_Settings'.default.T_GridSize;
	lWorldLocation.X = (aCell.X+1./2)*lGridSize.X;
	lWorldLocation.Y = (aCell.Y+1./2)*lGridSize.Y;
	lWorldLocation.Z = (aCell.Z+1)*lGridSize.Z;

	lTraceStart = lWorldLocation;
	//lTraceStart.Z += 5; // возьмем немного выше старт
	lTraceEnd = lWorldLocation;
	//lTraceEnd.Z = int(lTraceEnd.Z / class'X_COM_Settings'.default.T_GridSize.Z) * class'X_COM_Settings'.default.T_GridSize.Z; //и опустим конец чуть ниже уровня
	lTraceEnd.Z = (aCell.Z)*lGridSize.Z;
	lTraceExtent.X = lGridSize.X/2-2;//Pawn.GetCollisionExtent();
	lTraceExtent.Y = lGridSize.Y/2-2;
	lTraceExtent.Z = 8;//lGridSize.Z-2;


	lType = Empty;
	/**
	 * Для тех, кто будет править сию функцию:
	 *
	 * У разных объектов есть разные приоритеты для проходимости. Например, если в клетке есть стена -
	 * все остальные объекты можно автоматически игнорить. Если есть лестница и земля - то эта клетка
	 * должна считать именно ЛЕСТНИЦА, а не проходимый участок. Поэтому перед назначением lType какое-либо значение,
	 * нужно проводить проверку на наличие более приоритетных объектов. Например, перед тем, как назначить
	 * значение ct_passable, нужно проверить, является ли lType, сначала ct_obstacle, потом ct_ladder (именно
	 * в таком порядке).
	 */
	ForEach TraceActors(class'Actor', lTraceActor, lHitLocation, lHitNormal, lTraceEnd, lTraceStart, lTraceExtent)
	{
		if (lTraceActor != none)
		{
			if ( lTraceActor.isA('X_COM_Tile_SM') )
			{
				if(lType != Impassable && lType != Ladder)
					lType = Passable;
			}
			if ( lTraceActor.isA('X_COM_Tile_Apex'))
			{
					switch (X_COM_Tile_Apex(lTraceActor).Type)
					{
						case EATT_Door:
							if(lType != Impassable && lType != Ladder)
								lType = Passable;
						break;

						case EATT_Floor:
							if(aCell.Z>0)
							{
								`log("Floor");
							}
							if(lType == Impassable || lType == Empty)
								lType = Passable;
						break;

						case EATT_Wall:
							if(lHitLocation.Z - (lTraceEnd.Z+2) > 10)
								lType = Impassable;
							else
								lType = Passable;
						break;

						case EATT_Ladder:
							if(lType != Impassable)
							{
								if((lHitLocation.Z - (lTraceEnd.Z)) < lTraceStart.Z)
								{
									if((lHitLocation.Z - (lTraceEnd.Z)) < 10)
									{
										lType = Empty;
									}
									else
									{
										lType = Ladder;
										lHeight = lHitLocation.Z - (lTraceEnd.Z+2);
										aEnterDirection = lTraceActor.Rotation;
									}
								}
								else
								{
									lType = Impassable;
								}

							}
						break;

					case EATT_EdgeWall:
						lIsScanForEdgeWallsNeeded = true;
						break;
					}
				}
				if ( (lTraceActor.isA('X_COM_Unit')) && (X_COM_Unit(lTraceActor).bIsInvisibleForAI) ) lType = Impassable; // если на карте юнит, и юнит видим врагом то он является препятствием. Если юнит скрыт - он считается проходимым
		}
		else lType = Empty;
	}
	aFloorHeight = lHeight;
	/**
	 * Далее идёт проверка стен на предмет проходимости. В ней производится 8 трейсов.
	 * Это ЙАдрёно, но зато позволяет сделать классную ути-пути карту с аккуратненькими
	 * стеночками вместо здоровенных блоков на всю клетку.
	 */
	if(lIsScanForEdgeWallsNeeded)
	{
		DEBUG_EDGE_WALLS_SCANING_COUNTER++;
//		lCount = 0;
		for(i = 0; i < 3; i++)
		{
			for(j = 0; j < 3; j++)
			{
				lCellThatChacked = aCell;
				lCellThatChacked.X += j-1;
				lCellThatChacked.Y += i-1;

				if((i == 1 && j == 1) || !IsWithinMapBounds(lCellThatChacked))
					continue;
				lGridSize = class'X_COM_Settings'.default.T_GridSize;
				lWorldLocation.X = (aCell.X+(1./2)*j)*lGridSize.X;
				lWorldLocation.Y = (aCell.Y+(1./2)*i)*lGridSize.Y;
				lWorldLocation.Z = (aCell.Z+1)*lGridSize.Z;

				lTraceStart = lWorldLocation;
				//lTraceStart.Z += 5; // возьмем немного выше старт
				lTraceEnd = lWorldLocation;
				//lTraceEnd.Z = int(lTraceEnd.Z / class'X_COM_Settings'.default.T_GridSize.Z) * class'X_COM_Settings'.default.T_GridSize.Z; //и опустим конец чуть ниже уровня
				lTraceEnd.Z = (aCell.Z)*lGridSize.Z;
				lTraceExtent.X = 25;//Pawn.GetCollisionExtent();
				lTraceExtent.Y = 25;
				lTraceExtent.Z = 8;//class'X_COM_Settings'.default.T_GridSize.Z-2

				ForEach TraceActors(class'Actor', lTraceActor, lHitLocation, lHitNormal, lTraceEnd, lTraceStart, lTraceExtent)
				{
					if (lTraceActor != none)
					{
						if ( lTraceActor.isA('X_COM_Tile_Apex') && X_COM_Tile_Apex(lTraceActor).Type == EATT_EdgeWall)
						{
							if(lHitLocation.Z - (lTraceEnd.Z+2) > 10)
							{
								lEdges.Add(1);
								lEdges[lEdges.Length-1].From.X = aCell.X + j-1;
								lEdges[lEdges.Length-1].From.Y = aCell.Y + i-1;
								lEdges[lEdges.Length-1].From.Z = aCell.Z;

								lEdges[lEdges.Length-1].To.X = aCell.X;
								lEdges[lEdges.Length-1].To.Y = aCell.Y;
								lEdges[lEdges.Length-1].To.Z = aCell.Z;

								lEdgeType = Impassable;

								lEdges[lEdges.Length-1].Type = float(lEdgeType);
							}
						}
					}
				}
			}
		}
	}
	aEdges = lEdges;
	return lType;
}
//function Ecell_type ScanCell(vector aCell, optional out float aFloorHeight, optional out rotator aEnterDirection)
//{
//	local Actor lTraceActor;
//	local vector lTraceStart, lTraceEnd, lHitLocation, lHitNormal, lWorldLocation, lTraceExtent, lGridSize;
//	local Ecell_type lType, lResult;
//	local float lHeight;
//	//local X_COM_MapCell lMapCell;
//	/*local float lClockTime;

//	Clock( lClockTime );
//	UnClock( lClockTime );

//	`log("Setting 6 element value in "$lClockTime$" seconds");*/

//	//lWorldLocation = class'xcT_Defines'.static.GetLocationFromGridNumbers(aCell);
//	lGridSize = class'X_COM_Settings'.default.T_GridSize;
//	lWorldLocation.X = (aCell.X+1./2)*lGridSize.X;
//	lWorldLocation.Y = (aCell.Y+1./2)*lGridSize.Y;
//	lWorldLocation.Z = (aCell.Z+1)*lGridSize.Z;

//	lTraceStart = lWorldLocation;
//	//lTraceStart.Z += 5; // возьмем немного выше старт
//	lTraceEnd = lWorldLocation;
//	//lTraceEnd.Z = int(lTraceEnd.Z / class'X_COM_Settings'.default.T_GridSize.Z) * class'X_COM_Settings'.default.T_GridSize.Z; //и опустим конец чуть ниже уровня
//	lTraceEnd.Z = (aCell.Z)*lGridSize.Z;
//	lTraceExtent.X = class'X_COM_Settings'.default.T_GridSize.X/2-2;//Pawn.GetCollisionExtent();
//	lTraceExtent.Y = class'X_COM_Settings'.default.T_GridSize.Y/2-2;
//	lTraceExtent.Z = 8;//class'X_COM_Settings'.default.T_GridSize.Z-2;

//	//lTraceActor = Trace( lHitLocation, lHitNormal, lTraceEnd, lTraceStart, true, lTraceExtent);

//	//if ((lTraceActor.isA('xcT_Tile_SM_Object')) || (lTraceActor.isA('xcT_Tile_Apex_Wall')) || (lTraceActor.isA('X_COM_Unit')) )
//	//	return ct_obstacle;

//	//if (lTraceActor.isA('xcT_Tile_SM_Ground') || lTraceActor.isA('xcT_Tile_Apex_Floor') || lTraceActor.isA('xcT_Tile_Apex_Door') )
//	//	return ct_passable;

//	//if (lTraceActor.isA('xcT_Tile_Apex_Ladder'))
//	//	return ct_ladder;

//	//return ct_none;

//	lType = ct_none;
//	//lMapCell = mMap.CreateCell();//class'X_COM_MapCell'.static.Factory(mCellClassName, none);

//	//if(aCell.Z >0 )
//	//{
//	//	`log("z>0");
//	//}

//	/**
//	 * Для тех, кто будет править сию функцию:
//	 *
//	 * У разных объектов есть разные приоритеты для проходимости. Например, если в клетке есть стена -
//	 * все остальные объекты можно автоматически игнорить. Если есть лестница и земля - то эта клетка
//	 * должна считать именно ЛЕСТНИЦА, а не проходимый участок. Поэтому перед назначением lType какое-либо значение,
//	 * нужно проводить проверку на наличие более приоритетных объектов. Например, перед тем, как назначить
//	 * значение ct_passable, нужно проверить, является ли lType, сначала ct_obstacle, потом ct_ladder (именно
//	 * в таком порядке).
//	 */
//	ForEach TraceActors(class'Actor', lTraceActor, lHitLocation, lHitNormal, lTraceEnd, lTraceStart, lTraceExtent)
//	{
//		if (lTraceActor != none)
//		{
//			//if ((lTraceActor.isA('xcT_Tile_SM_Object')) || (lTraceActor.isA('xcT_Tile_Apex_Wall')) || (lTraceActor.isA('X_COM_Unit')) )
//			//	lType = ct_obstacle;

//			//if (lTraceActor.isA('X_COM_Tile_Apex') || lTraceActor.isA('xcT_Tile_SM_Ground') || lTraceActor.isA('xcT_Tile_Apex_Floor') || lTraceActor.isA('xcT_Tile_Apex_Door') )
//			//	lType = ct_passable;

//			//if (lTraceActor.isA('xcT_Tile_Apex_Ladder'))
//			//{
//			//	lHeight = lHitLocation.Z - (lTraceEnd.Z+2);
//			//	lType = ct_ladder;
//			//}

//			if ( lTraceActor.isA('X_COM_Tile_SM') )
//			{
//				if(lType != ct_obstacle && lType != ct_ladder)
//					lType = ct_passable;
//			}
//			if ( lTraceActor.isA('X_COM_Tile_Apex') )
//			{
//					switch (X_COM_Tile_Apex(lTraceActor).Type)
//					{
//						case EATT_Door:
//							if(lType != ct_obstacle && lType != ct_ladder)
//								lType = ct_passable;
//						break;

//						case EATT_Floor:
//							if(lType == ct_obstacle)
//								lType = ct_passable;
//						break;

//						case EATT_Wall:
//							if(lHitLocation.Z - (lTraceEnd.Z+2) > 10)
//								lType = ct_obstacle;
//							else
//								lType = ct_passable;
//						break;

//						case EATT_Ladder:
//							if(lType != ct_obstacle && (lHitLocation.Z - (lTraceEnd.Z+2)) > 10)
//							{
//								lType = ct_ladder;
//								lHeight = lHitLocation.Z - (lTraceEnd.Z+2);
//								aEnterDirection = lTraceActor.Rotation;
//							}
//						break;
//					}
//				}
//				if ( (lTraceActor.isA('X_COM_Unit')) && (X_COM_Unit(lTraceActor).bIsInvisibleForAI) ) lType = ct_obstacle; // если на карте юнит, и юнит видим врагом то он является препятствием. Если юнит скрыт - он считается проходимым
//		}
//		else lType = ct_none;
//	}
//	aFloorHeight = lHeight;
//	return lType;
//	/*
//	if( lTraceActor != none )
//	{
//		if (lTraceActor.isA('xcT_Tile_SM_Ground'))
//			return ct_passable;
//		if (lTraceActor.isA('xcT_Tile_Prefab'))
//			return ct_obstacle;
//		if (lTraceActor.isA('X_COM_Unit'))
//			return ct_obstacle;//ct_unit;
//		return ct_none;
//	}
//	else return ct_none;*/
//	//`warn(" ERROR. Could not find cell type for Cell : "$aCell$" in Location : "$lTraceStart);
//}

function GenerateCellMap()
{
	local int i, j, k;
	local vector lSize, lCell;
	local float lHeight;
	local CellType lType;
	local Rotator lRot;
//	local xcT_Test_PathFindingInterface lPathFindingInterfaceTest;
	local array<EdgeStructure> lEdges;

	//local Vector lScanSquare;

//	lDir = class'X_COM_Direction'.static.Construct(df_uninit);
	lSize.X = class'X_COM_Settings'.default.T_LevelSize.x / class'X_COM_Settings'.default.T_GridSize.x;
	lSize.Y = class'X_COM_Settings'.default.T_LevelSize.y / class'X_COM_Settings'.default.T_GridSize.y;
	lSize.Z = class'X_COM_Settings'.default.T_LevelSize.z / class'X_COM_Settings'.default.T_GridSize.z;
// задание размеров массивов
	if(mMap == none)
	{
		//mMap = class'X_COM_TacticalMap'.static.Construct(mCellClassName, lSize);
		mMap = Spawn(class'X_COM_TacticalMap');
		mMap.SetMapCellClassName(mCellClassName);

	}

	mMap.CreateMap(lSize.X, lSize.Y, lSize.Z);

	mMap2 = mSusaninInterface.CreateGrid(lSize.X, lSize.Y, lSize.Z, class'X_COM_Settings'.default.T_GridSize);

	for(i=0; i<lSize.Z; i++)
	{
		for(j=0; j<lSize.Y; j++)
		{
			for(k=0; k<lSize.X; k++)
			{
				lCell.z = i;
				lCell.y = j;
				lCell.x = k;
				lType = ScanCell(lCell, lEdges, lHeight, lRot);
				//lMC = mMap.SetCell(k, j, i, lType, lHeight);
				//if(lType == Ladder)
				//{

				//	lRoute.direction = lDir.SetFromRotator(lRot).Get();
				//	lMC.CustomRoutes.AddItem(lRoute);
				//}

				mMap2.mCells.SetCell(k, j, i, lType, lRot);
				if(lEdges.Length>0)
				{
					mMap2.mEdges.AddEdges(lEdges);
				}
			}
		}
	}
	`log("Edges was scanned "$DEBUG_EDGE_WALLS_SCANING_COUNTER$" times.");
	mMap2.mCells.CommitCells();
	mMap2.mEdges.CommitEdges();

	//arot = Normal(Vector(rot(65536, 0, 0)));
	//lPathFindingTest = Spawn(class'xcT_Test_MapCell');
//	lDirectionTests = new class'xcT_Test_Direction';
	//lOpenClosedNodeColectionTest = new class'xcT_Test_OpenClosedNodeColection';
//	lPathFindingInterfaceTest = Spawn(class'xcT_Test_PathFindingInterface');
//	lPathFindingTest.IsDiagonalMovementBlockedByCorner();
//	lPathFindingTest.GettingCellNeighbor();
//	lPathFindingTest.DoesCellPassable();
//	lPathFindingTest.CanPassDiagonal();
//	lPathFindingTest.CantPassDiagonalBecosOfCorner();
//	lPathFindingTest.CellIsPassable();
//	lPathFindingTest.SelectMostOptimalMovementReturnsFalse();
//	lPathFindingTest.SelectMostOptimalMovementReturnsFalseOnDiagonal();
//	lPathFindingTest.SelectMostOptimalMovementReturnsTrue();
//	lPathFindingTest.IsStraightMovementBeterThenDiagonal();
//	lPathFindingTest.IsStraightMovementBeterThenDiagonalThroughTwoCells();

//	lDirectionTests.IterateDirectionsWithDefaultParams();
//	lDirectionTests.IterateStreightDirections();
//	lOpenClosedNodeColectionTest.AddOpenListItem();
//	lPathFindingInterfaceTest.IsChildNodesGottenCorrectly();
	//lDirectionTests.GettingDirectionByRotator();
//	lPathFindingInterfaceTest.TestingPathFinding();
}

//function GeneratePassabilityMap()
//{
//	local int i, j, k;
//	local vector lSize, lCell;
//	//local float lHeight;
//	//local Ecell_type lType;
//	//local vector arot;
//	local X_COM_Direction lDir;
//	//local Rotator lRot;
//	//local RoutesCustomization lRoute;
//	local X_COM_MapCell lMC;
//	//local xcT_Test_MapCell lPathFindingTest;
//	//local xcT_Test_Direction lDirectionTests;
//	//local xcT_Test_OpenClosedNodeColection lOpenClosedNodeColectionTest;
//	local xcT_Test_PathFindingInterface lPathFindingInterfaceTest;

//	//local Vector lScanSquare;

//	lDir = class'X_COM_Direction'.static.Construct(df_uninit);
//	lSize.X = class'X_COM_Settings'.default.T_LevelSize.x / class'X_COM_Settings'.default.T_GridSize.x;
//	lSize.Y = class'X_COM_Settings'.default.T_LevelSize.y / class'X_COM_Settings'.default.T_GridSize.y;
//	lSize.Z = class'X_COM_Settings'.default.T_LevelSize.z / class'X_COM_Settings'.default.T_GridSize.z;
//// задание размеров массивов
//	//if(mMap == none)
//	//{
//	//	//mMap = class'X_COM_TacticalMap'.static.Construct(mCellClassName, lSize);
//	//	mMap = Spawn(class'X_COM_TacticalMap');
//	//	mMap.SetMapCellClassName(mCellClassName);
//	//}

//	//mMap.CreateMap(lSize.X, lSize.Y, lSize.Z);

//	for(i=0; i<lSize.Z; i++)
//	{
//		for(j=0; j<lSize.Y; j++)
//		{
//			for(k=0; k<lSize.X; k++)
//			{
//				lCell.z = i;
//				lCell.y = j;
//				lCell.x = k;
//				lMC = mMap.GetCell(k, j, i);//GetCellFromVector(lCell);
//				lMC.mIsPassable = lMC.CheckPassability();
//				//lType = ScanCell(lCell, lHeight, lRot);

//				//lMC = mMap.SetCell(k, j, i, lType, lHeight);
//				//if(lType == ct_ladder)
//				//{
//				//	lRoute.direction = lDir.SetFromRotator(lRot).Get();
//				//	lMC.CustomRoutes.AddItem(lRoute);
//				//}

//			}
//		}
//	}


//	//arot = Normal(Vector(rot(65536, 0, 0)));
//	//lPathFindingTest = Spawn(class'xcT_Test_MapCell');
//	//lDirectionTests = new class'xcT_Test_Direction';
//	//lOpenClosedNodeColectionTest = new class'xcT_Test_OpenClosedNodeColection';
//	//lPathFindingInterfaceTest = Spawn(class'xcT_Test_PathFindingInterface');
////	lPathFindingTest.IsDiagonalMovementBlockedByCorner();
////	lPathFindingTest.GettingCellNeighbor();
////	lPathFindingTest.DoesCellPassable();
////	lPathFindingTest.CanPassDiagonal();
////	lPathFindingTest.CantPassDiagonalBecosOfCorner();
////	lPathFindingTest.CellIsPassable();
////	lPathFindingTest.SelectMostOptimalMovementReturnsFalse();
////	lPathFindingTest.SelectMostOptimalMovementReturnsFalseOnDiagonal();
////	lPathFindingTest.SelectMostOptimalMovementReturnsTrue();
////	lPathFindingTest.IsStraightMovementBeterThenDiagonal();
////	lPathFindingTest.IsStraightMovementBeterThenDiagonalThroughTwoCells();

////	lDirectionTests.IterateDirectionsWithDefaultParams();
////	lDirectionTests.IterateStreightDirections();
////	lOpenClosedNodeColectionTest.AddOpenListItem();
////	lPathFindingInterfaceTest.IsChildNodesGottenCorrectly();
//	//lDirectionTests.GettingDirectionByRotator();
//	//lPathFindingInterfaceTest.TestingPathFinding();
//}

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
}
