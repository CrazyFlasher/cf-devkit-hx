package com.cf.devkit.services.resources;

#if !useStarling
import openfl.display.Tileset;
import com.cf.devkit.bitmapFont.BitmapFont;
import openfl.display.BitmapData;
#end
import com.cf.devkit.bundle.IDisplayObject;
import com.cf.devkit.bundle.IMovieClip;
import openfl.utils.ByteArray;
import openfl.media.Sound;
import openfl.text.Font;

interface IResourceServiceImmutable extends IServiceIImmutable
{
    var progress(get, never):Float;
    var contentScaleFactor(get, never):Float;

    function exists(path:String, type:String = null):Bool;
    function getText(path:String):String;
    function getSound(path:String):Sound;
    function hasMovieClipLibrary(libId:String = null):Bool;
    function getBytes(path:String):ByteArray;
    function getFont(path:String):Font;
    function getMovieClip(id:String, libId:String = null, forceReturnNew:Bool = false):IMovieClip;
    function getDisplayObject(id:String, libId:String = null, forceReturnNew:Bool = false):IDisplayObject;
    function getJson(path:String):Dynamic;
    function isQualityDependant(assetId:String):Bool;

    #if useStarling
    function getTexture(path:String, bundleId:String = null):starling.textures.Texture;
    function getTextureAtlas(path:String):starling.textures.TextureAtlas;
    function getBitmapFont(path:String):starling.text.BitmapFont;
    function getSpineAnimation(assetPath:String, skeletonPath:String = null):spine.starling.SkeletonAnimation;
    function getDragonBonesAnimation(texturePath:String, skeletonPath:String = null, textureConfigPath:String = null,
                                     armatureName:String = null):dragonBones.starling.StarlingArmatureDisplay;
    #else
    function getBitmapData(path:String):BitmapData;
    function getBitmapFont(path:String):BitmapFont;
    function getSpineTileset(assetPath:String, skeletonPath:String = null):Tileset;
    function getSpineTilemapSkeleton(assetPath:String, skeletonPath:String = null):spine.tilemap.SkeletonAnimation;
    function getSpineSpriteSkeleton(assetPath:String, skeletonPath:String = null):spine.openfl.SkeletonAnimation;
    function getSpriteSheet(path:String, ext:String = "png", exp:EReg = null):Spritesheet;
    function getDragonBonesAnimation(texturePath:String, skeletonPath:String = null, textureConfigPath:String = null,
                                     armatureName:String = null):dragonBones.openfl.OpenFLArmatureDisplay;
    #end
}
