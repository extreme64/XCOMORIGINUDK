/**
 * X-COM Tactics functions and variables class. 
 * Uses to store functions and variables for tactics classes.
 */
class X_COM_MovementRules extends object;

enum EMoveName
{
	mn_uper_step,
	mn_uper_turn,
	mn_uper_crouch,
	mn_stend_up
};

enum EPosition
{
	EP_none,
	EP_Standing,
	EP_Sitting,
	EP_Howering,
};

struct MovementType
{
	var EMoveName   mName;
	var int         Value;
};
//=============================================================================
// Constant movement TimeUnits cost
//=============================================================================
var array<MovementType> MovementTypes;
const           TUperStep = 4;
const			TUperTurn = 2;
const			TUperCrouch = 4;
const			TUperStandUp = 8;
const			TUperFire_Aimed = 60;
const			TUperFire_Burst = 15; //for one shot of 3.
const			TUperFire_Quick = 35;
const			TUperFire_Throw = 20;

//=============================================================================
// Functions
//=============================================================================

// Добавить
// Удалить
// Найти
// Изменить

//=============================================================================
// Default properties
//=============================================================================
defaultproperties
{
    Name="Default__X_COM_MovementRules"
}