package com.cf.devkit.config;

import com.cf.devkit.enums.AssetQuality;
import haxe.ds.ReadOnlyArray;
import hex.di.IInjectorContainer;

interface IConfig extends IInjectorContainer
{
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
}
