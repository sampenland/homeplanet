package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;
import nape.geom.Vec2;
import nape.phys.BodyType;

class Player extends FlxNapeSprite
{
	private var sprite:FlxSprite;
	private final moveSpeed:Int = 300;

	override public function new(x:Float, y:Float)
	{
		super(x, y);

		sprite = new FlxSprite();
		sprite.loadGraphic(AssetPaths.player__png, true, 12, 12);

		loadGraphicFromSprite(sprite);
		animation.add("stand", [0, 1], 5, true);
		animation.add("run", [2, 3, 4, 5], 5, true);
		animation.play("stand");

		createCircularBody(10);
		setBodyMaterial(0, 0, 0, 100);
		body.type = BodyType.DYNAMIC;
	}

	private function keyboardControls(elapsed:Float)
	{
		if (FlxG.keys.anyPressed([A, LEFT]))
		{
			move(-1, elapsed);
		}
		else if (FlxG.keys.anyPressed([D, RIGHT]))
		{
			move(1, elapsed);
		}
	}

	private function move(dir:Int, elapsed:Float)
	{
		flipX = dir < 0;
		body.applyImpulse(new Vec2(dir * moveSpeed * elapsed, 0));
	}

	private function updateSprite()
	{
		if (body.velocity.x > 0 || body.velocity.x < 0)
		{
			animation.play("run");
		}
		else
		{
			animation.play("stand");
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		keyboardControls(elapsed);
		updateSprite();
	}
}
