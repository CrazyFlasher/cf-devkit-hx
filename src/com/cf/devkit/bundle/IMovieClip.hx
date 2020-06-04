package com.cf.devkit.bundle;

interface IMovieClip extends IContainer
{
    var frameRate(get, set):Int;
    var currentFrame(get, never):Int;
    var totalFrames(get, never):Int;
    var currentLabel(get, never):String;
    var isPlaying(get, never):Bool;

    function gotoAndPlay(frame:Dynamic):IMovieClip;
    function gotoAndStop(frame:Dynamic):IMovieClip;
    function nextFrame():IMovieClip;
    function prevFrame():IMovieClip;
    function play(loop:Bool = true):IMovieClip;
    function stop():IMovieClip;
    function addFrameScript(frameIndex:Int, callBack:Void -> Void):IMovieClip;
    function addLabelScript(label:String, callBack:Void -> Void):IMovieClip;
    function stopAll():IMovieClip;
}
