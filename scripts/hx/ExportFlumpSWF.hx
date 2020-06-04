import hxp.Haxelib;
import sys.io.File;
import hxp.Script;

/**
* Export assets from Adobe Animate (AKA Flash) using Flump Exported
* More details about Flump:
* https://github.com/CrazyFlasher/flump
* Adobe AIR runtime is required:
* https://get.adobe.com/air/
* Usage: haxelib run hxp ExportFlumpSWF.hx -Ddir=<path to input folder>
*
* -Ddir - Path to directory with fla, swf and flump project file
**/
class ExportFlumpSWF extends Script
{
    private function isMac():Bool
    {
        return Sys.systemName().toLowerCase().indexOf("mac") != -1;
    }

    public function new()
    {
        super();

        Sys.setCwd(workingDirectory);

        if (!defines.exists("dir"))
        {
            trace("Path to directory with fla, swf and flump file is not specified!");
            trace("Define it as flag -Ddir=path_to_dir...");
            Sys.exit(1);
        }

        var jpgQuality:String = "70";
        if (defines.exists("jpgQuality"))
        {
            jpgQuality = defines.get("jpgQuality");
        }

        var lib:Haxelib = new Haxelib("flump");
        var winPath:String = Haxelib.getPath(lib) + "/bin/exporter/";
        var macPath:String = Haxelib.getPath(lib) + "/bin/exporter-mac/";
        var args:String = "--disablePOT 'true' --export " + workingDirectory + defines.get("dir") + "/f.flump --unmodified 'false' --jpgQuality " + jpgQuality;

        if (isMac())
        {
            trace("Mac");
            Sys.command("open -W -a " + macPath + "Contents/MacOS/Flump --args " + args);
        } else
        {
            trace("Win");
            Sys.command(winPath + "Flump.exe " + args);
        }

        var log:String = File.getContent((isMac() ? macPath + "Contents/Resources/" : winPath) + "exporter.log");
        trace(log);
    }
}