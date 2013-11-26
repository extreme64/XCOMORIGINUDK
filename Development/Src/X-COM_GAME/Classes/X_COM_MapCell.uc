/**
  Объект «Клетка карты»
Описывает клетку на сетке карты
	•	Порядковый номер - точный индекс в массиве, нужен для ссылок на него.
	•	Список собственных координат для сканирования соседей - точные координаты, по которым клетка находится на поле.
	•	Тип клетки - используется для определения возможности перемещения по ней, а также её цены.
*/
class X_COM_MapCell extends Object dependson(X_COM_Defines, X_COM_Direction, X_COM_Node);

var X_COM_TacticalMap mMap;

var int mId;
var protected int mX;
var protected int mY;
var protected int mZ;
//var private Vector mCoordinates;
var float mFloorHeight;
var X_COM_Tile DEBUG_TILE;

var public Ecell_type  mCellType; // Type of cell

/*
	df_nw_raise = 0,   df_n_raise = 1,  df_ne_raise = 2, 
	df_w_raise = 3,    df_raise = 4,    df_e_raise = 5,
	df_sw_raise = 6,   df_s_raise = 7,  df_se_raise = 8,

	df_nw = 9,         df_n = 10,        df_ne = 11, 
	df_w = 12,          df_self = 13,     df_e = 14,
	df_sw = 15,         df_s = 16,        df_se = 17,

	df_nw_lower = 18,   df_n_lower = 19,  df_ne_lower = 20, 
	df_w_lower = 21,    df_lower = 22,    df_e_lower = 23,
	df_sw_lower = 24,   df_s_lower = 25,  df_se_lower = 26,

	df_uninit
*/

/*enum ELatitude // По широте
{
	lt_W,
	lt_none,
	lt_E,
	NA,
};
enum ELongitude // По долготе
{

	ln_N,
	ln_none,
	ln_S,
	NA
};
enum EElevation // По высоте
{
	el_raise,
	el_none,
	el_lower,
	NA
};
enum EDirection 
{
	df_nw_raise,   df_n_raise,  df_ne_raise, 
	df_w_raise,    df_raise,    df_e_raise,
	df_sw_raise,   df_s_raise,  df_se_raise,

	df_nw,         df_n,        df_ne, 
	df_w,          df_self,     df_e,
	df_sw,         df_s,        df_se,

	df_nw_lower,   df_n_lower,  df_ne_lower, 
	df_w_lower,    df_lower,    df_e_lower,
	df_sw_lower,   df_s_lower,  df_se_lower,

	df_uninit  // направление не присвоено
};
*/
//const DIRECTIONS_PURE = 26;

struct RoutesCustomization
{
	var Edirection direction; // сторона, к которой относится настройка
	var Ecell_type type;    // класс стороны
};

var bool mIsPassable;
var array<RoutesCustomization> CustomRoutes; // Настройки проходимости отдельных сторон клетки

struct DirectionModifiers
{
	var int x, y, z;
};
/*	dir[df_w_raise].x   =-1; dir[df_w_raise].y         = 0; dir[df_w_raise].z         = 1;
	dir[df_e_raise].x   = 1; dir[df_e_raise].y        = 0; dir[df_e_raise].z        = 1;
	dir[df_n_raise].x   = 0; dir[df_n_raise].y           = 1; dir[df_n_raise].z           = 1;
	dir[df_s_raise].x   = 0; dir[df_s_raise].y         =-1; dir[df_s_raise].z         = 1;
	dir[df_nw_raise].x  =-1; dir[df_nw_raise].y      = 1; dir[df_nw_raise].z      = 1;
	dir[df_sw_raise].x  =-1; dir[df_sw_raise].y    =-1; dir[df_sw_raise].z    = 1;
	dir[df_ne_raise].x  = 1; dir[df_ne_raise].y     = 1; dir[df_ne_raise].z     = 1;
	dir[df_se_raise].x  = 1; dir[df_se_raise].y   =-1; dir[df_se_raise].z   = 1;
	dir[df_raise].x     = 0; dir[df_raise].y       = 0; dir[df_raise].z       = 1;

	dir[df_w].x              =-1; dir[df_w].y               = 0; dir[df_w].z               = 0;
	dir[df_e].x             = 1; dir[df_e].y              = 0; dir[df_e].z              = 0;
	dir[df_n].x                = 0; dir[df_n].y                 = 1; dir[df_n].z                 = 0;
	dir[df_s].x              = 0; dir[df_s].y               =-1; dir[df_s].z               = 0;
	dir[df_nw].x           =-1; dir[df_nw].y            = 1; dir[df_nw].z            = 0;
	dir[df_sw].x         =-1; dir[df_sw].y          =-1; dir[df_sw].z          = 0;
	dir[df_ne].x          = 1; dir[df_ne].y           = 1; dir[df_ne].z           = 0;
	dir[df_se].x        = 1; dir[df_se].y         =-1; dir[df_se].z         = 0;
	dir[df_self].x        = 0; dir[df_self].y         = 0; dir[df_self].z         = 0;

	

	dir[df_w_lower].x        =-1; dir[df_w_lower].y         = 0; dir[df_w_lower].z         =-1;
	dir[df_e_lower].x       = 1; dir[df_e_lower].y        = 0; dir[df_e_lower].z        =-1;
	dir[df_n_lower].x          = 0; dir[df_n_lower].y           = 1; dir[df_n_lower].z           =-1;
	dir[df_s_lower].x        = 0; dir[df_s_lower].y         =-1; dir[df_s_lower].z         =-1;
	dir[df_nw_lower].x     =-1; dir[df_nw_lower].y      = 1; dir[df_nw_lower].z      =-1;
	dir[df_sw_lower].x   =-1; dir[df_sw_lower].y    =-1; dir[df_sw_lower].z    =-1;
	dir[df_ne_lower].x    = 1; dir[df_ne_lower].y     = 1; dir[df_ne_lower].z     =-1;
	dir[df_se_lower].x  = 1; dir[df_se_lower].y   =-1; dir[df_se_lower].z   =-1;
	dir[df_lower].x      = 0; dir[df_lower].y       = 0; dir[df_lower].z       =-1;
*/
//var DirectionModifiers dir[DIRECTIONS_PURE];
//=============================================================================
// Constructors
//=============================================================================

static function X_COM_MapCell Factory(string aClassName, X_COM_TacticalMap aMap)
{
	local class<X_COM_MapCell> lCellName;
	local X_COM_MapCell lCell;
	if(aClassName == "")
	{
		`warn("Class name is not assigned");
		return none;
	}

	lCellName = class<X_COM_MapCell>(DynamicLoadObject(aClassName, class'Class'));
	//X_COM_MapCell(lCellName).SetMap(aMap);
	lCell = new lCellName;
	lCell.SetMap(aMap);
	return lCell;
}
//=============================================================================
// Properties
//=============================================================================
function int Id(optional int aId = -1)
{
	if(aId != -1)
		mId = aId;
	return mId;
}

function int X(optional int avalue = -1)
{
//	local int lId; 
	if(avalue != -1) mX = avalue;
//	lId = mMap.IdFromCrd(mX, mY, mZ);
	/*if(mId != lId)
	{
		Id(lId);
		//UpdateMap();
	}*/
	return mX;
}

function int Y(optional int avalue = -1)
{
//	local int lId;
	if(avalue != -1) mY = avalue;
//	lId = mMap.IdFromCrd(mX, mY, mZ);
	/*if(mId != lId)
	{
		Id(lId);
		//UpdateMap();
	}*/
	return mY;
}

function int Z(optional int avalue = -1)
{
//	local int lId;
	if(avalue != -1) mZ = avalue;
//	lId = mMap.IdFromCrd(mX, mY, mZ);
	/*if(mId != lId)
	{
		Id(lId);
		//UpdateMap();
	}*/
	return mZ;
}

function Ecell_type CellType(optional Ecell_type aType = ct_NA)
{
	if(aType != ct_NA)
		mCellType = aType;
	return mCellType;
}

function float FloorHeight(optional float aHeight = -1)
{
	if(aHeight != -1)
		mFloorHeight = aHeight;
	return mFloorHeight;
}
//=============================================================================
// Functions
//=============================================================================
function UpdateMap()	
{
	mMap.SetCellFromClass(self);
}

function SetMap(X_COM_TacticalMap aMap)
{
	mMap = aMap;
}

function vector Crd(optional int ax = -1, optional int ay = -1, optional int az = -1)
{
	local Vector lResult;
//	local int lId;

	if(ax != -1) mX = ax;
	lResult.X = mX;
	if(ay != -1) mY = ay;
	lResult.Y = mY;
	if(az != -1) mZ = az;
	lResult.Z = mZ;
//	lId = mMap.IdFromCrd(mX, mY, mZ);
	/*if(mId != lId)
	{
		Id(lId);
		//UpdateMap();
	}*/

	return lResult;
}

function vector CrdVector(Vector aVec)
{
	return Crd(aVec.x, aVec.y, aVec.z);
}
function vector Location(optional float ax = -1, optional float ay = -1, optional float az = -1)
{
	local Vector lcrd;
	lcrd = mMap.GetLocationFromGridCrd(Crd());
	if(ax > -1 || ay > -1 || az > -1)
	{
		if(ax > -1) lcrd.X = ax;
		if(ay > -1) lcrd.y = ay;
		if(az > -1) lcrd.z = az;
		CrdVector(mMap.GetGridCrdFromLocation(lcrd));
	}

	return lcrd;
}

function Copy(X_COM_MapCell aCell)
{
	X(aCell.X());
	Y(aCell.Y());
	Z(aCell.Z());

	mFloorHeight = aCell.mFloorHeight;
	mCellType   = aCell.mCellType;
}

function UpdateDebugInfo()
{
	local X_COM_Tile lTile;
	local Vector lLocation;

	if(mMap.DEBUG_MAP == true)
	{
		if(mCellType == ct_obstacle) // создание марекра, если тип клетки - припятствие
		{
			if(DEBUG_TILE == none) // маркер создаётся только если ещё не создан
			{
				lLocation = mMap.GetLocationFromGridCrd(Crd());
				lLocation.Z -= 64;
				lTile = mMap.spawn(class'X_COM_Tile', , , lLocation, rot(0,0,0), , true);
				lTile.AddStaticMesh(StaticMesh'TEST_TEMP.Meshes.obstacle');
				DEBUG_TILE = lTile;
			}
		}
		else if(DEBUG_TILE != none) // удаление маркера, если в нём нет необходимости.
												  // Например, если клетка проходима.
		{
			DEBUG_TILE.Destroy();
		}
	}
	else
	{
		if(DEBUG_TILE != none) // если маркер уже создан, а режим дебага выключен - удалить его
		{
			DEBUG_TILE.Destroy();
		}
	}
}
//=============================================================================
// Navigation functions
//=============================================================================

//static function Edirection getDirection(ELatitude aLatitude, ELongitude aLongitude, EElevation aElevation)
//{
//	return EDirection(aElevation*9+aLongitude*3+aLatitude);
//}

//function Edirection getDirFromVec(Vector dir)
//{
//	return EDirection(dir.Z*9+dir.Y*3+dir.X);
//}

//function vector getVecFromDir(Edirection dir)
//{
//	local Vector result;
//	result.Z = dir / 9;
//	result.Y = dir % 9 / 3;
//	result.X = dir % 9 % 3;
//	return result;
//}

//function ELatitude getLatFromDir(Edirection dir)
//{
//	return ELatitude(dir / 9);
//}

//function ELongitude getLongFromDir(Edirection dir)
//{
//	return ELongitude(dir % 9 / 3);
//}

//function EElevation getElevFromDir(Edirection dir)
//{
//	return EElevation(dir % 9 % 3);
//}




/*
function array<EDirection> GetSide(optional ELatitude aLatitude = -1, optional ELongitude aLongitude = -1, optional EElevation aElevation = -1)
{
	//local EDirection items;
	local int i, items;
	local array<EDirection> result;

	for(items = 0; items < DIRECTIONS_PURE; items++)
	{
		if(aElevation > -1)
		{
			i = getElevFromDir(EDirection(items));
			if(aElevation != i)
				continue;
		}
		if(aLongitude > -1)
		{
			i = getLongFromDir(EDirection(items));
			if(aLongitude != i)
				continue;
		}
		if(aLatitude > -1)
		{
			i = getLatFromDir(EDirection(items));
			if(aLatitude != i)
				continue;
		}
		result.AddItem(Edirection(items));
		//aElevation*9+aLongitude*3+lt_E;
	}
	return result;
}
*/
/*function EDirection GetSide(int )
{
	
}*/
/*function EDirection MirrorDirection(Edirection dir)
{
	local int x, y, z;
	x = getLatFromDir(dir);
	y = getLongFromDir(dir);
	z = getElevFromDir(dir);

}
static function EDirection OpositDirection(Edirection dir)
{
	
	return EDirection(DIRECTIONS_PURE - dir);
}
*/
function X_COM_MapCell GetNeighbor(EDirection aDir)
{
	local Vector lresult, ldest;
	local X_COM_Direction lDirection;
	lDirection = class'X_COM_Direction'.static.Construct(aDir);
	lresult = Crd();
	ldest = lDirection.GetNormalizedVector();
	lresult.X += ldest.X;
	lresult.Y += ldest.Y;
	lresult.Z += ldest.Z;

	return mMap.GetCellFromVector(lresult);

	//return lresult;
}

/*
function bool CanGoThroughCell(X_COM_MapCell aDest)
{
	local X_COM_MapCell lCell1, lCell2, lCell3;
	local Vector lLong, lLat;
	local X_COM_Direction lDir;

	//lDir = class'X_COM_Direction'.static.Construct(aDir);
	//lCell1 = GetNeighbor(lDir.Get()); // Получаем соседнюю клетку
	if(aDest != none)
	{
		if(aDest.CellType() != ct_obstacle && aDest.CellType() != ct_none) // проверяем, проходима ли соседняя клетка
		{
			if(lDir.IsDiagonal())
			{
				lLat = lDir.GetNormalizedVector(); // Получаем направление клетки
				lLong = lDir.GetNormalizedVector();
				lLat.X = 0; // Получаем направления по горизонтали и вертикали
				lLong.Y = 0;

				lCell2 = GetNeighbor(lDir.SetFromNormalizedVec(lLat).Get());
				if(lCell2 != none && lCell2.CellType() == ct_obstacle)
					return false;

				lCell3 = GetNeighbor(lDir.SetFromNormalizedVec(lLong).Get());
				if(lCell3 != none && lCell3.CellType() == ct_obstacle)
					return false;

				return true;
				/*if((lCell1.CellType() == ct_obstacle) || (lCell2.CellType() == ct_obstacle) || (lCell3.CellType() == ct_obstacle))
				{
					return false;
				}
				else
				{
					return true;
				}*/
			}
			else
				return true;
		}
		else
		{
			return false;
		}
	}
	else
		return false;
}*/

/*function bool CanBePassedFrom(EDirection aDir)
{
	
}*/
//======================================================================================

function setDirectionType(Edirection aDir, Ecell_type aType)
{
	local int i;
	i = CustomRoutes.Find('direction', aDir);
	CustomRoutes[i].type = aType;
}

function Ecell_type getDirectionType(EDirection aDir)
{
	local int i;
	i = CustomRoutes.Find('direction', aDir);
	if(i == -1)
	{
		return ct_NA;
	}
	return CustomRoutes[i].type;
}

/*function X_COM_MapCell getCellFromDirection(EDirection aDir)
{
	local int i;
	i = CustomRoutes.Find('direction', aDir);
	if(i == -1)
	{
		return ct_NA;
	}
	return CustomRoutes[i].type;
}*/


/*
static final preoperator X_COM_Direction ITERATE( out X_COM_Direction A )
{
	local EDirection dir;

	dir = EDirection(A.Get()+1);
	if(dir == df_self)
		dir = EDirection(dir+1);
	return A.Set(EDirection(dir));
}
*/
function bool IsPasable()
{
	return mIsPassable;
}
function bool CheckPassability()
{
	local X_COM_Direction lDirection;
	//local array<EDirection> lDirs;
	//local EDirection lDir;
	//local X_COM_MapCell lCell;

	lDirection = new class'X_COM_Direction';
	if(mCellType != ct_obstacle && mCellType != ct_none)
	{
		for(lDirection.Set(df_nw_raise); lDirection.Get()!= df_uninit; lDirection.Iterate())
		{
			if(CanGoThrough(lDirection.Get()))
			{
				return true;
			}
		}
	}
	return false;
}

function bool CanGoThrough(EDirection aDir)
{
	local X_COM_MapCell lCell1, lCell2, lCell3;
	local Vector lLong, lLat, lDirVec;
	local X_COM_Direction lDir;
	local EDirection lRev;

	lDir = class'X_COM_Direction'.static.Construct(aDir);
	lCell1 = GetNeighbor(aDir); // Получаем соседнюю клетку

	if(lCell1 != none)
	{
		if(lCell1.CellType() != ct_obstacle && lCell1.CellType() != ct_none) // проверяем, проходима ли соседняя клетка
		{
			if(lDir.IsDiagonal())
			{
				lLat = lDir.GetNormalizedVector(); // Получаем направление клетки
				lLong = lDir.GetNormalizedVector();
				//lElev = lDir.GetNormalizedVector();

				lLat.X = 0; // Получаем направления по горизонтали и вертикали
				lLong.Y = 0;


				lCell2 = GetNeighbor(lDir.SetFromNormalizedVec(lLat).Get());
				if(lCell2 != none && (lCell2.CellType() == ct_obstacle || lCell2.CellType() == ct_ladder))
					return false;

				lCell3 = GetNeighbor(lDir.SetFromNormalizedVec(lLong).Get());
				if(lCell3 != none && (lCell3.CellType() == ct_obstacle || lCell3.CellType() == ct_ladder))
					return false;

				/*if((lCell1.CellType() == ct_obstacle) || (lCell2.CellType() == ct_obstacle) || (lCell3.CellType() == ct_obstacle))
				{
					return false;
				}
				else
				{
					return true;
				}*/
			}
////// ЕСЛИ ЦЕЛЕВАЯ КЛЕТКА ЛЕСТНИЦА==================================================================
			if(lCell1.CellType() == ct_ladder)
			{
				if(mCellType == ct_passable)
				{
// Если мы таки двигаемся по одной и той же лестнице------------------------------------------
					if(mZ == lCell1.mZ)
					{
						// Проверяем, не пытается ли юнит сойти "за борт". По лестнице можно двигаться
						// либо вверх (в основном направлении), либо вниз (в противоположном направлении).
						
						//lMain = lCell1.CustomRoutes[0].direction;
						//lDirVec = lDir.Set(aDir).GetNormalizedVector();
						//lDirVec.Z = 0;
						//lRev = lDir.SetFromNormalizedVec(lDirVec).Get();
						if(lCell1.CustomRoutes[0].direction != aDir)
						{
							return false;
						}	
					}
// Спускаемся по лестнице---------------------------------------------------------------------
					else if(mZ > lCell1.mZ)
					{
						// Проверяем, двигаемся ли мы в противоположном направлении (коие является направлением спуска)
						

						//lMain = lCell1.CustomRoutes[0].direction;
						lDirVec = lDir.Set(aDir).GetNormalizedVector();
						lDirVec.Z = 0;
						lRev = lDir.SetFromNormalizedVec(lDirVec).Get();
						lDir.Set(lCell1.CustomRoutes[0].direction);
						if(lDir.Reverse().Get() != lRev)
						{
							return false;
						}
					}

				}
// Если мы это делаем с лестницы, значит мы либо двигаемся по лестнице, либо сходим с одной лестницы на другую
				else if(mCellType == ct_ladder)	
				{
					// Если мы таки двигаемся по одной и той же лестнице
					if(mZ == lCell1.mZ)
					{
						if(CustomRoutes[0].direction == lCell1.CustomRoutes[0].direction)
						{
							lDir.Set(CustomRoutes[0].direction);
							if(CustomRoutes[0].direction != aDir && lDir.Reverse().Get() != aDir)
							{
								return false;
							}	
						}
						// Проверяем, не пытается ли юнит сойти "за борт". По лестнице можно двигаться
						// либо вверх (в основном направлении), либо вниз (в противоположном направлении).
						
					}
					// Если мы спускаемся по лестнице на лестницу уровнем ниже
					else if(mZ > lCell1.mZ)
					{
						// Проверяем, двигаемся ли мы в противоположном направлении (коие является направлением спуска)
						lDir.Set(CustomRoutes[0].direction);
						if(lDir.Reverse().Get() != aDir)
						{
							return false;
						}
					}
					// Если мы поднимаемся с одной лестницы на другую
					else if(mZ < lCell1.mZ)
					{
						// Проверяем, двигаемся ли мы в основном направлении
						if(CustomRoutes[0].direction != aDir)
						{
							return false;
						}
					}
					
				}

				if(mZ < lCell1.mZ)
				{
					if(mCellType != ct_ladder || CustomRoutes[0].direction != aDir)
					{
						return false;
					}
				}	
			}

////// ЕСЛИ ЦЕЛЕВАЯ КЛЕТКА НЕ ЛЕСТНИЦА==================================================================
			else
			{
				if(mCellType == ct_passable)
				{
					// Если мы таки двигаемся по одной и той же лестнице
					if(mZ != lCell1.mZ)
					{
						return false;
					}
				}
				else if(mCellType == ct_ladder)	
				{
					// сходим с лестницы на землю
					if(mZ == lCell1.mZ)
					{
						lDir.Set(CustomRoutes[0].direction);
						if(lDir.Reverse().Get() != aDir)
						{
							return false;
						}
						
					}
					// Если мы поднимаемся на второй уровень по лестнице
					else if(mZ < lCell1.mZ)
					{
						// Проверяем, двигаемся ли мы в основном направлении
						lDirVec = lDir.Set(aDir).GetNormalizedVector();
						lDirVec.Z = 0;
						lRev = lDir.SetFromNormalizedVec(lDirVec).Get();
						lDir.Set(CustomRoutes[0].direction);
						if(lDir.Get() != lRev)
						{
							return false;
						}
					}
					
				}

				//if(mZ < lCell1.mZ)
				//{
				//	if(mCellType != ct_ladder || CustomRoutes[0].direction != aDir)
				//	{
				//		return false;
				//	}
				//}
				
			}
		}
		else
		{
			return false;
		}
	}
	else
		return false;

	return true;

	// OLD VERSION
	//local X_COM_MapCell lCell1, lCell2, lCell3;
	//local Vector lLong, lLat, lElev;
	//local X_COM_Direction lDir;

	//lDir = class'X_COM_Direction'.static.Construct(aDir);
	//lCell1 = GetNeighbor(aDir); // Получаем соседнюю клетку

	//if(lCell1 != none)
	//{
	//	if(lCell1.CellType() != ct_obstacle && lCell1.CellType() != ct_none) // проверяем, проходима ли соседняя клетка
	//	{
	//		if(lDir.IsDiagonal())
	//		{
	//			lLat = lDir.GetNormalizedVector(); // Получаем направление клетки
	//			lLong = lDir.GetNormalizedVector();
	//			lElev = lDir.GetNormalizedVector();

	//			lLat.X = 0; // Получаем направления по горизонтали и вертикали
	//			lLong.Y = 0;


	//			lCell2 = GetNeighbor(lDir.SetFromNormalizedVec(lLat).Get());
	//			if(lCell2 != none && lCell2.CellType() == ct_obstacle)
	//				return false;

	//			lCell3 = GetNeighbor(lDir.SetFromNormalizedVec(lLong).Get());
	//			if(lCell3 != none && lCell3.CellType() == ct_obstacle)
	//				return false;

	//			return true;
	//			/*if((lCell1.CellType() == ct_obstacle) || (lCell2.CellType() == ct_obstacle) || (lCell3.CellType() == ct_obstacle))
	//			{
	//				return false;
	//			}
	//			else
	//			{
	//				return true;
	//			}*/
	//		}
	//		else
	//			return true;
	//	}
	//	else
	//	{
	//		return false;
	//	}
	//}
	//else
	//	return false;
}

function X_COM_MapCell SelectMostOptimalMovement(X_COM_Sender aSender, EDirection aDirection, optional out EListType aListType, optional out EPosition aPosition, optional out float points)
{
//	local Vector lCrd1, lCrd2;//, lWay;
	local X_COM_Direction lDirection;
//	local EDirection ldir;
	local X_COM_MapCell lTarget;
	/*if(mMapGrid[aCellId].CellType)
		return TUperStepOnLand;*/
	/** @todo
	 *  Добавить проверку на тип клетки, добавить проверку её на проходимость.*/
	
	//lFrom = aFrom.CellCrd();
	//lDest = aDest.CellCrd();
	//lCompass = class'X_COM_Compass'.static.GetInstance();
	//ldir = lCompass.DirectionToCell(lFrom, lDest).Get();
	//if(aDirection != df_uninit)
	//{
	//	if(aDest.getDirectionType(aDirection) == ct_obstacle)
	//		return EP_NotPassable;
	//}
	//if(!( aDest.CellType() == ct_obstacle || aDest.CellType() == ct_none))
	//{
	//	points = class'X_COM_MovementRules'.const.TUperStep;
	//	if(lCompass.IsDiagonal())
	//		points *= 1.4;
	//	return EP_Standing;
	//}
	//else
	//	return EP_NotPassable;

	lDirection = class'X_COM_Direction'.static.Construct(aDirection);
	if(aDirection != df_uninit && aDirection != df_self)
	{
		lTarget = GetNeighbor(aDirection);
		if(lTarget != none)
		{
			if(!lTarget.IsPasable())
			{
				aListType = lt_ClosedList;
				return lTarget;
			}
			if(!CanGoThrough(aDirection))
			{
				aListType = lt_none;
				return lTarget;
			}
			points = 5;
			if(lDirection.IsDiagonal())
			{
				points *= 1.4;
			}
			aListType = lt_OpenList;
		}
		return lTarget;
	}
	/*
	if(aDirection != df_uninit && aDirection != df_self)
	{
		if(getDirectionType(aDirection) == ct_obstacle)
			return EP_none;

		if(!(mCellType == ct_obstacle || mCellType == ct_none))
		{
			points = class'X_COM_MovementRules'.const.TUperStep;
			/*if(mMap.mCompass.Set(aDirection).IsDiagonal())
			{
				//lCrd1 = lCrd2 = Crd();
				//lCrd1.X += Crd()-;
				//lCrd2.Y-=1;
				if(mMap.mMapGrid[mMap.IdFromVector(lCrd1)].CellType == ct_obstacle || mMap.mMapGrid[mMap.IdFromVector(lCrd2)].CellType == ct_obstacle)
				points *= 1.4;
			}*/
			return EP_Standing;
		}
		else
		{
			return EP_none;
		}
	}*/
}

/**
setSideType(optional ELatitude aLatitude = -1, optional ELongitude aLongitude = -1, optional EElevation aElevation = -1, bool aRevers, Ecell_type aType)
Функция меняет класс сразу целой стороны ячейки.
	@param optional ELatitude aLatitude = -1 - положение по широте (если не указан, выбираются сразу все широты)
	@param optional ELongitude aLongitude = -1 - положение по долготе (если не указан, выбираюся сразу все долготы)
	@param optional EElevation aElevation = -1 - положение по высоте (если не указан, выбираются сразу все высоты)
	@param bool aRevers - для выбора стороны, противоположной указанной (используется, для назначения класса стороне, смежной со стороной другой клетки)
	@param Ecell_type aType - значение, назначаемое стороне
 */
/*
function setSideType(Ecell_type aType, optional ELatitude aLatitude = NA, optional ELongitude aLongitude = NA, optional EElevation aElevation = NA, optional bool aRevers = false)
{
	local int i, items;
	local array<EDirection> result;

	/*for(items = 0; items < DIRECTIONS_PURE; items++)
	{
		if(aElevation != NA)
		{

			i = getElevFromDir(EDirection(items));
			if(aElevation != i)
				continue;
		}
		if(aLongitude != NA)
		{
			i = getLongFromDir(EDirection(items));
			if(aLongitude != i)
				continue;
		}
		if(aLatitude != NA)
		{
			i = getLatFromDir(EDirection(items));
			if(aLatitude != i)
				continue;
		}

		if(aRevers)
				i = OpositDirection(Edirection(items));
		i = CustomRoutes.Find('direction', Edirection(i));
		if(i == INDEX_NONE)
		{
			CustomRoutes.Add(1);
			CustomRoutes[CustomRoutes.Length-1].direction = Edirection(items);
			CustomRoutes[CustomRoutes.Length-1].type = aType;
		}
		else
		{
			CustomRoutes[i].type = aType;
		}
		//aElevation*9+aLongitude*3+lt_E;
	}*/
}*/
//=============================================================================
// Default properties
//=============================================================================
defaultproperties
{
/*
	dir[df_nw_raise]    = (-1, 1, 1)
	dir[df_n_raise]     = (0, 1, 1)
	dir[df_ne_raise]    = (1, 1, 1)
	dir[df_w_raise]     = (-1, 0, 1)
	dir[df_raise]       = (0, 0, 1)
	dir[df_e_raise]     = (1, 0, 1)
	dir[df_sw_raise]    = (-1, -1, 1)	
	dir[df_s_raise]     = (0, -1, 1)
	dir[df_se_raise]    = (1, -1, 1)
	

	dir[df_w]           = (-1, 0, 0)
	dir[df_e]           = (1, 0, 0)
	dir[df_n]           = (0, 1, 0)
	dir[df_s]           = (0, -1, 0)
	dir[df_nw]          = (-1, 1, 0)
	dir[df_sw]          = (-1, -1, 0)
	dir[df_ne]          = (1, 1, 0)
	dir[df_se]          = (1, -1, 0)
	dir[df_self]        = (0, 0, 0)

	dir[df_w_lower]     = (-1, 0, -1)
	dir[df_e_lower]     = (1, 0, -1)
	dir[df_n_lower]     = (0, 1, -1)
	dir[df_s_lower]     = (0, -1, -1)
	dir[df_nw_lower]    = (-1, 1, -1)
	dir[df_sw_lower]    = (-1, -1, -1)
	dir[df_ne_lower]    = (1, 1, -1)
	dir[df_se_lower]    = (1, -1, -1)
	dir[df_lower]       = (0, 0, -1)
*/



/*
	dir[df_w_raise].x   = (-1, 0, 1)
	dir[df_w_raise].y   = 0;
	dir[df_w_raise].z   = 1;

	dir[df_e_raise].x   = 1;
	dir[df_e_raise].y   = 0;
	dir[df_e_raise].z   = 1;

	dir[df_n_raise].x   = 0;
	dir[df_n_raise].y   = 1;
	dir[df_n_raise].z   = 1;

	dir[df_s_raise].x   = 0;
	dir[df_s_raise].y   =-1;
	dir[df_s_raise].z   = 1;

	dir[df_nw_raise].x  =-1;
	dir[df_nw_raise].y  = 1;
	dir[df_nw_raise].z  = 1;

	dir[df_sw_raise].x  =-1;
	dir[df_sw_raise].y  =-1;
	dir[df_sw_raise].z  = 1;

	dir[df_ne_raise].x  = 1;
	dir[df_ne_raise].y  = 1;
	dir[df_ne_raise].z  = 1;

	dir[df_se_raise].x  = 1;
	dir[df_se_raise].y  =-1;
	dir[df_se_raise].z  = 1;

	dir[df_raise].x     = 0;
	dir[df_raise].y     = 0;
	dir[df_raise].z     = 1;



	dir[df_w].x         =-1;
	dir[df_w].y         = 0;
	dir[df_w].z         = 0;

	dir[df_e].x         = 1;
	dir[df_e].y         = 0;
	dir[df_e].z         = 0;

	dir[df_n].x         = 0;
	dir[df_n].y         = 1;
	dir[df_n].z         = 0;

	dir[df_s].x         = 0;
	dir[df_s].y         =-1;
	dir[df_s].z         = 0;

	dir[df_nw].x        =-1;
	dir[df_nw].y        = 1;
	dir[df_nw].z        = 0;

	dir[df_sw].x        =-1;
	dir[df_sw].y        =-1;
	dir[df_sw].z        = 0;

	dir[df_ne].x        = 1;
	dir[df_ne].y        = 1;
	dir[df_ne].z        = 0;

	dir[df_se].x        = 1;
	dir[df_se].y        =-1;
	dir[df_se].z        = 0;

	dir[df_self].x      = 0;
	dir[df_self].y      = 0;
	dir[df_self].z      = 0;

	

	dir[df_w_lower].x   =-1;
	dir[df_w_lower].y   = 0;
	dir[df_w_lower].z   =-1;

	dir[df_e_lower].x   = 1;
	dir[df_e_lower].y   = 0;
	dir[df_e_lower].z   =-1;

	dir[df_n_lower].x   = 0;
	dir[df_n_lower].y   = 1;
	dir[df_n_lower].z   =-1;

	dir[df_s_lower].x   = 0;
	dir[df_s_lower].y   =-1;
	dir[df_s_lower].z   =-1;

	dir[df_nw_lower].x  =-1;
	dir[df_nw_lower].y  = 1;
	dir[df_nw_lower].z  =-1;

	dir[df_sw_lower].x  =-1;
	dir[df_sw_lower].y  =-1;
	dir[df_sw_lower].z  =-1;

	dir[df_ne_lower].x  = 1;
	dir[df_ne_lower].y  = 1;
	dir[df_ne_lower].z  =-1;

	dir[df_se_lower].x  = 1;
	dir[df_se_lower].y  =-1;
	dir[df_se_lower].z  =-1;

	dir[df_lower].x     = 0;
	dir[df_lower].y     = 0;
	dir[df_lower].z     =-1;
*/
    Name="Default__X_COM_MapCell"	
}