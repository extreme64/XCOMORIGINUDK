import flash.filters.GlowFilter;
import flash.external.ExternalInterface;

import script.inventory.inv_item_ammo;
import script.inventory.inv_item_grenade;
import script.inventory.inv_item_flakcanon;
import script.inventory.inv_item_weapon;
import script.inventory.inv_item_plasmapistol;
import script.inventory.inv_item_chainsword;

class script.inventory.inv_person extends MovieClip
{ 
    private var bOnFocus:Boolean = false;
	private var bIsSelected:Boolean = false;
	private var bIsTimed:Boolean = false;
	private var bIsValid:Boolean = true;

    private var Glow:GlowFilter;
	
	public var slots:Array;
	private var params:Array;
	
	private var timer:Number;

	public function inv_person()
	{
	    stop();
		Glow = new GlowFilter(0xFFFFFF, 1, 16, 16, 1, 5, true, false);
		timer = 0;
		
		slots = new Array();
		
		for (var i=0; i<23; i++)
		{
		    var temp:MovieClip;
			
			slots.push(temp = this.attachMovie("slot_32", "slot"+i, this.getNextHighestDepth()));
	        temp._visible = false;

			if (i < 9) slots[i].TYPE = 2;
			else if (i > 9 && i < 20) slots[i].TYPE = 3;
			else if (i > 19 && i < 22) slots[i].TYPE = slots[i].subtype = 1;
			else if (i == 22) {slots[i].TYPE = 1; slots[i].subtype = 3;}
		}
	}
	
	public function AddStat(stats:Array):Void
	{
	    params = stats;
	}
	
	private function onRollOver()
	{
	    if (bIsValid) {bOnFocus = true; this.filters = [Glow];}
		this._parent.ShowStat(this, params);
	}
	private function onRollOut()
	{
	    bOnFocus = false;
		this.filters = [];
		
		if (this._parent.selected != this) this._parent.params.HideStat();
		else this._parent.ShowStat(this, params);
	}

	private function onMouseUp()
	{
	    if (bOnFocus)
		{
		    if (!bIsSelected)
			{
			    var temp:Array = this._parent.Stat.persons;
				
				if (this._parent.selected != null && this._parent.selected != undefined)
				{
					this._parent.selected = null;
				}
				
				this._parent.selected = this;
				
			    for (var i in temp)
				{
				    temp[i].bIsSelected = false;
					temp[i].filters = [];
				}
				
				for (var i in this._parent.slots)
				{
				    if (this._parent.slots[i].TYPE > 0)  this._parent.slots[i].ShowSlot(false);
				    this._parent.slots[i].ShowSlot(true);
				}
				bIsSelected = true;
				
				ExternalInterface.call("GetPerson", this._name);
			}
			else
			{
			    this._parent.params.HideStat();
			    for (var i in this._parent.slots)
				    if (this._parent.slots[i].TYPE > 0)  this._parent.slots[i].ShowSlot(false);
				bIsSelected = false;
				this._parent.selected = null;
				
				for (var s in this._parent)
				{
				    if (this._parent[s]._name == "statistic"
					    && !this._parent[s].bOnFocus
						&& this._parent[s] != this._parent.selected)
						   this._parent.params.HideStat();
				}
			}
		}
	}
	
	private function onEnterFrame()
	{
	    if (bIsSelected)
		{
		    if (timer < 10 && !bIsTimed) {timer++; this.filters = [Glow];}
			else if (bIsTimed && timer > 0) {timer--; this.filters = [];}
			else if (timer == 10) bIsTimed = true;
			else if (timer == 0) bIsTimed = false;
		}
	}

	public function SaveData(slot:MovieClip, item:MovieClip):Void
	{
	    for (var i in slots)
		{
		    if (slots[i]._name == slot._name)
			{
			    slots[i].AddItem(item._name);
			}
		}
	}
	
	public function AddData(item:String, id:Number, quant:Number, slot:Number):Void
	{
		var bAdded:Boolean = false;
		var k:Number;
	
		for (var i in slots)
		{
		    if (!bAdded && (slots[i].child == null || slots[i].child._name == item))
			{
			    var Item;
				
				switch(item)
				{
				    case "item_ammo": Item = new inv_item_ammo(); break;
					case "item_grenade": Item = new inv_item_grenade(); break;
					case "item_flakcanon": Item = new inv_item_flakcanon(); break;
					case "item_weapon": Item = new inv_item_weapon(); break;
					case "item_plasmapistol": Item = new inv_item_plasmapistol(); break;
					case "item_chainsword": Item = new inv_item_chainsword(); break;
				}
				
				Item.id = id;
				
				if (slot != null && slot != undefined) k = slot;
				else k = i;
				
				if (Item.CheckType(slots[k]))
				{
				    if (Item.subtype == 1 && slots[20].child == null)
					{
			            slots[20].AddMultipleItem(item, 1);
				        bAdded = true;
					}
					else if (Item.subtype == 2)
					{
					    if (slots[20].child == null)
						{
			                slots[k].AddMultipleItem(item, 1);
				            bAdded = true;
						}
						else if (slots[20].child.subtype == 2 && slots[21].child == null)
						{
			                slots[21].AddMultipleItem(item, 1);
				            bAdded = true;
						}
					}
					else
					{
			            slots[k].AddMultipleItem(item, quant);
				        bAdded = true;
					}
				}
			}
			else ExternalInterface.call("AccessDenied", item, Item.id);
		}
	}
	
	public function ClearData(slot:MovieClip):Void
	{
	    var temp:MovieClip;
	
	    for (var i in slots)
		{
		    if (slots[i]._name == slot._name)
			{
			    temp = slots[i].Items.shift();
				slots[i].Update();
			}
		}
	}
	
	public function LoadData(slot:MovieClip):Void
	{
		for (var i in slots)
		{
		    if (slot._name == slots[i]._name)
			{
			    if (slots[i].child != null)
				{
			        for (var n=0; n<slots[i].Items.length; n++) slot.AddItem(slots[i].child._name);
				}
			}
		}
	}
}



