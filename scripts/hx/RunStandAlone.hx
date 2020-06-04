import hxp.HXML;
import hxp.Script;

/**
* Runs local web server and opens SA web version of the game in default browser.
* Usage: haxelib run hxp RunStandAlone.hx
**/
class RunStandAlone extends Script
{
    public function new()
    {
        super();

        Sys.setCwd(workingDirectory);

        new HXML({
            cmds: ["haxelib run openfl run project.xml html5 -DstandAlone"]
        }).build();
    }
}