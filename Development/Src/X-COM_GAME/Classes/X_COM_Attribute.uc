/**
 * X-Com attribute object.
 * Keep informations about a single attribute, can synchronise with database.
 */
class X_COM_Attribute extends XCOMDB_Object;


//=============================================================================
// Variables
//=============================================================================
var XCOMDB_Ref_Attribute mReference;
var int mValue;
var array<X_COM_Attribute> mAttributes;


DefaultProperties
{
	Name="Default__X_COM_Attribute"
}
