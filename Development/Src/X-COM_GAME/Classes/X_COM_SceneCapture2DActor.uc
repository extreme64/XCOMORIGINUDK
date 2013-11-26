/**
 * SceneCapture2DActor
 *
 * Place this actor in the level to capture it to a render target texture.
 * Uses a 2D scene capture component
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class X_COM_SceneCapture2DActor extends SceneCapture2DActor
	notplaceable;

defaultproperties
{
	// 2D scene capture
	Begin Object Name=SceneCapture2DComponent0
			FrameRate = 1
			TextureTarget = TextureRenderTarget2D'MiniMap.Textures.MM_Rendered_Texture'
			NearPlane=2048
			FarPlane=3840
			FieldOfView=90
			bUpdateMatrices=true
			ViewMode = SceneCapView_Unlit //SceneCapView_LitNoShadows //SceneCapView_Unlit
	End Object

	Location = (X= 3840, Y = 3840, Z = 3840)
	Rotation = (Pitch=-16384, Yaw=-16384, Roll=0)

	bStatic = false 
	bNoDelete = false
}
