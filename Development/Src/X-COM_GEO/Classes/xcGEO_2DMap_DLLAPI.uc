class xcGEO_2DMap_DLLAPI extends Object
	DLLBind(MapProjectionUdkBinding);

/** 
 Registers the Mercator Projection map and returns the id of the map. In case of failure returns -1 
 @param fileName -  file name of the map
 @param longitude0 - longitude of the left border of the map 0 - default
 @return mapid. id >= 0 on success, negative value indicates error. Mapid is used in other functions
 */
dllimport final function  int LoadMercatorMap(string fileName, float longitude0);

/**
 Gets color of the pixel which corresponds to current latitude and longitude of the map
 @param mapId - Id of map returned by one of Load...Map functions</param>
 @param latitude - Latitude of point
 @param longitude - Longinude of point
 @return Color as integer that is a composition of R, G, B bytes
 */ 
dllimport final function  int GetColorCode(int mapId, float latitude, float longitude);

/**
 Registers the PlateCarreeMap Projection map and returns the id of the map. In case of failure returns -1
 @param fileName -  file name of the map
 @param longitude0 - longitude of the left border of the map 0 - default
 @return mapid. id >= 0 on success, negative value indicates error. Mapid is used in other functions
 */
dllimport final function int LoadPlateCarreeMap(string fileName, float longitude0);

dllimport final function int SomeFunc(out int files[]);

DefaultProperties
{
	Name="Default__xcGEO_2DMap_DLLAPI"
}
