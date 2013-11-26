import flash.filters.GlowFilter;

class script.inventory.inv_slider extends MovieClip
{
    private var Glow:GlowFilter;
	
	public var btn_left:MovieClip;
	public var btn_right:MovieClip;
	public var navigator:MovieClip;
	
	private var bOnFocus:Boolean = false;
	private var bOverLBTN:Boolean = false;
	private var bOverRBTN:Boolean = false;
	private var bOverNav:Boolean = false;
	private var bNavPushed:Boolean = false;
	private var bPushed:Boolean = false;

	public function inv_slider()
	{
	    Glow = new GlowFilter(0xFFFFFF, 1, 16, 16, 1, 5, true, false);
		navigator._x = btn_left._x+btn_left._width/2+navigator._x-navigator._width/2;
	}
	
	private function onEnterFrame()
	{
	    if (CheckBTN() && !bPushed) GlowElement(CheckBTN()); else GlowElement(null);
		
		if (bNavPushed)
		{
		    if (navigator._x-navigator._width/2 > btn_left._x+btn_left._width/2 &&
			    navigator._x+navigator._width/2 < btn_right._x-btn_right._width/2)
				navigator._x = _xmouse;
		}
		else if (navigator._x-navigator._width/2 <= btn_left._x+btn_left._width/2)
		         navigator._x = btn_left._x+btn_left._width/2+navigator._width/2+1;
		else if (navigator._x+navigator._width/2 >= btn_right._x-btn_right._width/2)
		         navigator._x = btn_right._x-btn_right._width/2-navigator._width/2-1;
	}
	
	private function CheckBTN():MovieClip
	{
	    if (btn_left.hitTest(this._parent._xmouse,
		                   this._parent._ymouse)) {bOverLBTN = true; return btn_left;}
		else if (btn_right.hitTest(this._parent._xmouse,
		                   this._parent._ymouse)) {bOverRBTN = true; return btn_right;}
		else if (navigator.hitTest(this._parent._xmouse,
		                   this._parent._ymouse)) {bOverNav = true; return navigator;}
		else
		{
		    bOverLBTN = false;
			bOverRBTN = false;
			bOverNav = false;
		    return null;
	    }
	}
	
	private function onRollOver() {bOnFocus = true; GlowThis(true);}
	private function onRollOut() {bOnFocus = false; GlowThis(false);}
	
	private function GlowThis(flag:Boolean):Void
	{
	    var GlowThis:GlowFilter = new GlowFilter(0xFFFFFF, 1, 8, 8, 0.5, 5, true, false);
	    if (flag) this.filters = [GlowThis];
		else this.filters = [];
	}
	private function GlowElement(element:MovieClip):Void
	{
	    for (var i in this) 
        {
	        if (this[i] != element) this[i].filters = [];
			else if (element != null) this[i].filters = [Glow];
	    }
	}
	
	private function onMouseDown()
	{
	    if (bOverNav) bNavPushed = true;
		bPushed = true;
	}
	private function onMouseUp()
	{
	    if (bOverLBTN) navigator._x -= 5;
		else if (bOverRBTN) navigator._x += 5;
		
		if (navigator._x-navigator._width/2 <= btn_left._x+btn_left._width/2)
		         navigator._x = btn_left._x+btn_left._width/2+navigator._width/2+1;
		else if (navigator._x+navigator._width/2 >= btn_right._x-btn_right._width/2)
		         navigator._x = btn_right._x-btn_right._width/2-navigator._width/2-1;
		
		if (bNavPushed) bNavPushed = false;
		
		bPushed = false;
	}
}


