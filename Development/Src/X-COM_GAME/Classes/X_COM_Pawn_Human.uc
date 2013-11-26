/**
 * X-Com special human pawn class.
 */
class X_COM_Pawn_Human extends X_COM_Pawn
	hidecategories(XCOM_Alien)
	placeable;

var EHumanSoldierRanks               Rank;                   // Soldier rank
var(XCOM_Data) EArmorDefenceTypes	 ArmorType;              // Dressed armor
var SpotlightMovable                 Flashlight;

DefaultProperties
{
	Begin Object Class=SpotLightComponent Name=FlashlightComponent
		InnerConeAngle=45.0
		OuterConeAngle=60.0
		Radius=1024
		Brightness=1
		CastShadows=TRUE
		CastStaticShadows=TRUE
		CastDynamicShadows=TRUE
		bCastCompositeShadow=TRUE
		bAffectCompositeShadowDirection=TRUE
		bForceDynamicLight=TRUE
		UseDirectLightMap=TRUE
		bPrecomputedLightingIsValid=TRUE
		LightingChannels=(BSP=TRUE,Static=TRUE,Dynamic=TRUE,CompositeDynamic=TRUE,bInitialized=TRUE)
		LightShadowMode=LightShadow_Normal
		ShadowFilterQuality=SFQ_High
	End Object
    //Components.Add(FlashlightComponent)
	Flashlight=FlashlightComponent

	Begin Object Class=PointLightComponent Name=AroundlightComponent
		Radius=128
		CastDynamicShadows=true
		CastShadows=true
		CastStaticShadows=true
		bCastCompositeShadow=true
		LightShadowMode=LightShadow_ModulateBetter
	End Object
    Components.Add(AroundlightComponent)
	//Flashlight=AroundlightComponent

	Name="Default__X_COM_Pawn_Human"
}
