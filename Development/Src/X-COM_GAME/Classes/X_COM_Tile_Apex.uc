
class X_COM_Tile_Apex extends ApexDestructibleActorSpawnable
	placeable;

enum EApexTileTypes
{
	EATT_Door,
	EATT_Floor,
	EATT_Wall,
	EATT_Ladder,
	EATT_EdgeWall
};

var(XCOM_Apex) const EApexTileTypes Type;

var(XCOM_Apex) int Durability;

var private  bool bDestroyed;

//=============================================================================
// Functions
//=============================================================================
simulated function TakeDamage
(
	int						Damage,				/* The amount of Damage to apply */
	Controller				EventInstigator,    /* The instigator of this event */
	vector					HitLocation,		/* The location where the impact occured */
	vector					Momentum,			/* The momentum of the impact */
	class<DamageType>		DamageType,			/* The type of damage to apply */
	optional TraceHitInfo	HitInfo,			/* The detailed hit information for this damage event */
	optional Actor			DamageCauser		/* The actor which caused the damage */
)
{
	//local float testttt;

	`log("--------- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Apex TakeDamage");
	`log("in Damage : "$Damage);

	//testttt = ApexDestructibleAsset(self.StaticDestructibleComponent.Asset).DestructibleParameters.DamageThreshold;
	//`log("DamageThreshold : "$testttt);
	
	super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	Durability -= Damage;
	`log("Durability : "$Durability);
	if ( (!bDestroyed) && (Durability <= 0) )
	{
		bDestroyed = true;
		TakeDamage(10000, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	}		
}

simulated function TakeRadiusDamage
(
	Controller			InstigatedBy,		/* The instigator for this radius damage */
	float				BaseDamage,			/* The base damage amount */
	float				DamageRadius,		/* The radius of the damage */
	class<DamageType>	DamageType,			/* The type of damage to apply */
	float				Momentum,			/* The momentum of the damage */
	vector				HurtOrigin,			/* The origin of the damage */
	bool				bFullDamage,		/* Whether or not to apply full damage or attenuated damage */
	Actor				DamageCauser,		/* The actor which caused the damage */
	optional float      DamageFalloffExponent=1.f
)
{
	`log("--------- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Apex TakeRadiusDamage");
	super.TakeRadiusDamage(InstigatedBy, BaseDamage, DamageRadius, DamageType, Momentum, HurtOrigin, bFullDamage, DamageCauser, DamageFalloffExponent);
}

simulated function OnDestroy(SeqAct_Destroy Action)
{
	`log("--------- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Apex OnDestroy");
	super.OnDestroy(Action);
}

function Destroyed()
{
	`log("--------- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Apex Destroyed");
	super.Destroyed();
}

simulated function OnModifyHealth(SeqAct_ModifyHealth Action)
{
	`log("--------- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Apex OnModifyHealth()");
	super.OnModifyHealth(Action);
}

//=============================================================================
// Default Properties
//=============================================================================
defaultproperties
{
	Begin Object Name=DestructibleComponent0
		bCastDynamicShadow=TRUE
		bForceDirectLightMap=FALSE
		RBChannel = RBCC_EffectPhysics
		RBCollideWithChannels=(Default=True, GameplayPhysics=True, EffectPhysics=True, BlockingVolume=True)
	End Object
}