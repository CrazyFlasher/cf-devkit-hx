package com.cf.devkit.bundle.impl.openfl;

#if !useStarling
import openfl.display.Bitmap;
import openfl.display.BitmapData;

class OpenFLImage extends OpenFLDisplayObject implements IImage
{
    public var bitmapData(get, set):BitmapData;
    private var _bitmapData:BitmapData;

    private var bitmap:Bitmap;

    override private function init():Void
    {
        bitmap = new Bitmap(null, null, true);
        _assets = bitmap;

        super.init();
    }

    private function get_bitmapData():BitmapData
    {
        return _bitmapData;
    }

    private function set_bitmapData(value:BitmapData):BitmapData
    {
        _bitmapData = value;

        if (_bitmapData != null)
        {
            bitmap.bitmapData = value;
            bitmap.smoothing = true;
        }

        return value;
    }
}
#end