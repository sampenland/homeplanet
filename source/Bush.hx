package;

import flixel.FlxG;
import flixel.FlxSprite;
import nape.dynamics.InteractionFilter;

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

		createCircularBody(FlxG.random.int(6, 10));
		setBodyMaterial(0, 0, 0, 150);
		body.mass = 1;

		var interaction = new InteractionFilter(2, ~2);
		body.setShapeFilters(interaction);
	}
}
