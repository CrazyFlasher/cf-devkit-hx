import utils.FileUtils;
import hxp.Script;

/**
* Deletes out and export directories.
* Usage: haxelib run hxp CleanOutput.hx
**/
class CleanOutput extends Script
{
    public function new()
    {
        super();

        var out:String = workingDirectory + "out";
        var export:String = workingDirectory + "export";

        FileUtils.deleteWithFiles(out);
        FileUtils.deleteWithFiles(export);
    }
}