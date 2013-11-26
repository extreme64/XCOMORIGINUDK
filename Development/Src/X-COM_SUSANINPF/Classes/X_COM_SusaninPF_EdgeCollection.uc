/**
 * X-COM Tactics functions and variables class. 
 * Uses to store functions and variables for tactics classes.
 */
class X_COM_SusaninPF_EdgeCollection extends Object dependson(X_COM_SusaninPF_CellCollection);

struct EdgeStructure
{	
    var float Type;
    var Vector From;
	var Vector To;
};

struct EdgeStructureDynamicArrayStruct
{
    var array<EdgeStructure> Data;
};

struct CellEdgeIndex
{
    var Vector From;
    var Vector To;
};
//=============================================================================
// Fields
//=============================================================================
var protected int mMapId; // Represents ID of the SusaninPF map. Used for all operations on the map.

var private X_COM_SusaninPF_Interface mInterface; // SusaninPathFinder interface

var array<EdgeStructure> mEdges; // Edges of the cells

var array<EdgeStructure> mEdgesToCommit; // Edges that should be commited
//=============================================================================
// Constructors
//=============================================================================

public static function X_COM_SusaninPF_EdgeCollection Constructor(int aid, X_COM_SusaninPF_Interface aInterface)
{
	local X_COM_SusaninPF_EdgeCollection lCollection;

	lCollection = new class'X_COM_SusaninPF_EdgeCollection';
	lCollection.mMapId = aid;
	lCollection.mInterface = aInterface;

	return lCollection;
}

//=============================================================================
// Functions
//=============================================================================

public static function bool GetEdgeIndex(vector first, vector second, out CellEdgeIndex aIndex)
{
	local CellEdgeIndex lIndex;

	if (first.Z < second.Z)
    {
        lIndex.From = first;
        lIndex.To = second;
    }
    else
    if(first.Z > second.Z)
    {
        lIndex.From = second;
        lIndex.To = first;
    }
	else
	{
		if(first.Y < second.Y)
		{
			lIndex.From = first;
			lIndex.To = second;
		}
		else
		if(first.Y > second.Y)
		{
			lIndex.From = second;
			lIndex.To = first;
		}
		else
		{
			if( first.X < second.X)
			{
				lIndex.From = first;
				lIndex.To = second;
			}
			else
			if(first.X > second.X)
			{
				lIndex.From = second;
				lIndex.To = first;
			}
			else
			{
				`warn("X_COM_SusaninPF_EdgeCollection::GetIndex(): Given cells can't be the same");	
				return false;
			}
			
		}
		
	}
	aIndex = lIndex;
	return true;
}

public function bool GetEdge(vector from, vector to, out EdgeStructure result)
{
	local EdgeStructure lEdge;

	if(mInterface.DLLGetCellEdge(mMapId, from, to, lEdge))
	{
		result = lEdge;
		return true;
	}
	return false;
}

public function SetEdge(vector from, vector to, CellType type)
{
	local CellEdgeIndex lIndex;
	local EdgeStructure lEdge;
	local int li;
	local bool lEdgeExists;
	
	lEdgeExists = GetEdgeIndex(from, to, lIndex);
	if(!lEdgeExists)
	{
		`warn("X_COM_SusaninPF_EdgeCollection::SetEdge(): Given cells can't be the same");
		return;
	}

	for(li = 0; li<mEdgesToCommit.Length; li++)
	{
		if(lIndex.From.X == mEdgesToCommit[li].From.X 
			&&lIndex.From.Y == mEdgesToCommit[li].From.Y
			&&lIndex.From.Z == mEdgesToCommit[li].From.Z
			
			&&lIndex.To.X == mEdgesToCommit[li].To.X 
			&&lIndex.To.Y == mEdgesToCommit[li].To.Y
			&&lIndex.To.Z == mEdgesToCommit[li].To.Z)
		{
			mEdgesToCommit[li].Type = type;
			return;
		}
	}

	lEdge.From = lIndex.From;
	lEdge.To = lIndex.To;
	lEdge.Type = type;
	mEdgesToCommit.AddItem(lEdge);
}

public function AddEdge(EdgeStructure aEdge)
{
	SetEdge(aEdge.From, aEdge.To, CellType(aEdge.Type));
}

public function AddEdges(array<EdgeStructure> aEdges)
{
	local int i;

	for(i=0; i<aEdges.Length; i++)
	{
		AddEdge(aEdges[i]);
	}
}

public function bool CommitEdges()
{
	local EdgeStructureDynamicArrayStruct lStruct;

    lStruct.Data = mEdgesToCommit;
	if(mEdgesToCommit.Length > 0)
		return mInterface.DLLCommitCellEdges(mMapId, lStruct);

	return true;
}
/**
Resizes the existing map, selected by mapId. Atention! If some measure doesn't need to be changed - set it to 0.
 Returns false on failure.
 @param sizeX - new X size of the map
 @param sizeY - new Y size of the map
 @param sizeZ - new Z size of the map
 @param cellSize - new sizes of the cell.
 @return True on success
 */
//public function Resize(optional int ax = 0, optional int ay = 0, optional int az = 0, optional Vector aCellSize = vect(0, 0, 0))
//{
//	if(mInterface.DLLResizeMap(mMapId, ax, ay, az, aCellSize) == true)
//	{
//		if(ax > 0) X = ax;
//		if(ay > 0) Y = ay;
//		if(az > 0) Z = az;
//		if(aCellSize.X > 0) mCellSize.X = aCellSize.X;
//		if(aCellSize.Y > 0) mCellSize.Y = aCellSize.Y;
//		if(aCellSize.Z > 0) mCellSize.Z = aCellSize.Z;
//	}
//}

//function int IdFromCrd(int x, int y, int z)
//{
//	return (z*(SizeY*SizeX))+(y*SizeX)+x;
//}

//function int IdFromVector(Vector aV)
//{
//	return (aV.z*(SizeY*SizeX))+(aV.y*SizeX)+aV.x;
//}

////public function UpdateCells()
////{
////	local CellStructureDynamicArrayStruct lStruct;

////	mInterface.DLLCommitCells(mMapId, lStruct);
////	mCells = lStruct.Data;
////}

//public function CommitCells()
//{
//	local CellStructureDynamicArrayStruct lStruct;
//	local int li;

//    lStruct.Data = mCellsToCommit;

//	if(mInterface.DLLCommitCells(mMapId, lStruct))
//	{
//		for(li = 0; li < mCellsToCommit.Length; li++)
//		{
//			mCells[IdFromVector(mCellsToCommit[li].Point)] = mCellsToCommit[li];
//		}
//		mCellsToCommit.Length = 0;
//	}
//}

//public function UpdateCells()
//{
//	local CellStructureDynamicArrayStruct lStruct;

//    lStruct.Data = mCells;
//	mInterface.DLLUpdateCells(mMapId, lStruct);
//	mCells = lStruct.Data;
//	//return lStruct.Data;
//}

//public function array<Vector> FindPath(Vector lStart, Vector lEnd, MovementType lSender)
//{
//	//local VectorDynamicArrayStruct lStruct;
//	local array<Vector> arr;
//	local int lCount;

//	lCount = mInterface.DLLFindPath(mMapId, lStart, lEnd, int(lSender));
//	if(lCount > 0)
//	{
//		arr.Length = lCount;
//		lStruct.Data = arr;
//		mInterface.DLLFetchPath(lStruct);
//		return lStruct.Data;
//	}
//	else
//		return arr;
//}
////=============================================================================
//// Cells manipulation
////=============================================================================
//private function CellStructure GetCell(int x, int y, int z)	
//{
//	return mCells[IdFromCrd(x, y, z)];
//}

//public function SetCell(int x, int y, int z, CellType aType, Rotator aRot)
//{
//	local CellStructure lCell;
//	local int lindex;
//	local int li;
//	local float lp, ly, lr;
	
//	lCell = GetCell(x, y, z);

//	if(lCell.Type == float(aType) || aType == NA)
//	{
//		if(lCell.Type == float(CellType.Ladder))
//		{
//			if((lCell.Pitch == aRot.Pitch*UnrRotToDeg) && (lCell.Yaw == aRot.Yaw*UnrRotToDeg) && (lCell.Roll == aRot.Roll*UnrRotToDeg))
//			{
//				return;
//			}
//		}
//		else
//		{
//			return;
//		}
//	}
//	lCell.Pitch	= aRot.Pitch*UnrRotToDeg;
//	lCell.Yaw = aRot.Yaw*UnrRotToDeg;
//	lCell.Roll = aRot.Roll*UnrRotToDeg;
//	lCell.Type = float(aType);
	
//	lindex = -1;
//	for(li = 0; li < mCellsToCommit.Length; li++)
//	{
//		if(mCellsToCommit[li].Point.X == x && mCellsToCommit[li].Point.Y == y && mCellsToCommit[li].Point.Z == z)
//		{
//			lindex = li;
//			break;
//		}
//	}

//	if(lindex == -1)
//	{
//		mCellsToCommit.AddItem(lCell);
//	}
//	else
//	{
//		mCellsToCommit[lindex] = lCell;
//	}
//}

//public function SetCellType(int x, int y, int z, CellType aType)
//{
//	local Rotator lRot;
//	local CellStructure lCell;

//	lCell = GetCell(x, y, z);
//	lRot.Pitch = lCell.Pitch;
//	lRot.Yaw = lCell.Yaw;
//	lRot.Roll = lCell.Roll;

//	SetCell(x, y, z, aType, lRot);
//	//local CellStructure lCell;
//	//local int lindex;
//	//local int li;
//	//local float lp, ly, lr;
	
//	//lCell = GetCell(x, y, z);

//	//if(lCell.Type == float(aType) || aType == NA)
//	//{
//	//	return;
//	//}
//	//lCell.Type = float(aType);

//	//lindex = -1;
//	//for(li = 0; li < mCellsToCommit.Length; li++)
//	//{
//	//	if(mCellsToCommit[li].Point.X == x && mCellsToCommit[li].Point.Y == y && mCellsToCommit[li].Point.Z == z)
//	//	{
//	//		lindex = li;
//	//		break;
//	//	}
//	//}

//	//if(lindex == -1)
//	//{
//	//	mCellsToCommit.AddItem(lCell);
//	//}
//	//else
//	//{
//	//	mCellsToCommit[lindex] = lCell;
//	//}
//}

//public function SetCellRotation(int x, int y, int z, Rotator aRot)
//{
//	local CellStructure lCell;

//	lCell = GetCell(x, y, z);

//	SetCell(x, y, z, CellType(int(lCell.Type)), aRot);
//	//local CellStructure lCell;
//	//local int lindex;
//	//local int li;
//	//local float lp, ly, lr;
	
//	//lCell = GetCell(x, y, z);

//	//if(lCell.Type == float(CellType.Ladder))
//	//{
//	//	if((lCell.Pitch == aRot.Pitch*UnrRotToDeg) && (lCell.Yaw == aRot.Yaw*UnrRotToDeg) && (lCell.Roll == aRot.Roll*UnrRotToDeg))
//	//	{
//	//		return;
//	//	}
//	//}
//	//else
//	//{
//	//	return;
//	//}

//	//lCell.Pitch	= aRot.Pitch*UnrRotToDeg;
//	//lCell.Yaw = aRot.Yaw*UnrRotToDeg;
//	//lCell.Roll = aRot.Roll*UnrRotToDeg;
	
//	//lindex = -1;
//	//for(li = 0; li < mCellsToCommit.Length; li++)
//	//{
//	//	if(mCellsToCommit[li].Point.X == x && mCellsToCommit[li].Point.Y == y && mCellsToCommit[li].Point.Z == z)
//	//	{
//	//		lindex = li;
//	//		break;
//	//	}
//	//}

//	//if(lindex == -1)
//	//{
//	//	mCellsToCommit.AddItem(lCell);
//	//}
//	//else
//	//{
//	//	mCellsToCommit[lindex] = lCell;
//	//}
//}

////=============================================================================
//// Edges manipulation
////=============================================================================
//private function CellStructure GetEdge(int x, int y, int z)	
//{
//	return mEdges[IdFromCrd(x, y, z)];
//}

//public function SetCell(int x, int y, int z, CellType aType, Rotator aRot)
//{
//	local CellStructure lCell;
//	local int lindex;
//	local int li;
//	local float lp, ly, lr;
	
//	lCell = GetCell(x, y, z);

//	if(lCell.Type == float(aType) || aType == NA)
//	{
//		if(lCell.Type == float(CellType.Ladder))
//		{
//			if((lCell.Pitch == aRot.Pitch*UnrRotToDeg) && (lCell.Yaw == aRot.Yaw*UnrRotToDeg) && (lCell.Roll == aRot.Roll*UnrRotToDeg))
//			{
//				return;
//			}
//		}
//		else
//		{
//			return;
//		}
//	}
//	lCell.Pitch	= aRot.Pitch*UnrRotToDeg;
//	lCell.Yaw = aRot.Yaw*UnrRotToDeg;
//	lCell.Roll = aRot.Roll*UnrRotToDeg;
//	lCell.Type = float(aType);
	
//	lindex = -1;
//	for(li = 0; li < mCellsToCommit.Length; li++)
//	{
//		if(mCellsToCommit[li].Point.X == x && mCellsToCommit[li].Point.Y == y && mCellsToCommit[li].Point.Z == z)
//		{
//			lindex = li;
//			break;
//		}
//	}

//	if(lindex == -1)
//	{
//		mCellsToCommit.AddItem(lCell);
//	}
//	else
//	{
//		mCellsToCommit[lindex] = lCell;
//	}
//}

//public function SetCellType(int x, int y, int z, CellType aType)
//{
//	local Rotator lRot;
//	local CellStructure lCell;

//	lCell = GetCell(x, y, z);
//	lRot.Pitch = lCell.Pitch;
//	lRot.Yaw = lCell.Yaw;
//	lRot.Roll = lCell.Roll;

//	SetCell(x, y, z, aType, lRot);
//}

//public function SetCellRotation(int x, int y, int z, Rotator aRot)
//{
//	local CellStructure lCell;

//	lCell = GetCell(x, y, z);

//	SetCell(x, y, z, CellType(int(lCell.Type)), aRot);
//}
//=============================================================================
// Default properties
//=============================================================================
defaultproperties
{
    Name="Default__X_COM_SusaninPF_Grid"	
}