/**
 * X-COM Damage Type class
 */
class X_COM_DamageType extends DamageType
	dependson(X_COM_Defines);

//=============================================================================
// Variables: Damage
//=============================================================================
var EDamageTypes                TypeOfDamage;

var bool                        bShieldStops;

/** Whether or not this damage type can cause a blood splatter */
var bool                        bCausesBloodSplatterDecals;

/** Whether damage produces blood */
var bool					    bCausesBlood;

/** magnitude of momentum that must be caused by this damagetype for physics based takehit animations to be used on the target */
var float                       PhysicsTakeHitMomentumThreshold;

/** For ragdoll death. Add entirety of killing hit's momentum to ragdoll's initial velocity. */     
var	bool			            bThrowRagdoll;
var bool			            bLeaveBodyEffect;

////=============================================================================
//// Variables: DEATH ANIM
////=============================================================================
///** Name of animation to play upon death. */
//var(DeathAnim)	name	        DeathAnim;
///** How fast to play the death animation */
//var(DeathAnim)	float	        DeathAnimRate;
///** If true, char is stopped and root bone is animated using a bone spring for this type of death. */
//var(DeathAnim)	bool	        bAnimateHipsForDeathAnim;
///** If non-zero, motor strength is ramped down over this time (in seconds) */
//var(DeathAnim)	float	        MotorDecayTime;
///** If non-zero, stop death anim after this time (in seconds) after stopping taking damage of this type. */
//var(DeathAnim)	float	        StopAnimAfterDamageInterval;

//=============================================================================
// Functions:
//=============================================================================
/** Possibly spawn a custom hit effect */
static function SpawnHitEffect(Pawn P, float Damage, vector Momentum, name BoneName, vector HitLocation);

/** @return duration of hit effect, primarily used for replication timeout to avoid replicating out of date hits to clients when pawns become relevant */
static function float GetHitEffectDuration(Pawn P, float Damage)
{
	return 0.5;
}

//=============================================================================
// DefaultProperties
//=============================================================================
defaultproperties
{
//	DeathAnimRate = 1.0

	PhysicsTakeHitMomentumThreshold = 250.0

//	bAnimateHipsForDeathAnim = true
	bCausesBlood=true
	bCausesBloodSplatterDecals = true
	bCausesFracture = true
	bArmorStops = true
	bShieldStops = true
}


