import flash.external.ExternalInterface;

class script.XCOM_BTN_Base extends MovieClip
{
	private var bMouseLeftPressed:Boolean  = false;
	private var bMouseRightPressed:Boolean = false;
	private var bMouseMiddlePressed:Boolean = false;

	private function onPress():Void
	{
		ExternalInterface.call("BTN_Pressed", _name);
	};
	private function onRelease():Void
	{
		ExternalInterface.call("BTN_Released", _name);
	};
	private function onRollOver():Void
	{
		ExternalInterface.call("BTN_RollOver", _name);
	};
	private function onRollOut():Void 
	{
		ExternalInterface.call("BTN_RollOut", _name);
	};

	private function MouseDown(button):Void
  	{
		if (button == 1) bMouseLeftPressed = true;
			else if (button == 2) bMouseRightPressed = true;
				else if (button == 3) bMouseMiddlePressed = true;
  	};
  	private function MouseUp(button):Void
  	{
	  	bMouseLeftPressed = false;
	  	bMouseRightPressed = false;
		bMouseMiddlePressed = false;
  	};
}