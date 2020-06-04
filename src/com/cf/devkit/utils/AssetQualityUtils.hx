package com.cf.devkit.utils;

import com.cf.devkit.enums.AssetQuality;
import com.cf.devkit.enums.AssetQuality.AssetQualityFromString;
import com.cf.devkit.trace.Trace;
#if html5
import js.html.webgl.RenderingContext;
import js.html.CanvasElement;
#end

class AssetQualityUtils
{
    public static function getQuality():AssetQuality
    {
        //TODO: fix webOS issue
        #if webOS
        return AssetQuality.Low;
        #end

        var forcedQuality:String = null;

        #if (html5 && !webOS)
        var url_string = js.Browser.window.document.documentURI;
        var url = new js.html.URL(url_string);
        forcedQuality = url.searchParams.get("quality");
        #end
        #if forcedQuality
        forcedQuality = haxe.macro.Compiler.getDefine("forcedQuality");
        #end

        if (forcedQuality != null)
        {
            trace("Forced to use quality: " + forcedQuality, Trace.INFO);
            return AssetQualityFromString.get(forcedQuality);
        }

        #if (html5 && !webOS)
        var resolution:AssetQuality;
        try { resolution = get(); } catch (e:Dynamic) { resolution = cast AssetQuality.Low; }

        if (resolution == AssetQuality.Medium)
        {
            return AssetQuality.Medium;
        } else
        if (resolution == AssetQuality.High)
        {
            return AssetQuality.High;
        }

        return AssetQuality.Low;
        #else
        return AssetQuality.Medium;
        #end

        return AssetQuality.Medium;
    }

    #if (html5 && !webOS)
    private static function get():AssetQuality
    {

        var canvas:CanvasElement = cast js.Browser.document.createElement("canvas");
        var gl:RenderingContext = canvas.getContext("webgl");
        if (gl == null)
        {
            gl = canvas.getContext('experimental-webgl');
        }
        if (gl == null)
        {
            return null;
        }
        var debugRenderInfo:Dynamic = gl.getExtension('WEBGL_debug_renderer_info');
        var UNMASKED_RENDERER_WEBGL:Int = 37446; /*
            DK: No such parameter supported yet, solution:
            <html><body>
                <canvas id="canva"></canvas>
                <script>
                    var gl = document.getElementById('canva').getContext('webgl');
                    var debugInfo = gl.getExtension('WEBGL_debug_renderer_info');
                    var vendor = gl.getParameter(debugInfo.UNMASKED_VENDOR_WEBGL);
                    var renderer = gl.getParameter(debugInfo.UNMASKED_RENDERER_WEBGL);
                    console.log(debugInfo.UNMASKED_VENDOR_WEBGL, vendor);
                    console.log(debugInfo.UNMASKED_RENDERER_WEBGL, renderer);
                    </script>
            </body></html> */

        var glStats:Dynamic = {
            gpu: debugRenderInfo && gl.getParameter(UNMASKED_RENDERER_WEBGL),
            maxTextureSize: gl.getParameter(3379), // gl.MAX_TEXTURE_SIZE),
            maxFramebufferSize: gl.getParameter(34024), // gl.MAX_RENDERBUFFER_SIZE),
            maxFragmentUniformVectors: gl.getParameter(36349), // gl.MAX_FRAGMENT_UNIFORM_VECTORS),
            maxTextureImageUnits: gl.getParameter(34930), // gl.MAX_TEXTURE_IMAGE_UNITS),
            maxVaryingVectors: gl.getParameter(36348), // gl.MAX_VARYING_VECTORS),
            maxVertexAttribs: gl.getParameter(34921), // gl.MAX_VERTEX_ATTRIBS),
            maxVertexTextureImageUnits: gl.getParameter(35660), // gl.MAX_VERTEX_TEXTURE_IMAGE_UNITS),
            maxVertexUniformVectors: gl.getParameter(36347), // gl.MAX_VERTEX_UNIFORM_VECTORS)
        };

        var mobileDetect:MobileDetect = new MobileDetect(js.Browser.navigator.userAgent);
        var maxDimension = Math.max(js.Browser.window.screen.width, js.Browser.window.screen.height);
        var dpr = js.Browser.window.devicePixelRatio;
        var isMobile = mobileDetect.mobile() != null;
        var isTablet = mobileDetect.tablet() != null;

        if(!glStats) return AssetQuality.Low;

        var scalePrefix = AssetQuality.High;

        if(!isMobile && maxDimension * dpr > 2560)
        {
            scalePrefix =  AssetQuality.High;
        } else
        if(isMobile && maxDimension * dpr <= 1280)
        {
            scalePrefix =  AssetQuality.Low;
        } else
        {
            scalePrefix =  AssetQuality.Medium;
        }

        if(mobileDetect.is('iPad') && dpr == 1)
        {
            scalePrefix =  AssetQuality.Low;
        }

        if(['Apple A8 GPU', 'Apple A8X GPU'].indexOf(glStats.gpu) != -1) // iPhone 6 & 6+, iPad mini 4 & Air 2
        {
            scalePrefix = AssetQuality.Low;
        }

        return scalePrefix;
    }
    #end
}