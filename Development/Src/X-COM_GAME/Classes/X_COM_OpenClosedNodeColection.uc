/**
 * List of opened and closed nodes
 *
 */
class X_COM_OpenClosedNodeColection extends Object;

var public array<X_COM_Node> mNodeDictionary;         // Список узлов
var private array<X_COM_Node> mOpenNodeDictionary;     // Указатели на узлы открытого списка
var public int mClosedCount;
//var private array<X_COM_Node> mClosedNodeDictionary;   // Указатели на узлы закрытого списка

//=============================================================================
// Constructors
//=============================================================================

//=============================================================================
// Functions
//=============================================================================

/// Получить ближайший узел
public function X_COM_Node NearestNode()
{
	local int lI;
	//local array<X_COM_Node> lNodeArray;
	local X_COM_Node lNearestNodeInArray;

	//lNodeArray.Length = mOpenNodeDictionary.Length;

    // Continue only if there are nodes in the dictionary
    if (mOpenNodeDictionary.Length > 0)
    {

    	/*lNearestNodeInArray = mOpenNodeDictionary[0];
		lLowest = lNearestNodeInArray.mG_CurrentCost + lNearestNodeInArray.mH_HeuristicDistance;
		For(lI = 0; lI<mOpenNodeDictionary.Length; lI++)
		{
			F = mOpenNodeDictionary[lI].mG_CurrentCost + mOpenNodeDictionary[lI].mH_HeuristicDistance;
			if(F < lLowest)
			{
				lLowest = F;
				lNearestNodeInArray = mOpenNodeDictionary[lI];
			}
		}*/
    	//mOpenNodeDictionary.Values.CopyTo(lNodeArray, 0);

        // Start the search from the first node
        lNearestNodeInArray = mOpenNodeDictionary[0];

        for (lI = 1; lI < mOpenNodeDictionary.Length; lI++)
        {
            // If there is a node lesser than the current nearest node, this must be the new nearest
//			lSelected = mOpenNodeDictionary[lI];
            if (lNearestNodeInArray.CompareTo(mOpenNodeDictionary[lI]) > 0)
            {

                lNearestNodeInArray = mOpenNodeDictionary[lI];
            }
        }
    }

    return lNearestNodeInArray;
}

public function AddOpen(X_COM_Node aNode)
{
	/*if(mNodeDictionary[aNode.Id()] == none)
		mNodeDictionary[aNode.Id()] = aNode;
	aNode.ListType = lt_OpenList;
	mOpenNodeDictionary.AddItem(aNode);*/

	// OLD VERSION

	local X_COM_Node lOpenNode;
	local int lNodeId;

	if(mNodeDictionary.Find(aNode) != -1)
	{
		//`log("Opening Node "$aNode.Id()$"...");	
		// Пропускаем закрытые узлы
		if (aNode.ListType != lt_ClosedList)
		{
			// Проверяем, не является текущий путь лучше предыдущего?
			if (aNode.ListType == lt_OpenList)
			{
				lOpenNode = mOpenNodeDictionary[lNodeId];
				if (lOpenNode.mG_CurrentCost >= aNode.mG_CurrentCost)
				{
					// Заменяем путь на более оптимальный
					mNodeDictionary[aNode.mId] = aNode;
				}
			}
			else
			{
				// Узел не существует, создать новый
				aNode.ListType = lt_OpenList;
				mNodeDictionary[aNode.mId] = aNode;
				mOpenNodeDictionary.AddItem(aNode);
				//aNode.DebugOutput();
				//`log("Opened!");
			}
		}
	}
	else
	{
		aNode.ListType = lt_OpenList;
		mNodeDictionary[aNode.mId] = aNode;
		mOpenNodeDictionary.AddItem(aNode);
		//aNode.DebugOutput();
		//`log("Opened!");
	}

}

public function AddToList(X_COM_Node aNode)
{
	/*if(mNodeDictionary[aNode.Id()] == none)
		mNodeDictionary[aNode.Id()] = aNode;
	aNode.ListType = lt_OpenList;
	mOpenNodeDictionary.AddItem(aNode);*/

	// OLD VERSION

		if(aNode.ListType == lt_none)
		{
			mNodeDictionary[aNode.mId] = aNode;
		}
		else if(aNode.ListType == lt_OpenList)
		{
			AddOpen(aNode);
		}
		else if(aNode.ListType == lt_ClosedList)
		{
			AddClosed(aNode);
		}
	

}
/// <summary>
/// Add a node to the closed list (nodes that must not be considered)
/// </summary>
/// <param name="node">Node to add to the close list</param>
public function AddClosed(X_COM_Node aNode)
{
	/*if(aNode == none)
	{
		aNode = new class'X_COM_ListElem';
		aNode.Init(self);
	}*/
	/*aNode.ListType = lt_ClosedList;
	if(mOpenNodeDictionary.Find(aNode) != -1)
		mOpenNodeDictionary.RemoveItem(aNode);
	mClosedNodeDictionary.AddItem(aNode);
*/
	// OLD VERSION

    // Add the node to the close dictionary and remove it, if exist,
    // from the open dictionary
	//`log("Closing Node "$aNode.Id()$"...");
	if (mNodeDictionary.Find(aNode) == -1)
	{
		mNodeDictionary[aNode.mId] = aNode;
		//`log("Node does not mapped. Adding...");
	}
    if (aNode.ListType != lt_ClosedList)
    {
		aNode.ListType = lt_ClosedList;
        //mClosedNodeDictionary.AddItem(aNode);
		mClosedCount++;
        mOpenNodeDictionary.RemoveItem(aNode);
		//`log("Node is closed");
    }
}
//=============================================================================
// Default properties
//=============================================================================
defaultproperties
{
    Name="Default__xcT_Defines"	
}