/**
	������ �������� ������
������� ��������� ������, ������������ ��� ����������� ����.
	�	������ ��������������� ������ - id ������, ��������������� �������� ������.
	�	��������� �� ������� - id ������, � ������� ����� ������� �� ������ ������.
	�	�������� G � ����������� ���� �� ��������� ������� �� ���� ������
	�	�������� H - ������ ���� �� ����, ��������� �����������
*/

class X_COM_ListElem extends X_COM_AbstractNode dependson(X_COM_Defines);
/*
var X_COM_MapCell   cell;     // ������ �� ��������������� ������
var X_COM_ListElem  parent;   // ��������� �� ������� - ������, � ������� ����� ������� �� ������ ������.
var int G;                  // �������� G � ����������� ���� �� ��������� ������� �� ���� ������
var int H;                  // �������� H - ������ ���� �� ����, ��������� �����������
var X_COM_AstarPathfinding Pathfinding;

Enum EListType
{
	lt_OpenList,
	lt_ClosedList,
	lt_None
};
var EListType ListType;     // �������, ������������, ��� � ������ ������� ������ ������ ������ ������ �� ������,
							// � ������ ���������� ������ �������������� ������ �����������, ������ �� ������, ��� ���.

//=============================================================================
// Functions
//=============================================================================
function Init(X_COM_AstarPathfinding aAstar)
{
	Pathfinding = aAstar;
}

function X_COM_ListElem SetParams(int aId, X_COM_MapCell aCell, X_COM_ListElem aParent, int aG, int aH, EListType LT)
{
	mId         = aId;
	cell        = aCell;
	parent      = aParent;
	G           = aG;
	H           = aH;
	ListType    = LT;
	return self;
}

function SetParent(X_COM_ListElem aNewParent)
{
	if(Pathfinding == none)
	{
		`log("Pathfinder does not assigned");
		return;
	}
	parent = aNewParent;
	G = aNewParent.G;
}
//=============================================================================
// Default properties
//=============================================================================
defaultproperties
{
	cell    = none
	parent  = none
	G       = 0
	H       = 0
	ListType= lt_None
    Name="Default__X_COM_ListElem"	
}*/