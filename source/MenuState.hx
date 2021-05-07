package;

import flixel.FlxG;
import flixel.FlxState;

class MenuState extends FlxState
{
	override public function create()
	{
		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		keyboardListen(elapsed);
	}

	private function gotoGame()
	{
		FlxG.camera.fade(Colors.DARK_GRAY, 0.33, false, function()
		{
			FlxG.switchState(new GameState());
		});
	}

	private function keyboardListen(elapsed:Float)
	{
		if (FlxG.keys.anyJustPressed([ESCAPE]))
		{
			gotoGame();
		}
	}
}
