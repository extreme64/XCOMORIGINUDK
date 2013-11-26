class X_COM_Tile_AlienEvent extends X_COM_Tile
	hidecategories(Movement, Display, Attachment, Collision, Physics, Advanced, Debug, Object)
	placeable;

var(AlienEvent) EAlienEventType AlienEventType;

//=============================================================================
// DefaultProperties
//=============================================================================
defaultproperties
{
    Physics = PHYS_None
	
	CollisionType=COLLIDE_BlockAll

	bCollideActors = TRUE
	bBlockActors = TRUE
	BlockRigidBody = TRUE
	bWorldGeometry = TRUE

	Begin Object Name=xcTileMesh
		AlwaysCheckCollision = TRUE

		bAllowAmbientOcclusion = TRUE
		bAllowApproximateOcclusion = TRUE
 	 
		bForceMipStreaming = TRUE	
	
		BlockRigidBody=TRUE
		BlockActors=TRUE
		BlockZeroExtent=TRUE
		BlockNonZeroExtent=TRUE
		CollideActors = TRUE

		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE,Untitled3=TRUE, Pawn=TRUE, DeadPawn=TRUE)
    End Object
}
