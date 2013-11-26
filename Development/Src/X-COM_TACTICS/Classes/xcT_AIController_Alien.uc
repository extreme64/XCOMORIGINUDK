/**
 * Tactics AI controller. 
 * Uses for x-com and ufo controllers
 */
class xcT_AIController_Alien extends xcT_AIController; 

///** Overriden, and not used for self class */
//event SeeMonster( Pawn Seen );

//=============================================================================
// DefaultProperties
//=============================================================================
DefaultProperties
{
	bIsPlayer=TRUE  //если это поставить FALSE то перестанут рабоать команды тк playerreplication не будет существовать

	Name="Default__xT_AIController_Alien"
}
