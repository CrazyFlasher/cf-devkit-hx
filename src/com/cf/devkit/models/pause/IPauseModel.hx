package com.cf.devkit.models.pause;

import com.domwires.core.mvc.model.IModel;
import com.cf.devkit.models.pause.PauseModel;

interface IPauseModel extends IPauseModelImmutable extends IModel
{
    function setState(value:EnumValue):IPauseModel;
}
