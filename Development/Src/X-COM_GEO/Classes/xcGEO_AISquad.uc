/** for x-com only */

class xcGEO_AISquad extends Object;

//=============================================================================
// Variables
//=============================================================================
var private array<X_COM_Unit>          Members;
var private array<X_COM_Unit>          Enemies;

//=============================================================================
// 
//=============================================================================

//=============================================================================
// Functions: Members
//=============================================================================
public function RegisterSquadMember(X_COM_Unit aNewMember)
{
	Members.AddItem(aNewMember);
}

public function UnRegisterSquadMember(X_COM_Unit aOldMember)
{
	Members.RemoveItem(aOldMember);
}

//=============================================================================
// Functions: Enemies
//=============================================================================
public function RegisterEnemy(X_COM_Unit aNewEnemy)
{
	Enemies.AddItem(aNewEnemy);
}

public function UnRegisterEnemy(X_COM_Unit aOldEnemy)
{
	Enemies.RemoveItem(aOldEnemy);
}

//=============================================================================
// Functions: Getters
//=============================================================================
public function array<X_COM_Unit>  GetAllEnemies()
{
	return Enemies;
}

public function array<X_COM_Unit>  GetAllSquadMembers()
{
	return Members;
}

//=============================================================================
// DefaultProperties
//=============================================================================
defaultproperties
{
}
