package com.cf.devkit.bundle.impl.starling.flump;

#if useStarling
import com.cf.devkit.services.AbstractService;
import starling.display.DisplayObjectContainer;
import com.domwires.core.factory.IAppFactory;
import flump.display.Library;
import flump.display.Movie;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.Texture;

class FlumpMovieClipBundleService extends AbstractService implements IMovieClipBundleService
{
    @Inject
    private var lib:Library;

    @Inject("viewFactory")
    private var factory:IAppFactory;

    @Inject("bundleId")
    private var bundleId:String;

    private var movieMap:Map<String, IMovieClip> = new Map<String, IMovieClip>();
    private var displayObjectMap:Map<String, IDisplayObject> = new Map<String, IDisplayObject>();

    @PostConstruct
    private function init():Void
    {
		factory.mapClassNameToValue("Float", lib.baseScale, "baseScale");

        factory.mapToValue(IAppFactory, factory);
    }

    public function getMovieClip(id:String, forceReturnNew:Bool = false):IMovieClip
    {
        if (!forceReturnNew && movieMap.exists(id))
        {
            var object:IMovieClip = movieMap.get(id);
            if (!object.isDisposed)
            {
                return movieMap.get(id);
            }
        }

        var mc:Movie = lib.createMovie(id);

        factory.mapToValue(String, bundleId, "bundleId");
        factory.mapToValue(Movie, mc, "movie");
        factory.mapToValue(DisplayObjectContainer, mc, "canvas");
        factory.mapToValue(DisplayObject, mc, "assets");

        var movie:IMovieClip = factory.getInstance(IMovieClip);

        factory.unmap(Movie, "movie");
        factory.unmap(DisplayObjectContainer, "canvas");
        factory.unmap(DisplayObject, "assets");

        movieMap.set(id, movie);

        return movie;
    }

    public function getDisplayObject(id:String, forceReturnNew:Bool = false):IDisplayObject
    {
        try
        {
            return getMovieClip(id, forceReturnNew);
        } catch (e:Dynamic)
        {

        }

        if (!forceReturnNew && displayObjectMap.exists(id))
        {
            var object:IDisplayObject = displayObjectMap.get(id);
            if (!object.isDisposed)
            {
                return displayObjectMap.get(id);
            }
        }

        var image:Image = lib.createImage(id);

        factory.mapClassNameToValue("Float", lib.baseScale, "baseScale");
        factory.mapToValue(DisplayObject, image, "assets");

        var displayObject:IDisplayObject = factory.getInstance(IDisplayObject);

        factory.unmap(DisplayObject, "assets");

        displayObjectMap.set(id, displayObject);

        return displayObject;
    }

    public function getTexture(id:String):Texture
    {
        try
        {
            return lib.getImageTexture(id);
        } catch (e:Dynamic)
        {
        }

        return null;
    }

}
#end