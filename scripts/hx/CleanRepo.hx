import hxp.HXML;
import hxp.Script;

/**
* Deletes local haxelib repository with all dependencies and points to global one.
* Usage: haxelib run hxp CleanRepo.hx
**/
class CleanRepo extends Script
{
    public function new()
    {
        super();

        Sys.setCwd(workingDirectory);

        new HXML({
            cmds: ["haxelib deleterepo"]
        }).build();
    }
}