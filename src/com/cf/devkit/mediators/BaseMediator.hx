package com.cf.devkit.mediators;

import com.cf.devkit.services.resources.IResourceServiceImmutable;
import com.domwires.core.mvc.mediator.AbstractMediator;
import com.domwires.core.mvc.mediator.IMediator;
import com.domwires.core.factory.IAppFactory;

#if !useStarling
import openfl.display.DisplayObjectContainer;
#else
import starling.display.DisplayObjectContainer;
#end

class BaseMediator extends AbstractMediator implements IMediator
{
    @Inject
    private var res:IResourceServiceImmutable;

    @Inject("viewFactory")
    private var viewFactory:IAppFactory;

    @Inject("gameContainer")
    private var gameContainer:DisplayObjectContainer;

    private var container:DisplayObjectContainer;

    @PostConstruct
    private function init():Void
    {
        container = getContainer();

        addListeners();
    }

    public function show(value:Bool):Void
    {
        container.visible = value;
    }

    public function setTouchable(value:Bool):Void
    {
        #if useStarling
        container.touchable = value;
        #else
        container.mouseEnabled = container.mouseChildren = value;
        #end
    }

    private function getContainer():DisplayObjectContainer
    {
        return null;
    }

    private function addListeners():Void
    {
    }
}
