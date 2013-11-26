/**
 * Класс обьектов в тактике
 * Дома, фурнитура и т.д.
 */
class X_COM_Tile_Prefab extends X_COM_Tile;

//=============================================================================
// Functions
//=============================================================================
/** Установка обьекта для этого класса */
/*
function BuildPrefab(int alevel)
{
	local int a;
	local Prefab ThePrefab;
	local name lLevel;

	switch (alevel)
	{
		case 1	:   lLevel = 'Level_1';
		break;
		case 2	:   lLevel = 'Level_2';
		break;
		case 3  :   lLevel = 'Level_3';
		break;
	}

	//ThePrefab = Prefab'xcT_Bilding.Test.Pref_Test_1';
	ThePrefab = Prefab'xcT_Bilding.Test.Pref_2';

	a = ThePrefab.PrefabArchetypes.Length;

	for (a = 0; a < ThePrefab.PrefabArchetypes.Length; a++)
	{
		if ((Actor(ThePrefab.PrefabArchetypes[a]).Tag) == lLevel) Prefab_AddObject(Actor(ThePrefab.PrefabArchetypes[a]));
	}
}

function BuildPrefab()
{
	local int a;
	local Prefab ThePrefab;

	ThePrefab = Prefab'xcT_Bilding.Test.Pref_1';

	a = ThePrefab.PrefabArchetypes.Length;

	for (a = 0; a < ThePrefab.PrefabArchetypes.Length; a++)
	{
		Prefab_AddObject(Actor(ThePrefab.PrefabArchetypes[a]));
	}
}
*/

function Prefab_AddObject(Actor aPrefabPart)
{
	//local Actor lPrefabPart;

	//lPrefabPart = 
		Spawn(aPrefabPart.Class,,,Location+aPrefabPart.Location,Rotation+aPrefabPart.Rotation, aPrefabPart);
}

//=============================================================================
// Default Properties
//=============================================================================
defaultproperties
{
}

