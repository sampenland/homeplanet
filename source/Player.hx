package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.tweens.FlxTween;
import nape.dynamics.InteractionFilter;
import nape.geom.Vec2;
import nape.phys.BodyType;

class Player extends PlanetObject
{
	private var sprite:FlxSprite;
	private final moveSpeed:Int = 10000;
	private final jumpForce:Int = 5000;
	private var canJump:Bool = true;
	private var zooming:Bool = false;
	private var zoomed:Bool = true;

	override public function new(x:Float, y:Float, onPlanetR:Planet)
	{
		super(x, y, onPlanetR);

		sprite = new FlxSprite();
		sprite.loadGraphic(AssetPaths.player__png, true, 12, 12);

		loadGraphicFromSprite(sprite);
		animation.add("stand", [0, 1], 5, true);
		animation.add("run", [2, 3, 4, 5], 5, true);
		animation.play("stand");

		createCircularBody(8);
		setBodyMaterial(0, 0, 0, 150);
		setDrag(0.95, 0.95);
		body.type = BodyType.DYNAMIC;

		var interaction = new InteractionFilter(1, ~2);
		body.setShapeFilters(interaction);
	}

	private function keyboardControls(elapsed:Float)
	{
		if (onPlanet == null)
			return;

		var impulse = FlxVector.get(onPlanet.planet.getMidpoint().x - getMidpoint().x, onPlanet.planet.getMidpoint().y - getMidpoint().y).normalize();
		var impulseVector = FlxVector.get().copyFrom(impulse);
		impulseVector.length = moveSpeed * elapsed;

		var left = FlxG.keys.anyPressed([A, LEFT]);
		var right = FlxG.keys.anyPressed([D, RIGHT]);
		var jump = FlxG.keys.anyJustPressed([SPACE, UP]);

		if (FlxG.keys.anyJustPressed([A, LEFT]))
		{
			flipX = true;
		}
		else if (FlxG.keys.anyJustPressed([D, RIGHT]))
		{
			flipX = false;
		}

		if (!left && !right && !jump)
		{
			if (body.velocity.x < 1 && body.velocity.x > -1 || body.velocity.y < 1 && body.velocity.y > -1)
			{
				animation.play("stand");
			}
			return;
		}

		animation.play("run");

		if (left)
		{
			impulseVector.degrees += 90;
			body.applyImpulse(new Vec2(impulseVector.x, impulseVector.y));
		}
		else if (right)
		{
			impulseVector.degrees -= 90;
			body.applyImpulse(new Vec2(impulseVector.x, impulseVector.y));
		}

		if (jump && canJump)
		{
			canJump = false;
			FlxTween.tween(FlxG.camera, {zoom: 3.5}, 0.25, {onComplete: finishJump});

			var upVector:FlxVector = getMidpoint().subtractPoint(onPlanet.planet.getMidpoint(FlxPoint.weak()));
			upVector.length = 5 * jumpForce;
			body.applyImpulse(new Vec2(upVector.x, upVector.y));
		}
	}

	private function finishJump(_)
	{
		FlxTween.tween(FlxG.camera, {zoom: 4}, 0.25, {onComplete: resetJump});
	}

	private function resetJump(_)
	{
		canJump = true;
	}

	private function resetZoom(_)
	{
		zooming = false;
	}

	private function zoomControls()
	{
		if (zooming)
			return;

		if (FlxG.keys.anyJustPressed([Z]))
		{
			zooming = true;
			if (zoomed)
			{
				zoomed = false;
				FlxTween.tween(FlxG.camera, {zoom: GameState.minZoom}, 1, {onComplete: resetZoom});
				FlxG.camera.follow(null);
			}
			else
			{
				zoomed = true;
				FlxTween.tween(FlxG.camera, {zoom: GameState.maxZoom}, 1, {onComplete: resetZoom});
				FlxG.camera.follow(this, LOCKON, 0.05);
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		keyboardControls(elapsed);
		zoomControls();
	}
}
