package ;
import hxp.Path;
import sys.FileSystem;
import hxp.Script;
import sys.io.File;

/**
* Export SWF from Adobe Animate (AKA Flash) fla files using JSFL script
* Usage: haxelib run hxp ExportFlashSWF.hx -Ddir=<path to input folder>
*
* -Ddir - Path to directory with fla files
*
* NOTE: FLASH_IDE should be added to env. variables. Path to Animate install folder.
* NOTE: Animate IDE should be opened.
**/
class ExportFlashSWF extends Script
{
    private var completeFilePath:String;
    private var temp:String;

    private function isMac():Bool
    {
        return Sys.systemName().toLowerCase().indexOf("mac") != -1;
    }

    public function new()
    {
        var exeName:String = isMac() ? "Adobe Animate 2020.app/Contents/MacOS/Adobe Animate 2020" : "Animate.exe";
        // /Applications/Adobe Animate 2020/Adobe Animate 2020.app/Contents/MacOS/Adobe Animate 2020

        trace(exeName);

        if (isMac()) // TODO MAC is not properly converting FLA to SWF
        {
            return;
        }

        if (!isMac() && !Sys.environment().exists("FLASH_IDE"))
        {
            trace(isMac() ? "FLASH_IDE is not defined in environment variabled! Should contain full path to Adobe Animate application.": "FLASH_IDE is not defined in environment variabled! Should contain path to Animate install folder.");
            Sys.exit(1);
        }

        var pathToIDE:String = isMac() ?
        'open -a "' + exeName + '" --args'
        : '"' + Path.normalize(Sys.environment().get("FLASH_IDE")) + "/" + exeName + '"';

        super();

        if (!defines.exists("dir"))
        {
            trace("Path to directory with fla files is notе specified!");
            trace("Define it as flag -Ddir=path_to_dir...");
            Sys.exit(1);
        }

        completeFilePath = workingDirectory + defines.get("dir") + "/tempfile";

        var origin:String = "../jsfl/export-swf.jsfl";
        temp = "../jsfl/export-swf_temp.jsfl";

        if (FileSystem.exists(temp))
        {
            FileSystem.deleteFile(temp);
        }
        if (FileSystem.exists(completeFilePath))
        {
            FileSystem.deleteFile(completeFilePath);
        }

        trace(workingDirectory + defines.get("dir"));

        var content:String = File.getContent(origin);
        content = content.split("$taskId").join("export").split("$dirPath").join(workingDirectory + defines.get("dir"));

        content = content.split("\\").join("/");

        File.saveContent(temp, content);

        trace(pathToIDE + " " + temp + " -AlwaysRunJSFL");
        Sys.command(pathToIDE + " " + temp + " -AlwaysRunJSFL");

        haxe.Timer.delay(checkComplete, 500);
    }

    private function checkComplete():Void
    {
        if (FileSystem.exists(completeFilePath))
        {
            trace("Complete!");
            /*FileSystem.deleteFile(completeFilePath);

            if (FileSystem.exists(temp))
            {
                FileSystem.deleteFile(temp);
            }*/

            Sys.exit(0);
        } else
        {
            trace("Waiting...");
            haxe.Timer.delay(checkComplete, 500);
        }
    }
}