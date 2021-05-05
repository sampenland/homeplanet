package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;
import flixel.math.FlxAngle;
import flixel.math.FlxVector;
import nape.geom.Vec2;
import nape.phys.BodyType;

class Player extends PlanetObject
{
	private var sprite:FlxSprite;
	private final moveSpeed:Int = 6000;

	override public function new(x:Float, y:Float, onPlanetR:FlxNapeSprite)
	{
		super(x, y, onPlanetR);

		sprite = new FlxSprite();
		sprite.loadGraphic(AssetPaths.player__png, true, 12, 12);

		loadGraphicFromSprite(sprite);
		animation.add("stand", [0, 1], 5, true);
		animation.add("run", [2, 3, 4, 5], 5, true);
		animation.play("stand");

		createCircularBody(10);
		setBodyMaterial(0, 0, 0, 150);
		setDrag(0.95, 0.95);
		body.type = BodyType.DYNAMIC;
	}

	private function keyboardControls(elapsed:Float)
	{
		var impulse = FlxVector.get(onPlanet.getMidpoint().x - getMidpoint().x, onPlanet.getMidpoint().y - getMidpoint().y).normalize();
		var impulseVector = FlxVector.get().copyFrom(impulse);

		var left = FlxG.keys.anyPressed([A, LEFT]);
		var right = FlxG.keys.anyPressed([D, RIGHT]);

		if (FlxG.keys.anyJustPressed([A, LEFT]))
		{
			flipX = true;
		}
		else if (FlxG.keys.anyJustPressed([D, RIGHT]))
		{
			flipX = false;
		}

		if (!left && !right)
		{
			animation.play("stand");
			return;
		}

		animation.play("run");

		if (left)
		{
			impulseVector.degrees += 90;
		}
		else if (right)
		{
			impulseVector.degrees -= 90;
		}

		impulseVector.length = moveSpeed * elapsed;
		body.applyImpulse(new Vec2(impulseVector.x, impulseVector.y));
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		keyboardControls(elapsed);
	}
}
