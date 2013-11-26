/**
  ќбъект Ђ летка картыї
ќписывает клетку на сетке карты
	Х	ѕор€дковый номер - точный индекс в массиве, нужен дл€ ссылок на него.
	Х	—писок собственных координат дл€ сканировани€ соседей - точные координаты, по которым клетка находитс€ на поле.
	Х	“ип клетки - используетс€ дл€ определени€ возможности перемещени€ по ней, а также еЄ цены.
*/
class xcT_MapCell extends X_COM_MapCell;

function UpdateDebugInfo()
{
	local X_COM_Tile lTile;
	local Vector lLocation;
	local RoutesCustomization lCustomization;
	local MaterialInstanceConstant lMaterial;
	local name lName;
	local LinearColor lColor;
	local LinearColor lParam;

	if(mMap.DEBUG_MAP == true)
	{
		if((mCellType != ct_passable && mCellType != ct_none) || (CustomRoutes.Length > 0)) // создание марекра, если тип клетки - прип€тствие  ct_obstacle
		{
			if(CustomRoutes.Length > 0)
			{
				`log("Testing diagonals");
			}
			if(DEBUG_TILE == none) // маркер создаЄтс€ только если ещЄ не создан
			{
				lLocation = mMap.GetLocationFromGridCrd(Crd());
				lLocation.Z -= 64;
				lTile = mMap.Spawn(class'xcT_Tile_Debug', , ,lLocation, rot(0,0,0), , true);
				DEBUG_TILE = lTile;
			}
			lMaterial = new(None) Class'MaterialInstanceConstant';
			lMaterial.SetParent(xcT_Tile_Debug(DEBUG_TILE).mMainMaterial);

			lColor.R = 255;
			lColor.G = 0;
			lColor.B = 0;
			lColor.A = 0;

			foreach CustomRoutes(lCustomization)
			{
				lName = name(xcT_Tile_Debug(DEBUG_TILE).mDebugParamName$int(lCustomization.direction));
				lMaterial.SetVectorParameterValue(lName, lParam);
				lParam = lColor;
				//MeshComponent(xcT_Tile_Debug(DEBUG_TILE).StaticMeshComponent).SetMaterial(0, 
				//xcT_Tile_Debug(DEBUG_TILE).bCustomMaterial.SetMaterial( Se mDebugParamName
			}

		}
		else if(DEBUG_TILE != none) // удаление маркера, если в нЄм нет необходимости.
												  // Ќапример, если клетка проходима.
		{
			DEBUG_TILE.Destroy();
		}
	}
	else
	{
		if(DEBUG_TILE != none) // если маркер уже создан, а режим дебага выключен - удалить его
		{
			DEBUG_TILE.Destroy();
		}
	}

	
}
//=============================================================================
// Default properties
//=============================================================================
defaultproperties
{

/*
	dir[df_nw_raise]    = (-1, 1, 1)
	dir[df_n_raise]     = (0, 1, 1)
	dir[df_ne_raise]    = (1, 1, 1)
	dir[df_w_raise]     = (-1, 0, 1)
	dir[df_raise]       = (0, 0, 1)
	dir[df_e_raise]     = (1, 0, 1)
	dir[df_sw_raise]    = (-1, -1, 1)	
	dir[df_s_raise]     = (0, -1, 1)
	dir[df_se_raise]    = (1, -1, 1)
	

	dir[df_w]           = (-1, 0, 0)
	dir[df_e]           = (1, 0, 0)
	dir[df_n]           = (0, 1, 0)
	dir[df_s]           = (0, -1, 0)
	dir[df_nw]          = (-1, 1, 0)
	dir[df_sw]          = (-1, -1, 0)
	dir[df_ne]          = (1, 1, 0)
	dir[df_se]          = (1, -1, 0)
	dir[df_self]        = (0, 0, 0)

	dir[df_w_lower]     = (-1, 0, -1)
	dir[df_e_lower]     = (1, 0, -1)
	dir[df_n_lower]     = (0, 1, -1)
	dir[df_s_lower]     = (0, -1, -1)
	dir[df_nw_lower]    = (-1, 1, -1)
	dir[df_sw_lower]    = (-1, -1, -1)
	dir[df_ne_lower]    = (1, 1, -1)
	dir[df_se_lower]    = (1, -1, -1)
	dir[df_lower]       = (0, 0, -1)
*/



/*
	dir[df_w_raise].x   = (-1, 0, 1)
	dir[df_w_raise].y   = 0;
	dir[df_w_raise].z   = 1;

	dir[df_e_raise].x   = 1;
	dir[df_e_raise].y   = 0;
	dir[df_e_raise].z   = 1;

	dir[df_n_raise].x   = 0;
	dir[df_n_raise].y   = 1;
	dir[df_n_raise].z   = 1;

	dir[df_s_raise].x   = 0;
	dir[df_s_raise].y   =-1;
	dir[df_s_raise].z   = 1;

	dir[df_nw_raise].x  =-1;
	dir[df_nw_raise].y  = 1;
	dir[df_nw_raise].z  = 1;

	dir[df_sw_raise].x  =-1;
	dir[df_sw_raise].y  =-1;
	dir[df_sw_raise].z  = 1;

	dir[df_ne_raise].x  = 1;
	dir[df_ne_raise].y  = 1;
	dir[df_ne_raise].z  = 1;

	dir[df_se_raise].x  = 1;
	dir[df_se_raise].y  =-1;
	dir[df_se_raise].z  = 1;

	dir[df_raise].x     = 0;
	dir[df_raise].y     = 0;
	dir[df_raise].z     = 1;



	dir[df_w].x         =-1;
	dir[df_w].y         = 0;
	dir[df_w].z         = 0;

	dir[df_e].x         = 1;
	dir[df_e].y         = 0;
	dir[df_e].z         = 0;

	dir[df_n].x         = 0;
	dir[df_n].y         = 1;
	dir[df_n].z         = 0;

	dir[df_s].x         = 0;
	dir[df_s].y         =-1;
	dir[df_s].z         = 0;

	dir[df_nw].x        =-1;
	dir[df_nw].y        = 1;
	dir[df_nw].z        = 0;

	dir[df_sw].x        =-1;
	dir[df_sw].y        =-1;
	dir[df_sw].z        = 0;

	dir[df_ne].x        = 1;
	dir[df_ne].y        = 1;
	dir[df_ne].z        = 0;

	dir[df_se].x        = 1;
	dir[df_se].y        =-1;
	dir[df_se].z        = 0;

	dir[df_self].x      = 0;
	dir[df_self].y      = 0;
	dir[df_self].z      = 0;

	

	dir[df_w_lower].x   =-1;
	dir[df_w_lower].y   = 0;
	dir[df_w_lower].z   =-1;

	dir[df_e_lower].x   = 1;
	dir[df_e_lower].y   = 0;
	dir[df_e_lower].z   =-1;

	dir[df_n_lower].x   = 0;
	dir[df_n_lower].y   = 1;
	dir[df_n_lower].z   =-1;

	dir[df_s_lower].x   = 0;
	dir[df_s_lower].y   =-1;
	dir[df_s_lower].z   =-1;

	dir[df_nw_lower].x  =-1;
	dir[df_nw_lower].y  = 1;
	dir[df_nw_lower].z  =-1;

	dir[df_sw_lower].x  =-1;
	dir[df_sw_lower].y  =-1;
	dir[df_sw_lower].z  =-1;

	dir[df_ne_lower].x  = 1;
	dir[df_ne_lower].y  = 1;
	dir[df_ne_lower].z  =-1;

	dir[df_se_lower].x  = 1;
	dir[df_se_lower].y  =-1;
	dir[df_se_lower].z  =-1;

	dir[df_lower].x     = 0;
	dir[df_lower].y     = 0;
	dir[df_lower].z     =-1;
*/
    Name="Default__xcT_MapCell"	
}