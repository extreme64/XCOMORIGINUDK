/**
 * ���������, �������������� ������ ��� �����������, �������� �� ������� ��� ��������� �����, ��� ���.
 * ��� ������� ���� ����� ������ ������������ ������.
 * 
 */

class xcT_MovementType_Footman extends X_COM_MovementType;

var private X_COM_TacticalMap mMap;


function SetMap(X_COM_TacticalMap aMap)
{
	mMap = aMap;
}

/**
 * ����� �� ���� ��������� ��� � �������� ������?
 */
function bool CanMakeStep(X_COM_MapCell aCell, EDirection aDir)
{
	local X_COM_MapCell lCell1, lCell2, lCell3;
	local Vector lLong, lLat;
	local X_COM_Direction lDir;

	lDir = class'X_COM_Direction'.static.Construct(aDir);
	lCell1 = aCell.GetNeighbor(aDir); // �������� �������� ������

	if(lCell1 != none)
	{
		if(lCell1.CellType() != ct_obstacle && lCell1.CellType() != ct_none) // ���������, ��������� �� �������� ������
		{
			if(lDir.IsDiagonal())
			{
				lLat = lDir.GetNormalizedVector(); // �������� ����������� ������
				lLong = lDir.GetNormalizedVector();
				lLat.X = 0; // �������� ����������� �� ����������� � ���������
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
 * ����� �� ������ ���� ��������� ������ ����������� �����. � ����� - ���� ������� ������� false, ��� �� ������,
 * ��� ������ �����������. ��������, ���� ���� ����� ������������ �� ����� �������� ��������, ��� ������, ��� 
 * ������ ������ � ������� �� ����� ���� ����� ��� ��������, �� �������� ����������� ��� ������ �����.
 */
function bool CanOccupy(X_COM_MapCell aCell)
{
}

/**
 * ��������� ���� � �������� �������� ������
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
 * ������� ����������, ��������� �� ���� � ����� ����������, ��� ���������� ������ � ���, ����� ����� ���� �������,
 * ��� ����� �������.
 */
function bool IsNearTarget();