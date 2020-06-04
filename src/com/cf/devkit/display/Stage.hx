package com.cf.devkit.display;

#if !useStarling
    import openfl.Lib;
    import openfl.display.Stage;
#else
    import starling.core.Starling;
    import starling.display.Stage;
#end

class Stage
{
    public static var stageWidth(get, never):Float;
    public static var stageHeight(get, never):Float;

    public static function get():#if !useStarling openfl.display.Stage #else starling.display.Stage #end
    {
        return #if !useStarling Lib.application.window.stage #else Starling.current.stage #end;
    }

    public static function addResizeListener(handler:Dynamic -> Void, priority:Int = 0):Void
    {
        #if !useStarling
            Lib.application.window.stage.addEventListener("resize", handler, false, priority);
        #else
            Starling.current.stage.addEventListener("resize", handler);
        #end
    }

    public static function removeResizeListener(handler:Dynamic -> Void):Void
    {
        #if !useStarling
            Lib.application.window.stage.removeEventListener("resize", handler, false);
        #else
        Starling.current.stage.removeEventListener("resize", handler);
        #end
    }

    private static function get_stageWidth():Float
    {
        return #if !useStarling Lib.application.window.stage.stageWidth #else Starling.current.stage.stageWidth #end;
    }

    private static function get_stageHeight():Float
    {
        //on iPhone safari, tabBar height is not excluded from window.innerHeight
        #if (html5 && !standAlone)
        untyped __js__("
            function getH()
            {
                const topBar = document.getElementById('topBarContainer')
                let topOffset = topBar ? (window.innerHeight - Number(getComputedStyle(topBar).height.slice(0, -2))) / window.innerHeight : 1

                function getComputedStyle(node) {
                    return node.nodeType === 1 ? node.ownerDocument.defaultView.getComputedStyle(node, null) : {};
                }

                return window.innerHeight - topOffset;
            }
        ");
        #end

        var stageHeight:Float = #if !useStarling Lib.application.window.stage.stageHeight #else Starling.current.stage.stageHeight #end;
        var height:Float = #if (html5 && !standAlone) untyped getH() * openfl.Lib.application.window.scale #else stageHeight #end;

        return height;
    }
}
