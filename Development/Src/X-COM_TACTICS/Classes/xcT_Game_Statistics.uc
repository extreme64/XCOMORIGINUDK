/**
 * Статистика тактического боя
 */
class xcT_Game_Statistics extends Object
	config (XComSettings);

//=============================================================================
// Constant score costs
//=============================================================================
var config int Killed_Alien;
var config int Killed_Human;
var config int Killed_Civilian;

var config int Live_AlienSoldier;
var config int Live_AlienCommander;
var config int Live_Civilian;

var config int Rating_Awful;
var config int Rating_Bad;
var config int Rating_Normal;
var config int Rating_Good;
var config int Rating_Excelent;

//=============================================================================
// Variables Stats
//=============================================================================
var private int MissionStartTime;

var private int AliensKilled;
var private int HumansKilled;
var private int CivilianKilled;

var private int AliveAlienSoldiersCatched;
var private int AliveAlienCommanderCatched;

var private int AlienArtefactsGathered;

//=============================================================================
// Functions Stats: Elements getters
//=============================================================================
public function int Get_MissionStartTime()
{
	return MissionStartTime;
}



public function int Get_AliensKilled()
{
	return AliensKilled;
}

public function int Get_HumansKilled()
{
	return HumansKilled;
}

public function int Get_CivilianKilled()
{
	return CivilianKilled;
}



public function int Get_AliensScore()
{
	return AliensKilled*Killed_Alien;
}

public function int Get_HumansScore()
{
	return  HumansKilled*Killed_Human;
}

public function int Get_CiviliansScore()
{
	return CivilianKilled*Killed_Civilian;
}



public function int Get_AliveAlienSoldiersCatched()
{
	return AliveAlienSoldiersCatched;
}

public function int Get_AliveAlienCommanderCatched()
{
	return AliveAlienCommanderCatched;
}

//=============================================================================
// Functions Stats: Elements setters
//=============================================================================
public function Set_MissionStartTime(float aNewTime)
{
	MissionStartTime = aNewTime;
}



public function Increase_AliensKilled()
{
	AliensKilled++;
}

public function Increase_HumansKilled()
{
	HumansKilled++;
}

public function Increase_CivilianKilled()
{
	CivilianKilled++;
}



public function Increase_AliveAlienSoldiersCatched()
{
	AliveAlienSoldiersCatched++;
}

public function Increase_AliveAlienCommanderCatched()
{
	AliveAlienCommanderCatched++;
}

//=============================================================================
// Functions Stats: Results
//=============================================================================
public function Get_Result_Rating_and_Score(EMissionType aMissionType, out string ResultRating, out int ResultScore)
{
	ResultScore = Get_AliensScore() + Get_HumansScore() + AliveAlienSoldiersCatched*Live_AlienSoldier + AliveAlienCommanderCatched*Live_AlienCommander;
	switch (aMissionType)
	{
		case UfoCrash:
		break;

		case Terror:    ResultScore += Get_CiviliansScore(); // + Live_Civilian;
		break;

		case UFOBase:
		break;

		case XcomBase:
		break;

		Default:
		break;
	}

	// TODO should be get from localz DB with like some enum: ResultRating = DBmgr.getrating(Ebad)

	if (ResultScore < -100) ResultRating = "very shit";
	else if (ResultScore < 100) ResultRating = "bad";
			else if (ResultScore < 200) ResultRating = "good"; 
					else ResultRating = "excelent"; 
}

//=============================================================================
// Default properties
//=============================================================================
defaultproperties
{
}