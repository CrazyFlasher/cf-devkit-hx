package com.cf.devkit.bundle.impl.starling;

import com.domwires.core.utils.ArrayUtils;
import com.cf.devkit.starling.display.Line;
import starling.geom.Polygon;
import openfl.geom.Point;
import starling.display.Canvas;
import com.domwires.core.mvc.hierarchy.IHierarchyObject;
import starling.display.DisplayObject;
import com.cf.devkit.trace.Trace;
import starling.display.DisplayObjectContainer;

class StarlingContainer extends StarlingDisplayObject implements IContainer
{
	@Inject("canvas")
	private var _canvas:DisplayObjectContainer;
	
	public var canvas(get, never):DisplayObjectContainer;

	@:allow(com.cf.devkit.bundle.impl.starling.StarlingContainer)
	private var movieMap:Map<String, IMovieClip> = new Map<String, IMovieClip>();

	@:allow(com.cf.devkit.bundle.impl.starling.StarlingContainer)
	private var textFieldMap:Map<String, ITextField> = new Map<String, ITextField>();

	@:allow(com.cf.devkit.bundle.impl.starling.StarlingContainer)
	private var displayObjectMap:Map<String, IDisplayObject> = new Map<String, IDisplayObject>();

	@:allow(com.cf.devkit.bundle.impl.starling.StarlingContainer)
	private var spineMap:Map<String, ISpineClip> = new Map<String, ISpineClip>();

	@:allow(com.cf.devkit.bundle.impl.starling.StarlingContainer)
	private var dragonBonesMap:Map<String, IDragonBonesClip> = new Map<String, IDragonBonesClip>();

	@:allow(com.cf.devkit.bundle.impl.starling.StarlingContainer)
	private var particleMap:Map<String, IParticleClip> = new Map<String, IParticleClip>();

	@:allow(com.cf.devkit.bundle.impl.starling.StarlingContainer)
	private var sheetMap:Map<String, ISheetClip> = new Map<String, ISheetClip>();

	private var nullNameIndex:Int = 0;

	private var graphics:Canvas;
	private var lineList:Array<Line>;

	override private function init():Void
	{
		_assets = _canvas;

		super.init();
	}

	override public function dispose():Void
	{
		clearGraphics();

		lineList = null;

		super.dispose();
	}

	private function get_canvas():DisplayObjectContainer
	{
		return _canvas;
	}

	public function hasDisplayObject(name:String):Bool
	{
		return
			displayObjectMap.exists(name) ||
			movieMap.exists(name) ||
			textFieldMap.exists(name) ||
			spineMap.exists(name) ||
			dragonBonesMap.exists(name) ||
			particleMap.exists(name) ||
			sheetMap.exists(name);
	}

	private function getFromMap<T>(map:Map<String, T>, name):T
	{
		if (!map.exists(name))
		{
			trace("Not found: " + name, Trace.WARNING);
			return null;
		}

		return map.get(name);
	}

	public function getSheetClip(name:String = null):ISheetClip
	{
		if (name == null)
		{
			for (clip in sheetMap.iterator())
			{
				return clip;
			}
		}

		return getFromMap(sheetMap, name);
	}

	public function getSpineClip(name:String = null):ISpineClip
	{
		if (name == null)
		{
			for (clip in spineMap.iterator())
			{
				return clip;
			}
		}

		return getFromMap(spineMap, name);
	}

	public function getDragonBonesClip(name:String = null):IDragonBonesClip
	{
		if (name == null)
		{
			for (clip in dragonBonesMap.iterator())
			{
				return clip;
			}
		}

		return getFromMap(dragonBonesMap, name);
	}

	public function getParticleClip(name:String = null):IParticleClip
	{
		if (name == null)
		{
			for (clip in particleMap.iterator())
			{
				return clip;
			}
		}

		return getFromMap(particleMap, name);
	}

	public function getMovieClip(name:String):IMovieClip
	{
		return getFromMap(movieMap, name);
	}

	public function getTextField(name:String):ITextField
	{
		return getFromMap(textFieldMap, name);
	}

	public function getDisplayObject(name:String):IDisplayObject
	{
		if (displayObjectMap.exists(name)) return displayObjectMap.get(name);
		if (movieMap.exists(name)) return movieMap.get(name);
		if (textFieldMap.exists(name)) return textFieldMap.get(name);
		if (spineMap.exists(name)) return spineMap.get(name);
		if (dragonBonesMap.exists(name)) return dragonBonesMap.get(name);
		if (particleMap.exists(name)) return particleMap.get(name);
		if (sheetMap.exists(name)) return sheetMap.get(name);

		trace("Not found: " + name, Trace.WARNING);

		return null;
	}

	public function getChild(name:String):DisplayObject
	{
		var child:DisplayObject = canvas.getChildByName(name);

		if (child == null)
		{
			trace("Not found: " + name, Trace.WARNING);
		}

		return child;
	}

	public function addChild(value:IDisplayObject, index:Int = -1):IContainer
	{
		add(value, index);

		return this;
	}

	public function removeChild(value:IDisplayObject, dispose:Bool = true):IContainer
	{
		remove(value, dispose);

		return this;
	}

	public function removeChildren(dispose:Bool = true):IContainer
	{
		for (child in movieMap.iterator()) remove(child, dispose);
		for (child in textFieldMap.iterator()) remove(child, dispose);
		for (child in spineMap.iterator()) remove(child, dispose);
		for (child in dragonBonesMap.iterator()) remove(child, dispose);
		for (child in particleMap.iterator()) remove(child, dispose);
		for (child in sheetMap.iterator()) remove(child, dispose);
		for (child in displayObjectMap.iterator()) remove(child, dispose);

		return this;
	}

	public function swapZ(a:IDisplayObject, b:IDisplayObject):IContainer
	{
		canvas.swapChildren(a.assets, b.assets);

		var aIndex:Int = _childrenList.indexOf(a);
		var bIndex:Int = _childrenList.indexOf(b);

		_childrenList[aIndex] = b;
		_childrenList[bIndex] = a;

		_childrenListImmutable[aIndex] = b;
		_childrenListImmutable[bIndex] = a;

		return this;
	}

	@:allow(com.cf.devkit.bundle.impl.starling.StarlingContainer)
	override public function remove(child:IHierarchyObject, dispose:Bool = false):Bool
	{
		var displayObject:IDisplayObject = cast child;
		var name:String = displayObject.name;

		getMap(displayObject, true).remove(name);

		canvas.removeChild(displayObject.assets, dispose);

		super.remove(child, dispose);

		return true;
	}

	@:allow(com.cf.devkit.bundle.impl.starling.StarlingContainer)
	override public function add(child:IHierarchyObject, index:Int = -1):Bool
	{
		var displayObject:IDisplayObject = cast child;
		var name:String = displayObject.name;

		if (name == null)
		{
			name = "child_" + nullNameIndex;
			nullNameIndex++;
		}

		var map = getMap(displayObject, false);

		//TODO: check, why in case of flipbook there are either Image and Sprite
		if(_contains(map, name, displayObject))
		{
			throw haxe.io.Error.Custom("Current IContainer already contains object with name '" + name + "'");
		}

		if (displayObject.parent != null)
		{
			getMap(displayObject, true).remove(name);
		}

		super.add(child, index);

		map.set(name, cast displayObject);

		index >= 0 ? canvas.addChildAt(displayObject.assets, index) : canvas.addChild(displayObject.assets);

		return true;
	}

	private function _contains(map:Map<String, IDisplayObject>, name:String, child:IDisplayObject):Bool
	{
		return map.exists(name) && map.get(name) != child;
	}

	private function getMap<T>(displayObject:IDisplayObject, parentMap:Bool):Map<String, T>
	{
		var parent:StarlingContainer = cast displayObject.parent;

		if(Std.is(displayObject, IMovieClip)) return cast (parentMap ? parent.movieMap : movieMap);
		if(Std.is(displayObject, ITextField)) return cast (parentMap ? parent.textFieldMap : textFieldMap);
		if(Std.is(displayObject, ISpineClip)) return cast (parentMap ? parent.spineMap : spineMap);
		if(Std.is(displayObject, IDragonBonesClip)) return cast (parentMap ? parent.dragonBonesMap : dragonBonesMap);
		if(Std.is(displayObject, IParticleClip)) return cast (parentMap ? parent.particleMap : particleMap);
		if(Std.is(displayObject, ISheetClip)) return cast (parentMap ? parent.sheetMap : sheetMap);

		return cast (parentMap ? parent.displayObjectMap : displayObjectMap);
	}

	override private function set_touchable(value:Bool):Bool
	{
		super.set_touchable(value);

		setChildrenTouchable(_canvas, value);

		return value;
	}

	private function setChildrenTouchable(container:DisplayObjectContainer, value:Bool):Void
	{
		var l:Int = 0;
		var child:DisplayObject;
		
		while (l < container.numChildren)
		{
			child = container.getChildAt(l);
			child.touchable = value;
			
			if (Std.is(child, DisplayObjectContainer))
			{
				setChildrenTouchable(cast child, value);
			}
			
			l++;
		}
	}

	private function createCanvas():Void
	{
		if (graphics == null)
		{
			graphics = new Canvas();
			_canvas.addChild(graphics);
		}
	}

	public function clearGraphics():IDisplayObject
	{
		if (graphics == null) return this;
		if (lineList != null)
		{
			for (line in lineList)
			{
				line.removeFromParent(true);
			}

			ArrayUtils.clear(lineList);
		}

		graphics.clear();

		return this;
	}

	public function beginFill(color:UInt = 0xffffff, alpha:Float = 1.0):IDisplayObject
	{
		createCanvas();

		graphics.beginFill(color, alpha);

		return this;
	}

	public function drawLines(vertexList:Array<Point>, color:UInt = 0xffffff, alpha:Float = 1.0,
							  thickness:Float = 1, roundedCorners:Bool = true):IDisplayObject
	{
		createCanvas();

		if (lineList == null)
		{
			lineList = [];
		}

		for (i in 0...vertexList.length - 1)
		{
			var line:Line = new Line(thickness, color, roundedCorners);

			line.x = vertexList[i].x;
			line.y = vertexList[i].y;

			line.lineTo(vertexList[i + 1].x, vertexList[i + 1].y);

			graphics.addChild(line);
		}

		return this;
	}

	public function endFill():IDisplayObject
	{
		if (graphics == null) return this;

		graphics.endFill();

		return this;
	}

	public function drawPolygon(vertexList:Array<Point>):IDisplayObject
	{
		graphics.drawPolygon(new Polygon(vertexList));

		return this;
	}

	public function drawRectangle(x:Float, y:Float, width:Float, height:Float):IDisplayObject
	{
		graphics.drawRectangle(x, y, width, height);

		return this;
	}

	public function drawEllipse(x:Float, y:Float, width:Float, height:Float):IDisplayObject
	{
		graphics.drawEllipse(x, y, width, height);

		return this;
	}

	public function drawCircle(x:Float, y:Float, radius:Float):IDisplayObject
	{
		graphics.drawCircle(x, y, radius);

		return this;
	}
}
