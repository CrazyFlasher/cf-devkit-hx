package com.cf.devkit.bundle.impl.starling;

#if useStarling
import com.cf.devkit.services.resources.IResourceServiceImmutable;
import com.cf.devkit.particles.PexDisplayObjectParticleSystem;
import starling.animation.DelayedCall;
import com.cf.devkit.bundle.impl.starling.StarlingDisplayObject;
import openfl.geom.Point;
import starling.animation.IAnimatable;
import starling.animation.Juggler;
import starling.core.Starling;
import starling.extensions.PDParticleSystem;
import starling.textures.Texture;

@:keep
class StarlingParticleClip extends StarlingDisplayObject implements IParticleClip implements IAnimatable
{
    public var emitter(get, never):starling.extensions.PDParticleSystem;
    public var displayObjectEmitter(get, never):PexDisplayObjectParticleSystem;

    public var emitterX(get, set):Float;
    public var emitterY(get, set):Float;

    public var timeMultiplyer(get, set):Float;
    private var _timeMultiplyer:Float = 1.0;

    public var lifeSpan(get, set):Float;
    public var lifeSpanVariance(get, set):Float;
    public var sourcePosition(get, set):Point;
    public var sourcePositionVariance(get, set):Point;
    public var colorChangeDelay(get, set):Float;

    @Inject
    private var res:IResourceServiceImmutable;

    private var emitterId:String;
    private var textureId:String;
    private var displayObjectId:String;
    private var bundleId:String;

    private var _emitter:PDParticleSystem;
    private var _displayObjectEmitter:PexDisplayObjectParticleSystem;

    private var juggler:Juggler;

    private var clearDelayedCall:DelayedCall = new DelayedCall(null, 0);

    override private function init():Void
    {
        super.init();

        juggler = Starling.current.juggler;
    }

    override public function dispose():Void
    {
        disposeParticleSystem();

        clearDelayedCall = null;

        super.dispose();
    }

    private function disposeParticleSystem():Void
    {
        displayObjectId = null;
        textureId = null;
        bundleId = null;
        emitterId = null;

        if (_emitter != null)
        {
            clear();

            _emitter.removeFromParent(true);

            _emitter = null;
        } else
        if (_displayObjectEmitter != null)
        {
            clear();

            _displayObjectEmitter.removeFromParent(true);

            _displayObjectEmitter = null;
        }
    }

    public function setAssetId(pexDir:String, textureId:String = null, bundleId:String = null):IParticleClip
    {
        disposeParticleSystem();

        this.textureId = textureId == null ? pexDir + "/texture.png" : textureId;
        this.bundleId = bundleId;
        emitterId = pexDir + "/particle.pex";

        createParticleSystem();

        return this;
    }

    public function setDisplayObject(pexDir:String, displayObjectId:String, bundleId:String = null):IParticleClip
    {
        disposeParticleSystem();

        if (res.getTexture(displayObjectId, bundleId) != null)
        {
            this.textureId = displayObjectId;
        } else
        {
            this.displayObjectId = displayObjectId;
        }

        this.bundleId = bundleId;
        emitterId = pexDir + "/particle.pex";

        createParticleSystem();

        return this;
    }

    private function createParticleSystem():Void
    {
        if (displayObjectId == null)
        {
            var conf:String = res.getText(emitterId);
            var tex:Texture = res.getTexture(textureId, bundleId);
            _emitter = new PDParticleSystem(conf, tex);
        } else
        {
            _displayObjectEmitter = new PexDisplayObjectParticleSystem(res, emitterId, displayObjectId, bundleId, particleInitCallBack);
        }

        _assets = emitter != null ? emitter : _displayObjectEmitter;

        if (_assets != null)
        {
            _assets.touchable = false;
        }
    }

    private function particleInitCallBack(particle:IDisplayObject):Void
    {
        if (hasMessageListener(ParticleClipMessageType.ParticleInit))
        {
            dispatchMessage(ParticleClipMessageType.ParticleInit, particle);
        }
    }

    public function pause():Void
    {
        juggler.remove(this);
    }

    public function resume():Void
    {
        emit(emitterX, emitterY);
        juggler.add(this);
    }

    public function stop(clearInSec:Float = 3.0):Void
    {
        emitter != null ? emitter.stop() : displayObjectEmitter.stop();

        clearDelayedCall.reset(clear, clearInSec);
        juggler.add(clearDelayedCall);
    }

    public function clear():Void
    {
        juggler.remove(clearDelayedCall);

        emitter != null ? emitter.stop(true) : displayObjectEmitter.stop(true);

        juggler.remove(this);
    }

    public function emit(x:Float = 0, y:Float = 0):Void
    {
        juggler.remove(clearDelayedCall);

        emitterX = x;
        emitterY = y;

        if (emitter != null && !emitter.isEmitting)
        {
            emitter.start();
            juggler.add(this);
        } else
        if (displayObjectEmitter != null && !displayObjectEmitter.isEmitting)
        {
            displayObjectEmitter.start();
            juggler.add(this);
        }
    }

    private function get_timeMultiplyer():Float
    {
        return _timeMultiplyer;
    }

    private function set_timeMultiplyer(value:Float):Float
    {
        return _timeMultiplyer = value;
    }

    public function advanceTime(time:Float):Void
    {
        if (emitter != null)
        {
            emitter.advanceTime(time * _timeMultiplyer);
        } else
        {
            displayObjectEmitter.advanceTime(time * _timeMultiplyer);
        }
    }

    public function get_lifeSpan():Float
    {
        return emitter != null ? emitter.lifespan : displayObjectEmitter.lifespan;
    }

    public function set_lifeSpan(value:Float):Float
    {
        if (emitter != null)
        {
            emitter.lifespan = value;
        } else
        {
            displayObjectEmitter.lifespan = value;
        }

        return value;
    }

    private function get_lifeSpanVariance():Float
    {
        return emitter != null ? emitter.lifespanVariance : displayObjectEmitter.lifespanVariance;
    }

    private function set_lifeSpanVariance(value:Float):Float
    {
        if (emitter != null)
        {
            emitter.lifespanVariance = value;
        } else
        {
            displayObjectEmitter.lifespanVariance = value;
        }

        return value;
    }

    private function get_sourcePosition():Point
    {
        pointHelper.x = emitterX;
        pointHelper.y = emitterY;

        return pointHelper;
    }

    private function set_sourcePosition(value:Point):Point
    {
        emitterX = value.x;
        emitterY = value.y;

        return value;
    }

    private function get_sourcePositionVariance():Point
    {
        pointHelper.x = (emitter != null ? emitter.emitterXVariance : displayObjectEmitter.emitterXVariance);
        pointHelper.y = (emitter != null ? emitter.emitterYVariance : displayObjectEmitter.emitterYVariance);

        return pointHelper;
    }

    private function set_sourcePositionVariance(value:Point):Point
    {
        if (emitter != null)
        {
            emitter.emitterXVariance = value.x;
            emitter.emitterYVariance = value.y;
        } else
        {
            displayObjectEmitter.emitterXVariance = value.x;
            displayObjectEmitter.emitterYVariance = value.y;
        }

        return value;
    }

    private function get_colorChangeDelay():Float
    {
//        return emitter.colorChangeDelay;
        return 0;
    }

    private function set_colorChangeDelay(value:Float):Float
    {
//        return emitter.colorChangeDelay = value;
        return 1;
    }

    private function get_emitterX():Float
    {
        return emitter != null ? emitter.emitterX : displayObjectEmitter.emitterX;
    }

    private function get_emitterY():Float
    {
        return emitter != null ? emitter.emitterY : displayObjectEmitter.emitterY;
    }

    private function set_emitterX(value:Float):Float
    {
        emitter != null ? emitter.emitterX = value : displayObjectEmitter.emitterX = value;

        return value;
    }

    private function set_emitterY(value:Float):Float
    {
        emitter != null ? emitter.emitterY = value : displayObjectEmitter.emitterY = value;

        return value;
    }

    private function get_emitter():PDParticleSystem
    {
        return _emitter;
    }

    private function get_displayObjectEmitter():PexDisplayObjectParticleSystem
    {
        return _displayObjectEmitter;
    }
}
#end