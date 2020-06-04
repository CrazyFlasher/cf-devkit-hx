# CFDevkit

Dependency for games written in [Haxe](https://haxe.org/)

*Note:* it's strictly recommended to use specific commit, when installing **cf-devkit-hx** library for your Haxe project

Check [Samples](https://github.com/CrazyFlasher/cf-devkit-hx-samples/) 

##### 1. Build, run tests and generate docs

1. Download and install [Haxe 4.0.1](https://haxe.org/download/version/4.0.1/)
2. Download [Pngquant](https://https://pngquant.org/)
   * Extract binaries
   * Add path of extraction to "PATH" in environment variables (for Windows)
3. Install Java SE https://www.java.com/ 
4. In project directory run `haxe scripts/package.hxml`

* ~~Docs will be uploaded here~~
* ~~Simple tests reports will be uploaded here~~
* [Samples](https://github.com/CrazyFlasher/cf-devkit-hx-samples)
* ~~OpenFL samples~~ (currently outdated) 

##### 2. Run tests with detailed web generated report

Run `haxe haxelib run munit test ./scripts/test.hxml`<br/>
Web page will be automatically opened in default browser with test results

##### 3. Include CFDevkit to project

Run `haxelib git cf-devkit-hx https://github.com/CrazyFlasher/cf-devkit-hx <branch or commit>`

##### 4.1 Creating asset bundles in Adobe Animate (AKA Flash)

Check [cf-devkit-hx-samples](https://github.com/CrazyFlasher/cf-devkit-hx)

* First of all you need to install [Adobe Animate](https://www.adobe.com/products/animate.html), that will be used as visual editor.
* Install [Adobe AIR](https://get.adobe.com/air/) runtime.
* Create a **.fla** in [Adobe Animate](https://www.adobe.com/products/animate.html) 
* Create a new item in the library and draw a shape in its canvas.
* Right-click on the item, select its properties, tick the **Export for ActionScript** and **Export in frame 1** checkboxes and change
 its base class to `flash.display.Sprite`.
* Create a second item in the library, and drag the first into it.
* Add additional frames in the second item, and create a classic tween moving the first item around in those frames.
* Set the **Export for ActionScript** and **Export in frame 1** properties for the second item. Leave its base class as `flash.display.MovieClip`.
* Save the **.fla**.
* Create **.flump** project file using exporter UI (or just copy from [cf-devkit-hx-samples](https://github.com/CrazyFlasher/cf-devkit-hx-samples/tree/master/assets/bundle_1/f.flump).

**Windows UI:** `%project%/.haxelib/flump/git/bin/exporter/Flump.exe`

**Mac UI:** `%project%/.haxelib/flump/git/bin/exporter-mac/Contents/MacOS/Flump`

* Run `haxelib run hxp .haxelib/cf-devkit-hx/git/scripts/hx/ExportFlashSWF.hx -Ddir=%path_to_dir_with_fla_swf_flump%`
* Run `haxelib run hxp .haxelib/cf-devkit-hx/git/scripts/hx/ExportFlumpSWF.hx -Ddir=%path_to_dir_with_fla_swf_flump% -DjpgQuality=80`
* Run `haxelib run hxp .haxelib/cf-devkit-hx/git/scripts/hx/CompressPNGs.hx -Dfile=%path_to_zip% -Dq=0-80`

*More information about scripts can be found inside of scripts hx files.*

Those 3 actions can be combined in 1 **hxml** file. 
See [cf-devkit-hx-samples](https://github.com/CrazyFlasher/cf-devkit-hx-samples/blob/master/scripts/export-swf.hxml).

##### 4.2 Details of Flump's conversion

This walks through Flump's process when it exports a single .fla/.swf file combo.

##### Texture creation

For each item in the document's library that is exported for ActionScript and extends `flash.display.Sprite`, Flump creates a texture. To do so, it instantiates the library's exported symbol from the `.swf` file and renders it to a bitmap.

All of the created bitmaps for a Flash document are packed into texture atlases, and xml is generated to map between a texture's symbol and its location in the bitmap.

##### Animation creation

For each item in the document's library that extends `flash.display.MovieClip` and isn't a flipbook (explained below), Flump creates an animation. It checks that for all layers and keyframes, each used symbol is either a texture, an animation, or a flipbook. Flump animations can only be constructed from the flump types.

##### Flipbook creation

For animations that only contain a few frames, a **flipbook** may be more appropriate. To create one, add a new item to the library and name
 the first layer in the created item **flipbook**. When exporting, flump will create a bitmap for each keyframe in the flipbook layer. In
  playback, flump will display those bitmaps at the same timing.

##### Text fields

* To export texts field, create `flash.display.Sprite` with dynamic text field inside.
* Name of the layer with this sprite should contain `@tf:`.
* Open library and add `@tf:` at the beginning of the linkage name.

*Example:* `@tf:amount#160#0xFFFFFF#Noto Serif Condensed Black#center`

* `amount` - instance name
* `160` - font size
* `0xFFFFFF` - color
* `Noto Serif Condensed Black` - font name or path to bitmap font atlas image
* `center` - horizontal align

More information can be found in [FlumpMovieClip#getNewTextField](https://github.com/CrazyFlasher/cf-devkit-hx/blob/master/src/com/cf/devkit/bundle/impl/starling/flump/FlumpMovieClip.hx)

Of course, there are much more methods and properties, that can be modified via code.

##### Spine

To inject spine clip, create place holder with `flash.display.MovieClip` type and add `@spine:` to layer name.

##### DragonBones

To inject dragon bones clip, create place holder with `flash.display.MovieClip` type and add `@db:` to layer name.

##### Particle emitter (PEX)

To inject pex particle emitter, create place holder with `flash.display.MovieClip` type and add `@particle:` to layer name.

##### Sprite sheet animation

To inject sprite sheet animation, create place holder with `flash.display.MovieClip` type and add `@sheet:` to layer name.

##### External image

To inject external image, create place holder with `flash.display.MovieClip` type and add `@image:` to layer name.

##### Exclude layer

To exclude layer from being exported, add `$` to layer name. That means, than layer will be seen in Animate, but won't be exporter. Useful for placeholders. 

##### Force asset to be exported to separate atlas image

If you want to export asset to separate atlas, add `$single` to library linkage name.

##### Export as JPG

By default assets will be exported to `png` atlases. But you can optionally specified assets, that must be exported as `jpg`. Just add
 `$jpg` to library linkage name.