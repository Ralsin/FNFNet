package;

import flixel.FlxBasic.FlxType;
#if desktop
import sys.io.File;
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;

using StringTools;

class MainMenuState extends MusicBeatState
{
    var cur:Int = 0;
    var camFollow:FlxObject = new FlxObject(0, 0, 1, 1);
    var menuItems:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
    var optionShit:Array<String> = ['freeplay', 'play', 'options'];
    var mLogo:FlxSprite = new FlxSprite(650, -500);
    public static var notPlaying:Bool;

    override function create() {
        #if desktop
            DiscordClient.changePresence("In the new funky menu.", "Doing funky things.");
        #end
        transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		if (!FlxG.sound.music.playing){
            var now = Date.now();
            trace(now.getHours());
            if(now.getHours() >= 18) {
                FlxG.sound.playMusic(Paths.music('freakyNight'));
                Conductor.changeBPM(117);
            }
            else {
                FlxG.sound.playMusic(Paths.music('freakyMenu'));
                Conductor.changeBPM(102);
            }
        }
        persistentUpdate = persistentDraw = true;
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('bg'));
		bg.antialiasing = true;
		add(bg);
        mLogo.frames = Paths.getSparrowAtlas('menuLogoBumpin');
        mLogo.animation.addByPrefix('bump', 'menuLogoBumpin', 15, false);
        mLogo.antialiasing = true;
        add(mLogo);
		add(camFollow);
        camFollow.screenCenter();
		add(menuItems);

        var tex = Paths.getSparrowAtlas('main_menu_assets');
		for (i in 0...optionShit.length){
            var menuItem:FlxSprite = new FlxSprite(-300, 60 + i*240);
            menuItem.frames = tex;
            menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24, true);
            menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24, true);
            menuItem.animation.play('idle');
            menuItem.ID = i;
            if(optionShit[i] == "play") {
                #if updatecheck
                    if(TitleState.outdated) menuItem.alpha = 0.5;
                #end
            }
            menuItems.add(menuItem);
            menuItem.antialiasing = true;
        }
        var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "v" + Application.current.meta.get('version'), 12);
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
        FlxG.camera.follow(camFollow, null, 0.06);
        changeItem(1, true);
        super.create();
        super.beatHit();
        FlxTween.tween(mLogo, {y: 50}, 1, { ease: FlxEase.sineOut, onComplete: function(twn:FlxTween){FlxTween.tween(mLogo, {y: 100}, 2, { type: FlxTween.PINGPONG, ease: FlxEase.sineInOut });} });
    }

    var selected:Bool = false;

    override function update(elapsed:Float){
        if (!selected){
            if (controls.UP_P){
                changeItem(-1);
            }
            if (controls.DOWN_P){
                changeItem(1);
            }
            if (controls.BACK){
                FlxG.switchState(new TitleState());
            }
            if (controls.ACCEPT){
                selected = true;
                FlxG.sound.play(Paths.sound('confirmMenu'));
                FlxTween.tween(camFollow, {y: 1500}, 1, {ease: FlxEase.expoIn, onComplete: choose});
            }
        }
        if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;
        super.update(elapsed);
    }
    function changeItem(huh:Int = 0, start:Bool = false){
        if(!start) FlxG.sound.play(Paths.sound('scrollMenu'));
        cur += huh;

        if (cur >= menuItems.length) cur = 0;
        if (cur < 0) cur = menuItems.length - 1;

        menuItems.forEach(function(ass:FlxSprite){
            if(!start) FlxTween.tween(ass, {y: (cur-ass.ID) * FlxG.height * -0.37 + 300, x: 60 + (cur-ass.ID) * -50}, 0.5, {ease: FlxEase.sineOut});
            else {selected = true; FlxTween.tween(ass, {y: (cur-ass.ID) * FlxG.height * -0.37 + 300, x: 60 + (cur-ass.ID) * -50}, 1, {ease: FlxEase.backOut, onComplete: function(twn:FlxTween){selected = false;}});}
        });

        menuItems.forEach(function(spr:FlxSprite){
            spr.animation.play('idle');
            spr.alpha = 0.7;
            if (spr.ID == cur){ 
                spr.animation.play('selected');
                spr.alpha = 1;
            }
        });
    }
    function choose(twn:FlxTween){
        var daChoice:String = optionShit[cur];
        switch (daChoice){
            case 'freeplay':
                FlxG.switchState(new FreeplayState());
                trace("Freeplay Menu Selected");
            case 'play':
                #if updatecheck
                    if(!TitleState.outdated) FlxG.switchState(new online.FNFNetMenu());
                    else FlxG.resetState();
                #else
                    FlxG.switchState(new online.FNFNetMenu());
                #end		
            case 'options':
                FlxG.switchState(new OptionsMenu());
        }
    }
    override function beatHit(){
        super.beatHit();
        mLogo.animation.play('bump');
    }
}
