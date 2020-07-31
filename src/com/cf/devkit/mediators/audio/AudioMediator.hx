package com.cf.devkit.mediators.audio;

import com.cf.devkit.models.pause.PauseState;
import com.cf.devkit.models.pause.PauseModelMessageType;
import com.cf.devkit.models.pause.IPauseModelImmutable;
import com.domwires.core.mvc.message.IMessage;
import com.cf.devkit.config.IConfig;
import com.cf.devkit.mediators.audio.AudioNode;
import com.cf.devkit.mediators.BaseMediator;
import com.cf.devkit.tween.ITween;
import haxe.Timer;

class AudioMediator extends BaseMediator implements IAudioMediator
{
    @Inject
    private var config:IConfig;

    @Inject
    private var pauseModel:IPauseModelImmutable;

    private var musicVolume:Float = 1;
    private var sfxVolume:Float = 1;

    private var nodeListMap:Map<AudioType, Array<AudioNode>>;

    override private function init():Void
    {
        super.init();
        
        nodeListMap = new Map<AudioType, Array<AudioNode>>();

        for (audioType in Type.allEnums(AudioType)) 
        {
            nodeListMap.set(audioType, []);
        }
    }

    private function setMasterSoundVolume(value:Float):Void
    {
        sfxVolume = value;

        for (node in nodeListMap.get(AudioType.Sfx))
        {
            node.masterVolume = value;
            node.updateVolume();
        }
    }

    private function setMasterMusicVolume(value:Float):Void
    {
        musicVolume = value;

        for (node in nodeListMap.get(AudioType.Music))
        {
            node.masterVolume = value;
            node.updateVolume();
        }
    }

    override private function addListeners():Void
    {
        super.addListeners();

        addMessageListener(PauseModelMessageType.PauseStateChanged, pauseStateChanged);
    }

    private var timer:Timer;
    private function pauseStateChanged(m:IMessage):Void
    {
        //To avoid iPad with iOS 12 bug, when switching tabs
        var delay:Int = pauseModel.state == PauseState.PausedVisualsSoundsMusic ? 500 : 0;
        if (delay == 0)
        {
            updatePauseState();
        } else
        {
            if (timer != null)
            {
                timer.stop();
                timer = null;
            }

            timer = Timer.delay(updatePauseState, delay);
        }
    }

    private function updatePauseState():Void
    {
        if (pauseModel.state == PauseState.PausedVisualsSounds || pauseModel.state == PauseState.PausedVisualsSoundsMusic)
        {
            pauseSounds();

            if (pauseModel.state == PauseState.PausedVisualsSoundsMusic)
            {
                pauseMusic();
            } else
            {
                resumeMusic();
            }
        } else
        {
            resumeSounds();
            resumeMusic();
        }
    }

    private function pauseSounds():Void
    {
        pauseModes(nodeListMap.get(AudioType.Sfx));
    }

    private function pauseMusic():Void
    {
        pauseModes(nodeListMap.get(AudioType.Music));
    }

    private function pauseModes(nodeList:Array<AudioNode>):Void
    {
        for (node in nodeList)
        {
            node.pause();
        }
    }

    private function resumeMusic():Void
    {
        resumeNodes(nodeListMap.get(AudioType.Music));
    }

    private function resumeSounds():Void
    {
        resumeNodes(nodeListMap.get(AudioType.Sfx));
    }

    private function resumeNodes(nodeList:Array<AudioNode>):Void
    {
        for (node in nodeList)
        {
            node.resume();
        }
    }

    public function play(id:String, loop:Bool = false, volume:Float = 1.0, isMusic:Bool = false, pauseOnSleep:Bool = true, fadeIn:Float = 0, delay:Float = 0):Void
    {
        playAudio(new AudioVo(id, loop, volume, isMusic ? AudioType.Music : AudioType.Sfx, pauseOnSleep), fadeIn, delay);
    }

    public function playAudio(audio:AudioVo, fadeIn:Float = 0, delay:Float = 0):Void
    {
        if (audio == null) return;

        var type:String;

        #if useStarling
        type = starling.assets.AssetType.SOUND;
        #else
        type = cast openfl.utils.AssetType.SOUND;
        #end

        var ext:String = ".mp3";

        #if mobile
        ext = ".ogg";
        #end

        if (!res.exists(config.soundsPath + "/" + audio.soundId + ext, type))
        {
            trace("Sound not found. Check file path. If OK, then Probably issue with platform and AudioBuffer: " + config.soundsPath +
                  "/" + audio.soundId + ext);
            return;
        }

        var audioNode:AudioNode = new AudioNode(config.soundsPath + "/" + audio.soundId, res, audio.pauseOnSleep, audio.type, viewFactory.getInstance(ITween));
        audioNode.addMessageListener(SfxMessageType.SfxComplete, (m:IMessage) ->
        {
            audioNode.removeAllMessageListeners();
            if (nodeListMap.exists(audioNode.type)) nodeListMap[audioNode.type].remove(audioNode);
            #if dev
            var count:Int = 0;
            for (array in nodeListMap) count += array.length;
            trace("Completed audio: " + audio.soundId + " remain: " + count);
            #end
        });

        if (audio.type == AudioType.Music)
        {
            audioNode.masterVolume = musicVolume;
        } else 
        {
            audioNode.masterVolume = sfxVolume;
        }

        nodeListMap[audioNode.type].push(audioNode);

        audioNode.volume = audio.volume;

        audioNode.play(audio.loop, 0, fadeIn, delay);
    }

    public function stopAudio(id:String, fadeOut:Float = 0):Void
    {
        id = config.soundsPath + "/" + id;

        for (nodeKey in nodeListMap.keys())
        {
            var l:Int = nodeListMap.get(nodeKey).length - 1;
            var node:AudioNode;
            while (l >= 0)
            {
                node = nodeListMap.get(nodeKey)[l];
                if (node.getId() == id)
                {
                    stopNode(node, fadeOut);
                }
                l--;
            }
        }
    }

    private function stopNode(node:AudioNode, fadeOut:Float = 0)
    {
        if (node == null) return;

        trace("Stop audio: " + node.getId());

        node.stop(fadeOut);
    }

    public function isPlayingLoop(id:String):Bool
    {
        id = config.soundsPath + "/" + id;

        for (nodeKey in nodeListMap.keys())
        {
            for (node in nodeListMap[nodeKey])
            {
                if (node.getId() == id && node.getIsLoop())
                {
                    return true;
                }
            }
        }

        return false;
    }

    public function isPlaying(id:String):Bool
    {
        id = config.soundsPath + "/" + id;

        for (nodeKey in nodeListMap.keys())
        {
            for (node in nodeListMap[nodeKey])
            {
                if (node.getId() == id)
                {
                    return true;
                }
            }
        }

        return false;
    }

    public function stopMusic(fadeOut:Float = 0):Void
    {
        var l:Int = nodeListMap.get(AudioType.Music).length - 1;
        var node:AudioNode;
        while (l >= 0)
        {
            node = nodeListMap.get(AudioType.Music)[l];
            stopNode(node, fadeOut);
            l--;
        }
    }

    public function stopSfx(fadeOut:Float = 0):Void
    {
        var l:Int = nodeListMap.get(AudioType.Sfx).length - 1;
        var node:AudioNode;
        while (l >= 0)
        {
            node = nodeListMap.get(AudioType.Sfx)[l];
            stopNode(node, fadeOut);
            l--;
        }
    }
}