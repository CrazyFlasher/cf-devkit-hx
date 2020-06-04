import hxp.HXML;
import hxp.Script;

/**
* Builds web project with release settings.
* Usage: haxelib run hxp BuildWeb.hx
*
* -Ddev - dev build with forcer (optional)
* -Ddebug - debug build with extended logs, source maps, etc.
**/
class BuildWeb extends Script
{
    public function new()
    {
        super();

        Sys.setCwd(workingDirectory);

        var isDebug:Bool = defines.exists("debug");
        var isDev:Bool = defines.exists("dev");

        var type:String = isDebug ? "-debug" : "-final";

        var cmd:String = 'haxelib run openfl build project.xml html5 ${type} -verbose -dce full';

        if (isDev)
        {
            cmd += " -Ddev";
        }
        if (!isDebug)
        {
            cmd += " -minify";
        }

        trace("BuildWeb: command: " + cmd);

        new HXML({
            cmds: [cmd]
        }).build();
    }
}