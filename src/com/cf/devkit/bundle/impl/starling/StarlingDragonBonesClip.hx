package com.cf.devkit.bundle.impl.starling;

#if useStarling
import com.cf.devkit.services.resources.IResourceServiceImmutable;
import com.domwires.core.utils.ArrayUtils;
import dragonBones.events.EventObject;

class StarlingDragonBonesClip extends StarlingDisplayObject implements IDragonBonesClip
{
    @Inject
    private var res:IResourceServiceImmutable;

    public var display(get, never):dragonBones.starling.StarlingArmatureDisplay;
    public var timeScale(get, set):Float;
    public var currentAnim(get, never):String;

    private var _display:dragonBones.starling.StarlingArmatureDisplay;
    private var assetId:String;
    private var onComplete:Void -> Void;

    private var _currentAnim:String;
    private var _loop:Bool;

    private var animIdList:Array<String>;

    public function showAndStop(animId:String):Void
    {
        _display.animation.gotoAndStopByFrame(animId);
    }

    public function advanceTime(value:Float):Void
    {
        if (_display == null) return;

        _display.armature.advanceTime(value);
    }

    public function play(loop:Bool = true, animId:String = null, onComplete:Void -> Void = null, fadeInTime:Float = 0.0):Void
    {
        if (_display == null) return;

        if (animId == null)
        {
            animId = _display.animation.animationNames[0];
        }

        _currentAnim = animId;
        _loop = loop;

        this.onComplete = onComplete;

//        _display.animation.play(animId, loop ? 0 : 1);
        _display.animation.fadeIn(animId, fadeInTime, loop ? 0 : 1);
    }

    public function stop():Void
    {
        if (_display == null) return;

        _display.animation.reset();
    }

    public function getAnimDuration(animId:String = null):Float
    {
        return animId == null ? _display.animation.animations.get(_currentAnim).duration
            : _display.animation.animations.get(animId).duration;
    }

    public function setAssetId(textureId:String, skeletonId:String = null, textureConfigId:String = null):Void
    {
        disposeDBAsset();

        this.assetId = textureId;

        _display = res.getDragonBonesAnimation(textureId, skeletonId, textureConfigId);
        _display.touchable = false;

        _display.addEvent(EventObject.LOOP_COMPLETE, animCompleted);

        _assets = _display;

        scale = super.scale;
    }

    override private function set_width(value:Float):Float
    {
        return super.set_width(value) * res.contentScaleFactor;
    }

    override private function set_height(value:Float):Float
    {
        return super.set_height(value) * res.contentScaleFactor;
    }

    override private function get_width():Float
    {
        return super.get_width() / res.contentScaleFactor;
    }

    override private function get_height():Float
    {
        return super.get_height() / res.contentScaleFactor;
    }

    override private function get_scaleX():Float
    {
        return super.get_scaleX() / res.contentScaleFactor;
    }

    override private function get_scaleY():Float
    {
        return super.get_scaleY() / res.contentScaleFactor;
    }

    override private function get_scale():Float
    {
        return super.get_scale() / res.contentScaleFactor;
    }

    override private function set_scaleX(value:Float):Float
    {
        super.scaleX = value * res.contentScaleFactor;

        return value;
    }

    override private function set_scaleY(value:Float):Float
    {
        super.scaleY = value * res.contentScaleFactor;

        return value;
    }

    override private function set_scale(value:Float):Float
    {
        super.scale = value * res.contentScaleFactor;

        return value;
    }

    private function animCompleted(event:Dynamic):Void
    {
        if (onComplete != null)
        {
            onComplete();
        }
    }

    public function getAnimIdList():Array<String>
    {
        if (animIdList == null) animIdList = [];

        ArrayUtils.clear(animIdList);

        for (anim in _display.animation.animationNames)
        {
            animIdList.push(anim);
        }

        return animIdList;
    }

    private function get_timeScale():Float
    {
        return _display.animation.timeScale;
    }

    private function set_timeScale(value:Float):Float
    {
        return _display.animation.timeScale = value;
    }

    private function get_currentAnim():String
    {
        return _currentAnim;
    }

    private function disposeDBAsset():Void
    {
        if (_display != null)
        {
            _display.removeEvent(EventObject.LOOP_COMPLETE, animCompleted);

            if (_display.parent != null)
            {
                _display.removeFromParent(true);
            } else
            {
                _display.dispose();
            }

            _display = null;
        }
    }

    override public function dispose():Void
    {
        disposeDBAsset();

        super.dispose();
    }

    public function get_display():dragonBones.starling.StarlingArmatureDisplay
    {
        return _display;
    }
}
#end