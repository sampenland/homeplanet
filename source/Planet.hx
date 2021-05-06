package;

import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import nape.phys.BodyType;

class Planet extends FlxTypedGroup<FlxSprite>
{
	public var radius:Int;

	public var planet:FlxNapeSprite;
	public var planetDisplay:FlxSprite;

	private var planetFlag:FlxSprite;

	override public function new(x:Float, y:Float, bodySize:Int)
	{
		super();

		var neededScale = bodySize / 46;

		planetFlag = new FlxSprite();
		planetFlag.setPosition(x - 8, y - 62 - bodySize);
		planetFlag.loadGraphic(AssetPaths.flag__png, true, 12, 64);
		planetFlag.scale.set(neededScale, neededScale);
		planetFlag.animation.add("rise", [
			0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28
		], 8, false);
		add(planetFlag);

		planetDisplay = new FlxSprite();
		planetDisplay.loadGraphic(AssetPaths.planet__png, false, 100, 100);
		add(planetDisplay);

		planet = new FlxNapeSprite(x, y);
		planet.loadGraphicFromSprite(planetDisplay);
		planet.scale.set(neededScale, neededScale);
		planet.createCircularBody(bodySize);
		planet.setBodyMaterial(0, 0, 0, 100);
		planet.body.type = BodyType.STATIC;
		planet.body.mass = Std.int(10e5);
		add(planet);

		radius = bodySize;
	}

	public function raiseFlag()
	{
		planetFlag.animation.play("rise");
	}
}
