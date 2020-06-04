package com.cf.devkit.app;

#if dev
import Debug;
#end

#if require3D
import away3d.debug.AwayStats;
import away3d.containers.View3D;
import away3d.core.managers.Stage3DProxy;
import away3d.events.Stage3DEvent;
import away3d.core.managers.Stage3DManager;
#end

#if useStarling
import openfl.display3D.Context3DRenderMode;
import openfl.geom.Rectangle;
import starling.core.Starling;
import starling.events.ResizeEvent;
import starling.display.DisplayObjectContainer;
import starling.display.DisplayObject;
#else
import openfl.display.DisplayObjectContainer;
import openfl.display.DisplayObject;
#end

import openfl.text.TextFormat;
import openfl.Lib;
import openfl.display.FPS;

import com.cf.devkit.trace.Trace;
import haxe.io.Error;
import com.domwires.core.factory.AppFactory;
import com.domwires.core.factory.IAppFactory;

/**
* Application entry point
**/
class AbstractApp extends openfl.display.Sprite
{
	#if useStarling
	private static var _starling:Starling;
	private var viewPort:Rectangle = new Rectangle();
	#end

	private static var stats:DisplayObject;

	private var contextFactory:IAppFactory = new AppFactory();

	private var _root:DisplayObjectContainer;

	public function new()
	{
		#if (html5 && debug)
		js.Lib.debug();

		var captureStack = (cast js.lib.Error).captureStackTrace;
		(cast js.lib.Error).captureStackTrace = function(a, b):Void
		{
			captureStack(a, b);

			#if standAlone
			js.Browser.alert(a.stack);
			#else
			var lines:Array<String> = a.stack.split("\n");
			var result:String = "";
			for (i in 1...3)
			{
				result += lines[i] + "\n";
			}
			untyped gAPI.casinoUI.showAlert({title: lines[0], message: result});
			#end
		}
		#end

		Trace.init();

		super();

		#if require3D
		initProxies();
		#elseif useStarling
		initStarling();
		#else
        _root = new openfl.display.Sprite();
        addChild(_root);
        initialize();
        #end
	}

	#if require3D
	private var stage3DManager:Stage3DManager;
	private var stage3DProxy:Stage3DProxy;
	private var view3D:View3D;

	private function initProxies():Void
	{
		// Define a new Stage3DManager for the Stage3D objects
		stage3DManager = Stage3DManager.getInstance(stage);

		// Create a new Stage3D proxy to contain the separate views
		stage3DProxy = stage3DManager.getFreeStage3DProxy(false, "enhanced");
		stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContextCreated);
	}

	private function onContextCreated(event:Stage3DEvent):Void
	{
		initAway3D();

		#if useStarling
		initStarling();
		#else
        _root = new openfl.display.Sprite();
        addChild(_root);
        initialize();
        #end
	}

	private function initAway3D():Void
	{
		// Create the first Away3D view which holds the cube objects.
		view3D = new View3D();
		view3D.stage3DProxy = stage3DProxy;
		view3D.shareContext = true;

		addChild(view3D);

		var stats = new AwayStats(view3D);
		stats.y = 100;

		addChild(stats);
	}
	#end

	#if useStarling

	private function initStarling():Void
	{
		#if require3D
		viewPort.width = stage.stageWidth;
		viewPort.height = stage.stageHeight;

		view3D.width = viewPort.width;
		view3D.height = viewPort.height;
		view3D.x = viewPort.x;
		view3D.y = viewPort.y;

		_starling = new Starling(AppDisplay, stage, stage3DProxy.viewPort, stage3DProxy.stage3D, Context3DRenderMode.AUTO);

		stage.addEventListener(openfl.events.Event.ENTER_FRAME, e ->
		{
			stage3DProxy.context3D.clear(0, 0, 0, 1, 1, 127);
			stage3DProxy.bufferClear = true;

			_starling.nextFrame();
			view3D.render();

			stage3DProxy.context3D.present();
		});
		#else
        _starling = new Starling(AppDisplay, stage, null, null, Context3DRenderMode.AUTO);
        #end

//		_starling.simulateMultitouch = false;
//		_starling.enableErrorChecking = false;
//		_starling.skipUnchangedFrames = true;
//		_starling.supportBrowserZoom = false;

		_starling.addEventListener(starling.events.Event.ROOT_CREATED, rootCreated);
		_starling.start();
	}

	private function rootCreated(e:starling.events.Event):Void
	{
		_root = cast _starling.root;

		#if require3D
		stage.addEventListener(openfl.events.Event.RESIZE, onNativeStageResize);
		onNativeStageResize();
		#else
		_starling.stage.addEventListener(ResizeEvent.RESIZE, onStageResize);
		onStageResize(null, stage.stageWidth, stage.stageHeight);
		#end

		initialize();
	}

	#if require3D

	private function onNativeStageResize(e:openfl.events.Event = null):Void
	{
		view3D.width = stage.stageWidth;
		view3D.height = stage.stageHeight;

		_starling.viewPort = viewPort;
	}
	#else
	private function onStageResize(e:ResizeEvent = null, w:Int = 0, h:Int = 0):Void
	{
		var width:Int = e == null ? w : e.width;
		var height:Int = e == null ? h : e.height;

		_starling.stage.stageWidth = width;
		_starling.stage.stageHeight = height;

		viewPort.x = 0;
		viewPort.y = 0;
		viewPort.width = width;
		viewPort.height = height;

		_starling.viewPort = viewPort;
	}
	#end

	#end

	private function initialize():Void
	{
		createContext();

		#if (debug || showFPSAlways)
        showStats(true);
        #end
	}

	public static function showStats(value:Bool):Void
	{
		if (value)
		{
			if (stats == null)
			{
				#if useStarling
				var stats = new starling.core.StatsDisplay();
				stats.scale = 2/* * Lib.application.window.scale*/;
				stats.y = 50/* * stats.scale*/;
				_starling.addEventListener(starling.events.Event.RENDER, () -> stats.drawCount = _starling.painter.drawCount);
				_starling.stage.addChild(stats);

				AbstractApp.stats = stats;
				#else
                var color:Int = 0xffcc00;
                stats = new FPS(10 * Lib.application.window.scale, 40 * Lib.application.window.scale, color);
                var tf:TextFormat = new TextFormat();
                tf.size = 30;
                stats.width = 200;
                stats.height = 200;
                stats.defaultTextFormat = tf;
                stage.addChild(stats);
                #end
			}
		} else
		{
			stats.parent.removeChild(stats #if useStarling, true #end);
			stats = null;
		}
	}

	private function createContext():Void
	{
		contextFactory.mapToValue(IAppFactory, new AppFactory());
		contextFactory.mapToValue(getRootContainerImplementation(), getDisplay(), "root");
		contextFactory.mapToValue(openfl.display.DisplayObjectContainer, this, "window");

		contextFactory.getInstance(getContextImplementation());
	}

	/**
    * Override and return game specific display root
    **/
	private function getDisplay():DisplayObjectContainer
	{
		return _root;
	}

	/**
    * Override and return game specific context implementation
    **/
	private function getContextImplementation():Class<Dynamic>
	{
		throw Error.Custom("Override!");
	}

	/**
    * Override and return root display container implementation
    **/
	private function getRootContainerImplementation():Class<Dynamic>
	{
		return #if !useStarling openfl.display.DisplayObjectContainer #else starling.display.DisplayObjectContainer #end;
	}
}

#if useStarling
class AppDisplay extends starling.display.Sprite
{
	public function new()
	{
		super();
	}
}
#end
