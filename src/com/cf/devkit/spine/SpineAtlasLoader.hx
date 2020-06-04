package com.cf.devkit.spine;

import openfl.utils.AssetType;
import openfl.display.BitmapData;
import openfl.utils.Assets;
import zygame.utils.load.SpineTextureAtlasLoader.SpineTextureAtals;
import zygame.utils.load.SpineTextureAtlasLoader;
import zygame.utils.StringUtils;

class SpineAtlasLoader
{
    public var atlasPath(get, set):String;
    public var texPath(get, set):Array<String>;

    private var _texPath:Array<String> = new Array<String>();
    private var _texMap:Map<String, BitmapData> = new Map<String, BitmapData>();
    private var _atlasPath:String;
    private var _call:SpineTextureAtals -> Void;

    private var loadedTexCount:Int;

    public function new()
    {

    }

    public function clear():Void
    {
        while (_texPath.length > 0) _texPath.pop();
    }

    public function load(call:SpineTextureAtals -> Void)
    {
        loadedTexCount = 0;

        _call = call;

        _texMap.clear();

        next();
    }

    public function next():Void
    {
        if (_texPath.length > 0)
        {
            var path:String = cast(_texPath.shift());

            var bitmapData:BitmapData = Assets.cache.getBitmapData(path);
            if (bitmapData == null)
            {
                if (Assets.exists(path, AssetType.IMAGE))
                {
                    bitmapData = Assets.getBitmapData(path);
                    Assets.cache.setBitmapData(path, bitmapData);
                }
            }
            loadedTexCount++;

            _texMap.set(StringUtils.getName(path), bitmapData);

            next();
        } else
        {
            var spine:SpineTextureAtals = new SpineTextureAtals(_texMap, Assets.getText(_atlasPath));
            spine.path = _atlasPath;
            _call(spine);
        }
    }

    private function set_atlasPath(value:String):String
    {
        return _atlasPath = value;
    }

    private function set_texPath(value:Array<String>):Array<String>
    {
        return _texPath = value;
    }

    private function get_atlasPath():String
    {
        return _atlasPath;
    }

    private function get_texPath():Array<String>
    {
        return _texPath;
    }
}
