import hxp.HXML;
import hxp.Script;
import sys.FileSystem;

/**
* Creates and (or points if created) to local haxelib repo used for project dependencies.
* Usage: haxelib run hxp CreateRepo.hx
**/
class CreateRepo extends Script
{
    public function new()
    {
        super();

        Sys.setCwd(workingDirectory);

        new HXML({
            cmds: ["haxelib newrepo"]
        }).build();
    }
}