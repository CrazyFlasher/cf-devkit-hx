package com.cf.devkit.bundle.impl.openfl;

#if !useStarling
import com.cf.devkit.display.Stage;
import haxe.io.Error;
import com.cf.devkit.trace.Trace;
import com.domwires.core.mvc.hierarchy.IHierarchyObjectContainer;
import com.domwires.core.mvc.hierarchy.IHierarchyObject;
import com.domwires.core.factory.IAppFactory;
import openfl.display.Bitmap;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.MovieClip;
import openfl.text.TextField;
import Std;

class OpenFLMovieClip extends OpenFLDisplayObject implements IMovieClip
{
    @Inject
    private var factory:IAppFactory;

    @Inject("movie")
    private var movie:MovieClip;

    public var canvas(get, never):DisplayObjectContainer;

    public var isPlaying(get, never):Bool;
    public var currentFrame(get, never):Int;
    public var totalFrames(get, never):Int;
    public var currentLabel(get, never):String;
    public var frameRate(get, set):Int;

    @:allow(com.cf.devkit.bundle.impl.openfl.OpenFLMovieClip)
    private var movieMap:Map<String, IMovieClip> = new Map<String, IMovieClip>();

    @:allow(com.cf.devkit.bundle.impl.openfl.OpenFLMovieClip)
    private var textFieldMap:Map<String, ITextField> = new Map<String, ITextField>();

    @:allow(com.cf.devkit.bundle.impl.openfl.OpenFLMovieClip)
    private var displayObjectMap:Map<String, IDisplayObject> = new Map<String, IDisplayObject>();

    override private function init():Void
    {
        super.init();

        var l:Int = 0;
        var child:DisplayObject;

        var childList:Array<DisplayObject> = [];

        while (l < movie.numChildren)
        {
            childList.push(movie.getChildAt(l));
            l++;
        }

        for (i in 0...childList.length)
        {
            child = childList[i];

            if (isOpenFLMovieClip(child))
            {
                createMovieClip(cast child);
            } else
            if (Std.is(child, TextField))
            {
                createTextField(cast child);
            } else
            {
                createDisplayObject(child);
            }
        }

        movie.stop();
        movie.stopAllMovieClips();
    }

    private function isOpenFLMovieClip(child:DisplayObject):Bool
    {
        if (!Std.is(child, MovieClip)) return false;

        var mc:MovieClip = cast child;
        return !(mc.numChildren == 1 && Std.is(mc.getChildAt(0), Bitmap));
    }

    private function createTextField(value:TextField):Void
    {
        factory.mapToValue(TextField, value, "textField");
        factory.mapToValue(DisplayObject, value, "assets");

        addChild(factory.getInstance(ITextField));
    }

    private function createMovieClip(value:MovieClip):Void
    {
        factory.mapToValue(MovieClip, value, "movie");
        factory.mapToValue(DisplayObject, value, "assets");

        addChild(factory.getInstance(IMovieClip));
    }

    private function createDisplayObject(value:DisplayObject):Void
    {
        factory.mapToValue(DisplayObject, value, "assets");

        addChild(factory.getInstance(IDisplayObject));
    }

    public function addChild(value:IDisplayObject, index:Int = -1):IMovieClip
    {
        add(value, index);

        return this;
    }

    public function removeChild(value:IDisplayObject, dispose:Bool = true):IMovieClip
    {
        remove(value, dispose);

        return this;
    }

    public function removeChildren(dispose:Bool = true):IMovieClip
    {
        for (child in movieMap.iterator())
        {
            remove(child, dispose);
        }
        for (child in textFieldMap.iterator())
        {
            remove(child, dispose);
        }
        for (child in displayObjectMap.iterator())
        {
            remove(child, dispose);
        }

        return this;
    }

    public function swapZ(a:IDisplayObject, b:IDisplayObject):IMovieClip
    {
        movie.swapChildren(a.assets, b.assets);

        return this;
    }

    @:allow(com.cf.devkit.bundle.impl.openfl.OpenFLMovieClip)
    override public function remove(child:IHierarchyObject, dispose:Bool = false):IHierarchyObjectContainer
    {
        var displayObject:IDisplayObject = cast child;
        var name:String = displayObject.assets.name;

        var isMovieClip:Bool = Std.is(displayObject, IMovieClip);
        var isTextField:Bool = Std.is(displayObject, ITextField);

        if (isMovieClip)
        {
            movieMap.remove(name);
        } else
        if (isTextField)
        {
            textFieldMap.remove(name);
        } else
        {
            displayObjectMap.remove(name);
        }

        movie.removeChild(displayObject.assets);

        if (dispose)
        {
            displayObject.dispose();
        }

        super.remove(child, dispose);

        return this;
    }

    @:allow(com.cf.devkit.bundle.impl.openfl.OpenFLMovieClip)
    override public function add(child:IHierarchyObject, index:Int = -1):IHierarchyObjectContainer
    {
        var displayObject:IDisplayObject = cast child;
        var name:String = displayObject.assets.name;

        var isMovieClip:Bool = Std.is(displayObject, IMovieClip);
        var isTextField:Bool = Std.is(displayObject, ITextField);

        if (displayObject.parent != null)
        {
            var parentMovie:OpenFLMovieClip = cast displayObject.parent;

            if (isMovieClip)
            {
                parentMovie.movieMap.remove(name);
            } else
            if (isTextField)
            {
                parentMovie.textFieldMap.remove(name);
            } else
            {
                parentMovie.displayObjectMap.remove(name);
            }
        }

        super.add(child, index);

        if (isMovieClip)
        {
            movieMap.set(name, cast displayObject);
        } else
        if (isTextField)
        {
            textFieldMap.set(name, cast displayObject);
        } else
        {
            displayObjectMap.set(name, cast displayObject);
        }

        index >= 0 ? movie.addChildAt(displayObject.assets, index) : movie.addChild(displayObject.assets);

        return this;
    }

    private function get_canvas():DisplayObjectContainer
    {
        return movie;
    }

    public function gotoAndPlay(frame:Dynamic):IMovieClip
    {
        movie.gotoAndPlay(frame + 1);

        return this;
    }

    public function gotoAndStop(frame:Dynamic):IMovieClip
    {
        movie.gotoAndStop(frame + 1);

        return this;
    }

    public function nextFrame():IMovieClip
    {
        movie.nextFrame();

        return this;
    }

    public function prevFrame():IMovieClip
    {
        movie.prevFrame();

        return this;
    }

    public function play():IMovieClip
    {
        movie.play();

        return this;
    }

    public function stop():IMovieClip
    {
        movie.stop();

        return this;
    }

    public function addFrameScript(frameIndex:Int, callBack:Void -> Void):IMovieClip
    {
        movie.addFrameScript(frameIndex, callBack);

        return this;
    }

    public function stopAll():IMovieClip
    {
        movie.stopAllMovieClips();

        return this;
    }

    private function get_currentFrame():Int
    {
        return movie.currentFrame - 1;
    }

    private function get_currentLabel():String
    {
        return movie.currentLabel;
    }

    private function get_totalFrames():Int
    {
        return movie.totalFrames;
    }

    private function get_isPlaying():Bool
    {
        return movie.isPlaying;
    }

    public function getChild(name:String):DisplayObject
    {
        var child:DisplayObject = canvas.getChildByName(name);

        if (child == null)
        {
            trace("Not found: " + name, Trace.WARNING);
        }

        return child;
    }

    public function getDisplayObject(name:String):IDisplayObject
    {
        if (movieMap.exists(name))
        {
            return movieMap.get(name);
        }
        if (textFieldMap.exists(name))
        {
            return textFieldMap.get(name);
        }
        if (displayObjectMap.exists(name))
        {
            return displayObjectMap.get(name);
        }

        trace("Not found: " + name, Trace.WARNING);

        return null;
    }

    public function getSpineClip(name:String):ISpineClip
    {
        throw Error.Custom("Not implemented!");
    }

    public function getDragonBonesClip(name:String):IDragonBonesClip
    {
        throw Error.Custom("Not implemented!");
    }

    public function getParticleClip(name:String):IParticleClip
    {
        throw Error.Custom("Not implemented!");
    }

    public function getMovieClip(name:String):IMovieClip
    {
        if (!movieMap.exists(name))
        {
            trace("Not found: " + name, Trace.WARNING);
            return null;
        }

        return movieMap.get(name);
    }

    public function getTextField(name:String):ITextField
    {
        if (textFieldMap.exists(name))
        {
            return textFieldMap.get(name);
        }

        trace("Not found: " + name, Trace.WARNING);

        return null;
    }

    public function hasDisplayObject(name:String):Bool
    {
        return movieMap.exists(name) || textFieldMap.exists(name) || displayObjectMap.exists(name);
    }

    override private function set_touchable(value:Bool):Bool
    {
        super.set_touchable(value);

        return movie.mouseEnabled = movie.mouseChildren = value;
    }

    override private function get_touchable():Bool
    {
        super.get_touchable();

        return movie.mouseEnabled;
    }

    private function get_frameRate():Int
    {
        return Stage.get().frameRate;
    }

    private function set_frameRate(value:Int):Int
    {
        throw Error.Custom("Not implemented!");
    }
}
#end