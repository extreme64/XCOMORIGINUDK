/**
 * Класс, отвечающий за работу с направлениями и получение направлений по координатам 
 *
 */
class X_COM_Direction extends Object;

const DIRECTIONS_PURE = 26;
const DIRECTIONS_FULL = 27;

var protected Vector dir[DIRECTIONS_FULL];
//var private X_COM_Direction mInstance;

enum ELatitude // По широте
{
	lt_W,
	lt_none,
	lt_E,
	NA,
};
enum ELongitude // По долготе
{

	ln_N,
	ln_none,
	ln_S,
	NA
};
enum EElevation // По высоте
{
	el_raise,
	el_none,
	el_lower,
	NA
};

enum EDirection 
{
	df_nw_raise,   df_n_raise,  df_ne_raise,
	df_w_raise,    df_raise,    df_e_raise,
	df_sw_raise,   df_s_raise,  df_se_raise,

	df_nw,         df_n,        df_ne,
	df_w,          df_self,     df_e,
	df_sw,         df_s,        df_se,

	df_nw_lower,   df_n_lower,  df_ne_lower,
	df_w_lower,    df_lower,    df_e_lower,
	df_sw_lower,   df_s_lower,  df_se_lower,

	df_uninit  // направление не присвоено
};

var private EDirection mValue;
var bool iteration_option_straight_dirs;
var bool iteration_option_diagonal_dirs;
var bool iteration_option_exclude_self;

var protected array<Edirection> straight_dirs;
var protected array<EDirection> diagonal_dirs;

struct Row
{
	var array<EDirection> Vertical;
};

var protected array<Row> Horizontal;
//=============================================================================
// Constructors
//=============================================================================
static function X_COM_Direction Construct(EDirection adir)
{
	local X_COM_Direction linstance;
//	local int i, j;

	linstance = new class'X_COM_Direction';
	linstance.Set(adir);
	return linstance;
}

static final postoperator X_COM_Direction++( out X_COM_Direction A )
{
	return A.Set(EDirection(A.Get()+1));
}
//=============================================================================
// Functions
//=============================================================================
function X_COM_Direction SetFromAxes(ELatitude aLatitude, ELongitude aLongitude, EElevation aElevation)
{
	mValue = eDirection(aElevation*9+aLongitude*3+aLatitude);

	return self;
}

function X_COM_Direction SetFromAxesVec(Vector adir)
{

	mValue = eDirection(adir.Z*9+adir.Y*3+adir.X);
	return self;
}

function X_COM_Direction SetFromRotator(Rotator arot)
{
	local Vector vec;
	local int lAngle;

	lAngle = 65536 / 8;
	
	vec.X = arot.Yaw/lAngle;
	vec.Y = arot.Pitch/lAngle;
	
	//vec.Z = arot.Yaw/lAngle;
	//mValue = SetFromAxesVec(vec);
	mValue = Horizontal[vec.X].Vertical[vec.Y];
	return self;
}

function X_COM_Direction SetFromNormalizedVec(Vector adir)
{
	adir.X += 1;
	adir.Y += 1;
	adir.Z += 1;

	mValue = eDirection(adir.Z*9+adir.Y*3+adir.X);
	return self;
}

function int getLatFromDir(Edirection adir)
{
	return adir / 9;
}

function int getLongFromDir(Edirection adir)
{
	return adir % 9 / 3;
}

function int getElevFromDir(Edirection adir)
{
	return adir % 9 % 3;
}

/*function array<EDirection> SetStraightDirs()
{
	return straight_dirs;
}*/
function X_COM_Direction DirectionToCrd(vector aFrom, vector aTo)
{
	local Vector lWay;

	//lFrom = aFrom.GridCrd();
	//lDest = aTo.GridCrd();
	lWay = aTo - aFrom;
	lWay.X += 1;
	lWay.Y += 1;
	lWay.Z += 1;
	SetFromAxesVec(lWay);
	//mValue = getDirFromVec(lWay);
	return self;
}

function bool IsDiagonal()
{
	if(mValue == df_self)
		return false;

	if(mValue == df_w || mValue == df_n || mValue == df_e || mValue == df_s || mValue == df_raise || mValue == df_lower)
		return false;
	else 
		return true;
}

function X_COM_Direction Set(EDirection aDir)
{
	mValue = aDir;
	return self;
}

function EDirection Get()
{
	return mValue;
}

function int X()
{
	if(mValue != df_uninit)
		return dir[mValue].X;
}

function int Y()
{
	if(mValue != df_uninit)
		return dir[mValue].Y;
}

function int Z()
{
	if(mValue != df_uninit)
		return dir[mValue].Z;
}

function X_COM_Direction DirectionsIterationStart(optional EDirection aStartingValue = df_nw_raise)
{
	mValue = aStartingValue;

	do
	{
		if(mValue == df_self)
		{
			if(!iteration_option_exclude_self)
				break;
		}
		else 
		{
			if(IsDiagonal())
			{
				if(iteration_option_diagonal_dirs)
					break;
			}
			else
			{
				if(iteration_option_straight_dirs)
					break;
			}
		}
		mValue = EDirection(int(mValue)+1);
	}
	until(mValue == df_uninit);
	return self;
}

function X_COM_Direction Iterate()
{
	while(mValue != df_uninit)
	{
		mValue = EDirection(int(mValue)+1);
		if(mValue == df_self)
		{
			if(!iteration_option_exclude_self)
				break;
		}
		else 
		{
			if(IsDiagonal())
			{
				if(iteration_option_diagonal_dirs)
					break;
			}
			else
			{
				if(iteration_option_straight_dirs)
					break;
			}
		}

	}
	return self;

	/*dir = EDirection(A.Get()+1);
	if(iteration_option_exclude_self)
		if(dir == df_self)
			dir = EDirection(dir+1);
	return A.Set(EDirection(dir));

	mValue = EDirection(int(mValue)+1);
	return self;*/
}

function X_COM_Direction Reverse()
{
	local Vector lVec;

	lVec = GetNormalizedVector();
	lVec*=-1;
	SetFromNormalizedVec(lVec);

	return self;
}

function vector GetNeighbor(Vector aCrd, EDirection aDir)
{
	local Vector result;
	result = aCrd;
	result.X += dir[aDir].X;
	result.Y += dir[aDir].Y;
	result.Z += dir[aDir].Z;

	return result;
}

function vector GetNormalizedVector()
{
	if(mValue == df_uninit)
		mValue = df_nw_raise;
	return dir[mValue];
}
/*
static function bool IsDiagonal(optional Edirection aDir)
{
	local int lLat, lLong, lElev;

	lLat    = getLatFromDir(aDir);
	lLong   = getLongFromDir(aDir);
	lElev   = getElevFromDir(aDir);

	if(lLat!=1 || lLong!=1 || lElev!=1)
	if(aDir == df_nw_raise || aDir == df_n_raise || )
	{

	}
}*/
//=============================================================================
// Default properties
//=============================================================================
defaultproperties
{
	mValue             = df_uninit;
	iteration_option_straight_dirs = true;
	iteration_option_diagonal_dirs = true;
	iteration_option_exclude_self = true;
// Directions
	dir[df_nw_raise]    = (x=-1, y=-1, z=1)
	dir[df_n_raise]     = (x=0, y=-1, z=1)
	dir[df_ne_raise]    = (x=1, y=-1, z=1)
	dir[df_w_raise]     = (x=-1, y=0, z=1)
	dir[df_raise]       = (x=0, y=0, z=1)
	dir[df_e_raise]     = (x=1, y=0, z=1)
	dir[df_sw_raise]    = (x=-1, y=1, z=1)	
	dir[df_s_raise]     = (x=0, y=1, z=1)
	dir[df_se_raise]    = (x=1, y=1, z=1)
	

	dir[df_w]           = (x=-1, y=0, z=0)
	dir[df_e]           = (x=1, y=0, z=0)
	dir[df_n]           = (x=0, y=-1, z=0)
	dir[df_s]           = (x=0, y=1, z=0)
	dir[df_nw]          = (x=-1, y=-1, z=0)
	dir[df_sw]          = (x=-1, y=1, z=0)
	dir[df_ne]          = (x=1, y=-1, z=0)
	dir[df_se]          = (x=1, y=1, z=0)
	dir[df_self]        = (x=0, y=0, z=0)

	dir[df_w_lower]     = (x=-1, y=0, z=-1)
	dir[df_e_lower]     = (x=1, y=0, z=-1)
	dir[df_n_lower]     = (x=0, y=-1, z=-1)
	dir[df_s_lower]     = (x=0, y=1, z=-1)
	dir[df_nw_lower]    = (x=-1, y=-1, z=-1)
	dir[df_sw_lower]    = (x=-1, y=1, z=-1)
	dir[df_ne_lower]    = (x=1, y=-1, z=-1)
	dir[df_se_lower]    = (x=1, y=1, z=-1)
	dir[df_lower]       = (x=0, y=0, z=-1)

// Straight directions

	straight_dirs[0] = df_n
	straight_dirs[1] = df_e
	straight_dirs[2] = df_s
	straight_dirs[3] = df_w
	straight_dirs[4] = df_raise
	straight_dirs[5] = df_lower

// Diagonal directions

	diagonal_dirs[0] = df_nw_raise
	diagonal_dirs[1] = df_n_raise
	diagonal_dirs[2] = df_ne_raise
	diagonal_dirs[3] = df_w_raise
	diagonal_dirs[4] = df_e_raise
	diagonal_dirs[5] = df_sw_raise	
	diagonal_dirs[6] = df_s_raise
	diagonal_dirs[7] = df_se_raise

	diagonal_dirs[8] = df_nw
	diagonal_dirs[9] = df_sw
	diagonal_dirs[10] = df_ne
	diagonal_dirs[11] = df_se

	diagonal_dirs[12] = df_w_lower
	diagonal_dirs[13] = df_e_lower
	diagonal_dirs[14] = df_n_lower
	diagonal_dirs[15] = df_s_lower
	diagonal_dirs[16] = df_nw_lower
	diagonal_dirs[17] = df_sw_lower
	diagonal_dirs[18] = df_ne_lower
	diagonal_dirs[19] = df_se_lower


	Horizontal[0] ={(
		Vertical = (df_w, df_w_raise, df_raise, df_e_raise, df_e, df_e_lower, df_lower, df_w_lower)
		
		//Vertical[1] = df_n_raise,
		//Vertical[2] = df_raise,
		//Vertical[3] = df_s_raise,
		//Vertical[4] = df_s,
		//Vertical[5] = df_s_lower,
		//Vertical[6] = df_lower,
		//Vertical[7] = df_n_lower
	)}

	Horizontal[1] = {(
		Vertical = (df_nw, df_nw_raise, df_raise, df_se_raise, df_se, df_se_lower, df_lower, df_nw_lower)
	)}

	Horizontal[2] = {(
		Vertical = (df_n, df_n_raise, df_raise, df_s_raise, df_s, df_s_lower, df_lower, df_n_lower)
	)}

	Horizontal[3] = {(
		Vertical = (df_ne, df_ne_raise, df_raise, df_sw_raise, df_sw, df_sw_lower, df_lower, df_ne_lower)

		
	)}

	Horizontal[4] = {(
		Vertical = (df_e, df_e_raise, df_raise, df_w_raise, df_w, df_w_lower, df_lower, df_e_lower)

	)}

	Horizontal[5] = {(
		Vertical = (df_se, df_se_raise, df_raise, df_sw_raise, df_sw, df_sw_lower, df_lower, df_se_lower)

	)}

	Horizontal[6] = {(
		Vertical = (df_s, df_s_raise, df_raise, df_n_raise, df_n, df_n_lower, df_lower, df_s_lower)
	)}

	Horizontal[7] = {(
		Vertical = (df_sw, df_sw_raise, df_raise, df_se_raise, df_se, df_se_lower, df_lower, df_sw_lower)

	)}

	//Horizontal[1] = 
	//(
	//	Column[0] = df_ne,
	//	Column[1] = df_ne_raise,
	//	Column[2] = df_raise,
	//	Column[3] = df_sw_raise,
	//	Column[4] = df_sw,
	//	Column[5] = df_sw_lower,
	//	Column[6] = df_lower,
	//	Column[7] = df_ne_lower
	//)

	//rotation_dirs[2] = 
	//(
	//	Column[0] = df_e,
	//	Column[1] = df_e_raise,
	//	Column[2] = df_raise,
	//	Column[3] = df_w_raise,
	//	Column[4] = df_w,
	//	Column[5] = df_w_lower,
	//	Column[6] = df_lower,
	//	Column[7] = df_e_lower
	//)

	//rotation_dirs[3] = 
	//(
	//	Column[0] = df_se,
	//	Column[1] = df_se_raise,
	//	Column[2] = df_raise,
	//	Column[3] = df_sw_raise,
	//	Column[4] = df_sw,
	//	Column[5] = df_sw_lower,
	//	Column[6] = df_lower,
	//	Column[7] = df_se_lower
	//)

	//rotation_dirs[4] = 
	//(
	//	Column[0] = df_s,
	//	Column[1] = df_s_raise,
	//	Column[2] = df_raise,
	//	Column[3] = df_n_raise,
	//	Column[4] = df_n,
	//	Column[5] = df_n_lower,
	//	Column[6] = df_lower,
	//	Column[7] = df_s_lower
	//)

	//rotation_dirs[5] = 
	//(
	//	Column[0] = df_sw,
	//	Column[1] = df_sw_raise,
	//	Column[2] = df_raise,
	//	Column[3] = df_se_raise,
	//	Column[4] = df_se,
	//	Column[5] = df_se_lower,
	//	Column[6] = df_lower,
	//	Column[7] = df_sw_lower
	//)

	//rotation_dirs[6] = 
	//(
	//	Column[0] = df_w,
	//	Column[1] = df_w_raise,
	//	Column[2] = df_raise,
	//	Column[3] = df_e_raise,
	//	Column[4] = df_e,
	//	Column[5] = df_e_lower,
	//	Column[6] = df_lower,
	//	Column[7] = df_w_lower
	//)

	//rotation_dirs[7] = 
	//(
	//	Column[0] = df_nw,
	//	Column[1] = df_nw_raise,
	//	Column[2] = df_raise,
	//	Column[3] = df_se_raise,
	//	Column[4] = df_se,
	//	Column[5] = df_se_lower,
	//	Column[6] = df_lower,
	//	Column[7] = df_nw_lower
	//)

	//diagonal_dirs[0][0] = df_n
	//diagonal_dirs[0][1] = df_n_raise
	//diagonal_dirs[0][2] = df_raise
	//diagonal_dirs[0][3] = df_s_raise
	//diagonal_dirs[0][4] = df_s
	//diagonal_dirs[0][5] = df_s_lower
	//diagonal_dirs[0][6] = df_lower
	//diagonal_dirs[0][7] = df_n_lower

	//diagonal_dirs[1][0] = df_ne
	//diagonal_dirs[1][1] = df_ne_raise
	//diagonal_dirs[1][2] = df_raise
	//diagonal_dirs[1][3] = df_sw_raise
	//diagonal_dirs[1][4] = df_sw
	//diagonal_dirs[1][5] = df_sw_lower
	//diagonal_dirs[1][6] = df_lower
	//diagonal_dirs[1][7] = df_ne_lower

	//diagonal_dirs[2][0] = df_e
	//diagonal_dirs[2][1] = df_e_raise
	//diagonal_dirs[2][2] = df_raise
	//diagonal_dirs[2][3] = df_w_raise
	//diagonal_dirs[2][4] = df_w
	//diagonal_dirs[2][5] = df_w_lower
	//diagonal_dirs[2][6] = df_lower
	//diagonal_dirs[2][7] = df_e_lower

	//diagonal_dirs[3][0] = df_se
	//diagonal_dirs[3][1] = df_se_raise
	//diagonal_dirs[3][2] = df_raise
	//diagonal_dirs[3][3] = df_nw_raise
	//diagonal_dirs[3][4] = df_nw
	//diagonal_dirs[3][5] = df_nw_lower
	//diagonal_dirs[3][6] = df_lower
	//diagonal_dirs[3][7] = df_se_lower

	//diagonal_dirs[4][0] = df_s
	//diagonal_dirs[4][1] = df_s_raise
	//diagonal_dirs[4][2] = df_raise
	//diagonal_dirs[4][3] = df_n_raise
	//diagonal_dirs[4][4] = df_n
	//diagonal_dirs[4][5] = df_n_lower
	//diagonal_dirs[4][6] = df_lower
	//diagonal_dirs[4][7] = df_s_lower




	//diagonal_dirs[1] = df_n_raise
	//diagonal_dirs[2] = df_ne_raise
	//diagonal_dirs[3] = df_w_raise
	//diagonal_dirs[4] = df_e_raise
	//diagonal_dirs[5] = df_sw_raise	
	//diagonal_dirs[6] = df_s_raise
	//diagonal_dirs[7] = df_se_raise

	//mInstance = none
    Name="Default__X_COM_Compass"	
}