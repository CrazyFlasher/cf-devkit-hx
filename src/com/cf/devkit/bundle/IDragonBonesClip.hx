package com.cf.devkit.bundle;

interface IDragonBonesClip extends IDisplayObject
{
    var currentAnim(get, never):String;
    var timeScale(get, set):Float;
    
    #if useStarling
    var display(get, never):dragonBones.starling.StarlingArmatureDisplay;
    #else
    var display(get, never):dragonBones.openfl.OpenFLArmatureDisplay;
    #end

    function advanceTime(value:Float):Void;
    function showAndStop(animId:String):Void;
    function play(loop:Bool = true, animId:String = null, onComplete:Void -> Void = null, fadeInTime:Float = 0.0):Void;
    function stop():Void;
    function getAnimDuration(animId:String = null):Float;
    function setAssetId(textureId:String, skeletonId:String = null, textureConfigId:String = null):Void;
    function getAnimIdList():Array<String>;
}
