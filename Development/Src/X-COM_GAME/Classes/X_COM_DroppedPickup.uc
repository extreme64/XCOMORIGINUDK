class X_COM_DroppedPickup extends DroppedPickup;

enum ESpecEffectName
{
	/*
	 * Types of visual effects
	 */
	ES_None,

	ES_Fresnel,
};

struct SSpecEffect
{
	/*
	 * Custom visual effect
	 */
	var ESpecEffectName Id;
	var string SpecEffectName;
	var int Value;
};

enum EHUDEffectName
{
	/*
	 * Types of HUD effects of the object
	 */
	EG_None,

	EG_OnHover,
};

struct SHUDEffect
{
	/*
	 * Custom HUD effect of the Object
	 */
	var EHUDEffectName HUDEffectName;
	var bool Active;
	var int Priority;
	var array<SSpecEffect> SpecEffects; // List of visual effects that accompany the HUD effect of the object
};

var PrimitiveComponent PickupMesh;
var ParticleSystemComponent PickupParticles;
var float StartScale;
var bool bPickupable; // EMP forces a pickup to be unusable until it lands
var bool bAutoPickup; // Whether the object is automatically picked up, or not
var LightEnvironmentComponent MyLightEnvironment;
var(XCOM_Item) class<X_COM_Weapon> bItemClass;

var MaterialInstanceConstant bMainMaterial;
var MaterialInstanceConstant bCustomMaterial;

var EHUDEffectName bHUDState;
var EHUDEffectName bPrevState;

var array<SHUDEffect> bHUDEffects;

//var protected xT_DroppedPickup_Tile_AttachBox ColBox;


event PreBeginPlay()
{
	Super.PreBeginPlay();

	// if player who dropped me is still alive, prevent picking up until landing
	// to prevent that player from immediately picking us up
	bPickupable = (Instigator == None || Instigator.Health <= 0);
}

event PostBeginPlay()
{
//	local SHUDEffect lHUDEff;
//	local SSpecEffect lSEff;

//	// spawn an instance of the fake item for AI queries
//	if(bItemClass != none)
//		InventoryClass = bItemClass;
//	else
//		InventoryClass = class'xT_Weapons_Riffle';
//	Inventory = Spawn(InventoryClass);
//	SetPickupMesh(Inventory.DroppedPickupMesh);
///*Здесь когда-то были стили*/
//	/*lSEff.Id = ES_Fresnel;
//	lSEff.SpecEffectName = "OnHover_switch";
//	lSEff.Value = 1.0;*/
////--------- Creating test effects---------
//	bHUDEffects.Add(2);

//	bHUDEffects[0].HUDEffectName   = EG_OnHover;
//	bHUDEffects[0].Active          = false;
//	bHUDEffects[0].Priority        = 100;
//	bHUDEffects[0].SpecEffects.Add(1);

//	bHUDEffects[0].SpecEffects[0].Id            = ES_Fresnel;
//	bHUDEffects[0].SpecEffects[0].SpecEffectName= "OnHover_switch";
//	bHUDEffects[0].SpecEffects[0].Value         = 1.0;

//	//bHUDEffects.AddItem(lHUDEff);

//	bHUDEffects[1].HUDEffectName   = EG_None;
//	bHUDEffects[1].Active          = false;
//	bHUDEffects[1].Priority        = 0;
//	bHUDEffects[1].SpecEffects.Add(1);

//	bHUDEffects[1].SpecEffects[0].Id            = ES_Fresnel;
//	bHUDEffects[1].SpecEffects[0].SpecEffectName= "OnHover_switch";
//	bHUDEffects[1].SpecEffects[0].Value         = 0.0;
//	//lHUDEff.SpecEffects.AddItem(lSEff);
//	//bHUDEffects.AddItem(lHUDEff);
////----------------------------------------
//	bHUDState = EG_None;

//	bMainMaterial = new(None) Class'MaterialInstanceConstant';
//	bMainMaterial.SetParent(MeshComponent(PickupMesh).GetMaterial(0));

//	bCustomMaterial = new(None) Class'MaterialInstanceConstant';
//	bCustomMaterial.SetParent(bMainMaterial);
//	MeshComponent(PickupMesh).SetMaterial(0, bCustomMaterial);
//	//Mesh.SetMaterial(0, MatInst);
//	//UpdateMaterialInstance();
	
	Super.PostBeginPlay();

	AttachCollisionBox();
}

function UpdateMaterialEffects()
{
	local int li, lj;

	li = bHUDEffects.Find('HUDEffectName', bHUDState);
	if(li != INDEX_NONE)
	{
		if(bHUDEffects[li].SpecEffects.Length>0)
		{
			for(lj = 0; lj < bHUDEffects[li].SpecEffects.Length; lj++)
			{
				bCustomMaterial.SetScalarParameterValue(name(bHUDEffects[li].SpecEffects[lj].SpecEffectName), bHUDEffects[li].SpecEffects[lj].Value);
			}
		}
		else
		{
			bCustomMaterial.SetParent(bMainMaterial);
		}
	}
	/*for(li = 0; li < bHUDEffects.Length; li++)
	{
		if(bHUDEffects[li].Active)
		{
			for(lj = 0; lj < bHUDEffects[li].SpecEffects; lj++)
			{
				bCustomMaterial.SetScalarParameterValue(bHUDEffects[li].SpecEffects[lj].SpecEffectName, bHUDEffects[li].SpecEffects[lj].Value);
			}
		}
	}*/
}

function MouseHover()
{
	bHUDState = EG_OnHover;
	/*if( bPrevState != EG_OnHover)
	{
		bHUDState = EG_OnHover;
		UpdateMaterialEffects();
		bPrevState = EG_OnHover;
		bHUDState = EG_None;
	}*/
}

function AttachCollisionBox()
{
	//ColBox = spawn(class'xT_DroppedPickup_Tile_AttachBox', self, , self.Location, Rot(0,0,0), , true);
	//self.Attach(ColBox);
}

event Tick(float deltatime)
{
	if(bPrevState != bHUDState)
	{
		UpdateMaterialEffects();
	}
	bPrevState = bHUDState;
	bHUDState  = EG_None;
}

event Destroyed()
{
	super.Destroyed();
	//ColBox.Destroy();
}

simulated event SetPickupMesh(PrimitiveComponent NewPickupMesh)
{
	if (NewPickupMesh != None && WorldInfo.NetMode != NM_DedicatedServer )
	{
		PickupMesh = new(self) NewPickupMesh.Class(NewPickupMesh);
		if ( class<X_COM_Weapon>(InventoryClass) != None )
		{
			PickupMesh.SetScale(PickupMesh.Scale * 1.2);
		}
		PickupMesh.SetLightEnvironment(MyLightEnvironment);
		AttachComponent(PickupMesh);
	}
}

simulated event SetPickupParticles(ParticleSystemComponent NewPickupParticles)
{
	if (NewPickupParticles != None && WorldInfo.NetMode != NM_DedicatedServer )
	{
		PickupParticles = new(self) NewPickupParticles.Class(NewPickupParticles);
		AttachComponent(PickupParticles);
		PickupParticles.SetActive(true);
	}
}

simulated event Landed(vector HitNormal, Actor FloorActor)
{
	local float DotP, Offset;

	Super.Landed(HitNormal, FloorActor);

	if (PickupMesh != None)
	{
		DotP = HitNormal dot vect(0,0,1);
		if (DotP != 0.0 && DotP < 1.0)
		{
			Offset = sqrt(1.0 - square(DotP)) * CylinderComponent(CollisionComponent).CollisionRadius/DotP;
		}
		  //if ( class<X_COM_Weapon>(InventoryClass) != None )
		  //{
			 // Offset += class<X_COM_Weapon>(InventoryClass).default.DroppedPickupOffsetZ;
		  //}
	  
		  PickupMesh.SetTranslation(vect(0,0,-1) * Offset);
		  if(PickupParticles != None)
		  {
			  PickupParticles.SetTranslation(vect(0,0,-1) * Offset);
		  }
	}
}

/*auto state Pickup
{
	/*
	 Validate touch (if valid return true to let other pick me up and trigger event).
	*/
	function bool ValidTouch(Pawn Other)
	{
		// make sure its a live player
		if (Other == None || !Other.bCanPickupInventory || (Other.DrivenVehicle == None && Other.Controller == None))
		{
			return false;
		}

		// make sure thrower doesn't run over own weapon
		if ( (Physics == PHYS_Falling) && (Other == Instigator) && (Velocity.Z > 0) )
		{
			return false;
		}

		// make sure not touching through wall
		if ( !FastTrace(Other.Location, Location) )
		{
			SetTimer( 0.5, false, nameof(RecheckValidTouch) );
			return false;
		}

		// make sure game will let player pick me up
		if (WorldInfo.Game.PickupQuery(Other, Inventory.class, self))
		{
			return true;
		}
		return false;
	}

	/**
	Pickup was touched through a wall.  Check to see if touching pawn is no longer obstructed
	*/
	function RecheckValidTouch()
	{
		CheckTouching();
	}

	// When touched by an actor.
	event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
	{
		local Pawn P;

		// If touched by a player pawn, let him pick this up.
		P = Pawn(Other);
		if( P != None && ValidTouch(P) )
		{
			GiveTo(P);
		}
	}

	event Timer()
	{
		GotoState('FadeOut');
	}

	function CheckTouching()
	{
		local Pawn P;

		foreach TouchingActors(class'Pawn', P)
		{
			Touch( P, None, Location, vect(0,0,1) );
		}
	}

	event BeginState(Name PreviousStateName)
	{
		AddToNavigation();
		SetTimer(LifeSpan - 1, false);
	}

	event EndState(Name NextStateName)
	{
		RemoveFromNavigation();
	}

Begin:
		CheckTouching();
}*/
/*function SpawnDefaultInventory()
{
	//local Inventory lItem;
	if(InventoryClass != none)
	{
		self.Inventory = Spawn(InventoryClass);
		SetPickupMesh(Weapon(self.Inventory).Mesh);
		//InventoryClass.Possess(self,false);
	}
}*/
/*
 * OLD STATE PICKUP
 * 
 */
auto state Pickup
{
	/*
	 Validate touch (if valid return true to let other pick me up and trigger event).
	*/
	function CheckTouching()
	{
		if ( bAutoPickup == true )
		{
			super.CheckTouching();
		}
	}

	event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
	{
		if( bAutoPickup == true )
		{
			`log("Push me! Push me!");
			super.Touch(Other, OtherComp, HitLocation, HitNormal);
		}
			//super.Touch(Other, OtherComp, HitLocation, HitNormal);
	}

	function bool ValidTouch(Pawn Other)
	{
		return (bPickupable) ? Super.ValidTouch(Other) : false;
	}

	simulated event Landed(vector HitNormal, Actor FloorActor)
	{
		Global.Landed(HitNormal, FloorActor);
		if (Role == ROLE_Authority && !bPickupable)
		{
			bPickupable = true;
			CheckTouching();
		}
	}
}

State FadeOut
{

	simulated event Tick(FLOAT DeltaSeconds)
	{
		if ( (WorldInfo.NetMode == NM_DedicatedServer) || (PickupMesh == None) )
		{
			Disable('Tick');
		}
		else 
		{
			PickupMesh.SetScale(FMax(0.01, PickupMesh.Scale - StartScale * DeltaSeconds));
		}
	}

	simulated function BeginState(Name PreviousStateName)
	{
		bFadeOut = true;
		if ( PickupMesh != None )
		{
			StartScale = PickupMesh.Scale;
		}

		if( PickupParticles != None )
		{
			PickupParticles.DeactivateSystem();
		}

		LifeSpan = 1.0;
	}
}

defaultproperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=DroppedPickupLightEnvironment
		bDynamic=FALSE
		bCastShadows=FALSE
		AmbientGlow=(R=0.2,G=0.2,B=0.2,A=1.0)
	End Object
	MyLightEnvironment=DroppedPickupLightEnvironment
	Components.Add(DroppedPickupLightEnvironment)

	Begin Object NAME=CollisionCylinder
		CollisionRadius=+00050.000000
		CollisionHeight=+00050.000000
		CollideActors=TRUE
	End Object
	CollisionComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	bPickupable=true
	bDestroyedByInterpActor=TRUE
	bAutoPickup=false
	LifeSpan = 100500.0
	//--------- Creating test effects---------
	/*bHUDEffects[0] =
	(
		HUDEffectName = EG_OnHover,
		Active        = false,
		Priority      = 100,
		SpecEffects[0]= (Id = ES_Fresnel, SpecEffectName = "OnHover_switch", Value = 1.0)
	)

	bHUDEffects[1] =
	(
		HUDEffectName   = EG_None,
		Active          = false,
		Priority        = 0,
		SpecEffects[0]  = (Id = ES_Fresnel, SpecEffectName = "OnHover_switch", Value = 0.0)
	)*/

}

