class XCOMDB_DLLAPI extends Object
	DLLBind(UDKProjectDLL);

enum ESQLDriver
{
	SQLDrv_None,
	SQLDrv_SQLite
};

/**
 * SQL FUNCTIONS
 */
dllimport final function SQL_initSQLDriver(int aSQLDriver);
dllimport final function int SQL_createDatabase();
dllimport final function SQL_closeDatabase(int aDbIdx);
dllimport final function bool SQL_selectDatabase(int aDbIdx);
dllimport final function bool SQL_loadDatabase(string aFilename);
dllimport final function bool SQL_saveDatabase(string aFilename);
dllimport final function bool SQL_queryDatabase(string aStatement);
dllimport final function SQL_prepareStatement(string aStatement);
dllimport final function bool SQL_bindValueInt(int aParamIndex, int aValue);
dllimport final function bool SQL_bindNamedValueInt(string aParamName, int aValue);
dllimport final function bool SQL_bindValueFloat(int aParamIndex, float aValue);
dllimport final function bool SQL_bindNamedValueFloat(string aParamName, float aValue);
dllimport final function bool SQL_bindValueString(int aParamIndex, string aValue);
dllimport final function bool SQL_bindNamedValueString(string aParamName, string aValue);
dllimport final function bool SQL_executeStatement();
dllimport final function bool SQL_nextResult();
dllimport final function int SQL_lastInsertID();
dllimport final function SQL_getIntVal(string aParamName, out int aValue);
dllimport final function SQL_getFloatVal(string aParamName, out float aValue);
dllimport final function SQL_getStringVal(string aParamName, out string aValue);

// DEPRECATED
dllimport final function SQL_getValueInt(int aColumnIdx, out int aValue);
dllimport final function SQL_getValueFloat(int aColumnIdx, out float aValue);
dllimport final function SQL_getValueString(int aColumnIdx, out string aValue);

/**
 * IO FUNCTIONS
 */
dllimport final function bool IO_directoryExists(string aDirectoryPath);
dllimport final function bool IO_createDirectory(string aDirectoryPath);
dllimport final function bool IO_deleteDirectory(string aDirectoryPath, int aRecursive);
dllimport final function bool IO_fileExists(string aFilePath);
dllimport final function bool IO_deleteFile(string aFilePath);

DefaultProperties
{
	Name="Default__XCOMDB_DLLAPI"
}
