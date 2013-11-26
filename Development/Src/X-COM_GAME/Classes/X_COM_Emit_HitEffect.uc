/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class X_COM_Emit_HitEffect extends X_COM_Emitter;

simulated function AttachTo(Pawn P, name NewBoneName)
{
	if (NewBoneName == '')
	{
		SetBase(P);
	}
	else
	{
		SetBase(P,, P.Mesh, NewBoneName);
	}
}

simulated function PawnBaseDied()
{
	if (ParticleSystemComponent != None)
	{
		ParticleSystemComponent.DeactivateSystem();
	}
}

defaultproperties
{
}
