package com.cf.devkit.bundle.impl.openfl;

#if !useStarling
import openfl.geom.Rectangle;
import openfl.events.MouseEvent;
import openfl.events.Event;
import com.domwires.core.mvc.message.IMessage;
import com.domwires.core.mvc.hierarchy.HierarchyObjectContainer;
import openfl.filters.BitmapFilter;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.StageQuality;
import openfl.geom.Matrix;
import openfl.geom.Point;

class OpenFLDisplayObject extends HierarchyObjectContainer implements IDisplayObject
{
    @Inject("assets")
    @Optional
    private var _assets:DisplayObject;

    public var maskRect(get, set):Rectangle;
    public var assets(get, never):DisplayObject;

    public var mask(get, set):DisplayObject;

    public var touchable(get, set):Bool;
    public var x(get, set):Float;
    public var y(get, set):Float;
    public var width(get, set):Float;
    public var height(get, set):Float;
    public var alpha(get, set):Float;
    public var visible(get, set):Bool;
    public var scale(get, set):Float;
    public var scaleX(get, set):Float;
    public var scaleY(get, set):Float;
    public var rotation(get, set):Float;
    public var name(get, never):String;

    private var emptyArray:Array<BitmapFilter> = [];

    private var mappingData:Dynamic = {};

    @PostConstruct
    private function init():Void
    {

    }

    override public function removeMessageListener(type:EnumValue, listener:IMessage -> Void):Void
    {
        super.removeMessageListener(type, listener);

        if (_assets == null)
        {
            trace("Warning: assets are null");

            return;
        }

        if (type == DisplayObjectMessageType.AddedToStage)
        {
            _assets.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
        } else
        if (type == DisplayObjectMessageType.RemovedFromStage)
        {
            _assets.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
        } else
        if (type == DisplayObjectMessageType.EnterFrame)
        {
            _assets.removeEventListener(Event.ENTER_FRAME, enterFrame);
        } else
        if (type == DisplayObjectMessageType.TouchBegan)
        {
            _assets.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
        } else
        if (type == DisplayObjectMessageType.TouchEnded)
        {
            _assets.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
        } else
        if (type == DisplayObjectMessageType.TouchOut)
        {
            _assets.removeEventListener(MouseEvent.MOUSE_OUT, mouseOut);
        } else
        if (type == DisplayObjectMessageType.TouchOver)
        {
            _assets.removeEventListener(MouseEvent.MOUSE_OVER, mouseOver);
        } else
        if (type == DisplayObjectMessageType.Click)
        {
            _assets.removeEventListener(MouseEvent.CLICK, mouseClick);
        } else
        if (type == DisplayObjectMessageType.TouchMove)
        {
            _assets.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
        }
    }

    override public function removeAllMessageListeners():Void
    {
        super.removeAllMessageListeners();

        if (_assets == null)
        {
            trace("Warning: assets are null");

            return;
        }

        _assets.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
        _assets.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
        _assets.removeEventListener(Event.ENTER_FRAME, enterFrame);
        _assets.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
        _assets.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
        _assets.removeEventListener(MouseEvent.MOUSE_OUT, mouseOut);
        _assets.removeEventListener(MouseEvent.MOUSE_OVER, mouseOver);
        _assets.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
        _assets.removeEventListener(MouseEvent.CLICK, mouseClick);
    }

    override public function addMessageListener(type:EnumValue, listener:IMessage -> Void, priority:Int = 0):Void
    {
        super.addMessageListener(type, listener, priority);

        if (_assets == null)
        {
            trace("Warning: assets are null");
        }

        if (type == DisplayObjectMessageType.AddedToStage)
        {
            _assets.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
        } else
        if (type == DisplayObjectMessageType.RemovedFromStage)
        {
            _assets.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
        } else
        if (type == DisplayObjectMessageType.EnterFrame)
        {
            _assets.addEventListener(Event.ENTER_FRAME, enterFrame);
        } else
        if (type == DisplayObjectMessageType.TouchBegan)
        {
            _assets.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
        } else
        if (type == DisplayObjectMessageType.TouchEnded)
        {
            _assets.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
        } else
        if (type == DisplayObjectMessageType.TouchOut)
        {
            _assets.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
        } else
        if (type == DisplayObjectMessageType.TouchOver)
        {
            _assets.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
        } else
        if (type == DisplayObjectMessageType.Click)
        {
            _assets.addEventListener(MouseEvent.CLICK, mouseClick);
        } else
        if (type == DisplayObjectMessageType.TouchMove)
        {
            _assets.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
        }
    }

    private function mouseMove(e:MouseEvent):Void
    {
        mappingData.x = _assets.mouseX;
        mappingData.y = _assets.mouseY;

        dispatchMessage(DisplayObjectMessageType.TouchMove, mappingData);
    }

    private function mouseDown(e:MouseEvent):Void
    {
        dispatchMessage(DisplayObjectMessageType.TouchBegan);
    }

    private function mouseUp(e:MouseEvent):Void
    {
        dispatchMessage(DisplayObjectMessageType.TouchEnded);
    }

    private function mouseOut(e:MouseEvent):Void
    {
        dispatchMessage(DisplayObjectMessageType.TouchOut);
    }

    private function mouseOver(e:MouseEvent = null):Void
    {
        dispatchMessage(DisplayObjectMessageType.TouchOver);
    }

    private function mouseClick(e:MouseEvent):Void
    {
        dispatchMessage(DisplayObjectMessageType.Click);
    }

    private function enterFrame(e:Event):Void
    {
        dispatchMessage(DisplayObjectMessageType.EnterFrame);
    }

    private function removedFromStage(e:Event):Void
    {
        dispatchMessage(DisplayObjectMessageType.RemovedFromStage);
    }

    private function addedToStage(e:Event):Void
    {
        dispatchMessage(DisplayObjectMessageType.AddedToStage);
    }

    override public function dispose():Void
    {
        if (_assets != null)
        {
            if (_assets.parent != null)
            {
                _assets.parent.removeChild(_assets);
            }

            _assets.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
            _assets.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
            _assets.removeEventListener(Event.ENTER_FRAME, enterFrame);
            _assets.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
            _assets.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
            _assets.removeEventListener(MouseEvent.MOUSE_OUT, mouseOut);
            _assets.removeEventListener(MouseEvent.MOUSE_OVER, mouseOver);
            _assets.removeEventListener(MouseEvent.CLICK, mouseClick);
            _assets.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);

            _assets = null;
        }

        super.dispose();
    }

    public function localToGlobal(position:Point, out:Point = null):Point
    {
        var result:Point = _assets.localToGlobal(position);
        if (out == null)
        {
            return result;
        }

        out.x = result.x;
        out.y = result.y;

        return out;
    }

    public function globalToLocal(position:Point, out:Point = null):Point
    {
        var result:Point = _assets.globalToLocal(position);
        if (out == null)
        {
            return result;
        }

        out.x = result.x;
        out.y = result.y;

        return out;
    }

    public function drawToBitmapData(bitmapData:BitmapData = null, matrix:Matrix = null):BitmapData
    {
        if (bitmapData == null)
        {
            bitmapData = new BitmapData(Std.int(width), Std.int(height), true, 0);
        }

        bitmapData.drawWithQuality(_assets, matrix, null, null, null, true, StageQuality.BEST);

        return bitmapData;
    }

    public function clearFilters():IDisplayObject
    {
        _assets.filters = emptyArray;

        return this;
    }

    private function get_x():Float
    {
        return _assets.x;
    }

    private function get_y():Float
    {
        return _assets.y;
    }

    private function get_width():Float
    {
        return _assets.width;
    }

    private function get_height():Float
    {
        return _assets.height;
    }

    private function get_alpha():Float
    {
        return _assets.alpha;
    }

    private function get_visible():Bool
    {
        return _assets.visible;
    }

    private function get_scale():Float
    {
        return _assets.scaleX;
    }

    private function get_scaleX():Float
    {
        return _assets.scaleX;
    }

    private function get_scaleY():Float
    {
        return _assets.scaleY;
    }

    private function set_x(value:Float):Float
    {
        return _assets.x = value;
    }

    private function set_y(value:Float):Float
    {
        return _assets.y = value;
    }

    private function set_width(value:Float):Float
    {
        return _assets.width = value;
    }

    private function set_height(value:Float):Float
    {
        return _assets.height = value;
    }

    private function set_alpha(value:Float):Float
    {
        return _assets.alpha = value;
    }

    private function set_visible(value:Bool):Bool
    {
        return _assets.visible = value;
    }

    private function set_scale(value:Float):Float
    {
        _assets.scaleX = _assets.scaleY = value;

        return value;
    }

    private function set_scaleX(value:Float):Float
    {
        return _assets.scaleX = value;
    }

    private function set_scaleY(value:Float):Float
    {
        return _assets.scaleY = value;
    }

    private function get_assets():DisplayObject
    {
        return _assets;
    }

    private function get_rotation():Float
    {
        return _assets.rotation;
    }

    private function set_rotation(value:Float):Float
    {
        return _assets.rotation = value;
    }

    private function get_touchable():Bool
    {
        return false;
    }

    private function set_touchable(value:Bool):Bool
    {
        return value;
    }

    private function get_maskRect():Rectangle
    {
        return _assets.scrollRect;
    }

    private function set_maskRect(value:Rectangle):Rectangle
    {
        return _assets.scrollRect = value;
    }

    private function get_mask():DisplayObject
    {
        return _assets.mask;
    }

    private function set_mask(value:DisplayObject):DisplayObject
    {
        return _assets.mask = value;
    }

    private function get_name():String
    {
        return _assets.name;
    }
}
#end