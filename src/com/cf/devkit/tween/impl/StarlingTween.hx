package com.cf.devkit.tween.impl;

import starling.animation.IAnimatable;
import com.domwires.core.mvc.message.MessageDispatcher;
import starling.animation.Tween;
import starling.core.Starling;

class StarlingTween extends MessageDispatcher implements ITween implements IAnimatable
{
	public var isActive(get, never):Bool;
	private var _isActive:Bool;

	public var timeScale(get, set):Float;
	private var _timeScale:Float = 1.0;

	private var instance:Tween;

	private var _onStart:Void -> Void;
	private var _onUpdate:Void -> Void;
	private var _onComplete:Void -> Void;

	@PostConstruct
	private function init():Void
	{
		instance = new Tween(null, 0);
	}

	override public function dispose():Void
	{
		_isActive = false;
		removeFromJuggler();
		instance = null;

		super.dispose();
	}

	public function advanceTime(time:Float):Void
	{
		if (_isActive)
		{
			instance.advanceTime(time * _timeScale);
		} else
		{
			if (Starling.current.juggler.contains(this))
			{
				removeFromJuggler();
			}
		}
	}

	private function removeFromJuggler():Void
	{
		Starling.current.juggler.remove(this);
	}

	private function addToJuggler():Void
	{
		Starling.current.juggler.add(this);
	}

	public function tween(target:Dynamic, time:Float, props:Dynamic, transition:String = "linear"):ITween
	{
		_isActive = true;

		instance.reset(target, time, transition);

		for (prop in Reflect.fields(props))
		{
			instance.animate(prop, Reflect.field(props, prop));
		}

		if (hasMessageListener(TweenMessageType.Start))
		{
			instance.onStart = onStart;
		} else
		{
			instance.onStart = _onStart;
		}

		if (hasMessageListener(TweenMessageType.Complete))
		{
			instance.onComplete = onComplete;
		} else
		{
			/*instance.onComplete = () ->
			{
				_isActive = false;

				if (_onComplete != null)
				{
					_onComplete();
				}
			};*/

			instance.onComplete = _onComplete;
		}

		if (hasMessageListener(TweenMessageType.Update))
		{
			instance.onUpdate = onUpdate;
		} else
		{
			instance.onUpdate = _onUpdate;
		}

		_onStart = null;
		_onUpdate = null;
		_onComplete = null;

		addToJuggler();

		return this;
	}

	public function setOnStart(value:Void -> Void):ITween
	{
		_onStart = value;

		return this;
	}

	public function setOnUpdate(value:Void -> Void):ITween
	{
		_onUpdate = value;

		return this;
	}

	public function setOnComplete(value:Void -> Void):ITween
	{
		_onComplete = value;

		return this;
	}

	private function onStart():Void
	{
		dispatchMessage(TweenMessageType.Start);
	}

	private function onComplete():Void
	{
		_isActive = false;
		dispatchMessage(TweenMessageType.Complete);
	}

	private function onUpdate():Void
	{
		dispatchMessage(TweenMessageType.Update);
	}

	public function stop(complete:Bool = false):ITween
	{
		if (!_isActive) return this;

		if (complete)
		{
			instance.advanceTime(instance.totalTime);
		}

		instance.reset(null, 0);

		_isActive = false;
		removeFromJuggler();

		return this;
	}

	public function pause():ITween
	{
		removeFromJuggler();

		return this;
	}

	public function resume():ITween
	{
		addToJuggler();

		return this;
	}

	private function get_isActive():Bool
	{
		return _isActive;
	}

	private function get_timeScale():Float
	{
		return _timeScale;
	}

	private function set_timeScale(value:Float):Float
	{
		return _timeScale = value;
	}
}
