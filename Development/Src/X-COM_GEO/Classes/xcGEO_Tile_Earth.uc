/**
 * Ocean tile class
 * Uses for oceans, sea and big rivers in GEO
 */
class xcGEO_Tile_Earth extends X_COM_Tile;

//=============================================================================
// DefaultProperties
//=============================================================================
defaultproperties
{
	CollisionType=COLLIDE_BlockAll

	bCollideActors = TRUE
	bBlockActors = TRUE
	BlockRigidBody = TRUE
	bWorldGeometry = TRUE

	Begin Object Name=xcTileMesh 
		AlwaysCheckCollision = TRUE
		
		BlockRigidBody=TRUE
		BlockActors=TRUE
		BlockZeroExtent=TRUE
		BlockNonZeroExtent=TRUE
		CollideActors = TRUE

		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE,Untitled3=TRUE, Pawn=TRUE)
    End Object
}
