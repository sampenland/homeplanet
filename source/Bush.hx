package;

import flixel.FlxSprite;
import nape.phys.BodyType;

class Bush extends PlanetObject
{
	override public function new(x:Float, y:Float, onPlanetR:Planet)
	{
		super(x, y, onPlanetR);

		var display = new FlxSprite();
		display.loadGraphic(AssetPaths.bush__png, true, 12, 12);
		loadGraphicFromSprite(display);

		animation.add("idle", [0, 1], 3, true);
		animation.play("idle");

		createCircularBody(10);
		setBodyMaterial(0, 0, 0, 150);
	}
}
