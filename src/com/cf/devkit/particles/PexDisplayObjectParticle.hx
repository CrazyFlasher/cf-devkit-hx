// =================================================================================================
//
//	Starling Framework - Particle System Extension
//	Copyright Gamua GmbH. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package com.cf.devkit.particles;

import com.cf.devkit.bundle.IDisplayObject;

class PexDisplayObjectParticle extends AbstractDisplayObjectParticle
{
    public var startX:Float;
    public var startY:Float;
    public var velocityX:Float;
    public var velocityY:Float;
    public var radialAcceleration:Float;
    public var tangentialAcceleration:Float;
    public var emitRadius:Float;
    public var emitRadiusDelta:Float;
    public var emitRotation:Float;
    public var emitRotationDelta:Float;
    public var rotationDelta:Float;
    public var scaleDelta:Float;
    
    public function new(assets:IDisplayObject)
    {
        super(assets);
    }
}