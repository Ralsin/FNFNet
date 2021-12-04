package;

import online.EventState;
import openfl.display.BitmapData;
#if desktop
import sys.io.File;
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;

using StringTools;

class MainMenuState extends MusicBeatState
{
    var cur:Int = 0;
    var camFollow:FlxObject = new FlxObject(0, 0, 1, 1);
    var menuItems:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
    var optionShit:Array<String> = ['freeplay', 'play', 'account', 'options'];
    var mLogo:FlxSprite = new FlxSprite(650, -500);
    public static var exemel:String;
	public static var char:BitmapData;
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
            var menuItem:FlxSprite = new FlxSprite(-300, 30 + i*230);
            menuItem.frames = tex;
            menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24, true);
            menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24, true);
            menuItem.animation.play('idle');
            menuItem.ID = i;
            menuItems.add(menuItem);
            menuItem.antialiasing = true;
        }
        var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "v" + Application.current.meta.get('version'));
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
        var greeting:FlxText = new FlxText(0, FlxG.height - 35, FlxG.width, "Welcome, "+FlxG.save.data.username+"!");
		greeting.setFormat("VCR OSD Mono", 30, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(greeting);

        FlxG.camera.follow(camFollow, null, 0.06);
        changeItem(1, true);
        super.create();
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
                if((optionShit[cur] == "account" || optionShit[cur] == "fnfnet") && TitleState.outdated){
					FlxG.sound.play(Paths.sound("no"));
					return;
                }
                selected = true;
                FlxG.sound.play(Paths.sound('confirmMenu'));
                FlxTween.tween(camFollow, {y: 1500}, 1, {ease: FlxEase.expoIn, onComplete: choose});
            }
			if (FlxG.keys.justPressed.NINE) LoadingState.loadAndSwitchState(new online.Login());
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
            if(!start) {
                FlxTween.globalManager.cancelTweensOf(ass);
                FlxTween.tween(ass, {y: (cur-ass.ID) * FlxG.height * -0.37 + 300, x: 60 + (cur-ass.ID) * -50}, 0.5, {ease: FlxEase.sineOut, onUpdate: function(twn:FlxTween){if(ass.y>FlxG.height+100){ass.alpha = 0;}else{if(ass.ID==cur) ass.alpha = 1; else ass.alpha = 0.7;}}});
            }
            else {selected = true; FlxTween.tween(ass, {y: (cur-ass.ID) * FlxG.height * -0.37 + 300, x: 60 + (cur-ass.ID) * -50}, 1, {ease: FlxEase.backOut, onStart: function(twn:FlxTween){if(ass.ID==cur) ass.alpha = 1; else ass.alpha = 0.7;}, onComplete: function(twn:FlxTween){selected = false;}});}
        });
        menuItems.forEach(function(spr:FlxSprite){
            if (spr.ID == cur){ 
                spr.animation.play('selected');
            } else {spr.animation.play('idle');}
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
            case 'account':
				#if updatecheck
				    if(!TitleState.outdated) FlxG.switchState(!FlxG.save.data.loggedin?new online.Login():new online.Account());		
				    else FlxG.resetState();
                #else
				    FlxG.switchState(!FlxG.save.data.loggedin?new online.Login():new online.Account());	
				#end
        }
    }
    override function beatHit(){
        super.beatHit();
        mLogo.animation.play('bump');
    }
}
