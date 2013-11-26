/**
 * X-COM Tactics functions and variables class. 
 * Uses to store functions and variables for tactics classes.
 */
class xcT_Test_Direction extends Object;

var X_COM_Direction mDirection;

function Context()
{
	//mDirection = new class'X_COM_Direction';	
}

//=============================================================================
// Tests
//=============================================================================

function IterateDirectionsWithDefaultParams()
{
	//Context();

	//local X_COM_Direction lDirection;

	mDirection = new class'X_COM_Direction';
	for(mDirection.Set(df_nw_raise); mDirection.Get()!=df_uninit; mDirection.Iterate())
	{
		`log(mDirection.Get());
	}
}

function IterateStreightDirections()
{
	//Context();

//	local X_COM_Direction mDirection;

	mDirection = new class'X_COM_Direction';

	`log("Iterate streight directions test");
	mDirection.iteration_option_diagonal_dirs = false;

	for(mDirection.DirectionsIterationStart(); mDirection.Get()!=df_uninit; mDirection.Iterate())
	{
		`log(mDirection.Get());
	}
	`log("===================================================================");
}

function GettingDirectionByRotator()
{
//	local X_COM_Direction mDirection;

	mDirection = new class'X_COM_Direction';
	mDirection.SetFromRotator(rot(0, 0, 0));
	if(mDirection.Get() == df_n)
	{
		`log("Testing direction by rotator: OK");
	}
}
//=============================================================================
// Default properties
//=============================================================================
defaultproperties
{
    Name="Default__xcT_Test_Direction"	
}