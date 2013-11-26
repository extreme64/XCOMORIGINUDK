import flash.filters.GlowFilter;
import flash.filters.DropShadowFilter
import flash.external.ExternalInterface;

class script.inventory.inv_controller extends MovieClip
{
	public var Temp:MovieClip;
	public var Manual:MovieClip;
	private var params:MovieClip;
	public var Stat:MovieClip;
	public var selected:MovieClip;
	
	public var slots:Array = new Array();
	
	private var slot_X:Number = 500;
	private var slot_Y:Number = 330;
	private var belt_X:Number = 460;
	private var belt_Y:Number = 500;
	private var leg_X:Number = 470;
	private var leg_Y:Number = 560;
	private var arm_Y:Number = 236;
	private var stock_Y:Number = 640;
	private var stockID:Number = 29;
	
	private var quantity:Number = 0;
	
	private var Glow:GlowFilter;
	private var Shadow:DropShadowFilter;
	
	private var stat_lev:TextField;
	private var stat_exp:MovieClip;
	private var stat_hp:MovieClip;
	private var stat_mp:MovieClip;
	private var stat_acc:MovieClip;
	
	private var text_info:TextField;
	private var text_name:TextField;
	
	public var bDrag:Boolean = false;

	public function inv_controller()
	{
	    CreateStatistic();
		
		AddPerson("makaron marihuanovich", [0, 20, 100, 100, 50]);
		AddPerson("prosto ivan", [1, 20, 100, 100, 50]);
		AddPerson("juriy nikolaevich", [0, 33, 100, 50, 85]);
		AddPerson("homer simpson", [0, 25, 75, 100, 38]);
		AddPerson("spanch bob", [10, 20, 100, 100, 12]);
		AddPerson("terminator", [30, 100, 40, 100, 50]);
		AddPerson("cyrex", [44, 20, 100, 60, 50]);
		AddPerson("silvester stallone", [0, 20, 100, 100, 68]);
		AddPerson("predator", [11, 60, 100, 20, 70]);
		AddPerson("space marine", [0, 20, 100, 100, 100]);
		AddPerson("bender", [0, 0, 11, 100, 50]);
		AddPerson("mr hate", [7, 20, 100, 100, 20]);
		
		CreateStock();
		
		AddToStock("item_weapon", 2);
		AddToStock("item_plasmapistol", 1);
		AddToStock("item_chainsword", 3);
		AddToStock("item_flakcanon", 1);
		AddToStock("item_ammo", 10);
		AddToStock("item_grenade", 5);

		text_info = this._parent.createTextField("info", this._parent.getNextHighestDepth(), _xmouse, _ymouse, 200, 20);
	    Shadow = new DropShadowFilter(2, 45, 0x000000, 1, 0, 0, 1, 3, false, false, false);
	}
	
	public function CreateStock():Void
    {
	    for (var i=0; i<30; i++)
		{
			if (i < 9)
			{
				slot_X += 32;
				
				if (slot_X > 596) {slot_X -= 96; slot_Y += 32;}
				
				slots.push(Temp = this.attachMovie("slot_32", "slot"+i, this.getNextHighestDepth(), {_x:slot_X, _y:slot_Y}));
			    Temp.TYPE = 2;
				Temp._visible = false;
			}
			else if (i > 9 && i < 16)
			{
				belt_X += 32;
				
				slots.push(Temp = this.attachMovie("slot_32", "slot"+i, this.getNextHighestDepth(), {_x:belt_X, _y:belt_Y}));
			    Temp.TYPE = 3;
				Temp._visible = false;
			}
			else if (i > 15 && i < 20)
			{
				leg_X += 32;
				
				if (leg_X == 566) leg_X += 32;
				 
				slots.push(Temp = this.attachMovie("slot_32", "slot"+i, this.getNextHighestDepth(), {_x:leg_X, _y:leg_Y}));
			    Temp.TYPE = 3;
				Temp._visible = false;
			}
			else if (i > 19 && i < 22)
			{
				arm_Y += 64;
				
				if (arm_Y == 364) arm_Y += 32;
				
				slots.push(Temp = this.attachMovie("slot_64", "slot"+i, this.getNextHighestDepth(), {_x:768, _y:arm_Y}));
			    Temp.TYPE = 1;
				Temp._visible = false;
				Temp.subtype = 1;
			}
			else if (i == 22)
			{
				slots.push(Temp = this.attachMovie("slot_64", "slot"+i, this.getNextHighestDepth(), {_x:380, _y:300}));
			    Temp.TYPE = 1;
				Temp._visible = false;
				Temp.subtype = 3;
			}
		    else if (i > 22)
		    {
			    stock_Y -= 64;
				
			    slots.push(Temp = this.attachMovie("slot_64", "slot"+i, this.getNextHighestDepth(), {_x:1040, _y:stock_Y}));
			    Temp.TYPE = 0;
			}
		}
	}
	
	public function DisplayStock(flag:Boolean):Void
    {
	    var s:MovieClip;
	
	    for (s in slots) if (slots[s].TYPE == 0)
		{
		    slots[s]._visible = flag;
			for (var i in slots[s].Items) slots[s].Items[i]._visible = flag;
			slots[s].text_number._visible = flag;
			slots[s].text_info._visible = flag;
		}
	}
	
	public function AddToStock(item, quantity):Void
    {
		if (!slots[stockID].child == null) stockID += 0;
		else stockID -= 1;
		
		for (var i=0; i<quantity; i++) slots[stockID].AddItem(item);
		
		Temp = null;
	}
	public function AddToInventory(person, item, id, quantity, slot):Void
    {
	    for (var p in Stat.persons)
		{
		    if (Stat.persons[p]._name == person) Stat.persons[p].AddData(item, id, quantity, slot);
		}
	}
	public function AddManually(person, item, id, quant):Void
    {
		DisplayInventory(true, person);
		
		Manual = attachMovie(item, "manual", getNextHighestDepth(), {_x:_xmouse, _y:_ymouse});
		Manual._name = item;
		Manual.id = id;
		
		quantity = quant;
		
		Temp = Manual;
		Temp.Update();
		
		bDrag = true;
	}
	public function AddPerson(person, stats):Void {Stat.AddPerson(person, stats);}
	public function AddStat(person, stats):Void
    {
		for (var p in Stat.persons)
		{
		    if (Stat.persons[p]._name == person) Stat.persons[p].AddStat(stats);
		}
	}
	public function RemovePerson(person):Void {Stat.RemovePerson(person);}
	
	public function ShowValidSlots(show:Boolean):Void
	{
	    if (Temp.subtype == 1)
		{
		    slots[21].bIsValid = false;
		    slots[20].bIsValid = false;
			if (slots[19].Items.length == 1 || slots[20].child != null) slots[19].bIsValid = false;
			else slots[19].bIsValid = true;
		}
	    else if (Temp.subtype == 2)
		{
		    slots[21].bIsValid = false;
		    if (slots[20].Items.length == 1) slots[20].bIsValid = false;
			else slots[20].bIsValid = true;
			if (slots[19].Items.length == 1) slots[19].bIsValid = false;
			else slots[19].bIsValid = true;
		}
		else if (Temp.subtype == 3)
		{
		    if (slots[21].Items.length == 1) slots[21].bIsValid = false;
			else slots[21].bIsValid = true;
		    slots[20].bIsValid = false;
			slots[19].bIsValid = false;
		}

	    for (var slot in slots)
        {
		    if (show)
			{
		        if (Temp.CheckType(slots[slot]) && slots[slot].bIsValid)
			    {
				    Glow = new GlowFilter(0xFFFFFF, 1, 16, 16, 1, 5, true, false)
					slots[slot].GlowTemp = Glow;
		        }
			    else
			    {
			    	Glow = new GlowFilter(0xFF0000, 1, 16, 16, 1, 5, true, false)
			    	slots[slot].GlowTemp = Glow;
			    }
			}
			else slots[slot].filters = [];
		}
	}
	
	private function CreateStatistic():Void
    {
	    Stat = this.attachMovie("stock_persons", "stock_persons", this.getNextHighestDepth(), {_x:268, _y:68});
	}
	
	public function DisplayStatistic(flag:Boolean):Void
    {
	    Stat.slider._visible = flag;
	    Stat._visible = flag;
	}
	
	private function ShowStat(person:MovieClip, stats:Array):Void
    {
	    params = this.attachMovie("statistic", "statistic", this.getNextHighestDepth(), {_x:Stat._x-Stat._width/2, _y:Stat._y+Stat._height/2+4});
        params.HideStat = function() {this.removeMovieClip();}
	
		var pers:MovieClip = params.attachMovie("slot_person", person._name, params.getNextHighestDepth(), {_x:48, _y:68});
	    pers.gotoAndStop(person._name);
		pers.bIsValid = false;

		stat_exp = params.attachMovie("mc_exp", "exp", params.getNextHighestDepth(), {_x:48, _y:114});
        stat_exp._xscale = stats[1];
		
		stat_hp = params.attachMovie("mc_hp", "hp", params.getNextHighestDepth(), {_x:48, _y:134});
		stat_hp._xscale = stats[2];							   

		stat_mp = params.attachMovie("mc_mp", "mp", params.getNextHighestDepth(), {_x:48, _y:154});
		stat_mp._xscale = stats[3];							   
  
		stat_acc = params.attachMovie("mc_acc", "acc", params.getNextHighestDepth(), {_x:48, _y:174});
		stat_acc._xscale = stats[4];	

        stat_lev = params.createTextField("lev", params.getNextHighestDepth(), 70, 56, 100, 40);
		text_name = params.createTextField("name", params.getNextHighestDepth(), 4, 0, 150, 60);
		
		var format:TextFormat = new TextFormat();									
		format.color = 0xFFFFFF;
	    format.font = "Arial";
		format.bold = true;
		format.size = 14;
		format.align = "center";
		
        stat_lev.text = String("level "+stats[0]);
	    stat_lev.setTextFormat(format);
		stat_lev.selectable = false;
		stat_lev.wordWrap = true;
		
		text_name.text = pers._name;
	    text_name.setTextFormat(format);
		text_name.selectable = false;
		text_name.wordWrap = true;
		text_name.multiline = true;
	}
	
	public function ShowItemInfo(slot:MovieClip):Void
	{
	    text_info.selectable = false;
		text_info.swapDepths(this._parent.getNextHighestDepth());

		if (slot.Items != null && slot.Items.length > 0)
		{
			var format:TextFormat = new TextFormat();
            format.color = 0xFFFFFF;
			format.font = "Arial";
			format.align = "center";
            text_info.text = String(slot.child.info);
			text_info.setTextFormat(format);
		    text_info.wordWrap = true;
			text_info.filters = [Shadow];
		}
	}
	public function HideInfo():Void {text_info.text = "";}
	
	private function onEnterFrame()
	{
	    if (text_info.text != "")
		{
	        text_info._x = _xmouse-100;
	        text_info._y = _ymouse-16;
		}
		
		if (bDrag) Manual.CurSlot();
	}
	
	public function DisplayInventory(flag:Boolean, person:String):Void
	{
	    var s:MovieClip;
	    var p:MovieClip;
	
	    for (p in Stat.persons)
		{
		    if (Stat.persons[p]._name == person)
			{
			    if (flag) selected = Stat.persons[p];
			    else selected = null;
				Stat.persons[p].bIsSelected = flag;
			}
		}
	
	    for (s in slots)
		{
			if (slots[s].TYPE > 0) slots[s].ShowSlot(flag);
			slots[s].ShowSlot(true);
		}
	}
	
	private function onMouseUp()
	{
	    if (bDrag)
		{
		    var slot = Manual.CheckSlot();
			
			if (slot != null && Manual.CheckType(slot)
				&& (slot.child == undefined || slot.child == null || slot.child == Manual)
				&& slot.bIsValid && slot._visible)
			{
			    for (var q=quantity; q>=1; q--)
				{
			        slot.AddItem(Manual._name);
			        selected.SaveData(slot, Manual);
				}
				
			    Manual.Destroy();
			    Manual = null;
			    bDrag = false;
			    ShowValidSlots(false);
			}
		}
	}
}




