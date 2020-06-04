package com.cf.devkit.bundle;

import spine.Animation;

@:keep
interface ISpineClip extends IDisplayObject
{
    var currentAnim(get, never):String;
    var timeScale(get, set):Float;
    var isPlaying(get, never):Bool;

    function showAndStop(animId:String):Void;
    function play(loop:Bool = true, animId:String = null, onComplete:Void -> Void = null):Void;
    function stop():Void;
    function getAnimDuration(animId:String = null):Float;
    function getAnim(animId:String = null):Animation;
    function setAssetId(assetId:String, skeletonId:String = null):Void;
    function getAnimIdList():Array<String>;
    function setBlendTime(value:Float):Void;

    #if !useStarling
    var animTile(get, never):spine.tilemap.SkeletonAnimation;
    var animSprite(get, never):spine.openfl.SkeletonAnimation;
    #else
    var animSprite(get, never):spine.starling.SkeletonAnimation;
    #end
}
