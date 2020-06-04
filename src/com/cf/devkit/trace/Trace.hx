package com.cf.devkit.trace;

class Trace
{
    public static inline var INFO:String = "color:blue;";
    public static inline var WARNING:String = "color:violet;";
    public static inline var ERROR:String = "color:red;";

    private static var TYPE_MAP:Array<String> = [
        INFO, WARNING, ERROR
    ];

    public static function init():Void
    {
        /*var tf:TextField = new TextField();
        tf.alpha = 0.75;
        tf.width = stage.stageWidth;
        tf.height = stage.stageHeight;
        tf.multiline = true;
        tf.wordWrap = true;
        tf.textColor = 0xffffff;
        stage.addChild(tf);

        haxe.Log.trace = (v:Dynamic, ?infos:haxe.PosInfos) ->
        {
            tf.appendText(Std.string(v) + "\n");
            tf.scrollV = tf.maxScrollV;
        }*/

        #if js
        var defaultTrace = haxe.Log.trace;
        haxe.Log.trace = (v:Dynamic, ?infos:haxe.PosInfos) ->
        {
            if (infos != null && infos.customParams != null)
            {
                for (param in infos.customParams)
                {
                    if(typeListContains(param))
                    {
                        infos.customParams.remove(param);

                        js.Browser.console.log("%c" + v, param, infos);

                        return;
                    }
                }
            }

            defaultTrace(v, infos);
        }
        #end
    }

    private static function typeListContains(param:String):Bool
    {
        for (type in TYPE_MAP)
        {
            if (type == param)
            {
                return true;
            }
        }

        return false;
    }
}
