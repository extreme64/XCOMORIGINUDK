import flash.filters.GlowFilter;
import flash.external.ExternalInterface;

class script.inventory.inv_slot extends MovieClip
{
	public var TYPE:Number = 0;
	public var subtype:Number = 0;
	
	private var child:MovieClip;
	private var Temp:MovieClip;
	
	private var bOnFocus:Boolean = false;
	public var bIsValid:Boolean = true;
	private var bMousePress:Boolean = false;
	
	public var text_number:TextField;
	public var text_info:TextField;
	
	public var Items:Array;
	
	private var Glow:GlowFilter;
	public var GlowTemp:GlowFilter;

	public function inv_slot()
	{
		Glow = new GlowFilter(0xFFFFFF, 1, 16, 16, 1, 5, true, false);
	}
	
	private function Update():Void
	{
	    text_number.removeTextField();
	    text_number = this._parent.createTextField("num", this._parent.getNextHighestDepth(), _x-_width/2+2, _y-_height/2+2, 20, 20);
	    text_number.selectable = false;
	
		if (Items != null && Items.length > 1 && this._parent != _root.Controller.selected)
		{
			var format:TextFormat = new TextFormat();
            format.color = 0xFFFFFF;
			format.font = "Arial";
            text_number.text = String(Items.length);
			text_number.setTextFormat(format);
		}
		else text_number.text = "";
	}
	
	public function AddItem(item:String, id:Number):Void
	{
	    if (item != null)
		{
		    if (Items == null) Items = new Array();

			if (this._parent != _root.Controller.selected)
			{
			    child = this._parent.attachMovie(item, item, this._parent.getNextHighestDepth(), {_x:this._x, _y:this._y});
	        }
			else child = this.attachMovie(item, item, this.getNextHighestDepth(), {_x:0, _y:0});
			
			child.id = id;
			Items.push(child);
		    Update();
			ExternalInterface.call("AddItem", child._name, child.id);
			
			if (this == this._parent.slots[19] && child.subtype == 1)
			{
				this._parent.slots[20]._visible = false;
			}
			else if (this.TYPE == 0 && child.subtype == 1 && this._parent.selected != null)
			{
			    this._parent.slots[20]._visible = true;
			}
		}
	}

	private function GotItem():Void
	{
		this._parent.Temp = MovieClip(Items.shift());
		this._parent.Temp._name = child._name;
		this._parent.Temp.base = this;
		this._parent.Temp.Update();

		Update();
		ExternalInterface.call("RemoveItem", child._name, child.id);
		
		if (Items.length == 0)
		{
		    Temp = this._parent.attachMovie(this._parent.Temp._name, "clone", this._parent.getNextHighestDepth(), {_x:this._x, _y:this._y});
			Temp._alpha = 50;
		}
		
		this._parent.HideInfo();
	}
	
	private function ClearSlot():Void
	{
		FindChild().swapDepths(this._parent.getNextHighestDepth());
        FindChild().removeMovieClip();
		
		Items = null;
		child = null;
		Temp = null;
		
		Update();
	}
	
	private function FindChild():MovieClip
	{
	    for (var i in this) 
        {
	        if (typeof(this[i]) == 'movieclip') return this[i];
	    }
	}
	
	private function onRollOver()
	{
	    bOnFocus = true;
		this._parent.ShowItemInfo(this);
		if (Items.length > 0) this.filters = [Glow];
	}
	private function onRollOut()
	{
	    bOnFocus = false;
		this._parent.HideInfo();
		this.filters = [];
	}
	
	private function onMouseDown()
	{
		if (bOnFocus && !this._parent.bDrag)
		{
			GotItem();
			bOnFocus = false;
			bMousePress = true;
			
			this.onMouseUp = function()
			{
			    var temp:MovieClip = this._parent.Temp;
			    var slot = temp.CheckSlot();
				
				if (this == temp.base)
				{
			        if (slot != null && temp.CheckType(slot)
				        && (slot.child == undefined || slot.child == null || slot.child == temp)
						&& slot.bIsValid && slot._visible)
				    {
				        if (temp.base.Items.length == 0) temp.base.ClearSlot();
						this._parent.selected.SaveData(slot, temp);
						this._parent.selected.ClearData(temp.base);
			            slot.AddItem(temp._name);
				    }
					else if (slot == null || slot == undefined)
					{
					    if (temp.base.Items.length == 0) temp.base.ClearSlot();
						this._parent.selected.SaveData(slot, temp);
						this._parent.selected.ClearData(temp.base);
						this._parent.ShowValidSlots(false);
						ExternalInterface.call("DropItem", child._name, child.id);
					}
				    else
				    { 
					    if (Temp != null)
						{
					        Temp.swapDepths(this._parent.getNextHighestDepth());
                            Temp.removeMovieClip();
							Temp = null;
						}
				        this.AddItem(temp._name);
				    }
					
					temp.Destroy();
			        temp = null;
					bMousePress = false;
				}
			}
		}
		else return;
	}
	
	public function ShowSlot(flag:Boolean):Void
	{
		if (this == this._parent.slots[20] && this._parent.slots[19].Items > 0
		    && this._parent.slots[19].child.subtype == 1)
		{
		    this._visible = false;
		    Temp._visible = false;
		    text_number._visible = false;
		}
		else
		{
		    if (flag) this._parent.selected.LoadData(this);
		    else {for (var mc in Items) Items[mc]._visible = flag; ClearSlot();}
		
		    this._visible = flag;
		    Temp._visible = flag;
		    text_number._visible = flag;
		}
	}
	
	public function AddMultipleItem(item:String, quant:Number):Void
	{
	    if (Items == null) Items = new Array();
		
		child = this.attachMovie(item, item, this.getNextHighestDepth(), {_x:0, _y:0});
		
		for (var n=0; n<quant; n++)
		{
		    Items.push(child);
		    ExternalInterface.call("AddItem", child._name, child.id);
		}
	}
	
	private function onEnterFrame():Void
	{
	    if (bMousePress)
		{
		    var temp:MovieClip = this._parent.Temp;
			
		    temp.CurSlot();
		}
	}
	
	public function SetGlow(glow:GlowFilter):Void
	{
	    filters = [glow];
	}
}




