/**
 * Clouds tile class
 * 
 */
class xcGEO_Tile_Earth_Clouds extends xcGEO_Tile_Earth;

var xcGEO_GameInfo mGameInfo;

function PostBeginPlay()
{
	super.PostBeginPlay();
	mGameInfo = xcGEO_GameInfo(Worldinfo.Game);
}

event Tick(float aDeltaTime)
{
	super.Tick(aDeltaTime);
	RotationRate.Yaw = default.RotationRate.Yaw * mGameInfo.GetGameSpeed();
}

//=============================================================================
// DefaultProperties
//=============================================================================
defaultproperties
{
	PrePivot = (X=0,Y=0,Z=0)
    Physics = PHYS_Rotating
    RotationRate = (Pitch=0, Yaw=182, Roll=0) //1 degrees = DegToUnrRot = 182.0444

	CollisionType=COLLIDE_BlockAll

	bCollideActors = FALSE
	bBlockActors = FALSE
	BlockRigidBody = FALSE
	bWorldGeometry = FALSE

	Begin Object Name=xcTileMesh
		AlwaysCheckCollision = FALSE
		
		BlockRigidBody=FALSE
		BlockActors=FALSE
		BlockZeroExtent=FALSE
		BlockNonZeroExtent=FALSE
		CollideActors = FALSE

		RBCollideWithChannels=(Default=FALSE, BlockingVolume=FALSE, GameplayPhysics=FALSE, EffectPhysics=FALSE, Vehicle=FALSE, Untitled3=FALSE, Pawn=FALSE)
    End Object
}
