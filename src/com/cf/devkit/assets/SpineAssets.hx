package com.cf.devkit.assets;

import com.cf.devkit.spine.SpineAtlasLoader;
import openfl.display.BitmapData;
import openfl.utils.Assets;
import zygame.utils.load.SpineTextureAtlasLoader.SpineTextureAtals;
import zygame.utils.load.SpineTextureAtlasLoader;

class SpineAssets
{
    private static var map:Map<String, SpineVo> = new Map<String, SpineVo>();

    public static function get(path:String, skeletonPath:String = null):SpineVo
    {
        var vo:SpineVo = map.get(path);

        if (vo != null)
        {
            return vo;
        }

        var loader:SpineAtlasLoader = new SpineAtlasLoader();
        loader.clear();
        loader.atlasPath = path + ".atlas";

        loader.texPath.push(path + ".png");
        loader.texPath.push(path + "2.png");
        loader.texPath.push(path + "3.png");
        loader.texPath.push(path + "4.png");
        loader.texPath.push(path + "5.png");

        loader.load(
            (atlas:SpineTextureAtals) ->
            {
                var data:String = Assets.getText(skeletonPath == null ? path + ".json" : skeletonPath + ".json");
                vo = getVo(path, atlas, data);
                map.set(path, vo);
            }
        );

        return vo;
    }

    private static function getVo(id:String, atlas:SpineTextureAtals, jsonData:String):SpineVo
    {
        /*var temp:SkeletonAnimation = atlas.buildSpriteSkeleton(id, jsonData);
        temp.isNative = true;
        Lib.application.window.stage.addChild(temp);

        temp.play(temp.state.getData().getSkeletonData().getAnimations()[0].name);
        temp.advanceTime(0);
        temp.stop();
        temp.stopAllMovieClips();

        var matrix:Matrix = new Matrix();
        matrix.tx = temp.width / 2;
        matrix.ty = temp.height / 2;

        var bitmapData:BitmapData = new BitmapData(Math.ceil(temp.width), Math.ceil(temp.height), true, 0);
        bitmapData.draw(temp, matrix, null, null, null, true);

        temp.parent.removeChild(temp);
        temp.destroy();*/

        return new SpineVo(id, atlas, jsonData, /*bitmapData*/null);
    }

}

class SpineVo
{
    public var atlas(get, never):SpineTextureAtals;
    public var jsonData(get, never):String;
    public var id(get, never):String;
    public var previewBitmapData(get, never):BitmapData;

    private var _id:String;
    private var _atlas:SpineTextureAtals;
    private var _jsonData:String;
    private var _previewBitmapData:BitmapData;

    public function new(id:String, atlas:SpineTextureAtals, jsonData:String, previewBitmapData:BitmapData)
    {
        _id = id;
        _atlas = atlas;
        _jsonData = jsonData;
        _previewBitmapData = previewBitmapData;
    }

    private function get_atlas():SpineTextureAtals
    {
        return _atlas;
    }

    private function get_jsonData():String
    {
        return _jsonData;
    }

    private function get_id():String
    {
        return _id;
    }

    private function get_previewBitmapData():BitmapData
    {
        return _previewBitmapData;
    }
}
