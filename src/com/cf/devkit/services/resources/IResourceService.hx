package com.cf.devkit.services.resources;

import com.cf.devkit.services.resources.ResourceService;
import openfl.display.BitmapData;

interface IResourceService extends IResourceServiceImmutable extends IService
{
    function loadFromManifest(path:String = null):IResourceService;
    function setBitmapData(path:String, value:BitmapData):IResourceService;

    #if useStarling
    function setTexture(id:String, value:starling.textures.Texture):IResourceService;
    #end
}
