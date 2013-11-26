/**
 * HUD class 
 * 
 */
class X_COM_PathFindingInterface extends object dependson(X_COM_Defines, X_COM_MapCell, X_COM_Node, X_COM_PathFinding);

//=============================================================================
// Variables: References
//=============================================================================
var X_COM_PathFinding mPathfinder;
var X_COM_MapCell mStartPosition;
var X_COM_MapCell mEndPosition;

var private X_COM_NodeMap mNodeMap;
var private X_COM_MovementType mMovementType;
var private X_COM_Sender mSender;
//=============================================================================
// Constructors
//=============================================================================

static function X_COM_PathFindingInterface Construct(X_COM_NodeMap aNodeMap, X_COM_Sender aSender, X_COM_PathFinding aPathFinder)
{
	local X_COM_PathFindingInterface lPathF;
	lPathF = new class'X_COM_PathFindingInterface';
	lPathF.mNodeMap = aNodeMap;
	lPathF.SetSender(aSender);
	lPathF.SetPathFinder(aPathFinder);

	return lPathF;
}

//=============================================================================
// Functions
//=============================================================================
function SetStartPosition(vector aStartPos)
{
	if(aStartPos.X != -1 && aStartPos.Y != -1 && aStartPos.Z != -1)
		mStartPosition = mNodeMap.GetCell(aStartPos.X, aStartPos.Y, aStartPos.Z);
	else
		`warn("Invalid starting coordinates");
}

function SetEndPosition(vector aEndPos)
{
	if(aEndPos.X != -1 && aEndPos.Y != -1 && aEndPos.Z != -1)
		mEndPosition = mNodeMap.GetCell(aEndPos.X, aEndPos.Y, aEndPos.Z);
	else
		`warn("Invalid starting coordinates");
}

function SetSender(X_COM_Sender aSender)
{
	mSender = aSender;
	if(aSender != none)
	{
		SetStartPosition(aSender.GetStartingNode());
		SetEndPosition(aSender.GetDestinationNode());
	}
	else
	{
		mStartPosition = none;
		mEndPosition = none;
	}

}

function SetPathFinder(X_COM_PathFinding aPathFinder)
{
	if(aPathFinder != none)
	{
		mPathfinder = aPathFinder;
		aPathFinder.mInterface = self;
	}
}

function X_COM_Node GetStartingNode()
{
	local X_COM_Node lStartPosition;
//	local X_COM_MapCell lCell;

	//lCell = mStartPosition;
	//lPos = lCell.SelectMostOptimalMovement(mSender, Edirection(lDir), lPoints);

	//lH = lCell.Heuristic(mEndPosition.mItem.CellCrd());
	lStartPosition =  class'X_COM_Node'.static.Construct(mStartPosition.Id(), none, 0, 0, EP_none, mStartPosition);

	return lStartPosition;
}
function X_COM_Node GetDestinationNode()
{
	local X_COM_Node lEndPosition;
//	local X_COM_MapCell lCell; 

	//lCell = mNodeMap.GetCell(mEndPosition.X, mEndPosition.Y, mEndPosition.Z);
	//lPos = lCell.SelectMostOptimalMovement(mSender, Edirection(lDir), lPoints);
	if(mEndPosition.mCellType == ct_none || mEndPosition.mCellType == ct_obstacle)
		lEndPosition =  none;
	else
		lEndPosition =  class'X_COM_Node'.static.Construct(mEndPosition.Id(), none, 0, 0, EP_none, mEndPosition);

	return lEndPosition;
}

public function bool IsWayCrdsValid()
{
	local bool lstart, lend;

	lstart = (mStartPosition.X() != -1 && mStartPosition.Y() != -1 && mStartPosition.Z() != -1);
	lend = (mStartPosition.X() != -1 && mStartPosition.Y() != -1 && mStartPosition.Z() != -1);
	
	Return lstart && lend;
}

static function bool IsCrdValid(Vector aCrd)
{
	local bool x, y, z;
	x = (aCrd.X >= 0 && aCrd.X < class'X_COM_Settings'.default.T_GridSize.X);//mMapSize.X);
	y = (aCrd.Y >= 0 && aCrd.Y < class'X_COM_Settings'.default.T_GridSize.Y);//mMapSize.Y);
	z = (aCrd.Z >= 0 && aCrd.Z < class'X_COM_Settings'.default.T_GridSize.Z);//mMapSize.Z);

	return (x && y && z);
}

public function array<X_COM_Node> FindPath()
{
	local array<X_COM_Node> lArr;
	local X_COM_Pathfinding lPathfinding;

	

	lArr.Length = 0;

	if(IsWayCrdsValid())
	{
		if(mPathfinder == none)
		{
			//`warn("Path finder is not assigned");
			//return lArr;
			lPathfinding = class'X_COM_PathFinding'.static.Construct(self);
			SetPathFinder(lPathfinding);
		}
		return mPathfinder.FindPath();
	}
	else
	{
		`warn("Invalid coordinates");
		return lArr;
	}
}

function int Heuristic(X_COM_MapCell aStart, X_COM_MapCell aEnd)
{
	local int counter;
	counter = (abs(aStart.X() - aEnd.X()) + abs(aStart.Y() - aEnd.Y()) + abs(aStart.Z() - aEnd.Z()))*10;
	return counter;
}

function GetChildNodes(X_COM_Node aActualNode, X_COM_OpenClosedNodeColection aCollection)
{
	local EPosition lPos;
	local X_COM_MapCell lCell;
	local X_COM_Direction lDirection;
	local EListType lListType;
	local float lPoints;
	local int lH;
	local X_COM_Node lNode;
	
	lDirection = new class'X_COM_Direction';
	for(lDirection.DirectionsIterationStart(); lDirection.Get() != df_uninit; lDirection.Iterate())
	{
		lCell = aActualNode.Item().SelectMostOptimalMovement(mSender, Edirection(lDirection.Get()), lListType, lPos, lPoints);//aActualNode.Item().GetNeighbor(lDirection.Get());
		if(lCell != none)
		{
			/*if(aCollection.mNodeDictionary[lCell.Id()] != none)
			{
				if(aCollection.mNodeDictionary[lCell.Id()].ListType == lt_ClosedList)
				{
					continue;
				}
				lNode = aCollection.mNodeDictionary[lCell.Id()];
			}
			else
			{
				lNode =  class'X_COM_Node'.static.Construct(lCell.Id(), aActualNode, lPoints, lH, EPosition(lPos), lCell);
			}*/
			//lType = EListType(lCell.SelectMostOptimalMovement(mSender, Edirection(lDirection.Get()), lPos, lPoints));
 			if(lCell.Id() < aCollection.mNodeDictionary.Length && aCollection.mNodeDictionary[lCell.Id()] != none && aCollection.mNodeDictionary[lCell.Id()].ListType == lt_ClosedList)
			{
				continue;
			}
			lH = Heuristic(lCell, mEndPosition);
			lNode =  class'X_COM_Node'.static.Construct(lCell.Id(), aActualNode, lPoints, lH, EPosition(lPos), lCell, lListType);
			aCollection.AddToList(lNode);
		}
	}
}


function GetChildMultyNodes(X_COM_Node aActualNode, X_COM_OpenClosedNodeColection aCollection)
{
	local EPosition lPos;
	local X_COM_MapCell lCell;
	local X_COM_Direction lDirection;
	local EListType lListType;
	local float lPoints;
	local float lH;
	local X_COM_Node lNode;
	
	lDirection = new class'X_COM_Direction';
	for(lDirection.DirectionsIterationStart(); lDirection.Get() != df_uninit; lDirection.Iterate())
	{
		lCell = aActualNode.Item().SelectMostOptimalMovement(mSender, Edirection(lDirection.Get()), lListType, lPos, lPoints);//aActualNode.Item().GetNeighbor(lDirection.Get());
		if(lCell != none)
		{
			/*if(aCollection.mNodeDictionary[lCell.Id()] != none)
			{
				if(aCollection.mNodeDictionary[lCell.Id()].ListType == lt_ClosedList)
				{
					continue;
				}
				lNode = aCollection.mNodeDictionary[lCell.Id()];
			}
			else
			{
				lNode =  class'X_COM_Node'.static.Construct(lCell.Id(), aActualNode, lPoints, lH, EPosition(lPos), lCell);
			}*/
			//lType = EListType(lCell.SelectMostOptimalMovement(mSender, Edirection(lDirection.Get()), lPos, lPoints));
			if(aCollection.mNodeDictionary[lCell.Id()] != none && aCollection.mNodeDictionary[lCell.Id()].ListType == lt_ClosedList)
			{
				continue;
			}
			lH = Heuristic(lCell, mEndPosition);
			lNode =  class'X_COM_Node'.static.Construct(lCell.Id(), aActualNode, lPoints, lH, EPosition(lPos), lCell, lListType);
			aCollection.AddToList(lNode);
		}
	}
}
/*
function array<X_COM_Node> GetChildNodes(X_COM_Node aActualNode, X_COM_OpenClosedNodeColection aCollection)
{
	local array<X_COM_Node> lNodes;
	local X_COM_Node lNode;
	local Vector lCrd;
	local int lid;
	local float lcost;
	local int lDir, lH;
	local EListType lType;
	local EPosition lPos;
	local X_COM_MapCell lCell;
	local X_COM_Direction lCompass;
	local float lPoints;
	
	lCompass = new class'X_COM_Direction';
	for(lDir = 0; lDir < lCompass.const.DIRECTIONS_PURE; lDir++)
	{
		if(lDir != df_self)
		{

			lCrd = lCompass.GetNeighbor(aActualNode.Item().Crd(), Edirection(lDir));
			if(IsCrdValid(lCrd))
			{
				lCell = mNodeMap.GetCell(lCrd.X, lCrd.Y, lCrd.Z);
				lType = EListType(lCell.SelectMostOptimalMovement(mSender, Edirection(lDir), lPos, lPoints));
				
				//lid = IdFromVector(lCrd);
				//lPos = EPosition(mMapGrid[lid].SelectMostOptimalMovement(Edirection(lDir), lcost));

				// Если цена клетки равна -1, значит клетка непроходима для данного солдата
				//if(lcost > -1)
				//	lcost = aActualNode.mG_CurrentCost + lcost;
				//lNodes.Add(1);
				//lNodes[lNodes.Length-1] = new class'X_COM_Node';
				//lNodes[lNodes.Length-1].Construct(lid, aActualNode, lcost, getHeuristic(), GetCellFromVector(lCrd));
				lH = lCell.Heuristic(mEndPosition);
				lNode =  class'X_COM_Node'.static.Construct(lCell.Id(), aActualNode, lPoints, lH, EPosition(lPos), lCell);
				//lNode.Construct(lid, aActualNode, aActualNode.mG_CurrentCost + lcost, lH, EPosition(lPos), GetCellFromVector(lCrd));
				//lNode.DebugOutput();
				lNodes.AddItem(lNode);
			}
		}
	}
	return lNodes;
}
*/
//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
//	mStartPosition = (-1, -1, -1)
//	mEndPosition = (-1, -1, -1)
	Name="Default__X_COM_PathFindingInterface"
}