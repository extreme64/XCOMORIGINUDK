/**
 * X-COM Tactics functions and variables class. 
 * Uses to store functions and variables for tactics classes.
 */
class X_COM_SusaninPF_CellCollection extends Object;

enum CellType
{
    Na,
	Empty,
    Passable,
    Impassable,
    Ladder
};

enum Direction
{
    NA,
	North,
    NorthEast,
    East,
    SouthEast,
    South,
    SouthWest,
    West,
    NorthWest,

    NorthLower,
    NorthEastLower,
    EastLower,
    SouthEastLower,
    SouthLower,
    SouthWestLower,
    WestLower,
    NorthWestLower,
    Lower,

    NorthRaise,
    NorthEastRaise,
    EastRaise,
    SouthEastRaise,
    SouthRaise,
    SouthWestRaise,
    WestRaise,
    NorthWestRaise,
    Raise

    
};

enum MovementType
{
    Na,
	Walking,
};

struct CellStructure
{	
    var float Type;
	var float Pitch;
	var float Yaw;
	var float Roll;
    var Vector Point;
};

struct CellStructureDynamicArrayStruct
{
    var array<CellStructure> Data;
};

//=============================================================================
// Fields
//=============================================================================

var protected int mMapId; // Represents ID of the SusaninPF map. Used for all operations on the map.

var private X_COM_SusaninPF_Interface mInterface;

var protectedwrite int SizeX; // X size of the map. Can't be changed in normal way. Use "Resize" function insted.
var protectedwrite int SizeY; // Y size of the map. Can't be changed in normal way. Use "Resize" function insted.
var protectedwrite int SizeZ; // Z size of the map. Can't be changed in normal way. Use "Resize" function insted.

var protectedwrite Vector mCellSize; // Size of a cell. Can't be changed in normal way. Use "Resize" function insted. 

var array<CellStructure> mCells; // Cells of the array

var array<CellStructure> mCellsToCommit; // Cells of the array
//=============================================================================
// Constructors
//=============================================================================

public static function X_COM_SusaninPF_CellCollection Constructor(int aid, int ax, int ay, int az, Vector aCellSize, X_COM_SusaninPF_Interface aInterface)
{
	local X_COM_SusaninPF_CellCollection lCollection;

	lCollection = new class'X_COM_SusaninPF_CellCollection';
	lCollection.mMapId = aid;
	lCollection.SizeX = ax;
	lCollection.SizeY = ay;
	lCollection.SizeZ = az;
	lCollection.mCellSize = aCellSize;
	lCollection.mCells.Length = ax*ay*az; //lGrid.IdFromCrd(ax, ay, az);
	lCollection.mInterface = aInterface;

	return lCollection;
}

//=============================================================================
// Functions
//=============================================================================

function int IdFromCrd(int x, int y, int z)
{
	return (z*(SizeY*SizeX))+(y*SizeX)+x;
}

function int IdFromVector(Vector aV)
{
	return (aV.z*(SizeY*SizeX))+(aV.y*SizeX)+aV.x;
}

//public function UpdateCells()
//{
//	local CellStructureDynamicArrayStruct lStruct;

//	mInterface.DLLCommitCells(mMapId, lStruct);
//	mCells = lStruct.Data;
//}

public function CommitCells()
{
	local CellStructureDynamicArrayStruct lStruct;
	local int li;

    lStruct.Data = mCellsToCommit;

	if(mInterface.DLLCommitCells(mMapId, lStruct))
	{
		for(li = 0; li < mCellsToCommit.Length; li++)
		{
			mCells[IdFromVector(mCellsToCommit[li].Point)] = mCellsToCommit[li];
		}
		mCellsToCommit.Length = 0;
	}
}

public function UpdateCells()
{
	local CellStructureDynamicArrayStruct lStruct;

    lStruct.Data = mCells;
	mInterface.DLLUpdateCells(mMapId, lStruct);
	mCells = lStruct.Data;
}

//=============================================================================
// Cells manipulation
//=============================================================================
public function CellStructure GetCell(int x, int y, int z)	
{
	return mCells[IdFromCrd(x, y, z)];
}

public function SetCell(int x, int y, int z, CellType aType, Rotator aRot)
{
	local CellStructure lCell;
	local int lindex;
	local int li;
	
	lCell = GetCell(x, y, z);

	if(lCell.Type == float(aType) || aType == NA)
	{
		if(lCell.Type == float(CellType.Ladder))
		{
			if((lCell.Pitch == aRot.Pitch*UnrRotToDeg) && (lCell.Yaw == aRot.Yaw*UnrRotToDeg) && (lCell.Roll == aRot.Roll*UnrRotToDeg))
			{
				return;
			}
		}
		else
		{
			return;
		}
	}
	lCell.Pitch	= aRot.Pitch*UnrRotToDeg;
	lCell.Yaw = aRot.Yaw*UnrRotToDeg;
	lCell.Roll = aRot.Roll*UnrRotToDeg;
	lCell.Type = float(aType);
	
	lindex = -1;
	for(li = 0; li < mCellsToCommit.Length; li++)
	{
		if(mCellsToCommit[li].Point.X == x && mCellsToCommit[li].Point.Y == y && mCellsToCommit[li].Point.Z == z)
		{
			lindex = li;
			break;
		}
	}

	if(lindex == -1)
	{
		mCellsToCommit.AddItem(lCell);
	}
	else
	{
		mCellsToCommit[lindex] = lCell;
	}
}

public function SetCellType(int x, int y, int z, CellType aType)
{
	local Rotator lRot;
	local CellStructure lCell;

	lCell = GetCell(x, y, z);
	lRot.Pitch = lCell.Pitch;
	lRot.Yaw = lCell.Yaw;
	lRot.Roll = lCell.Roll;

	SetCell(x, y, z, aType, lRot);
}

public function SetCellRotation(int x, int y, int z, Rotator aRot)
{
	local CellStructure lCell;

	lCell = GetCell(x, y, z);

	SetCell(x, y, z, CellType(int(lCell.Type)), aRot);
}

//=============================================================================
// Default properties
//=============================================================================
defaultproperties
{
    Name="Default__X_COM_SusaninPF_Grid"	
}