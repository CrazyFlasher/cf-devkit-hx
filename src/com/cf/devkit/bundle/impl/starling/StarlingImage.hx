package com.cf.devkit.bundle.impl.starling;

#if useStarling
import com.cf.devkit.services.resources.IResourceServiceImmutable;
import openfl.geom.Rectangle;
import starling.display.Image;
import starling.textures.Texture;

class StarlingImage extends StarlingDisplayObject implements IImage
{
    @Inject
    private var res:IResourceServiceImmutable;

    @Inject("baseScale")
    private var baseScale:Float;

    public var scale9Grid(get, set):Rectangle;

    private var image:Image;

    private var _assetId:String;
    private var _scale9Grid:Rectangle;

    private var checkBaseScale:Bool = true;

    public function setAssetId(assetId:String):Void
    {
        if (_assetId != assetId)
        {
            var texture:Texture = res.getTexture(assetId);

            setTexture(texture);

            _assetId = assetId;

            if (checkBaseScale)
            {
                checkBaseScale = false;

                if (res.isQualityDependant(_assetId))
                {
                    image.scale = 1 / baseScale;
                }
            }
        }
    }

    public function setTexture(texture:starling.textures.Texture):Void
    {
        _assetId = null;

        if (image == null)
        {
            image = new Image(texture);
            _assets = image;

            if (_scale9Grid != null)
            {
                scale9Grid = _scale9Grid;
            }

        } else
        {
            image.texture = texture;
        }
    }

    private function get_scale9Grid():Rectangle
    {
        return _scale9Grid;
    }

    private function set_scale9Grid(value:Rectangle):Rectangle
    {
        _scale9Grid = value;

        if (image != null)
        {
            image.scale9Grid = value;
        }

        return value;
    }
}
#end