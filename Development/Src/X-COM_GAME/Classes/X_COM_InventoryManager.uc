class X_COM_InventoryManager extends InventoryManager;

var XCOMDB_Info_Inventory  mInfoInventory;        //Database inventory object

/** Holds last inserted inventory item */
var protectedwrite X_COM_Inventory InventoryChainLast;


simulated function XCOMDB_Info_Inventory SetInventory(XCOMDB_Info_Inventory lInv)
{
	mInfoInventory = lInv;
	return mInfoInventory;
}

simulated function XCOMDB_Info_Inventory GetInventory()
{
	return mInfoInventory;
}

simulated function X_COM_Inventory CreateInventoryFromTemplate(Actor InventoryActorTemplate, optional bool bDoNotActivate)
{
	local X_COM_Inventory Inv;

	if( InventoryActorTemplate != None )
	{
		inv = X_COM_Inventory(Spawn(InventoryActorTemplate.Class, Owner,,,,InventoryActorTemplate,true));

		if( inv != None )
		{
			if( !AddInventory(Inv, bDoNotActivate) )
			{
				`warn("InventoryManager::CreateInventory - Couldn't Add newly created inventory" @ Inv);
				Inv.Destroy();
				Inv = None;
			}
		}
		else
		{
			`warn("InventoryManager::CreateInventory - Couldn't spawn inventory" @ InventoryActorTemplate);
		}
	}

	return Inv;
}

simulated function Inventory CreateInventoryFromName(string aName, optional bool aDoNotActivate)
{
	local array<string> lName;
	local class<Inventory>	lInvClass;
	//local Inventory lItem;

	ParseStringIntoArray(aName, lName, ".", true);
	lInvClass = class<Inventory>(DynamicLoadObject("X-COM_Tactics.xcT_"$lName[0], class'Class'));
	//`log('xT_'$lName[0]);
	`log("Weapon class name - "$lInvClass);
	//lItem=spawn(lInvClass);
	
	return CreateInventory(lInvClass, aDoNotActivate);
}

/**
 * Handle AutoSwitching to a weapon. Overided from parent class because we can have many copies of one items
 */
simulated function bool AddInventory(Inventory NewItem, optional bool bDoNotActivate)
{
	// The item should not have been destroyed if we get here.
	if( (NewItem != None) && !NewItem.bDeleteMe )
	{
		// if we don't have an inventory list, start here
		if( InventoryChain == None )
		{
			InventoryChain = newItem;
		}

		`LogInv("adding" @ NewItem @ "bDoNotActivate:" @ bDoNotActivate);

		NewItem.SetOwner( Instigator );
		NewItem.Instigator = Instigator;
		NewItem.InvManager = Self;
		NewItem.GivenTo( Instigator, bDoNotActivate);

		InventoryChainLast = X_COM_Inventory(newItem);
		if (!bDoNotActivate) InventoryChainLast.ActivateItem();

		// Trigger inventory event
		Instigator.TriggerEventClass(class'SeqEvent_GetInventory', NewItem);
		return TRUE;
	}

	return FALSE;
}


/**
 * Scans the inventory looking for any of type InvClass.  If it finds it it returns it, other
 * it returns none.
 */
simulated function Inventory HasInventoryOfClass(class<Inventory> InvClass)
{
	local inventory inv;

	inv = InventoryChain;
	while(inv!=none)
	{
		if (Inv.Class==InvClass)
			return Inv;

		Inv = Inv.Inventory;
	}
	return none;
}

simulated function array<X_COM_Weapon> GetWeaponList(optional bool bWithAmmoOnly)
{
	local X_COM_Weapon lWeapon;
	local array<X_COM_Weapon> lWeaponList;

	ForEach InventoryActors( class'X_COM_Weapon', lWeapon )
	{
		if (bWithAmmoOnly)
		{
			if (lWeapon.HasAmmo()) lWeaponList.AddItem(lWeapon);
		}
		else
		{
			lWeaponList.AddItem(lWeapon);
		}
	}
	return lWeaponList;
}

simulated function X_COM_Weapon FindBestWeapon(optional bool bWithAmmoOnly)
{
	local X_COM_Weapon lWeapon;
	local X_COM_Weapon lBestWeapon;
	local array<X_COM_Weapon> lWeaponList;
	local int il, jl;

	lWeaponList = GetWeaponList(bWithAmmoOnly);

	if (lWeaponList.Length > 0)
	{
		lBestWeapon = lWeaponList[0];
		for (il=0; il < lWeaponList.Length; ++il)
		{
			for (jl=0; jl < lWeaponList.Length; ++jl)
			{
				if (lWeaponList[il].Damage > lWeaponList[jl].Damage)
				{
					lWeapon = lWeaponList[il];
				}
				if (lWeapon.Damage > lBestWeapon.Damage) lBestWeapon = lWeapon;
			}
		}
		return lBestWeapon;
	}
	return none;
}

Defaultproperties
{
	bMustHoldWeapon=true
	PendingFire(0)=0
	PendingFire(1)=0

	bOnlyRelevantToOwner = FALSE
	bReplicateInstigator = TRUE
	bOnlyDirtyReplication = FALSE
	Role = ROLE_Authority
	RemoteRole = ROLE_SimulatedProxy

	bAlwaysRelevant=true
}
