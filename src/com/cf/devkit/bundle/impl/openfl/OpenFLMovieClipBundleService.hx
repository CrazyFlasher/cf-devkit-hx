package com.cf.devkit.bundle.impl.openfl;

#if !useStarling
import openfl.display.DisplayObject;
import openfl.display.MovieClip;
import com.domwires.core.factory.AppFactory;
import com.domwires.core.factory.IAppFactory;
import openfl.utils.AssetLibrary;
import com.cf.devkit.services.AbstractService;

class OpenFLMovieClipBundleService extends AbstractService implements IMovieClipBundleService
{
    @Inject
    private var lib:AssetLibrary;

    @Inject("viewFactory")
    private var factory:IAppFactory;

    private var movieMap:Map<String, IMovieClip> = new Map<String, IMovieClip>();

    @PostConstruct
    private function init():Void
    {
        factory.mapToValue(IAppFactory, factory);
        factory.mapToType(IMovieClip, OpenFLMovieClip);
        factory.mapToType(IDisplayObject, OpenFLDisplayObject);
        factory.mapToType(ITextField, OpenFLTextField);
        factory.mapToType(IImage, OpenFLImage);
        factory.mapToType(ISpineClip, OpenFLSpineClip);
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

        var mc:MovieClip = lib.getMovieClip(id);

        factory.mapToValue(MovieClip, mc, "movie");
        factory.mapToValue(DisplayObject, mc, "assets");

        var movie:IMovieClip = factory.getInstance(IMovieClip);

        factory.unmap(MovieClip, "movie");
        factory.unmap(DisplayObject, "assets");

        movieMap.set(id, movie);

        return movie;
    }

    public function getDisplayObject(id:String, forceReturnNew:Bool = false):IDisplayObject
    {
        return getMovieClip(id, forceReturnNew);
    }
}
#end