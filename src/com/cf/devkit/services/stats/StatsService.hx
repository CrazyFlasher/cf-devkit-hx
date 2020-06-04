package com.cf.devkit.services.stats;

import com.cf.devkit.display.Stage;
import openfl.Lib;

#if !useStarling
    import openfl.events.Event;
#else
    import starling.events.Event;
#end

@:keep
class StatsService extends AbstractService implements IStatsService
{
    public var fps(get, never):Int;

    private var cacheCount:Int;
    private var currentTime:Int;
    private var times:Array<Int>;

    private var _fps:Int = 0;

    @PostConstruct
    private function init():Void
    {
        cacheCount = 0;
        currentTime = 0;
        times = [];

       Stage.get().addEventListener(Event.ENTER_FRAME, enterFrame);
    }

    private function enterFrame(e:Event):Void
    {
        var time:Int = Lib.getTimer();
        var deltaTime:Int = time - currentTime;

        currentTime += deltaTime;
        times.push(currentTime);

        while (times[0] < currentTime - 1000)
        {
            times.shift();
        }

        var currentCount:Int = times.length;
        _fps = Math.round((currentCount + cacheCount) / 2);

        cacheCount = currentCount;
    }

    private function get_fps():Int
    {
        return _fps;
    }
}
