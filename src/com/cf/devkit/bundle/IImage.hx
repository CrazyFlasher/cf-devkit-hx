package com.cf.devkit.bundle;

import openfl.geom.Rectangle;

interface IImage extends IDisplayObject
{
    var scale9Grid(get, set):Rectangle;

    function setAssetId(assetId:String):Void;
    #if useStarling
    function setTexture(texture:starling.textures.Texture):Void;
    #end
}
