package com.cf.devkit.context;

import com.cf.devkit.services.resources.IResourceServiceImmutable;
import com.cf.devkit.services.stats.IStatsServiceImmutable;
import com.cf.devkit.models.pause.IPauseModelImmutable;
import com.cf.devkit.services.stats.IStatsService;
import com.cf.devkit.models.pause.IPauseModel;
import com.cf.devkit.services.resources.IResourceService;
import com.cf.devkit.config.IConfig;
import com.cf.devkit.bundle.ITextField;
import com.cf.devkit.bundle.IMovieClip;
import com.cf.devkit.bundle.IContainer;
import com.cf.devkit.tween.ITween;
import com.cf.devkit.mediators.audio.IAudioMediator;
import com.cf.devkit.bundle.ISheetClip;
import com.domwires.core.mvc.command.ICommandMapper;
import openfl.geom.Rectangle;
import com.cf.devkit.screen.ScreenResizer;
import com.domwires.core.factory.AppFactory;
import com.cf.devkit.bundle.IImage;
import com.cf.devkit.bundle.IDragonBonesClip;
import com.cf.devkit.bundle.ISpineClip;
import com.cf.devkit.bundle.IDisplayObject;
import com.cf.devkit.bundle.IParticleClip;
import com.cf.devkit.bundle.IStage;
import com.cf.devkit.display.Stage;
import haxe.macro.Compiler;
import com.domwires.core.factory.IAppFactory;
import com.domwires.core.mvc.context.AbstractContext;

#if !useStarling
import openfl.display.DisplayObjectContainer;
#else
import starling.display.DisplayObjectContainer;
#end

class BaseContext extends AbstractContext implements IBaseContext
{
    private var screenResizer:ScreenResizer;
    private var safeArea:Rectangle = new Rectangle();

    private var appConfig:IConfig;

    @Inject("window")
    private var window:openfl.display.DisplayObjectContainer;

    @Inject("root")
    private var root:DisplayObjectContainer;

    private var gameContainer:DisplayObjectContainer;

    private var gameWidth:Int;
    private var gameHeight:Int;

    private var modelFactory:IAppFactory;
    private var mediatorFactory:IAppFactory;
    private var viewFactory:IAppFactory;

	private var pauseModel:IPauseModel;

    private var resourceService:IResourceService;
    private var statsService:IStatsService;

    private var audioMediator:IAudioMediator;

    override private function init():Void
    {
        super.init();

        createGameContainer();

        gameWidth = Std.parseInt(Compiler.getDefine("windowWidth"));
        gameHeight = Std.parseInt(Compiler.getDefine("windowHeight"));

        createScreenResizer();

        createModelFactory();
        createMediatorFactory();
        createViewFactory();

        mapTypes();

        createConfig();
        createModels();
        mapValues();

        createAudioMediator();
    }

    private function createAudioMediator():Void
    {
        audioMediator = mediatorFactory.getInstance(IAudioMediator);
        addMediator(audioMediator);

        mediatorFactory.mapToValue(IAudioMediator, audioMediator);
        viewFactory.mapToValue(IAudioMediator, audioMediator);
    }

    private function createGameContainer():Void
    {
        gameContainer = root;
    }

    private function mapValues():Void
    {
        mediatorFactory.mapToValue(openfl.display.DisplayObjectContainer, window, "window");

        mediatorFactory.mapClassNameToValue("Int", gameWidth, "gameWidth");
        mediatorFactory.mapClassNameToValue("Int", gameHeight, "gameHeight");

		mediatorFactory.mapToValue(IPauseModelImmutable, pauseModel);
        mediatorFactory.mapToValue(IStatsServiceImmutable, statsService);
        mediatorFactory.mapToValue(IResourceServiceImmutable, resourceService);

        viewFactory.mapToValue(openfl.display.DisplayObjectContainer, window, "window");

        viewFactory.mapClassNameToValue("Int", gameWidth, "gameWidth");
        viewFactory.mapClassNameToValue("Int", gameHeight, "gameHeight");

		viewFactory.mapToValue(IPauseModelImmutable, pauseModel);
        viewFactory.mapToValue(IStatsServiceImmutable, statsService);
        viewFactory.mapToValue(IResourceServiceImmutable, resourceService);

        //internal context factory. Also Used for command mapper
        factory.mapToValue(ICommandMapper, this);
		factory.mapToValue(IPauseModel, pauseModel);
        factory.mapToValue(IResourceService, resourceService);
        factory.mapToValue(IAppFactory, modelFactory, "modelFactory");
    }

    private function createConfig():Void
    {
        appConfig = modelFactory.getInstance(IConfig);

        modelFactory.mapToValue(IConfig, appConfig);
        mediatorFactory.mapToValue(IConfig, appConfig);
        viewFactory.mapToValue(IConfig, appConfig);
        factory.mapToValue(IConfig, appConfig);
    }

    private function createModels():Void
    {
		pauseModel = modelFactory.getInstance(IPauseModel);
        resourceService = modelFactory.getInstance(IResourceService);
        statsService = modelFactory.getInstance(IStatsService);

		addModel(pauseModel);
        addModel(resourceService);
        addModel(statsService);
    }

    private function createScreenResizer():Void
    {
        if (screenResizer != null)
        {
            screenResizer.dispose();
        }

        screenResizer = new ScreenResizer(gameContainer, safeArea, gameWidth, gameHeight);
    }

    private function mapTypes():Void
    {
        #if useStarling
        viewFactory.mapToValue(starling.display.Stage, Stage.get(), "stage");
        viewFactory.mapToType(IStage, com.cf.devkit.bundle.impl.starling.StarlingStage);
        viewFactory.mapToType(IParticleClip, com.cf.devkit.bundle.impl.starling.StarlingParticleClip);
        viewFactory.mapToType(IDisplayObject, com.cf.devkit.bundle.impl.starling.StarlingDisplayObject);
        viewFactory.mapToType(IContainer, com.cf.devkit.bundle.impl.starling.StarlingContainer);
        viewFactory.mapToType(IMovieClip, com.cf.devkit.bundle.impl.starling.flump.FlumpMovieClip);
        viewFactory.mapToType(ITextField, com.cf.devkit.bundle.impl.starling.flump.FlumpTextField);
        viewFactory.mapToType(ISpineClip, com.cf.devkit.bundle.impl.starling.StarlingSpineClip);
        viewFactory.mapToType(IDragonBonesClip, com.cf.devkit.bundle.impl.starling.StarlingDragonBonesClip);
        viewFactory.mapToType(IImage, com.cf.devkit.bundle.impl.starling.StarlingImage);
        viewFactory.mapToType(ISheetClip, com.cf.devkit.bundle.impl.starling.StarlingSheetClip);
        viewFactory.mapToType(ITween, com.cf.devkit.tween.impl.StarlingTween);
        #else
        zygame.utils.SpineManager.init(Stage.get());
        viewFactory.mapToValue(openfl.display.Stage, Stage.get(), "stage");
        viewFactory.mapToType(IStage, com.cf.devkit.bundle.impl.openfl.OpenFLStage);
        viewFactory.mapToType(IParticleClip, com.cf.devkit.bundle.impl.openfl.OpenFLParticleClip);
        viewFactory.mapToType(IDisplayObject, com.cf.devkit.bundle.impl.openfl.OpenFLDisplayObject);
        viewFactory.mapToType(ISpineClip, com.cf.devkit.bundle.impl.openfl.OpenFLSpineClip);
        viewFactory.mapToType(IDragonBonesClip, com.cf.devkit.bundle.impl.openfl.OpenFLDragonBonesClip);
        viewFactory.mapToType(IImage, com.cf.devkit.bundle.impl.openfl.OpenFLImage);
        viewFactory.mapToType(ITween, com.cf.devkit.tween.impl.ActuateTween);
        #end
    }

    private function createModelFactory():Void
    {
        modelFactory = new AppFactory();
        modelFactory.mapToValue(IAppFactory, modelFactory, "modelFactory");
    }

    private function createMediatorFactory():Void
    {
        mediatorFactory = new AppFactory();
        mediatorFactory.mapToValue(DisplayObjectContainer, gameContainer, "gameContainer");
        mediatorFactory.mapToValue(Rectangle, safeArea, "safeArea");
    }

    private function createViewFactory():Void
    {
        viewFactory = new AppFactory();
        viewFactory.mapToValue(DisplayObjectContainer, gameContainer, "gameContainer");
        viewFactory.mapToValue(Rectangle, safeArea, "safeArea");

        modelFactory.mapToValue(IAppFactory, viewFactory, "viewFactory");
        viewFactory.mapToValue(IAppFactory, viewFactory, "viewFactory");
        mediatorFactory.mapToValue(IAppFactory, viewFactory, "viewFactory");
    }
}
