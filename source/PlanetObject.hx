package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;

class PlanetObject extends FlxNapeSprite
{
	public var onPlanet:Planet;

	override public function new(x:Float, y:Float)
	{
		super(x, y);
	}
}
