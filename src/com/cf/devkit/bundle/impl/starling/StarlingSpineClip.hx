package com.cf.devkit.bundle.impl.starling;

#if useStarling
import com.cf.devkit.services.resources.IResourceServiceImmutable;
import com.domwires.core.utils.ArrayUtils;
import spine.Animation;
import spine.events.AnimationEvent;
import spine.events.SpineEvent;
import spine.SkeletonData;
import spine.starling.SkeletonAnimation;
import spine.support.math.Vector2;
import spine.support.utils.FloatArray;
import starling.core.Starling;

class StarlingSpineClip extends StarlingDisplayObject implements ISpineClip
{
    @Inject
    private var res:IResourceServiceImmutable;

    private var animId:String;

    public var animSprite(get, never):spine.starling.SkeletonAnimation;
    private var _animSprite:SkeletonAnimation;

    private var skeletonData:SkeletonData;

    private var event:AnimationEvent = new AnimationEvent();

    private var onComplete:Void -> Void;

    public var timeScale(get, set):Float;
    public var isPlaying(get, never):Bool;

    public var currentAnim(get, never):String;
    private var _currentAnim:String;
    private var _loop:Bool;

    private var animIdList:Array<String>;

    private var input:Vector2 = new Vector2();
    private var output:Vector2 = new Vector2();
    private var temp:FloatArray = new FloatArray();

    private var _width:Float = 0;
    private var _height:Float = 0;

    private var _blendTime:Float = 0;

    override public function dispose():Void
    {
        disposeSpineAsset();

        super.dispose();
    }

    public function getAnimIdList():Array<String>
    {
        if (animIdList == null) animIdList = [];

        ArrayUtils.clear(animIdList);

        for (anim in skeletonData.getAnimations())
        {
            animIdList.push(anim.name);
        }

        return animIdList;
    }

    public function showAndStop(animId:String):Void
    {
        play(false, animId);

        _animSprite.advanceTime(0);
        if (Starling.current.juggler.contains(_animSprite))
        {
            Starling.current.juggler.remove(_animSprite);
        }
    }

    public function play(loop:Bool = true, animId:String = null, onComplete:Void -> Void = null):Void
    {
        if (_animSprite == null) return;

        if (animId == null)
        {
            animId = skeletonData.getAnimations()[0].name;
        }

        _currentAnim = animId;
        _loop = loop;

        this.onComplete = onComplete;

        _animSprite.state.setAnimationByName(0, animId, loop);

        if (!Starling.current.juggler.contains(_animSprite))
        {
            Starling.current.juggler.add(_animSprite);
        }
    }

    private function animCompleted(event:SpineEvent):Void
    {
        if (onComplete != null)
        {
            onComplete();
        }
    }

    public function stop():Void
    {
        if (_animSprite == null) return;

        _animSprite.skeleton.setToSetupPose();
        _animSprite.state.clearTracks();
        Starling.current.juggler.remove(_animSprite);
    }

    public function getAnimDuration(animId:String = null):Float
    {
        return getAnim(animId).duration;
    }

    public function getAnim(animId:String = null):Animation
    {
        return animId != null ? skeletonData.findAnimation(animId) :
            skeletonData.getAnimations()[0];
    }

    override private function get_width():Float
    {
        _animSprite.skeleton.getBounds(input, output, temp);
        _width = output.x * scale;

        return _width;
    }

    override private function get_height():Float
    {
        _animSprite.skeleton.getBounds(input, output, temp);
        _height = output.y * scale;

        return _height;
    }

    public function setBlendTime(value:Float):Void
    {
        _blendTime = value;
    }

    public function setAssetId(assetId:String, skeletonId:String = null):Void
    {
//		if (this.assetId == assetId) return;

        disposeSpineAsset();

        this.animId = assetId;

        _animSprite = res.getSpineAnimation(assetId, skeletonId);
        _animSprite.touchable = false;
        _animSprite.state.addListener(event);

        //Crossfade animation
        _animSprite.state.getData().setDefaultMix(_blendTime);

        skeletonData = _animSprite.state.getData().getSkeletonData();

        _assets = _animSprite;

        _animSprite.skeleton.getBounds(input, output, temp);

        play();

        _animSprite.advanceTime(0);
        Starling.current.juggler.remove(_animSprite);

        event.addEventListener(SpineEvent.COMPLETE, animCompleted);
    }

    private function disposeSpineAsset():Void
    {
        _width = _height = 0;

        event.removeEventListener(SpineEvent.COMPLETE, animCompleted);

        if (_animSprite != null)
        {
            _animSprite.state.removeListener(event);
            Starling.current.juggler.remove(_animSprite);

            if (_animSprite.parent != null)
            {
                _animSprite.removeFromParent(true);
            } else
            {
                _animSprite.dispose();
            }

            _animSprite = null;
        }
    }

    private function get_currentAnim():String
    {
        return _currentAnim;
    }

    private function get_timeScale():Float
    {
        return _animSprite.state.getTimeScale();
    }

    private function set_timeScale(value:Float):Float
    {
        _animSprite.state.setTimeScale(value);

        return value;
    }

    private function get_isPlaying():Bool
    {
        if (_animSprite == null) return false;

        return Starling.current.juggler.contains(_animSprite);
    }

    private function get_animSprite():spine.starling.SkeletonAnimation
    {
        return _animSprite;
    }
}
#end