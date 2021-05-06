package;

import flixel.addons.nape.FlxNapeSprite;

class PlanetObject extends FlxNapeSprite
{
	private var onPlanet:FlxNapeSprite;

	override public function new(x:Float, y:Float, onPlanetR:Planet)
	{
		super(x, y);

		onPlanet = onPlanetR;
	}

	public function setOnPlanet(oP:Planet)
	{
		if (oP == onPlanet)
			return;

		onPlanet = oP;
	}
}
