class xcGEO_AICommand extends X_COM_AICommand;
//=============================================================================
// Variables: Movement
//=============================================================================
										/**new move destination from UI */
var private Vector                      MoveDestination; 

										/**interpolated step destination */
var private Vector                      NextDestination; 
										
										/**flag indication we are in the radius from the destination */
var bool                                DestinationIsReached;

										/** counter of how many little steps were done */
var int                                 StepCount;

                                        /**kind of self check variable to calculate the real speed */
var private Vector                      PreviousPosition;
                                        
                                        /** Distance to target on which it is assumed that the destination is reached*/
var float                               DestinationReachedDistance;

                                        /** desired orientation of vehicle: towards destination point, parallel to the ground position*/
var Vector                              DesiredOrientationZ;
var Vector                              DesiredOrientationY;
var Vector                              DesiredOrientationX;

//=============================================================================
// Reaction on sensors
//=============================================================================
public function Reaction_SeeEnemy(X_COM_Unit aEnemy)
{
	//`log("Reaction_EnemyVisible");
	// first is say to self and near units that see enemy detected
	//Report_EnemyDetected(aEnemy);
	//Report_TeamAboutEnemy(aEnemy);
	if (Pawn != none)
	{
		if (CommandList == GetActiveCommand()) CheckForEnemyReported();
		//{
		//	if (Pawn.Weapon != none)
		//	{
		//		X_COM_AIController(Outer).StartAttackEnemy(aEnemy);
				
		//	}
		//	else 
		//	{
		//		X_COM_AIController(Outer).MoveFarFromEnemy();
		//	}
		//}
		else if (GetActiveCommand().IsA('xcGEO_AICommand_Cmd_Move') && Pawn.IsA('xcGEO_Pawn_Alien')) CheckForEnemyReported(); //used with Aliens only
	}
}

public function Reaction_UnderEnemyFire(X_COM_Unit aEnemy)
{
	
}

//=============================================================================
// Actions
//=============================================================================
public function CheckForEnemyReported()
{
	If (X_COM_AIController(Outer).GetEnemiesCount() > 0)
	{
		if (Pawn.Weapon != none) xcGeo_AIController(Outer).StartAttackEnemy(X_COM_AIController(Outer).GetClosestEnemy()); //we get the closest enemy
	}
}

//=============================================================================
// Movement elementary function
//=============================================================================

/** @brief Updates the movement destination according to AI controlles NewDestination vector 
 */
function UpdateDestination() // final destination quaternion calculation
{
	local Vector lDestination;
	local Vector lWorldCenter;
	
	DestinationIsReached = false; //in will be checked on first ProcessMovementStep

	lWorldCenter = class'X_COM_Settings'.default.GEO_WorldCenter;

	lDestination = Normal(lWorldCenter - X_COM_AIController(Outer).NewDestination); // Destination vector  
	MoveDestination = lWorldCenter - lDestination * class'X_COM_Settings'.default.GEO_FlyingDistanceFromPlanet; // Orbital location

	//QuatDestination = QuatFromRotator(Rotator(lWorldCenter - MoveDestination)); //Final destination quaternion
	PreviousPosition = MoveDestination; //to be sure PrevPosition is set to something
	
	//>oO debug  xcGEO_GameInfo(WorldInfo.Game).DisplayHudDebug("Dst ", "X "$lDestination.X$" Y "$lDestination.Y$" Z "$lDestination.Z);
}



/** Processes elementary movement step. 
 *  This function produces elementary movement and rotation towards the direction 
 *  
 *  This function also relies on the next functions:
 *  @see CalculateDesiredOrientation
 *  @see ProcessVehicleRotation
 *  @see ProcessVehicleShift
 *  
 *  @remarks 
 *  If you once use UpdateDestination and then call ProcessMovementStep untill bDestinationReached is true 
 *  you will get exactly MoveToPosition logic =)
 */
function ProcessMovementStep(float DeltaTime) 
{
	local float lDistance;
	local xcGEO_GameInfo lGameInfo;
	local X_COM_Vehicle_AirVehicle lVehicle; //Corresponding air vehicle

	//Ok... Lets start...
	// We can introduce ANY rotation of a solid body like
	// a rotation around any axis (parallel to the original) 
	// and some translational movement. 
	//
	// So as our plane doesnt change the hights its movement
	// is a rotation around the earch center. 
	// As we say before, we can split this rotation by:
	// a) horizontal movement in the direction of flight
	// b) vertical movement - we shift plane to be on the same height
	// c) rotation around aircraft center (0,0,0 around aircraft framework)
	//
	// Wierd isn't it? Why do we need such compexity?
	// Such complexity (which is not as complex by the way) leads to 
	// one great simplification: aircraft may completely 'think' 
	// and 'act' like if it was on a plane. 
	//
		
	//get globals
	lGameInfo = xcGEO_GameInfo(WorldInfo.Game);
	lVehicle = X_COM_Vehicle_AirVehicle(Pawn);
					
	// Direct distance from present aircraft location to final destination
	lDistance = abs(Acos((Normal(MoveDestination) Dot Normal(Pawn.Location))) * class'X_COM_Settings'.default.GEO_FlyingDistanceFromPlanet);

	//check if distance is enough small for considering it to be a destination
	if(lDistance < DestinationReachedDistance) DestinationIsReached = true;
	
	//FIND DESIRED ORIENTATION
	CalculateDesiredOrientation();
	
	//PROCESS VEHICLE ROTATION
	ProcessVehicleRotation();

	//PROCESS VEHICLE SHIFT
	ProcessVehicleShift(lDistance, lVehicle.Direction);

    //Some final values
	StepCount++;                                                // more steps
	lVehicle.RealSpeed = Pawn.Location - PreviousPosition;      // ActualSpeed
	PreviousPosition = Pawn.Location;
		
	// >oO debug
	lGameInfo.DisplayHudDebug(lVehicle.NumericalId $ " Mov step", string(StepCount));
	lGameInfo.DisplayHudDebug(lVehicle.NumericalId $ " Speed   ", string(VSize(lVehicle.RealSpeed)));
	lGameInfo.DisplayHudDebug(lVehicle.NumericalId $  "Dest is reachd ", string(DestinationIsReached));
}


/**
 * Function relates to @see ProcessMovementStep. Calculates the desired orientation of vehicle:
 * towards destination point, parallel to the ground position
 */
private function CalculateDesiredOrientation()
{
	local Vector lWorldCenter;
	lWorldCenter = class'X_COM_Settings'.default.GEO_WorldCenter;

    // Rotation calculation. Calculates desired position
	DesiredOrientationZ = Normal(Pawn.Location - lWorldCenter);
	DesiredOrientationY = Normal(DesiredOrientationZ Cross (MoveDestination - Pawn.Location));
	DesiredOrientationX = Normal(DesiredOrientationY Cross DesiredOrientationZ);
}

/**
 * Function relates to @see ProcessMovementStep. Process rotaion part of the movement
 */
private function ProcessVehicleRotation()
{	
	local Vector lCurrentDirection;  //Current vehicle rotation
	local Vector lResultDirection;   //Calculated result direction of vehicle
	local Vector lDestination1;      //one solution of rotation
	local Vector lDestination2;      //second solution of rotation
	local float lTurnAngle;          //vechicle angle that will be
	local float lNeedTurnAngle;      //Turn angle that is needed 
	local float lScaledMaxTurnAngle; //scaled by game speed vehicle.MaxTurnAngle
	local Vector objX,objY,objZ;     //temp variables
    local X_COM_Vehicle_AirVehicle lVehicle; //Corresponding air vehicle
    local xcGEO_GameInfo lGameInfo;  //game info
	local Vector lWorldCenter;
	
	//Constants and globals
    lGameInfo = xcGEO_GameInfo(WorldInfo.Game);
	lVehicle = X_COM_Vehicle_AirVehicle(Pawn);
	lWorldCenter = class'X_COM_Settings'.default.GEO_WorldCenter;


	//         <--    
	// D    P    C
	//  \   |   /
	//   \  |  /
	//    \ | /
	//     \|/
    //-A-
	// This is a view from the top
	// (-A-)ircraft - is the aircraft
	// (C)urrent  - his actual movement direction
	// (D)esired  - is the direction of destination
	// (P)ossible - it is the angle the aircraft is possible 
	//              to turn at this step from the current position

	lCurrentDirection = Normal(Vector(lVehicle.Rotation));              //Current vehicle direction

	//Angle between C and D
	lNeedTurnAngle = Acos(lCurrentDirection Dot DesiredOrientationX);

	//>oO Debug lGameInfo.DisplayHudDebug("lNeedTurnAngle", string((lNeedTurnAngle * 180)/3.14));

	//lTurnAngle - is an angle we will turn our vehicle
	lTurnAngle = lNeedTurnAngle; 
		
	//Now we chek, that we can turn on this angle on this step,  
	//or we have to turn only on some allowed angle
	lScaledMaxTurnAngle = lVehicle.MaxTurnAngle * lGameInfo.GetGameSpeed();
	if(lNeedTurnAngle > lScaledMaxTurnAngle) lTurnAngle = lScaledMaxTurnAngle;  

    //At this point we know value of horizontal angle we must turn the vehicle
	//But The problem now is a sign of this lTurnAngle. 
	//Lets check maybe the angle to turn it too small and we can skip the sign calculations?
	if(lTurnAngle > 0.01) //0.01 rad is 0.57 deg
	{	
		//The solution of the problem is not so cute, it is brute! so you can rewrite it in the future
		//we will do 2 turns and see where the result vector is closed to desired vector
		lDestination1 = lCurrentDirection >> QuatToRotator(QuatFromAxisAndAngle(DesiredOrientationZ, lTurnAngle));
		lDestination2 = lCurrentDirection >> QuatToRotator(QuatFromAxisAndAngle(DesiredOrientationZ, -lTurnAngle));
		if(VSizeSq(lDestination1-DesiredOrientationX) < VSizeSq(lDestination2-DesiredOrientationX))
		{
			lResultDirection = lDestination1;
			lVehicle.TurnDirection = Pawn.Location + Normal(lCurrentDirection >> QuatToRotator(QuatFromAxisAndAngle(DesiredOrientationZ, 2*lTurnAngle)))*100;
		}
		else
		{
			lResultDirection = lDestination2;
			lVehicle.TurnDirection = Pawn.Location + Normal(lCurrentDirection >> QuatToRotator(QuatFromAxisAndAngle(DesiredOrientationZ, -2*lTurnAngle)))*100;
		}
	}
	else
	{
		//The angle is too small, we will not turn this time, 
		//we will flight forward untill the turn andgle will be enough to turn somethins
		lResultDirection = lCurrentDirection;
		lVehicle.TurnDirection.X = 0;
		lVehicle.TurnDirection.Y = 0;
		lVehicle.TurnDirection.Z = 0;
	}
	lVehicle.DestinationDirection = Pawn.Location + Normal(DesiredOrientationX)*100;

	//In case of vehicle inclination will be in future we add objZ = Normal(Pawn.Location - lWorldCenter) >> QuatToRotator(QuatFromAxisAndAngle(lResultDirection, lVehicle.InclinationAngle))
	//but now there is no inclination, so we juct
	objZ = Normal(Pawn.Location - lWorldCenter);
	objY = Normal(objZ Cross lResultDirection);
	objX = Normal(objY Cross objZ);
	lVehicle.Direction = objX;

	//Set the new orientation of vehicle
	Pawn.SetRotation(OrthoRotation (objX, objY, objZ));
}


/**
 * Function relates to @see ProcessMovementStep. Process shift of the vehicle to new location 
 * 
 */
private function ProcessVehicleShift(float aDistanceToTarget, vector aDirection)
{
	local float lMoveDistance;       //Distance to move on this turn (based on gave speed, etc.)
	local X_COM_Vehicle_AirVehicle lVehicle; //Corresponding air vehicle

	lVehicle = X_COM_Vehicle_AirVehicle(Pawn);

	//(!) since the movement is done by small dX, we approximate the arc movement is the same as linear movement

	// The distance we will move the ship at this step. Based on game speed
	lMoveDistance = (lVehicle.AirSpeed/3600) * xcGEO_GameInfo(WorldInfo.Game).GetGameSpeed();
	if(aDistanceToTarget < lMoveDistance) lMoveDistance = aDistanceToTarget;

	//Set the new position of vehicle
	lVehicle.SetLocation(Normal(Pawn.Location + aDirection*lMoveDistance)* class'X_COM_Settings'.default.GEO_FlyingDistanceFromPlanet);
}

//=============================================================================
// Default Properties
//=============================================================================
defaultproperties
{
	DestinationReachedDistance = 50;
}
