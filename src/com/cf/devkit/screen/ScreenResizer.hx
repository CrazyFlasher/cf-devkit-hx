package com.cf.devkit.screen;

import com.domwires.core.common.AbstractDisposable;
import com.cf.devkit.display.Stage;
import feathers.controls.Application;
import openfl.geom.Rectangle;

#if !useStarling
    import openfl.display.DisplayObject;
#else
    import starling.display.DisplayObject;
#end

class ScreenResizer extends AbstractDisposable
{
    private var appScale(get, set):Float;

    private var source:DisplayObject;
    private var padding:Rectangle;

    private var appWidth:Int;
    private var appHeight:Int;

    public function new(source:DisplayObject, padding:Rectangle, appWidth:Int, appHeight:Int)
    {
        super();

        this.source = source;
        this.padding = padding;
        this.appWidth = appWidth;
        this.appHeight = appHeight;

        init();
    }

    override public function dispose():Void
    {
        Stage.removeResizeListener(onStageResize);

        if (source != null)
        {
            source.scaleX = source.scaleY = 1.0;
        }

        source = null;
        padding = null;

        super.dispose();
    }

    private function init():Void
    {
        Stage.addResizeListener(onStageResize, 100);

        update();
    }

    private function onStageResize(e:Dynamic):Void
    {
		update();
    }

    public function update():Void
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

        var stageWidth:Float = openfl.Lib.application.window.stage.stageWidth;
        var stageHeight:Float = openfl.Lib.application.window.stage.stageHeight;

        var height:Float = #if (html5 && !standAlone) untyped getH() * openfl.Lib.application.window.scale #else stageHeight #end;
        var width:Float = stageWidth;

        var decHeight:Float = height * (padding.bottom + padding.top);
        var decWidth:Float = width * (padding.left + padding.right);

        var scaleX:Float = (width - decWidth) / appWidth;
        var scaleY:Float = (height - decHeight) / appHeight;
        var scale:Float = scaleX < scaleY ? scaleX : scaleY;

        appScale = scale;

        source.x = (width - appWidth * scale) / 2
            + (width * padding.left - width * padding.right) / 2;

        source.y = (height - appHeight * scale) / 2
            + (height * padding.top - height * padding.bottom) / 2;
    }

    private function get_appScale():Float
    {
        if (Std.is(source, Application))
        {
            var app:Application = cast source;

            return app.customScale;
        }

        return source.scaleX;
    }

    private function set_appScale(value:Float):Float
    {
        if (Std.is(source, Application))
        {
            var app:Application = cast source;
            app.customScale = value;
        } else
        {
            source.scaleX = source.scaleY = value;
        }

        return value;
    }
}
