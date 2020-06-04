package com.cf.devkit.models.pause;

import com.domwires.core.mvc.model.IModelImmutable;

interface IPauseModelImmutable extends IModelImmutable
{
    var state(get, never):EnumValue;
}
