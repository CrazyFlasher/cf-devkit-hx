import haxe.io.Path;
import sys.io.FileOutput;
import utils.FileUtils;
import sys.io.File;
import haxe.zip.Reader;
import haxe.zip.Writer;
import haxe.zip.Entry;
import sys.FileSystem;
import hxp.HXML;
import hxp.Script;

/**
* Compresses PNGs in directory using pngquant.
* Usage: haxelib run hxp CompressPNGs.hx -Din=<path to input folder>
*
* -Din - path to input directory
* -Dq - quality (0-100) (optional)
* -Dzip - will compress pngs inside zip archives (optional)
* -Dfile - will compress specific png or zip file (optional)
* -Dignore - will ignore specific png in zip file (optional. ex.: -Dignore=atlas_0.png,atlas_1.png)
* -Dnofs - disable Floyd-Steinberg dithering (optional)
**/
class CompressPNGs extends Script
{
    private var input:String;

    private var quality:String = "0-90";
    private var checkZip:Bool = false;
    private var file:String;
    private var ignoreInZip:Array<String>;
    private var hasNoFs:Bool;

    public function new()
    {
        super();

        if (defines.exists("file"))
        {
            trace("Compressing specific file...");
            file = Std.string(defines.get("file"));
        } else
        {
            if (!defines.exists("in"))
            {
                trace("Path to input directory is not specified!");
                trace("Define it as flag -Din=path_to_dir...");
                Sys.exit(1);
            }
            if (defines.exists("zip"))
            {
                checkZip = true;

                trace("Will check inside zip files also...");
            }
        }
        if (!defines.exists("q"))
        {
            trace("Quality no specified. Using default: 0-90...");
        } else
        {
            quality = Std.string(defines.get("q"));
        }

		hasNoFs = defines.exists("nofs");

		if (hasNoFs)
		{
			trace("Floyd-Steinberg dithering disabled!");
		}

        if (file == null)
        {
            input = Path.join([workingDirectory, defines.get("in")]);
            compressDir(input);
        } else
        {
            input = Path.join([workingDirectory, defines.get("file")]);
            if (isPNG(input))
            {
                compressFile(input);
            }else
            if (isZIP(input))
            {
                if (defines.exists("ignore"))
                {
                    ignoreInZip = Std.string(defines.get("ignore")).split(",");

                    trace("Will ignore files in zip: " + ignoreInZip.toString());
                }
                compressZip(input);
            }
        }
    }

    private function compressDir(path:String):Void
    {
        if (FileSystem.exists(path) && FileSystem.isDirectory(path))
        {
            for (filePath in FileSystem.readDirectory(path))
            {
                var p:String = Path.join([path, filePath]);

                if (FileSystem.isDirectory(p))
                {
                    compressDir(p);
                } else
                {
                    if (isPNG(filePath))
                    {
                        compressFile(p);
                    }else
                    if (isZIP(filePath) && checkZip)
                    {
                        compressZip(p);
                    }
                }
            }
        }
    }

    private function compressZip(path:String):Void
    {
        trace("Unpacking zip file: " + path);

        var reader:Reader = new Reader(File.read(path, true));
        var list:List<Entry> = reader.read();

        var dir:String = path + "_temp/";
        FileUtils.deleteWithFiles(dir);
        FileSystem.createDirectory(dir);

        for (entry in list)
        {
            Reader.unzip(entry);

            var filePath:String = Path.join([dir, entry.fileName]);
            File.saveBytes(filePath, entry.data);

            if (isPNG(entry.fileName))
            {
                if (ignoreInZip != null && ignoreInZip.indexOf(entry.fileName) != -1)
                {
                    trace("Ignoring file: " + entry.fileName);
                } else
                {
                    compressFile(filePath);
                }
            }
        }

        // create the output file
        var out:FileOutput = File.write(path, true);
        // write the zip file
        var writer:Writer = new Writer(out);
        writer.write(getEntries(dir));

        FileUtils.deleteWithFiles(dir);
    }

    // recursive read a directory, add the file entries to the list
    private function getEntries(dir:String, entries:List<haxe.zip.Entry> = null, inDir:Null<String> = null)
    {
        if (entries == null) entries = new List<haxe.zip.Entry>();
        if (inDir == null) inDir = dir;
        for (file in sys.FileSystem.readDirectory(dir))
        {
            var path = haxe.io.Path.join([dir, file]);
            if (sys.FileSystem.isDirectory(path))
            {
                getEntries(path, entries, inDir);
            } else
            {
                var bytes:haxe.io.Bytes = haxe.io.Bytes.ofData(sys.io.File.getBytes(path).getData());
                var entry:haxe.zip.Entry = {
//                    fileName: file.toString(),
                    fileName: StringTools.replace(path, inDir, ""),
                    fileSize: bytes.length,
                    fileTime: Date.now(),
                    compressed: false,
                    dataSize: 0,
                    data: bytes,
                    crc32: haxe.crypto.Crc32.make(bytes)
                };
                entries.push(entry);
            }
        }
        return entries;
    }

    private function compressFile(path:String):Void
    {
        trace("Compress file: " + path);

        var result:Int = new HXML({
//            cmds: ["pngquant " + path + " --ext .png --force --speed 1 --posterize ARGB4444 --quality " + quality]
//            cmds: ["pngquant " + path + " --ext .png --force --speed 1 --nofs --quality " + quality]
//            cmds: ["pngquant " + path + " --ext .png --force --speed 1 --posterize ARGB4444 --quality " + quality]
			cmds: ["pngquant " + path + " --ext .png --force --speed 1 --posterize ARGB4444 --quality " + quality + (hasNoFs ? " --nofs" : "")]
        }).build();
    }

    private function isPNG(fileName:String):Bool
    {
        return fileName.substr(fileName.length - 4) == ".png";
    }

    private function isZIP(fileName:String):Bool
    {
        return fileName.substr(fileName.length - 4) == ".zip";
    }
}