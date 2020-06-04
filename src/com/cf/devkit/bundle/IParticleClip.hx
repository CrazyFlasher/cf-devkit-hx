package com.cf.devkit.bundle;

import com.cf.devkit.particles.PexDisplayObjectParticleSystem;
import com.cf.devkit.bundle.IDisplayObject;
import openfl.geom.Point;

interface IParticleClip extends IDisplayObject
{
    var emitterX(get, set):Float;
    var emitterY(get, set):Float;

    var timeMultiplyer(get, set):Float;
    var lifeSpan(get, set):Float;
    var lifeSpanVariance(get, set):Float;
    var sourcePosition(get, set):Point;
    var sourcePositionVariance(get, set):Point;
    var colorChangeDelay(get, set):Float;

    function setAssetId(pexDir:String, textureId:String = null, bundleId:String = null):IParticleClip;
    function setDisplayObject(pexDir:String, displayObjectId:String, bundleId:String = null):IParticleClip;
    function pause():Void;
    function resume():Void;
    function stop(clearInSec:Float = 3.0):Void;
    function emit(x:Float = 0, y:Float = 0):Void;
    function clear():Void;

    #if useStarling
    var emitter(get, never):starling.extensions.PDParticleSystem;
    var displayObjectEmitter(get, never):PexDisplayObjectParticleSystem;
    #else
    var emitter(get, never):org.zamedev.particles.ParticleSystem;
    #end
}
