package com.cf.devkit.bundle;

import starling.textures.Texture;
import com.cf.devkit.services.IServiceIImmutable;

interface IMovieClipBundleServiceImmutable extends IServiceIImmutable
{
    function getMovieClip(id:String, forceReturnNew:Bool = false):IMovieClip;
    function getDisplayObject(id:String, forceReturnNew:Bool = false):IDisplayObject;
    #if useStarling
    function getTexture(id:String):Texture;
    #end
}
