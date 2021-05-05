package;

import flixel.addons.nape.FlxNapeSprite;

class Planet extends FlxNapeSprite
{
	public var radius:Int;

	override public function new(x:Float, y:Float, r:Int)
	{
		super(x, y);
		radius = r;
	}
}
