package com.cf.devkit.bundle.impl.starling;

#if useStarling
import starling.core.Starling;
import starling.extensions.pixelmask.PixelMaskDisplayObject;
import com.cf.devkit.trace.Trace;
import starling.utils.RectangleUtil;
import starling.display.Stage;
import openfl.geom.Rectangle;
import starling.display.DisplayObjectContainer;
import starling.display.Sprite;
import starling.display.Quad;
import starling.events.TouchPhase;
import starling.events.Touch;
import starling.events.TouchEvent;
import com.domwires.core.mvc.hierarchy.HierarchyObjectContainer;
import com.domwires.core.mvc.message.IMessage;
import openfl.display.BitmapData;
import starling.display.DisplayObject;
import starling.events.Event;
import openfl.geom.Matrix;
import openfl.geom.Point;

@:keep
class StarlingDisplayObject extends HierarchyObjectContainer implements IDisplayObject
{
    @Inject("assets")
    @Optional
    private var _assets:DisplayObject;

    public var maskRect(get, set):Rectangle;
    private var _maskRect:Rectangle;
    private var maskQuad:Quad;

    public var mask(get, set):DisplayObject;
    public var pixelMask(get, set):DisplayObject;
    public var pixelMaskInverted(get, set):Bool;

    private var pixelMaskContainer:PixelMaskDisplayObject;
    private var _pixelMaskInverted:Bool;

    public var assets(get, never):DisplayObject;

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
    public var name(get, set):String;

    private var _name:String;

    private var mappingData:Dynamic = {};

    private var pointHelper:Point = new Point();
    private var stageBounds:Rectangle = new Rectangle();

    private var isHovering:Bool;
    private var isTouching:Bool;

    @PostConstruct
    private function init():Void
    {
        if (_assets != null)
        {
            if (_name != null)
            {
                _assets.name = name;
            } else
            {
                _name = _assets.name;
            }

            _assets.touchable = false;

            if (_assets.name != null)
            {
                var index:Int = _assets.name.lastIndexOf("/");
                if (index > 0)
                {
                    name = _assets.name.substr(index + 1, _assets.name.length);
                }
            }
        }
    }

    override public function removeMessageListener(type:EnumValue, listener:IMessage -> Void):Void
    {
        super.removeMessageListener(type, listener);

        if (_assets != null)
        {
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
            if (!hasTouchRelatedListeners())
            {
                _assets.removeEventListener(TouchEvent.TOUCH, onTouch);
            }
        }
    }

    private function hasTouchRelatedListeners():Bool{
        return
            hasMessageListener(DisplayObjectMessageType.TouchMove) ||
            hasMessageListener(DisplayObjectMessageType.TouchBegan) ||
            hasMessageListener(DisplayObjectMessageType.TouchEnded) ||
            hasMessageListener(DisplayObjectMessageType.TouchOut) ||
            hasMessageListener(DisplayObjectMessageType.TouchOver) ||
            hasMessageListener(DisplayObjectMessageType.Click);
    }

    override public function removeAllMessageListeners():Void
    {
        super.removeAllMessageListeners();

        if (_assets == null)
        {
            trace("Warning: assets are null");
        } else
        {
            _assets.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
            _assets.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
            _assets.removeEventListener(Event.ENTER_FRAME, enterFrame);
            _assets.removeEventListener(TouchEvent.TOUCH, onTouch);
        }
    }

    override public function addMessageListener(type:EnumValue, listener:IMessage -> Void, priority:Int = 0):Void
    {
        super.addMessageListener(type, listener, priority);

        if (_assets != null)
        {
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
            if (
                type == DisplayObjectMessageType.TouchMove ||
                type == DisplayObjectMessageType.TouchBegan ||
                type == DisplayObjectMessageType.TouchEnded ||
                type == DisplayObjectMessageType.TouchOut ||
                type == DisplayObjectMessageType.TouchOver ||
                type == DisplayObjectMessageType.Click
            )
            {
                if (!_assets.hasEventListener(TouchEvent.TOUCH, onTouch))
                {
                    _assets.addEventListener(TouchEvent.TOUCH, onTouch);
                }

                if (!_assets.touchable)
                {
                    touchable = true;

                    if (Std.is(_assets, DisplayObjectContainer))
                    {
                        var c:DisplayObjectContainer = cast _assets;

                        var l:Int = 0;
                        while (l < c.numChildren)
                        {
                            c.getChildAt(l).touchable = true;
                            l++;
                        }
                    }

                    if (_assets.parent != null)
                    {
                        setParentsTouchable();
                    } else
                    {
                        if (!_assets.hasEventListener(Event.ADDED_TO_STAGE))
                        {
                            _assets.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
                        }
                    }
                }
            }
        }
    }

    private function setParentsTouchable():Void
    {
        var parent:DisplayObjectContainer = _assets.parent;

        while (parent != null)
        {
            parent.touchable = true;
            parent = parent.parent;
        }
    }

    private function onTouch(e:TouchEvent):Void
    {
        if (!isTouching)
        {
            if (isHovering && hasMessageListener(DisplayObjectMessageType.TouchOut) && !e.interactsWith(_assets))
            {
                isHovering = false;

                mouseOut();
            } else
            if (!isHovering && hasMessageListener(DisplayObjectMessageType.TouchOver) && e.interactsWith(_assets))
            {
                isHovering = true;

                mouseOver();
            }
        }

        var touch:Touch = e.getTouch(_assets);

        if (touch != null)
        {
            if (touch.phase == TouchPhase.BEGAN && (hasMessageListener(DisplayObjectMessageType.TouchBegan) ||
                hasMessageListener(DisplayObjectMessageType.Click)))
            {
                isTouching = true;

                mouseDown(touch);
            } else
            if ((touch.phase == TouchPhase.MOVED || touch.phase == TouchPhase.HOVER) && hasMessageListener(DisplayObjectMessageType.TouchMove))
            {
                mouseMove(touch);
            } else
            if (touch.phase == TouchPhase.ENDED && (hasMessageListener(DisplayObjectMessageType.TouchEnded) ||
                hasMessageListener(DisplayObjectMessageType.Click)))
            {
                isHovering = isTouching = false;

                mouseUp(touch);
            }
        }
    }

    private function mouseMove(touch:Touch):Void
    {
        touch.getLocation(_assets, pointHelper);

        mappingData.x = pointHelper.x;
        mappingData.y = pointHelper.y;

        trace("TouchMove");
        dispatchMessage(DisplayObjectMessageType.TouchMove, mappingData);
    }

    private function mouseDown(touch:Touch):Void
    {
        trace("TouchBegan");
        dispatchMessage(DisplayObjectMessageType.TouchBegan);
    }

    private function mouseUp(touch:Touch):Void
    {
        trace("TouchEnded");
        dispatchMessage(DisplayObjectMessageType.TouchEnded);

        if (hasMessageListener(DisplayObjectMessageType.Click) && _assets.stage != null)
        {
            touch.getLocation(_assets.stage, pointHelper);
            _assets.getBounds(_assets.stage, stageBounds);

            if (stageBounds.contains(pointHelper.x, pointHelper.y))
            {
                mouseClick();
            }
        }
    }

    private function mouseOut():Void
    {
        trace("TouchOut");

        dispatchMessage(DisplayObjectMessageType.TouchOut);
    }

    private function mouseOver():Void
    {
        trace("TouchOver");

        dispatchMessage(DisplayObjectMessageType.TouchOver);
    }

    private function mouseClick():Void
    {
        trace("Click");
        dispatchMessage(DisplayObjectMessageType.Click);
    }

    private function enterFrame():Void
    {
        dispatchMessage(DisplayObjectMessageType.EnterFrame);
    }

    private function removedFromStage():Void
    {
        dispatchMessage(DisplayObjectMessageType.RemovedFromStage);
    }

    private function addedToStage():Void
    {
        if (_assets.touchable)
        {
            setParentsTouchable();
        }

        dispatchMessage(DisplayObjectMessageType.AddedToStage);
    }

    override public function dispose():Void
    {
        clearFilters();

        maskQuad = null;

        if (_assets != null)
        {
            if (_assets.parent != null)
            {
                _assets.removeFromParent();
            }

            _assets.removeEventListeners();
            _assets.dispose();
            _assets = null;
        }

        super.dispose();
    }

    public function localToGlobal(position:Point, out:Point = null):Point
    {
        return _assets.localToGlobal(position, out);
    }

    public function globalToLocal(position:Point, out:Point = null):Point
    {
        return _assets.globalToLocal(position, out);
    }

    public function drawToBitmapData(bitmapData:BitmapData = null, matrix:Matrix = null):BitmapData
    {
        //TODO: handle ty, tx

        var originScaleX:Float = scaleX;
        var originScaleY:Float = scaleY;
        var originX:Float = x;
        var originY:Float = y;
        var originPivotX:Float = _assets.pivotX;
        var originPivotY:Float = _assets.pivotY;
        var originMask:DisplayObject = _assets.mask;
        var s:Sprite = new Sprite();
        s.x = x;
        s.y = y;
        x = y = 0;
        scaleX = scaleY = 1;
        _assets.pivotX = _assets.pivotY = 0;
        _assets.mask = null;

        var parent:DisplayObjectContainer;
        var index:Int;

        if (matrix != null)
        {
            scaleX = matrix.a;
            scaleY = matrix.d;
            if (matrix.tx != 0 || matrix.ty != 0)
            {
                var quad = new Quad(width + matrix.tx * 2, height + matrix.ty * 2, 0);
                quad.visible = false;
                s.addChild(quad);
                x += matrix.tx;
                y += matrix.ty;
            }
        }

        var stage:Stage = _assets.stage;

        parent = _assets.parent;
        index = parent.getChildIndex(_assets);
        s.addChild(_assets);
        stage.addChild(s);

        if (stage.stageWidth < s.width || stage.stageHeight < s.height)
        {
            trace("Warning! Bitmap is larger than Starling stage! ", Trace.WARNING);
        }

        bitmapData = s.drawToBitmapData(bitmapData);
        parent.addChildAt(_assets, index);
        s.removeFromParent(true);

        scaleX = originScaleX;
        scaleY = originScaleY;
        x = originX;
        y = originY;
        _assets.pivotX = originPivotX;
        _assets.pivotY = originPivotY;
        _assets.mask = originMask;

        return bitmapData;
    }

    public function clearFilters():IDisplayObject
    {
        //TODO: consider filter chain

        if (_assets.filter != null)
        {
            _assets.filter.dispose();
            _assets.filter = null;
        }

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
        return _assets.touchable;
    }

    private function set_touchable(value:Bool):Bool
    {
        if (!value)
        {
            isHovering = isTouching = false;
        }

        return _assets.touchable = value;
    }

    private function get_maskRect():Rectangle
    {
        return _maskRect;
    }

    private function set_maskRect(value:Rectangle):Rectangle
    {
        _maskRect = value;

        if (value == null)
        {
            _assets.mask = null;

            maskQuad = null;
        } else
        {
            if (maskQuad == null)
            {
                maskQuad = new Quad(value.width, value.height, 0);
            }

            maskQuad.x = value.x;
            maskQuad.y = value.y;

            if (_assets.mask == null)
            {
                _assets.mask = maskQuad;
            }
        }

        return value;
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
        return _name;
    }

    private function set_name(value:String):String
    {
        if (parent != null)
        {
            throw haxe.io.Error.Custom("Please, specify name before adding to heirarchy!");
        }

        _name = value;

        if (_assets != null)
        {
            _assets.name = _name;
        }

        return value;
    }

    private function get_pixelMask():DisplayObject
    {
        return pixelMaskContainer == null ? null : pixelMaskContainer.pixelMask;
    }

    private function set_pixelMask(value:DisplayObject):DisplayObject
    {
        if (pixelMaskContainer == null)
        {
            var index:Int = 0;
            var parent:DisplayObjectContainer = null;
            if (_assets.parent != null)
            {
                parent = _assets.parent;
                index = parent.getChildIndex(_assets);
            }

            pixelMaskContainer = new PixelMaskDisplayObject();

            if (parent != null)
            {
                parent.addChildAt(pixelMaskContainer, index);
            }

            pixelMaskContainer.addChild(_assets);
            pixelMaskContainer.touchable = _assets.touchable;

            _assets = pixelMaskContainer;

            pixelMaskContainer.inverted = _pixelMaskInverted;
        }

        return pixelMaskContainer.pixelMask = value;
    }

    private function get_pixelMaskInverted():Bool
    {
        return _pixelMaskInverted;
    }

    private function set_pixelMaskInverted(value:Bool):Bool
    {
        _pixelMaskInverted = value;

        if (pixelMaskContainer != null)
        {
            pixelMaskContainer.inverted = _pixelMaskInverted;
        }

        return value;
    }

    public function toViewPortCenter():IDisplayObject
    {
        if (parent == null)
        {
            throw haxe.io.Error.Custom("Object should be in display list!");
        }

        var stage:Stage = Starling.current.stage;
        pointHelper.x = stage.stageWidth / 2;
        pointHelper.y = stage.stageHeight / 2;

        var parentContainer:IContainer = cast parent;
        parentContainer.globalToLocal(pointHelper, pointHelper);

        x = pointHelper.x;
        y = pointHelper.y;

        return this;
    }
}
#end