class X_COM_Projectile_Air extends X_COM_Projectile;

var private Actor Target;

var private bool bCanTick;

public function SetTarget(Actor aTarget)
{
	Target = aTarget;
	bCanTick = TRUE;
}

function Tick(float aDeltaTime)
{
	//local vector laccel, lvel;
	
	//`log("--------------------------------");

	//laccel = Normal(Velocity) * AccelRate;
	//`log(" laccel = "$laccel);
	//`log(" Acceleration = "$Acceleration);

	//lvel = Normal(Acceleration) * maxspeed;
	//`log(" lvel maxspeed = "$lvel);
	//lvel = Normal(Acceleration) * speed;
	//`log(" lvel speed = "$lvel);
	//`log(" Velocity = "$Velocity);

	//AccelRate = (default.AccelRate * xcGeo_GameInfo(Worldinfo.Game).mTimeSpeed) / 100;

	//Acceleration = Normal(Velocity) * AccelRate;

	if (bCanTick)
	{
		if (Target != none)
		{
			Velocity = Normal(Velocity) * (Speed * X_COM_GameInfo(Worldinfo.Game).GetGameSpeed()) * class'X_COM_Settings'.default.GEO_EarthScale;
		}
		else
		{
			bCanTick = FALSE;
			Destroy();
		}
	}
	

	//`log(" Velocity AFTER = "$Velocity);

	super.Tick(aDeltaTime);
}

defaultproperties
{
	lifespan = 0.0f //unlimited life time

	bCanTick = FALSE
}
