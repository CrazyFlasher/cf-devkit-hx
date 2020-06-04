package com.cf.devkit.bundle;

import openfl.geom.Rectangle;
import com.domwires.core.mvc.hierarchy.IHierarchyObjectContainer;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.geom.Point;

#if useStarling
import starling.display.DisplayObject;
#else
import openfl.display.DisplayObject;
#end

interface IDisplayObject extends IHierarchyObjectContainer
{
    var assets(get, never):DisplayObject;
    var maskRect(get, set):Rectangle;
    var mask(get, set):DisplayObject;
    var pixelMask(get, set):DisplayObject;
    var pixelMaskInverted(get, set):Bool;

    var touchable(get, set):Bool;
    var x(get, set):Float;
    var y(get, set):Float;
    var width(get, set):Float;
    var height(get, set):Float;
    var alpha(get, set):Float;
    var visible(get, set):Bool;
    var scale(get, set):Float;
    var scaleX(get, set):Float;
    var scaleY(get, set):Float;
    var rotation(get, set):Float;
    var name(get, set):String;

    function drawToBitmapData(bitmapData:BitmapData = null, matrix:Matrix = null):BitmapData;

    function localToGlobal(position:Point, out:Point = null):Point;

    function globalToLocal(position:Point, out:Point = null):Point;

    function clearFilters():IDisplayObject;

    function toViewPortCenter():IDisplayObject;
}
