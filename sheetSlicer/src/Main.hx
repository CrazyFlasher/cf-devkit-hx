import haxe.Json;
import openfl.display.BitmapData;
import openfl.display.IBitmapDrawable;
import openfl.display.JPEGEncoderOptions;
import openfl.display.PNGEncoderOptions;
import openfl.display.Sprite;
import openfl.display.Tile;
import openfl.display.Tilemap;
import openfl.geom.Point;
import openfl.utils.Assets;
import openfl.utils.ByteArray;
import openfl.utils.Object;
import spritesheet.data.SpritesheetFrame;
import spritesheet.importers.TexturePackerImporter;
import spritesheet.Spritesheet;
import sys.FileSystem;
import sys.io.File;

class Main extends Sprite
{
    public function new()
    {
        super();

        init();
    }

    private function init():Void
    {
        var outDir:String = "../../../out";
        FileSystem.createDirectory(outDir);

        for (filePath in FileSystem.readDirectory("../../../assets"))
        {
            var ext:String = filePath.substr(filePath.length - 4);
            if (ext == ".png" || ext == ".jpg")
            {
                var fileName:String = filePath.split(ext)[0];
                var basePath:String = outDir + "/" + filePath;

                if (Assets.exists("assets/" + filePath.split(ext).join(".json")))
                {
                    trace("Exporting: " + filePath);

                    var json:Dynamic = convert(Json.parse(Assets.getText("assets/" + fileName + ".json")));
                    var bitmap:BitmapData = Assets.getBitmapData("assets/" + filePath);

                    var tpParser = new TexturePackerImporter();

                    var sheet:Spritesheet = tpParser.parse(Json.stringify(json), bitmap);

                    var tilemap:Tilemap = new Tilemap(5000, 5000, sheet.tileset);
                    tilemap.x = tilemap.y = 0;
                    addChild(tilemap);

                    var basePath:String = outDir + "/" + fileName;
                    FileSystem.createDirectory(basePath);

                    for (i in 0...sheet.totalFrames)
                    {
                        tilemap.removeTiles();

                        var frame:SpritesheetFrame = sheet.getFrame(i);
                        var tile:Tile = new Tile(frame.id);

                        tilemap.addTile(tile);

                        tile.originX = tile.width / 2;
                        tile.originY = tile.height / 2;

                        if (isRotated(cast (json.frames, Array<Dynamic>), tile))
                        {
                            tile.rotation = -90;
                        }

                        tile.x = tile.width / 2;
                        tile.y = tile.height / 2;

                        var path:String = basePath + "/" + getName(cast (json.frames, Array<Dynamic>), tile);
                        save(tilemap, path, Math.ceil(tile.width), Math.ceil(tile.height), ext);
                    }

                    removeChild(tilemap);
                } else
                {
                    trace("No atlas file...copying: " + "../../../assets/" + filePath + " to " + outDir + "/" + filePath);
                    try
                    {
                        File.copy("../../../assets/" + filePath, outDir + "/" + filePath);
                    } catch (e:Dynamic)
                    {
                        trace(e);
                    }
                }
            }
        }

        Sys.exit(0);
    }

    private function save(tilemap:IBitmapDrawable, path:String, width:Int, height:Int, ext:String):Void
    {
        var bd:BitmapData = new BitmapData(width, height, true, 0);
        bd.draw(tilemap);

        var compressor:Object = ext == ".jpg" ? new JPEGEncoderOptions(90) : new PNGEncoderOptions();

        var ba:ByteArray = bd.encode(bd.rect, compressor);
        File.saveBytes(path.split(".jpg").join(ext).split(".png").join(ext), ba);
    }

    private function getName(frames:Array<Dynamic>, tile:Tile):String
    {
        return frames[tile.id].filename;
    }

    private function getPivot(frames:Array<Dynamic>, tile:Tile):Point
    {
        return new Point(frames[tile.id].pivot.x, frames[tile.id].pivot.y);
    }

    private function isRotated(frames:Array<Dynamic>, tile:Tile):Bool
    {
        return frames[tile.id].rotated;
    }

    private function convert(json:Dynamic):Dynamic
    {
        var converted:Dynamic = {
            frames: []
        };
        for (field in Reflect.fields(json.frames))
        {
            var frame:Dynamic = Reflect.field(json.frames, field);
            frame.filename = field;

            converted.frames.push(frame);
        }

        return converted;
    }
}
