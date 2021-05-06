package;

import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;

class PlanetObject extends FlxNapeSprite
{
	private var onPlanet:Planet;

	override public function new(x:Float, y:Float, onPlanetR:Planet)
	{
		super(x, y);

		onPlanet = onPlanetR;
	}

	public function setOnPlanet(oP:Planet)
	{
		if (oP.planet == onPlanet.planet)
			return;

		onPlanet = oP;
	}
}
