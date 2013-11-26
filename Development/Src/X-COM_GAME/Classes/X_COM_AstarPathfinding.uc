Class X_COM_AstarPathfinding extends Object dependson(X_COM_ListElem, X_COM_MapCell, X_COM_Defines);
/*
//=============================================================================
// Debug
//=============================================================================
var protected bool DEBUG_PATHFINDING;

//=============================================================================
// Variables: Pawn and map
//=============================================================================
var protected X_COM_Unit        mPawn; // Ссылка на двигающийся объект
//var xcT_LevelManager            mLevelManager; // Класс, управляющий уровнем
var array<X_COM_MapCell>        mMapGrid;
var X_COM_TacticalMap           mMap;
//=============================================================================
// Variables: Movement
//=============================================================================
var private Vector              mMoveDestination, TempDest;
var private Vector              mStartCell, mEndCell, mDesiredEndCell;
var protected X_COM_ListElem    mSelected;
var protected bool              bShouldWalk;

var private int mi;                     // Counter

var array<X_COM_Tile> TEST_TEMP_OBJECTS; //TEST TEMP

//=============================================================================
// Variables: Path-Finding
//=============================================================================
var private array<vector>       mWaypoints;

/**
	Массив вейпоинтов
В даный массив записываются данные о клетках, как объектах поиска путей. В дальнейшем даный список будет
делиться на открытый и закрытый список. Хитрость сделана, чтобы не терять информацию о клетках при перемещении
в открытые-закрытые списки.
 */
var array<X_COM_ListElem> mWPList;

/**
	Открытый список
Динамический массив, в который помещаются текущие проверяемые клетки.
*/
var array<X_COM_ListElem> mOpenList;
//var array<int> bOpenListIndex; // Массив индексов, позволяющий производить итерацию по существующим элементам списка.
/**
	Закрытый список 
Статический массив размером со всю карту, хранящий информацию об уже проверенных элементах.
При каждой проверке клетки, проверяется, находится ли она в закрытом списке, и если да,
поиск прерывается, если нет – она заносится в список, и поиск продолжается.
Записи в массив производятся по порядковому номеру проверяемой ячейки для более быстрого поиска.
Объект закрытого списка – пока что булев объект. В большем смысла не вижу.

*/
//var array<ListElement> mClosedList;      // Сам список.
var array<X_COM_ListElem> mClosedList; // Массив ссылок, позволяющий производить итерацию по существующим элементам списка.

// Направления движения
//Костыль для выбора, для какого из списков применять функцию.
//Добавляю, потому что мозги в говно и ничего лучше придумать не могут.
/*Enum EListType
{
	lt_OpenList,
	lt_ClosedList
};*/

enum Edirection_from 
{
	df_left_up,     df_up,      df_right_up, 
	df_left,                    df_right,
	df_left_down,   df_down,    df_right_down,

	df_left_up_raise,     df_up_raise,      df_right_up_raise, 
	df_left_raise,        df_center_raise,  df_right_raise,
	df_left_down_raise,   df_down_raise,    df_right_down_raise,

	df_left_up_lower,     df_up_lower,      df_right_up_lower, 
	df_left_lower,        df_center_lower,   df_right_lower,
	df_left_down_lower,   df_down_lower,    df_right_down_lower,

	df_uninit  // направление не присвоено
};

//`define DIRECTIONS_ALL 27
//`define DIRECTIONS_PURE 26

var int DIRECTIONS_PURE;

var private vector dir[26]; // basic directions

//=============================================================================
// Events
//=============================================================================

event PreDispatch()
{
//	//mLevelManager = xcT_GameInfo(WorldInfo.Game).TLevelManager;
//	//mMapGrid = X_COM_GameInfo(WorldInfo.game).TLevelManager.mMapGrid;
//	mWPList.Length = mLevelManager.mMapSize.Z*mLevelManager.mMapSize.Y*mLevelManager.mMapSize.X;
//	//mClosedList.Length = mLevelManager.mMapSize.Z*mLevelManager.mMapSize.Y*mLevelManager.mMapSize.X;
	//DIRECTIONS_PURE = 26;
//// инициализация массива простейших направлений

	//dir[df_left].x      =-1; dir[df_left].y         = 0; dir[df_left].z         =0;
	//dir[df_right].x     = 1; dir[df_right].y        = 0; dir[df_right].z        =0;
	//dir[df_up].x        = 0; dir[df_up].y           = 1; dir[df_up].z           =0;
	//dir[df_down].x      = 0; dir[df_down].y         =-1; dir[df_down].z         =0;
	//dir[df_left_up].x   =-1; dir[df_left_up].y      = 1; dir[df_left_up].z      =0;
	//dir[df_left_down].x =-1; dir[df_left_down].y    =-1; dir[df_left_down].z    =0;
	//dir[df_right_up].x  = 1; dir[df_right_up].y     = 1; dir[df_right_up].z     =0;
	//dir[df_right_down].x= 1; dir[df_right_down].y   =-1; dir[df_right_down].z   =0;

	//dir[df_left_raise].x        =-1; dir[df_left_raise].y         = 0; dir[df_left_raise].z         =1;
	//dir[df_right_raise].x       = 1; dir[df_right_raise].y        = 0; dir[df_right_raise].z        =1;
	//dir[df_up_raise].x          = 0; dir[df_up_raise].y           = 1; dir[df_up_raise].z           =1;
	//dir[df_down_raise].x        = 0; dir[df_down_raise].y         =-1; dir[df_down_raise].z         =1;
	//dir[df_left_up_raise].x     =-1; dir[df_left_up_raise].y      = 1; dir[df_left_up_raise].z      =1;
	//dir[df_left_down_raise].x   =-1; dir[df_left_down_raise].y    =-1; dir[df_left_down_raise].z    =1;
	//dir[df_right_up_raise].x    = 1; dir[df_right_up_raise].y     = 1; dir[df_right_up_raise].z     =1;
	//dir[df_right_down_raise].x  = 1; dir[df_right_down_raise].y   =-1; dir[df_right_down_raise].z   =1;
	//dir[df_center_raise].x      = 0; dir[df_center_raise].y       = 0; dir[df_center_raise].z       =1;

	//dir[df_left_lower].x        =-1; dir[df_left_lower].y         = 0; dir[df_left_lower].z         =-1;
	//dir[df_right_lower].x       = 1; dir[df_right_lower].y        = 0; dir[df_right_lower].z        =-1;
	//dir[df_up_lower].x          = 0; dir[df_up_lower].y           = 1; dir[df_up_lower].z           =-1;
	//dir[df_down_lower].x        = 0; dir[df_down_lower].y         =-1; dir[df_down_lower].z         =-1;
	//dir[df_left_up_lower].x     =-1; dir[df_left_up_lower].y      = 1; dir[df_left_up_lower].z      =-1;
	//dir[df_left_down_lower].x   =-1; dir[df_left_down_lower].y    =-1; dir[df_left_down_lower].z    =-1;
	//dir[df_right_up_lower].x    = 1; dir[df_right_up_lower].y     = 1; dir[df_right_up_lower].z     =-1;
	//dir[df_right_down_lower].x  = 1; dir[df_right_down_lower].y   =-1; dir[df_right_down_lower].z   =-1;
	//dir[df_center_lower].x      = 0; dir[df_center_lower].y       = 0; dir[df_center_lower].z       =-1;
}


//=============================================================================
// Functions
//=============================================================================

function SetMap(X_COM_TacticalMap aMap)
{
	mMap = aMap;
}

function SetBuferLength(Vector size)
{
	mWPList.Length = size.Z * size.Y * size.X;
}
function Init(X_COM_TacticalMap aMap)
{
	SetMap(aMap);
	//mWPList.Length = mMap.MapSize().Z*mMap.MapSize().Y*mMap.MapSize().X;
	SetBuferLength(mMap.MapSize());
	//mClosedList.Length = mLevelManager.mMapSize.Z*mLevelManager.mMapSize.Y*mLevelManager.mMapSize.X;
	DIRECTIONS_PURE = 26;
// инициализация массива простейших направлений

	dir[df_left].x      =-1; dir[df_left].y         = 0; dir[df_left].z         =0;
	dir[df_right].x     = 1; dir[df_right].y        = 0; dir[df_right].z        =0;
	dir[df_up].x        = 0; dir[df_up].y           = 1; dir[df_up].z           =0;
	dir[df_down].x      = 0; dir[df_down].y         =-1; dir[df_down].z         =0;
	dir[df_left_up].x   =-1; dir[df_left_up].y      = 1; dir[df_left_up].z      =0;
	dir[df_left_down].x =-1; dir[df_left_down].y    =-1; dir[df_left_down].z    =0;
	dir[df_right_up].x  = 1; dir[df_right_up].y     = 1; dir[df_right_up].z     =0;
	dir[df_right_down].x= 1; dir[df_right_down].y   =-1; dir[df_right_down].z   =0;

	dir[df_left_raise].x        =-1; dir[df_left_raise].y         = 0; dir[df_left_raise].z         =1;
	dir[df_right_raise].x       = 1; dir[df_right_raise].y        = 0; dir[df_right_raise].z        =1;
	dir[df_up_raise].x          = 0; dir[df_up_raise].y           = 1; dir[df_up_raise].z           =1;
	dir[df_down_raise].x        = 0; dir[df_down_raise].y         =-1; dir[df_down_raise].z         =1;
	dir[df_left_up_raise].x     =-1; dir[df_left_up_raise].y      = 1; dir[df_left_up_raise].z      =1;
	dir[df_left_down_raise].x   =-1; dir[df_left_down_raise].y    =-1; dir[df_left_down_raise].z    =1;
	dir[df_right_up_raise].x    = 1; dir[df_right_up_raise].y     = 1; dir[df_right_up_raise].z     =1;
	dir[df_right_down_raise].x  = 1; dir[df_right_down_raise].y   =-1; dir[df_right_down_raise].z   =1;
	dir[df_center_raise].x      = 0; dir[df_center_raise].y       = 0; dir[df_center_raise].z       =1;

	dir[df_left_lower].x        =-1; dir[df_left_lower].y         = 0; dir[df_left_lower].z         =-1;
	dir[df_right_lower].x       = 1; dir[df_right_lower].y        = 0; dir[df_right_lower].z        =-1;
	dir[df_up_lower].x          = 0; dir[df_up_lower].y           = 1; dir[df_up_lower].z           =-1;
	dir[df_down_lower].x        = 0; dir[df_down_lower].y         =-1; dir[df_down_lower].z         =-1;
	dir[df_left_up_lower].x     =-1; dir[df_left_up_lower].y      = 1; dir[df_left_up_lower].z      =-1;
	dir[df_left_down_lower].x   =-1; dir[df_left_down_lower].y    =-1; dir[df_left_down_lower].z    =-1;
	dir[df_right_up_lower].x    = 1; dir[df_right_up_lower].y     = 1; dir[df_right_up_lower].z     =-1;
	dir[df_right_down_lower].x  = 1; dir[df_right_down_lower].y   =-1; dir[df_right_down_lower].z   =-1;
	dir[df_center_lower].x      = 0; dir[df_center_lower].y       = 0; dir[df_center_lower].z       =-1;
}
delegate vector CrdTransformFunction(vector aGridNumber);

function float IsDiagonal(vector aFrom, vector aDest)
{
	local bool x, y, z;

	x = aFrom.X != aDest.X;
	y = aFrom.Y != aDest.Y;
	z = aFrom.Z != aDest.Z;
	if((x && y) || (y && z) || (x && z))
		return 1.4;
	else
		return 1;
}
/**
	Функция «Найти наиболее оптимальный способ перемещения» - SelectMostOptimalMovement(X_COM_Pawn aUnit, int aCellId)
	Параметры:
		aUnit - Ссылка на юнита, выполняющего попытку перемещения.
		aCellId - Порядковый номер клетки, с которой происходит сравнение.
Сравнивает каждый способ перемещения, доступный юниту, с каждым способом перемещения в белом списке.
Если тип есть, то чёрный список не проверяется. Иначе проверяется, есть ли дефолтное значение, и если есть,
проверяется чёрный список, и если в нём нет данного типа перемещения, то используется дефолтная цена.
Также доступны 3 условия проверки на фиксированность типа:
	1.	Нефиксированный – при перемещении юнит использует наиболее выгодный способ перемещения.
	2.	Условно-фиксированный – юнит использует указанный способ перемещения, за исключением ситуаций,
		если он запрещён для данной клетки. Тогда используется наиболее выгодный для неё.
	3.	Фиксированный – юнит использует только выбранный способ перемещения. Все клетки,
		для которых он недоступен, считаются непроходимыми.

Способы подсчёта значения также могут быть различными. Я потом обдумаю эту тему,
а пока что у клетки будет множитель для скорости юнита, и результирующей ценой клетки будет P = S * M,
где S – скорость текущего способа перемещения юнита, а M – множитель клетки.
*/

function EPosition SelectMostOptimalMovement(X_COM_Unit aUnit, X_COM_ListElem aFrom, X_COM_MapCell aDest, optional out float points)
{
	local Vector lFrom, lDest;//, lWay;
	local EDirection ldir;
	local X_COM_Direction lDirection;
	/*if(mMapGrid[aCellId].CellType)
		return TUperStepOnLand;*/
	/** @todo
	 *  Добавить проверку на тип клетки, добавить проверку её на проходимость.*/
	
	lFrom = aFrom.cell.Crd();
	lDest = aDest.Crd();
	lDirection = new class'X_COM_Direction';
	/*lWay = lDest - lFrom;
	lWay.X += 1;
	lWay.Y += 1;
	lWay.Z += 1;*/
	//if()
	ldir = lDirection.DirectionToCrd(lFrom, lDest).Get();
	if(ldir != df_uninit)
	{
		if(aDest.getDirectionType(ldir) == ct_obstacle)
			return EP_none;
	}
	if(!( aDest.CellType() == ct_obstacle || aDest.CellType() == ct_none))
	{
		points = class'X_COM_MovementRules'.const.TUperStep;
		if(lDirection.IsDiagonal())
			points *= 1.4;
		return EP_Standing;
	}
	else
		return EP_none;
}
/**
 * Open list functions
 */

function int MoveToOpenList(X_COM_ListElem lElem)
{
	if(lElem == none)
	{
		lElem = new class'X_COM_ListElem';
		lElem.Init(self);
	}
	lElem.ListType = lt_OpenList;
	mOpenList.AddItem(lElem);

//	mOpenList[lElem.cell.Id()] = lElem;
//	mOpenList[lElem.cell.Id()].Enabled = true;

	return mOpenList.Length-1;
}

function int AddToOpenList(int id, X_COM_MapCell cell, X_COM_ListElem parent, int G, int H)
{
	//local int c;

	if(mWPList[id] == none)
		mWPList[id] = new class'X_COM_ListElem';
	mOpenList.AddItem(mWPList[id].SetParams(id, cell, parent, G, H, lt_Openlist));
	//aElem = mOpenList[mOpenList.Length-1];
	/*
	mOpenList.Add(1); 
	c = mOpenList.Length-1;
	mOpenList[c].id = cell.Id();
	mOpenList[c].cell = cell;
	mOpenList[c].parent = parent;
	mOpenList[c].G = G;
	mOpenList[c].H = H;
	mOpenList[c].Enabled = true;*/

	return mOpenList.Length-1;
}

function X_COM_ListElem FindByCellId(int aId)
{
	if(mWPList[aId] != none && mWPList[aId].ListType != lt_None)
		return mWPList[aId];
	else
		return none;
	/*if(aType == lt_OpenList)
		return mOpenList.Find('Id', aId);
	if(aType == lt_ClosedList)
		return aId;*/
	/*local int lI;
	local ListElement lElem;

	foreach mOpenList(lElem, lI)
	{
		if(lElem.cellId == aId)
			return lI;
	}
	return -1;*/
}

/**

	Функция «Вернуть результирующий путь» - ReturnWayToCell(ListElement aElem, optional delegate<WPFunc> aWPFunc, out int aSumm)
Поскольку при каждом переходе на следующую клетку, мы записываем клетку, с которой мы пришли,
фактически поиск пути обратно к точке старта сводится к рекурсивному движению по ссылке на предка,
до достижения самого начала списка – это и есть наш путь. Функция возвращает путь и/или сумму найденного пути.
	Параметры:
		@param aElem - порядковый номер клетки, от которой производится обратное движение.
		@param aWPFunc - математическая функция, применяемая к клетке перед записью в массив.
		@param aSumm - ссылка на переменную, в которую будет записана сумма найденного пути.
*/
//delegate vector WPFunc(vector aGridNumber);

function array<vector> ReturnWayToCell(X_COM_ListElem aElem, delegate<CrdTransformFunction> aWPFunc, optional out int aSumm)
{
	local X_COM_ListElem lCE;
	local array<Vector> lResult;
	local Vector lVector;
	//local array<X_COM_ListElem> lList;
	local float lPrice;

	//lResult.Lenght = 0;
	/*if(aType == lt_OpenList)
		lList = mOpenList;
	else if(aType == lt_ClosedList)
		lList = mClosedList;*/

	aSumm = 0;
	lCE = aElem;

	/*while(mWPList[lCE].parent!=none)
	{
		// Пока что буду подсчитывать путь по константным ячейкам, но потом каждому типу ячейки присвою свои характеристики,
		// и буду брать их честно.
		SelectMostOptimalMovement(X_COM_Pawn(Pawn), lList[lCE].cell.Id(), lPrice);
		aSumm += lPrice;
		lVector.X = mMapGrid[lList[lCE].cell.Id()].x;
		lVector.y = mMapGrid[lList[lCE].cell.Id()].y;
		lVector.z = mMapGrid[lList[lCE].cell.Id()].z;
		if(aWPFunc == none)
		{
			lResult.AddItem(lVector);
		}
		else
			lResult.AddItem(aWPFunc(lVector));
		lCE = FindByCellId(aType, lList[lCE].parent.Id());
	}
*/
	while(lCE!=none)
	{
		// Пока что буду подсчитывать путь по константным ячейкам, но потом каждому типу ячейки присвою свои характеристики,
		// и буду брать их честно.
		SelectMostOptimalMovement(mPawn, lCE.parent, lCE.cell, lPrice);
		aSumm += lPrice;
		lVector.X = lCE.cell.x();
		lVector.y = lCE.cell.y();
		lVector.z = lCE.cell.z();
		if(aWPFunc == none)
		{
			lResult.AddItem(lVector);
		}
		else
			lResult.AddItem(aWPFunc(lVector));
		if(lCE.parent != none)
			lCE = FindByCellId(lCE.parent.Id());
		else
			lCE = none;
	}
	return lResult;
}

/**
	Функция GetG(X_COM_ListElem aElem)
Функция ищет G точки.
	@param X_COM_ListElem aElem - элемент, чей G расчитываем
*/
function int GetG(X_COM_ListElem aElem, optional X_COM_ListElem aFrom = none)
{
	local float lPrice;
	local X_COM_ListElem lFrom;
	if(aFrom != none)
		lFrom = aFrom;
	else if(aElem.parent != none)
		lFrom = aElem.parent;
	else
	{
		`log("GetG :: Parent not assigned!");
		return 0;
	}

	SelectMostOptimalMovement(mPawn, lFrom, aElem.cell, lPrice);
	if(lFrom != none)
		return lPrice + mWPList[lFrom.cell.Id()].G;
	else
		return lPrice;
}
/**
 * Closed List functions
 */
/**
	Функция «Проверить наличие в закрытом списке» - InClosedList(int aId)
	Параметры:
		aId - Порядковый номер клетки, наличие который нужно проверить
Проверяет, существует ли в закрытом списке запись по объекту текущего порядкового номера? Возвращает true или false.
*/

/*function bool InClosedList(int aId)
{
	if(mClosedList[aId].Enabled == false)
		return false;
	else
		return true;
}*/
/**
	Функция «Добавить в закрытый список» - AddToClosedList(ListElement lElem)
Добавляет ячейку в закрытый список.	
	Параметры:
		@param lElem - объект, которую нужно добавить в список.

*/

function int MoveToClosedList(X_COM_ListElem lElem)
{
	/*mClosedList[lElem.cell.Id()] = lElem;
	mClosedList[lElem.cell.Id()].Enabled = true;
	mClosedListIndex.AddItem(lElem.cell.Id());*/
	if(lElem == none)
	{
		lElem = new class'X_COM_ListElem';
		lElem.Init(self);
	}
	lElem.ListType = lt_ClosedList;
	mClosedList.AddItem(lElem);
	return mClosedList.Length-1;
}

function int AddToClosedList(int id, X_COM_MapCell cell, X_COM_ListElem parent, int G, int H)
{
	/*mClosedList[id].id = cell.Id();
	mClosedList[id].cell = cell;
	mClosedList[id].parent = parent;
	mClosedList[id].G = G;
	mClosedList[id].H = H;
	mClosedList[id].Enabled = true;
	mClosedListIndex.AddItem(id);*/

	//mClosedList[lElem.cell.Id()].SetParams(id, cell, parent, G, H);
	//mClosedList[lElem.cell.Id()].Enabled = true;
	//mClosedListIndex.AddItem(lElem.cell.Id());
	if(mWPList[id] == none)
	{
		mWPList[id] = new class'X_COM_ListElem';
		mWPList[id].Init(self);
	}
	mClosedList.AddItem(mWPList[id].SetParams(id, cell, parent, G, H, lt_Closedlist));
	return mClosedList.Length-1;
}

/*************************************************************************/

/**
	Функция «Высчитать прямой путь, игнорируя препятствия» - CalculateStraightWay(int aStartId, int aEndId)
	Параметры:
		aStartId - порядковый номер клетки, из которой поиск начинается.
		aEndId – порядковый номер клетки, к которой ищется путь.
Функция просто старается максимально быстро сблизиться с целью, как правило для этого
хватает обычного цикла в котором на каждом витке происходит сближение по одной координате,
затем общее кол-во клеток суммируется и возвращается в виде результата.
*/
function int CalculateDistance(X_COM_MapCell aStart, X_COM_MapCell aEnd)
{
	local int counter; // счётчик суммы
	//local int axc; // счётчик осей
	////local int x, y, z; // начальные координаты
	//local int points;

	//counter = 0;
	//axc = 0;
	//x = aStart.x;
	//y = aStart.y;
	//z = aStart.z;

	////ex = aEnd.x;
	////ey = aEnd.y;
	////ez = aEnd.z;
	////while((x != aEnd.x)||(y != aEnd.y)||(z != aEnd.z))
	///*while((x != aEnd.x) || (y != aEnd.y) || (z != aEnd.z))
	//{
	//	if(axc == 0)
	//	{
	//		if(x < aEnd.x) x++;
	//		else if(x > aEnd.x) x--;
	//		else axc++;
			
	//	}
	//	else if(axc == 1)
	//	{
	//		if(y < aEnd.y) y++;
	//		else if(y > aEnd.y) y--;
	//		else axc++;
			
	//	}
	//	else if(axc == 2)
	//	{
	//		if(z < aEnd.z) z++;
	//		else if(z > aEnd.z) z--;
	//		else axc++;
			
	//	}
	//	SelectMostOptimalMovement(X_COM_Pawn(Pawn), mLevelManager.GetCell(x, y, z), points);
	//	counter+=points;
	//	if(axc > 2) axc=0; 
	//}*/

	counter = (abs(aStart.X() - aEnd.X()) + abs(aStart.Y() - aEnd.Y()) + abs(aStart.Z() - aEnd.Z()))*4;
	return counter;
}

/**
	Функция «Выбрать клетку с наименьшим F» - FindLowestF()
Находит клетку с наименьшим значением F = G + H. Обходит массив в цикле,
вычисляет F и возвращает ссылку на ячейку с наименьшим значением.	
*/

function int FindLowestF()
{
	local int lI;
	local int lLowest, lLowestIndex; // Наименьшее значение.
	local int F;       // F-значение.
	//local X_COM_ListElem lElem;

	lLowestIndex = 0;
	lLowest = mOpenList[lLowest].G + mOpenList[lLowest].H;
	For(lI = 0; lI<mOpenList.Length; lI++)
	{
		F = mOpenList[lI].G + mOpenList[lI].H;
		if(F < lLowest)
		{
			lLowest = F;
			lLowestIndex = lI;
		}
	}
	return lLowestIndex;
}

/**  
	Функция GetCellType(vector aCell)
Возвращает тип клетки по координате ячейки: проходима, не проходима, павн, и т.д. 
	@param [aCell] - проверяемая клетка
 */
/*
function Ecell_type GetCellType(vector aCell)
{
	local Actor lTraceActor;
	local vector lTraceStart, lTraceEnd, lHitLocation, lHitNormal, lWorldLocation, lTraceExtent;
	/*local float lClockTime;
	
	Clock( lClockTime );
	UnClock( lClockTime );
 
	`log("Setting 6 element value in "$lClockTime$" seconds");*/

	lWorldLocation = class'xcT_Defines'.static.GetLocationFromGridNumbers(aCell);
	lTraceStart = lWorldLocation;
	lTraceStart.Z += 5; // возьмем немного выше старт
	lTraceEnd = lWorldLocation;
	lTraceEnd.Z = int(lTraceEnd.Z / class'X_COM_Settings'.default.T_GridSize.Z) * class'X_COM_Settings'.default.T_GridSize.Z - 5; //и опустим конец чуть ниже уровня
	lTraceExtent = Pawn.GetCollisionExtent();
	lTraceActor = Trace( lHitLocation, lHitNormal, lTraceEnd, lTraceStart, false, lTraceExtent);//, , class'Actor'.const.TRACEFLAG_Bullet);
	
	if( lTraceActor != none )
	{
		if (lTraceActor.isA('xcT_Tile_Ground')) return ct_passable;
		if (lTraceActor.isA('xcT_Tile_Prefab')) return ct_obstacle;
		if (lTraceActor.isA('X_COM_Unit')) return ct_obstacle;//ct_unit;
		return ct_none;
	}
	else return ct_none;
	//`warn(" ERROR. Could not find cell type for Cell : "$aCell$" in Location : "$lTraceStart);
}
*/

/**
	Функция "Назначить родителя" - SetParent()

*/


/**
	Функция «Алгоритм А*» - FindPathWithAstar(int aStartId, int aEndId)
Выполняет поиск пути по алгоритму А*.
	1.	Добавить стартовую точку в открытый список.
	2.	Выполнять в цикле, пока не получен наиболее оптимальный путь к цели.
		a.	Выбрать наиболее оптимальный по F элемент открытого списка.
		b.	Удалить элемент из открытого списка.
		c.	Добавить элемент в закрытый список.
		d.	Добавить всех соседей в открытый список.
			i.	При добавлении соседа в открытый список, назначить ему текущую ячейку в качестве предка.
			ii.	Проверить, находится ли сосед в открытом списке.
				1.	Если да – проверить его F. Если F соседа меньше – прекратить проверку данной клетки
					и перейти к проверке соседа.
			iii.	Проверить, находится ли сосед в закрытом списке. Если есть – не добавлять эту клетку
					в открытый список.
			iv.	Высчитать для добавляемого соседа прямой путь до цели и записать в параметр H.
			v.	Высчитать для добавляемого соседа путь от начальной точки и записать в параметр G.
			vi.	Не включать в открытый список объекты, непроходимые для данного юнита.
	3.	Вычислить кратчайший путь при помощи функции «Вычислить результирующий путь».
	4.	Вернуть результат.

	Параметры:
		@param [aStartId] – откуда начинается поиск.
		@param [aEndId] – докуда путь ищется.

*/
function DoCleanup()
{
	mWPList.Remove(0, mWPList.Length-1);
	SetBuferLength(mMap.MapSize());
	mOpenList.Remove(0, mOpenList.Length);
	mClosedList.Remove(0, mClosedList.Length);
}

function array<vector> FindPathTo(X_COM_MapCell aStart, X_COM_MapCell aEnd)
{
	local int lElem;
	local int lI,/* lZ, lY, lX,*/ X, Y, Z, lDir;
	//local int lSumm;
	local float G, H, TempG;
	//local X_COM_ListElem lSelected;
	local X_COM_MapCell lCell;
	local array<Vector> lResult;
	//local Vector aStartCrd;

	if(aEnd.CellType() != ct_obstacle)
	{
		mOpenList.Remove(0, mOpenList.Length);
	
	
		/*lListElem = new class'X_COM_ListElem';
		lListElem.cell.Id(mLevelManager.IdFromCrd(aStartId.X, aStartId.Y, aStartId.Z));
		lListElem.parent = none;
		lListElem.H = 0;
		lListElem.G = 0;*/
		//aStartCrd = aStart.Crd();
		//lElem = mLevelManager.IdFromCrd(aStartCrd.X, aStartCrd.Y, aStartCrd.Z);
	
		//mOpenList.AddItem(lListElem);
		//lEnd.cellId = aEndId;
		//1.	Добавить стартовую точку в открытый список.
		lI = AddToOpenList(aStart.Id(), aStart, none, 0, 0);
		mSelected = mOpenList[lI]; // Кто не врубился в фокус
		// Я прямо в квадратных скобках добавляю элемент и сразу же использую вернувшийся индекс,
		// чтобы получить копию добавленного элемента

		//2.	Выполнять в цикле, пока не получен наиболее оптимальный путь к цели.
		while(mSelected.cell.Id() != aEnd.Id())
		{
			//a.	Выбрать наиболее оптимальный по F элемент открытого списка.
			lI = FindLowestF();
			mSelected = mOpenList[lI];
			//c.	Добавить элемент в закрытый список.
			//mClosedList[mOpenList[lI].cell.Id()] = mOpenList[lI];
			MoveToClosedList(mOpenList[lI]);
			//b.	Удалить элемент из открытого списка.
			mOpenList.Remove(lI, 1);
			//d.	Добавить всех соседей в открытый список.
			//for(lZ = -1; lZ<3; lZ++)
			for(lDir = 0; lDir < DIRECTIONS_PURE; lDir++)
			{
				Z = mSelected.cell.z() + dir[lDir].Z;
				//Z = lSelected.cell.z + lZ;
				if(Z >= 0 && Z < class'X_COM_Settings'.default.T_GridSize.z)
				{
					Y = mSelected.cell.y() + dir[lDir].Y;
					//for(lY = -1; lY<3; lY++)
					//{
						//Y = mMapGrid[lSelected.cell.Id()].y + lY;
						if(Y >= 0 && Y < class'X_COM_Settings'.default.T_GridSize.y)
						{
							X = mSelected.cell.x() + dir[lDir].X;
							//for(lX = -1; lX<3; lX++)
							//{
								//X = mMapGrid[lSelected.cell.Id()].x + lX;
								//if((X >= 0 && X < class'X_COM_Settings'.default.T_GridSize.x) && !( lX==0 && lY==0 && lZ==0))
								if(X >= 0 && X < class'X_COM_Settings'.default.T_GridSize.x)
								{
									/** @todo Добавить проверку на проходимость клетки, прежде чем добавлять её в открытый список*/
									lCell =  mMap.GetCell(X, Y, Z);
									
			
									
									if( SelectMostOptimalMovement(X_COM_Pawn(mPawn), mSelected, lCell) == EP_none)
									{
										continue;
									}
									if( mWPList[lCell.Id()] != none)
									{
										if(mWPList[lCell.Id()].ListType == lt_OpenList)
										{
											TempG = GetG(mWPList[lCell.Id()], mSelected);
											G = mWPList[lCell.Id()].G;
											H = mWPList[lCell.Id()].H;
											if((TempG + H) < (G + H))
												mWPList[lCell.Id()].SetParent(mSelected);
											continue;
										}
										else
											continue;
									}
									H = CalculateDistance(lCell, aEnd);
									lElem = AddToOpenList(lCell.Id(), lCell, mSelected, 0, H);
									//ReturnWayToCell(mOpenList[lElem], none, lSumm);
									G = GetG(mOpenList[lElem]);
									mOpenList[lElem].G = G;
								
									//vi.	Не включать в открытый список объекты, непроходимые для данного юнита.
								
								}
						
						}
				
				}
			}
		}
		//3.	Вычислить кратчайший путь при помощи функции «Вычислить результирующий путь».
		lResult = ReturnWayToCell(FindByCellId(aEnd.Id()), mMap.GetLocationFromCellByGridNumbers);
		DoCleanup();
		return lResult;
	}

	
	/*for(lI = 0; lI<mWaypoints.Length-1; lI++)
	{
		WorldInfo.MyEmitterPool.SpawnEmitter(class'X_COM_Settings'.default.ClickToTerrainEffect, mWaypoints[lI], rot(0,0,0));
	}*/
	//Return   class'xcT_Defines'.static.GetLocationFromGridNumbers(lCell);
	//4.	Вернуть результат.
}
defaultproperties
{

}*/