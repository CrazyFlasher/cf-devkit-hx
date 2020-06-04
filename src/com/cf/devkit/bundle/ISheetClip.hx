package com.cf.devkit.bundle;

interface ISheetClip extends IDisplayObject
{
    var frameRate(get, set):Int;
    var currentFrame(get, never):Int;
    var totalFrames(get, never):Int;
    var isPlaying(get, never):Bool;

    function gotoAndPlay(frame:Int):ISheetClip;
    function gotoAndStop(frame:Int):ISheetClip;
    function nextFrame():ISheetClip;
    function prevFrame():ISheetClip;
    function play(loop:Bool = true):ISheetClip;
    function stop():ISheetClip;
    function addFrameScript(frameIndex:Int, callBack:Void -> Void):ISheetClip;
    function setAssetId(assetId:String):ISheetClip;
}
