import hxp.Script;

/**
* Deletes output dirs, build project (web and SA)
* Usage: haxelib run hxp Build.hx
**/
class Build extends Script
{
    public function new()
    {
        super();

        Sys.setCwd(workingDirectory);

        new CleanOutput();
        new BuildWeb();
        new BuildStandAlone();
    }
}