// =================================================================================================
//
//	Starling Framework - Particle System Extension
//	Copyright 2012 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package com.cf.devkit.particles;

import haxe.io.Error;
import openfl.display3D.Context3DBlendFactor;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.Vector;
import starling.animation.IAnimatable;
import starling.display.BlendMode;
import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.events.Event;
import starling.utils.MatrixUtil;
import starling.utils.Max;
import starling.utils.MeshSubset;

/** Dispatched when emission of particles is finished. */
@:meta(Event(name="complete", type="starling.events.Event"))

class AbstractDisplayObjectParticleSystem extends Sprite implements IAnimatable
{
    public static inline var MAX_NUM_PARTICLES:Int = 16383;
    
    private var _particles:Vector<AbstractDisplayObjectParticle>;
    private var _frameTime:Float;
    private var _numParticles:Int = 0;
    private var _emissionRate:Float; // emitted particles per second
    private var _emissionTime:Float;
    private var _emitterX:Float;
    private var _emitterY:Float;
    private var _blendFactorSource:Context3DBlendFactor;
    private var _blendFactorDestination:Context3DBlendFactor;

    // helper objects
    private static var sHelperMatrix:Matrix = new Matrix();
    private static var sHelperPoint:Point = new Point();
    private static var sSubset:MeshSubset = new MeshSubset();

    public function new()
    {
        super();

        touchable = false;

        _particles = new Vector<AbstractDisplayObjectParticle>(0, false);
        _frameTime = 0.0;
        _emitterX = _emitterY = 0.0;
        _emissionTime = 0.0;
        _emissionRate = 10;
        _blendFactorSource = Context3DBlendFactor.ONE;
        _blendFactorDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;

        updateBlendMode();
    }

    /** @inheritDoc */
    override public function dispose():Void
    {
        if (parent != null)
        {
            removeFromParent(true);
        } else
        {
            super.dispose();
        }
    }

    /** Always returns <code>null</code>. An actual test would be too expensive. */
    override public function hitTest(localPoint:Point):DisplayObject
    {
        return null;
    }

    private function updateBlendMode():Void
    {
        // Particle Designer uses special logic for a certain blend factor combination
        if (_blendFactorSource == Context3DBlendFactor.ONE &&
            _blendFactorDestination == Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA)
        {
            _blendFactorSource = Context3DBlendFactor.SOURCE_ALPHA;
        }
        
        var registeredBlendMode:BlendMode = BlendMode.getByFactors(_blendFactorSource, _blendFactorDestination);
        if (registeredBlendMode != null)
        {
            blendMode = registeredBlendMode.name;
        }
        else
        {
            blendMode = _blendFactorSource + ", " + _blendFactorDestination;
            BlendMode.register(blendMode, _blendFactorSource, _blendFactorDestination);
        }
    }
    
    private function createParticle():AbstractDisplayObjectParticle
    {
        throw Error.Custom("Override!");
    }
    
    private function initParticle(particle:AbstractDisplayObjectParticle):Void
    {
        particle.x = _emitterX;
        particle.y = _emitterY;
        particle.currentTime = 0;
        particle.totalTime = 1;
    }

    private function advanceParticle(particle:AbstractDisplayObjectParticle, passedTime:Float):Void
    {
        particle.alpha = 1;

        particle.y += passedTime * 250;
        particle.alpha = 1.0 - particle.currentTime / particle.totalTime;
        particle.currentTime += passedTime;
    }

    /** Starts the emitter for a certain time. @default infinite time */
    public function start(duration:Float=Max.MAX_VALUE):Void
    {
        if (_emissionRate != 0)
            _emissionTime = duration;
    }
    
    /** Stops emitting new particles. Depending on 'clearParticles', the existing particles
        *  will either keep animating until they die or will be removed right away. */
    public function stop(clearParticles:Bool=false):Void
    {
        _emissionTime = 0.0;
        if (clearParticles) clear();
    }
    
    /** Removes all currently active particles. */
    public function clear():Void
    {
        _numParticles = 0;

        for (partcle in _particles)
        {
            partcle.assets.visible = false;
        }
    }
    
    /** Returns an empty rectangle at the particle system's position. Calculating the
        *  actual bounds would be too expensive. */
    public override function getBounds(targetSpace:DisplayObject,
                                        resultRect:Rectangle=null):Rectangle
    {
        if (resultRect == null) resultRect = new Rectangle();
        
        getTransformationMatrix(targetSpace, sHelperMatrix);
        MatrixUtil.transformCoords(sHelperMatrix, 0, 0, sHelperPoint);
        
        resultRect.x = sHelperPoint.x;
        resultRect.y = sHelperPoint.y;
        resultRect.width = resultRect.height = 0;
        
        return resultRect;
    }
    
    public function advanceTime(passedTime:Float):Void
    {
        var particleIndex:Int = 0;
        var particle:AbstractDisplayObjectParticle;
        var maxNumParticles:Int = capacity;
        
        // advance existing particles

        while (particleIndex < _numParticles)
        {
            particle = _particles[particleIndex];
            
            if (particle.currentTime < particle.totalTime)
            {
                advanceParticle(particle, passedTime);
                ++particleIndex;
            }
            else
            {
                if (particleIndex != _numParticles - 1)
                {
                    var nextParticle:AbstractDisplayObjectParticle = _particles[Std.int(_numParticles-1)];
                    _particles[Std.int(_numParticles-1)] = particle;
                    _particles[particleIndex] = nextParticle;
                }

                --_numParticles;

                if (_numParticles == 0 && _emissionTime == 0)
                    dispatchEventWith(Event.COMPLETE);
            }
        }
        
        // create and advance new particles
        
        if (_emissionTime > 0)
        {
            var timeBetweenParticles:Float = 1.0 / _emissionRate;
            _frameTime += passedTime;
            
            while (_frameTime > 0)
            {
                if (_numParticles < maxNumParticles)
                {
                    if (_numParticles >= _particles.length)
                    {
                        _particles[_numParticles] = createParticle();
                    }

                    particle = _particles[_numParticles];
                    initParticle(particle);
                    
                    // particle might be dead at birth
                    if (particle.totalTime > 0.0)
                    {
                        advanceParticle(particle, _frameTime);
                        ++_numParticles;
                    }
                }
                
                _frameTime -= timeBetweenParticles;
            }
            
            if (_emissionTime != Max.MAX_VALUE)
                _emissionTime = _emissionTime > passedTime ? _emissionTime - passedTime : 0.0;

            if (_numParticles == 0 && _emissionTime == 0)
                dispatchEventWith(Event.COMPLETE);
        }

        // update vertex data
        
        var rotation:Float;
        var x:Float, y:Float;
        var offsetX:Float, offsetY:Float;
        var pivotX:Float = 0;
        var pivotY:Float = 0;
        
        for (i in 0..._numParticles)
        {
            particle = _particles[i];
            rotation = particle.rotation;
            offsetX = pivotX * particle.scale;
            offsetY = pivotY * particle.scale;
            x = particle.x;
            y = particle.y;
        }
    }

    /** Initialize the <code>ParticleSystem</code> with particles distributed randomly
        *  throughout their lifespans. */
    public function populate(count:Int):Void
    {
        var maxNumParticles:Int = capacity;
        count = Std.int(Math.min(count, maxNumParticles - _numParticles));
        
        var p:AbstractDisplayObjectParticle;
        for (i in 0...count)
        {
            p = _particles[_numParticles+i];
            initParticle(p);
            advanceParticle(p, Math.random() * p.totalTime);
        }
        
        _numParticles += count;
    }

    public var capacity(get, set):Int;
    private var _capacity:Int = 0;

    private function get_capacity():Int
    {
        return _capacity;
    }
    private function set_capacity(value:Int):Int
    {
        var oldCapacity:Int = _capacity;
        var newCapacity:Int = value > MAX_NUM_PARTICLES ? MAX_NUM_PARTICLES : value;

        /*for (i in oldCapacity...newCapacity)
        {
            _particles[i] = createParticle();
        }*/

        if (newCapacity < oldCapacity)
        {
            var i:Int = _particles.length;
            while (i > newCapacity)
            {
                _particles[i].assets.dispose();

                i--;
            }

            _particles.length = newCapacity;

            if (_numParticles > newCapacity)
            {
                _numParticles = newCapacity;
            }
        }

        _capacity = value;

        return value;
    }
    
    // properties

    public var isEmitting(get, never):Bool;
    private function get_isEmitting():Bool { return _emissionTime > 0 && _emissionRate > 0; }
   
    public var numParticles(get, never):Int;
    private function get_numParticles():Int { return _numParticles; }
    
    public var emissionRate(get, set):Float;
    private function get_emissionRate():Float { return _emissionRate; }
    private function set_emissionRate(value:Float):Float { return _emissionRate = value; }
    
    public var emitterX(get, set):Float;
    private function get_emitterX():Float { return _emitterX; }
    private function set_emitterX(value:Float):Float { return _emitterX = value; }
    
    public var emitterY(get, set):Float;
    private function get_emitterY():Float { return _emitterY; }
    private function set_emitterY(value:Float):Float { return _emitterY = value; }
    
    public var blendFactorSource(get, set):Context3DBlendFactor;
    private function get_blendFactorSource():Context3DBlendFactor { return _blendFactorSource; }
    private function set_blendFactorSource(value:Context3DBlendFactor):Context3DBlendFactor
    {
        _blendFactorSource = value;
        updateBlendMode();
        return value;
    }
    
    public var blendFactorDestination(get, set):Context3DBlendFactor;
    private function get_blendFactorDestination():Context3DBlendFactor { return _blendFactorDestination; }
    private function set_blendFactorDestination(value:Context3DBlendFactor):Context3DBlendFactor
    {
        _blendFactorDestination = value;
        updateBlendMode();
        return value;
    }
}