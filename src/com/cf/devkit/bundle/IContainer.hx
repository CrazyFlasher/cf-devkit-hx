package com.cf.devkit.bundle;

#if useStarling
import openfl.geom.Point;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
#else
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
#end

interface IContainer extends IDisplayObject
{
	var canvas(get, never):DisplayObjectContainer;

	function addChild(value:IDisplayObject, index:Int = -1):IContainer;
	function removeChild(value:IDisplayObject, dispose:Bool = true):IContainer;
	function removeChildren(dispose:Bool = true):IContainer;
	function swapZ(a:IDisplayObject, b:IDisplayObject):IContainer;

	function hasDisplayObject(name:String):Bool;
	function getMovieClip(name:String):IMovieClip;
	function getSpineClip(name:String = null):ISpineClip;
	function getDragonBonesClip(name:String = null):IDragonBonesClip;
	function getParticleClip(name:String = null):IParticleClip;
	function getSheetClip(name:String = null):ISheetClip;
	function getChild(name:String):DisplayObject;
	function getDisplayObject(name:String):IDisplayObject;
	function getTextField(name:String):ITextField;

	function clearGraphics():IDisplayObject;
	function beginFill(color:UInt = 0xffffff, alpha:Float = 1.0):IDisplayObject;
	function endFill():IDisplayObject;
	function drawPolygon(vertexList:Array<Point>):IDisplayObject;
	function drawRectangle(x:Float, y:Float, width:Float, height:Float):IDisplayObject;
	function drawEllipse(x:Float, y:Float, width:Float, height:Float):IDisplayObject;
	function drawCircle(x:Float, y:Float, radius:Float):IDisplayObject;
	function drawLines(vertexList:Array<Point>, color:UInt = 0xffffff, alpha:Float = 1.0,
					   thickness:Float = 1, roundedCorners:Bool = true):IDisplayObject;
}
