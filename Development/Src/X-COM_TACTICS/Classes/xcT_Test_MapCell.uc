/**
 * ёнит тест поиска путей
 * ¬ этом классе буду писать тесты различных аспектов поиска путей.
 * 
 * ≈сли у кого есть желание писать свои собственные тесты - старайтесь это делать в едином стиле.
 * ѕока что € буду писать тесты по методике TDD. ¬озможно, в дальнейшем перейду на BDD
 */
class xcT_Test_MapCell extends Actor
	notplaceable;

var X_COM_TacticalMap mMap;
var X_COM_Direction mCompass;
//=============================================================================
// Constructors
//=============================================================================
event PreBeginPlay()
{
	mMap = Spawn(class'X_COM_TacticalMap');
	mMap.SetMapCellClassName("X-COM_TACTICS.xcT_MapCell");
}
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
/*
function Context()
{
	mMap.CreateMap(2, 2, 1);
	mMap.SetCell(0, 0, 0, ct_obstacle);
	mMap.SetCell(1, 0, 0, ct_passable);
	mMap.SetCell(1, 1, 0, ct_obstacle);
	mMap.SetCell(0, 1, 0, ct_passable);
	mCompass = new class'X_COM_Direction';
}

function Context2()
{
	mMap.CreateMap(2, 2, 1);
	mMap.SetCell(0, 0, 0, ct_passable);
	mMap.SetCell(1, 0, 0, ct_passable);
	mMap.SetCell(1, 1, 0, ct_passable); 
	mMap.SetCell(0, 1, 0, ct_passable); // старт
	mCompass = new class'X_COM_Direction';
}

function Context3()
{
	mMap.CreateMap(2, 2, 1);
	mMap.SetCell(0, 0, 0, ct_obstacle);
	mMap.SetCell(1, 0, 0, ct_passable);
	mMap.SetCell(1, 1, 0, ct_passable);
	mMap.SetCell(0, 1, 0, ct_passable);
	mCompass = new class'X_COM_Direction';
}

function Context4()
{
	mMap.CreateMap(3, 3, 1);
	mMap.SetCell(0, 0, 0, ct_passable);
	mMap.SetCell(1, 0, 0, ct_obstacle);
	mMap.SetCell(2, 0, 0, ct_passable);
	mMap.SetCell(0, 1, 0, ct_obstacle);
	mMap.SetCell(1, 1, 0, ct_passable);
	mMap.SetCell(2, 1, 0, ct_obstacle);
	mMap.SetCell(0, 2, 0, ct_passable);
	mMap.SetCell(1, 2, 0, ct_obstacle);
	mMap.SetCell(2, 2, 0, ct_passable);
	mCompass = new class'X_COM_Direction';
}

function Context5()
{
	mMap.CreateMap(3, 3, 1);
	mMap.SetCell(0, 0, 0, ct_passable);
	mMap.SetCell(1, 0, 0, ct_obstacle);
	mMap.SetCell(2, 0, 0, ct_passable);
	mMap.SetCell(0, 1, 0, ct_obstacle);
	mMap.SetCell(1, 1, 0, ct_passable);
	mMap.SetCell(2, 1, 0, ct_passable);
	mMap.SetCell(0, 2, 0, ct_passable);
	mMap.SetCell(1, 2, 0, ct_obstacle);
	mMap.SetCell(2, 2, 0, ct_passable);
	mCompass = new class'X_COM_Direction';
}

function Context6()
{
	mMap.CreateMap(3, 3, 1);
	mMap.SetCell(0, 0, 0, ct_passable);
	mMap.SetCell(1, 0, 0, ct_passable);
	mMap.SetCell(2, 0, 0, ct_passable);
	mMap.SetCell(0, 1, 0, ct_passable);
	mMap.SetCell(1, 1, 0, ct_passable);
	mMap.SetCell(2, 1, 0, ct_passable);
	mMap.SetCell(0, 2, 0, ct_passable);
	mMap.SetCell(1, 2, 0, ct_passable);
	mMap.SetCell(2, 2, 0, ct_passable);
	mCompass = new class'X_COM_Direction';
}*/
//=============================================================================
// Tests
//=============================================================================
/**
 * Ѕлокировано ли перемещение по диагонали углом соседней клетки?
 * 
 * ѕеремещение по диагонали должно быть блокировано, если
 * на соседней к стартовой и целевой клеткам находитс€ непроходима€ клетка
 * 
 *  _____
 * |_|X|*|
 * |_|o|_|
 * |_|_|_|
 * X - ѕреграда
 * о - ёнит
 * * - ѕункт назначени€
 * 
 * ¬ представленной выше ситуации юнит не должен идти наискосок. ќн должен обойти преп€тствие буквой √.
 */
/*
function bool IsDiagonalMovementBlockedByCorner()
{
	local X_COM_MapCell lUnitPosition;
	local EListType lType;
	//local X_COM_Direction lCompass;
	local Vector lDest;
	local X_COM_Sender lSender;

	Context();
	lUnitPosition = mMap.GetCell(1, 0, 0);
	lDest.X = 0;
	lDest.Y = 1;
	lDest.Z = 0;
	lSender = new class'X_COM_Sender';	
	mCompass.DirectionToCrd(lUnitPosition.Crd(), lDest);
	lUnitPosition.SelectMostOptimalMovement(lSender, mCompass.Get(), lType);
	if(lType == EP_none)
		return true;
	else
		return false;
}
// “естирую получение соседней клетки
function bool GettingCellNeighbor()
{
	local X_COM_MapCell lTarget, lNeighbor;
	Context();

	lTarget = mMap.GetCell(0, 1, 0);
	lNeighbor = lTarget.GetNeighbor(df_ne);
	if(lNeighbor != none)
		return true;
	else
		return false;
}

function bool CantPassDiagonalBecosOfCorner()
{
	local X_COM_MapCell lStart;
	local bool lPos;
	local X_COM_Direction lDir;

	lDir = class'X_COM_Direction'.static.Construct(df_ne);

	// “естирую, сможет ли юнит пройти по диагонали между двум€ непроходимыми блоками (не должен)
	Context();

	lStart = mMap.GetCell(0, 1, 0);

	lPos = lStart.CanGoThrough(lDir.Get());

	if(!lPos)
	{
		`log("Test failed. Can walk through impassable terrain");
		return false;
	}
	else
		`log("Cant walk through two corners");

	// “естирую, сможет ли юнит пройти по диагонали мимо непроходимого блока (не должен)
	Context3();

	lStart = mMap.GetCell(0, 1, 0);

	lPos = lStart.CanGoThrough(lDir.Get());

	if(!lPos)
	{
		`log("Test failed. Can walk through impassable terrain");
		return false;
	}
	else
		`log("Cant walk through two corners");
}

function bool CanPassDiagonal()
{
	local X_COM_MapCell lStart;
	local bool lPos;

	Context2();

	lStart = mMap.GetCell(0, 1, 0);

	lPos = lStart.CanGoThrough(df_ne);
	return lPos;
}
function bool CellIsNotPassable()
{
	local X_COM_MapCell lTarget;
	local bool lPasable;
	//local X_COM_Direction lCompass;
//	local Vector lDest;
//	local X_COM_Sender lSender;

	Context4();
	lTarget = mMap.GetCell(1, 1, 0);
	//lSender = new class'xcT_Dummy_Sender';
	//mCompass.DirectionToCrd(lUnitPosition.Crd(), lDest);
	//lType = EPosition(lUnitPosition.SelectMostOptimalMovement(lSender, lCompass.Get()));
	lPasable = lTarget.IsPasable();
	return lPasable;
}

function bool CellIsPassable()
{
	local X_COM_MapCell lTarget;
	local bool lPasable;
	//local X_COM_Direction lCompass;
//	local Vector lDest;
//	local X_COM_Sender lSender;

	Context5();
	lTarget = mMap.GetCell(1, 1, 0);
	//lSender = new class'xcT_Dummy_Sender';
	//mCompass.DirectionToCrd(lUnitPosition.Crd(), lDest);
	//lType = EPosition(lUnitPosition.SelectMostOptimalMovement(lSender, lCompass.Get()));
	lPasable = lTarget.IsPasable();
	return lPasable;
}

function bool SelectMostOptimalMovementReturnsFalse()
{
	local X_COM_MapCell lStartingCell;	
	local bool lPasable;
	//local X_COM_Direction lCompass;
	local Vector lDest;
	local X_COM_Sender lSender;
	local EListType lListType;

	Context5();
	lStartingCell = mMap.GetCell(0, 2, 0);
	//lSender = new class'xcT_Dummy_Sender';
	//mCompass.DirectionToCrd(lUnitPosition.Crd(), lDest);
	lStartingCell.SelectMostOptimalMovement(lSender, df_ne, lListType);

	//lPasable = lTarget.IsPasable();
	if(lListType == lt_ClosedList)
	return true;
}

function bool SelectMostOptimalMovementReturnsFalseOnDiagonal()
{
	local X_COM_MapCell lStartingCell;	
	local bool lPasable;
	//local X_COM_Direction lCompass;
	local Vector lDest;
	local X_COM_Sender lSender;
	local EListType lListType;

	Context5();
	lStartingCell = mMap.GetCell(2, 2, 0);
	//lSender = new class'xcT_Dummy_Sender';
	//mCompass.DirectionToCrd(lUnitPosition.Crd(), lDest);
	lStartingCell.SelectMostOptimalMovement(lSender, df_nw, lListType);

	//lPasable = lTarget.IsPasable();
	if(lListType  == lt_ClosedList)
	return true;
}

function bool SelectMostOptimalMovementReturnsTrue()
{
	local X_COM_MapCell lStartingCell;
	local EListType lListType;
	local X_COM_Sender lSender;
	Context5();

	lStartingCell = mMap.GetCell(2, 1, 0);
	lStartingCell.SelectMostOptimalMovement(lSender, df_w, lListType);

	//lPasable = lTarget.IsPasable();
	if(lListType != lt_ClosedList)
	return true;
}

function bool IsStraightMovementBeterThenDiagonal()
{
	local X_COM_MapCell lStartingCell;
	//local EListType lStreight, lDiagonal;
	local float lStreight, lDiagonal;
	local X_COM_Sender lSender;
	Context6();

	lStartingCell = mMap.GetCell(2, 1, 0);
	lStartingCell.SelectMostOptimalMovement(lSender, df_w, , , lStreight);
	lStartingCell.SelectMostOptimalMovement(lSender, df_nw, , , lDiagonal);

	//lPasable = lTarget.IsPasable();
	if(lStreight < lDiagonal)
		return true;
}

function bool IsStraightMovementBeterThenDiagonalThroughTwoCells()
{
	local X_COM_MapCell lStartingCell;
	//local EListType lStreight, lDiagonal;
	local float lPoints, lStreight, lDiagonal;
	local X_COM_Sender lSender;
	Context6();

	lStartingCell = mMap.GetCell(2, 1, 0);
	lStartingCell.SelectMostOptimalMovement(lSender, df_w, , , lPoints);
	lStreight += lPoints;
	lStartingCell = lStartingCell.GetNeighbor(df_w);
	lStartingCell.SelectMostOptimalMovement(lSender, df_w, , , lPoints);
	lStreight += lPoints;

	lStartingCell = mMap.GetCell(2, 1, 0);
	lStartingCell.SelectMostOptimalMovement(lSender, df_nw, , , lPoints);
	lDiagonal += lPoints;
	lStartingCell = lStartingCell.GetNeighbor(df_nw);
	lStartingCell.SelectMostOptimalMovement(lSender, df_sw, , , lPoints);
	lDiagonal += lPoints;

	//lPasable = lTarget.IsPasable();
	if(lStreight < lDiagonal)
		return true;
}*/
//=============================================================================
// Default Properties
//=============================================================================
defaultproperties
{
}
