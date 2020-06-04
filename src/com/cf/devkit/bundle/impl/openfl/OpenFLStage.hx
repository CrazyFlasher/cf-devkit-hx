package com.cf.devkit.bundle.impl.openfl;

#if !useStarling
import openfl.display.Stage;

class OpenFLStage extends OpenFLDisplayObject implements IStage
{
    @Inject("stage")
    private var stage:Stage;

    public var stageWidth(get, never):Float;
    public var stageHeight(get, never):Float;

    override private function init():Void
    {
        _assets = stage;

        super.init();
    }

    private function get_stageWidth():Float
    {
        return stage.stageWidth;
    }

    private function get_stageHeight():Float
    {
        return stage.stageHeight;
    }
}
#end