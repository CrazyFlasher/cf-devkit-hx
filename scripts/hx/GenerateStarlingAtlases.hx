import hxp.Haxelib;
import hxp.HXML;
import hxp.Script;

/**
* Generates texture atlasses in XML Starling / Sparrow format using ta-gen tool.
* Adobe AIR runtime is required.
* Usage: haxelib run hxp GenerateStarlingAtlases.hx -Din=<path to input folder> -Dout=<path to output dir>
*
* -Din - path to input directory
* -Dout - path to output directory
* -Djpg - if atlas should be in JPEG format (optional; default is png with alpha channel)
* -DjpgQuality - specify output JPEG atlas quality (optional; default is 90)
* -Dmaxdim - maximum dimensions of altas. If higher, then extra atlases will be created (optional; default is 2048)
* -Dscale - scale of atlas (optional; default is 1.0)
* -Dpngprefix - prefix that will be added to atlas xml file; path to image (optional)
**/
class GenerateStarlingAtlases extends Script
{
    private var isJPG:Bool;
    private var jpgQuality:String = "90";
    private var maxDim:String = "2048";

    public function new()
    {
        super();

        Sys.setCwd(workingDirectory);

        if (!defines.exists("in"))
        {
            trace("Path to input directory is not specified!");
            trace("Define it as flag -Din=path_to_dir...");
            Sys.exit(1);
        }
        if (!defines.exists("out"))
        {
            trace("Path to out directory is not specified!");
            trace("Define it as flag -Dout=path_to_dir...");
            Sys.exit(1);
        }

        isJPG = defines.exists("jpg");
        if (isJPG && defines.exists("jpgQuality"))
        {
            jpgQuality = defines.get("jpgQuality");
        }
        if (defines.exists("maxdim"))
        {
            maxDim = defines.get("maxdim");
        }

        var lib:Haxelib = new Haxelib("ta-gen");
        var path:String = Haxelib.getPath(lib) + "/release/ta-gen_v1.8_air32.0_exe/";

        var scale:String = cast defines.get("scale");
        var pngprefix:String = cast defines.get("pngprefix");
        var input:String = workingDirectory + defines.get("in");
        var output:String = workingDirectory + defines.get("out");

        path += "ta-gen.exe -in " + input + " -out " + output + " -multipart -maxdim " + maxDim;

        if (isJPG)
        {
            path += " -jpg -jpgQuality " + jpgQuality;
        }
        if (scale != null)
        {
            path += " -scale " + scale;
        }
        if (pngprefix != null)
        {
            path += " -pngprefix " + pngprefix;
        }

        trace("Running: " + path);

        Sys.command(path);
    }
}