package com.cf.devkit.starling.display;

import starling.display.Canvas;
import starling.display.Mesh;
import starling.display.Quad;
import starling.display.Sprite;

class Line extends Sprite
{
    public var color(get, set):Int;
    public var thickness(get, set):Float;

    private var baseQuad:Quad;
    private var _thickness:Float;
    private var _color:Int;

    private var roundedCorners:Bool;

    public var leftRound(get, never):Canvas;
    public var rightRound(get, never):Canvas;

    private var _leftRound:Canvas;
    private var _rightRound:Canvas;

    public function new(thickness:Float = 1.0, color:Int = 0, roundedCorners:Bool = true)
    {
        super();

        _thickness = thickness;
        _color = color;
        this.roundedCorners = roundedCorners;

        createCorners();

        baseQuad = new Quad(2, _thickness, _color);
        addChild(baseQuad);
    }

    private function createCorners():Void
    {
        if (_leftRound != null)
        {
            _leftRound.removeFromParent(true);
            _rightRound.removeFromParent(true);
        }

        _leftRound = drawCircle();
        _rightRound = drawCircle();

        addChild(_leftRound);
        addChild(_rightRound);

        if (!roundedCorners)
        {
            _leftRound.visible = _rightRound.visible = false;
        }
    }

    private function drawCircle():Canvas
    {
        var canvas:Canvas = new Canvas();

        canvas.beginFill(_color);
        canvas.drawCircle(0, 0, thickness / 2);
        canvas.endFill();

        return canvas;
    }

    public function lineTo(toX:Float, toY:Float):Void
    {
        var toX2:Float = toX - this.x;
        var toY2:Float = toY - this.y;
        baseQuad.rotation = 0;
        baseQuad.pivotY = thickness / 2;
        baseQuad.width = Math.round(Math.sqrt((toX2 * toX2) + (toY2 * toY2)));
        baseQuad.rotation = Math.atan2(toY2, toX2);

        _rightRound.x = toX2;
        _rightRound.y = toY2;
    }

    private function set_thickness(value:Float):Float
    {
        var currentRotation:Float = baseQuad.rotation;
        baseQuad.rotation = 0;
        baseQuad.height = _thickness = value;
        baseQuad.rotation = currentRotation;

        createCorners();

        return value;
    }

    private function get_thickness():Float
    {
        return _thickness;
    }

    private function set_color(value:Int):Int
    {
        baseQuad.color = _color = value;

        return value;
    }

    private function get_color():Int
    {
        return _color;
    }

    private function get_leftRound():Canvas
    {
        return _leftRound;
    }

    private function get_rightRound():Canvas
    {
        return _rightRound;
    }
}
