package com.cf.devkit.enums;

import com.cf.devkit.trace.Trace;

enum abstract AssetQuality(String)
{
    var Low = "low";
    var Medium = "medium";
    var High = "high";
}

class AssetQualityFromString
{
    public static function get(name:String):AssetQuality
    {
        if (name == cast AssetQuality.Low) return AssetQuality.Low;
        if (name == cast AssetQuality.Medium) return AssetQuality.Medium;
        if (name == cast AssetQuality.High) return AssetQuality.High;

        trace("Invalid assets quality: " + name, Trace.WARNING);

        return AssetQuality.Medium;
    }
}