package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.math.FlxAngle;
import flixel.tweens.FlxTween;
import nape.geom.Vec2;
import nape.phys.BodyType;

class GameState extends FlxState
{
	private final totalPlanets:Int = 10;

	public static var player:Player;

	private var planets:Array<Planet>;
	private var onPlanet:Map<Int, Array<PlanetObject>>;
	private var planetIdx:Map<Planet, Int>;

	override public function create()
	{
		super.create();

		FlxTween.tween(FlxG.camera, {zoom: 3}, 2);

		setup();
		createLevel();
		createActors();

		// FlxNapeSpace.drawDebug = true;
	}

	private function setup()
	{
		planets = new Array<Planet>();
		onPlanet = new Map<Int, Array<PlanetObject>>();
		planetIdx = new Map<Planet, Int>();

		for (p in 0...totalPlanets)
		{
			onPlanet[p] = new Array<PlanetObject>();
		}
	}

	private function createActors()
	{
		player = new Player(FlxG.width / 2, FlxG.height - 300, planets[0]);
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

		var startPlanet = createPlanet(20, FlxG.width / 2, FlxG.height - 260);
		createPlanetVeg(startPlanet, 12);
	}

	private function createPlanetVeg(planet:Planet, vegCount:Int)
	{
		for (_ in 0...vegCount)
		{
			var rx = FlxG.random.int(Std.int(planet.x - planet.width), Std.int(planet.x + planet.width));
			var ry = if (FlxG.random.int(0, 10) < 5) planet.y - planet.height else planet.y + planet.height;

			var bush = new Bush(rx, ry, planet);
			add(bush);
			onPlanet[planetIdx[planet]].push(bush);
		}
	}

	private function createPlanet(bodySize:Int, x:Float, y:Float)
	{
		var planetDisplay = new FlxSprite();
		planetDisplay.loadGraphic(AssetPaths.planet__png, false, 50, 50);

		var planet = new Planet(planetDisplay.x, planetDisplay.y, bodySize);
		planet.setPosition(x, y);
		planet.loadGraphicFromSprite(planetDisplay);
		planet.createCircularBody(bodySize);
		planet.setBodyMaterial(0, 0, 0, 100);
		planet.body.type = BodyType.STATIC;
		planet.body.mass = Std.int(10e5);
		add(planet);
		planets.push(planet);
		planetIdx[planet] = planets.length - 1;

		return planet;
	}

	private function planetGravity(elapsed:Float)
	{
		for (planet in onPlanet.keys())
		{
			for (obj in onPlanet[planet])
			{
				var distance = planets[planet].getMidpoint().distanceTo(obj.getMidpoint());

				var impulse = 9.8 * planets[planet].body.mass / (distance * distance);
				var dx = planets[planet].getMidpoint().x - obj.getMidpoint().x;
				var dy = planets[planet].getMidpoint().y - obj.getMidpoint().y;

				var force:Vec2 = new Vec2(dx * impulse, dy * impulse);

				force.muleq(elapsed);
				obj.body.applyImpulse(force);

				var newAngle = FlxAngle.angleBetween(obj, planets[planet], true) - 90;
				obj.angle = newAngle;
			}
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		planetGravity(elapsed);
	}
}
