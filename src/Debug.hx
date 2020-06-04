import com.cf.devkit.app.AbstractApp;
import dragonBones.animation.WorldClock;
import motion.Actuate;
import com.cf.devkit.trace.Trace;

#if useStarling
import starling.core.Starling;
import dragonBones.starling.StarlingFactory;
#end

@:keep @:expose
class Debug
{
    public static function setTimeScale(value:Float = 1.0):Void
    {
        #if useStarling
        if (Starling.current == null || Starling.current.juggler == null)
        {
            trace("Starling is not initialized yet!", Trace.WARNING);
        } else
        {
            Starling.current.juggler.timeScale = value;
            trace("Setting global timeScale to: " + value, Trace.INFO);
        }


        //Warning! Taking private property via reflect.
        //Might not work on some platforms.
        var clock:WorldClock = Reflect.getProperty(StarlingFactory, "_clock");
        clock.timeScale = value;
        #end

        Actuate.timeScale = value;
        //TODO: timeScale SpineManager needed for OpenFL target (not Starling)
    }

    public static function setAlpha(value:Float = 1.0):Void
    {
        openfl.Lib.application.window.stage.getChildAt(0).alpha = value;
        #if useStarling
        Starling.current.root.alpha = value;
        #end
    }

    public static function showStats(value:Bool = true):Void
    {
        AbstractApp.showStats(value);
    }
}
