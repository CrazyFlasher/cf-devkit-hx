import hxp.HXML;
import hxp.Script;

/**
* Builds SA web project with release settings.
* Usage: haxelib run hxp BuildStandAlone.hx
**/
class BuildStandAlone extends Script
{
    public function new()
    {
        super();

        Sys.setCwd(workingDirectory);

        new HXML({
            cmds: ["haxelib run openfl build project.xml html5 -final -verbose -dce full -minify -DstandAlone"]
        }).build();
    }
}