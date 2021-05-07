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

	public var zooming:Bool = false;

	private var zoomed:Bool = true;
	private var flying:Bool = false;

	override public function new(x:Float, y:Float)
	{
		super(x, y);

		sprite = new FlxSprite();
		sprite.loadGraphic(AssetPaths.player__png, true, 12, 12);

		loadGraphicFromSprite(sprite);
		animation.add("stand", [0, 1], 5, true);
		animation.add("run", [2, 3, 4, 5], 5, true);
		animation.add("jump", [6, 7, 8, 9, 10, 11, 12, 13, 14, 15], 20, false);
		animation.add("fly", [16, 17, 18, 19, 20, 21, 22], 20, true);
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
		kMoveControls(elapsed);
	}

	private function kFlyControls()
	{
		var left = FlxG.keys.anyPressed([A, LEFT]);
		var right = FlxG.keys.anyPressed([D, RIGHT]);
		var up = FlxG.keys.anyJustPressed([UP, W]);
		var fly = FlxG.keys.anyPressed([SPACE]);
		var down = FlxG.keys.anyPressed([DOWN, S]);

		var impulseThrustVector = FlxVector.get(1, 1);
		impulseThrustVector.length = 0.1 * jumpForce;

		var moving:Bool = false;
		impulseThrustVector.degrees = -90;
		if (FlxG.keys.anyPressed([UP, W]))
		{
			moving = true;
			body.applyImpulse(new Vec2(impulseThrustVector.x, impulseThrustVector.y));

			if (left)
			{
				moving = true;
				impulseThrustVector.degrees -= 45;
				body.applyImpulse(new Vec2(impulseThrustVector.x, impulseThrustVector.y));
			}

			if (right)
			{
				moving = true;
				impulseThrustVector.degrees += 45;
				body.applyImpulse(new Vec2(impulseThrustVector.x, impulseThrustVector.y));
			}
		}
		else if (down)
		{
			moving = true;
			impulseThrustVector.degrees -= 180;
			body.applyImpulse(new Vec2(impulseThrustVector.x, impulseThrustVector.y));

			if (left)
			{
				moving = true;
				impulseThrustVector.degrees += 45;
				body.applyImpulse(new Vec2(impulseThrustVector.x, impulseThrustVector.y));
			}

			if (right)
			{
				moving = true;
				impulseThrustVector.degrees -= 45;
				body.applyImpulse(new Vec2(impulseThrustVector.x, impulseThrustVector.y));
			}
		}
		else
		{
			if (left)
			{
				moving = true;
				impulseThrustVector.degrees -= 45;
				body.applyImpulse(new Vec2(impulseThrustVector.x, impulseThrustVector.y));
			}

			if (right)
			{
				moving = true;
				impulseThrustVector.degrees += 45;
				body.applyImpulse(new Vec2(impulseThrustVector.x, impulseThrustVector.y));
			}
		}

		if (!moving)
		{
			impulseThrustVector.degrees = -90;
			animation.play("stand");
			angle = 0;
		}
		else
		{
			animation.play("fly");
			angle = impulseThrustVector.degrees + 90;
		}

		impulseThrustVector.put();
	}

	private function kMoveControls(elapsed:Float)
	{
		var left = FlxG.keys.anyPressed([A, LEFT]);
		var right = FlxG.keys.anyPressed([D, RIGHT]);
		var up = FlxG.keys.anyJustPressed([UP, W]);
		var fly = FlxG.keys.anyPressed([SPACE]);

		flying = onPlanet == null;

		if (onPlanet == null)
		{
			kFlyControls();
			return;
		}

		var impulse = FlxVector.get(onPlanet.planet.getMidpoint().x - getMidpoint().x, onPlanet.planet.getMidpoint().y - getMidpoint().y).normalize();
		var impulseVector = FlxVector.get().copyFrom(impulse);
		impulseVector.length = moveSpeed * elapsed;

		if (FlxG.keys.anyJustPressed([A, LEFT]))
		{
			flipX = true;
		}
		else if (FlxG.keys.anyJustPressed([D, RIGHT]))
		{
			flipX = false;
		}

		if (!left && !right && !up && !fly)
		{
			if (body.velocity.x < 1 && body.velocity.x > -1 || body.velocity.y < 1 && body.velocity.y > -1)
			{
				if (canJump)
					animation.play("stand");
			}
			return;
		}

		if (!fly)
		{
			if (canJump)
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
		}

		var upVector:FlxVector = getMidpoint().subtractPoint(onPlanet.planet.getMidpoint(FlxPoint.weak()));

		if (fly)
		{
			animation.play("fly");
			upVector.length = 0.25 * jumpForce;
			body.applyImpulse(new Vec2(upVector.x, upVector.y));
		}

		if (!fly)
		{
			if (up && canJump)
			{
				canJump = false;
				animation.play("jump");
				FlxTween.tween(FlxG.camera, {zoom: 3.5}, 0.25, {onComplete: finishJump});

				upVector.length = (onPlanet.planet.mass * 2.25) * jumpForce;
				body.applyImpulse(new Vec2(upVector.x, upVector.y));
			}
		}

		upVector.put();
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

		if (flying)
		{
			if (flying && FlxG.camera.zoom != GameState.flyZoom)
			{
				zooming = true;
				FlxTween.tween(FlxG.camera, {zoom: GameState.flyZoom}, 1, {onComplete: resetZoom});
			}

			return;
		}
		else
		{
			if (FlxG.camera.zoom == GameState.flyZoom)
			{
				zooming = true;
				FlxTween.tween(FlxG.camera, {zoom: GameState.maxZoom}, 1, {onComplete: resetZoom});
			}
		}

		if (FlxG.keys.anyJustPressed([Z]))
		{
			zooming = true;
			if (zoomed)
			{
				zoomed = false;
				FlxTween.tween(FlxG.camera, {zoom: GameState.minZoom}, 1, {onComplete: resetZoom});
			}
			else
			{
				zoomed = true;
				FlxG.camera.follow(this, LOCKON, 0.05);
				FlxTween.tween(FlxG.camera, {zoom: GameState.maxZoom}, 1, {onComplete: resetZoom});
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
