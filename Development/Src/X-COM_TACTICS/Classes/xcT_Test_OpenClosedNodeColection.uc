class xcT_Test_OpenClosedNodeColection extends object;

var X_COM_OpenClosedNodeColection mNodeColection;
//=============================================================================
// Constructors
//=============================================================================
/*
static function xcT_Test_PathFinding Construct()
{
	local xcT_Test_PathFinding lTest;
	lTest = new Spawn(class'xcT_Test_PathFinding');
	lTest.mMap = Spawn(class'X_COM_TacticalMap');
	lTest.mMap.SetMapCellClassName("X-COM_TACTICS.xcT_MapCell");	

	//lTest.mMap.CreateMap(lSize.X, lSize.Y, lSize.Z);
	return lTest;
}*/
//=============================================================================
// Functions
//=============================================================================

function Context()
{
	mNodeColection = new class'X_COM_OpenClosedNodeColection';
}

//=============================================================================
// Tests
//=============================================================================

function bool AddOpenListItem()
{
	local X_COM_Node lNode;
	Context();

	lNode =  class'X_COM_Node'.static.Construct(100, none, 1, 1, EP_Standing, none, lt_OpenList);
	mNodeColection.AddToList(lNode);

	return true;
}

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
//	MyDamageType=class'xcT_Test_OpenClosedNodeColection'
}
