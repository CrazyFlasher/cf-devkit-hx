package com.cf.devkit.mediators.audio;

import com.cf.devkit.services.resources.IResourceServiceImmutable;
import com.domwires.core.mvc.message.MessageDispatcher;
import com.cf.devkit.tween.ITween;
import haxe.Json;
import motion.Actuate;
import motion.actuators.IGenericActuator;
import openfl.events.Event;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;

@:keep
class AudioNode extends MessageDispatcher
{
    public var resultVolume(get, null):Float;

    public var volume(get, set):Float;
    private var _volume:Float = 1;

    public var masterVolume(never, set):Float;
    private var _masterVolume:Float = 1;

    private var res:IResourceServiceImmutable;
    private var soundId:String;
    private var loop:Bool;
    private var pauseOnSleep:Bool;

    private var isPaused:Bool = false;

    private var sound:Sound;
    private var channel:SoundChannel;

    private var startOffset:Int = 0;
    private var totalDuration:Int = 0;

    // For extra loop options
    private var startLoopOffset:Int = 0;
    private var loopDuration:Int = 0;

    private var resumeTime:Float = 0;
    public var type(default, null):AudioType;

    private var timer:IGenericActuator;
    private var volumeTween:ITween;
    private var isDelay:Bool;

    public function new(soundId:String, res:IResourceServiceImmutable, pauseOnSleep:Bool, type:AudioType, volumeTween:ITween)
    {
        super();

        this.res = res;
        this.soundId = soundId;
        this.pauseOnSleep = pauseOnSleep;
        this.type = type;
        this.volumeTween = volumeTween;

        var loopDataId:String = soundId + ".json";

        if (res.exists(loopDataId, #if useStarling starling.assets.AssetType.OBJECT #else cast openfl.utils.AssetType.TEXT #end))
        {
            trace("Loop file exists: " + loopDataId);

            var loopId:String = soundId.substr(soundId.lastIndexOf("/") + 1, soundId.length);
            var loopData:Array<Dynamic> = Reflect.getProperty(Json.parse(res.getText(loopDataId)).sprite, "loop-" + loopId);

            if (loopData.length >= 2)
            {
                startOffset = loopData[0];
                totalDuration = loopData[1];

                startLoopOffset = startOffset;
                loopDuration = totalDuration;

                if (loopData.length >= 3)
                {
                    startLoopOffset = loopData[2];
                }
                
                if (loopData.length >= 4)
                {
                    loopDuration = loopData[3];
                }
            }
        }
    }

    public function getLoopTimer():IGenericActuator
    {
        return timer;
    }

    public function getIsLoop():Bool
    {
        return loop;
    }

    public function getId():String
    {
        return soundId;
    }

    public function getCanPause():Bool
    {
        return pauseOnSleep;
    }

    public function play(loop:Bool = false, startTime:Int = 0, fadeIn:Float = 0, delay:Float = 0):Void
    {
        this.loop = loop;

        var ext:String;

        #if mobile
        ext = ".ogg";
        #else
        ext = ".mp3";
        #end

        if (delay > 0)
        {
            isDelay = true;
            timer = Actuate.timer(delay);
            timer.onComplete(()-> {
                play(loop, startTime, fadeIn);
            });
            return;
        }

        isDelay = false;
        sound = res.getSound(soundId + ext);

        if (sound == null)
        {
            trace("Sound not found. Check file path. If OK, then Probably issue with platform and AudioBuffer!");
            dispatchMessage(SfxMessageType.SfxComplete);
            return;
        }

        if (totalDuration == 0)
        {
            totalDuration = Std.int(sound.length);
        }
        if (loopDuration == 0)
        {
            loopDuration = totalDuration - startLoopOffset;
        }

        var offset = startTime == 0 ? startOffset : startTime;
        channel = sound.play(offset, loop ? 1000000000 : 0, new SoundTransform(resultVolume));

        if (channel == null)
        {
            trace("Out of sound channel limit amount or no sound card installed!");
            onComplete(null);
            return;
        }

        if (loop)
        {
            if (startLoopOffset != startOffset || loopDuration != totalDuration)
            {
                if (offset >= (loopDuration + startLoopOffset))
                {
                    offset = startLoopOffset;
                }
                var duration:Float = startLoopOffset + loopDuration - offset;
                startLoop(offset, duration);
            }
        } else
        {
            channel.addEventListener(Event.SOUND_COMPLETE, onComplete, false, 0, true);
        }

        if (fadeIn > 0)
        {
            fadeVolume(fadeIn, volume);
            volume = 0;
        }
    }

    public function getIsPaused():Bool
    {
        return isPaused;
    }

    public function stop(fadeOut:Float = 0):Void
    {
        if (channel != null)
        {
            if (fadeOut > 0)
            {
                stopVolumeTween();
                volumeTween.setOnComplete(() -> {
                    stop(0);
                });
                fadeVolume(fadeOut, 0);
            } else {
                stopTimer();
                channel.stop();
                channel = null;
                dispatchMessage(SfxMessageType.SfxComplete);
            }
        }
        else if (timer != null)
        {
            stopTimer();
            dispatchMessage(SfxMessageType.SfxComplete);
        }
    }

    public function pause():Void
    {
        if (isPaused) return;
        if (!getCanPause()) return;

        isPaused = true;

        volumeTween.pause();

        if (channel != null)
        {
            resumeTime = channel.position;
            channel.stop();
            channel = null;
        }
    }

    public function resume():Void
    {
        if (!isPaused) return;

        volumeTween.resume();
        isPaused = false;

        if (!isDelay)
        {
            play(loop);
            if (resumeTime > 0)
            {
                channel.position = resumeTime;
                resumeTime = 0;
            }
        }
    }

    private function stopTimer()
    {
        if (timer != null)
        {
            Actuate.stop(timer, null, false, false);
            timer = null;
        }
    }

    private function restartLoop():Void
    {
        startLoop(startLoopOffset, loopDuration);
    }

    private function startLoop(offset:Float, duration:Float):Void
    {
        stopTimer();
        if (channel != null)
        {
            channel.position = offset;
            timer = Actuate.timer(duration / 1000.0);
            timer.onComplete(restartLoop);
        }
    }

    private function onComplete(e:Event):Void
    {
        stop();
    }

    private function get_volume():Float
    {
        return _volume;
    }

    private function set_masterVolume(value:Float):Float
    {
        _masterVolume = value;

        return value;
    }

    private function set_volume(value:Float):Float
    {
        _volume = value;

        return value;
    }

    private function get_resultVolume():Float
    {
        return _volume * _masterVolume;
    }

    public function updateVolume():Void
    {
        if (channel != null)
        {
            channel.soundTransform = new SoundTransform(resultVolume);
        }
    }

    private function fadeVolume(fadeTime:Float, volume:Float):Void
    {
        stopVolumeTween();

        volumeTween.setOnUpdate(updateVolume);
        volumeTween.tween(this, fadeTime, {volume: volume});
    }

    private function stopVolumeTween():Void
    {
        volumeTween.removeAllMessageListeners();
        volumeTween.stop(false);
    }
}

enum SfxMessageType
{
    SfxComplete;
}

enum AudioType
{
    Sfx;
    Music;
}