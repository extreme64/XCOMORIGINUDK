/**
	ќбъект ЂЁлемент спискаї
Ёлемент открытого списка, используемый дл€ буферизации пути.
	Х	»ндекс соответствующей клетки - id клетки, соответствующа€ элементу списка.
	Х	”казатель на Ђпредкаї - id клетки, с которой поиск перешЄл на данную клетку.
	Х	«начение G Ц проделанный путь от стартовой позиции до этой клетки
	Х	«начение H - пр€мой путь до цели, игнориру€ преп€тстви€
*/

class X_COM_ListElem extends X_COM_AbstractNode dependson(X_COM_Defines);
/*
var X_COM_MapCell   cell;     // —сылка на соответствующую клетки
var X_COM_ListElem  parent;   // ”казатель на Ђпредкаї - клетку, с которой поиск перешЄл на данную клетку.
var int G;                  // «начение G Ц проделанный путь от стартовой позиции до этой клетки
var int H;                  // «начение H - пр€мой путь до цели, игнориру€ преп€тстви€
var X_COM_AstarPathfinding Pathfinding;

Enum EListType
{
	lt_OpenList,
	lt_ClosedList,
	lt_None
};
var EListType ListType;     //  остыль, используемый, ибо в анриал скрипте нельз€ делать пустые ссылки на объект,
							// а потому приходитс€ делать альтернативный способ определени€, создан ли объект, или нет.

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