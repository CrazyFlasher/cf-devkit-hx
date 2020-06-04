package com.cf.devkit.config;

import com.cf.devkit.utils.AssetQualityUtils;
import com.cf.devkit.enums.AssetQuality;
import com.cf.devkit.trace.Trace;
import haxe.ds.ReadOnlyArray;

class CasinoConfig implements ICasinoConfig
{
    public var singleWinHighLightDuration(get, never):Float;
    public var allWinsHighLightDuration(get, never):Float;
    public var iterateWinsWhileHighlightingAll(get, never):Bool;
    public var pauseDuringBigWin(get, never):Bool;
    public var winCountUpDuration(get, never):Float;

    public var basePath(get, never):String;
    private var _basePath:String = "assets/";

    public var soundsPath(get, never):String;
    private var _soundsPath:String = "sounds";

    public var swfAssetLibList(get, never):Array<String>;
    private var _swfAssetLibList:Array<String>;

    public var assetsQuality(get, never):AssetQuality;
    private var _assetsQuality:AssetQuality;

    public var mysterySymbolIdList(get, never):ReadOnlyArray<Int>;
    private var _mysterySymbolIdList:Array<Int> = [];

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

    private function get_mysterySymbolIdList():ReadOnlyArray<Int>
    {
        return _mysterySymbolIdList;
    }

    private function get_singleWinHighLightDuration():Float
    {
        return 1;
    }

    private function get_allWinsHighLightDuration():Float
    {
        return 2;
    }

    private function get_iterateWinsWhileHighlightingAll():Bool
    {
        return false;
    }

    private function get_pauseDuringBigWin():Bool
    {
        return false;
    }

    private function get_winCountUpDuration():Float
    {
        return 5;
    }
}
