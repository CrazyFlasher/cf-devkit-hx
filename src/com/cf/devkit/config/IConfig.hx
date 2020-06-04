package com.cf.devkit.config;

import com.cf.devkit.enums.AssetQuality;
import haxe.ds.ReadOnlyArray;
import hex.di.IInjectorContainer;

interface IConfig extends IInjectorContainer
{
    /**
    * Id list of mistery symbols that should be replaced.
    **/
    var mysterySymbolIdList(get, never):ReadOnlyArray<Int>;

    /**
    * Runtime chosen asset quality, depending on device.
    **/
    var assetsQuality(get, never):AssetQuality;

    /**
    * Base path to assets.
    **/
    var basePath(get, never):String;

    /**
    * Path to sounds.
    **/
    var soundsPath(get, never):String;

    /**
    * Path to swf asset lib.
    **/
    var swfAssetLibList(get, never):Array<String>;

    /**
    * Duration of each win to be highlighted on display.
    **/
    var singleWinHighLightDuration(get, never):Float;

    /**
    * All wins highlight duration.
    **/
    var allWinsHighLightDuration(get, never):Float;

    /**
    * Iterate though each win when showing all wins.
    **/
    var iterateWinsWhileHighlightingAll(get, never):Bool;

    /**
    * Pause wins iteration during big win.
    **/
    var pauseDuringBigWin(get, never):Bool;

    /**
    * Duration of increasing visual win value.
    **/
    var winCountUpDuration(get, never):Float;
}
