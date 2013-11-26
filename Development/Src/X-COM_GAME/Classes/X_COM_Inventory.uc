class X_COM_Inventory extends Inventory
	classgroup(XCOM)
	hidecategories(Movement, Debug, Display, Attachment, Collision, Physics, Advanced, Object)
	abstract
	notplaceable;

//=============================================================================
// Variables
//=============================================================================
/** Inventory Item Mesh */
var (XCOM_Item) const SkeletalMeshComponent Mesh;

/** Holds socket name attached to */
var protectedwrite name AttachedToSocket;

var protectedwrite bool bActive; // Итем активен

//=============================================================================
// Functions
//=============================================================================
/** Any item added to inventory first should be activated */
simulated public function bool ActivateItem(optional name aSocketName)
{
	if (bActive) return true;
	return AttachItemTo(aSocketName);
}

simulated protected final function bool AttachItemTo( Name aSocketName )
{
	local X_COM_Unit P;

	P = X_COM_Unit(Instigator);

	if (Mesh != none)
	{
		if (Mesh.SkeletalMesh == none) `warn("ERROR: no SkeletalMesh on "$self );

		if ( (aSocketName != '') && (P.Mesh.GetSocketByName(aSocketName) != None) )
		{
			SetBase(P, , P.Mesh, aSocketName);
			P.Mesh.AttachComponentToSocket(Mesh, aSocketName);
			AttachedToSocket = aSocketName;
		}
		else
		{
			SetBase(P, , P.Mesh);
			P.Mesh.AttachComponent(Mesh,'b_root');
		}

		Mesh.SetLightEnvironment(P.LightEnvironment); //share the light environment
		Mesh.SetShadowParent(P.Mesh); //and the shadows
	}

	GoToState('ACTIVE');
	SetHidden(false);
	return true;
}

/** Deactivate current item */
simulated public function bool DeactivateItem()
{
	if (bActive) DetachItem();
	return true;
}

protected function DetachItem()
{
	DetachComponent( Mesh );
	SetBase(None);
	SetHidden(True);
	Mesh.SetLightEnvironment(None);
	GotoState('Inactive');
}

//=============================================================================
// STATES
//=============================================================================
AUTO STATE INACTIVE
{
	simulated function BeginState( Name PreviousStateName )
	{
		`log(" AUTO STATE INACTIVE BeginState "$self);
		bActive = false;
	}
	
	simulated function EndState( Name NextStateName )
	{
		`log(" AUTO STATE INACTIVE EndState "$self);
	}
}

simulated STATE ACTIVE
{
	/** Initialize the weapon as being active and ready to go. */
	simulated function BeginState( Name PreviousStateName )
	{
		`log(" STATE ACTIVE BeginState "$self);
		bActive = true;
	}

	simulated function EndState( Name NextStateName )
	{
		`log(" STATE ACTIVE EndState "$self);
	}
}

//=============================================================================
// Default Properties
//=============================================================================
DefaultProperties
{
	Components.Remove(Sprite)

	Begin Object Class=UDKSkeletalMeshComponent Name=SkeletalMeshComponent0
		bOwnerNoSee=FALSE
		bOnlyOwnerSee=FALSE
		AlwaysLoadOnClient=TRUE
		AlwaysLoadOnServer=TRUE
		MaxDrawDistance=4000
		bUpdateSkelWhenNotRendered=FALSE
		bIgnoreControllersWhenNotRendered=TRUE
		bOverrideAttachmentOwnerVisibility=TRUE
		bAcceptsDynamicDecals=FALSE
		CastShadow=TRUE
		bCastDynamicShadow=TRUE
	End Object
	Components.Add(SkeletalMeshComponent0)
	Mesh=SkeletalMeshComponent0

	bCollideComplex=TRUE
	bCollideActors=TRUE
	bCollideWorld=TRUE
	CollisionType=COLLIDE_TouchAll

	bOrientOnSlope=TRUE
	bShouldBaseAtStartup=TRUE
	bIgnoreRigidBodyPawns=TRUE

	bHidden=TRUE // do not show iten until it is active

	Name="Default__X_COM_Inventory"

	bOnlyRelevantToOwner = FALSE
	bReplicateInstigator = TRUE // Set true as the Instigator variable needs to be consistent for the simulation to be accurate. 
	bOnlyDirtyReplication = TRUE
	Role = ROLE_Authority
	RemoteRole = ROLE_SimulatedProxy // Set to ROLE_SimulatedProxy as clients need to be able to simulate this actor.

	bAlwaysRelevant=true
}
