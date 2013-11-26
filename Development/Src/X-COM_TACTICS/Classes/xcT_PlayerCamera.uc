class xcT_PlayerCamera extends GamePlayerCamera;

protected function GameCameraBase FindBestCameraType(Actor CameraTarget)
{
	return ThirdPersonCam;
}

defaultproperties
{
	ThirdPersonCameraClass=class'X-COM_Tactics.xcT_PlayerCamera_OrbitCamera'
}
