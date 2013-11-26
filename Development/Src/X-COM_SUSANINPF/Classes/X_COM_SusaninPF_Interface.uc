/**
 * X-COM Tactics functions and variables class. 
 * Uses to store functions and variables for tactics classes.
 */
class X_COM_SusaninPF_Interface extends Object dependson(X_COM_SusaninPF_Grid)
        DLLBind(SusaninPathFindingUDKInterface);

//=============================================================================
// Functions
//=============================================================================

final function X_COM_SusaninPF_Grid CreateGrid(int sizeX, int sizeY, int sizeZ, Vector cellSize)
{
    local X_COM_SusaninPF_Grid lGrid;
	local int lId;

	lId = DLLCreateGrid(sizeX, sizeY, sizeZ, cellSize);

	lGrid = class'X_COM_SusaninPF_Grid'.static.Constructor(lId, sizeX, sizeY, sizeZ, cellSize, self);

	lGrid.mCells.UpdateCells();

    return lGrid;
}

final function array<Vector> TestGetPath(/*array<Vector> arr*/int count)
{
    local VectorDynamicArrayStruct lStruct;
	local array<Vector> arr;

	arr.Add(count);
    lStruct.Data = arr;
    TestGetResult(lStruct);
	return lStruct.Data;
}

//=============================================================================
// Interface for Susanin Path Finding library
//=============================================================================
/** 
 Registers the Susanin Path Finding map and returns the id of the map. 
 @param sizeX -  X size of the map
 @param sizeY -  Y size of the map
 @param sizeZ -  Z size of the map
 @param cellSize - sizes of the cell.
 @return mapid. id >= 0 on success, negative value indicates error. Mapid is used in other functions
 */
dllimport final function int DLLCreateGrid(int sizeX, int sizeY, int sizeZ, Vector cellSize);

/** 
 Resizes the existing map, selected by mapId. Atention! If some measure doesn't need to be changed - set it to 0.
 Returns false on failure.
 @param mapId - the ID of the map
 @param sizeX - new X size of the map
 @param sizeY - new Y size of the map
 @param sizeZ - new Z size of the map
 @param cellSize - new sizes of the cell.
 @return True on success
 */
//dllimport final function bool DLLResizeMap(int mapId, int sizeX, int sizeY, int sizeZ, Vector cellSize);

////////////////////////////////////////////////////
// Cells collection related
////////////////////////////////////////////////////
/**
Commits cells array into the grid represented by mapId. Returns true on success.
 @param mapId - the ID of the map.
 @param cells - the array of the cells, which sould be commited.
 @return True on success
 */
dllimport final function bool DLLCommitCells(int mapId, CellStructureDynamicArrayStruct cells);

/**
Updates cells from the grid, represented by mapId, into an array. Returns true on success.
 @param mapId - the ID of the map.
 @param cells - the array which should be filled with cells.
 @return True on success
 */
dllimport final function bool DLLUpdateCells(int mapId, out CellStructureDynamicArrayStruct cells);

//////////////////////////////////////////////////
// Cell edges related
//////////////////////////////////////////////////

dllimport final function bool DLLGetCellEdge(int mapId, Vector lFrom, Vector lTo, out EdgeStructure result);

dllimport final function bool DLLCommitCellEdges(int mapId, EdgeStructureDynamicArrayStruct result);

//////////////////////////////////////////////////
// Path finding related
//////////////////////////////////////////////////

dllimport final function int DLLFindPath(int mapId, Vector lStart, Vector lEnd, int lSender);

dllimport final function DLLFetchPath(out VectorDynamicArrayStruct aStruct);
///**
// Gets color of the pixel which corresponds to current latitude and longitude of the map
// @param mapId - Id of map returned by one of Load...Map functions</param>
// @param latitude - Latitude of point
// @param longitude - Longinude of point
// @return Color as integer that is a composition of R, G, B bytes
// */ 
//dllimport final function int TestSendTwoArrays(SendedArray arr1, SendedArray arr2);

///**
// Registers the PlateCarreeMap Projection map and returns the id of the map. In case of failure returns -1
// @param fileName -  file name of the map
// @param longitude0 - longitude of the left border of the map 0 - default
// @return mapid. id >= 0 on success, negative value indicates error. Mapid is used in other functions
// */
dllimport final function int TestSendValue(int val);

dllimport final function int TestFindPath(Vector from, Vector to);

dllimport final function TestGetResult(out VectorDynamicArrayStruct aStruct);

//dllimport final function double TestSendTwoValues(double val1, double val2);

//=============================================================================
// Default properties
//=============================================================================
defaultproperties
{
    Name="Default__X_COM_SusaninPF_Interface"	
}