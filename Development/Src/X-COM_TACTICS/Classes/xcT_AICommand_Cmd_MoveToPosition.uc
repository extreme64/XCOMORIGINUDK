Class xcT_AICommand_Cmd_MoveToPosition extends xcT_AICommand_Cmd implements(X_COM_Sender);

//=============================================================================
// Variables: Movement
//=============================================================================
var private Vector                      mMoveDestination, TempDest;
var private Vector                      mStartCell, mEndCell, mDesiredEndCell;
var protected bool              bShouldWalk;
var protected Object            mPathFinding;
var private int mi;                     // Counter

var array<X_COM_Tile> TEST_TEMP_OBJECTS; //TEST TEMP

//=============================================================================
// Variables: Path-Finding
//=============================================================================
var private array<Vector>       mWaypoints;
var xcT_LevelManager            mLevelManager; // �����, ����������� �������
var array<X_COM_MapCell>        mMapGrid;
var X_COM_TacticalMap           mMap;
var X_COM_MapCell               mCell;
var X_COM_Node                  mNode;
var X_COM_PathFindingInterface  mPathFinder;
var X_COM_SusaninPF_Grid        mGrid;
var Rotator mRot;
//var private vector                      mMapSize; // Map size
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
} ;

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
/**
	���� �����
����������, ����������� ������ �����, �� ������� ������ ����.

*/
var array<MapCell> mMapGrid;
*/
/**
	������ �������� ������
������� ��������� ������, ������������ ��� ����������� ����.
	�	������ ��������������� ������ - id ������, ��������������� �������� ������.
	�	��������� �� ������� - id ������, � ������� ����� ������� �� ������ ������.
	�	�������� G � ����������� ���� �� ��������� ������� �� ���� ������
	�	�������� H - ������ ���� �� ����, ��������� �����������
*/

struct ListElement
{
	var int id;
	var X_COM_MapCell cell;     // ������ ��������������� ������ - id ������, ��������������� �������� ������.
	var X_COM_MapCell parent;   // ��������� �� ������� - id ������, � ������� ����� ������� �� ������ ������.
	var int G;          // �������� G � ����������� ���� �� ��������� ������� �� ���� ������
	var int H;          // �������� H - ������ ���� �� ����, ��������� �����������
	var bool Enabled;   // �������, ������������, ��� � ������ ������� ������ ������ ������ ������ �� ������,
						// � ������ ���������� ������ �������������� ������ �����������, ������ �� ������, ��� ���.
};

/**
	������ ����������
� ����� ������ ������������ ������ � �������, ��� �������� ������ �����. � ���������� ����� ������ �����
�������� �� �������� � �������� ������. �������� �������, ����� �� ������ ���������� � ������� ��� �����������
� ��������-�������� ������.
 */
var array<X_COM_ListElem> mWPList;

/**
	�������� ������
������������ ������, � ������� ���������� ������� ����������� ������.
*/
var array<X_COM_ListElem> mOpenList;
//var array<int> bOpenListIndex; // ������ ��������, ����������� ����������� �������� �� ������������ ��������� ������.
/**
	�������� ������ 
����������� ������ �������� �� ��� �����, �������� ���������� �� ��� ����������� ���������.
��� ������ �������� ������, �����������, ��������� �� ��� � �������� ������, � ���� ��,
����� �����������, ���� ��� � ��� ��������� � ������, � ����� ������������.
������ � ������ ������������ �� ����������� ������ ����������� ������ ��� ����� �������� ������.
������ ��������� ������ � ���� ��� ����� ������. � ������� ������ �� ����.

*/
//var array<ListElement> mClosedList;      // ��� ������.
var array<X_COM_ListElem> mClosedList; // ������ ������, ����������� ����������� �������� �� ������������ ��������� ������.

// ����������� ��������
//������� ��� ������, ��� ������ �� ������� ��������� �������.
//��������, ������ ��� ����� � ����� � ������ ����� ��������� �� �����.
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

	df_uninit  // ����������� �� ���������
};

//`define DIRECTIONS_ALL 27
//`define DIRECTIONS_PURE 26

var int DIRECTIONS_PURE;

var private vector dir[26]; // basic directions
//=============================================================================
// Functions
//=============================================================================
/*
// ������� �������������� ��������� ��������� � ����������
function int Id(int x, int y, int z)
{
	//`log("Getting cell ID by X="$x$" Y="$y$" Z="$z$" :: Z("$tz$")+Y("$ty$")+X("$x$"), ID="$result);
	return (z*(mMapSize.y*mMapSize.x))+(y*mMapSize.x)+x;
}

function dummy()
{
}
// ������� ������ �� ��������� �����������
function MapCell GetCell(int x, int y, int z)
{
	return mMapGrid[Id(x, y, z)];
}

// ������� ������ � ��������� ����������
function SetCell(int x, int y, int z, Ecell_type aType)
{
	local int lid;


	mX = x;
	mY = y;
	mZ = z;
	lid = Id(x, y, z);

	mMapGrid[lid].x = x;
	mMapGrid[lid].y = y;
	mMapGrid[lid].z = z;
	mMapGrid[lid].id = lid;
	mMapGrid[lid].CellType = aType;
}
// vector from MapCell
function vector VfC(MapCell aCell)
{
	local Vector r;
	r.X = aCell.x;
	r.Y = aCell.y;
	r.Z = aCell.z;

	return r;
}*/
/**
	������� ������ �������� ����������� ������ ������������ - SelectMostOptimalMovement(X_COM_Pawn aUnit, int aCellId)
	���������:
		aUnit - ������ �� �����, ������������ ������� �����������.
		aCellId - ���������� ����� ������, � ������� ���������� ���������.
���������� ������ ������ �����������, ��������� �����, � ������ �������� ����������� � ����� ������.
���� ��� ����, �� ������ ������ �� �����������. ����� �����������, ���� �� ��������� ��������, � ���� ����,
����������� ������ ������, � ���� � �� ��� ������� ���� �����������, �� ������������ ��������� ����.
����� �������� 3 ������� �������� �� ��������������� ����:
	1.	��������������� � ��� ����������� ���� ���������� �������� �������� ������ �����������.
	2.	�������-������������� � ���� ���������� ��������� ������ �����������, �� ����������� ��������,
		���� �� �������� ��� ������ ������. ����� ������������ �������� �������� ��� ��.
	3.	������������� � ���� ���������� ������ ��������� ������ �����������. ��� ������,
		��� ������� �� ����������, ��������� �������������.

������� �������� �������� ����� ����� ���� ����������. � ����� ������� ��� ����,
� ���� ��� � ������ ����� ��������� ��� �������� �����, � �������������� ����� ������ ����� P = S * M,
��� S � �������� �������� ������� ����������� �����, � M � ��������� ������.
*/

/*
function EPosition SelectMostOptimalMovement(X_COM_Pawn aUnit, X_COM_MapCell aCell, optional out int points)
{
	/*if(mMapGrid[aCellId].CellType)
		return TUperStepOnLand;*/
	/** @todo
	 *  �������� �������� �� ��� ������, �������� �������� � �� ������������.*/
	if(!( aCell.CellType == ct_obstacle || aCell.CellType == ct_none))
	{
		points = class'xcT_Defines'.const.TUperStep;
		return EP_Standing;
	}
	else
		return EP_NotPassable;
}
/**
 * Open list functions
 */
function int MoveToOpenList(X_COM_ListElem lElem)
{
	if(lElem == none)
		lElem = new class'X_COM_ListElem';
	mOpenList.AddItem(lElem);
//	mOpenList[lElem.cell.Id()] = lElem;
//	mOpenList[lElem.cell.Id()].Enabled = true;

	return mOpenList.Length-1;
}

function int AddToOpenList(int id, X_COM_MapCell cell, X_COM_MapCell parent, int G, int H)
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

	������� �������� �������������� ����� - ReturnWayToCell(ListElement aElem, optional delegate<WPFunc> aWPFunc, out int aSumm)
��������� ��� ������ �������� �� ��������� ������, �� ���������� ������, � ������� �� ������,
���������� ����� ���� ������� � ����� ������ �������� � ������������ �������� �� ������ �� ������,
�� ���������� ������ ������ ������ � ��� � ���� ��� ����. ������� ���������� ���� �/��� ����� ���������� ����.
	���������:
		@param aElem - ���������� ����� ������, �� ������� ������������ �������� ��������.
		@param aWPFunc - �������������� �������, ����������� � ������ ����� ������� � ������.
		@param aSumm - ������ �� ����������, � ������� ����� �������� ����� ���������� ����.
*/
delegate vector WPFunc(vector aGridNumber);

function array<vector> ReturnWayToCell(X_COM_ListElem aElem, delegate<WPFunc> aWPFunc, optional out int aSumm)
{
	local X_COM_ListElem lCE;
	local array<Vector> lResult;
	local Vector lVector;
	//local array<xcT_listElem> lList;
	local int lPrice;

	//lResult.Lenght = 0;
	/*if(aType == lt_OpenList)
		lList = mOpenList;
	else if(aType == lt_ClosedList)
		lList = mClosedList;*/

	aSumm = 0;
	lCE = aElem;

	/*while(mWPList[lCE].parent!=none)
	{
		// ���� ��� ���� ������������ ���� �� ����������� �������, �� ����� ������� ���� ������ ������� ���� ��������������,
		// � ���� ����� �� ������.
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
		// ���� ��� ���� ������������ ���� �� ����������� �������, �� ����� ������� ���� ������ ������� ���� ��������������,
		// � ���� ����� �� ������.
		SelectMostOptimalMovement(X_COM_Pawn(Pawn), lCE.cell, lPrice);
		aSumm += lPrice;
		lVector.X = lCE.cell.x;
		lVector.y = lCE.cell.y;
		lVector.z = lCE.cell.z;
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
	������� GetG(X_COM_ListElem aElem)
������� ���� G �����.
	@param X_COM_ListElem aElem - �������, ��� G �����������
*/
function int GetG(X_COM_ListElem aElem)
{
	local int lPrice;

	SelectMostOptimalMovement(X_COM_Pawn(Pawn), aElem.cell, lPrice);
	if(aElem.parent != none)
		return lPrice + mWPList[aElem.parent.Id()].G;
	else
		return lPrice;
}
/**
 * Closed List functions
 */
/**
	������� ���������� ������� � �������� ������ - InClosedList(int aId)
	���������:
		aId - ���������� ����� ������, ������� ������� ����� ���������
���������, ���������� �� � �������� ������ ������ �� ������� �������� ����������� ������? ���������� true ��� false.
*/

/*function bool InClosedList(int aId)
{
	if(mClosedList[aId].Enabled == false)
		return false;
	else
		return true;
}*/
/**
	������� ��������� � �������� ������ - AddToClosedList(ListElement lElem)
��������� ������ � �������� ������.	
	���������:
		@param lElem - ������, ������� ����� �������� � ������.

*/

function int MoveToClosedList(X_COM_ListElem lElem)
{
	/*mClosedList[lElem.cell.Id()] = lElem;
	mClosedList[lElem.cell.Id()].Enabled = true;
	mClosedListIndex.AddItem(lElem.cell.Id());*/
	if(lElem == none)
		lElem = new class'X_COM_ListElem';
	mClosedList.AddItem(lElem);
	return mClosedList.Length-1;
}

function int AddToClosedList(int id, X_COM_MapCell cell, X_COM_MapCell parent, int G, int H)
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
		mWPList[id] = new class'X_COM_ListElem';
	mClosedList.AddItem(mWPList[id].SetParams(id, cell, parent, G, H, lt_Closedlist));
	return mClosedList.Length-1;
}

/*************************************************************************/

/**
	������� ���������� ������ ����, ��������� ������������ - CalculateStraightWay(int aStartId, int aEndId)
	���������:
		aStartId - ���������� ����� ������, �� ������� ����� ����������.
		aEndId � ���������� ����� ������, � ������� ������ ����.
������� ������ ��������� ����������� ������ ���������� � �����, ��� ������� ��� �����
������� �������� ����� � ������� �� ������ ����� ���������� ��������� �� ����� ����������,
����� ����� ���-�� ������ ����������� � ������������ � ���� ����������.
*/
function int CalculateStraightWay(X_COM_MapCell aStart, X_COM_MapCell aEnd)
{
	local int counter; // ������� �����
	//local int axc; // ������� ����
	//local int x, y, z; // ��������� ����������
	//local int points;

	counter = 0;
	//axc = 0;
	//x = aStart.x;
	//y = aStart.y;
	//z = aStart.z;

	//ex = aEnd.x;
	//ey = aEnd.y;
	//ez = aEnd.z;
	//while((x != aEnd.x)||(y != aEnd.y)||(z != aEnd.z))
	/*while((x != aEnd.x) || (y != aEnd.y) || (z != aEnd.z))
	{
		if(axc == 0)
		{
			if(x < aEnd.x) x++;
			else if(x > aEnd.x) x--;
			else axc++;
			
		}
		else if(axc == 1)
		{
			if(y < aEnd.y) y++;
			else if(y > aEnd.y) y--;
			else axc++;
			
		}
		else if(axc == 2)
		{
			if(z < aEnd.z) z++;
			else if(z > aEnd.z) z--;
			else axc++;
			
		}
		SelectMostOptimalMovement(X_COM_Pawn(Pawn), mLevelManager.GetCell(x, y, z), points);
		counter+=points;
		if(axc > 2) axc=0; 
	}*/

	counter = (abs(aStart.X - aEnd.X) + abs(aStart.Y - aEnd.Y) + abs(aStart.Z - aEnd.Z))*4;
	return counter;
}

/**
	������� �������� ������ � ���������� F� - FindLowestF()
������� ������ � ���������� ��������� F = G + H. ������� ������ � �����,
��������� F � ���������� ������ �� ������ � ���������� ���������.	
*/

function int FindLowestF()
{
	local int lI;
	local int lLowest, lLowestIndex; // ���������� ��������.
	local int F;       // F-��������.
	//local xcT_ListElem lElem;

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
	������� GetCellType(vector aCell)
���������� ��� ������ �� ���������� ������: ���������, �� ���������, ����, � �.�. 
	@param [aCell] - ����������� ������
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
	lTraceStart.Z += 5; // ������� ������� ���� �����
	lTraceEnd = lWorldLocation;
	lTraceEnd.Z = int(lTraceEnd.Z / class'X_COM_Settings'.default.T_GridSize.Z) * class'X_COM_Settings'.default.T_GridSize.Z - 5; //� ������� ����� ���� ���� ������
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
	������� ��������� �*� - FindPathWithAstar(int aStartId, int aEndId)
��������� ����� ���� �� ��������� �*.
	1.	�������� ��������� ����� � �������� ������.
	2.	��������� � �����, ���� �� ������� �������� ����������� ���� � ����.
		a.	������� �������� ����������� �� F ������� ��������� ������.
		b.	������� ������� �� ��������� ������.
		c.	�������� ������� � �������� ������.
		d.	�������� ���� ������� � �������� ������.
			i.	��� ���������� ������ � �������� ������, ��������� ��� ������� ������ � �������� ������.
			ii.	���������, ��������� �� ����� � �������� ������.
				1.	���� �� � ��������� ��� F. ���� F ������ ������ � ���������� �������� ������ ������
					� ������� � �������� ������.
			iii.	���������, ��������� �� ����� � �������� ������. ���� ���� � �� ��������� ��� ������
					� �������� ������.
			iv.	��������� ��� ������������ ������ ������ ���� �� ���� � �������� � �������� H.
			v.	��������� ��� ������������ ������ ���� �� ��������� ����� � �������� � �������� G.
			vi.	�� �������� � �������� ������ �������, ������������ ��� ������� �����.
	3.	��������� ���������� ���� ��� ������ ������� ���������� �������������� �����.
	4.	������� ���������.

	���������:
		@param [aStartId] � ������ ���������� �����.
		@param [aEndId] � ������ ���� ������.

*/

function FindPathWithAstar(X_COM_MapCell aStart, X_COM_MapCell aEnd)
{
	local int lElem;
	local int lI,/* lZ, lY, lX,*/ X, Y, Z, lDir, lMOW;
	//local int lSumm;
	local int G, H;
	local X_COM_ListElem lSelected;
	local X_COM_MapCell lCell;
	//local Vector aStartCrd;

	if(aEnd.CellType != ct_obstacle)
	{
		mOpenList.Remove(0, mOpenList.Length);
	
	
		/*lListElem = new class'xcT_ListElem';
		lListElem.cell.Id(mLevelManager.IdFromCrd(aStartId.X, aStartId.Y, aStartId.Z));
		lListElem.parent = none;
		lListElem.H = 0;
		lListElem.G = 0;*/
		//aStartCrd = aStart.Crd();
		//lElem = mLevelManager.IdFromCrd(aStartCrd.X, aStartCrd.Y, aStartCrd.Z);
	
		//mOpenList.AddItem(lListElem);
		//lEnd.cellId = aEndId;
		//1.	�������� ��������� ����� � �������� ������.
		lI = AddToOpenList(aStart.Id(), aStart, none, 0, 0);
		lSelected = mOpenList[lI]; // ��� �� �������� � �����
		// � ����� � ���������� ������� �������� ������� � ����� �� ��������� ����������� ������,
		// ����� �������� ����� ������������ ��������

		//2.	��������� � �����, ���� �� ������� �������� ����������� ���� � ����.
		while(lSelected.cell.Id() != aEnd.Id())
		{
			//a.	������� �������� ����������� �� F ������� ��������� ������.
			lI = FindLowestF();
			lSelected = mOpenList[lI];
			//c.	�������� ������� � �������� ������.
			//mClosedList[mOpenList[lI].cell.Id()] = mOpenList[lI];
			MoveToClosedList(mOpenList[lI]);
			//b.	������� ������� �� ��������� ������.
			mOpenList.Remove(lI, 1);
			//d.	�������� ���� ������� � �������� ������.
			//for(lZ = -1; lZ<3; lZ++)
			for(lDir = 0; lDir < DIRECTIONS_PURE; lDir++)
			{
				Z = lSelected.cell.z + dir[lDir].Z;
				//Z = lSelected.cell.z + lZ;
				if(Z >= 0 && Z < class'X_COM_Settings'.default.T_GridSize.z)
				{
					Y = lSelected.cell.y + dir[lDir].Y;
					//for(lY = -1; lY<3; lY++)
					//{
						//Y = mMapGrid[lSelected.cell.Id()].y + lY;
						if(Y >= 0 && Y < class'X_COM_Settings'.default.T_GridSize.y)
						{
							X = lSelected.cell.x + dir[lDir].X;
							//for(lX = -1; lX<3; lX++)
							//{
								//X = mMapGrid[lSelected.cell.Id()].x + lX;
								//if((X >= 0 && X < class'X_COM_Settings'.default.T_GridSize.x) && !( lX==0 && lY==0 && lZ==0))
								if(X >= 0 && X < class'X_COM_Settings'.default.T_GridSize.x)
								{
									/** @todo �������� �������� �� ������������ ������, ������ ��� ��������� � � �������� ������*/
									lCell =  mLevelManager.GetCell(X, Y, Z);
									////AddToOpenList(lCell.Id(), lCell, lSelected.cell, G, H);
									/*mOpenList.Add(1);
									lElem = mOpenList.Length-1;
									mOpenList[lElem].cell = mLevelManager.GetCell(X, Y, Z);*/
									//i. ��� ���������� ������ � �������� ������, ��������� ��� ������� ������ � �������� ������.
									//mOpenList[lElem].parent = lSelected.cell;
									//ii.	���������, ��������� �� ����� � �������� ������. ���� ���� � �� ���������
									//      ��� ������ � �������� ������.
									if(SelectMostOptimalMovement(X_COM_Pawn(Pawn), lCell, lMOW) == EP_NotPassable)
									{
										continue;
									}
									if( mWPList[lCell.Id()] != none)
									{
										if(mWPList[lCell.Id()].ListType == lt_ClosedList)
											continue;
										if(mWPList[lCell.Id()].ListType == lt_OpenList)
										{
											if(mWPList[lCell.Id()].G > lSelected.G + lMOW)
											{
												mWPList[lCell.Id()].parent = lSelected.cell;
												mWPList[lCell.Id()].G = GetG(mWPList[lCell.Id()]);
											}
											continue;
										}
									}
									
									//ii.	��������� ��� ������������ ������ ������ ���� �� ���� � �������� � �������� H.
									//mOpenList[lElem].H = CalculateStraightWay(mOpenList[lElem].cell, mLevelManager.GetCell(aEnd.X, aEnd.Y, aEnd.Z));
									H = CalculateStraightWay(lCell, aEnd);
									//iv.	��������� ��� ������������ ������ ���� �� ��������� ����� � �������� � �������� G.
								
								
									//mOpenList[lElem].G = lSumm;
									lElem = AddToOpenList(lCell.Id(), lCell, lSelected.cell, 0, H);
									//ReturnWayToCell(mOpenList[lElem], none, lSumm);
									G = GetG(mOpenList[lElem]);
									mOpenList[lElem].G = G;
								
									//vi.	�� �������� � �������� ������ �������, ������������ ��� ������� �����.
								
								}
						}
				}
			}
		}
		//3.	��������� ���������� ���� ��� ������ ������� ���������� �������������� �����.
		mWaypoints = ReturnWayToCell(FindByCellId(aEnd.Id()), class'xcT_Defines'.static.GetLocationFromGridNumbers);
	}
	/*for(lI = 0; lI<mWaypoints.Length-1; lI++)
	{
		WorldInfo.MyEmitterPool.SpawnEmitter(class'X_COM_Settings'.default.ClickToTerrainEffect, mWaypoints[lI], rot(0,0,0));
	}*/
	//Return   class'xcT_Defines'.static.GetLocationFromGridNumbers(lCell);
	//4.	������� ���������.
}
*/
//=============================================================================
// From X_COM_Sender
//=============================================================================
function vector GetStartingNode()
{
	mStartCell = class'xcT_Defines'.static.GetGridNumbersFromLocation(Pawn.Location); // ���� ��������� ������
	return mStartCell;
};
function vector GetDestinationNode()
{
	mDesiredEndCell = class'xcT_Defines'.static.GetGridNumbersFromLocation(mMoveDestination); // ����� ����������, �.�. ���� ��������.
	return mDesiredEndCell;
}
//=============================================================================
// Events
//=============================================================================
// ���� �����������
event Pushed()
{
	//local int i, j, k;
	//local vector lCell;
	//local Vector lScanSquare;

	//local array<int> lTest1;
	//local array<int> lTest2;
	//local int lTest1[10];
	//local int lTest2[1000];

	//mMapSize.X = class'X_COM_Settings'.default.T_LevelSize.x / class'X_COM_Settings'.default.T_GridSize.x;
	//mMapSize.Y = class'X_COM_Settings'.default.T_LevelSize.y / class'X_COM_Settings'.default.T_GridSize.y;
	//mMapSize.Z = class'X_COM_Settings'.default.T_LevelSize.z / class'X_COM_Settings'.default.T_GridSize.z;
// ������� �������� ��������
	//mMapGrid.Length = mMapSize.Z*mMapSize.Y*mMapSize.X; // ������ ���� � �������
	
	
/* ���� ����������� ��� �������� ��� ��������� MU ��� �����*/
/* ���� MU ����� ������� � ������ ������*/



/***   ��� ����, ��� ������ ���� �� ���� ��������  function Ecell_type GetCellType(vector aCell)???????????????????????  ***/

	/*lTest1.Add(10);
	lTest2.Add(32000);
	Clock( lClockTime );
	lTest1[6] = 10;
	UnClock( lClockTime );
 
	`log("Setting 6 element value in "$lClockTime$" seconds");

	Clock( lClockTime );
	lTest2[25000] = 10;
	UnClock( lClockTime );
 
	`log("Setting 25000 element value in "$lClockTime$" seconds");*/

	
	/*lDummy = new class'X_COM_TestDummy';
	Clock( lClockTime );
	for(i=0; i<10000; i++)
	{
		lDummy.SetDummyInt(10);
	}
	UnClock( lClockTime );
 
	`log("Setting 10000 element value in "$lClockTime$" seconds");

	Clock( lClockTime );
	for(i=0; i<10000; i++)
	{
		lDummy.GetDummyInt();
	}
	UnClock( lClockTime );
 
	`log("Getting 10000 element value in "$lClockTime$" seconds");

	Clock( lClockTime );
	for(i=0; i<10000; i++)
	{
		lDummy.IncrementDummyInt();
	}
	UnClock( lClockTime );
 
	`log("Getting 10000 element value in "$lClockTime$" seconds");

	Clock( lClockTime );
	for(i=0; i<10000; i++)
	{
	}
	UnClock( lClockTime );
 
	`log("Getting 10000 element value in "$lClockTime$" seconds");*/
	/*for(i=0; i<mMapSize.Z; i++)
	{
		for(j=0; j<mMapSize.Y; j++)
		{
			for(k=0; k<mMapSize.X; k++) 
			{
				lCell.z = i;
				lCell.y = j;
				lCell.x = k;

				SetCell(k, j, i, GetCellType(lCell));
				dummy();
				//    MUw(i,j,GetCellType(vect(i,j,0)));
			}
		}
	}*/
	mLevelManager = xcT_gameinfo(WorldInfo.game).TLevelManager;
	mMap = xcT_gameinfo(WorldInfo.game).TLevelManager.mMap;
	mGrid = xcT_gameinfo(WorldInfo.game).TLevelManager.mMap2;
	//mMapGrid = xcT_gameinfo(WorldInfo.game).TLevelManager.mMapGrid;
	mWPList.Length = mLevelManager.mMap.MapSize().Z*mLevelManager.mMap.MapSize().Y*mLevelManager.mMap.MapSize().X;
	/*mPathFinding = new class'X_COM_AstarPathfinding';
	X_COM_AstarPathfinding(mPathFinding).mLevelManager = xcT_gameinfo(WorldInfo.game).TLevelManager;
	X_COM_AstarPathfinding(mPathFinding).mMapGrid = xcT_gameinfo(WorldInfo.game).TLevelManager.mMapGrid;
	X_COM_AstarPathfinding(mPathFinding).mDefines = */
	//mClosedList.Length = mLevelManager.mMapSize.Z*mLevelManager.mMapSize.Y*mLevelManager.mMapSize.X;
	DIRECTIONS_PURE = 26;
// ������������� ������� ���������� �����������

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

AUTO state MoveToPosition
{
	function bool isTUsEnoughtForStep()
	{
		local int lTUremain;
		local int lTUperStep;

		lTUremain = X_COM_Unit(Pawn).TimeUnitsRemain;
		lTUperStep = class'xcT_Defines'.const.TUperStep;
		return lTUremain >= lTUperStep;
	}
	
	function ProcessTUMovement()
	{
		local int lTUremain;
		local int lTUperStep;

		lTUremain = X_COM_Unit(Pawn).TimeUnitsRemain;
		lTUperStep = class'xcT_Defines'.const.TUperStep;
		X_COM_Unit(Pawn).TimeUnitsRemain = lTUremain - lTUperStep;
	}

Begin:
	// ��������� �������� ����� ���� (��� ��������� ����������)
	mMoveDestination = X_COM_AIController(Outer).NewDestination;
	GetStartingNode();
	GetDestinationNode();
	if (IsZero(mMoveDestination)) // ���� �� ����� �� ������� �������� ����� = 0 ��:
	{
		Sleep(WorldInfo.DeltaSeconds); // ���� 1 ����
		Goto('Ending'); // ���� �� �����
	}

FindPath:

	// �������������� ��������� � ����� ������ �� ���� ����
	// �� ������� ��� ������ = 80, ������ ������ ���������� � 0, �� 79. ������� ����� ����� ����� ���������� � ������ ������ +1
	mLevelManager.mMap.SetCell(mStartCell.X, mStartCell.Y, mStartCell.Z, ct_passable); // ��������� � ����� ������������ ������ � ������� ���� ��������� ������ ��� ����������

	//FindPathWithAstar(mLevelManager.GetCellFromVector(mStartCell), mLevelManager.GetCellFromVector(mDesiredEndCell)); // ����� ����
	//mWaypoints = mLevelManager.mMap.FindPathTo(mLevelManager.GetCellFromVector(mStartCell), mLevelManager.GetCellFromVector(mDesiredEndCell));
	//mPathFinder = mMap.GetPathFinder();
	//mPathFinder.SetSender(self);
	mWaypoints =  mGrid.FindPath(mStartCell, mDesiredEndCell, Walking);//mPathFinder.FindPath();
TEST_TEMP1:
	//TEST_TEMP_ADD_PATH_BLOCKS();
	TEST_TEMP_ADD_DESTENATION_BLOCK();
Moveing:
	if (isTUsEnoughtForStep()) // ���� ����-������ ���������� ���� �� ��� 1�� ����
	{
		if (mWaypoints.Length > 1)
		{
			//mCell = mWaypoints[0].mItem;
			if ( Pawn.NeedToTurn(mWaypoints[1]) ) xcT_AIController(Outer).TurnToPosition(mWaypoints[1], true, false); // ���������� �������������� � ����������� ��������, ���� ��� ����������

			for (mi = 0; mi < mWaypoints.Length; mi++) // ��� ������� �������� ������� MovePoints, ��� TempDest - ��������� ��������.
			//foreach mWaypoints(mNode)
			{
				if (!isTUsEnoughtForStep()) break; // ����� ��������� ���������� �� ����-������ ��� ����

				TempDest = mWaypoints[mi];
				// ��������� TempDest �� ���������� � �������������� �����
				if (isZero(TempDest) || class'xcT_Defines'.static.CheckLocationLimit(TempDest))
				{
					`warn("ERROR! mWaypoints["$mi$"] = "$TempDest);
					break;
				}

				// ��������� ��� ���� ������� �� ����� ����� ������� �������� ����� ��������� �������� � ���� �����.
				// ������ ������� ����� �� ������ ��������� ����� � �����. ��� ��� ��� ��� ��������� ��������� ����� ��������� �����.
				// ���� � ��� ��� ��� ����� ����� (������ ��� ��� ������� � �������� ������ ���� ������ ������� �������� ����, �� ����, ����� ���� ���� ����� � ����� ������ ������)
				TempDest += (Normal(TempDest - Pawn.Location) * (Pawn.GetCollisionRadius()/2) ); // �������� ����� ������������� �� ��������� ������� �������� �������� ����� � ����������� �������� 
				// ��� ��� ���� �������� � ��������� ������. ��������� �������. ���� ����� � ������ ������� �� �������� ������� ���� � ��� ���� ��������������� ��������
				MoveToDirectNonPathPos(TempDest, none, 0.0f, bShouldWalk);

				ProcessTUMovement(); // ��������� ��������������� ��������� �� ���������� ��������
				
				if (!bCanContinueAction) break; // �������� �� �� �����������, ��� ��������� �������� �� �������

				if (bShouldStopAction) break; // ������ �������� �� ������� ����� �������� ����� (�������� ������ �������� ��� ����� �������� �� ��������)
			}
		}
		else `warn("ERROR! mWaypoints lenght = 0");
	}
	else
	{
		// TODO: ������ �� ����� ��������� � ��� ��� ��� �� ��� ������� �����
	}

Finishing:
	mLevelManager.mMap2.mCells.SetCell(mStartCell.X, mStartCell.Y, mStartCell.Z, mLevelManager.ScanCell(mStartCell, , , mRot), mRot); // ��������� � ����� ������������ ������ � ������� ���� ��� �����
	mEndCell = class'xcT_Defines'.static.GetGridNumbersFromLocation(Pawn.Location); // ��������� ��������� �� ���������� ���� ����� ���������� �� ��������� (�������� �� ������� ��)
	mLevelManager.mMap2.mCells.SetCell(mEndCell.X,   mEndCell.Y,   mEndCell.Z,   mLevelManager.ScanCell(mEndCell, , , mRot), mRot); // ��������� � ����� ������������ ������ � ������� ���� ������

Ending:
	PopCommand(Self);
}



event PostPopped()
{
	super.PostPopped();
	TEST_TEMP_ERASE_PATH_BLOCKS();
}

function TEST_TEMP_ADD_PATH_BLOCKS()
{
	local X_COM_Tile lTile;
	local vector lLocation;
	local int il;
	if (mWaypoints.Length > 0)
	{
		for (il = 0; il < mWaypoints.Length; il++)
		{
			lLocation = mWaypoints[il];
			lLocation.Z -= 64;
			lTile = spawn(class'X_COM_Tile', , , lLocation, rot(0,0,0), , true);
			lTile.AddStaticMesh(StaticMesh'TEST_TEMP.Meshes.passable');			
			TEST_TEMP_OBJECTS.AddItem(lTile);
		}
	}
}



function TEST_TEMP_ERASE_PATH_BLOCKS()
{
	local int il;
	if (TEST_TEMP_OBJECTS.Length > 0)
	{
		for (il = 0; il <= TEST_TEMP_OBJECTS.Length -1; il++)
		{
			TEST_TEMP_OBJECTS[il].Destroy();
		}
	}
	TEST_TEMP_OBJECTS.Remove(0, TEST_TEMP_OBJECTS.Length -1);
}

function TEST_TEMP_ADD_DESTENATION_BLOCK()	
{
	local X_COM_Tile lTile;
	local vector lLocation;
	local int il;
	if (mWaypoints.Length > 0)
	{
		lLocation = mWaypoints[mWaypoints.Length-1];
		lLocation.Z -= 64;
		lTile = spawn(class'X_COM_Tile', , , lLocation, rot(0,0,0), , true);
		lTile.AddStaticMesh(StaticMesh'TEST_TEMP.Meshes.passable');			
		TEST_TEMP_OBJECTS.AddItem(lTile);

		//for (il = 0; il < mWaypoints.Length; il++)
		//{
		//	lLocation = mWaypoints[il];
		//	lLocation.Z -= 64;
		//	lTile = spawn(class'X_COM_Tile', , , lLocation, rot(0,0,0), , true);
		//	lTile.AddStaticMesh(StaticMesh'TEST_TEMP.Meshes.passable');			
		//	TEST_TEMP_OBJECTS.AddItem(lTile);
		//}
	}
}

function TEST_TEMP_ERASE_DESTENATION_BLOCK()
{
	local int il;
	if (TEST_TEMP_OBJECTS.Length > 0)
	{
		for (il = 0; il <= TEST_TEMP_OBJECTS.Length -1; il++)
		{
			TEST_TEMP_OBJECTS[il].Destroy();
		}
	}
	TEST_TEMP_OBJECTS.Remove(0, TEST_TEMP_OBJECTS.Length -1);
}











/*
 * OLD VERSION
 * 
 *

//=============================================================================
// Variables: Movement
//=============================================================================
var vector                      PreviousGrid; // Saved old grid pawn location for TU calculation
var Vector                      mCurrentLocation;
var Vector                      mMoveDestination, TempDest;
var protected bool              bShouldWalk;

//=============================================================================
// Variables: Path-Finding
//=============================================================================
var private array<vector>               MovePoints;
var private int                         mi; //counter

var private vector                       Map_Cells; // ������� �������� ����

// ���������� ������ �������� ����, ��� ��� �������� ������� ������
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
} ;

// ������������ ������ ������
struct array_mu_within1 
{        
	var array<Ecell_type> arr1;  // �������-������ ������� ������ ����� ��� �������������
};
var array<array_mu_within1> mu;  // ������ ������

// ������������ ������ ���������
struct array_dst_within1 
{        // �������-������ ������� ���������
	                       // ����� ��� �������������
  var array<float> arr1;  
};
var array<array_dst_within1> dst;  // ������ ���������

// ���������� ����� � ������ ����������
var vector unit_cell, target_cell;

// ����������� ���������� �����������
enum Edirection_from 
{
  df_left,df_right,
  df_up,df_down,
  df_left_up,df_left_down,
  df_right_up,df_right_down,
  df_uninit  // ����������� �� ���������
};

`define DIRECTIONS_ALL 9
`define DIRECTIONS_PURE 8

struct Sdir_vec 
{
	var int x, y, z;
};
// ������������ �����������
var Sdir_vec dv[`DIRECTIONS_PURE];

// ������������ ������ ����������� ������� � ������
struct array_dir_within1 
{        // �������-������ ������� �����������
	                       // ����� ��� �������������
  var array<Edirection_from> arr1;  
};
var array<array_dir_within1> dir;  // ������ ���������

// ����� ����� ������, ������������, �.�. ������������ �����������
// �� ����� ���� ��� ���������� �������� FIFO, �.�. ������ (queue)
// � �� ����� ��� ������� ����������� ���� - LIFO
var array<Sdir_vec> wave_buffer;
var int buffer_read,buffer_write;

var bool is_search_complete;

`define MAX_PATH_LENGTH 400
var Sdir_vec path[`MAX_PATH_LENGTH];  // ���� �� �������
var int path_c; // ����� ���� � "�����"

//=============================================================================
// Events
//=============================================================================
// ���� �����������
event Pushed()
{
	local int i, j;
	local vector lCell;
  Map_Cells.X = class'X_COM_Settings'.default.T_LevelSize.x / class'X_COM_Settings'.default.T_GridSize.x;
  Map_Cells.Y = class'X_COM_Settings'.default.T_LevelSize.y / class'X_COM_Settings'.default.T_GridSize.y;
  // ������� �������� ��������
  mu.Length = Map_Cells.X ;  // ������ ���� � ������� �� �
  dir.Length= Map_Cells.X ;
  dst.Length= Map_Cells.X;
  for(i=0;i<Map_Cells.X;i++)  
  {
    mu[i].arr1.Length = Map_Cells.Y;  // -- �� Y
	dir[i].arr1.Length = Map_Cells.Y;
	dst[i].arr1.Length = Map_Cells.Y;
  }
  /* ���� ����������� ��� �������� ��� ��������� MU ��� �����*/
  /* ���� MU ����� ������� � ������ ������*/



  /***   ��� ����, ��� ������ ���� �� ���� ��������  function Ecell_type GetCellType(vector aCell)???????????????????????  ***/

	for(i=0;i<Map_Cells.X;i++)
	{
		for(j=0;j<Map_Cells.Y;j++) 
		{
			lCell.x = i;
			lCell.y = j;
			MUw(i,j,GetCellType(lCell));
			//    MUw(i,j,GetCellType(vect(i,j,0)));
		}
	}

// ����� ��� �������� 300
`define BUFFER_LENGTH 300
  // ��������� ������ ��� �����
  wave_buffer.Length = `BUFFER_LENGTH;

  // ������������� ������� ���������� �����������
  dv[df_left].x=-1; dv[df_left].y= 0;
  dv[df_right].x=1; dv[df_right].y=0;
  dv[df_up].x=   0; dv[df_up].y=   1;
  dv[df_down].x= 0; dv[df_down].y=-1;
  dv[df_left_up].x=  -1; dv[df_left_up].y=    1;
  dv[df_left_down].x=-1; dv[df_left_down].y= -1;
  dv[df_right_up].x=  1; dv[df_right_up].y=   1;
  dv[df_right_down].x=1; dv[df_right_down].y=-1;
}

//���� ����������
//=============================================================================
// Events
//=============================================================================
event PostPopped()
{
	super.PostPopped();

	StopLatentExecution();
	if (pawn != none) Pawn.ZeroMovementVariables();
}

//=============================================================================
// �������
//=============================================================================
/** ������� ���������� ��� ������ �� ���������� ������: ���������, �� ���������, ����, � �.�. 
 *  @param aCell �� ��� ��� ��������))
 */
function Ecell_type GetCellType(vector aCell)
{
	local Actor lTraceActor;
	local vector lTraceStart, lTraceEnd, lHitLocation, lHitNormal, lWorldLocation, lTraceExtent;

	lWorldLocation = class'xcT_Defines'.static.GetLocationFromGridNumbers(aCell);
	lTraceStart = lWorldLocation;
	lTraceStart.Z += 5; // ������� ������� ���� �����
	lTraceEnd = lWorldLocation;
	lTraceEnd.Z = int(lTraceEnd.Z / class'X_COM_Settings'.default.T_GridSize.Z) * class'X_COM_Settings'.default.T_GridSize.Z - 5; //� ������� ����� ���� ���� ������
	lTraceExtent = Pawn.GetCollisionExtent();
	
	lTraceActor = Trace( lHitLocation, lHitNormal, lTraceEnd, lTraceStart, false, lTraceExtent);//, , class'Actor'.const.TRACEFLAG_Bullet);

	if( lTraceActor != none )
	{
		if (lTraceActor.isA('xcT_Tile_SM_Ground')) return ct_passable;
		if (lTraceActor.isA('xcT_Tile_SM_Object')) return ct_obstacle;
		if (lTraceActor.isA('xcT_Tile_Apex')) return ct_obstacle;
		if (lTraceActor.isA('X_COM_Unit')) return ct_obstacle;//ct_unit;
		return ct_none;
	}
	else `warn(" ERROR. Could not find cell type for Cell : "$aCell$" in Location : "$lTraceStart);
}

// ������� ������ � ������ ����������� ��������
function Ecell_type MUr(int x, int y)
{ return mu[x].arr1[y]; }
function Edirection_from DIRr(int x, int y)
{ return dir[x].arr1[y]; }
function float DSTr(int x, int y)
{ return dst[x].arr1[y]; }
function MUw(int x, int y, Ecell_type cell)
{ mu[x].arr1[y]=cell; }
function DIRw(int x, int y, Edirection_from cell)
{ dir[x].arr1[y]=cell; }
function DSTw(int x, int y, float f)
{ dst[x].arr1[y]=f; }

/** 
* ������� ��������������� ����� � ������ (x,y)
* @param aDir - ����������� �� �������� � ��� ������ �������� ������
* @param distance - ������ ��������� ���� ������� � ����������
*/
function try_go(int x,int y,Edirection_from aDir, float distance)
{
  // ����� �� ������ ����� �� ������� ����
  if(x<0||y<0||x==Map_Cells.X||y==Map_Cells.Y) return;
  // ����� �� ���������������� ������ �����������
  if(MUr(x,y)!=ct_passable) return;
  /* ��� �������� "����������" ����������� ����������� ����������� �������� */
  /* � ������ dir */

  if(x==target_cell.x && y==target_cell.y) {
	DSTw(x,y,distance);  // �������� ���������, �.�. ��������� ������� � TU
	is_search_complete=true;  // ���� ������ ����������
	DIRw(x,y,aDir);  // ��������� �����������
	return;
  }

  if(
 /* 	 (MUr(x,y)==ct_passable  // ������ ���������, �������� ������� ���������
  	    && */
  	  distance<DSTr(x,y) /*)*/ // ��������� �������� ������� ������ ����������, �.�. ������� ���� ����� ��������
  	  ||
	 /*(*/DIRr(x,y)==df_uninit  // � ��� ������ ��� �� ��������� ����� ������
	 /*&&mu[i][j]!=ct_target)*/) {
	// ���������� ����� � ������
	wave_buffer[buffer_write].x=x;
	wave_buffer[buffer_write].y=y;
	buffer_write++;
    // ����������� ������
	if(buffer_write==`BUFFER_LENGTH)
	  buffer_write=0;
    // ������������ ������
	if(buffer_write==buffer_read)
	  `log("Search buffer overflow!!!!!");

	// �������� � �������� ��������� � ����������� �������
    DSTw(x,y,distance);
    DIRw(x,y,aDir);

    /* ����� ����������� ���������� ����� ����� ��������� � ������ */
	/* ����� ����� �������� ��������� �������� ����� 5�� */

	/***
	 * *  ����� ���� ���������� ��� ������� �������� ����� � ������ (x,y) �� ����� �������� distance
	 * 
	***/
	//  DrawDebugString(vector TextLocation, coerce string Text, optional Actor TestBaseActor, optional color TextColor, optional float Duration=-1.f) const;
	// ��� ������������ DrawDebugString("������ ������ ������ �� � ��� ��� ���� ���� ��������� �� ������", "����� ������� ��������");
  }
}

// ����� ������ ����
function gopathfinding()
{
  local int i,j,k;
  local Edirection_from from;
  local vector lCell;

  for(i=0;i<Map_Cells.X;i++)
	for(j=0;j<Map_Cells.Y;j++) {
	  DSTw(i,j,0);
	  DIRw(i,j,df_uninit);
	}
  is_search_complete=false;

  // �������� ������������ �������� �����
  buffer_read=0;buffer_write=1;
  wave_buffer[0].x=unit_cell.x;
  wave_buffer[0].y=unit_cell.y;

  // ���������� ������ ��� ������
  while(!is_search_complete) {
    // ������ �� ������
	i=wave_buffer[buffer_read].x;
	j=wave_buffer[buffer_read].y;
	buffer_read++;
	// ����������� ������
	if(buffer_read==`BUFFER_LENGTH)
	  buffer_read=0;

	// ���������� ���������� ������ �� ������
	for(k=0;k<8;k++) {
	  try_go(i-dv[k].x,j-dv[k].y,Edirection_from(k),DSTr(i,j)+1);
/*	for(from=0;from<df_uninit;from++) {
	  try_go(i-dv[from].x,j-dv[from].y,from,DSTr(i,j)+1); */
	  // ���� ��� ���� ������ ���� = 1,
	  // �� ���� �������� ������� � ����� ���������
	  // �� ���� �����������, ���� ����������, ����������� �����
		  // dist+cena[from]    - +��� �����������
		  // dist+f(cena[from]+cena(i,j)  - +��� �����������
	}
	// �������� �� ���������� ����
	if(buffer_read==buffer_write)  // �.�. ����� ����
	{
      `log("Path not found!!!");
	  return;
	}
  }

  i=target_cell.x;
  j=target_cell.y; 
  path_c=0;
  while(!(i==unit_cell.x&&j==unit_cell.y)) {
	path[path_c].x=i;
	path[path_c].y=j;
	path_c++;
	if(path_c==`MAX_PATH_LENGTH) {
	  `log("MAX path exceeded!!");
	  return;
	}
	from=DIRr(i,j);
	i+=dv[from].x;
	j+=dv[from].y;
/*	gotoxy(j+1,i+1);
	cprintf("%c",2);  // ��������� ��������� ����
	delay(100); */
    }
  lCell.x=unit_cell.x;
  lCell.y=unit_cell.y;
  lCell.z=unit_cell.z;
  WorldInfo.MyEmitterPool.SpawnEmitter(class'X_COM_Settings'.default.ClickToTerrainEffect, class'xcT_Defines'.static.GetLocationFromGridNumbers(lCell), rot(0,0,0));
  i=0;
  for(k=path_c-1;k>-1;k--) {
    MovePoints.Add(1);
/*    MovePoints[i].x=path[k].x * class'X_COM_Settings'.default.T_GridSize.x;
    MovePoints[i].y=path[k].y * class'X_COM_Settings'.default.T_GridSize.y; */
	lCell.x=path[k].x;
	lCell.y=path[k].y;
	lCell.z=path[k].z;
    MovePoints[i]=class'xcT_Defines'.static.GetLocationFromGridNumbers(lCell);
	WorldInfo.MyEmitterPool.SpawnEmitter(class'X_COM_Settings'.default.ClickOnEarthEffect, MovePoints[i], rot(0,0,0));
	i++;
  }
}

//=============================================================================
// State
//=============================================================================
AUTO state MoveToPosition
{
	/** Trace Actor under location */
	function Actor ActorUnderTraceLocation(vector aTraceLocation)
	{
		local Vector lTraceLocation, lHitLocation, lHitNormal, lTraceExtent;
		local Vector lTraceStart, lTraceEnd;//, lTraceDir;	
		local Actor lActor;

		lTraceExtent = class'X_COM_Settings'.default.T_GridSize / 2; //half then grid

		lTraceLocation = aTraceLocation;
		lTraceStart = lTraceLocation;
		lTraceStart.Z += class'X_COM_Settings'.default.T_GridSize.Z / 2;
		lTraceEnd = lTraceLocation;
		lTraceEnd.Z -= class'X_COM_Settings'.default.T_GridSize.Z / 2;

		lActor = Trace( lHitLocation, lHitNormal, lTraceEnd, lTraceStart, true, lTraceExtent);

		return lActor;
	}

	//function bool isTUsEnoughtForStep()
	//{
	//	local int lTUremain;
	//	local int lTUperStep;
	//	local bool lresult;

	//	lTUremain = X_COM_Unit(Pawn).mData.TimeUnitsRemain;
	//	switch (ActorUnderTraceLocation(PreviousGrid).class)
	//	{
	//		case    class'xcT_Tile_Ground' :   lTUperStep = class'xcT_Defines'.const.TUperStepOnLand;
	//		break;
	//		case    class'xcT_Tile_Object' :   lTUperStep = class'xcT_Defines'.const.TUperStepOnObject;
	//		break;
	//	}

	//	if (lTUremain < lTUperStep ) lresult = false;
	//	else lresult = true;
	//	return lresult;
	//}

	function bool isTUsEnoughtForStep()
	{
		local int lTUremain;
		local int lTUperStep;
		local bool lresult;
		local Actor lActorUnderUnit;

		lActorUnderUnit = ActorUnderTraceLocation(PreviousGrid);

		if (lActorUnderUnit != none)
		{
			lTUremain = X_COM_Unit(Pawn).mData.TimeUnitsRemain;
			switch (lActorUnderUnit.class)
			{
				case    class'xcT_Tile_SM_Ground' :   lTUperStep = class'xcT_Defines'.const.TUperStepOnLand;
				break;
				case    class'xcT_Tile_SM_Object' :   lTUperStep = class'xcT_Defines'.const.TUperStepOnObject;
				break;
			}

			if (lTUremain < lTUperStep ) lresult = false;
			else lresult = true;
			return lresult;
		}
		else return false;
	}
	
	function MovingWithTU()
	{
		local int lTUremain;
		local int lTUperStep;
		local Vector NowInGrid;

		lTUremain = X_COM_Unit(Pawn).mData.TimeUnitsRemain;
		switch (ActorUnderTraceLocation(PreviousGrid).class)
		{
			case    class'xcT_Tile_SM_Ground' :   lTUperStep = class'xcT_Defines'.const.TUperStepOnLand;
			break;
			case    class'xcT_Tile_SM_Object' :   lTUperStep = class'xcT_Defines'.const.TUperStepOnObject;
			break;
		}

		if (lTUremain >= lTUperStep ) 
		{
			NowInGrid = class'xcT_Defines'.static.GetGridCoord(Pawn.Location);
			if (PreviousGrid != NowInGrid)
			{
				X_COM_Unit(Pawn).mData.TimeUnitsRemain = lTUremain - lTUperStep;
				PreviousGrid = NowInGrid;
			}
		}
	}

Begin:
	//`log("xT_AICommand_MoveToPosition  executed ---------------------------- "); // ����� � ��� ���� ��� ����������� ����������� ��������� � ������� ����.

	// ��������� �������� ����� ���� (��� ��������� ����������)
	mMoveDestination = X_COM_AIController(Outer).NewDestination;
	if (IsZero(mMoveDestination)) // ���� �� ����� �� ������� �������� ����� = 0 ��:
	{
		Sleep(WorldInfo.DeltaSeconds); // ���� 1 ����
		Goto('Ending'); // ���� �� �����
	}

Moveing:
	// �������������� ��������� � ����� ������ �� ���� ����
	// �� ������� ��� ������ = 80, ������ ������ ���������� � 0, �� 79. ������� ����� ����� ����� ���������� � ������ ������ +1
	unit_cell = class'xcT_Defines'.static.GetGridNumbersFromLocation(Pawn.Location); // ���� ��������� ������
	target_cell = class'xcT_Defines'.static.GetGridNumbersFromLocation(mMoveDestination); // ����� ����������, �.�. ���� ��������.

	//`log(" unit_cell : "$class'xcT_Defines'.static.CellToVect(unit_cell)$" | target_cell : "$class'xcT_Defines'.static.CellToVect(target_cell));

	if (isTUsEnoughtForStep()) // ���� ����-������ ���������� ���� �� ��� 1�� ����
	{
		gopathfinding(); // ����� ����

		if (MovePoints.Length > 0)
		{
			xcT_AIController(Outer).TurnToPosition(MovePoints[0], true, false);

			for (mi=0; mi < MovePoints.Length; mi++) // ��� ������� �������� ������� MovePoints, ��� TempDest - ��������� ��������.
			{
				TempDest = MovePoints[mi];

				// ��������� ��� ���� ������� �� ����� ����� ������� �������� ����� ��������� �������� � ���� �����.
				// ������ ������� ����� �� ������ ��������� ����� � �����. ��� ��� ��� ��� ��������� ��������� ����� ��������� �����.
				// ���� � ��� ��� ��� ����� ����� (������ ��� ��� ������� � �������� ������ ���� ������ ������� �������� ����, �� ����, ����� ���� ���� ����� � ����� ������ ������)
				TempDest = TempDest + (Normal(TempDest - Pawn.Location) * Pawn.GetCollisionRadius()); // �������� ����� ������������� �� ��������� ������� �������� �������� ����� � ����������� ��������

				// ��� ��� ���� �������� � ��������� ������. ��������� �������. ���� ����� � ������ ������� �� �������� ������� ���� � ��� ���� ��������������� ��������
				MoveToDirectNonPathPos(TempDest, none, 0.0f, bShouldWalk);
				
				if (!bCanContinueAction) break; // 

				if (!isTUsEnoughtForStep()) break;
				else MovingWithTU(); //��� ���� ���� ����� ��������� �� ���� ��������������� ��� ������ � �� � ������
			}
		}
	}

Ending:
	PopCommand(Self);
}
*/