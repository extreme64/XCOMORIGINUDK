/**
 * Интерфейс, обеспечивающий методы для определения, проходим ли участок для заданного юнита, или нет.
 * Для каждого типа юнита методы определяются заново.
 * 
 */

class xcT_MovementType_Footman extends X_COM_MovementType;

var private X_COM_TacticalMap mMap;


function SetMap(X_COM_TacticalMap aMap)
{
	mMap = aMap;
}

/**
 * Может ли юнит совершить шаг в соседнюю клетку?
 */
function bool CanMakeStep(X_COM_MapCell aCell, EDirection aDir)
{
	local X_COM_MapCell lCell1, lCell2, lCell3;
	local Vector lLong, lLat;
	local X_COM_Direction lDir;

	lDir = class'X_COM_Direction'.static.Construct(aDir);
	lCell1 = aCell.GetNeighbor(aDir); // Получаем соседнюю клетку

	if(lCell1 != none)
	{
		if(lCell1.CellType() != ct_obstacle && lCell1.CellType() != ct_none) // проверяем, проходима ли соседняя клетка
		{
			if(lDir.IsDiagonal())
			{
				lLat = lDir.GetNormalizedVector(); // Получаем направление клетки
				lLong = lDir.GetNormalizedVector();
				lLat.X = 0; // Получаем направления по горизонтали и вертикали
				lLong.Y = 0;

				lCell2 = aCell.GetNeighbor(lDir.SetFromNormalizedVec(lLat).Get());
				if(lCell2 != none && lCell2.CellType() == ct_obstacle)
					return false;

				lCell3 = aCell.GetNeighbor(lDir.SetFromNormalizedVec(lLong).Get());
				if(lCell3 != none && lCell3.CellType() == ct_obstacle)
					return false;

				return true;
			}
			else
				return true;
		}
		else
		{
			return false;
		}
	}
	else
		return false;
}

/**
 * Может ли клетка быть финальной точкой перемещения юнита. К слову - если функция вернула false, это не значит,
 * что клетка непроходима. Например, если юнит умеет перемещаться по карте длинными прыжками, это значит, что 
 * пустые клетки в воздухе не могут быть целью его движения, но являются проходимыми при поиске путей.
 */
function bool CanOccupy(X_COM_MapCell aCell)
{
}

/**
 * Стоимость шага в заданную соседнюю клетку
 */
function int GetStepCost(X_COM_MapCell aCell, EDirection aDirection)
{
	//local Vector lCrd1, lCrd2;//, lWay;
	//local X_COM_Direction lDirection;
	//local EDirection ldir;
	//local X_COM_MapCell lTarget;

	//lDirection = class'X_COM_Direction'.static.Construct(aDirection);
	//if(aDirection != df_uninit && aDirection != df_self)
	//{
	//	lTarget = aCell.GetNeighbor(aDirection);
	//	if(lTarget != none)
	//	{
	//		if(!lTarget.IsPasable())
	//		{
	//			aListType = lt_ClosedList;
	//			return lTarget;
	//		}
	//		if(!CanGoThrough(aDirection))
	//		{
	//			aListType = lt_none;
	//			return lTarget;
	//		}
	//		points = 5;
	//		if(lDirection.IsDiagonal())
	//		{
	//			points *= 1.4;
	//		}
	//		aListType = lt_OpenList;
	//	}
	//	return lTarget;
	//}
}

/**
 * Функция определяет, находится ли юнит в точке назначения, или достаточно близко к ней, чтобы можно было считать,
 * что поиск окончен.
 */
function bool IsNearTarget();