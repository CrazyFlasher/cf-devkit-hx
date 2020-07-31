package com.cf.devkit.config;

import com.cf.devkit.utils.AssetQualityUtils;
import com.cf.devkit.enums.AssetQuality;
import com.cf.devkit.trace.Trace;
import haxe.ds.ReadOnlyArray;

class Config implements IConfig
{
    public var basePath(get, never):String;
    private var _basePath:String = "assets/";

    public var soundsPath(get, never):String;
    private var _soundsPath:String = "sounds";

    public var swfAssetLibList(get, never):Array<String>;
    private var _swfAssetLibList:Array<String>;

    public var assetsQuality(get, never):AssetQuality;
    private var _assetsQuality:AssetQuality;

    @PostConstruct
    private function init():Void
    {
        chooseAssetsQuality();
    }

    private function chooseAssetsQuality():Void
    {
        _assetsQuality = AssetQualityUtils.getQuality();

        trace("Chosen quality: " + _assetsQuality, Trace.INFO);

        #if !ignoreQuality
        _basePath += Std.string(_assetsQuality) + "/";
        #end
    }

    private function get_assetsQuality():AssetQuality
    {
        return _assetsQuality;
    }

    private function get_swfAssetLibList():Array<String>
    {
        return _swfAssetLibList;
    }

    private function get_basePath():String
    {
        return _basePath;
    }

    private function get_soundsPath():String
    {
        return _soundsPath;
    }
}
