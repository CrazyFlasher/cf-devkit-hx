package com.cf.devkit.bundle.impl.openfl;

#if !useStarling
import openfl.display.Sprite;
import dragonBones.openfl.OpenFLArmatureDisplay;
import com.domwires.core.utils.ArrayUtils;
import com.cf.dev.resources.IResourceServiceImmutable;
import dragonBones.events.EventObject;

class OpenFLDragonBonesClip extends OpenFLDisplayObject implements IDragonBonesClip
{
    @Inject
    private var res:IResourceServiceImmutable;

    public var display(get, never):dragonBones.openfl.OpenFLArmatureDisplay;
    public var timeScale(get, set):Float;
    public var currentAnim(get, never):String;

    private var _display:dragonBones.openfl.OpenFLArmatureDisplay;
    private var assetId:String;
    private var onComplete:Void -> Void;

    private var _currentAnim:String;
    private var _loop:Bool;

    private var animIdList:Array<String>;

    private var sprite:Sprite;

    override private function init():Void
    {
        sprite = new Sprite();
        sprite.mouseEnabled = sprite.mouseChildren = false;

        _assets = sprite;

        super.init();
    }

    public function showAndStop(animId:String):Void
    {
        _display.animation.gotoAndStopByFrame(animId);
    }

    public function advanceTime(value:Float):Void
    {
        if (_display == null) return;

        _display.armature.advanceTime(value);
    }

    public function play(loop:Bool = true, assetId:String = null, onComplete:Void -> Void = null):Void
    {
        if (_display == null) return;

        if (assetId == null)
        {
            assetId = _display.animation.animationNames[0];
        }

        _currentAnim = assetId;
        _loop = loop;

        this.onComplete = onComplete;

        _display.animation.play(assetId, loop ? -1 : 1);
    }

    public function stop():Void
    {
        if (_display == null) return;

        _display.animation.reset();
    }

    public function getAnimDuration(animId:String = null):Float
    {
        return animId == null ? _display.animation.animations.get(_display.animation.animationNames[0]).duration
            : _display.animation.animations.get(animId).duration;
    }

    public function setSkeletonAnimation(textureId:String, skeletonId:String = null, textureConfigId:String = null):Void
    {
        disposeDBAsset();

        this.assetId = textureId;

        _display = res.getDragonBonesAnimation(textureId, skeletonId, textureConfigId);
        _display.addEvent(EventObject.LOOP_COMPLETE, animCompleted);

        sprite.addChild(_display);
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
                _display.parent.removeChild(_display);
            }

            _display.dispose();
            _display = null;
        }
    }

    private function get_display():dragonBones.openfl.OpenFLArmatureDisplay
    {
        return _display;
    }
}
#end