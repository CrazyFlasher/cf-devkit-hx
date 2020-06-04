package com.cf.devkit.bundle.impl.openfl;

#if !useStarling
import spine.support.utils.FloatArray;
import spine.support.math.Vector2;
import com.domwires.core.utils.ArrayUtils;
import openfl.display.Sprite;
import com.cf.devkit.resources.IResourceServiceImmutable;
import openfl.display.Tilemap;
import openfl.display.Tileset;
import spine.Animation;
import spine.events.AnimationEvent;
import spine.events.SpineEvent;
import spine.SkeletonData;

class OpenFLSpineClip extends OpenFLDisplayObject implements ISpineClip
{
    @Inject("maxWidth")
    @Optional
    private var maxWidth:Int = 0;

    @Inject("maxHeight")
    @Optional
    private var maxHeight:Int = 0;

    @Inject("renderAsSprite")
    @Optional
    private var renderAsSprite:Bool = false;

    @Inject
    private var res:IResourceServiceImmutable;

    private var animId:String;

    public var animTile(get, never):spine.tilemap.SkeletonAnimation;
    public var animSprite(get, never):spine.openfl.SkeletonAnimation;
    
    private var _animTile:spine.tilemap.SkeletonAnimation;
    private var _animSprite:spine.openfl.SkeletonAnimation;

    private var tilemap:Tilemap;

    private var skeletonData:SkeletonData;

    private var event:AnimationEvent = new AnimationEvent();

    private var onComplete:Void -> Void;

    public var timeScale(get, set):Float;

    public var isPlaying(get, never):Bool;

    public var currentAnim(get, never):String;
    private var _currentAnim:String;
    private var _loop:Bool;

    private var sprite:Sprite;

    private var animIdList:Array<String>;

    private var input:Vector2 = new Vector2();
    private var output:Vector2 = new Vector2();
    private var temp:FloatArray = new FloatArray();

    private var _width:Float = 0;
    private var _height:Float = 0;

    private var _blendTime:Float = 0;

    override private function init():Void
    {
        sprite = new Sprite();
        sprite.mouseEnabled = sprite.mouseChildren = false;

        _assets = sprite;

        super.init();
    }

    override public function dispose():Void
    {
        disposeSpineAsset();

        super.dispose();
    }

    public function showAndStop(animId:String):Void
    {
        play(false, animId);

        if (!renderAsSprite)
        {
            _animTile.advanceTime(0);
            _animTile.stop();
        } else
        {
            _animSprite.advanceTime(0);
            _animSprite.stop();
        }
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

    public function play(loop:Bool = true, animId:String = null, onComplete:Void -> Void = null):Void
    {
        if (_animTile == null && _animSprite == null) return;

        if (animId == null)
        {
            animId = skeletonData.getAnimations()[0].name;
        }

        _currentAnim = animId;
        _loop = loop;

        this.onComplete = onComplete;

        if (!renderAsSprite)
        {
            _animTile.play(animId, loop);
        } else
        {
            _animSprite.playForce(animId, loop);
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
        if (_animTile == null && _animSprite == null) return;

        if (!renderAsSprite)
        {
            _animTile.skeleton.setToSetupPose();
            _animTile.state.clearTracks();
            _animTile.stop();
        } else
        {
            _animSprite.skeleton.setToSetupPose();
            _animSprite.state.clearTracks();
            _animSprite.stop();
        }
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
        if (_animSprite != null)
        {
            _animSprite.skeleton.getBounds(input, output, temp);
        } else
        {
            _animTile.skeleton.getBounds(input, output, temp);
        }

        _width = output.x * scale;

        return _width;
    }

    override private function get_height():Float
    {
        if (_animSprite != null)
        {
            _animSprite.skeleton.getBounds(input, output, temp);
        } else
        {
            _animTile.skeleton.getBounds(input, output, temp);
        }

        _height = output.y * scale;

        return _height;
    }

    public function setBlendTime(value:Float):Void
    {
        _blendTime = value;
    }

    public function setSkeletonAnimation(animId:String, skeletonId:String = null):Void
    {
//		if (this.animId == animId) return;

        disposeSpineAsset();

        this.animId = animId;

        if (!renderAsSprite)
        {
            _animTile = res.getSpineTilemapSkeleton(animId, skeletonId);
            _animTile.state.getData().setDefaultMix(_blendTime);

            var tileset:Tileset = res.getSpineTileset(animId, skeletonId);

            _animTile.state.addListener(event);

            if (tilemap == null)
            {
                var w:Int = maxWidth > 0 ? maxWidth : 700;
                var h:Int = maxHeight > 0 ? maxHeight : w;

                tilemap = new Tilemap(w, h, tileset);
                tilemap.x -= tilemap.width / 2;
                tilemap.y -= tilemap.height / 2;

                sprite.addChild(tilemap);
            } else
            {
                tilemap.tileset = tileset;
            }

            _animTile.x = tilemap.width / 2;
            _animTile.y = tilemap.height / 2;

            skeletonData = _animTile.state.getData().getSkeletonData();

            tilemap.addTile(_animTile);

            play();

            _animTile.advanceTime(0);
            _animTile.stop();
        } else
        {
            _animSprite = res.getSpineSpriteSkeleton(animId, skeletonId);
            _animSprite.state.getData().setDefaultMix(_blendTime);
            _animSprite.state.addListener(event);

            skeletonData = _animSprite.state.getData().getSkeletonData();

            sprite.addChild(_animSprite);

            play();

            _animSprite.advanceTime(0);
            _animSprite.stop();
        }

        event.addEventListener(SpineEvent.COMPLETE, animCompleted);
    }

    private function disposeSpineAsset():Void
    {
        event.removeEventListener(SpineEvent.COMPLETE, animCompleted);

        if (_animTile != null)
        {
            _animTile.state.removeListener(event);

            if (_animTile.parent != null)
            {
                tilemap.removeTile(_animTile);
            }

            _animTile.destroy();
            _animTile = null;
        } else
        if (_animSprite != null)
        {
            _animSprite.state.removeListener(event);

            if (_animSprite.parent != null)
            {
                _animSprite.parent.removeChild(_animSprite);
            }

            _animSprite.destroy();
            _animSprite = null;
        }
    }

    private function get_currentAnim():String
    {
        return _currentAnim;
    }

    private function get_timeScale():Float
    {
        return _animTile != null ? _animTile.timeScale : _animSprite.timeScale;
    }

    private function set_timeScale(value:Float):Float
    {
        _animTile != null ? _animTile.timeScale = value : _animSprite.timeScale = value;

        return value;
    }

    private function get_isPlaying():Bool
    {
        if (_animTile == null && _animSprite == null) return false;

        return _animTile != null ? _animTile.isPlay : _animSprite.isPlay;
    }

    private function get_animTile():spine.tilemap.SkeletonAnimation
    {
        return _animTile;
    }

    private function get_animSprite():spine.openfl.SkeletonAnimation
    {
        return _animSprite;
    }
}
#end