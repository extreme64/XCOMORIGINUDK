/**
 * Implement data do manage the nodes for the A* algorithm
 *
 */
class xcT_Test_PathFindingInterface extends Actor dependson(X_COM_Node);

var X_COM_PathFindingInterface mPathFindingInterface;
var X_COM_TacticalMap mMap;
//=============================================================================
// SetUp
//=============================================================================
/*function Context()
{
	local RoutesCustomization lCustom;

	if(mMap == none)
	{
		mMap = Spawn(class'X_COM_TacticalMap');
		mMap.SetMapCellClassName("X-COM_TACTICS.xcT_MapCell");
	}
	if(mPathFindingInterface == none)
		mPathFindingInterface = class'X_COM_PathFindingInterface'.static.Construct(mMap, none, none);
	
	mMap.CreateMap(5, 5, 2);
	// Первый уровень
	mMap.SetCell(0, 0, 0, ct_passable);
	mMap.SetCell(1, 0, 0, ct_passable);
	mMap.SetCell(2, 0, 0, ct_passable);
	mMap.SetCell(3, 0, 0, ct_passable);
	mMap.SetCell(4, 0, 0, ct_passable);

	mMap.SetCell(0, 1, 0, ct_passable);
	mMap.SetCell(1, 1, 0,   ct_obstacle);
	mMap.SetCell(2, 1, 0,   ct_obstacle);
	mMap.SetCell(3, 1, 0,   ct_obstacle);
	mMap.SetCell(4, 1, 0, ct_passable);

	mMap.SetCell(0, 2, 0, ct_passable);
	lCustom.direction = df_n;
	mMap.SetCell(1, 2, 0, ct_ladder).CustomRoutes.AddItem(lCustom);
	mMap.SetCell(2, 2, 0, ct_passable);
	mMap.SetCell(3, 2, 0, ct_passable);
	mMap.SetCell(4, 2, 0, ct_passable);

	mMap.SetCell(0, 3, 0, ct_passable);
	mMap.SetCell(1, 3, 0, ct_ladder).CustomRoutes.AddItem(lCustom);
	mMap.SetCell(2, 3, 0, ct_passable);
	mMap.SetCell(3, 3, 0, ct_passable);
	mMap.SetCell(4, 3, 0, ct_passable);

	mMap.SetCell(0, 4, 0, ct_passable);
	mMap.SetCell(1, 4, 0, ct_passable);
	mMap.SetCell(2, 4, 0, ct_passable);
	mMap.SetCell(3, 4, 0, ct_passable);
	mMap.SetCell(4, 4, 0, ct_passable);

	// Второй уровень
	mMap.SetCell(0, 0, 1, ct_none);
	mMap.SetCell(1, 0, 1, ct_none);
	mMap.SetCell(2, 0, 1, ct_none);
	mMap.SetCell(3, 0, 1, ct_none);
	mMap.SetCell(4, 0, 1, ct_none);

	mMap.SetCell(0, 1, 1, ct_none);
	mMap.SetCell(1, 1, 1, ct_passable);
	mMap.SetCell(2, 1, 1, ct_passable);
	mMap.SetCell(3, 1, 1, ct_passable);
	mMap.SetCell(4, 1, 1, ct_none);

	mMap.SetCell(0, 2, 1, ct_none);
	mMap.SetCell(1, 2, 1, ct_none);
	mMap.SetCell(2, 2, 1, ct_none);
	mMap.SetCell(3, 2, 1, ct_none);
	mMap.SetCell(4, 2, 1, ct_none);

	mMap.SetCell(0, 3, 1, ct_none);
	mMap.SetCell(1, 3, 1, ct_none);
	mMap.SetCell(2, 3, 1, ct_none);
	mMap.SetCell(3, 3, 1, ct_none);
	mMap.SetCell(4, 3, 1, ct_none);

	mMap.SetCell(0, 4, 1, ct_none);
	mMap.SetCell(1, 4, 1, ct_none);
	mMap.SetCell(2, 4, 1, ct_none);
	mMap.SetCell(3, 4, 1, ct_none);
	mMap.SetCell(4, 4, 1, ct_none);
}

//=============================================================================
// Tests
//=============================================================================
function bool IsChildNodesGottenCorrectly()
{
	local X_COM_MapCell lUnitPosition;
	local X_COM_OpenClosedNodeColection lCollection;
	//local X_COM_Direction lCompass;
	local X_COM_Node lNode;
	//local X_COM_Sender lSender;
	//local EListType lListType;

	Context();
	lUnitPosition = mMap.GetCell(2, 2, 0);
	lNode = class'X_COM_Node'.static.Construct(lUnitPosition.Id(), none, 10, 20, EP_Standing, lUnitPosition, lt_ClosedList);

//	lSender = new class'X_COM_Sender';
	lCollection = new class'X_COM_OpenClosedNodeColection';

	mPathFindingInterface.GetChildNodes(lNode, lCollection);

	lListType = lCollection.mNodeDictionary[mMap.GetCell(1, 1, 0).Id()].ListType;
	lNode = lCollection.mNodeDictionary[mMap.GetCell(2, 1, 0).Id()];

	mPathFindingInterface.GetChildNodes(lNode, lCollection);

	lListType = lCollection.mNodeDictionary[mMap.GetCell(1, 1, 0).Id()].ListType;
	return true;
}

function bool TestingPathFinding()
{
	local xcT_DummySender lSender;
	//local array<X_COM_Node> mWaypoints;

	lSender = new class'xcT_DummySender';

	lSender.mStart = vect(0, 0, 0);
	lSender.mEnd = vect(3, 1, 1);

	Context();
	//lUnitPosition = mMap.GetCell(2, 2, 0);


	//mPathFinder = mMap.GetPathFinder();
	mPathFindingInterface.SetSender(lSender);
//	mWaypoints =  mPathFindingInterface.FindPath();
	
	
	
	
	//lNode = class'X_COM_Node'.static.Construct(lUnitPosition.Id(), none, 10, 20, EP_Standing, lUnitPosition, lt_ClosedList);

	//lSender = new class'xcT_Dummy_Sender';
	//lCollection = new class'X_COM_OpenClosedNodeColection';

	//mPathFindingInterface.GetChildNodes(lNode, lCollection);

	//lListType = lCollection.mNodeDictionary[mMap.GetCell(1, 1, 0).Id()].ListType;
	//lNode = lCollection.mNodeDictionary[mMap.GetCell(2, 1, 0).Id()];

	//mPathFindingInterface.GetChildNodes(lNode, lCollection);

	//lListType = lCollection.mNodeDictionary[mMap.GetCell(1, 1, 0).Id()].ListType;
	return true;
}*/
//=============================================================================
// Default properties
//=============================================================================
defaultproperties
{
    Name="Default__xcT_Test_PathFindingInterface"
}