/**
 * X-COM Tactics functions and variables class. 
 * Uses to store functions and variables for tactics classes.
 */
class X_COM_TacticalMap extends Actor implements (X_COM_NodeMap) dependson(X_COM_Settings, X_COM_MapCell, X_COM_AstarPathfinding, X_COM_Tile, X_COM_MovementRules);

var bool                    DEBUG_MAP;

var string                  mMapCellClass;  // Имя класса клетки, используемого в данном контексте
var array<X_COM_MapCell>    mMapGrid;
var vector                  mMapSize;
var X_COM_PathFinding       mPathfinder;
var private Vector          mStartPosition; // Точка старта поиска пути
var private Vector          mEndPosition;   // Место назначения поиска пути

//var vector dir[26];
enum ETacticalMapExeption
{
	tme_OK,
	tme_crd_out_of_bounds
};
event PreBeginPlay()
{
	mPathfinder = class'X_COM_PathFinding'.static.Construct();
	//mCompass = new class'X_COM_Direction';
/*
	dir[df_w_raise].x   =-1; dir[df_w_raise].y    = 0; dir[df_w_raise].z   = 1;
	dir[df_e_raise].x   = 1; dir[df_e_raise].y    = 0; dir[df_e_raise].z   = 1;
	dir[df_n_raise].x   = 0; dir[df_n_raise].y    = 1; dir[df_n_raise].z   = 1;
	dir[df_s_raise].x   = 0; dir[df_s_raise].y    =-1; dir[df_s_raise].z   = 1;
	dir[df_nw_raise].x  =-1; dir[df_nw_raise].y   = 1; dir[df_nw_raise].z  = 1;
	dir[df_sw_raise].x  =-1; dir[df_sw_raise].y   =-1; dir[df_sw_raise].z  = 1;
	dir[df_ne_raise].x  = 1; dir[df_ne_raise].y   = 1; dir[df_ne_raise].z  = 1;
	dir[df_se_raise].x  = 1; dir[df_se_raise].y   =-1; dir[df_se_raise].z  = 1;
	dir[df_raise].x     = 0; dir[df_raise].y      = 0; dir[df_raise].z     = 1;

	dir[df_w].x         =-1; dir[df_w].y          = 0; dir[df_w].z         = 0;
	dir[df_e].x         = 1; dir[df_e].y          = 0; dir[df_e].z         = 0;
	dir[df_n].x         = 0; dir[df_n].y          = 1; dir[df_n].z         = 0;
	dir[df_s].x         = 0; dir[df_s].y          =-1; dir[df_s].z         = 0;
	dir[df_nw].x        =-1; dir[df_nw].y         = 1; dir[df_nw].z        = 0;
	dir[df_sw].x        =-1; dir[df_sw].y         =-1; dir[df_sw].z        = 0;
	dir[df_ne].x        = 1; dir[df_ne].y         = 1; dir[df_ne].z        = 0;
	dir[df_se].x        = 1; dir[df_se].y         =-1; dir[df_se].z        = 0;
	dir[df_self].x      = 0; dir[df_self].y       = 0; dir[df_self].z      = 0;

	

	dir[df_w_lower].x   =-1; dir[df_w_lower].y    = 0; dir[df_w_lower].z   =-1;
	dir[df_e_lower].x   = 1; dir[df_e_lower].y    = 0; dir[df_e_lower].z   =-1;
	dir[df_n_lower].x   = 0; dir[df_n_lower].y    = 1; dir[df_n_lower].z   =-1;
	dir[df_s_lower].x   = 0; dir[df_s_lower].y    =-1; dir[df_s_lower].z   =-1;
	dir[df_nw_lower].x  =-1; dir[df_nw_lower].y   = 1; dir[df_nw_lower].z  =-1;
	dir[df_sw_lower].x  =-1; dir[df_sw_lower].y   =-1; dir[df_sw_lower].z  =-1;
	dir[df_ne_lower].x  = 1; dir[df_ne_lower].y   = 1; dir[df_ne_lower].z  =-1;
	dir[df_se_lower].x  = 1; dir[df_se_lower].y   =-1; dir[df_se_lower].z  =-1;
	dir[df_lower].x     = 0; dir[df_lower].y      = 0; dir[df_lower].z     =-1;*/
}

function int IdFromCrd(int x, int y, int z)
{
	//`log("Getting cell ID by X="$x$" Y="$y$" Z="$z$" :: Z("$tz$")+Y("$ty$")+X("$x$"), ID="$result);
	return (z*(mMapSize.y*mMapSize.x))+(y*mMapSize.x)+x;
}

function int IdFromVector(Vector aV)
{
	//`log("Getting cell ID by X="$x$" Y="$y$" Z="$z$" :: Z("$tz$")+Y("$ty$")+X("$x$"), ID="$result);
	return (aV.z*(mMapSize.y*mMapSize.x))+(aV.y*mMapSize.x)+aV.x;
}


//=============================================================================
// Constructors
//=============================================================================
/*
static function X_COM_TacticalMap Construct(string aClassName = "", Vector aSize)
{
	local X_COM_TacticalMap lMap;
	lMap = Spawn(class'X_COM_TacticalMap');
	if(aClassName == "")
		aClassName = "X-COM_TACTICS.xcT_MapCell";
	lMap.SetMapCellClassName(aClassName);
	//lMap.CreateMap(aSize.X, aSize.Y, aSize.Z);
}*/
//========================================================
// Coordinates manipulation
//========================================================

function vector GetGridCoord(vector aLocation)
{
	local   vector  lNewLocation, lGridLocation, lGridSize;
	CheckLocationLimit(aLocation, lNewLocation);
	lGridSize = class'X_COM_Settings'.default.T_GridSize;
//	lGridLocation.X = lNewLocation.X * lGridSize.x + lGridSize.x/2;
//	lGridLocation.Y = lNewLocation.Y * lGridSize.y + lGridSize.y/2;
//	lGridLocation.Z = lNewLocation.Z * lGridSize.z + lGridSize.z/2;
	lGridLocation.X = int(lNewLocation.X / mMapSize.x) * lGridSize.x + lGridSize.x/2; // half grid size added
	lGridLocation.Y = int(lNewLocation.Y / mMapSize.y) * lGridSize.y + lGridSize.y/2; // half grid size added
	lGridLocation.Z = int(lNewLocation.Z / mMapSize.z) * lGridSize.z + lGridSize.z/2; // keep it little upper on the ground 
	return lGridLocation;
}

/** Check if location is out of location limits and correct it*/
function bool CheckLocationLimit(vector NowLocation, optional out vector NewLocation)
{
	local bool bIsInLimit;
	local Vector lLevelSize, lGridSize;
	lLevelSize = mMapSize;
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
function vector GetGridCrdFromLocation(vector aLocation)
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

function vector VfC(X_COM_MapCell aCell)
{
	local Vector r;
	r.X = aCell.x();
	r.Y = aCell.y();
	r.Z = aCell.z();

	return r;
}

static function vector GetLocationFromGridCrd(vector aGridNumber)
{
	local   vector lGridSize, lLocation;
	lGridSize = class'X_COM_Settings'.default.T_GridSize;
	lLocation.X = (aGridNumber.X+1./2)*lGridSize.X;
	lLocation.Y = (aGridNumber.Y+1./2)*lGridSize.Y;
	lLocation.Z = (aGridNumber.Z+1./2)*lGridSize.Z;
	return lLocation;
}

function vector GetLocationFromCell(X_COM_MapCell aCell)
{
	local   vector lGridSize, lLocation;
	lGridSize = class'X_COM_Settings'.default.T_GridSize;
	lLocation.X = (aCell.X()+1./2)*lGridSize.X;
	lLocation.Y = (aCell.Y()+1./2)*lGridSize.Y;
	lLocation.Z = ((aCell.Z())+1./2)*lGridSize.Z+(aCell.FloorHeight()+1./2);
	return lLocation;
}

function vector GetLocationFromCellByGridNumbers(vector aGridNumber)
{
	local X_COM_MapCell lCell;
	lCell = GetCell(aGridNumber.X, aGridNumber.Y, aGridNumber.Z);
	return GetLocationFromCell(lCell);
}

function SetMapCellClassName(string aClassName)
{
	if(aClassName == "")
	{
		`warn("Class name is empty. Using default...");
		aClassName = "X-COM_GAME.X_COM_MapCell";
	}

	mMapCellClass = aClassName;
}
function X_COM_MapCell CreateCell()
{
	local X_COM_MapCell lCell;
	if(mMapCellClass == "")
	{
		`warn("Invalid class name...");
		return none;
	}

	lCell = class'X_COM_MapCell'.static.Factory(mMapCellClass, self);
	return lCell;
}
//==================================================================================
/*function ConnectCells(X_COM_MapCell aCell, Edirection aDir, Ecell_type aType)
{
	local Vector d;

	d = aCell.CellCrd();
	d.X += dir[aDir].X;
	d.Y += dir[aDir].Y;
	d.Z += dir[aDir].Z;

	aCell.setDirectionType(aDir, aType);
	mMapGrid[IdFromVector(d)].setDirectionType(class'X_COM_MapCell'.static.OpositDirection(aDir), aType);
}*/

function X_COM_MapCell GetCell(int x, int y, int z)
{

	return mMapGrid[IdFromCrd(x, y, z)];
}
/**
 * Функция возвращает регион, начинающийся в точке aLeftTopCrd, размером aSize
 * 
 *//*
function array<X_COM_MapCell> GetRegion(vector aLeftTopCrd, vector aSize)
{
	local array<X_COM_MapCell> lCells;
	local int lX, lY, lZ;
	local int li, lj, lk;
	local bool lOutOfBounds, lStartBiggerThenFinish;

	lOutOfBounds = aLeftTopCrd.X >= mMapSize.X || aLeftTopCrd.Y >= mMapSize.Y || aLeftTopCrd.Z >= mMapSize.Z;
	lStartBiggerThenFinish = aLeftTopCrd.X > aSize.X || aLeftTopCrd.Y > aSize.Y || aLeftTopCrd.Z > aSize.Z;

	lX = aSize.X - aLeftTopCrd.X;
	lY = aSize.Y - aLeftTopCrd.Y;
	lZ = aSize.Z - aLeftTopCrd.Z;
	if(lOutOfBounds || lStartBiggerThenFinish)
	{
		return none;
	}
	for(li = 0; li < lZ; li++)
	{
		for(lj = 0; lj < lY; lj++)
		{
			for(lk = 0; lk < lX; lk++)
			{
				lCells.AddItem(mMapGrid[IdFromCrd(x, y, z)]);
			}
		}
	}
	return lCells;
}*/

function X_COM_MapCell SetCell(int x, int y, int z, optional Ecell_type aType = ct_NA, optional float aFloorHeight = -1)
{
	local int lid;

	lid = IdFromCrd(x, y, z);
	if(mMapGrid[lid] == none)
	{
		mMapGrid[lid] = CreateCell();
		//mMapGrid[lid] = new class'X_COM_MapCell';
		//mMapGrid[lid].SetMap(self);
	}

	mMapGrid[lid].x(x);
	mMapGrid[lid].y(y);
	mMapGrid[lid].z(z);
	mMapGrid[lid].id(lid);
	if(aType != ct_NA)
		mMapGrid[lid].CellType(aType);
	if(aFloorHeight != -1)
		mMapGrid[lid].FloorHeight(aFloorHeight);
	/*switch(aType)
	{
	case ct_obstacle:
		aDirs = mCompass.getStraightDirs();
		foreach aDirs(lCursor)
		{
			//lInd = class'X_COM_MapCell'.static.getDirection(ELatitude(i), 1, 1);
			mCompass.Set(lCursor);
			if(mCompass.X() != 0) lx = 1+mCompass.X(); else lx = 3;
			if(mCompass.y() != 0) ly = 1+mCompass.y(); else ly = 3;
			if(mCompass.z() != 0) lz = 1+mCompass.z(); else lz = 3;
			
			mMapGrid[IdFromCrd(x + mCompass.X(), y + mCompass.y(), z + mCompass.z())].setSideType(ct_obstacle, ELatitude(lx), ELongitude(ly), EElevation(lz), true);
		}
		/*for(i = 0; i < 3; i+=2)
		{
			lInd = class'X_COM_MapCell'.static.getDirection(ELatitude(i), 1, 1);
			if(dir[lInd].X != 0) lx = 1+dir[lInd].X; else lx = 3;
			if(dir[lInd].Y != 0) ly = 1+dir[lInd].Y; else ly = 3;
			if(dir[lInd].Z != 0) lz = 1+dir[lInd].Z; else lz = 3;
			
			mMapGrid[IdFromCrd(x + dir[lInd].X, y + dir[lInd].y, z + dir[lInd].z)].setSideType(ct_obstacle, ELatitude(lx), ELongitude(ly), EElevation(lz), true);
		}
		for(i = 0; i < 3; i+=2)
		{
			lInd = class'X_COM_MapCell'.static.getDirection(1, ELongitude(i), 1);
			if(dir[lInd].X != 0) lx = 1+dir[lInd].X; else lx = 3;
			if(dir[lInd].Y != 0) ly = 1+dir[lInd].Y; else ly = 3;
			if(dir[lInd].Z != 0) lz = 1+dir[lInd].Z; else lz = 3;
			
			mMapGrid[IdFromCrd(x + dir[lInd].X, y + dir[lInd].y, z + dir[lInd].z)].setSideType(ct_obstacle, ELatitude(lx), ELongitude(ly), EElevation(lz), true);
		}
		for(i = 0; i < 3; i+=2)
		{
			lInd = class'X_COM_MapCell'.static.getDirection(1, 1, EElevation(i));
			if(dir[lInd].X != 0) lx = 1+dir[lInd].X; else lx = 3;
			if(dir[lInd].Y != 0) ly = 1+dir[lInd].Y; else ly = 3;
			if(dir[lInd].Z != 0) lz = 1+dir[lInd].Z; else lz = 3;
			
			mMapGrid[IdFromCrd(x + dir[lInd].X, y + dir[lInd].y, z + dir[lInd].z)].setSideType(ct_obstacle, ELatitude(lx), ELongitude(ly), EElevation(lz), true);
		}*/

		/*for(i = 0; i < class'X_COM_MapCell'.const.DIRECTIONS_PURE; i++)
		{
			if(dir[i].X > 0) lx = 1+dir[i].X; else lx = 3;
			if(dir[i].Y > 0) ly = 1+dir[i].Y; else ly = 3;
			if(dir[i].Z > 0) lz = 1+dir[i].Z; else lz = 3;

			mMapGrid[IdFromCrd(x - dir[i].X, y - dir[i].y, z - dir[i].z)].setSideType(ct_obstacle, ELatitude(lx), ELongitude(ly), EElevation(lz), true);
		}*/
	}*/
// Создание маркера отладчика
	mMapGrid[lid].UpdateDebugInfo();
	return mMapGrid[lid];
	/*if(DEBUG_MAP == true)
	{
		if(aType == ct_obstacle) // создание марекра, если тип клетки - припятствие
		{
			if(mMapGrid[lid].DEBUG_TILE == none) // маркер создаётся только если ещё не создан
			{
				lLocation = GetLocationFromGridCrd(VfC(mMapGrid[lid]));
				lLocation.Z -= 64;
				lTile = spawn(class'X_COM_Tile', , , lLocation, rot(0,0,0), , true);
				lTile.AddStaticMesh(StaticMesh'FX_TacticalDebug.Meshes.TacticalDebug_Cell');
				mMapGrid[lid].DEBUG_TILE = lTile;
			}
		}
		else if(mMapGrid[lid].DEBUG_TILE != none) // удаление маркера, если в нём нет необходимости.
												  // Например, если клетка проходима.
		{
			mMapGrid[lid].DEBUG_TILE.Destroy();
		}
	}*/
}

function SetCellFromClass(X_COM_MapCell aCell)
{
	local int lid;
	lid = aCell.Id();
	mMapGrid[lid] = aCell;
	mMapGrid[lid].UpdateDebugInfo();
}

function vector MapSize()
{
	return mMapSize;
}


// Функция чтения по трёхмерным координатам


function X_COM_MapCell GetCellFromVector(Vector aV)
{
	if(IsCrdValid(aV))
		return mMapGrid[IdFromVector(aV)];
	else
		return none;
}

// Функция записи в трёхмерные координаты


function CreateMap(int x, int y, int z)
{
	//Очистка поля, если оно уже создано
	if(mMapGrid.Length > 0)
	{
		mMapGrid.Length = 0;
	}

	// задание размеров массива
	mMapSize.X = x;
	mMapSize.Y = y;
	mMapSize.Z = z;

	mMapGrid.Length = mMapSize.Z*mMapSize.Y*mMapSize.X; // размер поля в ячейках
	//mPathfinder.Construct(self);
}

function bool IsCrdValid(Vector aCrd)
{
	local bool x, y, z;
	x = (aCrd.X >= 0 && aCrd.X < mMapSize.X);
	y = (aCrd.Y >= 0 && aCrd.Y < mMapSize.Y);
	z = (aCrd.Z >= 0 && aCrd.Z < mMapSize.Z);

	return (x && y && z);
}/*
function X_COM_Node GetStartingNode()
{
	local X_COM_Node lNode;
	lNode = new class'X_COM_Node';
	lNode.Construct(GetCellFromVector(mStartPosition).Id(), none, 0, 0, EP_none, GetCellFromVector(mStartPosition));
	return lNode;
}

function X_COM_Node GetDestinationNode()
{
	local X_COM_Node lNode;
	lNode = new class'X_COM_Node';
	lNode.Construct(GetCellFromVector(mEndPosition).Id(), none, 0, 0, EP_none, GetCellFromVector(mEndPosition));
	return lNode;
}*/
/*
function int Heuristic(X_COM_MapCell aStart, X_COM_MapCell aEnd)
{
	local int counter;
	counter = (abs(aStart.X() - aEnd.X()) + abs(aStart.Y() - aEnd.Y()) + abs(aStart.Z() - aEnd.Z()))*4;
	return counter;
}*/

public function X_COM_PathFindingInterface GetPathFinder()
{
	local X_COM_PathFindingInterface lPFIn;
	mStartPosition.x = -1;
	mStartPosition.Y = -1;
	mStartPosition.Z = -1;
	mEndPosition = mStartPosition;

	lPFIn = class'X_COM_PathFindingInterface'.static.Construct(self, none, mPathfinder);
	return lPFIn;
}

public function X_COM_TacticalMap SetStartPosition(Vector aPosition)
{
	mStartPosition = aPosition;
	return self;
}

public function X_COM_TacticalMap SetEndPosition(Vector aPosition)
{
	mEndPosition = aPosition;
	return self;
}

public function bool IsWayCrdsValid()
{
	local bool lstart, lend;

	lstart = (mStartPosition.X != -1 && mStartPosition.Y != -1 && mStartPosition.Z != -1);
	lend = (mStartPosition.X != -1 && mStartPosition.Y != -1 && mStartPosition.Z != -1);
	
	Return lstart && lend;
}
/*
function array<X_COM_Node> GetChildNodes(vector aActualNode)
{
	local array<X_COM_Node> lNodes;
	local X_COM_Node lNode;
	local Vector lCrd;
	local int lid;
	local float lcost;
	local int lDir, lH;
	local EPosition lPos;
	
	for(lDir = 0; lDir < mCompass.const.DIRECTIONS_PURE; lDir++)
	{
		if(lDir != df_self)
		{

			lCrd = mCompass.GetNeighbor(aActualNode.Item().CellCrd(), Edirection(lDir));
			if(IsCrdValid(lCrd))
			{
				lCell = GetCell(lCrd.X, lCrd.Y, lCrd.Z);
				lPos = lCell.SelectMostOptimalMovement(aSender, Edirection(lDir), lPoints);

				//lid = IdFromVector(lCrd);
				//lPos = EPosition(mMapGrid[lid].SelectMostOptimalMovement(Edirection(lDir), lcost));

				// Если цена клетки равна -1, значит клетка непроходима для данного солдата
				//if(lcost > -1)
				//	lcost = aActualNode.mG_CurrentCost + lcost;
				//lNodes.Add(1);
				//lNodes[lNodes.Length-1] = new class'X_COM_Node';
				//lNodes[lNodes.Length-1].Construct(lid, aActualNode, lcost, getHeuristic(), GetCellFromVector(lCrd));
				lH = lCell.Heuristic
				lNode =  class'X_COM_Node'.static.Construct(lCell.Id(), aActualNode, lPoints, lH, lMovementType, lCell);
				lNode.Construct(lid, aActualNode, aActualNode.mG_CurrentCost + lcost, lH, EPosition(lPos), GetCellFromVector(lCrd));
				lNode.DebugOutput();
				lNodes.AddItem(lNode);
			}
		}
	}
	return lNodes;
}*/
/*public function X_COM_PathFinding GetPathFinder()
{
	local X_COM_MapCell lcell;
	local array<X_COM_Node> lList;
	if(IsWayCrdsValid())
	{
		lList = mPathfinder.FindPath();
		lcell = lList[0].mItem;
		return lList;
	}
	else
		`warn("ERROR: Incorrect start coordinates");
}*/
//var X_COM_AstarPathfinding  mAstar;

//=============================================================================
// Default properties
//=============================================================================
defaultproperties
{
	DEBUG_MAP = true
    Name="Default__X_COM_TacticalMap"
}