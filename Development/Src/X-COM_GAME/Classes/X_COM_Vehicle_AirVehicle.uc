class X_COM_Vehicle_AirVehicle extends X_COM_Vehicle
	hidecategories(XCOM_Alien, XCOM_DATA);

//=============================================================================
// Variables:
//=============================================================================
var public array<X_COM_Weapon> WeaponGuns;
var public array<X_COM_Weapon> WeaponRockets;
var public array<X_COM_Weapon> WeaponSpecials;

//=============================================================================
// Variables: Movement
//=============================================================================
                                /** Minimum speed Used for Geo movement */
var(XCOM_Aircraft) float                       MinAirSpeed;

                                /** Maximum speed Used for Geo movement */
var(XCOM_Aircraft)  float                       MaxAirSpeed;      
                                
                                /**[rad] This is the max angle vehicle can turn for one movement step calculation*/
var(XCOM_Aircraft)  float                       MaxTurnAngle;     
                                
                                /** How much the vehicle inclines left or right while turning. 
                                *  @remarks InclinationAngle = InclinationRatio * TurnAngle_on_x1_speed    */
var(XCOM_Aircraft)  float                       InclinationRatio;

								/** Maximum inctlination of vehicle to left or right while turning. 
                                *  @remarks InclinationAngle = InclinationRatio * TurnAngle_on_x1_speed    */
var(XCOM_Aircraft)  float                       MaxInclination;

                                /** Numerical vehicle Id, unique for each vehicle */
var int                         NumericalId;
//=============================================================================
//  UNIT CHARACTERISTICS
//=============================================================================
                                /** point of moving destination */
var Vector                      DestinationDirection; 

                                /** debug vector, points the vehicle will be turned on the next movement check */
var Vector                      TurnDirection;      

                                /** moving direction */ 
var Vector                      Direction;      
	
							    /** this is the real speed, calculated by tracking position change
							     *  @remarks it is used by enemy AI and for nothing else*/
var Vector                      RealSpeed;
                                
//=============================================================================
// Functions:
//=============================================================================
function SetMovementPhysics(); //disabled due to not change physics when projectile hits
/** Overided for Aircrafts. Should not be used, bacause physics always should be NONE */
function SetDyingPhysics(); // disabled to not falls when dying

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	//ShowShineEffect();SpeedDirection = Vector(Rotation);
}

public function SetNewOrtoRotation(Vector aX, Vector aY, Vector aZ)
{
	SetRotation(OrthoRotation (aX, aY, aZ));
}

//Tick function
function Tick(Float Delta)
{
	Super.Tick(Delta);  //?What is DELTA parameter?
	
	DrawDebugLine(Location, Location + Normal(Vector(Rotation))*200, 0,0,255);
	DrawDebugLine(Location, DestinationDirection, 10,255,10);                            //Green Direction to desired destination is 
	DrawDebugLine(Location, Location + Normal(TurnDirection - Location)*150, 255,10,0);                                 //Blue - original 
	//DrawDebugLine(Location, Location + Normal(Vector(Rotation))*200, 255,10,10);        //wtf?
}

///** Show static shine effect around Aircraft **/
//function ShowShineEffect()
//{
//	local Vector lTranslation, lDimensions;
//	local Box Bounds;
//		ShineEffect = spawn(class'X_COM_Tile',,,Location);
//	ShineEffect.SetBase(self,,self.Mesh, MeshCenterSocket);
//	ShineEffect.SetStaticMesh(StaticMesh(DynamicLoadObject("xcSimpleObjects.Meshes.SimpleSphere",class'StaticMesh')));
//	ShineEffect.StaticMeshComponent.SetMaterial(0, MaterialInterface(DynamicLoadObject(ShineEffectMaterial,class'MaterialInterface')));

//	ShineEffect.GetComponentsBoundingBox(Bounds);
//	lDimensions = Bounds.Max - Bounds.Min - vect(2,2,2);	
//	lTranslation.X = lDimensions.X*5;
//	lTranslation.Y = lDimensions.Y*5;
//	lTranslation.Z = 0;
//	ShineEffect.StaticMeshComponent.SetTranslation(lTranslation);
//}

//=============================================================================
// Aircrafts dying:
//=============================================================================
State Dying
{
	simulated function BeginState(Name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);
		CustomGravityScaling = 0.0; // Disable world Z-axe gravity
	}
}

//=============================================================================
// Own Firing system
//=============================================================================
simulated public function ProcessFire(vector aAtLocation); //not used

simulated public function ProcessFireGuns(vector aAtLocation)
{
	local int il;

	if (WeaponGuns.Length > 0)
	{
		for (il=0; il < WeaponGuns.Length; ++il)
		{
			if (WeaponGuns[il] != none)
			{
				WeaponGuns[il].StartFire(aAtLocation);
			}
		}
	}
}

simulated public function ProcessFireRockets(vector aAtLocation)
{
	local int il;

	if (WeaponRockets.Length > 0)
	{
		for (il=0; il < WeaponRockets.Length; ++il)
		{
			if (WeaponRockets[il] != none)
			{
				WeaponRockets[il].StartFire(aAtLocation);
			}
		}
	}
}

simulated public function ProcessFireSpecials(vector aAtLocation)
{
	local int il;

	if (WeaponSpecials.Length > 0)
	{
		for (il=0; il < WeaponSpecials.Length; ++il)
		{
			if (WeaponSpecials[il] != none)
			{
				WeaponSpecials[il].StartFire(aAtLocation);
			}
		}
	}
}

simulated function bool CanAttack(Actor Other)
{
	return true;
}


//=============================================================================
// Selecting effects
//=============================================================================
/** Show particle effect when pawn is selecting by the player **/
public simulated function ShowUnitSelectingEffect()
{
	local ParticleSystemComponent lPSC;
	if ( (WorldInfo != none) && (WorldInfo.NetMode == NM_Standalone) )
	{
		WorldInfo.MyEmitterPool.SpawnEmitter(UnitSelectionEffectTemplate, Location, Rotation, self); // не работает в сетевой игре
	}
	else
	{
		if ( UnitSelectionEffectTemplate!=none)
		{
			lPSC = new(Outer)class'ParticleSystemComponent';
			lPSC.SetRotation(Rotation);
			lPSC.SetTemplate(UnitSelectionEffectTemplate);
			AttachComponent(lPSC);
			lPSC.ActivateSystem();
		}
	}
}

/** Show particle effect when pawn was being selected by the player **/
protected function ShowUnitSelectedEffect()
{
	`log(" ShowUnitSelectedEffect called ");
	//UnitSelectedEffect = WorldInfo.MyEmitterPool.SpawnEmitter(UnitSelectedEffectTemplate, self.Location, self.Rotation, self); // не работает в сетевой игре
	if ( (WorldInfo != none) && (WorldInfo.NetMode == NM_Standalone) )
	{
		UnitSelectedEffect = WorldInfo.MyEmitterPool.SpawnEmitter(UnitSelectedEffectTemplate, Location, Rotation, self); // не работает в сетевой игре
	}
	else
	{
		if ( UnitSelectedEffectTemplate!=none)
		{
			UnitSelectedEffect = new(Outer)class'ParticleSystemComponent';
			UnitSelectedEffect.SetRotation(Rotation);
			UnitSelectedEffect.SetTemplate(UnitSelectedEffectTemplate);
			AttachComponent(UnitSelectedEffect);
			UnitSelectedEffect.ActivateSystem();
		}
	}
}

/** Show static particle effect player unit**/
public simulated function ShowStaticUnitEffect()
{
	`log(" ShowStaticUnitEffect called ");
	//StaticUnitEffect = WorldInfo.MyEmitterPool.SpawnEmitter(StaticUnitEffectTemplate, self.Location, self.Rotation, self); // не работает в сетевой игре
	if ( (WorldInfo != none) && (WorldInfo.NetMode == NM_Standalone) )
	{
		StaticUnitEffect = WorldInfo.MyEmitterPool.SpawnEmitter(StaticUnitEffectTemplate, Location, Rotation, self); // не работает в сетевой игре
	}
	else
	{
		if ( StaticUnitEffectTemplate!=none)
		{
			StaticUnitEffect = new(Outer)class'ParticleSystemComponent';
			StaticUnitEffect.SetRotation(Rotation);
			StaticUnitEffect.SetTemplate(StaticUnitEffectTemplate);
			AttachComponent(StaticUnitEffect);
			StaticUnitEffect.ActivateSystem();
		}
	}
}

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
	DefaultPhysics = PHYS_None

	DeadVehicleLifeSpan=4.5 //should to disappear
	BurnOutTime=3.5

	Begin Object Name=PawnLightEnvironment
         AmbientGlow=(R=0.9,G=0.9,B=0.9,A=1.0)
    End Object

	Begin Object Name=CollisionCylinder
		CollisionRadius=+50.f
		CollisionHeight=+50.f
	End Object

	VehicleEffects(0)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Cicada.Effects.P_VH_Cicada_GroundEffect',EffectSocket=Engine_Smoke)
	VehicleEffects(1)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Cicada.Effects.P_VH_Cicada_Exhaust',EffectSocket=L_Engine)
	VehicleEffects(2)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Cicada.Effects.P_VH_Cicada_Exhaust',EffectSocket=R_Engine)
	VehicleEffects(3)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'Envy_Effects.Vehicle_Damage.P_Vehicle_Damage_1_Cicada',EffectSocket=Damage_Smoke)

	VehicleAnims(0)=(AnimTag=EngineStart,AnimSeqs=(interceptor_Up),AnimRate=1.0,bAnimLoopLastSeq=false,AnimPlayerName=AirVehicle)
	VehicleAnims(1)=(AnimTag=EngineStop,AnimSeqs=(interceptor_Land),AnimRate=1.0,bAnimLoopLastSeq=false,AnimPlayerName=AirVehicle)
	VehicleAnims(2)=(AnimTag=Fly,AnimSeqs=(interceptor_Move),AnimRate=1.0,bAnimLoopLastSeq=true,AnimPlayerName=AirVehicle)
	VehicleAnims(3)=(AnimTag=Idle,AnimSeqs=(interceptor_Move),AnimRate=1.0,bAnimLoopLastSeq=true,AnimPlayerName=AirVehicle)

	BurnOutMaterial=MaterialInterface'VH_Cicada.Materials.MITV_VH_Cicada_Red_BO'
}