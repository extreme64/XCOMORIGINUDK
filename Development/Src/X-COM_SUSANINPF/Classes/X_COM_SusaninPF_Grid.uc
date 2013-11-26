/**
 * X-COM Tactics functions and variables class. 
 * Uses to store functions and variables for tactics classes.
 */
class X_COM_SusaninPF_Grid extends Object dependson(X_COM_SusaninPF_CellCollection, X_COM_SusaninPF_EdgeCollection);

//enum CellType
//{
//    Na,
//	Empty,
//    Passable,
//    Impassable,
//    Ladder
//};

//struct CellStructure
//{	
//    var float Type;
//	var float Pitch;
//	var float Yaw;
//	var float Roll;
//    var Vector Point;
//};

//struct EdgeStructure
//{	
//    var float Type;
//    var Vector From;
//	var Vector To;
//};

//struct CellStructureDynamicArrayStruct
//{
//    var array<CellStructure> Data;
//};

struct VectorDynamicArrayStruct
{
    var array<Vector> Data;
};
//=============================================================================
// Fields
//=============================================================================

var private X_COM_SusaninPF_Interface mInterface;

var protected int mMapId; // Represents ID of the SusaninPF map. Used for all operations on the map.

var protectedwrite int SizeX; // X size of the map. Can't be changed in normal way. Use "Resize" function insted.
var protectedwrite int SizeY; // Y size of the map. Can't be changed in normal way. Use "Resize" function insted.
var protectedwrite int SizeZ; // Z size of the map. Can't be changed in normal way. Use "Resize" function insted.

var protectedwrite Vector mCellSize; // Size of a cell. Can't be changed in normal way. Use "Resize" function insted. 

//var array<CellStructure> mCells; // Cells of the array

//var array<CellStructure> mCellsToCommit; // Cells of the array

var protectedwrite X_COM_SusaninPF_CellCollection mCells; // Cell collection

var protectedwrite X_COM_SusaninPF_EdgeCollection mEdges;
//var array<EdgeStructure> mEdges; // Cells of the array

//var array<EdgeStructure> mEdgesToCommit; // Cells of the array
//=============================================================================
// Constructors
//=============================================================================

public static function X_COM_SusaninPF_Grid Constructor(int aid, int ax, int ay, int az, Vector aCellSize, X_COM_SusaninPF_Interface aInterface)
{
	local X_COM_SusaninPF_Grid lGrid;

	lGrid = new class'X_COM_SusaninPF_Grid';
	lGrid.mMapId = aid;
	lGrid.mInterface = aInterface;
	lGrid.SizeX = ax;
	lGrid.SizeY = ay;
	lGrid.SizeZ = az;
	lGrid.mCellSize = aCellSize;
	//lGrid.mCells.SetSize(ax*ay*az);//lGrid.IdFromCrd(ax, ay, az);
	lGrid.mCells = class'X_COM_SusaninPF_CellCollection'.static.Constructor(aid, ax, ay, az, aCellSize, aInterface);
	lGrid.mEdges = class'X_COM_SusaninPF_EdgeCollection'.static.Constructor(aid, aInterface);

	return lGrid;
}

//=============================================================================
// Functions
//=============================================================================

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

//public function UpdateCells()
//{
//	local CellStructureDynamicArrayStruct lStruct;

//	mInterface.DLLCommitCells(mMapId, lStruct);
//	mCells = lStruct.Data;
//}




//function int IdFromCrd(int x, int y, int z)
//{
//	return (z*(SizeY*SizeX))+(y*SizeX)+x;
//}

//function int IdFromVector(Vector aV)
//{
//	return (aV.z*(SizeY*SizeX))+(aV.y*SizeX)+aV.x;
//}

//public function CommitCells()
//{
//	mCells.CommiteCells();
//}

//public function UpdateCells()
//{
//	mCells.UpdateCells();
//}

public function array<Vector> FindPath(Vector lStart, Vector lEnd, MovementType lSender)
{
	local VectorDynamicArrayStruct lStruct;
	local array<Vector> arr;
	local int lCount;

	lCount = mInterface.DLLFindPath(mMapId, lStart, lEnd, int(lSender));
	if(lCount > 0)
	{
		arr.Length = lCount;
		lStruct.Data = arr;
		mInterface.DLLFetchPath(lStruct);
		return lStruct.Data;
	}
	else
		return arr;
}
//=============================================================================
// Cells manipulation
//=============================================================================
//private function CellStructure GetCell(int x, int y, int z)	
//{
//	return mCells.GetCell;
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
// Edges manipulation
//=============================================================================
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