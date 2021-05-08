package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.math.FlxAngle;
import flixel.math.FlxVector;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import nape.geom.Vec2;

class GameState extends FlxState
{
	public static final gameWidth:Int = 5000;
	public static final gameHeight:Int = 5000;

	private final starCount:Int = 20000;

	private final totalPlanets:Int = 20;
	private final maxSpacingBetweenPlanets:Int = 25;
	private final minPlanetSize:Int = 60;
	private final maxPlanetSize:Int = 160;
	private final breakGravityDistance:Float = 2.5;

	public static final minZoom:Float = 0.1;
	public static final maxZoom:Float = 3.5;
	public static final flyZoom:Float = 1;

	public static var player:Player;
	public static var sun:Planet;
	public static final minRevSpeed:Float = 10000;
	public static final maxRevSpeed:Float = 20000;

	private var planets:Array<Planet>;
	private var onPlanet:Map<Int, Array<PlanetObject>>;

	override public function create()
	{
		super.create();
		FlxG.camera.bgColor = Colors.DARK_GRAY;
		FlxG.camera.zoom = 0.05;

		var endZoom = function(_)
		{
			player.zooming = false;
		};

		FlxTween.tween(FlxG.camera, {zoom: 3.5}, 5, {onComplete: endZoom});

		setup();

		// FlxNapeSpace.drawDebug = true;
	}

	private function setup()
	{
		var stars = new FlxSprite(-gameWidth, -gameHeight);
		stars.makeGraphic(gameWidth * 3, gameHeight * 3, FlxColor.TRANSPARENT);
		for (_ in 0...starCount)
		{
			var x = FlxG.random.int(0, Std.int(gameWidth * 4));
			var y = FlxG.random.int(0, Std.int(gameHeight * 4));

			var star = new FlxSprite(x, y);
			var s = FlxG.random.int(1, 4);
			star.makeGraphic(s, s, Colors.WHITE);
			stars.stamp(star, x, y);
		}
		add(stars);

		planets = new Array<Planet>();
		onPlanet = new Map<Int, Array<PlanetObject>>();

		for (p in 0...totalPlanets)
		{
			onPlanet[p] = new Array<PlanetObject>();
		}

		createLevel();
		createActors();
	}

	private function createActors()
	{
		createPlayer(planets[1]);
	}

	private function createPlayer(p:Planet)
	{
		var px = p.planet.x + p.planet.width / 2;
		var py = p.planet.y - p.planet.height / 2;

		player = new Player(px, py);
		player.onPlanet = p;
		player.zooming = true;
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
		var distanceOut:Int = 0;
		while (cnt < totalPlanets)
		{
			var planetSize = FlxG.random.int(minPlanetSize, maxPlanetSize);

			if (cnt == 0)
			{
				planetSize = maxPlanetSize;
			}

			var planetVec = FlxVector.get(gameWidth / 2, gameHeight / 2);
			planetVec.degrees = FlxG.random.int(0, 360);

			planetVec.length = distanceOut;
			distanceOut += (planetSize * 3) + FlxG.random.int(Std.int(maxSpacingBetweenPlanets / 2), maxSpacingBetweenPlanets);

			var planet = createPlanet(planetVec.x, planetVec.y, planetSize, FlxG.random.int(60, 120), cnt == 0);

			if (cnt == 0)
				sun = planet;

			cnt += 1;
		}
	}

	private function createPlanet(x:Float, y:Float, bodySize:Int, vegCnt:Int, ?sun:Bool)
	{
		var planet = new Planet(x, y, bodySize, vegCnt, sun);
		add(planet);
		planets.push(planet);

		return planet;
	}

	private function planetGravity(elapsed:Float)
	{
		for (planet in onPlanet.keys())
		{
			if (planets[planet].isSun)
				continue;

			var sunOutVec = FlxVector.get(sun.planet.getMidpoint().x - player.getMidpoint().x, sun.planet.getMidpoint().y - player.getMidpoint().y);
			sunOutVec.degrees += 90;
			sunOutVec.length = planets[planet].revSpeed;
			planets[planet].planet.body.applyImpulse(new Vec2(sunOutVec.x, sunOutVec.y));

			for (obj in onPlanet[planet])
			{
				var distance = planets[planet].planet.getMidpoint().distanceTo(obj.getMidpoint());

				if (distance > planets[planet].radius * breakGravityDistance)
				{
					obj.onPlanet = null;
					onPlanet[planet].remove(obj);
					continue;
				}

				if (planets[planet].isSun)
					continue;

				var gravityVec = FlxVector.get(planets[planet].planet.getMidpoint().x - obj.getMidpoint().x,
					planets[planet].planet.getMidpoint().y - obj.getMidpoint().y);

				gravityVec.length = 980 * planets[planet].planet.body.mass / (distance * distance) * elapsed;
				obj.body.applyImpulse(new Vec2(gravityVec.x, gravityVec.y));

				var newAngle = FlxAngle.angleBetween(obj, planets[planet].planet, true) - 90;
				obj.angle = newAngle;
			}
		}

		if (player.onPlanet == null)
		{
			for (p in 0...totalPlanets)
			{
				if (planets[p].isSun)
					continue;

				var distance = planets[p].planet.getMidpoint().distanceTo(player.getMidpoint());
				if (distance < planets[p].radius * breakGravityDistance)
				{
					player.onPlanet = planets[p];
					onPlanet[p].push(player);
					break;
				}
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
