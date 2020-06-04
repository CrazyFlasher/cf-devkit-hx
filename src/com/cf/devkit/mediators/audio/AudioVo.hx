package com.cf.devkit.mediators.audio;

import com.cf.devkit.mediators.audio.AudioNode.AudioType;

class AudioVo 
{
    public var soundId(default, null):String;
    public var loop(default, null):Bool;
    public var volume(default, null):Float;
    public var type(default, null):AudioType;
    public var pauseOnSleep(default, null):Bool;

    public function new(soundId:String, loop:Bool = false, volume:Float = 1.0, type:AudioType = AudioType.Sfx, pauseOnSleep:Bool = true)
    {
        this.soundId = soundId;
        this.loop = loop;
        this.volume = volume;
        this.type = type;
        this.pauseOnSleep = pauseOnSleep;
    }
}