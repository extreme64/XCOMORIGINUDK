/**
 * Tactical Level Manager 
 * Uses for generating maps and for spawn x-com and alien pawns
 */
class X_COM_LevelManager extends Actor notplaceable;// dependson(X_COM_System_Pawn_Data);

//=============================================================================
// Variables
//=============================================================================
//


//=============================================================================
// Functions
//=============================================================================

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


// Path finding relied functions

// Функция преобразования трёхмерных координат в одномерные
function int IdFromCrd(int x, int y, int z){}

//function int IdFromVector(Vector aV);

// Функция чтения по трёхмерным координатам
//function X_COM_MapCell GetCell(int x, int y, int z);

//function X_COM_MapCell GetCellFromVector(Vector aV);

// Функция записи в трёхмерные координаты
//function SetCell(int x, int y, int z, Ecell_type aType);

// vector from MapCell
/*function vector VfC(X_COM_MapCell aCell)
{
	local Vector r;
	r.X = aCell.x;
	r.Y = aCell.y;
	r.Z = aCell.z;

	return r;
}
*/
/*function Ecell_type GetCellType(vector aCell);

function GeneratePathMap();*/
//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
}