package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxVector;
import nape.phys.BodyType;

class Planet extends FlxTypedGroup<FlxSprite>
{
	public var planet:FlxNapeSprite;
	public var planetDisplay:FlxSprite;

	private var planetFlag:FlxSprite;

	public var isBlackHole:Bool;

	public var radius:Float;

	override public function new(x:Float, y:Float, bodySize:Int, vegCnt:Int, ?blackHole:Bool)
	{
		super();

		isBlackHole = blackHole;
		var neededScale = bodySize / 46;
		radius = bodySize;

		if (!blackHole)
		{
			planetFlag = new FlxSprite();
			planetFlag.loadGraphic(AssetPaths.flag__png, true, 12, 64);
			planetFlag.setPosition(x - 8, y - 62 - bodySize);

			planetFlag.scale.set(neededScale, neededScale);
			planetFlag.animation.add("rise", [
				0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28
			], 8, false);
			add(planetFlag);
		}

		planetDisplay = new FlxSprite();
		if (blackHole)
		{
			planetDisplay.loadGraphic(AssetPaths.blackHole__png, true, 100, 100);
		}
		else
		{
			planetDisplay.loadGraphic(AssetPaths.planet__png, true, 100, 100);
		}

		planet = new FlxNapeSprite(x, y);
		planet.loadGraphicFromSprite(planetDisplay);
		planet.scale.set(neededScale, neededScale);
		planet.createCircularBody(bodySize);
		planet.setBodyMaterial(0, 0, 0, 100);
		planet.body.type = BodyType.STATIC;
		planet.body.mass = Std.int(10e5);
		add(planet);

		if (!blackHole)
		{
			for (_ in 0...vegCnt)
			{
				var bush = new FlxSprite();
				bush.loadGraphic(AssetPaths.bush__png, true, 12, 12);
				add(bush);

				bush.animation.add("idle", [0, 1], 3, true);
				bush.animation.play("idle");

				var v = FlxVector.get(1, 1);
				v.degrees = FlxG.random.float(0, 359);
				bush.angle = v.degrees + 90;
				v.length = bodySize + bush.width - 2;

				bush.x = x - bush.width / 2 + v.x;
				bush.y = y - bush.height / 2 + v.y;
				v.put();
			}
		}
	}

	public function raiseFlag()
	{
		if (isBlackHole)
			return;

		planetFlag.animation.play("rise");
	}
}
