/**
 * Implement data do manage the nodes for the A* algorithm
 *
 */
class X_COM_Node extends object dependson(X_COM_MovementRules);

var public int mId;
// ��������� �� ������� - ������, � ������� ����� ������� �� ������ ������.
var public X_COM_Node mParent;

// �������� G � ����������� ���� �� ��������� ������� �� ���� ������
var public int mG_CurrentCost;

// �������� H - ��������� ���������� �� ����
var public int mH_HeuristicDistance;

// ����� ��������� ���� �� ������ ������ � ���������� �� ����
var public int mF_PathScore;

var public EPosition mMovementMode;

// ������ �� ��������������� ������
var public X_COM_MapCell mItem;

Enum EListType
{
	lt_OpenList,
	lt_ClosedList,
	lt_None,
	lt_NA
};

enum EPassability
{
	cp_passable,
	cp_partialy_passable,
	cp_impassable
};
// ������, � �������� ��������� ����. ��� ����� �������� ������.

var EListType ListType;
/**
	Create a new instance of a node
	@param aNodeGuid
		ID ����
	@param aParent
		������������ ����
	@param aMovementCost
		��������� ����������� �� ����� ����
	@param aHeuristic
		��������� ���������� �� ����
	@param aMovementType
		�������� ����������� ��� ������� ����� ������ ����������� � ��� ������
	@param aItem
		������ ��, ����������, ������
 */
static public function X_COM_Node Construct(int aNodeGuid, X_COM_Node aParent, int aMovementCost, int aHeuristic, EPosition aMovementType, X_COM_MapCell aItem, optional EListType aListType = lt_NA)
{
	local X_COM_Node lNode;
    local int lParentCurrentCost;

	lNode = new class'X_COM_Node';
	if(aParent == none)
		lParentCurrentCost = 0;
	else
		lParentCurrentCost = aParent.mG_CurrentCost;

    lNode.mId = aNodeGuid;
	lNode.mParent = aParent;
    lNode.mG_CurrentCost = lParentCurrentCost + aMovementCost;
    lNode.mH_HeuristicDistance = aHeuristic;
    lNode.mF_PathScore = lNode.mG_CurrentCost + aHeuristic;
	lNode.mMovementMode = aMovementType;
    lNode.mItem = aItem;
	if(aListType != lt_NA)
		lNode.ListType = aListType;
	return lNode;
}

//=============================================================================
// Properties
//=============================================================================
public function X_COM_MapCell Item()
{
	return mItem;
}
//=============================================================================
// Functions
//=============================================================================

public function int CompareTo(X_COM_Node aOther)
{

    local int FCompare;
    FCompare = mF_PathScore - aOther.mF_PathScore;
	/*return FCompare;*/
    if (FCompare == 0)
    {
        // Path scores equals: return the current scores comparison
        return mG_CurrentCost - aOther.mG_CurrentCost;
    }
    else
    {
        // Path scores not equals: return the path scores comparison
        return FCompare;
    }
}

public function bool Equals(X_COM_Node aOther)
{
    return mid == aOther.mId;
}
/*
public function DebugOutput()
{
	`log("Node "$Id()$", X: "$mItem.X$", Y: "$mItem.Y$", Z: "$mItem.Z);
	`log("G: "$mG_CurrentCost$", H: "$mH_HeuristicDistance$", F: "$mF_PathScore);
}*/
//=============================================================================
// Default properties
//=============================================================================
defaultproperties
{
    Name="Default__X_COM_Node"	
}