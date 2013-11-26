class X_COM_Vehicle_AirVehicle_Alien extends X_COM_Vehicle_AirVehicle
	hidecategories(XCOM_Human)
	placeable;

//=============================================================================
// Variables
//=============================================================================

//=============================================================================
// UFO dying:
//=============================================================================
//simulated state DyingVehicle
//{
//	simulated function BeginState(Name PreviousStateName)
//	{
//		Super.BeginState(PreviousStateName);
//	}
//}

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
	DeadVehicleLifeSpan=2.5
	BurnOutTime=5.0
}