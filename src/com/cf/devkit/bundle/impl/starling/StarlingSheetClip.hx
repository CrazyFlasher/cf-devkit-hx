package com.cf.devkit.bundle.impl.starling;

import com.cf.devkit.services.resources.IResourceServiceImmutable;
import com.cf.devkit.starling.display.MovieClip;
import starling.animation.Juggler;
import starling.core.Starling;

class StarlingSheetClip extends StarlingDisplayObject implements ISheetClip
{
    @Inject
    private var res:IResourceServiceImmutable;

    @Inject("baseScale")
    private var baseScale:Float;

    private var movie:MovieClip;

    public var frameRate(get, set):Int;
    public var currentFrame(get, never):Int;
    public var totalFrames(get, never):Int;
    public var isPlaying(get, never):Bool;

    private var _frameRate:Int;

    override private function init():Void
    {
        super.init();

        _frameRate = Std.int(Starling.current.nativeStage.frameRate);
    }

    override public function dispose():Void
    {
        disposeMovie();

        super.dispose();
    }

    private function disposeMovie():Void
    {
        addTojuggler(false);

        if (movie.parent != null)
        {
            movie.removeFromParent(true);
        } else
        {
            movie.dispose();
        }

        movie = null;
    }

    public function setAssetId(assetId:String):ISheetClip
    {
        if (movie != null)
        {
            disposeMovie();
        }

        movie = new MovieClip(res.getTextureAtlas(assetId).getTextures(), _frameRate);

        if (res.isQualityDependant(assetId))
        {
            movie.scale = 1 / baseScale;
        }

        _assets = movie;
        _assets.touchable = false;

        return this;
    }

    private function addTojuggler(add:Bool):Void
    {
        if (movie == null) return;

        var juggler:Juggler = Starling.current.juggler;

        add ? juggler.add(movie) : juggler.remove(movie);
    }

    public function gotoAndPlay(frame:Int):ISheetClip
    {
        movie.currentFrame = cast frame;

        addTojuggler(true);

        return this;
    }

    public function gotoAndStop(frame:Int):ISheetClip
    {
        movie.currentFrame = cast frame;

        addTojuggler(false);

        return this;
    }

    public function nextFrame():ISheetClip
    {
        movie.currentFrame = (movie.currentFrame == movie.numFrames - 1 ? 0 : movie.currentFrame + 1);

        stop();

        return this;
    }

    public function prevFrame():ISheetClip
    {
        movie.currentFrame = (movie.currentFrame == 0 ? movie.numFrames - 1 : movie.currentFrame - 1);

        stop();

        return this;
    }

    public function play(loop:Bool = true):ISheetClip
    {
        movie.loop = loop;
        movie.play();

        addTojuggler(true);

        return this;
    }

    public function stop():ISheetClip
    {
        movie.stop();

        addTojuggler(false);

        return this;
    }

    public function addFrameScript(frameIndex:Int, callBack:Void -> Void):ISheetClip
    {
        movie.setFrameAction(frameIndex, callBack);
        return this;
    }

    private function get_frameRate():Int
    {
        return _frameRate;
    }

    private function set_frameRate(value:Int):Int
    {
        _frameRate = value;

        if (movie != null)
        {
            movie.fps = cast value;
        }

        return _frameRate;
    }

    private function get_currentFrame():Int
    {
        return movie.currentFrame;
    }

    private function get_totalFrames():Int
    {
        return movie.numFrames;
    }

    private function get_isPlaying():Bool
    {
        return movie.isPlaying;
    }
}
