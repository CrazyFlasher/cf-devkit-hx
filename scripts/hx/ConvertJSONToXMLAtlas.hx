import haxe.Json;
import sys.io.File;
import hxp.Script;
import sys.FileSystem;

/**
* Converts JSON hash atlas data files to XML Starling / Sparrow format in specified directory.
* Usage: haxelib run hxp ConvertJSONToXMLAtlas.hx -Din=<path to input folder>
*
* -Din - path to input directory
* -Dext - jpg or png (optional; default is png)
* -DimagePath - path, that will be assigned to imagePath xml attribute. If not defined -Din will be considered as imagePath (optional)
**/
class ConvertJSONToXMLAtlas extends Script
{
    private var input:String;
    private var ext:String = "png";
    private var imagePath:String;

    public function new()
    {
        super();

        Sys.setCwd(workingDirectory);

        if (!defines.exists("in"))
        {
            trace("Path to input directory is not specified!");
            trace("Define it as flag -Din=path_to_dir...");
            Sys.exit(1);
        }

        if (defines.exists("ext"))
        {
            ext = defines.get("ext");
        }

        input = defines.get("in");

        if (defines.exists("imagePath"))
        {
            imagePath = defines.get("imagePath");
        } else
        {
            imagePath = input;
        }

        convertDir(input);
    }

    private function convertDir(path:String):Void
    {
        if (FileSystem.exists(path) && FileSystem.isDirectory(path))
        {
            for (filePath in FileSystem.readDirectory(path))
            {
                var p:String = path + "/" + filePath;
                if (FileSystem.isDirectory(p))
                {
                    convertDir(p);
                } else
                {
                    if (isJSON(filePath))
                    {
                        convertFile(p, filePath);
                    }
                }
            }
        }
    }

    private function isJSON(fileName:String):Bool
    {
        return fileName.substr(fileName.length - 5) == ".json";
    }

    private function convertFile(path:String, fileName:String):Void
    {
        trace("Convert file: " + path);

        var fileNameNoExt:String = fileName.substr(0, fileName.length - 5);

        var json:Dynamic = Json.parse(File.getContent(path));

        var xmlStr:String =
            "<?xml version='1.0' encoding='utf-8'?>\n" +
                "<TextureAtlas imagePath='" + imagePath + "/" + fileNameNoExt + "." + ext + "'>\n";

        for (field in Reflect.fields(json.frames))
        {
            var frame:Dynamic = Reflect.field(json.frames, field).frame;
            var spriteSourceSize:Dynamic = Reflect.field(json.frames, field).spriteSourceSize;
            var sourceSize:Dynamic = Reflect.field(json.frames, field).sourceSize;
            var pivot:Dynamic = Reflect.field(json.frames, field).pivot;

            var rotated =  Reflect.field(json.frames, field).rotated;
            var x = frame.x;
            var y = frame.y;
            var width = !rotated ? frame.w : frame.h;
            var height = !rotated ? frame.h : frame.w;
            var frameX = frame.w - sourceSize.w;
            var frameY = frame.h - sourceSize.h;
            var frameWidth = sourceSize.w;
            var frameHeight = sourceSize.h;
            var rotatedStr = rotated ? 'true' : 'false';
            var subText:String = '<SubTexture name=\'${field}\' x=\'${x}\' y=\'${y}\' width=\'${width}\' height=\'${height}\' frameX=\'${frameX}\' frameY=\'${frameY}\' frameWidth=\'${frameWidth}\' frameHeight=\'${frameHeight}\' rotated=\'${rotatedStr}\'/>\n';

            xmlStr += subText;
        }

        xmlStr += "</TextureAtlas>";

        trace(xmlStr);

        File.saveContent(defines.get("in") + "/" + fileNameNoExt + ".xml", xmlStr);
    }
}
