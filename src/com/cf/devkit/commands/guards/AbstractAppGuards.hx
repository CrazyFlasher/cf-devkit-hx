package com.cf.devkit.commands.guards;

import com.domwires.core.mvc.command.AbstractGuards;

class AbstractAppGuards extends AbstractGuards
{
    override private function get_allows():Bool
    {
        return super.get_allows();
    }
}
