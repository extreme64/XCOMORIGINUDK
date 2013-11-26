class X_COM_Vehicle_AirVehicle_Human extends X_COM_Vehicle_AirVehicle
	placeable;


simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	//PlaySound(LaunchVehicleSound); // aircraft shown sound
}

DefaultProperties
{
}