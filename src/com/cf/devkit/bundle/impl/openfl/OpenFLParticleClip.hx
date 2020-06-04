package com.cf.devkit.bundle.impl.openfl;

#if !useStarling
import motion.Actuate;
import motion.actuators.IGenericActuator;
import com.cf.devkit.bundle.impl.openfl.OpenFLDisplayObject;
import org.zamedev.particles.util.ParticleVector;
import openfl.geom.Point;
import org.zamedev.particles.loaders.ParticleLoader;
import org.zamedev.particles.internal.TilemapExt;
import org.zamedev.particles.ParticleSystem;
import org.zamedev.particles.renderers.TileContainerParticleRenderer;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;

@:keep
class OpenFLParticleClip extends OpenFLDisplayObject implements IParticleClip
{
    public var emitter(get, never):org.zamedev.particles.ParticleSystem;

    public var emitterX(get, set):Float;
    public var emitterY(get, set):Float;

    public var timeMultiplyer(get, set):Float;
    private var _timeMultiplyer:Float = 1.0;

    public var lifeSpan(get, set):Float;
    public var lifeSpanVariance(get, set):Float;
    public var sourcePosition(get, set):Point;
    public var sourcePositionVariance(get, set):Point;
    public var colorChangeDelay(get, set):Float;

    private var particleRenderer:TileContainerParticleRenderer;

    @Inject
    private var emitterId:String;

    private var particleTilemapContainer:DisplayObjectContainer;

    private var _emitter:ParticleSystem;

    private var isPaused:Bool;

    private var pointHelper:Point = new Point();
    private var particleVectorHelper:ParticleVector = new ParticleVector(0, 0);

    private var delayedCall:IGenericActuator;

    override private function init():Void
    {
        super.init();

        createParticleSystem();
    }

    public function clear():Void
    {
        if (delayedCall != null) Actuate.stop(delayedCall, null, false, false);

        _emitter.reset();

        _assets.removeEventListener(Event.ENTER_FRAME, updateParticleRenderer);
    }

    override public function dispose():Void
    {
        clear();

        if (particleTilemapContainer != null)
        {
            particleTilemapContainer.removeChildren();
        }

        super.dispose();
    }

    public function pause():Void
    {
        isPaused = true;
    }

    public function resume():Void
    {
        isPaused = false;
    }

    public function stop(clearInSec:Float = 3.0):Void
    {
        if (delayedCall != null) Actuate.stop(delayedCall, null, false, false);

        _emitter.stop();

        if (clearInSec > 0)
        {
            delayedCall = Actuate.timer(clearInSec).onComplete(clear);
        } else
        {
            clear();
        }
    }

    private function createParticleSystem():Void
    {
        particleRenderer = new TileContainerParticleRenderer(true);
        particleRenderer.x = particleRenderer.y = 2500;

        particleTilemapContainer = new Sprite();

        var particleTileMap:TilemapExt = new TilemapExt(5000, 5000);
        particleTileMap.x = particleTileMap.y = -2500;

        particleTilemapContainer.addChild(particleTileMap);

        particleTileMap.addTile(particleRenderer);

        _emitter = ParticleLoader.load(emitterId);
        particleRenderer.addParticleSystem(_emitter);

        _assets = particleTilemapContainer;
    }

    public function emit(x:Float, y:Float):Void
    {
        _assets.addEventListener(Event.ENTER_FRAME, updateParticleRenderer);

        _emitter.emit(x, y);
    }

    private function updateParticleRenderer(e:Event):Void
    {
        if (!isPaused)
        {
            particleRenderer.update();
        }
    }

    private function get_timeMultiplyer():Float
    {
        return _timeMultiplyer;
    }

    private function set_timeMultiplyer(value:Float):Float
    {
        _emitter.setTimeMultiplier(value);

        return _timeMultiplyer = value;
    }

    public function get_lifeSpan():Float
    {
        return _emitter.particleLifespan;
    }

    public function set_lifeSpan(value:Float):Float
    {
        return _emitter.particleLifespan = value;
    }

    private function get_lifeSpanVariance():Float
    {
        return _emitter.particleLifespanVariance;
    }

    private function set_lifeSpanVariance(value:Float):Float
    {
        return _emitter.particleLifespanVariance = value;
    }

    private function get_sourcePosition():Point
    {
        pointHelper.x = _emitter.sourcePosition.x;
        pointHelper.y = _emitter.sourcePosition.y;

        return pointHelper;
    }

    private function set_sourcePosition(value:Point):Point
    {
        particleVectorHelper.x = value.x;
        particleVectorHelper.y = value.y;

        _emitter.sourcePosition = particleVectorHelper;

        return value;
    }

    private function get_sourcePositionVariance():Point
    {
        pointHelper.x = _emitter.sourcePositionVariance.x;
        pointHelper.y = _emitter.sourcePositionVariance.y;

        return pointHelper;
    }

    private function set_sourcePositionVariance(value:Point):Point
    {
        particleVectorHelper.x = value.x;
        particleVectorHelper.y = value.y;

        _emitter.sourcePositionVariance = particleVectorHelper;

        return value;
    }

    private function get_colorChangeDelay():Float
    {
        return _emitter.colorChangeDelay;
    }

    private function set_colorChangeDelay(value:Float):Float
    {
        return _emitter.colorChangeDelay = value;
    }

    private function get_emitterX():Float
    {
        return _emitter.sourcePosition.x;
    }

    private function get_emitterY():Float
    {
        return _emitter.sourcePosition.y;
    }

    private function set_emitterX(value:Float):Float
    {
        _emitter.sourcePosition.x = value;

        return value;
    }

    private function set_emitterY(value:Float):Float
    {
        _emitter.sourcePosition.y = value;

        return value;
    }

    private function get_emitter():ParticleSystem
    {
        return _emitter;
    }
}
#end