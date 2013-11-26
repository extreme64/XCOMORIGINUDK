class X_COM_Equipment_Shields_AirVehicle extends X_COM_Equipment_Shields
	placeable;

/** Time since shield will regeneate its defence value */
var(XCOM_Shield) const float RegenerationTime;

public function StartRegeneration()
{
	bDoRegen = true;
	RegenStartTime = Worldinfo.TimeSeconds;
}

function Tick(float aDeltaTime)
{
	super.Tick(aDeltaTime);
	if (bDoRegen)
	{
		if (Defence < MaxDefence)
		{
			if ( (Worldinfo.TimeSeconds - RegenStartTime) >= RegenerationTime )
			{
				Defence += RegenerationValue;
				Defence = max(Defence, MaxDefence);
			}
		}
		else bDoRegen = false;
	}
}

DefaultProperties
{

}
