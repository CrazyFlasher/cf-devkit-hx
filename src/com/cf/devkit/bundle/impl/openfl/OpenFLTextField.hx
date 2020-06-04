package com.cf.devkit.bundle.impl.openfl;

#if !useStarling
import openfl.text.TextField;

class OpenFLTextField extends OpenFLDisplayObject implements ITextField
{
    @Inject("textField")
    private var tf:TextField;

    public var text(get, set):String;
    public var textField(get, never):TextField;

    private function get_text():String
    {
        return tf.text;
    }

    private function set_text(value:String):String
    {
        return tf.text = value;
    }

    private function get_textField():TextField
    {
        return tf;
    }
}
#end