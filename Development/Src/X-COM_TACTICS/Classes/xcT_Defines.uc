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
 * ������������ ��������� ������������� ���� ������������
 *  �������� ������ ������������ � ���� ����� �����������.
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
	ct_none, //�� ����������

	ct_passable,  // ������ ���������
	ct_obstacle,  // � ������ ����������� - ������ �����������

	// ��������, ��� ��������� �������� ���������
	ct_unit,  // � ������ ������
	ct_target  // ������ �������� ������� ���������� �����������
	// ���� �� ����� ���� ��������� ����������� � �������� ������, ������ ����� � ��������
	// ����� �� ����� ���� ������� � ����� �����
} ;*/

/**
  ������ ������� ������
��������� ������ �� ����� �����
	�	���������� ����� - ������ ������ � �������, ����� ��� ������ �� ����.
	�	������ ����������� ��������� ��� ������������ ������� - ������ ����������, �� ������� ������ ��������� �� ����.
	�	��� ������ - ������������ ��� ����������� ����������� ����������� �� ���, � ����� � ����.
*/

struct MapCell
{
	var int         id;         // ���������� ����� - ������ ������ � �������, ����� ��� ������ �� ����.
	var int         x, y, z;    // ������ ����������� ��������� ��� ������������ ������� - ������ ����������,
								// �� ������� ������ ��������� �� ����.
	var Ecell_type  CellType;   // ��� ������ - ������������ ��� ����������� ����������� ����������� �� ���, � ����� � ����.
};

/*
/**
  ������ ����� ���� ������������ - MovementTypeCost
	��������� ��� �������� ���� ������������ ������� ����������� ��� ������������ ������� �������� �� ������ ���������.
	�	������������ ���� - ����������, ��� ������� �����������
	�	���� � ���� ��������� - ��������, �� ������� �������� �������� ����������� ����� �� ������ ���������,
		��� ������ ������� ������� �����������.
*/
struct MovementTypeCost
{
	var EMovementType   Name; // ������������ ���� - ����������, ��� ������� �����������

	var float           M;  //���� � ���� ��������� - ��������, �� ������� �������� �������� ����������� ����� �� ������ ���������,
							//��� ������ ������� ������� �����������.
};

/**
	������ ���� ������ - CellType
��� ������ � � ���� �� �����������.
	�	���� ��� ������ ����� ����������� (������)
	�	׸���� ������ ����� ����������� (������)
		o	���� ��� �������, ��� ���� ������������, ���� ������� ��� �� � �����, �� � ������ ������.
*/

struct CellType
{
	var array<MovementTypeCost> bWhiteList; // ���� ��� ���������� ����� �����������
	var array<EMovementType>    bBlackList; // ������ ������������ ����� �����������
};


/**
������� ������ �������� ����������� ������ ������������ - SelectMostOptimalMovement()
	���������:
		������ �� ����� � ����, ����������� ������� �����������.
		���������� ����� ������ � ������, � ������� ���������� ���������.
���������� ������ ������ �����������, ��������� �����, � ������ �������� ����������� � ����� ������. ���� ��� ����, �� ������ ������ �� �����������. ����� �����������, ���� �� ��������� ��������, � ���� ����, ����������� ������ ������, � ���� � �� ��� ������� ���� �����������, �� ������������ ��������� ����.
����� �������� 3 ������� �������� �� ��������������� ����:
1.	��������������� � ��� ����������� ���� ���������� �������� �������� ������ �����������.
2.	�������-������������� � ���� ���������� ��������� ������ �����������, �� ����������� ��������, ���� �� �������� ��� ������ ������. ����� ������������ �������� �������� ��� ��.
3.	������������� � ���� ���������� ������ ��������� ������ �����������. ��� ������, ��� ������� �� ����������, ��������� �������������.
������� �������� �������� ����� ����� ���� ����������. � ����� ������� ��� ����, � ���� ��� � ������ ����� ��������� ��� �������� �����, � �������������� ����� ������ ����� P = S * M, ��� S � �������� �������� ������� ����������� �����, � M � ��������� ������.
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
// ���������� ��� ������������� �� ����� ������ � ����� ������
// ������������ ��������� � ����� ������ (����� �� �������� � �������������� ���������)
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
	return bIsInLimit;  // ����� true, ���� ������������� ���������
}

/** Returns grid number for all axes for location*/
// ���� �� ������������ ����������� �� ����, �������� ������ (�.�. �������) � ������� ����.
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

// �� �������� �������� ����������-world ������ ������ 
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