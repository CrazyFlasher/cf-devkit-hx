package com.cf.devkit.mediators.audio;

import com.domwires.core.mvc.mediator.IMediator;
import com.cf.devkit.mediators.audio.AudioMediator;

interface IAudioMediator extends IMediator
{
    /**
    * Play audio
    * @param audio audio playback settings
    * @param fadeIn play with fade In volume, 0 = no fadeIn (Optional)
    **/
    function playAudio(audio:AudioVo, fadeIn:Float = 0, delay:Float = 0):Void;

    /**
    * Stop audio
    * @param id id of the sound
    * @param fadeOut stop with fade Out volume, 0 = no fadeOut (Optional)
    **/
    function stopAudio(id:String, fadeOut:Float = 0):Void;

    /**
    * Play sound, same as playAudio, but old way
    **/
    @deprecated
    function play(id:String, loop:Bool = false, volume:Float = 1.0, isMusic:Bool = false, pauseOnSleep:Bool = true, fadeIn:Float = 0, delay:Float = 0):Void;

    /**
    * Stop all music instances
    * @param fadeOut stop with fade Out volume, 0 = no fadeOut (Optional)
    **/
    function stopMusic(fadeOut:Float = 0):Void;

    /**
    * Stops all AudioType.Sfx sounds
    **/
    function stopSfx(fadeOut:Float = 0):Void;

    /**
    * Check if sound is looping and playing
    * @param id id of the sound
    **/
    function isPlayingLoop(id:String):Bool;
    
    /**
    * Check if sound is playing
    * @param id id of the sound
    **/
    function isPlaying(id:String):Bool;
}
