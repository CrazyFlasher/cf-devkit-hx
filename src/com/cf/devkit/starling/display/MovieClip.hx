package com.cf.devkit.starling.display;

import starling.core.Starling;

class MovieClip extends starling.display.MovieClip
{
	override public function dispose():Void
	{
		if (Starling.current.juggler.contains(this))
		{
			Starling.current.juggler.remove(this);
		}

		__frames = null;

		super.dispose();
	}
}
