# HMEngine

Fork of Psych Engine 1.0.4 / Psyche Engine.

## Tính năng

### Gameplay
- Hệ thống rhythm 4 phím
- Health bar, score, combo, rating (Sick/Good/Bad/Shit)
- Scroll speed, BPM changes
- Note types: Normal, Alt Animation, Hey!, Hurt Note, GF Sing, No Animation
- Custom notetypes qua Lua
- Gameplay modifiers: Scroll Type, Scroll Speed, Playback Rate, Health Gain/Loss, Instakill, Practice, Botplay

### Modchart
- 60+ modifiers: confusion, drunk, tornadow, bumpy, bounce, beat, stealth, scale, zoom, rotate, reverse, v.v.
- Lua API: `addModifier`, `setPercent`, `ease`, `set`, `add`, `callback`, `repeater`
- Không cần `addModifier` — tự động thêm khi gọi `ease`/`set`
- Timeline theo beat, ease functions đầy đủ
- Path modifiers: arrowShape, eyeShape, [luapath](command-line)
- false_paradise modifiers: wiggle, vibrate, spiral, counterClockWise

### Lua Scripting
- `linc_luajit` — đầy đủ Lua API
- Sprite/Animation: `makeLuaSprite`, `addAnimation`, `playAnim`, `loadGraphic`
- Tweens: `startTween`, `doTweenX/Y/Angle/Alpha`, `noteTweenX/Y/Angle`
- Camera: `cameraShake`, `cameraFlash`, `cameraFade`, `setCameraScroll`
- Sound: `playMusic`, `playSound`, `soundFadeIn/Out`
- Input: `keyboardJustPressed`, `gamepadAnalogX/Y`
- Save: `initSaveData`, `setDataFromSave`, `flushSaveData`
- Shaders: `initLuaShader`, runtime `.frag`/`.vert`
- File I/O: `getTextFromFile`, `saveFile`, `deleteFile`
- Callbacks đầy đủ: `onCreate`, `onStepHit`, `onBeatHit`, `goodNoteHit`, `onEvent`, `onGameOver`

### HScript
- `hscript-iris` — Haxe scripting trong Lua
- Pre-imported: FlxG, FlxSprite, FlxTween, FlxEase, PlayState, Paths, Conductor, v.v.

### Editors
- Chart Editor
- Character Editor
- Stage Editor
- Week Editor
- Menu Character Editor
- Dialogue Editor
- Dialogue Portrait Editor
- Note Splash Editor

### Options
- Note Colors (per-lane RGB)
- Controls (keyboard + gamepad)
- Adjust Delay & Combo
- Graphics (Low Quality, Anti-Aliasing, Shaders, Framerate)
- Visuals (Note Skin, Note Splash, Hide HUD, Time Bar, Camera Zooms)
- Gameplay (Downscroll, Middlescroll, Ghost Tapping, Hit Windows)
- Language
- Modding

### Other
- Discord Rich Presence
- Mod system (enable/disable, per-mod settings)
- Achievements
- Translations (.lang files)
- Video cutscenes (hxvlc)
- Stage system with Lua callbacks
- Loading screen
- Screenshot plugin
- Crash handler

## Build

```bash
haxelib run lime build windows
```

## Dependencies

- flixel 5.9.0, flixel-addons 3.3.0
- lime 8.1.2
- linc_luajit
- hxvlc 2.1.0
- hxdiscord_rpc 1.2.4
- hscript-iris 1.1.3
- flxanimate, tjson

## Credits

- **Friday Night Funkin'** — ninja_muffin99, PhantomArcade, kawaisprite, evilsk8er
- **Psych Engine** — Shadow Mario, RiverOaken, bbpanzu
- **FunkinModchart** — dotaxel, Swordcube
- Xem thêm [CREDITS.md](CREDITS.md)
