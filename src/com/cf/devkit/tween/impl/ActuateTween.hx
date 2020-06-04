package com.cf.devkit.tween.impl;

import motion.easing.Bounce;
import motion.easing.Elastic;
import motion.easing.Back;
import motion.easing.Quad;
import motion.easing.Linear;
import motion.easing.IEasing;
import com.domwires.core.mvc.message.MessageDispatcher;
import motion.Actuate;
import motion.actuators.IGenericActuator;

class ActuateTween extends MessageDispatcher implements ITween
{
	public var isActive(get, never):Bool;
	private var _isActive:Bool;

	public var timeScale(get, set):Float;
	private var _timeScale:Float = 1.0;

	private var instance:IGenericActuator;

	private var _onStart:Void -> Void;
	private var _onUpdate:Void -> Void;
	private var _onComplete:Void -> Void;

	private var transitonMap:Map<String, IEasing> = new Map<String, IEasing>();

	@PostConstruct
	private function init():Void
	{
		transitonMap.set(TweenTransition.LINEAR, Linear.easeNone);
		transitonMap.set(TweenTransition.EASE_IN, Quad.easeIn);
		transitonMap.set(TweenTransition.EASE_OUT, Quad.easeOut);
		transitonMap.set(TweenTransition.EASE_IN_OUT, Quad.easeInOut);
		transitonMap.set(TweenTransition.EASE_IN_BACK, Back.easeIn);
		transitonMap.set(TweenTransition.EASE_OUT_BACK, Back.easeOut);
		transitonMap.set(TweenTransition.EASE_IN_OUT_BACK, Back.easeInOut);
		transitonMap.set(TweenTransition.EASE_IN_ELASTIC, Elastic.easeIn);
		transitonMap.set(TweenTransition.EASE_OUT_ELASTIC, Elastic.easeOut);
		transitonMap.set(TweenTransition.EASE_IN_OUT_ELASTIC, Elastic.easeInOut);
		transitonMap.set(TweenTransition.EASE_IN_BOUNCE, Bounce.easeIn);
		transitonMap.set(TweenTransition.EASE_OUT_BOUNCE, Bounce.easeOut);
		transitonMap.set(TweenTransition.EASE_IN_OUT_BOUNCE, Bounce.easeInOut);
	}

	public function tween(target:Dynamic, time:Float, props:Dynamic, transition:String = "linear"):ITween
	{
		_isActive = true;

		var t:IEasing = transitonMap.exists(transition) ? transitonMap.get(transition) : Linear.easeNone;

		instance = Actuate.tween(target, time, props, false).ease(t);

		if (hasMessageListener(TweenMessageType.Start))
		{
			onStart();
		} else
		{
			if (_onStart != null) _onStart();
		}

		if (hasMessageListener(TweenMessageType.Complete))
		{
			instance.onComplete(onComplete);
		} else
		{
			instance.onComplete(_onComplete);
		}

		if (hasMessageListener(TweenMessageType.Update))
		{
			instance.onUpdate(onUpdate);
		} else
		{
			instance.onUpdate(_onUpdate);
		}

		_onStart = null;
		_onUpdate = null;
		_onComplete = null;

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
		_isActive = false;
		Actuate.stop(instance, null, complete, complete);

		return this;
	}

	public function pause():ITween
	{
		Actuate.pause(instance);

		return this;
	}

	public function resume():ITween
	{
		Actuate.resume(instance);

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
//		return _timeScale = value;

		throw haxe.io.Error.Custom("Not implemented!");
	}
}
