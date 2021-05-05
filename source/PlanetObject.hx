package;

import flixel.addons.nape.FlxNapeSprite;

class PlanetObject extends FlxNapeSprite
{
	private var onPlanet:FlxNapeSprite;

	override public function new(x:Float, y:Float, onPlanetR:FlxNapeSprite)
	{
		super(x, y);

		onPlanet = onPlanetR;
	}

	public function setOnPlanet(oP:FlxNapeSprite)
	{
		onPlanet = oP;
	}
}
