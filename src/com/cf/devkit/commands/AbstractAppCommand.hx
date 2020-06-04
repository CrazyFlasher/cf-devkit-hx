package com.cf.devkit.commands;

import com.domwires.core.mvc.command.AbstractCommand;

class AbstractAppCommand extends AbstractCommand
{
    #if debug
    private var logExecution:Bool = true;
    #end

    override public function execute():Void
    {
        super.execute();

        #if debug
        if (logExecution) trace("[execute]: " + Type.getClassName(Type.getClass(this)));
        #end
    }
}
