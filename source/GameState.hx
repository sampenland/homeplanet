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
	private final totalPlanets:Int = 20;
	private final maxSpacingBetweenPlanets:Int = 250;
	private final minPlanetSize:Int = 18;
	private final maxPlanetSize:Int = 120;

	public static var player:Player;

	private var planets:Array<Planet>;
	private var onPlanet:Map<Int, Array<PlanetObject>>;
	private var planetIdx:Map<Planet, Int>;

	override public function create()
	{
		super.create();
		FlxG.camera.zoom = 0.2;
		FlxTween.tween(FlxG.camera, {zoom: 4}, 6);

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
		var px = planets[0].x + planets[0].width / 2;
		var py = planets[0].y - 20;

		player = new Player(px, py, planets[0]);
		add(player);
		FlxG.camera.follow(player, LOCKON, 0.05);

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

		var cnt:Int = 0;
		var lastX = FlxG.width / 2;
		var startY = FlxG.height / 2;
		while (cnt < totalPlanets)
		{
			var planetSize = FlxG.random.int(minPlanetSize, maxPlanetSize);

			var rx = lastX + (FlxG.random.int(0, Std.int(FlxG.width / 4)) * (if (FlxG.random.int(0, 10) < 5) 1 else -1));
			lastX = rx;

			var y = (startY - (cnt * (planetSize * 2) + (cnt * FlxG.random.int(120, maxSpacingBetweenPlanets))));
			var planet = createPlanet(planetSize, rx, y);
			createPlanetVeg(planet, FlxG.random.int(10, 20));

			cnt += 1;
		}
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

		var neededScale = bodySize / 20;
		planet.scale.set(neededScale, neededScale);

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

	private function switchPlanets(elapsed:Float)
	{
		var closestPlanet:Planet = null;
		var minDistance:Float = 99999;
		for (planet in planets)
		{
			var distance = player.getMidpoint().distanceTo(planet.getMidpoint());
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
