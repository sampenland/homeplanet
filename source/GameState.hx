package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.math.FlxAngle;
import flixel.math.FlxRect;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import nape.geom.Vec2;

class GameState extends FlxState
{
	private static final gameWidth:Int = 10000;
	private static final gameHeight:Int = 10000;

	private final starCount:Int = 15000;

	private final totalPlanets:Int = 40;
	private final maxSpacingBetweenPlanets:Int = 100;
	private final minPlanetSize:Int = 40;
	private final maxPlanetSize:Int = 150;
	private final breakGravityDistance:Int = 100;

	public static final minZoom:Float = 0.05;
	public static final maxZoom:Float = 3.5;

	public static var player:Player;

	private var planets:Array<Planet>;
	private var onPlanet:Map<Int, Array<PlanetObject>>;
	private var planetIdx:Map<Planet, Int>;
	private var planetLocations:Array<FlxRect>;

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
		var stars = new FlxSprite(-gameWidth, -gameHeight);
		stars.makeGraphic(gameWidth * 2, gameHeight * 2, FlxColor.TRANSPARENT);
		for (_ in 0...starCount)
		{
			var x = FlxG.random.int(0, gameWidth * 2);
			var y = FlxG.random.int(0, gameHeight * 2);

			var star = new FlxSprite(x, y);
			var s = FlxG.random.int(1, 4);
			star.makeGraphic(s, s, Colors.WHITE);
			stars.stamp(star, x, y);
		}
		add(stars);

		planets = new Array<Planet>();
		onPlanet = new Map<Int, Array<PlanetObject>>();
		planetIdx = new Map<Planet, Int>();
		planetLocations = new Array<FlxRect>();

		for (p in 0...totalPlanets)
		{
			onPlanet[p] = new Array<PlanetObject>();
		}
	}

	private function createActors()
	{
		var px = planets[1].planet.x + planets[1].planet.width / 2;
		var py = planets[1].planet.y - planets[1].planet.height;

		player = new Player(px, py, planets[1]);
		add(player);
		FlxG.camera.follow(player, LOCKON, 0.05);

		onPlanet[1].push(player);
		planets[1].raiseFlag();
	}

	private function createLevel()
	{
		FlxNapeSpace.init();

		FlxNapeSpace.space.worldAngularDrag = 0;
		FlxNapeSpace.space.worldLinearDrag = 0;
		FlxNapeSpace.space.gravity = new Vec2(0, 0);

		var cnt:Int = 0;
		while (cnt < totalPlanets)
		{
			var planetSize = FlxG.random.int(minPlanetSize, maxPlanetSize);

			if (cnt == 0)
			{
				planetSize = maxPlanetSize;
			}

			var planetX = FlxG.random.int(-Std.int(gameWidth / 2), Std.int(gameWidth / 2));
			var planetY = FlxG.random.int(-Std.int(gameHeight / 2), gameHeight);
			var planetRect = new FlxRect(planetSize, planetY, planetSize, planetSize);

			if (cnt == 0)
			{
				planetX = 0;
				planetY = 0;
				planetRect = new FlxRect(planetSize, planetY, planetSize, planetSize);
			}
			else
			{
				while (true)
				{
					planetX = FlxG.random.int(-gameWidth, gameWidth);
					planetY = FlxG.random.int(-gameHeight, gameHeight);
					planetRect = new FlxRect(planetSize, planetY, planetSize, planetSize);

					var failed = false;
					for (rect in planetLocations)
					{
						if (planetX > rect.x && planetX < rect.x + rect.width && planetY > rect.y && planetY < rect.y + rect.height)
						{
							failed = true;
							break;
						}
					}

					if (!failed)
						break;
				}
			}

			planetLocations.push(planetRect);

			var planet = createPlanet(planetX, planetY, planetSize, FlxG.random.int(60, 120), cnt == 0);
			planet.planet.alive = false;

			cnt += 1;
		}
	}

	private function createPlanet(x:Float, y:Float, bodySize:Int, vegCnt:Int, ?blackHole:Bool)
	{
		var planet = new Planet(x, y, bodySize, vegCnt, blackHole);
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

				if (distance > planets[planet].radius + breakGravityDistance)
				{
					obj.setOnPlanet(planets[0]);
					break;
				}

				if (planets[planet].isBlackHole)
					continue;

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

		for (planetObj in planets)
		{
			var distance = planetObj.planet.getMidpoint().distanceTo(player.getMidpoint());
			if (distance < planetObj.radius + breakGravityDistance)
			{
				player.setOnPlanet(planetObj);
				break;
			}
		}
	}

	private function gotoMenu()
	{
		FlxG.camera.fade(Colors.DARK_GRAY, 0.33, false, function()
		{
			FlxG.switchState(new MenuState());
		});
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		planetGravity(elapsed);
		keyboardListen(elapsed);
	}

	private function keyboardListen(elapsed:Float)
	{
		if (FlxG.keys.anyJustPressed([ESCAPE]))
		{
			gotoMenu();
		}
	}
}
