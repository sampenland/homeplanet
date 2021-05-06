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
	private final totalPlanets:Int = 3;
	private final maxSpacingBetweenPlanets:Int = 250;
	private final minPlanetSize:Int = 80;
	private final maxPlanetSize:Int = 100;

	public static final minZoom:Float = 0.05;
	public static final maxZoom:Float = 3.5;

	public static var player:Player;

	private var planets:Array<Planet>;
	private var onPlanet:Map<Int, Array<PlanetObject>>;
	private var planetIdx:Map<Planet, Int>;

	override public function create()
	{
		super.create();
		FlxG.camera.bgColor = Colors.DARK_GRAY;
		FlxG.camera.zoom = 0.05;
		FlxTween.tween(FlxG.camera, {zoom: 3.5}, 5);

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
		var px = planets[0].planet.x + planets[0].planet.width / 2;
		var py = planets[0].planet.y - planets[0].planet.height;

		player = new Player(px, py, planets[0]);
		add(player);
		FlxG.camera.follow(player, LOCKON, 0.05);

		onPlanet[0].push(player);
	}

	private function createLevel()
	{
		FlxNapeSpace.init();

		FlxNapeSpace.space.worldAngularDrag = 0;
		FlxNapeSpace.space.worldLinearDrag = 0;
		FlxNapeSpace.space.gravity = new Vec2(0, 0);

		var cnt:Int = 0;
		var lastX = FlxG.width / 2;
		var startY = FlxG.height / 2;
		while (cnt < totalPlanets)
		{
			var planetSize = FlxG.random.int(minPlanetSize, maxPlanetSize);

			var rx = lastX + (FlxG.random.int(0, Std.int(FlxG.width / 4)) * (if (FlxG.random.int(0, 10) < 5) 1 else -1));
			lastX = rx;

			var y = (startY - (cnt * (planetSize * 2) + (cnt * FlxG.random.int(120, maxSpacingBetweenPlanets))));
			var planet = createPlanet(rx, y, planetSize);
			planet.planet.alive = false;
			createPlanetVeg(planet, FlxG.random.int(100, 200));

			if (cnt == 0)
			{
				planet.raiseFlag();
				planet.planet.alive = true;
			}

			cnt += 1;
		}
	}

	private function createPlanetVeg(planet:Planet, vegCount:Int)
	{
		for (_ in 0...vegCount)
		{
			var rx = FlxG.random.int(Std.int(planet.planet.x - planet.planet.width * 2), Std.int(planet.planet.x + planet.planet.width) * 2);
			var ry = if (FlxG.random.int(0, 10) < 5) planet.planet.y - planet.planet.height else planet.planet.y + planet.planet.height;

			var bush = new Bush(rx, ry, planet);
			add(bush);
			onPlanet[planetIdx[planet]].push(bush);
		}
	}

	private function createPlanet(x:Float, y:Float, bodySize:Int)
	{
		var planet = new Planet(x, y, bodySize);
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
				var distance = planets[planet].planet.getMidpoint().distanceTo(obj.getMidpoint());

				var impulse = 9.8 * planets[planet].planet.body.mass / (distance * distance);
				var dx = planets[planet].planet.getMidpoint().x - obj.getMidpoint().x;
				var dy = planets[planet].planet.getMidpoint().y - obj.getMidpoint().y;

				var force:Vec2 = new Vec2(dx * impulse, dy * impulse);

				force.muleq(elapsed);
				obj.body.applyImpulse(force);

				var newAngle = FlxAngle.angleBetween(obj, planets[planet].planet, true) - 90;
				obj.angle = newAngle;
			}
		}
	}

	private function switchPlanets(elapsed:Float)
	{
		var closestPlanet:Planet = null;
		var minDistance:Float = 99999;
		for (planet in planets)
		{
			var distance = player.getMidpoint().distanceTo(planet.planet.getMidpoint());
			if (distance < minDistance)
			{
				closestPlanet = planet;
				minDistance = distance;
			}
		}

		if (closestPlanet != null)
		{
			player.setOnPlanet(closestPlanet);
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		planetGravity(elapsed);
	}
}
