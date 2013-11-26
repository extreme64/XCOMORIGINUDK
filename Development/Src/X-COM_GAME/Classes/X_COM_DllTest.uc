/**
 * X-COM Tactics functions and variables class. 
 * Uses to store functions and variables for tactics classes.
 */
class X_COM_DllTest extends Object
        DLLBind(TestDLLBind);

//struct CellStructure
//{	
//    var int Type;
//    var Vector Point;
//	var int Direction;
//};



//struct VectorDynamicArrayStruct
//{
//    var array<Vector> Data;
//};

final function int TestSendCellsArray(array<CellStructure> arr)
{
    local CellStructureDynamicArrayStruct lStruct;
    lStruct.Data = arr;
    return TestSendArray(lStruct);
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

/** 
 Registers the Mercator Projection map and returns the id of the map. In case of failure returns -1 
 @param fileName -  file name of the map
 @param longitude0 - longitude of the left border of the map 0 - default
 @return mapid. id >= 0 on success, negative value indicates error. Mapid is used in other functions
 */
dllimport final function int TestSendArray(CellStructureDynamicArrayStruct aStruct);

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
    Name="Default__X_COM_DllTest"	
}