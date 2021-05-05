package;

import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		FlxG.stage.quality = flash.display.StageQuality.BEST;
		addChild(new FlxGame(0, 0, GameState, 1, 60, 60, true));
	}
}
