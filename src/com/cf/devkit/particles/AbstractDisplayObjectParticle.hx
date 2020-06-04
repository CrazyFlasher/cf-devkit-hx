// =================================================================================================
//
//	Starling Framework - Particle System Extension
//	Copyright Gamua GmbH. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package com.cf.devkit.particles;

import com.cf.devkit.bundle.IDisplayObject;

class AbstractDisplayObjectParticle
{
    public var x(get, set):Float;
    public var y(get, set):Float;
    public var scale(get, set):Float;
    public var rotation(get, set):Float;
    public var alpha(get, set):Float;
    public var currentTime(get, set):Float;
    public var totalTime:Float;
    public var width(get, never):Float;

    public var assets(get, never):IDisplayObject;

    private var _assets:IDisplayObject;
    private var _currentTime:Float;
    private var _width:Float;

    public function new(assets:IDisplayObject)
    {
        _assets = assets;
        _assets.touchable = false;

        _width = _assets.width;

        x = y = rotation = currentTime = 0.0;
        totalTime = alpha = scale = 1.0;
    }

    function get_x():Float
    {
        return _assets.x;
    }

    function get_y():Float
    {
        return _assets.y;
    }

    function get_scale():Float
    {
        return _assets.scale;
    }

    function get_rotation():Float
    {
        return _assets.rotation;
    }

    function get_alpha():Float
    {
        return _assets.alpha;
    }

    function set_alpha(value:Float):Float
    {
        return _assets.alpha = value;
    }

    function set_rotation(value:Float):Float
    {
        return _assets.rotation = value;
    }

    function set_scale(value:Float):Float
    {
        return _assets.scale = value;
    }

    function set_y(value:Float):Float
    {
        return _assets.y = value;
    }

    function set_x(value:Float):Float
    {
        return _assets.x = value;
    }

    function get_assets():IDisplayObject
    {
        return _assets;
    }

    function get_width():Float
    {
        return _width;
    }

    function get_currentTime():Float
    {
        return _currentTime;
    }

    function set_currentTime(value:Float):Float
    {
        _currentTime = value;

        _assets.visible = _currentTime < totalTime && _currentTime > 0;

        return value;
    }
}