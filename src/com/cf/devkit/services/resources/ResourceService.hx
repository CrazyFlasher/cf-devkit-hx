package com.cf.devkit.services.resources;

import com.cf.devkit.enums.AssetQuality;
import com.cf.devkit.config.ICasinoConfig;
import com.cf.devkit.bundle.IDisplayObject;
import starling.core.Starling;
import com.cf.devkit.bundle.ISheetClip;
import com.cf.devkit.trace.Trace;
import dragonBones.objects.DragonBonesData;
import haxe.Json;
import spine.support.files.FileHandle;
import com.cf.devkit.bundle.IMovieClip;
import com.domwires.core.factory.IAppFactory;
import com.cf.devkit.bundle.IMovieClipBundleService;
import openfl.utils.ByteArray;
import haxe.io.Error;
import lime.utils.AssetManifest;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.text.Font;
import openfl.utils.AssetType;

#if !useStarling
import spritesheet.importers.TexturePackerImporter;
import spritesheet.Spritesheet;
import com.cf.devkit.bitmapFont.BitmapFont;
import com.cf.devkit.assets.SpineAssets;
import openfl.display.Tileset;
import com.cf.devkit.bundle.impl.openfl.OpenFLMovieClipBundleService;
import openfl.utils.Function;
import openfl.utils.AssetLibrary;
#else
import com.cf.devkit.bundle.impl.starling.flump.FlumpMovieClipBundleService;
import flump.display.LibraryLoader;
#end

@:keep
class ResourceService extends AbstractService implements IResourceService
{
    @Inject
    private var config:ICasinoConfig;

    @Inject("modelFactory")
    private var modelFactory:IAppFactory;

    private var movieClipBundleMap:Map<String, IMovieClipBundleService> = new Map<String, IMovieClipBundleService>();

    public var progress(get, never):Float;
    public var contentScaleFactor(get, never):Float;

    private var manifest:AssetManifest;
    private var assetListToPreload:Array<AssetVo> = [];

    private var swfLibTotalSizeIncluded:Bool;
    private var assetsSizeLoaded:Int;
    private var assetsSizeTotal:Int;

    private var assetsPreloadProgress:Float;

    public function loadFromManifest(path:String = null):IResourceService
    {
        assetsPreloadProgress = 0.0;

        AssetManifest.loadFromFile(path == null ? "manifest/default.json" : path).onComplete(manifestLoaded);

        return this;
    }

    private function manifestLoaded(manifest:AssetManifest):Void
    {
        this.manifest = manifest;

        assetsSizeLoaded = 0;
        assetsSizeTotal = 0;

//        trace(manifest);

        for (asset in manifest.assets)
        {
            //Texts won't be cached currently

            if (assetSuits(asset))
            {
                var assetVo:AssetVo = new AssetVo(asset.id, asset.type, asset.size);
                assetListToPreload.push(assetVo);

                assetsSizeTotal += assetVo.size;
            }
        }

        loadSWFLibrary();
    }

    private function assetSuits(asset:Dynamic):Bool
    {
        #if ignoreQuality
        #if useStarling
        return !asset.preload;
        #else
        return asset.type != AssetType.TEXT && !asset.preload;
        #end
        #end

        #if !useStarling
        return (asset.type == AssetType.MUSIC || asset.type == AssetType.SOUND ||
            StringTools.contains(asset.id, config.basePath))
            && asset.type != AssetType.TEXT && !asset.preload;
        #else
        var isVideo:Bool = asset.id.substr(asset.id.length - 4) == ".mp4";
        var isImage:Bool = asset.type == AssetType.IMAGE;
        var imageSizeSuits:Bool = isImage && StringTools.contains(asset.id, config.basePath);

//        trace("isImage: ", isImage);
//        trace("imageSizeSuits: ", imageSizeSuits);
//        trace("isQualityDependant: ", isQualityDependant);

        return !isVideo && (isQualityDependant(asset.id) && StringTools.contains(asset.id, config.basePath) ||
            !isQualityDependant(asset.id));
        #end
    }

    public function isQualityDependant(assetId:String):Bool
    {
        #if ignoreQuality
        return false;
        #end

        return StringTools.contains(assetId, AssetQuality.High + "/") ||
               StringTools.contains(assetId, AssetQuality.Medium + "/") ||
               StringTools.contains(assetId, AssetQuality.Low + "/");
    }

    private function continueLoadingAssets():Void
    {
        #if !mobile
        if (assetListToPreload.length > 0)
        {
            var soundsToPreloadList:Array<AssetVo> = [];
            for (asset in assetListToPreload)
            {
                #if useStarling
                if (asset.type == openfl.utils.AssetType.SOUND || asset.type == openfl.utils.AssetType.MUSIC)
                {
                    soundsToPreloadList.push(asset);
                } else
                {
                    assetManager.enqueueSingle(asset.id, asset.id);
                }
                #else
                loadAsset(asset);
                #end
            }

            #if useStarling
            #if debug
            assetManager.verbose = true;
            #end
            assetManager.basePath = config.basePath;
            if (soundsToPreloadList.length == 0)
            {
                loadQueue();
            } else
            {
                loadSounds(soundsToPreloadList);
            }
            #end
        } else
        {
            onAssetsLoaded();
        }
        #else
            onAssetsLoaded();
        #end
    }

    private function assetError(error:String):Void
    {
        trace(error);
    }

    #if useStarling
    private var assetManager:AssetManager = new AssetManager();

    private function loadSounds(list:Array<AssetVo>):Void
    {
        var current:AssetVo;
        var loadedCount:Int = 0;

        var continueSounds:Void -> Void = () -> {
            assetsSizeLoaded += current.size;

            onAssetsProgress();

            loadedCount++;

            if (loadedCount == list.length)
            {
                loadQueue();
            }
        }

        for (i in 0...list.length)
        {
            var future = Assets.loadSound(list[i].id);
            future.onComplete((_) -> {
                current = list[i];

                trace("Sound loaded:  " + current.id);

                continueSounds();
            });
            future.onError((error:String) -> {
                current = list[i];

                trace("Sound error: " + current.id, Trace.ERROR);
                assetError(error);

                continueSounds();
            });
        }
    }

    private function loadQueue():Void
    {
        assetManager.loadQueue(onAssetsLoaded, assetError, (progress:Float) ->
        {
            if (config.swfAssetLibList != null)
            {
                progress -= progress * config.swfAssetLibList.length * 0.1;
            }

            assetsPreloadProgress = progress;
            onAssetsProgress();
        });
    }

    private function onAssetsProgress():Void
    {
        dispatchMessage(ResourceServiceMessageType.LoadProgress);
    }

	public function setTexture(id:String, value:starling.textures.Texture):IResourceService
	{
		assetManager.addAsset(id, value, starling.assets.AssetType.TEXTURE);

		return this;
	}

    public function getTexture(path:String, bundleId:String = null):starling.textures.Texture
    {
        var texture:starling.textures.Texture = bundleId == null ? assetManager.getTexture(path) :
            movieClipBundleMap.get(bundleId).getTexture(path);

        if (texture == null)
        {
            traceNotFoundWarning(path);
        }

        return texture;
    }

    public function getTextureAtlas(path:String):starling.textures.TextureAtlas
    {
        var atlas:starling.textures.TextureAtlas = assetManager.getTextureAtlas(path);

        if (atlas == null)
        {
            traceNotFoundWarning(path);
        }

        return atlas;
    }

    public function getBitmapFont(path:String):starling.text.BitmapFont
    {
        var font:starling.text.BitmapFont = assetManager.getBitmapFont(path);

        if (font == null)
        {
            traceNotFoundWarning(path);
        }

        return font;
    }

    private var skeletonDataMap:Map<String, spine.SkeletonData> = new Map<String, spine.SkeletonData>();

    public function getSpineAnimation(assetPath:String, skeletonPath:String = null):spine.starling.SkeletonAnimation
    {
        if (skeletonPath == null)
        {
            skeletonPath = assetPath;
        }

        if (!skeletonDataMap.exists(skeletonPath))
        {
            var textureAtlas = new spine.support.graphics.TextureAtlas(
                getText(assetPath + ".atlas"),
                new spine.starling.StarlingTextureLoader(getTexture(assetPath + ".png"))
            );

            var loader = new spine.attachments.AtlasAttachmentLoader(textureAtlas);
            var skeletonJson = new spine.SkeletonJson(loader);
            var skeletonData = skeletonJson.readSkeletonData(new AssetFile(skeletonPath + ".json", assetManager));

            skeletonDataMap.set(skeletonPath, skeletonData);
        }

        return new spine.starling.SkeletonAnimation(skeletonDataMap.get(skeletonPath));
    }

    private var dbSkeletonDataMap:Map<String, DragonBonesData> = new Map<String, DragonBonesData>();

    public function getDragonBonesAnimation(texturePath:String, skeletonPath:String = null, textureConfigPath:String = null,
                                            armatureName:String = null):dragonBones.starling.StarlingArmatureDisplay
    {
        if (skeletonPath == null)
        {
            skeletonPath = texturePath;
        }
        if (textureConfigPath == null)
        {
            textureConfigPath = texturePath + "_tex";
        }

        if (!dbSkeletonDataMap.exists(skeletonPath))
        {
            var dbSkeletonData:DragonBonesData = null;

            try
            {
                dbSkeletonData = dragonBones.starling.StarlingFactory.factory.parseDragonBonesData(
                    getJson(skeletonPath + ".json"), skeletonPath
                );
            } catch (e:Dynamic)
            {
                throw haxe.io.Error.Custom("DragonBones parse error: " + skeletonPath + ".json");
            }

            dragonBones.starling.StarlingFactory.factory.parseTextureAtlasData(
                getJson(textureConfigPath + ".json"),
                    #if useStarling getTexture(texturePath + ".png") #else getBitmapData(texturePath + ".png") #end,
                    skeletonPath
            );

            dbSkeletonDataMap.set(skeletonPath, dbSkeletonData);
        }

        var armature:dragonBones.starling.StarlingArmatureDisplay =  
            dragonBones.starling.StarlingFactory.factory.buildArmatureDisplay(armatureName == null ?
            dbSkeletonDataMap.get(skeletonPath).armatureNames[0] : armatureName, skeletonPath);

        return armature;
    }

    private var currentSwfLibIndex:Int;

    private function onAssetsLoaded():Void
    {
        if (config.swfAssetLibList != null)
        {
            currentSwfLibIndex = 0;

            createLibrary();
        } else
        {
            dispatchMessage(ResourceServiceMessageType.LoadComplete);
        }
    }

    private var libLoader:LibraryLoader;

    private function createLibrary():Void
    {
        libLoader = new LibraryLoader();
        libLoader.addEventListener(LibraryLoaderEvent.LOADED, libLoaded);
        libLoader.addEventListener(LibraryLoaderEvent.ERROR, libError);

        var path:String = config.swfAssetLibList[currentSwfLibIndex];
        if (exists(path, starling.assets.AssetType.BYTE_ARRAY))
        {
            libLoader.loadBytes(getBytes(path));
        } else
        {
            libError();
        }
    }

    private function libError(e:LibraryLoaderEvent = null):Void
    {
        trace("Failed to load library! " + config.swfAssetLibList[currentSwfLibIndex]);
    }

    private function libLoaded(e:LibraryLoaderEvent):Void
    {
        trace("Library loaded! " + config.swfAssetLibList[currentSwfLibIndex]);

        modelFactory.mapToValue(flump.display.Library, libLoader.library);
        modelFactory.mapToValue(String, config.swfAssetLibList[currentSwfLibIndex], "bundleId");

        movieClipBundleMap.set(config.swfAssetLibList[currentSwfLibIndex], modelFactory.instantiateUnmapped(FlumpMovieClipBundleService));

        currentSwfLibIndex++;

        trace("assetsPreloadProgress " + assetsPreloadProgress);

        if (currentSwfLibIndex == config.swfAssetLibList.length)
        {
            assetsPreloadProgress += assetsPreloadProgress * 0.1;
            onAssetsProgress();

            dispatchMessage(ResourceServiceMessageType.LoadComplete);
        } else
        {
            assetsPreloadProgress = 1.0;
            onAssetsProgress();

            createLibrary();
        }
    }

    public function setBitmapData(path:String, value:BitmapData):IResourceService
    {
        assetManager.addAsset(path, starling.textures.Texture.fromBitmapData(value), starling.assets.AssetType.TEXTURE);

        return this;
    }

    private function loadSWFLibrary():Void
    {
        continueLoadingAssets();
    }

    #else

    private var bitmapFontMap:Map<String, BitmapFont>;
    private var sheetMap:Map<String, Spritesheet>;

    private function loadSWFLibrary():Void
    {
        #if !standAlone
        if (config.swfAssetLibList != null)
        {
            trace("Load swf library: " + config.swfAssetLibList[0]);

            swfLibTotalSizeIncluded = false;

            Assets.loadLibrary(config.swfAssetLibList[0]).onProgress(onSwfLibProgress).onComplete(onSwfLibComplete).onError(onSwfLibError);
        } else
        {
            onSwfLibComplete();
        }
        #else
            onSwfLibComplete();
        #end
    }

    private function onSwfLibError(message:String):Void
    {
        trace("Failed to load swf library: " + message);
    }

    private function onSwfLibProgress(loadedCount:Int, totalCount:Int):Void
    {
        if (!swfLibTotalSizeIncluded)
        {
            swfLibTotalSizeIncluded = true;

            assetsSizeTotal += totalCount * 5000; //it's count, not size. Simulate size by multiplying :(
        }

        assetsSizeLoaded = loadedCount * 5000;

        onAssetsProgress();
    }

    private function onSwfLibComplete(lib:AssetLibrary = null):Void
    {
        modelFactory.mapToValue(AssetLibrary, cast Assets.getLibrary(config.swfAssetLibList[0]));
        movieClipBundle = cast modelFactory.instantiateUnmapped(OpenFLMovieClipBundleService);

        continueLoadingAssets();
    }

    private function loadAsset(asset:AssetVo):Void
    {
        var future = getLoadMethod(asset.type)(asset.id);
        future.onComplete((_) -> assetLoaded(asset));
        future.onError(assetError);
    }

    private function assetLoaded(asset:AssetVo):Void
    {
        trace("assetLoaded " + asset.id);

        assetsSizeLoaded += asset.size;

        onAssetsProgress();
    }

    private function getLoadMethod(assetType:AssetType):Function
    {
        if (assetType == AssetType.IMAGE) return Assets.loadBitmapData;
        if (assetType == AssetType.BINARY) return Assets.loadBytes;
        if (assetType == AssetType.FONT) return Assets.loadFont;
        if (assetType == AssetType.MUSIC) return Assets.loadSound;
        if (assetType == AssetType.SOUND) return Assets.loadSound;
        //if (assetType == AssetType.TEXT) return Assets.loadText;

        throw Error.Custom("Unsupported asset type: " + assetType);
    }

    private function onAssetsProgress():Void
    {
        assetsPreloadProgress = assetsSizeLoaded / assetsSizeTotal;

        if (assetsSizeLoaded == assetsSizeTotal)
        {
            onAssetsLoaded();
        } else
        {
            dispatchMessage(ResourceServiceMessageType.LoadProgress);
        }
    }

    public function getBitmapData(path:String):BitmapData
    {
        var b:BitmapData = Assets.cache.getBitmapData(path);
        if (b == null)
        {
            b = Assets.getBitmapData(path);
            Assets.cache.setBitmapData(path, b);
        }

        return b;
    }

    public function getBitmapFont(path:String):BitmapFont
    {
        if (bitmapFontMap == null)
        {
            bitmapFontMap = new Map<String, BitmapFont>();
        }

        if (!bitmapFontMap.exists(path))
        {
            var fontImage:BitmapData = getBitmapData(path + ".png");
            var fontXML:Xml = Xml.parse(getText(path + ".xml"));
            var font:BitmapFont = BitmapFont.fromAngelCode(fontImage, fontXML);

            bitmapFontMap.set(path, font);
        }

        return bitmapFontMap.get(path);
    }

    public function getSpineTileset(assetPath:String, skeletonPath:String = null):Tileset
    {
        return SpineAssets.get(assetPath, skeletonPath).atlas.loader.getTileset();
    }

    public function getSpineTilemapSkeleton(assetPath:String, skeletonPath:String = null):spine.tilemap.SkeletonAnimation
    {
        if (skeletonPath == null)
        {
            skeletonPath = assetPath;
        }

        var vo:SpineVo = SpineAssets.get(assetPath, skeletonPath);
        var spine:spine.tilemap.SkeletonAnimation = vo.atlas.buildTilemapSkeleton(skeletonPath, vo.jsonData);

        return spine;
    }

    public function getSpineSpriteSkeleton(assetPath:String, skeletonPath:String = null):spine.openfl.SkeletonAnimation
    {
        if (skeletonPath == null)
        {
            skeletonPath = assetPath;
        }

        var vo:SpineVo = SpineAssets.get(assetPath, skeletonPath);
        var spine:spine.openfl.SkeletonAnimation = vo.atlas.buildSpriteSkeleton(skeletonPath, vo.jsonData);
        spine.mouseEnabled = spine.mouseChildren = false;

        return spine;
    }

    private var dbSkeletonDataMap:Map<String, DragonBonesData> = new Map<String, DragonBonesData>();

    public function getDragonBonesAnimation(assetPath:String, skeletonPath:String = null, armatureName:String = null):dragonBones.openfl.OpenFLArmatureDisplay
    {
        if (skeletonPath == null)
        {
            skeletonPath = assetPath;
        }

        if (!dbSkeletonDataMap.exists(skeletonPath))
        {
            var dbSkeletonData:DragonBonesData = dragonBones.openfl.OpenFLFactory.factory.parseDragonBonesData(
                getJson(skeletonPath + ".json")
            );

            dragonBones.openfl.OpenFLFactory.factory.parseTextureAtlasData(
                getJson(assetPath + "_tex.json"),
                    #if useStarling getTexture(assetPath + ".png") #else getBitmapData(assetPath + ".png") #end
            );

            dbSkeletonDataMap.set(skeletonPath, dbSkeletonData);
        }

        return dragonBones.openfl.OpenFLFactory.factory.buildArmatureDisplay(armatureName == null ?
            dbSkeletonDataMap.get(skeletonPath).armatureNames[0] : armatureName);
    }

    public function getSpriteSheet(path:String, ext:String = "png", exp:EReg = null):Spritesheet
    {
        if (sheetMap == null)
        {
            sheetMap = new Map<String, Spritesheet>();
        }

        if (!sheetMap.exists(path))
        {
            var sheet:Spritesheet = new TexturePackerImporter().parse(
                getText(path + ".json"),
                getBitmapData(path + "." + ext),
                exp
            );

            sheetMap.set(path, sheet);
        }

        return sheetMap.get(path);
    }

    private function onAssetsLoaded():Void
    {
        dispatchMessage(ResourceServiceMessageType.LoadComplete);
    }

    public function setBitmapData(path:String, value:BitmapData):IResourceService
    {
        Assets.cache.setBitmapData(path, value);

        return this;
    }

    #end

    public function getMovieClip(id:String, libId:String = null, forceReturnNew:Bool = false):IMovieClip
    {
        if (libId == null) libId = config.swfAssetLibList[0];

        return movieClipBundleMap.get(libId).getMovieClip(id, forceReturnNew);
    }

    public function getDisplayObject(id:String, libId:String = null, forceReturnNew:Bool = false):IDisplayObject
    {
        if (libId == null) libId = config.swfAssetLibList[0];

        return movieClipBundleMap.get(libId).getDisplayObject(id, forceReturnNew);
    }

    public function getJson(path:String):Dynamic
    {
        #if useStarling
        var json:Dynamic = assetManager.getObject(path);
        if (json == null)
        {
            traceNotFoundWarning(path);
        }
        return json;
        #else
        return Json.parse(Assets.getText(path));
        #end
    }

    public function getText(path:String):String
    {
        #if useStarling
        var xml:Xml = assetManager.getXml(path);
        if (xml != null)
        {
            return xml.toString();
        }
        var json:Dynamic = assetManager.getObject(path);
        if (json != null)
        {
            return Json.stringify(json);
        }
        var ba:ByteArray = assetManager.getByteArray(path);
        if (ba == null)
        {
            traceNotFoundWarning(path);
        }
        return ba.toString();
        #else
        return Assets.getText(path);
        #end
    }

    private function traceNotFoundWarning(path:String):Void
    {
        trace("Not found: '" + path + "'. Did you include it to project.xml?", Trace.WARNING);
    }

    public function getBytes(path:String):ByteArray
    {
        return #if useStarling assetManager.getByteArray(path) #else Assets.getBytes(path) #end;
    }

    public function hasMovieClipLibrary(libId:String = null):Bool
    {
        if (libId == null) libId = config.swfAssetLibList[0];

        return movieClipBundleMap.exists(libId);
    }

    public function getSound(path:String):Sound
    {
        return Assets.cache.getSound(path);
    }

    public function getFont(path:String):Font
    {
        return Assets.getFont(path);
    }

    public function exists(path:String, type:String = null):Bool
    {
        #if useStarling
        return type == starling.assets.AssetType.SOUND ? Assets.exists(path, openfl.utils.AssetType.SOUND) :
            assetManager.getAsset(type, path) != null;
        #else
        return Assets.exists(path, cast type);
        #end
    }

    private function get_progress():Float
    {
        return assetsPreloadProgress;
    }

    private function get_contentScaleFactor():Float
    {
        if (config.assetsQuality == AssetQuality.High) return 0.5;
        if (config.assetsQuality == AssetQuality.Low) return 2.0;
        return 1.0;
    }
}

private class AssetVo
{
    public var id(get, never):String;
    public var type(get, never):AssetType;
    public var size(get, never):Int;

    private var _id:String;
    private var _type:AssetType;
    private var _size:Int;

    public function new(id:String, type:AssetType, size:Int)
    {
        _id = id;
        _type = type;
        _size = size;
    }

    private function get_id():String
    {
        return _id;
    }

    private function get_type():AssetType
    {
        return _type;
    }

    private function get_size():Int
    {
        return _size;
    }
}

#if useStarling
class AssetManager extends starling.assets.AssetManager
{
    public var basePath:String;

    public function new(scaleFactor:Float = 1)
    {
        super(scaleFactor);
    }

    override private function getNameFromUrl(url:String):String
    {
        return url;
    }
}

class AssetFile implements FileHandle
{
    public var path:String;
    private var am:AssetManager;

    public function new(id:String, am:AssetManager)
    {
        path = id;
        this.am = am;
    }

    public function getContent():String
    {
        return Json.stringify(am.getObject(path));
    }
}
#end