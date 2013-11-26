/**
 * X-COM Tactics functions and variables class. 
 * Uses to store functions and variables for tactics classes.
 */
class xcT_Defines extends X_COM_Defines;

Enum EEventNames
{
	EN_None,
	EN_EnemySeen,
	EN_EnemyHeard,
};
/*
/**
 * 
 * Нумерованная константа «Наименование типа перемещения»
 *  Содержит список существующих в игре типов перемещения.
 *
 * */
Enum EMovementType
{
	MT_Walk,
	MT_Fly,
	MT_Default
};*/
//=============================================================================
// Variables
//=============================================================================
struct Cells
{
	var int X;
	var int Y;
	var int Z;
};
/*
enum Ecell_type 
{
	ct_none, //не определено

	ct_passable,  // клетка проходима
	ct_obstacle,  // в клетке препятствие - клетка непроходима

	// возможно, что следующие значения избыточны
	ct_unit,  // в клетке солдат
	ct_target  // клетка является клеткой назначения перемещения
	// сюда же могут быть добавлены препятствия с круглыми углами, всякие лифты и лестницы
	// здесь же может быть отмечен и туман войны
} ;*/

/**
  Объект «Клетка карты»
Описывает клетку на сетке карты
	•	Порядковый номер - точный индекс в массиве, нужен для ссылок на него.
	•	Список собственных координат для сканирования соседей - точные координаты, по которым клетка находится на поле.
	•	Тип клетки - используется для определения возможности перемещения по ней, а также её цены.
*/

struct MapCell
{
	var int         id;         // Порядковый номер - точный индекс в массиве, нужен для ссылок на него.
	var int         x, y, z;    // Список собственных координат для сканирования соседей - точные координаты,
								// по которым клетка находится на поле.
	var Ecell_type  CellType;   // Тип клетки - используется для определения возможности перемещения по ней, а также её цены.
};

/*
/**
  Объект «Цена типа перемещения» - MovementTypeCost
	Структура для хранения цены определённого способа перемещения для определённого способа движения по данной местности.
	•	Наименование типа - собственно, имя способа перемещения
	•	Цена в виде множителя - значение, на которое множится скорость перемещения юнита по данной местности,
		при помощи данного способа перемещения.
*/
struct MovementTypeCost
{
	var EMovementType   Name; // Наименование типа - собственно, имя способа перемещения

	var float           M;  //Цена в виде множителя - значение, на которое множится скорость перемещения юнита по данной местности,
							//при помощи данного способа перемещения.
};

/**
	Объект «Тип клетки» - CellType
Тип клетки и её цены на перемещение.
	•	Цены для разных типов перемещения (массив)
	•	Чёрный список типов перемещения (массив)
		o	Есть тип «дефолт», чья цена используется, если объекта нет ни в белом, ни в чёрном списке.
*/

struct CellType
{
	var array<MovementTypeCost> bWhiteList; // Цены для допустимых типов перемещения
	var array<EMovementType>    bBlackList; // Список недопустимых типов перемещения
};


/**
Функция «Найти наиболее оптимальный способ перемещения» - SelectMostOptimalMovement()
	Параметры:
		Ссылка на юнита – юнит, выполняющий попытку перемещения.
		Порядковый номер клетки – клетка, с которой происходит сравнение.
Сравнивает каждый способ перемещения, доступный юниту, с каждым способом перемещения в белом списке. Если тип есть, то чёрный список не проверяется. Иначе проверяется, есть ли дефолтное значение, и если есть, проверяется чёрный список, и если в нём нет данного типа перемещения, то используется дефолтная цена.
Также доступны 3 условия проверки на фиксированность типа:
1.	Нефиксированный – при перемещении юнит использует наиболее выгодный способ перемещения.
2.	Условно-фиксированный – юнит использует указанный способ перемещения, за исключением ситуаций, если он запрещён для данной клетки. Тогда используется наиболее выгодный для неё.
3.	Фиксированный – юнит использует только выбранный способ перемещения. Все клетки, для которых он недоступен, считаются непроходимыми.
Способы подсчёта значения также могут быть различными. Я потом обдумаю эту тему, а пока что у клетки будет множитель для скорости юнита, и результирующей ценой клетки будет P = S * M, где S – скорость текущего способа перемещения юнита, а M – множитель клетки.
*/

*/
//=============================================================================
// Constant movement TimeUnits cost
//=============================================================================
const			TUperStep = 4;
const			TUperTurn = 2;
const			TUperCrouch = 4;
const			TUperStandUp = 8;
const			TUperFire_Aimed = 60;
const			TUperFire_Burst = 15; //for one shot of 3.
const			TUperFire_Quick = 35;
const			TUperFire_Throw = 20;

//=============================================================================
// Functions
//=============================================================================
/** Changes world location coords to grid coords.*/
// Фактически это трансформация из ворлд коордс в ворлд коордс
// Выравнивание координат в центр клетки (чисто по проекции в горизонтальной плоскости)
final static function vector GetGridCoord(vector aLocation)
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
final static function bool CheckLocationLimit(vector NowLocation, optional out vector NewLocation)
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
final static function vector GetGridNumbersFromLocation(vector aLocation)
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
final static function vector GetLocationFromGridNumbers(vector aGridNumber)
{
	local   vector lGridSize, lLocation;
	lGridSize = class'X_COM_Settings'.default.T_GridSize;
	lLocation.X = (aGridNumber.X+1./2)*lGridSize.X;
	lLocation.Y = (aGridNumber.Y+1./2)*lGridSize.Y;
	lLocation.Z = (aGridNumber.Z+1./2)*lGridSize.Z;
	return lLocation;
}

final static function Cells VectToCell(vector aVector)
{
	local Cells lCell;
	lCell.X = aVector.X;
	lCell.Y = aVector.Y;
	lCell.Z = aVector.Z;
	return lCell;
}

final static function vector CellToVect(Cells aCell)
{
	local vector lVect;
	lVect.X = aCell.X;
	lVect.Y = aCell.Y;
	lVect.Z = aCell.Z;
	return lVect;
}

//=============================================================================
// Default properties
//=============================================================================
defaultproperties
{
    Name="Default__xcT_Defines"	
}