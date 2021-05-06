package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxVector;

class Bush extends FlxSprite
{
	private var onPlanet:Planet;

	override public function new(onPlanetR:Planet)
	{
		super(0, 0);

		onPlanet = onPlanetR;

		var display = new FlxSprite();
		display.loadGraphic(AssetPaths.bush__png, true, 12, 12);
		loadGraphicFromSprite(display);

		animation.add("idle", [0, 1], 3, true);
		animation.play("idle");

		var v = FlxVector.get(1, 1);
		v.degrees = FlxG.random.float(0, 359);
		angle = v.degrees - 180;
		v.length = onPlanetR.radius;

		x = onPlanet.planet.x + v.x;
		y = onPlanet.planet.y + v.y;
	}
}
