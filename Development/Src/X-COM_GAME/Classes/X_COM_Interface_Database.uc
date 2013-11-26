/**
 * X-Com database interface providing global functions to sync with database.
 */
interface X_COM_Interface_Database;

//=============================================================================
// Database handling
//=============================================================================
/**
 * Sync with database => Write values to database
 */
function sync();

/**
 * Sync with database => Read value from database
 */
function update();