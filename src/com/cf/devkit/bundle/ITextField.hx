package com.cf.devkit.bundle;

#if useStarling
import starling.text.TextField;
#else
import openfl.text.TextField;
#end

interface ITextField extends IDisplayObject
{
    var text(get, set):String;
    var textField(get, never):TextField;
}
