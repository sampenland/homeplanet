package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxAngle;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import nape.geom.Vec2;
import nape.phys.BodyType;

class GameState extends FlxState
{
	private final totalPlanets:Int = 10;

	public static var player:Player;

	private var planets:Array<FlxNapeSprite>;
	private var onPlanet:Map<Int, Array<FlxNapeSprite>>;

	override public function create()
	{
		super.create();

		FlxTween.tween(FlxG.camera, {zoom: 3}, 2);

		setup();
		createLevel();
		createActors();

		FlxNapeSpace.drawDebug = true;
	}

	private function setup()
	{
		planets = new Array<FlxNapeSprite>();
		onPlanet = new Map<Int, Array<FlxNapeSprite>>();

		for (p in 0...totalPlanets)
		{
			onPlanet[p] = new Array<FlxNapeSprite>();
		}
	}

	private function createActors()
	{
		player = new Player(FlxG.width / 2, FlxG.height - 300);
		add(player);

		onPlanet[0].push(player);
	}

	private function createLevel()
	{
		var background = new FlxSprite();
		background.makeGraphic(FlxG.width, FlxG.height, Colors.DARK_GRAY);
		add(background);

		FlxNapeSpace.init();

		FlxNapeSpace.space.worldAngularDrag = 0;
		FlxNapeSpace.space.worldLinearDrag = 0;
		FlxNapeSpace.space.gravity = new Vec2(0, 0);

		FlxNapeSpace.createWalls();

		var planetDisplay = new FlxSprite();
		planetDisplay.loadGraphic(AssetPaths.planet__png, false, 50, 50);

		var startPlanet = new FlxNapeSprite(planetDisplay.x, planetDisplay.y);
		startPlanet.setPosition(FlxG.width / 2, FlxG.height - 260);
		startPlanet.loadGraphicFromSprite(planetDisplay);
		startPlanet.createCircularBody(20);
		startPlanet.setBodyMaterial(0, 0, 0, 100);
		startPlanet.body.type = BodyType.STATIC;
		startPlanet.body.mass = Std.int(10e5);
		add(startPlanet);
		planets.push(startPlanet);
	}

	private function planetGravity(elapsed:Float)
	{
		for (planet in onPlanet.keys())
		{
			for (obj in onPlanet[planet])
			{
				var distance = planets[planet].getPosition().distanceTo(obj.getPosition());

				var impulse = 10 * planets[planet].body.mass / (distance * distance);
				var dx = planets[planet].getMidpoint().x - obj.getMidpoint().x;
				var dy = planets[planet].getMidpoint().y - obj.getMidpoint().y;

				var force:Vec2 = new Vec2(dx * impulse, dy * impulse);

				force.muleq(elapsed);
				obj.body.applyImpulse(force);

				obj.angle = FlxAngle.angleBetween(obj, planets[planet], true) - 90;
			}
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		planetGravity(elapsed);
	}
}
