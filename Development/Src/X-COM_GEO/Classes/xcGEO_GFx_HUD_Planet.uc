/**
 * X-COM planet HUD class
 */
class xcGEO_GFx_HUD_Planet extends X_COM_GFx_Menu;

//=============================================================================
// Functions: Buttons
//=============================================================================
protected function BTN_Released(string aButtonName)
{
	super.BTN_Released(aButtonName);

	switch (aButtonName)
	{
		case "btn_f1"       :	xcGEO_PlayerController(myPlayerController).CreateNewBase();
		break;

		case "btn_f2"       :   xcGEO_PlayerController(myPlayerController).ShowInterceptors();
		break;

		case "btn_f3"	    :   xcGEO_PlayerController(myPlayerController).InterceptorsFire();
		break;


		case "btn_time_1d"	    :       xcGEO_PlayerController(myPlayerController).TimeChange_1h();
										new_time(myGameInfo.Worldinfo.TimeSeconds, xcGEO_gameinfo(myGameInfo).GetGameSpeed(), aButtonName);
		break;

		case "btn_time_1h"	    :       xcGEO_PlayerController(myPlayerController).TimeChange_1m();
										new_time(myGameInfo.Worldinfo.TimeSeconds, xcGEO_gameinfo(myGameInfo).GetGameSpeed(), aButtonName);
		break;

		case "btn_time_1m"	    :       xcGEO_PlayerController(myPlayerController).TimeChange_1s();
										new_time(myGameInfo.Worldinfo.TimeSeconds, xcGEO_gameinfo(myGameInfo).GetGameSpeed(), aButtonName);
		break;

		case "btn_time_1s"	    :       xcGEO_PlayerController(myPlayerController).TimeChange_Pause();
										new_time(myGameInfo.Worldinfo.TimeSeconds, xcGEO_gameinfo(myGameInfo).GetGameSpeed(), aButtonName);
		break;

		default:
		break;
	}
}

//=============================================================================
// Functions: ActionScript functions calls
//=============================================================================
public function AddNewEvent(String aNewEvent)
{
     //ActionScriptVoid("AddNewEvent");
}

private function new_time(float aNewTime, int aGameSpeed, string aButtonName)
{
     ActionScriptVoid("new_time");
}

//=============================================================================
// Default Properties:
//=============================================================================
DefaultProperties
{
	MovieInfo = SwfMovie'X-COM_UI.GEO_Planet'
}