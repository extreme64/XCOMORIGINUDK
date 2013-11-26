class script.inventory.inv_stock_persons extends MovieClip
{
    public var slider:MovieClip;
	
	public var persons:Array;
	
	private var text_name:TextField;
	
	private var PosX:Number;

	public function inv_stock_persons()
	{
	    slider = this._parent.attachMovie("slider", "slider", this._parent.getNextHighestDepth(), {_x:_x, _y:_y+34});
										
		PosX = this._x-this._width/2-20;
		
		persons = new Array();
	}

	public function AddPerson(person:String, params:Array):Void
	{
	    PosX += 48;
	
	    var temp:MovieClip = this._parent.attachMovie("slot_person", person, this._parent.getNextHighestDepth(), {_x:PosX, _y:_y-9});
	    temp.gotoAndStop(person);
		temp._xscale = 75;
		temp.AddStat(params);
		persons.push(temp);
		
		for (var i in temp)
		{
		    if (typeof(temp[i]) == 'movieclip')
			{
		        temp[i]._y = -10;
				temp[i]._yscale = 75;
			}
		}

		text_name = temp.createTextField("name", temp.getNextHighestDepth(), -22, 9, 45, 35);

		var format:TextFormat = new TextFormat();
        format.color = 0xFFFFFF;
	    format.font = "Arial";
		format.size = 10;
		format.align = "center";
		text_name.text = person;
		text_name.selectable = false;
		text_name.multiline = true;
		text_name.wordWrap = true;
		text_name._yscale = 85;
		text_name.setTextFormat(format);
		
		Update();
    }
	
	public function RemovePerson(person:String):Void
	{
	    for (var p in persons)
		{
		    if (persons[p]._name == person)
			{
			    persons.splice(p, 1);
				
			    for (var i=p; i<persons.length; i++)
				{
				    persons[i]._x -= 48;
				}
			}
		}
		
		for (var mc in this._parent) if (this._parent[mc]._name == person) this._parent[mc].removeMovieClip();

	    Update();
	}
	
	private function Update():Void
	{
	    for (var i in persons)
		{
		    if (persons[i]._x > this._x+this._width/2) persons[i]._visible = false;
			else persons[i]._visible = true;
		}
	}
}



