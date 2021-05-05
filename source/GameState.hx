package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import nape.geom.Vec2;
import nape.phys.BodyType;

class GameState extends FlxState
{
	var planets:Array<FlxNapeSprite>;

	override public function create()
	{
		super.create();

		var background = new FlxSprite();
		background.makeGraphic(FlxG.width, FlxG.height, Colors.DARK_GRAY);
		add(background);

		FlxNapeSpace.init();

		FlxNapeSpace.space.worldAngularDrag = 0;
		FlxNapeSpace.space.worldLinearDrag = 0;
		FlxNapeSpace.space.gravity = new Vec2(0, 0);

		FlxNapeSpace.createWalls();

		planets = new Array<FlxNapeSprite>();

		var planetDisplay = new FlxSprite();
		planetDisplay.loadGraphic(AssetPaths.planet__png, false, 50, 50);

		var planet = new FlxNapeSprite(planetDisplay.x, planetDisplay.y);
		planet.setPosition(FlxG.width / 2, FlxG.height - 260);
		planet.loadGraphicFromSprite(planetDisplay);
		planet.createCircularBody(20);
		planet.setBodyMaterial(0, 0, 0, 100);
		planet.body.type = BodyType.STATIC;
		add(planet);

		FlxNapeSpace.drawDebug = true;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
