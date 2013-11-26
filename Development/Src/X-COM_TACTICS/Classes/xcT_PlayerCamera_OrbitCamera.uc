class xcT_PlayerCamera_OrbitCamera extends GameCameraBase;

var private float CameraDeepAngleMaxDegrees;
var private float CameraDeepAngleMinDegrees;
var private float internalCameraDeepAngleDegrees;

var private int LeftAngleCameraDegrees;
var private int RightAngleCameraDegrees;
var private bool ShouldLockCameraRotation;

var private float Distance;
var private float MinDistance;
var private float MaxDistance;

var private float DesiredDistance;
var private bool bZoomin, bZoomout;
var private float ZoomStep;
var private bool bCameraShouldDoZoom;

/** Expected to fill in OutVT with new camera pos/loc/fov. */
function UpdateCamera(Pawn P, GamePlayerCamera CameraActor, float DeltaTime, out TViewTarget OutVT)
{
	local vector    cameraOffset;
	local Rotator   camRotation;

	super.UpdateCamera(P, CameraActor, DeltaTime, OutVT);

 	//limit pitch in conroller rotation
 	camRotation = LimitViewRotation(OutVT.Target.Rotation, 
 									(90 - InternalCameraDeepAngleDegrees) * DegToUnrRot, 
 									(90 - RightAngleCameraDegrees) * DegToUnrRot, 
 									(90 - LeftAngleCameraDegrees) * DegToUnrRot );
 
	if (bCameraShouldDoZoom)
	{
		//if (int(DesiredDistance) != int(Distance))
		if ( !class'X_COM_Defines'.static.NumbersAlmostEqual(DesiredDistance, Distance, 3) )
		{
			if (bZoomin) 
			{
				Distance -= ZoomStep/5;
				internalCameraDeepAngleDegrees = Clamp( (Distance/ (MaxDistance - MinDistance) * CameraDeepAngleMaxDegrees), CameraDeepAngleMinDegrees, CameraDeepAngleMaxDegrees );
			}
			if (bZoomOut) 
			{
				Distance += ZoomStep/5;
				internalCameraDeepAngleDegrees = Clamp( (Distance/ (MaxDistance - MinDistance) * CameraDeepAngleMaxDegrees), CameraDeepAngleMinDegrees, CameraDeepAngleMaxDegrees );
			}
		}
		else StopZooming();
	}

 	//calculate cam offset
 	cameraOffset = Vector(camRotation) * -Distance;
 
 	OutVT.POV.FOV = 80.0f;
 	OutVT.POV.Location = OutVT.Target.Location + cameraOffset;
 	OutVT.POV.Rotation = camRotation;
}

function ProcessViewRotation( float DeltaTime, Actor ViewTarget, out Rotator out_ViewRotation, out Rotator out_DeltaRot )
{
	super.ProcessViewRotation(DeltaTime, ViewTarget, out_ViewRotation, out_DeltaRot);

	out_ViewRotation += out_DeltaRot;
	out_ViewRotation = LimitViewRotation(out_ViewRotation, 
										((90 - InternalCameraDeepAngleDegrees)* DegToRad) * RadToUnrRot, 
										((90 - RightAngleCameraDegrees)* DegToRad) * RadToUnrRot,
										((90 - LeftAngleCameraDegrees)* DegToRad) * RadToUnrRot);
}

function Rotator LimitViewRotation( Rotator ViewRotation, float DeepAngleDegrees, float LeftAngle, float RightAngle)
{
	ViewRotation.Pitch = Clamp(ViewRotation.Pitch, 49152 + DeepAngleDegrees, 49152 + DeepAngleDegrees);
	if (ShouldLockCameraRotation)
		ViewRotation.Yaw = Clamp(ViewRotation.Yaw, 49152 + LeftAngle, 49152 + RightAngle);

	return ViewRotation;
}

function Init()
{
	super.Init();
}

function ZoomIn()
{
	bCameraShouldDoZoom = true;
	bZoomin = true;
	bZoomout = false;
	DesiredDistance -= ZoomStep;
	DesiredDistance = Clamp(DesiredDistance, MinDistance, MaxDistance);

	
}

function ZoomOut()
{
	bCameraShouldDoZoom = true;
	bZoomin = false;
	bZoomout = true;
	DesiredDistance += ZoomStep;
	DesiredDistance = Clamp(DesiredDistance, MinDistance, MaxDistance);


}

function StopZooming()
{
	bCameraShouldDoZoom = false;
	bZoomin = false;
	bZoomout = false;
}

defaultproperties
{
	CameraDeepAngleMaxDegrees = 65
	CameraDeepAngleMinDegrees = 15
	InternalCameraDeepAngleDegrees = 65;

	ShouldLockCameraRotation = true;
	LeftAngleCameraDegrees = 30;
	RightAngleCameraDegrees = 150;

	Distance=1024.0f
	DesiredDistance=1024.0f
	MinDistance=256.0f
	MaxDistance=1024.0f
	ZoomStep= 64.0f
}