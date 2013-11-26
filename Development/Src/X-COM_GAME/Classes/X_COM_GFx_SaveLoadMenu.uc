/**
 * X-COM save|load menu class
 */
class X_COM_GFx_SaveLoadMenu extends X_COM_GFx_Menu;
/*
//=============================================================================
// Variables: 
//=============================================================================
/** Menu buttons */
var GFxClikWidget               MenuBtn_SaveLoad,
								MenuBtn_DeleteSave,
								MenuBtn_Cancel;
/** Menu objects */
var GFxObject					MenuObj_FileList,  
								MenuObj_InputTextField;

var private MenuButtonsType     ButtonsType; // Menu buttons type. Menu will be use save menu buttons ot load menu buttons

//=============================================================================
// Functions:
//=============================================================================
/** Buttons type set */
function SetMenuButtonsType(MenuButtonsType aButtonsType)
{
	ButtonsType = aButtonsType;
}

/** Screen and buttons initialization  */
function InitUI(X_COM_GameInfo aGameInfo, optional LocalPlayer LocPlay)
{
	mGameInfo = aGameInfo;
	SetTimingMode(TM_Real);
	Start();
	TitleScreenMC = GetVariableObject("_root");
	Advance(0.f);

	MenuBtn_Cancel = GFxClikWidget(TitleScreenMC.GetObject("MenuBtn_Cancel", class'GFxClikWidget'));
	MenuBtn_Cancel.SetFloat("data", MenuButtonsType.MENU_BACKTOMAINMENU);
	MenuBtn_Cancel.SetString("label", "Cancel");

	MenuBtn_DeleteSave = GFxClikWidget(TitleScreenMC.GetObject("MenuBtn_DeleteSave", class'GFxClikWidget'));
	MenuBtn_DeleteSave.SetFloat("data", MenuButtonsType.MENU_DELETESAVE);
	MenuBtn_DeleteSave.SetString("label", "Delete");

	MenuObj_InputTextField = TitleScreenMC.GetObject("SaveLoadFileName", class'GFxObject');

	MenuBtn_SaveLoad = GFxClikWidget(TitleScreenMC.GetObject("MenuBtn_SaveLoad", class'GFxClikWidget'));

	switch (ButtonsType)
	{
		case(MENU_LOADGAME):
			MenuBtn_SaveLoad.SetFloat("data", MenuButtonsType.MENU_LOADGAME);
			MenuBtn_SaveLoad.SetString("label", "Load");
			MenuObj_InputTextField.SetBool("editable", false);
			MenuBtn_DeleteSave.SetBool("visible", false);
		break;

		case(MENU_SAVEGAME):		
			MenuBtn_SaveLoad.SetFloat("data", MenuButtonsType.MENU_SAVEGAME);
			MenuBtn_SaveLoad.SetString("label", "Save");
		break;

        default:
        break;
	}

	MenuBtn_SaveLoad.AddEventListener('CLIK_click', OnMenuButtonPress);
	MenuBtn_DeleteSave.AddEventListener('CLIK_click', OnMenuButtonPress);
	MenuBtn_Cancel.AddEventListener('CLIK_click', OnMenuButtonPress);

	GetAndSetSaveFilesList(); //load files list
}

/** Button click */ 
function OnMenuButtonPress(GFxClikWidget.EventData ev)
{
	Selection = byte(ev.target.GetFloat("data"));
    switch (Selection)
    {
        case(MENU_LOADGAME):

			if (mGameInfo.getSaveLoadMgr().LoadSavedGame(MenuObj_InputTextField.GetText())) Close();
        break;

        case(MENU_SAVEGAME):
			if (mGameInfo.getSaveLoadMgr().NewSaveGame(MenuObj_InputTextField.GetText())) Close();
        break;

		case(MENU_DELETESAVE):
			if (mGameInfo.getSaveLoadMgr().DeleteSaveFile(MenuObj_InputTextField.GetText()))
			{
				ClearSaveFilesList();
				GetAndSetSaveFilesList();
			}
			else mGameInfo.Broadcast(mGameInfo, "ERROR! Could not delete saved game");
		break;

		case(MENU_BACKTOMAINMENU):
			Close();
		break;

        default:
        break;
    }
}

/** Getting save files list from saved games DB */ 
function GetAndSetSaveFilesList()
{
	local int il;
	local array<string> lSaveFileNames, lSaveDates;

	if (!mGameInfo.getSaveLoadMgr().GetSavedGamesList(lSaveFileNames, lSaveDates)) // We get 2 arrays of names and dates
	{
		mGameInfo.Broadcast(mGameInfo, "ERROR! Could not get saved games list");
		return;
	}
	else
	{
		if (lSaveFileNames.Length != lSaveDates.Length)
		{
			mGameInfo.Broadcast(mGameInfo, "ERROR! Saved games list is wrong");
			return;
		}
		else
		{
			for (il=0; il<lSaveFileNames.Length; ++il)
			{
				UpdateSaveFilesList(lSaveFileNames[il], lSaveDates[il]); // Filling grid list in flash with items from arrays we got.
			}
		}
	}
}

//=============================================================================
// Functions: ActionScript functions calls
//=============================================================================
/** Update list of saved games */ 
function UpdateSaveFilesList(string SaveName, string SaveDate)
{
     ActionScriptVoid("UpdateSaveFilesList");
}

/** Clear list of saved games */ 
function ClearSaveFilesList()
{
	ActionScriptVoid("ClearSaveFilesList");
}
*/
//=============================================================================
// Default Properties:
//=============================================================================
DefaultProperties
{
	// The path to the swf asset
	MovieInfo = SwfMovie'X-COM_UI.SaveLoadMenu'
}