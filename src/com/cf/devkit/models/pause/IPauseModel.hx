package com.cf.devkit.models.pause;

import com.domwires.core.mvc.model.IModel;

interface IPauseModel extends IPauseModelImmutable extends IModel
{
    function setState(value:EnumValue):IPauseModel;
}
