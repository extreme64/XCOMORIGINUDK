class xcT_GFx_MiniMap extends X_COM_GFx_Menu;

protected function BTN_Released(string aButtonName)
{
	super.BTN_Released(aButtonName);

	switch (aButtonName)
	{
		case "BTN_MiniMap"       :	    xcT_PlayerController(myPlayerController).CameraChangeLocationInMinimap(); // ����� �������� ����� �������� ���������� ����� �� ������
		break;

		default:
		break;
	}
}

function UpdateMiniMap(Texture aNewTexture)
{
	SetExternalTexture("minimap", aNewTexture);
}

DefaultProperties
{
	MovieInfo = SwfMovie'X-COM_UI.Tactics_MiniMap'
}
