/**
 * 
 * 
 */
class X_COM_PathFinding extends Object;


var X_COM_Node mStartPosition;
var X_COM_Node mEndPosition;

enum ESearchState
{
    ss_Searching,
    ss_Found,
    ss_NotFound
};

var X_COM_PathFindingInterface mInterface;
//var X_COM_NodeMap mNodeMap;
//var X_COM_Sender mSender;
//delegate PathFoundEventHandler(array<X_COM_Node> aGridNumber);

//=============================================================================
// Constructors
//=============================================================================


static function X_COM_PathFinding Construct(optional X_COM_PathFindingInterface aInterface = none)
{
	local X_COM_PathFinding lPathF;
	lPathF = new class'X_COM_PathFinding';
	if(aInterface != none)
		lPathF.mInterface = aInterface;
	return lPathF;
}

//=============================================================================
// Functions
//=============================================================================
/*public function X_COM_TacticalMap SetStartPosition(Vector aPosition)
{
	mStartPosition = aPosition;
	return self;
}

public function X_COM_TacticalMap SetEndPosition(Vector aPosition)
{
	mEndPosition = aPosition;
	return self;
}*/

public function bool IsWayCrdsValid()
{
	local bool lstart, lend;

	lstart = (mStartPosition.mItem.X() != -1 && mStartPosition.mItem.Y() != -1 && mStartPosition.mItem.Z() != -1);
	lend = (mStartPosition.mItem.X() != -1 && mStartPosition.mItem.Y() != -1 && mStartPosition.mItem.Z() != -1);
	
	Return lstart && lend;
}

function EPosition SelectMostOptimalMovement(X_COM_MapCell aFrom, X_COM_MapCell aDest, optional out float points)
{
	local Vector lFrom, lDest;//, lWay;
	local X_COM_Direction lCompass;
	local EDirection ldir;
	/*if(mMapGrid[aCellId].CellType)
		return TUperStepOnLand;*/
	/** @todo
	 *  �������� �������� �� ��� ������, �������� �������� � �� ������������.*/
	
	lFrom = aFrom.Crd();
	lDest = aDest.Crd();
	lCompass = new class'X_COM_Direction';
	ldir = EDirection(lCompass.DirectionToCrd(lFrom, lDest).Get());
	if(ldir != df_uninit)
	{
		if(aDest.getDirectionType(EDirection(ldir)) == ct_obstacle)
			return EP_none;
	}
	if(!( aDest.CellType() == ct_obstacle || aDest.CellType() == ct_none))
	{
		points = class'X_COM_MovementRules'.const.TUperStep;
		if(lCompass.IsDiagonal())
			points *= 1.4;
		return EP_Standing;
	}
	else
		return EP_none;
}
/*
function int Heuristic(X_COM_MapCell aStart, X_COM_MapCell aEnd)
{
	local int counter;
	counter = (abs(aStart.X - aEnd.X) + abs(aStart.Y - aEnd.Y) + abs(aStart.Z - aEnd.Z))*4;
	return counter;
}*/

function array<X_COM_Node> ReturnWayToCell(X_COM_Node aElem, optional out int aSumm)
{
	local X_COM_Node lCE;
	local array<X_COM_Node> lResult;

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
		//SelectMostOptimalMovement(mPawn, lCE.parent, lCE.cell, lPrice);
		aSumm += lCE.mF_PathScore;
		//lVector.X = lCE.mItem.x();
		//lVector.y = lCE.mItem.y();
		//lVector.z = lCE.mItem.z();
		lResult.InsertItem(0, lCE);
		if(lCE.mParent != none)
			lCE = lCE.mParent;
		else
			lCE = none;
	}
	return lResult;
}

public function array<X_COM_Node> FindPath()
{
/*	local int X, Y, Z, lDir;
	local float G, H, TempG;
	local X_COM_MapCell lCell;
	local X_COM_Node lNode;
	local float lPoints;
	local array<X_COM_Node> lNeighbors;
	local array<X_COM_Node> lResult;
	local X_COM_OpenClosedNodeColection lNodeCollection;

	local X_COM_Node lSelected;
	local EPosition lMovementType;
	local X_COM_Compass lCompass;
	local vector  lCrd;
	lCompass = class'X_COM_Compass'.static.GetInstance();
	mStartPosition = mSender.GetStartingNode();
	mEndPosition = mSender.GetDestinationNode();

	lResult.Length = 0;
	if(!IsWayCrdsValid())
	{
		`warn("X_COM_PathFinder::FindPath - Way coordinates are invalid!!!");
		return lResult;
	}
	if(mEndPosition.mItem.CellType() != ct_obstacle)
	{
		//mOpenList.Remove(0, mOpenList.Length);
		//1.	�������� ��������� ����� � �������� ������.
		/*lNode = new class'X_COM_Node';
		lNode.Id(aStart.Id());
		lNode.mItem = aStart;
		lNode.mParent = none;
		lNode.mG_CurrentCost = 0;
		lNode.mH_HeuristicDistance = 0;
		lNode.mF_PathScore = 0;*/
		lNodeCollection = new class'X_COM_OpenClosedNodeColection';
		lNodeCollection.AddOpen(mStartPosition);
		lSelected = mStartPosition;

		//2.	��������� � �����, ���� �� ������� �������� ����������� ���� � ����.
		while(lSelected.Id() != mEndPosition.Id())
		{
			//a.	������� �������� ����������� �� F ������� ��������� ������.
			//lI = lNodeCollection.FindLowestF();
			lSelected = lNodeCollection.NearestNode();
			//c.	�������� ������� � �������� ������.
			lNodeCollection.AddClosed(lSelected);
			//MoveToClosedList(mOpenList[lI]);
			//b.	������� ������� �� ��������� ������.
			//mOpenList.Remove(lI, 1);
			//d.	�������� ���� ������� � �������� ������.

			//for(lDir = 0; lDir < lCompass.const.DIRECTIONS_PURE; lDir++)
			//{
			//	if(lDir != df_self)
			//	{
			//		lCrd = lCompass.GetNeighbor(lSelected.Item().CellCrd(), Edirection(lDir));
			//		if(class'X_COM_TacticalMap'.static.IsCrdValid(lCrd))
			//		{

			//for(lDir = 0; lDir < class'X_COM_MapCell'.const.DIRECTIONS_PURE; lDir++)
			//{
			//	Z = lSelected.mItem.z + lCompass.Z();// dir[lDir].Z;
			//	if(Z >= 0 && Z < class'X_COM_Settings'.default.T_GridSize.z)
			//	{
			//		Y = lSelected.mItem.y + lCompass.Y();//dir[lDir].Y;
			//		if(Y >= 0 && Y < class'X_COM_Settings'.default.T_GridSize.y)
			//		{
			//			X = lSelected.mItem.x + lCompass.X();//dir[lDir].X;
			//			if(X >= 0 && X < class'X_COM_Settings'.default.T_GridSize.x)
			//			{

			lNeighbors = mInterface.mNodeMap.GetChildNodes(lSelected);
						/** @todo �������� �������� �� ������������ ������, ������ ��� ��������� � � �������� ������*/
						lCell = mNodeMap.GetCell(lCrd.X, lCrd.Y, lCrd.Z);
						lMovementType = SelectMostOptimalMovement(lSelected.mItem, lCell, lPoints);
						if(lMovementType == EP_NotPassable)
						{
							continue;
						}
						lNode = lNodeCollection.mNodeDictionary[lCell.Id()];
						if(lNode != none  /*mWPList[lCell.Id()] != none*/)
						{
								
							/*if(lNode.ListType == lt_OpenList)
							{
								TempG = GetG(lNode, mSelected);
								G = mWPList[lCell.Id()].G;
								H = mWPList[lCell.Id()].H;
								if((TempG + H) < (G + H))
									mWPList[lCell.Id()].SetParent(mSelected);
								continue;
							}
							else
								continue;*/

							continue;
						}
						H = Heuristic(lCell, mEndPosition.mItem);
						//lElem = AddToOpenList(lCell.Id(), lCell, mSelected, 0, H);;
						lNode =  class'X_COM_Node'.static.Construct(lCell.Id(), lSelected, lPoints, H, lMovementType, lCell);
						lNodeCollection.AddOpen(lNode);
						//G = GetG(mOpenList[lElem]);
						//mOpenList[lElem].G = G;
								
						//vi.	�� �������� � �������� ������ �������, ������������ ��� ������� �����.
			//		}
			//	}
			//}
								
			//			}
			//		}
			//	}
			//}
		}
		//3.	��������� ���������� ���� ��� ������ ������� ���������� �������������� �����.
		lResult = ReturnWayToCell(lNodeCollection.mNodeDictionary[mEndPosition.Id()]);
		return lResult;
	}
*/

	local array<X_COM_Node> lPathNodeList;                  // ���� ����� ������������ ����
	//local array<X_COM_Node> lChildNodes;                    // ������ �������� �����
	local X_COM_Node lActualNode;//, lNode;                    // ����������� ����
	local X_COM_Node lDestinationNode;                      // �������� ����
	local X_COM_Node lNearestNode;                          // ��������� ����
	local ESearchState lSearchResult;                       // ��������� ������
	local X_COM_OpenClosedNodeColection lNodeCollection;    // ������ ����������� �����
//	local X_COM_MapCell lCell;

	lNodeCollection = new class'X_COM_OpenClosedNodeColection';
	//`log("Finding path with A*");
    lActualNode = mInterface.GetStartingNode();         // �������� ��������� ���� � ��������� ��� ������� �����������
	//`log("Starting node:");
	//lActualNode.DebugOutput();
    lDestinationNode = mInterface.GetDestinationNode(); // �������� �������� ����
	//`log("Destination:");	
	//lDestinationNode.DebugOutput();
	lSearchResult = ss_Searching;
	//	`log("============================================================================");
    // ���������, �� ������ �� ��������� � �������� ����?
    if (lActualNode == none || lDestinationNode == none)
    {
        return lPathNodeList;
    }


    // �������� �����
    do
    {
		//`log("Getting child nodes:");
        // �������� �������� ���� 
        mInterface.GetChildNodes(lActualNode, lNodeCollection);
		//`log("============================================================================");
        // ��������� ����������� ���� � �������� ������
        lNodeCollection.AddClosed(lActualNode);
		//`log("============================================================================");
        // ��������� �������� ����
        if (lNodeCollection.mNodeDictionary.Length > 0)
        {
            /*foreach lChildNodes (lNode)
            {
                // ��������� ���� � �������� ������, ���� �� ��������
				if(lNode.mMovementMode != EP_none)
				{
					lNodeCollection.AddOpen(lNode);
				}
            }*/

            // �������� ��������� ����
            lNearestNode = lNodeCollection.NearestNode();

            if (lNearestNode != none)
            {
                //lCell = lNearestNode.mItem;
            	lActualNode = lNearestNode;

                // ���� ����������, ���������� �����
                if (lActualNode.Equals(lDestinationNode))
                {
                    lSearchResult = ss_Found;
                }
            }
            else
            {
                // �������� ����� �� ��������, ������� �����
                lActualNode = lActualNode.mParent;

                // ���� �� ����������
                if (lActualNode == none)
                {
                    lSearchResult = ss_NotFound;
                }
            }
        }
        else
        {
            // �������� ����� �� ����������, ������� �����
            lActualNode = lActualNode.mParent;

            // ���� �� ����������, ���������� �����
            if (lActualNode == none)
            {
                lSearchResult = ss_NotFound;
            }
        }
    }
    until (lSearchResult != ss_Searching);

    // ���� ���� ������, ��������� ���
    if (lSearchResult == ss_Found)
    {
        // ��������� ���� �� �������� ����������� �����
		//do
        while (lActualNode.mParent != none)
        {
//			lCell = lActualNode.mItem;
            lPathNodeList.InsertItem(0, lActualNode);
            lActualNode = lActualNode.mParent;
        }
		//until(lActorNode.mParent == none);
    }

    // ���������� ��������� ����
	//local array<X_COM_Node> lPathNodeList;
	
    return lPathNodeList;

	// ����������� ������
/*
	local array<X_COM_Node> lPathNodeList;                  // ���� ����� ������������ ����
	local array<X_COM_Node> lChildNodes;                    // ������ �������� �����
	local X_COM_Node lActualNode, lNode;                    // ����������� ����
	local X_COM_Node lDestinationNode;                      // �������� ����
	local X_COM_Node lNearestNode;                          // ��������� ����
	local ESearchState lSearchResult;                       // ��������� ������
	local X_COM_OpenClosedNodeColection lNodeCollection;    // ������ ����������� �����
	local X_COM_MapCell lCell;

	lNodeCollection = new class'X_COM_OpenClosedNodeColection';
	//`log("Finding path with A*");
    lActualNode = mInterface.GetStartingNode();         // �������� ��������� ���� � ��������� ��� ������� �����������
	//`log("Starting node:");
	lActualNode.DebugOutput();
    lDestinationNode = mInterface.GetDestinationNode(); // �������� �������� ����
	//`log("Destination:");	
	lDestinationNode.DebugOutput();
	lSearchResult = ss_Searching;
	//	`log("============================================================================");
    // ���������, �� ������ �� ��������� � �������� ����?
    if (lActualNode == none || lDestinationNode == none)
    {
        return lPathNodeList;
    }


    // �������� �����
    do
    {
		//`log("Getting child nodes:");
        // �������� �������� ���� 
        lChildNodes = mInterface.GetChildNodes(lActualNode, lNodeCollection);
		//`log("============================================================================");
        // ��������� ����������� ���� � �������� ������
        lNodeCollection.AddClosed(lActualNode);
		//`log("============================================================================");
        // ��������� �������� ����
        if (lChildNodes.Length > 0)
        {
            foreach lChildNodes (lNode)
            {
                // ��������� ���� � �������� ������, ���� �� ��������
				if(lNode.mMovementMode != EP_none)
				{
					lNodeCollection.AddOpen(lNode);
				}
            }

            // �������� ��������� ����
            lNearestNode = lNodeCollection.NearestNode();

            if (lNearestNode != none)
            {
                lCell = lNearestNode.mItem;
            	lActualNode = lNearestNode;

                // ���� ����������, ���������� �����
                if (lActualNode.Equals(lDestinationNode))
                {
                    lSearchResult = ss_Found;
                }
            }
            else
            {
                // �������� ����� �� ��������, ������� �����
                lActualNode = lActualNode.mParent;

                // ���� �� ����������
                if (lActualNode == none)
                {
                    lSearchResult = ss_NotFound;
                }
            }
        }
        else
        {
            // �������� ����� �� ����������, ������� �����
            lActualNode = lActualNode.mParent;

            // ���� �� ����������, ���������� �����
            if (lActualNode == none)
            {
                lSearchResult = ss_NotFound;
            }
        }
    }
    until (lSearchResult != ss_Searching);

    // ���� ���� ������, ��������� ���
    if (lSearchResult == ss_Found)
    {
        // ��������� ���� �� �������� ����������� �����
		//do
        while (lActualNode.mParent != none)
        {
			lCell = lActualNode.mItem;
            lPathNodeList.InsertItem(0, lActualNode);
            lActualNode = lActualNode.mParent;
        }
		//until(lActorNode.mParent == none);
    }

    // ���������� ��������� ����
	//local array<X_COM_Node> lPathNodeList;
	
    return lPathNodeList;*/
}

//=============================================================================
// Default properties
//=============================================================================
defaultproperties
{
//	mStartPosition = (-1, -1, -1)
//	mEndPosition = (-1, -1, -1)
    Name="Default__X_COM_PathFinding"	
}