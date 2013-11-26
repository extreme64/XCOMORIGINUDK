class X_COM_PlayerInput extends PlayerInput within X_COM_PlayerController;;

exec function XC_ShowMainMenu()
{
	if (X_COM_HUD(myHUD) != none) X_COM_HUD(myHUD).ShowMainMenu(); // ESC
}

exec function XC_SelectNextUnit()
{
	SelectNextUnit();
}

exec function XC_MouseScrollUp()
{
	ZoomIn();
}

exec function XC_MouseScrollDown()
{
	ZoomOut();
}


exec function XC_LeftMouseClick(bool Pressed)
{
	//TODO fix this code
	if(Pressed)
	{
		//xcPC.StartFire(0);
		LeftMousePressed();
	}
	else
	{
		LeftMouseReleased();
		//xcPC.StopFire(0);
	}
}

exec function XC_RightMouseClick(bool Pressed)
{
	if(Pressed)
	{
		//xcPC.StartAltFire(0);
		RightMousePressed();
	}
	else
	{
		//xcPC.StopAltFire(0);
		RightMouseReleased();
	}
}

exec function XC_MiddleMouseClick(bool Pressed)
{
	if(Pressed)
	{
		//xcPC.StartAltFire(0);
		MiddleMousePressed();
	}
	else
	{
		//xcPC.StopAltFire(0);
		MiddleMouseReleased();
	}
}

/** Нажатие кнопки SPACE */
exec function XC_SpaceBar()
{
	SpaceBar(); // Снять выделение с выбраного персонажа
}


DefaultProperties
{
}