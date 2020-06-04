package com.cf.devkit.tween;

import com.domwires.core.mvc.message.IMessageDispatcher;

interface ITween extends IMessageDispatcher
{
	var isActive(get, never):Bool;
	var timeScale(get, set):Float;

	function tween(target:Dynamic, time:Float, props:Dynamic, transition:String = "linear"):ITween;

	function stop(complete:Bool = false):ITween;

	function pause():ITween;

	function resume():ITween;

	function setOnStart(value:Void -> Void):ITween;
	function setOnUpdate(value:Void -> Void):ITween;
	function setOnComplete(value:Void -> Void):ITween;
}
