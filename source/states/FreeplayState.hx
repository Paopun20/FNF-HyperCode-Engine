package states;

// 1. IMPORTS
import backend.WeekData;
import backend.Highscore;
import backend.Song;
import objects.HealthIcon;
import objects.MusicPlayer;
import options.GameplayChangersSubstate;
import substates.ResetScoreSubState;
import flixel.math.FlxMath;
import flixel.util.FlxDestroyUtil;
import openfl.utils.Assets;
import haxe.Json;

class FreeplayState extends MusicBeatState
{
    // 2. CLASS VARIABLES
    
    // Song Data
    var songs:Array<SongMetadata> = [];
    private static var curSelected:Int = 0;
    var lerpSelected:Float = 0;
    var curDifficulty:Int = -1;
    private static var lastDifficultyName:String = Difficulty.getDefault();
    
    // UI Elements
    var grpSongs:FlxTypedGroup<Alphabet>;
    var iconArray:Array<HealthIcon> = [];
    
    // Score Display
    var scoreBG:FlxSprite;
    var scoreText:FlxText;
    var diffText:FlxText;
    var lerpScore:Int = 0;
    var lerpRating:Float = 0;
    var intendedScore:Int = 0;
    var intendedRating:Float = 0;
    
    // Background
    var bg:FlxSprite;
    var intendedColor:Int;
    
    // Error Handling
    var missingTextBG:FlxSprite;
    var missingText:FlxText;
    
    // Bottom Panel
    var bottomString:String;
    var bottomText:FlxText;
    var bottomBG:FlxSprite;
    
    // Music Playback
    var player:MusicPlayer;
    var instPlaying:Int = -1;
    public static var vocals:FlxSound = null;
    public static var opponentVocals:FlxSound = null;
    var holdTime:Float = 0;
    var stopMusicPlay:Bool = false;

    // 3. STATE LIFECYCLE METHODS
    
    override function create()
    {
        persistentUpdate = true;
        setupFreeplay();
        super.create();
    }

    override function update(elapsed:Float)
    {
        if(WeekData.weeksList.length < 1) return;
        
        updateMusicVolume(elapsed);
        updateScoreDisplay(elapsed);
        handleInput(elapsed);
        updateTexts(elapsed);
        
        super.update(elapsed);
    }

    override function destroy():Void
    {
        super.destroy();
        handleAutoPause();
    }

    override function closeSubState()
    {
        changeSelection(0, false);
        persistentUpdate = true;
        super.closeSubState();
    }

    // 4. INITIALIZATION METHODS
    
    function setupFreeplay()
    {
        PlayState.isStoryMode = false;
        WeekData.reloadWeekFiles(false);
        
        #if DISCORD_ALLOWED
        DiscordClient.changePresence("In the Menus", null);
        #end
        
        checkForEmptyWeeks();
        loadAvailableSongs();
        createUI();
        initializeSelection();
    }

    function checkForEmptyWeeks()
    {
        if(WeekData.weeksList.length < 1)
        {
            FlxTransitionableState.skipNextTransIn = true;
            persistentUpdate = false;
            MusicBeatState.switchState(new states.ErrorState(
                "NO WEEKS ADDED FOR FREEPLAY\n\nPress ACCEPT to go to the Week Editor Menu.\nPress BACK to return to Main Menu.",
                function() MusicBeatState.switchState(new states.editors.WeekEditorState()),
                function() MusicBeatState.switchState(new states.MainMenuState())
            ));
        }
    }

    function loadAvailableSongs()
    {
        for (i in 0...WeekData.weeksList.length)
        {
            if(weekIsLocked(WeekData.weeksList[i])) continue;
            
            var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
            WeekData.setDirectoryFromWeek(leWeek);
            
            for (song in leWeek.songs)
            {
                var colors:Array<Int> = song[2];
                if(colors == null || colors.length < 3) colors = [146, 113, 253];
                addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
            }
        }
        Mods.loadTopMod();
    }

    function createUI()
    {
        createBackground();
        createSongList();
        createScoreDisplay();
        createErrorDisplay();
        createBottomPanel();
        addPlayer();
    }

    function createBackground()
    {
        bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.antialiasing = ClientPrefs.data.antialiasing;
        add(bg);
        bg.screenCenter();
    }

    function createSongList()
    {
        grpSongs = new FlxTypedGroup<Alphabet>();
        add(grpSongs);

        for (i in 0...songs.length)
        {
            var songText:Alphabet = new Alphabet(90, 320, songs[i].songName, true);
            songText.targetY = i;
            songText.scaleX = Math.min(1, 980 / songText.width);
            songText.snapToPosition();
            songText.visible = songText.active = songText.isMenuItem = false;
            grpSongs.add(songText);

            Mods.currentModDirectory = songs[i].folder;
            var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
            icon.sprTracker = songText;
            icon.visible = icon.active = false;
            iconArray.push(icon);
            add(icon);
        }
        WeekData.setDirectoryFromWeek();
    }

    function createScoreDisplay()
    {
        scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
        scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

        scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
        scoreBG.alpha = 0.6;
        add(scoreBG);

        diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
        diffText.font = scoreText.font;
        add(diffText);
        add(scoreText);
    }

    function createErrorDisplay()
    {
        missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        missingTextBG.alpha = 0.6;
        missingTextBG.visible = false;
        add(missingTextBG);
        
        missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
        missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        missingText.scrollFactor.set();
        missingText.visible = false;
        add(missingText);
    }

    function createBottomPanel()
    {
        bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
        bottomBG.alpha = 0.6;
        add(bottomBG);

        bottomString = Language.getPhrase("freeplay_tip", "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.");
        bottomText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, bottomString, 16);
        bottomText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
        bottomText.scrollFactor.set();
        add(bottomText);
    }

    function addPlayer()
    {
        player = new MusicPlayer(this);
        add(player);
    }

    function initializeSelection()
    {
        if(curSelected >= songs.length) curSelected = 0;
        bg.color = songs[curSelected].color;
        intendedColor = bg.color;
        lerpSelected = curSelected;
        curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));
        changeSelection();
    }

    // 5. SELECTION & NAVIGATION METHODS
    
    function changeSelection(change:Int = 0, playSound:Bool = true)
    {
        if (player.playingMusic) return;
        
        curSelected = FlxMath.wrap(curSelected + change, 0, songs.length-1);
        _updateSongLastDifficulty();
        
        if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
        updateSelectionColor();
        updateSelectionVisuals();
        updateDifficultyFromSelection();
    }

    function updateSelectionColor()
    {
        var newColor:Int = songs[curSelected].color;
        if(newColor != intendedColor)
        {
            intendedColor = newColor;
            FlxTween.cancelTweensOf(bg);
            FlxTween.color(bg, 1, bg.color, intendedColor);
        }
    }

    function updateSelectionVisuals()
    {
        for (num => item in grpSongs.members)
        {
            var icon:HealthIcon = iconArray[num];
            item.alpha = 0.6;
            icon.alpha = 0.6;
            if (item.targetY == curSelected)
            {
                item.alpha = 1;
                icon.alpha = 1;
            }
        }
    }

    function updateDifficultyFromSelection()
    {
        Mods.currentModDirectory = songs[curSelected].folder;
        PlayState.storyWeek = songs[curSelected].week;
        Difficulty.loadFromWeek();
        
        var savedDiff:String = songs[curSelected].lastDifficulty;
        var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
        if(savedDiff != null && !Difficulty.list.contains(savedDiff) && Difficulty.list.contains(savedDiff))
            curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
        else if(lastDiff > -1)
            curDifficulty = lastDiff;
        else if(Difficulty.list.contains(Difficulty.getDefault()))
            curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
        else
            curDifficulty = 0;

        changeDiff();
        _updateSongLastDifficulty();
    }

    function changeDiff(change:Int = 0)
    {
        if (player.playingMusic) return;
        
        curDifficulty = FlxMath.wrap(curDifficulty + change, 0, Difficulty.list.length-1);
        updateScoreData();
        updateDiffDisplay();
        positionHighscore();
        hideErrorMessages();
    }

    function updateScoreData()
    {
        #if !switch
        intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
        intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
        #end
    }

    function updateDiffDisplay()
    {
        lastDifficultyName = Difficulty.getString(curDifficulty, false);
        var displayDiff:String = Difficulty.getString(curDifficulty);
        if (Difficulty.list.length > 1)
            diffText.text = '< ' + displayDiff.toUpperCase() + ' >';
        else
            diffText.text = displayDiff.toUpperCase();
    }

    function hideErrorMessages()
    {
        missingText.visible = false;
        missingTextBG.visible = false;
    }

    // 6. INPUT HANDLING
    
    function handleInput(elapsed:Float)
    {
        if (!player.playingMusic)
        {
            handleSongSelectionInput(elapsed);
            handleDifficultyInput();
        }
        
        handleBackInput();
        handleGameplayChangersInput();
        handlePreviewInput();
        handlePlayInput();
        handleResetInput();
    }

    function handleSongSelectionInput(elapsed:Float)
    {
        if(songs.length > 1)
        {
            handleHomeEndKeys();
            handleUpDownKeys(elapsed);
            handleMouseWheel();
        }
    }

    function handleHomeEndKeys()
    {
        if(FlxG.keys.justPressed.HOME)
        {
            curSelected = 0;
            changeSelection();
            holdTime = 0;    
        }
        else if(FlxG.keys.justPressed.END)
        {
            curSelected = songs.length - 1;
            changeSelection();
            holdTime = 0;    
        }
    }

    function handleUpDownKeys(elapsed:Float)
    {
        var shiftMult:Int = FlxG.keys.pressed.SHIFT ? 3 : 1;
        
        if (controls.UI_UP_P)
        {
            changeSelection(-shiftMult);
            holdTime = 0;
        }
        if (controls.UI_DOWN_P)
        {
            changeSelection(shiftMult);
            holdTime = 0;
        }

        if(controls.UI_DOWN || controls.UI_UP)
        {
            var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
            holdTime += elapsed;
            var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

            if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
                changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
        }
    }

    function handleMouseWheel()
    {
        if(FlxG.mouse.wheel != 0)
        {
            FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
            changeSelection(-(FlxG.keys.pressed.SHIFT ? 3 : 1) * FlxG.mouse.wheel, false);
        }
    }

    function handleDifficultyInput()
    {
        if (controls.UI_LEFT_P)
        {
            changeDiff(-1);
            _updateSongLastDifficulty();
        }
        else if (controls.UI_RIGHT_P)
        {
            changeDiff(1);
            _updateSongLastDifficulty();
        }
    }

    function handleBackInput()
    {
        if (controls.BACK)
        {
            if (player.playingMusic)
            {
                stopPreviewMusic();
            }
            else 
            {
                persistentUpdate = false;
                FlxG.sound.play(Paths.sound('cancelMenu'));
                MusicBeatState.switchState(new MainMenuState());
            }
        }
    }

    function handleGameplayChangersInput()
    {
        if(FlxG.keys.justPressed.CONTROL && !player.playingMusic)
        {
            persistentUpdate = false;
            openSubState(new GameplayChangersSubstate());
        }
    }

    function handlePreviewInput()
    {
        if(FlxG.keys.justPressed.SPACE)
        {
            if(instPlaying != curSelected && !player.playingMusic)
            {
                startPreviewMusic();
            }
            else if (instPlaying == curSelected && player.playingMusic)
            {
                player.pauseOrResume(!player.playing);
            }
        }
    }

    function handlePlayInput()
    {
        if (controls.ACCEPT && !player.playingMusic)
        {
            persistentUpdate = false;
            tryStartSong();
        } else if (controls.justPressed("debug_1")) {
            persistentUpdate = false;
            PlayState.chartingMode = true;
            tryStartSong();
        }
    }

    function handleResetInput()
    {
        if(controls.RESET && !player.playingMusic)
        {
            persistentUpdate = false;
            openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
            FlxG.sound.play(Paths.sound('scrollMenu'));
        }
    }

    // 7. MUSIC PLAYBACK METHODS
    
    function startPreviewMusic()
    {
        destroyFreeplayVocals();
        FlxG.sound.music.volume = 0;

        Mods.currentModDirectory = songs[curSelected].folder;
        var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
        Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
        
        if (PlayState.SONG.needsVoices)
        {
            loadVocals();
        }

        FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.8);
        FlxG.sound.music.pause();
        instPlaying = curSelected;

        player.playingMusic = true;
        player.curTime = 0;
        player.switchPlayMusic();
        player.pauseOrResume(true);
    }

    function loadVocals()
    {
        loadPlayerVocals();
        loadOpponentVocals();
    }

    function loadPlayerVocals()
    {
        vocals = new FlxSound();
        try
        {
            var playerVocals:String = getVocalFromCharacter(PlayState.SONG.player1);
            var loadedVocals = Paths.voices(PlayState.SONG.song, (playerVocals != null && playerVocals.length > 0) ? playerVocals : 'Player');
            if(loadedVocals == null) loadedVocals = Paths.voices(PlayState.SONG.song);
            
            if(loadedVocals != null && loadedVocals.length > 0)
            {
                vocals.loadEmbedded(loadedVocals);
                FlxG.sound.list.add(vocals);
                vocals.persist = vocals.looped = true;
                vocals.volume = 0.8;
                vocals.play();
                vocals.pause();
            }
            else vocals = FlxDestroyUtil.destroy(vocals);
        }
        catch(e:Dynamic)
        {
            vocals = FlxDestroyUtil.destroy(vocals);
        }
    }

    function loadOpponentVocals()
    {
        opponentVocals = new FlxSound();
        try
        {
            var oppVocals:String = getVocalFromCharacter(PlayState.SONG.player2);
            var loadedVocals = Paths.voices(PlayState.SONG.song, (oppVocals != null && oppVocals.length > 0) ? oppVocals : 'Opponent');
            
            if(loadedVocals != null && loadedVocals.length > 0)
            {
                opponentVocals.loadEmbedded(loadedVocals);
                FlxG.sound.list.add(opponentVocals);
                opponentVocals.persist = opponentVocals.looped = true;
                opponentVocals.volume = 0.8;
                opponentVocals.play();
                opponentVocals.pause();
            }
            else opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
        }
        catch(e:Dynamic)
        {
            opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
        }
    }

    function stopPreviewMusic()
    {
        FlxG.sound.music.stop();
        destroyFreeplayVocals();
        FlxG.sound.music.volume = 0;
        instPlaying = -1;

        player.playingMusic = false;
        player.switchPlayMusic();

        FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
        FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);
    }

    public static function destroyFreeplayVocals() 
    {
        if(vocals != null) vocals.stop();
        vocals = FlxDestroyUtil.destroy(vocals);

        if(opponentVocals != null) opponentVocals.stop();
        opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
    }

    // 8. SONG PLAY METHODS
    
    function tryStartSong()
    {
        var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
        var poop:String = Highscore.formatSong(songLowercase, curDifficulty);

        try
        {
            Song.loadFromJson(poop, songLowercase);
            PlayState.isStoryMode = false;
            PlayState.storyDifficulty = curDifficulty;

            trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
            prepareToPlay();
        }
        catch(e:haxe.Exception)
        {
            handleChartError(e, songLowercase);
        }
    }

    function prepareToPlay()
    {
        @:privateAccess
        if(PlayState._lastLoadedModDirectory != Mods.currentModDirectory)
        {
            trace('CHANGED MOD DIRECTORY, RELOADING STUFF');
            Paths.freeGraphicsFromMemory();
        }
        LoadingState.prepareToSong();
        LoadingState.loadAndSwitchState(new PlayState());
        #if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
        stopMusicPlay = true;

        destroyFreeplayVocals();
        #if (MODS_ALLOWED && DISCORD_ALLOWED)
        DiscordClient.loadModRPC();
        #end
    }

    function handleChartError(e:haxe.Exception, songLowercase:String)
    {
        trace('ERROR! ${e.message}');

        var errorStr:String = e.message;
        if(errorStr.contains('There is no TEXT asset with an ID of')) 
            errorStr = 'Missing file: ' + errorStr.substring(errorStr.indexOf(songLowercase), errorStr.length-1);
        else 
            errorStr += '\n\n' + e.stack;

        missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
        missingText.screenCenter(Y);
        missingText.visible = true;
        missingTextBG.visible = true;
        FlxG.sound.play(Paths.sound('cancelMenu'));
    }

    // 9. UI UPDATE METHODS
    
    function updateMusicVolume(elapsed:Float)
    {
        if (FlxG.sound.music.volume < 0.7)
            FlxG.sound.music.volume += 0.5 * elapsed;
    }

    function updateScoreDisplay(elapsed:Float)
    {
        lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
        lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));

        if (Math.abs(lerpScore - intendedScore) <= 10)
            lerpScore = intendedScore;
        if (Math.abs(lerpRating - intendedRating) <= 0.01)
            lerpRating = intendedRating;

        var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
        if(ratingSplit.length < 2) ratingSplit.push('');
        while(ratingSplit[1].length < 2) ratingSplit[1] += '0';

        if (!player.playingMusic)
        {
            scoreText.text = Language.getPhrase('personal_best', 'PERSONAL BEST: {1} ({2}%)', [lerpScore, ratingSplit.join('.')]);
            positionHighscore();
        }
    }

    function updateTexts(elapsed:Float = 0.0)
    {
        lerpSelected = FlxMath.lerp(curSelected, lerpSelected, Math.exp(-elapsed * 9.6));
        updateVisibleItems();
    }

    function updateVisibleItems()
    {
        for (i in _lastVisibles)
        {
            grpSongs.members[i].visible = grpSongs.members[i].active = false;
            iconArray[i].visible = iconArray[i].active = false;
        }
        _lastVisibles = [];

        var min:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected - _drawDistance)));
        var max:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected + _drawDistance)));
        for (i in min...max)
        {
            var item:Alphabet = grpSongs.members[i];
            item.visible = item.active = true;
            item.x = ((item.targetY - lerpSelected) * item.distancePerItem.x) + item.startPosition.x;
            item.y = ((item.targetY - lerpSelected) * 1.3 * item.distancePerItem.y) + item.startPosition.y;

            var icon:HealthIcon = iconArray[i];
            icon.visible = icon.active = true;
            _lastVisibles.push(i);
        }
    }

    function positionHighscore()
    {
        scoreText.x = FlxG.width - scoreText.width - 6;
        scoreBG.scale.x = FlxG.width - scoreText.x + 6;
        scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
        diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
        diffText.x -= diffText.width / 2;
    }

    // 10. HELPER METHODS
    
    public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
    {
        songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
    }

    function weekIsLocked(name:String):Bool
    {
        var leWeek:WeekData = WeekData.weeksLoaded.get(name);
        return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
    }

    function getVocalFromCharacter(char:String)
    {
        try
        {
            var path:String = Paths.getPath('characters/$char.json', TEXT);
            #if MODS_ALLOWED
            var character:Dynamic = Json.parse(File.getContent(path));
            #else
            var character:Dynamic = Json.parse(Assets.getText(path));
            #end
            return character.vocals_file;
        }
        catch (e:Dynamic) {}
        return null;
    }

    function handleAutoPause()
    {
        FlxG.autoPause = ClientPrefs.data.autoPause;
        if (!FlxG.sound.music.playing && !stopMusicPlay)
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
    }

    inline private function _updateSongLastDifficulty()
        songs[curSelected].lastDifficulty = Difficulty.getString(curDifficulty, false);

    // 11. PRIVATE VARIABLES
    
    var _drawDistance:Int = 4;
    var _lastVisibles:Array<Int> = [];
}

// 12. METADATA CLASS
class SongMetadata
{
    public var songName:String = "";
    public var week:Int = 0;
    public var songCharacter:String = "";
    public var color:Int = -7179779;
    public var folder:String = "";
    public var lastDifficulty:String = null;

    public function new(song:String, week:Int, songCharacter:String, color:Int)
    {
        this.songName = song;
        this.week = week;
        this.songCharacter = songCharacter;
        this.color = color;
        this.folder = Mods.currentModDirectory;
        if(this.folder == null) this.folder = '';
    }
}