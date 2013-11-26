import flash.filters.GlowFilter;

class script.inventory.inv_item extends MovieClip
{
	public var TYPE:Number = 0;
	public var subtype:Number = 0;
	public var id:Number = 0;
	
	public var info:String = "item";
	
	public var base:MovieClip;
	
	private var Glow:GlowFilter;

	public function inv_item()
	{
	    Glow = new GlowFilter(0x00FF00, 1, 16, 16, 1, 5, true, false);
	}
	
	public function CheckType(target:MovieClip):Boolean
	{
		if (target.TYPE == 0) return true;
	    else if (TYPE == 1 && target.TYPE == 1) return true;
		else if (TYPE == 2 && (target.TYPE == 2 || target.TYPE == 3)) return true;
		else if (TYPE == 3 && target.TYPE == 3) return true;
		else return false;
	}
	
	public function Update():Void
	{
		_x = this._parent._xmouse;
		_y = this._parent._ymouse;
		startDrag(this);
		this.swapDepths(999);
		this._parent.ShowValidSlots(true);
	}
	
	public function Destroy():Void
	{
		base = null;
		this._parent.Temp = null;
		this.swapDepths(this._parent.getNextHighestDepth());
        this.removeMovieClip();	
		this._parent.ShowValidSlots(false);
	}
	
	public function CheckSlot():MovieClip
	{
	    var slots:Array = this._parent.slots;
	
	    for (var slot in slots)
        {
		    if (slots[slot].hitTest(this._parent._xmouse, this._parent._ymouse))
			    return slots[slot];
		}
		
		return null;
	}
	
	public function CurSlot():Void
	{
	    var slots:Array = this._parent.slots;
	
	    for (var slot in slots)
        {
		    if (slots[slot].hitTest(this._parent._xmouse, this._parent._ymouse) && CheckType(slots[slot])
                && slots[slot].bIsValid) slots[slot].SetGlow(Glow);
			else slots[slot].SetGlow(slots[slot].GlowTemp);
		}
	}
}


