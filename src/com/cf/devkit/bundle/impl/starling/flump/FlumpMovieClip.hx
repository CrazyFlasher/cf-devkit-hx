package com.cf.devkit.bundle.impl.starling.flump;

#if useStarling
import com.cf.devkit.config.ICasinoConfig;
import starling.utils.Align;
import com.domwires.core.factory.IAppFactory;
import com.cf.devkit.bundle.IMovieClip;
import com.cf.devkit.trace.Trace;
import flump.display.Movie;
import starling.animation.IAnimatable;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.text.TextField;
import starling.text.TextFieldAutoSize;
import starling.text.TextFormat;
import Std;

class FlumpMovieClip extends StarlingContainer implements IMovieClip implements IAnimatable
{
    @Inject
    @Optional
    private var config:ICasinoConfig;

    @Inject("bundleId")
    private var bundleId:String;

    @Inject
    private var factory:IAppFactory;

    @Inject("movie")
    private var movie:Movie;

    public var isPlaying(get, never):Bool;
    public var currentFrame(get, never):Int;
    public var totalFrames(get, never):Int;
    public var currentLabel(get, never):String;
    public var frameRate(get, set):Int;

    private var _loop:Bool;

    private var frameScriptMap:Map<Int, Script>;
    private var labelScriptMap:Map<String, Void -> Void>;

    private var initialized:Bool = false;

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

            if (Std.is(child, Movie))
            {
                var movie:Movie = cast child;
                if (isImage(movie))
                {
                    createImage(movie);
                } else
                if (isSheetClip(movie))
                {
                    createSheetClip(movie);
                } else
                if (isSpineClip(movie))
                {
                    createSpineClip(movie);
                } else
                if (isDragonBonesClip(movie))
                {
                    createDragonBonesClip(movie);
                } else
                if (isParticleClip(movie))
                {
                    createParticleClip(movie);
                } else
                {
                    createMovieClip(movie);
                }
            } else
            if (Std.is(child, Image))
            {
                if (isTextField(child))
                {
                    createTextField(cast child);
                } else
                {
                    createDisplayObject(child);
                }
            }
        }

        childList = null;

        movie.addEventListener(MovieEvent.LABEL_PASSED, labelPassed);

        initialized = true;
    }

    override private function _contains(map:Map<String, IDisplayObject>, name:String, child:IDisplayObject):Bool
    {
        return initialized && super._contains(map, name, child);
    }

    private function get_frameRate():Int
    {
        return movie.frameRate;
    }

    private function set_frameRate(value:Int):Int
    {
        movie.frameRate = value;
        clearScriptsExecutionState(value);

        return value;
    }

    private function labelPassed():Void
    {
//        trace("LABEL PASSED: " + movie.name + " " + movie.currentLabel, Trace.INFO);

        if (labelScriptMap != null && labelScriptMap.exists(movie.currentLabel))
        {
            trace("Executing label script: " + movie.currentLabel, Trace.INFO);
            labelScriptMap.get(movie.currentLabel)();
        }

        if (movie.currentLabel == Movie.LAST_FRAME)
        {
            executeFrameScripts(true);

            clearScriptsExecutionState();

            if (_loop)
            {
                gotoAndStop(0);
                play(true);
            }
        }
    }

    private function clearScriptsExecutionState(?beforeFrame:Dynamic):Void
    {
        if (frameScriptMap != null)
        {
            var beforeFrameInt:Int;

            if (beforeFrame != null)
            {
                beforeFrameInt = Std.is(beforeFrame, String) ? movie.getFrameForLabel(beforeFrame) : beforeFrame;
            } else
            {
                beforeFrameInt = totalFrames;
            }

            for (script in frameScriptMap.iterator())
            {
                if (script.frame < beforeFrameInt)
                {
                    script.executed = false;
                }
            }
        }
    }

    override public function dispose():Void
    {
        if (frameScriptMap != null)
        {
            frameScriptMap.clear();
            frameScriptMap = null;
        }
        if (labelScriptMap != null)
        {
            labelScriptMap.clear();
            labelScriptMap = null;
        }

        addToJuggler(false);

        super.dispose();
    }

    private function isImage(child:DisplayObject):Bool
    {
        return child.name.indexOf("@image") != -1 && child.name.charAt(0) == "@";
    }

    private function isSheetClip(child:DisplayObject):Bool
    {
        return child.name.indexOf("@sheet") != -1 && child.name.charAt(0) == "@";
    }

    private function isParticleClip(child:DisplayObject):Bool
    {
        return child.name.indexOf("@particle") != -1 && child.name.charAt(0) == "@";
    }

    private function isDragonBonesClip(child:DisplayObject):Bool
    {
        return child.name.indexOf("@db") != -1 && child.name.charAt(0) == "@";
    }

    private function isSpineClip(child:DisplayObject):Bool
    {
        return child.name.indexOf("@spine") != -1 && child.name.charAt(0) == "@";
    }

    private function isTextField(child:DisplayObject):Bool
    {
        return child.name.indexOf("@tf") != -1 && child.name.charAt(0) == "@";
    }

    private function createTextField(value:Image):Void
    {
        var textField:TextField = getNewTextField(value);

        factory.mapToValue(TextField, textField, "textField");
        factory.mapToValue(DisplayObject, textField, "assets");

        var tf:ITextField = factory.getInstance(ITextField);

        //TODO: assign other props also
        tf.alpha = value.alpha;

        addChild(tf);

        value.removeFromParent(true);
    }

    private function getNewTextField(value:DisplayObject):TextField
    {
        /*
            Temporary solution until exporter will generate textfields automatically.
            Currently text field will be generated from sprite, with layer name, that stats from "@tf":
			@tf:instanceName:#fontSize#fontColor#fontName#align#style#defaultText#autoSize
         */

        var name:String = "undefined";
        var textField:TextField;

        var fontSize:Int = 12;
        var fontColor:Int = 0x000000;
        var fontName:String = "Noto Sans Med";
        var hAlign:String = "left";
        var style:String = "regular";
        var defaultText:String = "text";
        var autoSize:Bool = false;
        var isBitmapFont:Bool = false;

        var splitted:Array<Dynamic> = value.name.split(":");

        var params:Array<Dynamic> = splitted[1].split("#");

        name = params[0];

        if (params.length > 1)
        {
            fontSize = Std.int(params[1]);
        }
        if (params.length > 2)
        {
            fontColor = Std.int(params[2]);
        }
        if (params.length > 3)
        {
            fontName = params[3];

            if (config != null && fontName.indexOf(".png") != -1)
            {
                isBitmapFont = true;
                fontName = config.basePath + fontName;
            }
        }
        if (params.length > 4)
        {
            hAlign = params[4];
        }
        if (params.length > 5)
        {
            style = params[5];
        }
        if (params.length > 6)
        {
            defaultText = params[6];
        }
        if (params.length > 7)
        {
            autoSize = params[7] == "true";
        }

        var width:Int = Math.ceil(value.width);
        var height:Int = Math.ceil(value.height);
        var textFormat:TextFormat = new TextFormat(fontName, fontSize, fontColor, hAlign, Align.CENTER);
        textFormat.bold = (style == "bold");

        if (!isBitmapFont)
        {
            textFormat.leading = Math.ceil(fontSize * 0.15);
            height = Math.ceil(height + fontSize * 2);
        }

        textField = new TextFieldEx(isBitmapFont, width, height, defaultText, textFormat);
        textField.name = name;
        value.name = name;

        if (autoSize)
        {
            textField.autoSize = TextFieldAutoSize.HORIZONTAL;
        } else
        {
            textField.autoScale = true;
        }

//        textField.border = true;
        textField.x = value.x;
        textField.y = value.y - (!isBitmapFont ? fontSize : 0);
        textField.pivotX = value.pivotX;
        textField.pivotY = value.pivotY + (!isBitmapFont ? fontSize : 0);
        textField.touchable = value.touchable;
        textField.pixelSnapping = false;

        return textField;
    }

    private function getAssetIdAndUpdateName(value:DisplayObject):String
    {
        var name:String = value.name;
        var splitted:Array<Dynamic> = name.split(":");
        var params:Array<Dynamic> = splitted[1].split("#");
        var assetId:String = params[1];

        value.name = params[0];

        var id:String = config != null ? config.basePath + assetId : assetId;

        if (name.indexOf("#../") != -1)
        {
            id = StringTools.replace(id, Std.string(config.assetsQuality) + "/../", "");
        }

        return id;
    }

    private function getNewSpineClip(value:DisplayObject):ISpineClip
    {
        var clip:ISpineClip = factory.getInstance(ISpineClip);
        clip.setAssetId(getAssetIdAndUpdateName(value));

        return clip;
    }

    private function createSpineClip(value:Movie):Void
    {
        var clip:IDisplayObject = getNewSpineClip(value);
        var movie:IMovieClip = createMovieClip(value);
        movie.addChild(clip);
    }

    private function createImage(value:Movie):Void
    {
        var clip:IImage = factory.getInstance(IImage);
        clip.setAssetId(getAssetIdAndUpdateName(value));

        var movie:IMovieClip = createMovieClip(value);
        movie.addChild(clip);
    }

    private function getNewSheetClip(value:DisplayObject):ISheetClip
    {
        var clip:ISheetClip = factory.getInstance(ISheetClip);
        clip.setAssetId(getAssetIdAndUpdateName(value));

        return clip;
    }

    private function createSheetClip(value:Movie):Void
    {
        var clip:IDisplayObject = getNewSheetClip(value);
        var movie:IMovieClip = createMovieClip(value);
        movie.addChild(clip);
    }

    private function getNewDragonBonesClip(value:DisplayObject):IDragonBonesClip
    {
        var clip:IDragonBonesClip = factory.getInstance(IDragonBonesClip);
        clip.setAssetId(getAssetIdAndUpdateName(value));

        return clip;
    }

    private function createDragonBonesClip(value:Movie):Void
    {
        var clip:IDisplayObject = getNewDragonBonesClip(value);
        var movie:IMovieClip = createMovieClip(value);
        movie.addChild(clip);
    }

    //TODO: optimize
    private function getNewParticleClip(value:DisplayObject):IParticleClip
    {
        var name:String = value.name;

        var clip:IParticleClip = factory.getInstance(IParticleClip);
        var textureName:String = name.substring(name.lastIndexOf("/") + 1);

        var params:Array<Dynamic> = name.split(":")[1].split("#");
        if (params.length > 2)
        {
            clip.setDisplayObject(getAssetIdAndUpdateName(value), params[2], bundleId);
        } else
        {
            clip.setAssetId(getAssetIdAndUpdateName(value), textureName, bundleId);
        }

        return clip;
    }

    private function createParticleClip(value:Movie):Void
    {
        var clip:IDisplayObject = getNewParticleClip(value);
        var movie:FlumpMovieClip = cast createMovieClip(value);
        var canvas:Movie = cast movie.canvas;
        canvas.overrideSetX(movie.overrideX);
        canvas.overrideSetY(movie.overrideY);
        movie.addChild(clip);
    }

    @:allow(com.cf.devkit.bundle.impl.flump.FlumpMovieClip)
    private function overrideX(value:Float):Float
    {
        getParticleClip().emitterX = -x + value;

        return value;
    }

    @:allow(com.cf.devkit.bundle.impl.flump.FlumpMovieClip)
    private function overrideY(value:Float):Float
    {
        getParticleClip().emitterY = -y + value;

        return value;
    }

    private function createMovieClip(value:Movie):IMovieClip
    {
        factory.mapToValue(Movie, value, "movie");
        factory.mapToValue(DisplayObjectContainer, value, "canvas");
        factory.mapToValue(DisplayObject, value, "assets");

        var movie:IMovieClip = factory.getInstance(IMovieClip);
        addChild(movie);

        return movie;
    }

    private function createDisplayObject(value:DisplayObject):Void
    {
        factory.mapToValue(DisplayObject, value, "assets");

        addChild(factory.getInstance(IDisplayObject));
    }

    private function addToJuggler(value:Bool):Void
    {
        if (value)
        {
            Starling.current.juggler.add(this);
        } else
        {
            Starling.current.juggler.remove(this);
        }
    }

    public function advanceTime(time:Float):Void
    {
        if (frameScriptMap != null)
        {
            var frameTime:Float = 1 / Starling.current.nativeStage.frameRate;
            var timeLeft:Float = time - frameTime;

            movie.advanceTime(frameTime);

            executeFrameScripts();

            if (timeLeft > 0)
            {
                movie.advanceTime(timeLeft);
            }
        } else
        {
            movie.advanceTime(time);
        }
    }

    private function executeFrameScripts(all:Bool = false):Void
    {
        if (frameScriptMap != null)
        {
            for (script in frameScriptMap.iterator())
            {
                if ((all || script.frame <= movie.frame) && !script.executed)
                {
                    script.action();
                    script.executed = true;
                }
            }
        }
    }

    public function gotoAndPlay(frame:Dynamic):IMovieClip
    {
        clearScriptsExecutionState(frame);

        movie.goTo(frame);

        play();

        return this;
    }

    public function gotoAndStop(frame:Dynamic):IMovieClip
    {
        clearScriptsExecutionState(frame);

        movie.goTo(frame);

        stop();

        return this;
    }

    public function nextFrame():IMovieClip
    {
        movie.goTo(movie.frame == movie.numFrames - 1 ? 0 : movie.frame + 1);

        stop();

        return this;
    }

    public function prevFrame():IMovieClip
    {
        movie.goTo(movie.frame == 0 ? movie.numFrames - 1 : movie.frame - 1);

        stop();

        return this;
    }

    public function play(loop:Bool = true):IMovieClip
    {
        _loop = loop;

        movie.playTo(totalFrames - 1, false);

        addToJuggler(true);

        return this;
    }

    public function stop():IMovieClip
    {
        _loop = false;

        movie.stop();

        addToJuggler(false);

        return this;
    }

    public function addLabelScript(label:String, callBack:Void -> Void):IMovieClip
    {
        if (labelScriptMap == null)
        {
            labelScriptMap = new Map<String, Void -> Void>();
        }

        if (callBack == null && labelScriptMap.exists(label))
        {
            labelScriptMap.remove(label);
        } else
        {
            labelScriptMap.set(label, callBack);
        }

        return this;
    }

    public function addFrameScript(frameIndex:Int, callBack:Void -> Void):IMovieClip
    {
        if (frameScriptMap == null)
        {
            frameScriptMap = new Map<Int, Script>();
        }

        if (callBack == null && frameScriptMap.exists(frameIndex))
        {
            frameScriptMap.remove(frameIndex);
        } else
        {
            var script:Script = {
                frame: frameIndex,
                action: callBack,
                executed: false
            };

            frameScriptMap.set(frameIndex, script);
        }

        return this;
    }

    public function stopAll():IMovieClip
    {
        //TODO: stop children recursively
        stop();

        return this;
    }

    private function get_currentFrame():Int
    {
        return movie.frame;
    }

    private function get_currentLabel():String
    {
        return movie.currentLabel;
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

class TextFieldEx extends TextField
{
    private var isBitmapFont:Bool;

    public function new(isBitmapFont:Bool, width:Int, height:Int, text:String="", format:TextFormat=null)
    {
        this.isBitmapFont = isBitmapFont;

        super(width, height, text, format);

        if (!isBitmapFont)
        {
            _options.padding = format.leading;
        }
    }

    override private function set_wordWrap(value:Bool):Bool
    {
        super.set_wordWrap(value);

        set_text(text);

        return value;
    }

    override private function set_text(value:String):String
    {
        super.set_text(!isBitmapFont && wordWrap ? "\n" + value + "\n" : value);

        return value;
    }
}

typedef Script = {
    var frame:Int;
    var executed:Bool;
    var action:Void -> Void;
}
#end