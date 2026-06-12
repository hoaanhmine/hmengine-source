package states.editors;

import backend.MusicBeatState;
import backend.Paths;
import backend.Mods;
import backend.CoolUtil;
import backend.ClientPrefs;
import backend.Conductor;
import backend.Song;
import backend.Difficulty;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;

import openfl.geom.Rectangle;
import openfl.utils.Assets;

import sys.io.File;
import sys.FileSystem;

typedef ModchartEventData =
{
	var type:String;
	var modifier:String;
	var beat:Float;
	var length:Float;
	var value:Float;
	var ease:String;
	var player:Int;
}

class ModchartEditorState extends MusicBeatState
{
	// Song data
	var songName:String = 'test';
	var songPath:String = '';
	var bpm:Float = 100;

	// UI elements
	var topBar:FlxSprite;
	var bottomBar:FlxSprite;
	var dividerV:FlxSprite;
	var topText:FlxText;
	var statusText:FlxText;
	var beatText:FlxText;
	var eventCountText:FlxText;
	var codeText:FlxText;
	var codeBg:FlxSprite;

	// Timeline
	var timelineBg:FlxSprite;
	var timelineBeatWidth:Float = 60;
	var timelineOffset:Float = 0;
	var timelineMarkers:FlxTypedGroup<FlxSprite>;
	var timelineLabels:FlxTypedGroup<FlxText>;
	var timelineEvents:FlxTypedGroup<FlxSprite>;
	var timelineCursor:FlxSprite;

	// Play controls
	var playing:Bool = false;
	var currentBeat:Float = 0;
	var playbackSpeed:Float = 1.0;
	var songLength:Float = 0;

	// Event data
	var events:Array<ModchartEventData> = [];
	var selectedEvent:Int = -1;
	var eventListTexts:FlxTypedGroup<FlxText>;
	var eventListBg:FlxSprite;
	var scrollOffset:Int = 0;
	var maxVisibleEvents:Int = 14;

	var eventListView:FlxSpriteGroup;

	// Editor form
	var formType:Int = 0; // 0=set, 1=ease, 2=add, 3=setAdd
	var formModifier:Int = 0;
	var formBeat:Float = 0;
	var formLength:Float = 4;
	var formValue:Float = 1;
	var formEase:Int = 0;
	var formPlayer:Int = -1;

	// Available modifiers
	static var modifierList:Array<String> = [
		"confusion", "drunk", "tipsy", "tornado", "bumpy", "bounce", "beat",
		"reverse", "stealth", "scale", "rotate", "zoom", "invert",
		"mini", "tiny", "stretch", "dark", "alpha",
		"boost", "brake", "wave", "skew", "asymptote", "attenuate",
		"parabola", "cubic",
		"infinite", "radionic", "carousel", "receptorScroll",
		"arrowShape", "eyeShape",
		"shake", "blink", "flip", "opponentSwap",
		"transformX", "transformY", "transformZ",
		"confusionX", "confusionY", "confusionZ",
		"rotateX", "rotateY", "rotateZ",
		"centerRotateX", "centerRotateY", "centerRotateZ",
		"fieldRotateX", "fieldRotateY", "fieldRotateZ",
		"localRotateX", "localRotateY", "localRotateZ",
		"scrollAngleX", "scrollAngleY", "scrollAngleZ",
		"curvedScrollX", "curvedScrollY",
		"xmod", "randomspeed",
		"sudden", "suddenStart", "suddenEnd", "suddenGlow",
		"hidden", "hiddenStart", "hiddenEnd", "hiddenGlow",
		"sawtooth", "square", "zigzag", "digital", "drugged",
		"wiggle", "vibrate", "spiral", "counterClockWise"
	];

	static var easeList:Array<String> = [
		"linear", "sineIn", "sineOut", "sineInOut",
		"quadIn", "quadOut", "quadInOut",
		"cubeIn", "cubeOut", "cubeInOut",
		"quartIn", "quartOut", "quartInOut",
		"quintIn", "quintOut", "quintInOut",
		"expoIn", "expoOut", "expoInOut",
		"circIn", "circOut", "circInOut",
		"elasticIn", "elasticOut", "elasticInOut",
		"backIn", "backOut", "backInOut",
		"bounceIn", "bounceOut", "bounceInOut",
		"smoothStep", "smootherStep", "pop", "popSmall", "popLarge", "step"
	];

	static var typeList:Array<String> = ["set", "ease", "add", "setAdd", "callback", "repeater"];

	override function create()
	{
		super.create();

		FlxG.camera.bgColor = 0xFF1a1a2e;

		loadSong(songName);

		createUI();
		refreshEventList();
		updateCodePreview();
	}

	function loadSong(name:String)
	{
		var formatted = Paths.formatToSongPath(name);
		var path = Paths.json('songs/$formatted/$formatted');

		if (Assets.exists(path, TEXT))
		{
			var rawJson = Assets.getText(path);
			var songData = Song.parseJSON(rawJson, formatted, 'psych_v1');
			if (songData != null)
			{
				bpm = songData.bpm;
				songName = formatted;
				songLength = 0;
				songPath = Paths.modsJson('songs/$formatted/');
				return;
			}
		}
		bpm = 120;
		songName = name;
	}

	function createUI()
	{
		var uiScale = FlxG.height / 720;

		// Top bar
		topBar = new FlxSprite(0, 0).makeGraphic(FlxG.width, 40, 0xFF16213e);
		topBar.scrollFactor.set();
		add(topBar);

		topText = new FlxText(10, 8, 0, 'Modchart Editor - $songName', 16);
		topText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE);
		topText.scrollFactor.set();
		add(topText);

		beatText = new FlxText(FlxG.width - 200, 8, 190, 'Beat: 0', 16);
		beatText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.CYAN, RIGHT);
		beatText.scrollFactor.set();
		add(beatText);

		// Timeline area
		timelineBg = new FlxSprite(0, 40).makeGraphic(FlxG.width, 50, 0xFF0f3460);
		timelineBg.scrollFactor.set();
		add(timelineBg);

		timelineMarkers = new FlxTypedGroup<FlxSprite>();
		add(timelineMarkers);
		timelineLabels = new FlxTypedGroup<FlxText>();
		add(timelineLabels);
		timelineEvents = new FlxTypedGroup<FlxSprite>();
		add(timelineEvents);
		timelineCursor = new FlxSprite(0, 40).makeGraphic(2, 50, FlxColor.CYAN);
		timelineCursor.scrollFactor.set();
		add(timelineCursor);

		// Event list
		var listY = 90;
		var listH = FlxG.height - listY - 150;

		eventListBg = new FlxSprite(0, listY).makeGraphic(Std.int(FlxG.width * 0.45), Std.int(listH), 0xFF16213e);
		eventListBg.scrollFactor.set();
		add(eventListBg);

		eventListView = new FlxSpriteGroup();
		eventListView.scrollFactor.set();
		add(eventListView);

		var headerText = new FlxText(5, listY + 2, Std.int(eventListBg.width), '# Type    Modifier         Beat   Val', 12);
		headerText.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.YELLOW);
		headerText.scrollFactor.set();
		add(headerText);

		eventListTexts = new FlxTypedGroup<FlxText>();
		add(eventListTexts);

		for (i in 0...maxVisibleEvents)
		{
			var et = new FlxText(5, listY + 18 + i * 16, Std.int(eventListBg.width), '', 12);
			et.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE);
			et.scrollFactor.set();
			eventListTexts.add(et);
		}

		// Divider
		var formX = Std.int(FlxG.width * 0.45);
		dividerV = new FlxSprite(formX, listY).makeGraphic(2, Std.int(listH), 0xFF0f3460);
		dividerV.scrollFactor.set();
		add(dividerV);

		// Editor form
		createForm(formX + 10, listY + 5);

		// Bottom bar
		var codeY = FlxG.height - 150;
		bottomBar = new FlxSprite(0, codeY).makeGraphic(FlxG.width, 150, 0xFF16213e);
		bottomBar.scrollFactor.set();
		add(bottomBar);

		codeBg = new FlxSprite(5, codeY + 5).makeGraphic(FlxG.width - 10, 110, 0xFF0a0a1a);
		codeBg.scrollFactor.set();
		add(codeBg);

		codeText = new FlxText(10, codeY + 8, FlxG.width - 20, '', 10);
		codeText.setFormat(Paths.font("vcr.ttf"), 12, 0xFF88FF88);
		codeText.scrollFactor.set();
		add(codeText);

		// Bottom buttons
		createBottomButtons(codeY);
	}

	function createForm(x:Int, y:Int)
	{
		var labelY = y;
		var stepY = 28;

		var lbl1 = new FlxText(x, labelY, 100, 'Type:', 14);
		lbl1.setFormat(Paths.font("vcr.ttf"), 14, FlxColor.ORANGE);
		lbl1.scrollFactor.set();
		add(lbl1);

		addTypeSelector(x + 60, labelY);

		var lbl2 = new FlxText(x, labelY + stepY, 100, 'Modifier:', 14);
		lbl2.setFormat(Paths.font("vcr.ttf"), 14, FlxColor.ORANGE);
		lbl2.scrollFactor.set();
		add(lbl2);

		addModifierSelector(x + 90, labelY + stepY);

		var lbl3 = new FlxText(x, labelY + stepY * 2, 100, 'Start Beat:', 14);
		lbl3.setFormat(Paths.font("vcr.ttf"), 14, FlxColor.ORANGE);
		lbl3.scrollFactor.set();
		add(lbl3);

		addBeatInput(x + 100, labelY + stepY * 2);

		var lbl4 = new FlxText(x, labelY + stepY * 3, 100, 'Length:', 14);
		lbl4.setFormat(Paths.font("vcr.ttf"), 14, FlxColor.ORANGE);
		lbl4.scrollFactor.set();
		add(lbl4);

		addLengthInput(x + 100, labelY + stepY * 3);

		var lbl5 = new FlxText(x, labelY + stepY * 4, 100, 'Value:', 14);
		lbl5.setFormat(Paths.font("vcr.ttf"), 14, FlxColor.ORANGE);
		lbl5.scrollFactor.set();
		add(lbl5);

		addValueInput(x + 100, labelY + stepY * 4);

		var lbl6 = new FlxText(x, labelY + stepY * 5, 100, 'Ease:', 14);
		lbl6.setFormat(Paths.font("vcr.ttf"), 14, FlxColor.ORANGE);
		lbl6.scrollFactor.set();
		add(lbl6);

		addEaseSelector(x + 65, labelY + stepY * 5);

		var lbl7 = new FlxText(x, labelY + stepY * 6, 100, 'Player:', 14);
		lbl7.setFormat(Paths.font("vcr.ttf"), 14, FlxColor.ORANGE);
		lbl7.scrollFactor.set();
		add(lbl7);

		addPlayerSelector(x + 75, labelY + stepY * 6);

		// Action buttons
		var btnY = labelY + stepY * 7 + 10;
		addFormButton(x, btnY, 'Add Event');
		addFormButton(x + 100, btnY, 'Update', true);
		addFormButton(x + 200, btnY, 'Delete', true);
		addFormButton(x + 300, btnY, 'Clear', true);
	}

	var typeDropdown:PsychUIDropDownMenu;
	var modifierDropdown:PsychUIDropDownMenu;
	var easeDropdown:PsychUIDropDownMenu;
	var playerDropdown:PsychUIDropDownMenu;
	var beatInput:PsychUINumericStepper;
	var lengthInput:PsychUINumericStepper;
	var valueInput:PsychUINumericStepper;

	function addTypeSelector(x:Int, y:Int)
	{
		typeDropdown = new PsychUIDropDownMenu(x, y, typeList, function(id, label)
		{
			formType = id;
		}, 100);
		typeDropdown.scrollFactor.set();
		add(typeDropdown);
	}

	function addModifierSelector(x:Int, y:Int)
	{
		modifierDropdown = new PsychUIDropDownMenu(x, y, modifierList, function(id, label)
		{
			formModifier = id;
		}, 160);
		modifierDropdown.scrollFactor.set();
		add(modifierDropdown);
	}

	function addEaseSelector(x:Int, y:Int)
	{
		easeDropdown = new PsychUIDropDownMenu(x, y, easeList, function(id, label)
		{
			formEase = id;
		}, 140);
		easeDropdown.scrollFactor.set();
		add(easeDropdown);
	}

	function addPlayerSelector(x:Int, y:Int)
	{
		playerDropdown = new PsychUIDropDownMenu(x, y, ['Both (-1)', 'Player 0', 'Player 1'], function(id, label)
		{
			formPlayer = id == 0 ? -1 : id - 1;
		}, 120);
		playerDropdown.scrollFactor.set();
		add(playerDropdown);
	}

	function addBeatInput(x:Int, y:Int)
	{
		beatInput = new PsychUINumericStepper(x, y, 1, 0, 0, 9999, 1, 80);
		beatInput.scrollFactor.set();
		beatInput.onValueChange = function() { formBeat = beatInput.value; };
		add(beatInput);
	}

	function addLengthInput(x:Int, y:Int)
	{
		lengthInput = new PsychUINumericStepper(x, y, 1, 4, 0, 999, 1, 80);
		lengthInput.scrollFactor.set();
		lengthInput.onValueChange = function() { formLength = lengthInput.value; };
		add(lengthInput);
	}

	function addValueInput(x:Int, y:Int)
	{
		valueInput = new PsychUINumericStepper(x, y, 0.1, 1, -999, 999, 2, 80);
		valueInput.scrollFactor.set();
		valueInput.onValueChange = function() { formValue = valueInput.value; };
		add(valueInput);
	}

	function addFormButton(x:Int, y:Int, label:String, ?altColor:Bool = false)
	{
		var btn = new PsychUIButton(x, y, label, null, Std.int(90), 22);
		if (altColor)
		{
			btn.normalStyle.bgColor = 0xFF533483;
			btn.normalStyle.textColor = FlxColor.WHITE;
		}
		btn.scrollFactor.set();
		add(btn);

		switch (label)
		{
			case 'Add Event': btn.onClick = onAddEvent;
			case 'Update': btn.onClick = onUpdateEvent;
			case 'Delete': btn.onClick = onDeleteEvent;
			case 'Clear': btn.onClick = onClearEvents;
		}
	}

	function createBottomButtons(codeY:Int)
	{
		var btnY = codeY + 120;
		var saveBtn = new PsychUIButton(10, btnY, 'Save Script', onSave, 110, 22);
		saveBtn.scrollFactor.set();
		add(saveBtn);

		var loadBtn = new PsychUIButton(130, btnY, 'Load Script', onLoad, 110, 22);
		loadBtn.scrollFactor.set();
		add(loadBtn);

		var playBtn = new PsychUIButton(250, btnY, 'Preview Play', onTogglePlay, 120, 22);
		playBtn.normalStyle.bgColor = 0xFF1b813e;
		playBtn.normalStyle.textColor = FlxColor.WHITE;
		playBtn.scrollFactor.set();
		add(playBtn);

		var backBtn = new PsychUIButton(FlxG.width - 100, btnY, 'Back', onBack, 90, 22);
		backBtn.normalStyle.bgColor = 0xFF8b0000;
		backBtn.normalStyle.textColor = FlxColor.WHITE;
		backBtn.scrollFactor.set();
		add(backBtn);

		statusText = new FlxText(380, btnY + 2, 400, 'Ready', 12);
		statusText.setFormat(Paths.font("vcr.ttf"), 12, 0xFF88FF88);
		statusText.scrollFactor.set();
		add(statusText);

		eventCountText = new FlxText(FlxG.width - 200, btnY + 2, 190, 'Events: 0', 12);
		eventCountText.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.YELLOW, RIGHT);
		eventCountText.scrollFactor.set();
		add(eventCountText);
	}

	// Event operations
	function onAddEvent()
	{
		var evt:ModchartEventData = {
			type: typeList[formType],
			modifier: modifierList[formModifier],
			beat: beatInput.value,
			length: lengthInput.value,
			value: valueInput.value,
			ease: easeList[formEase],
			player: formPlayer
		};
		events.push(evt);
		events.sort(function(a, b) return Std.int(a.beat - b.beat));
		refreshEventList();
		updateCodePreview();
		setStatus('Event added');
	}

	function onUpdateEvent()
	{
		if (selectedEvent < 0 || selectedEvent >= events.length) return;
		var evt = events[selectedEvent];
		evt.type = typeList[formType];
		evt.modifier = modifierList[formModifier];
		evt.beat = beatInput.value;
		evt.length = lengthInput.value;
		evt.value = valueInput.value;
		evt.ease = easeList[formEase];
		evt.player = formPlayer;
		events.sort(function(a, b) return Std.int(a.beat - b.beat));
		refreshEventList();
		updateCodePreview();
		setStatus('Event updated');
	}

	function onDeleteEvent()
	{
		if (selectedEvent < 0 || selectedEvent >= events.length) return;
		events.splice(selectedEvent, 1);
		selectedEvent = -1;
		refreshEventList();
		updateCodePreview();
		setStatus('Event deleted');
	}

	function onClearEvents()
	{
		if (events.length == 0) return;
		events = [];
		selectedEvent = -1;
		refreshEventList();
		updateCodePreview();
		setStatus('All events cleared');
	}

	function selectEvent(index:Int)
	{
		selectedEvent = index;
		if (index >= 0 && index < events.length)
		{
			var evt = events[index];
			var tid = typeList.indexOf(evt.type);
			if (tid >= 0) { typeDropdown.selectedIndex = tid; formType = tid; }
			var mid = modifierList.indexOf(evt.modifier);
			if (mid >= 0) { modifierDropdown.selectedIndex = mid; formModifier = mid; }
			beatInput.value = evt.beat; formBeat = evt.beat;
			lengthInput.value = evt.length; formLength = evt.length;
			valueInput.value = evt.value; formValue = evt.value;
			var eid = easeList.indexOf(evt.ease);
			if (eid >= 0) { easeDropdown.selectedIndex = eid; formEase = eid; }
			playerDropdown.selectedIndex = evt.player == -1 ? 0 : evt.player + 1;
			formPlayer = evt.player;
		}
	}

	function refreshEventList()
	{
		var listY = Std.int(eventListBg.y);
		eventCountText.text = 'Events: ${events.length}';

		for (i in 0...maxVisibleEvents)
		{
			var idx = i + scrollOffset;
			var txt = eventListTexts.members[i];
			if (txt == null) continue;

			if (idx < events.length)
			{
				var evt = events[idx];
				var selected = (idx == selectedEvent) ? '>' : ' ';
				txt.text = '$selected$idx  ${evt.type}  ${evt.modifier}  ${evt.beat}    ${evt.value}';
				txt.color = (idx == selectedEvent) ? FlxColor.CYAN : FlxColor.WHITE;
			}
			else
			{
				txt.text = '';
			}
		}
		updateTimeline();
	}

	function updateTimeline()
	{
		timelineMarkers.clear();
		timelineLabels.clear();
		timelineEvents.clear();

		if (events.length == 0) return;

		var maxBeat = 0;
		for (evt in events)
		{
			var end = evt.beat + evt.length;
			if (end > maxBeat) maxBeat = Std.int(end) + 4;
		}
		maxBeat = Std.int(Math.max(maxBeat, 32));

		var startX = 10;
		var y = timelineBg.y;
		var h = timelineBg.height;

		for (b in 0...Std.int(maxBeat))
		{
			var x = startX + b * timelineBeatWidth - timelineOffset;
			if (x < -timelineBeatWidth || x > FlxG.width + timelineBeatWidth) continue;

			var marker = new FlxSprite(x, y).makeGraphic(1, Std.int(h), 0x33FFFFFF);
			marker.scrollFactor.set();
			timelineMarkers.add(marker);

			if (b % 4 == 0)
			{
				var label = new FlxText(x + 2, y + h - 14, 40, Std.string(b), 10);
				label.setFormat(Paths.font("vcr.ttf"), 10, 0x88FFFFFF);
				label.scrollFactor.set();
				timelineLabels.add(label);
			}
		}

		for (i in 0...events.length)
		{
			var evt = events[i];
			var x = startX + evt.beat * timelineBeatWidth - timelineOffset;
			if (x < -10 || x > FlxG.width + 10) continue;

			var color = getEventColor(evt.type);
			var marker = new FlxSprite(x, y + 5).makeGraphic(8, Std.int(h) - 10, color);
			marker.scrollFactor.set();
			timelineEvents.add(marker);

			if (evt.length > 0 && (evt.type == 'ease' || evt.type == 'add'))
			{
				var endX = startX + (evt.beat + evt.length) * timelineBeatWidth - timelineOffset;
				var w = Std.int(Math.max(endX - x, 4));
				var bar = new FlxSprite(x, y + Std.int(h / 2) - 2).makeGraphic(w, 4, color);
				bar.alpha = 0.5;
				bar.scrollFactor.set();
				timelineEvents.add(bar);
			}
		}
	}

	function getEventColor(type:String):FlxColor
	{
		return switch (type)
		{
			case 'set': 0xFF00FF00;
			case 'ease': 0xFF00AAFF;
			case 'add': 0xFFFFAA00;
			case 'setAdd': 0xFFFF00FF;
			case 'callback': 0xFFFFFFFF;
			case 'repeater': 0xFFFF6666;
			default: 0xFFCCCCCC;
		}
	}

	function updateCodePreview()
	{
		var code = '-- Generated by HMEngine Modchart Editor\n';
		code += 'function onCreatePost()\n';

		var usedMods:Map<String, Bool> = [];
		for (evt in events)
		{
			if (!usedMods.exists(evt.modifier))
			{
				usedMods.set(evt.modifier, true);
				code += '  addModifier("${evt.modifier}")\n';
			}
		}

		code += '\n';
		for (evt in events)
		{
			var playerStr = evt.player == -1 ? '' : ', ${evt.player}';
			switch (evt.type)
			{
				case 'set':
					code += '  ${evt.type}("${evt.modifier}", ${evt.beat}, ${evt.value}$playerStr)\n';
				case 'ease', 'add':
					code += '  ${evt.type}("${evt.modifier}", ${evt.beat}, ${evt.length}, ${evt.value}, "${evt.ease}"$playerStr)\n';
				case 'setAdd':
					code += '  ${evt.type}("${evt.modifier}", ${evt.beat}, ${evt.value}$playerStr)\n';
				case 'callback':
					code += '  callback(${evt.beat}, "cb_${evt.modifier}"$playerStr)\n';
				case 'repeater':
					code += '  repeater(${evt.beat}, ${evt.length}, "rep_${evt.modifier}"$playerStr)\n';
			}
		}

		code += 'end\n';
		codeText.text = code;
	}

	public function setSong(name:String)
	{
		songName = name;
		loadSong(name);
	}

	// Save/Load
	function onSave()
	{
		#if sys
		var savePath = CoolUtil.getSavePath() + '/modcharts/';
		if (!FileSystem.exists(savePath)) FileSystem.createDirectory(savePath);
		var filePath = savePath + songName + '.lua';
		File.saveContent(filePath, codeText.text);
		setStatus('Saved to $filePath');
		#else
		setStatus('Save not supported on this platform');
		#end
	}

	function onLoad()
	{
		#if sys
		var loadPath = CoolUtil.getSavePath() + '/modcharts/' + songName + '.lua';
		if (FileSystem.exists(loadPath))
		{
			var content = File.getContent(loadPath);
			codeText.text = content;
			parseLuaToEvents(content);
			setStatus('Loaded from $loadPath');
		}
		else
		{
			setStatus('No saved modchart found for this song');
		}
		#else
		setStatus('Load not supported on this platform');
		#end
	}

	function parseLuaToEvents(luaCode:String)
	{
		events = [];
		selectedEvent = -1;

		var lines = luaCode.split('\n');
		for (line in lines)
		{
			line = line.trim();
			if (line.length == 0 || line.startsWith('--')) continue;

			for (type in typeList)
			{
				var search = '$type(';
				var pos = line.indexOf(search);
				if (pos < 0) continue;

				var argsStr = line.substring(pos + search.length, line.length - 1);
				if (argsStr.length == 0) continue;

				var parts = [];
				var current = '';
				var inStr = false;
				for (c in argsStr.split(''))
				{
					if (c == '"') { inStr = !inStr; continue; }
					if (c == ',' && !inStr) { parts.push(current.trim()); current = ''; continue; }
					current += c;
				}
				if (current.length > 0) parts.push(current.trim());
				if (parts.length < 2) continue;

				var mod = parts[0];
				var beat = Std.parseFloat(parts[1]);
				if (Math.isNaN(beat)) continue;

				var evt:ModchartEventData = {
					type: type,
					modifier: mod.length > 0 ? mod : 'confusion',
					beat: beat,
					length: 0,
					value: 1,
					ease: 'linear',
					player: -1
				};

				if (type == 'set' || type == 'setAdd')
				{
					if (parts.length > 2) { evt.value = Std.parseFloat(parts[2]); if (Math.isNaN(evt.value)) evt.value = 1; }
					if (parts.length > 3) { evt.player = Std.parseInt(parts[3]); if (evt.player == null) evt.player = -1; }
				}
				else if (type == 'ease' || type == 'add')
				{
					if (parts.length > 2) { evt.length = Std.parseFloat(parts[2]); if (Math.isNaN(evt.length)) evt.length = 4; }
					if (parts.length > 3) { evt.value = Std.parseFloat(parts[3]); if (Math.isNaN(evt.value)) evt.value = 1; }
					if (parts.length > 4) evt.ease = parts[4];
					if (parts.length > 5) { evt.player = Std.parseInt(parts[5]); if (evt.player == null) evt.player = -1; }
				}

				events.push(evt);
				break;
			}
		}

		events.sort(function(a, b) return Std.int(a.beat - b.beat));
		refreshEventList();
		updateCodePreview();
	}

	// Playback controls
	function onTogglePlay()
	{
		if (playing)
		{
			playing = false;
			FlxG.sound.music.pause();
			setStatus('Preview paused');
		}
		else
		{
			if (FlxG.sound.music == null || !FlxG.sound.music.playing)
			{
				startPreviewSong();
			}
			playing = true;
			FlxG.sound.music.play();
			setStatus('Preview playing');
		}
	}

	function startPreviewSong()
	{
		var formatted = Paths.formatToSongPath(songName);
		FlxG.sound.playMusic(Paths.inst(formatted), 1, false);
		songLength = FlxG.sound.music.length;
	}

	function onBack()
	{
		if (playing) FlxG.sound.music.stop();
		MusicBeatState.switchState(new MasterEditorMenu());
	}

	override function update(elapsed:Float)
	{
		if (playing && FlxG.sound.music != null && FlxG.sound.music.playing)
		{
			currentBeat = (FlxG.sound.music.time / 1000) * (bpm / 60);
			beatText.text = 'Beat: ${Std.int(currentBeat)}';
			timelineCursor.x = 10 + currentBeat * timelineBeatWidth - timelineOffset;
		}

		// Keyboard shortcuts
		if (FlxG.keys.justPressed.SPACE)
		{
			onTogglePlay();
		}
		if (FlxG.keys.justPressed.ESCAPE)
		{
			onBack();
		}
		if (FlxG.keys.justPressed.DELETE || FlxG.keys.justPressed.BACKSPACE)
		{
			onDeleteEvent();
		}

		// Scroll event list
		if (FlxG.keys.justPressed.PAGEUP) { scrollOffset = Std.int(Math.max(0, scrollOffset - maxVisibleEvents)); refreshEventList(); }
		if (FlxG.keys.justPressed.PAGEDOWN) { scrollOffset += maxVisibleEvents; refreshEventList(); }

		// Timeline scroll
		if (FlxG.keys.pressed.LEFT) { timelineOffset = Math.max(0, timelineOffset - elapsed * 200); updateTimeline(); }
		if (FlxG.keys.pressed.RIGHT) { timelineOffset += elapsed * 200; updateTimeline(); }

		// Number keys to select events (1-9, 0)
		var numKey:Int = -1;
		if (FlxG.keys.justPressed.ONE) numKey = 0;
		else if (FlxG.keys.justPressed.TWO) numKey = 1;
		else if (FlxG.keys.justPressed.THREE) numKey = 2;
		else if (FlxG.keys.justPressed.FOUR) numKey = 3;
		else if (FlxG.keys.justPressed.FIVE) numKey = 4;
		else if (FlxG.keys.justPressed.SIX) numKey = 5;
		else if (FlxG.keys.justPressed.SEVEN) numKey = 6;
		else if (FlxG.keys.justPressed.EIGHT) numKey = 7;
		else if (FlxG.keys.justPressed.NINE) numKey = 8;
		else if (FlxG.keys.justPressed.ZERO) numKey = 9;
		if (numKey >= 0)
		{
			var idx = numKey + scrollOffset;
			if (idx >= 0 && idx < events.length)
			{
				selectEvent(idx);
				refreshEventList();
			}
		}

		// Up/Down to navigate events
		if (FlxG.keys.justPressed.UP)
		{
			selectedEvent = Std.int(Math.max(0, selectedEvent - 1));
			selectEvent(selectedEvent);
			refreshEventList();
		}
		if (FlxG.keys.justPressed.DOWN)
		{
			selectedEvent = Std.int(Math.min(events.length - 1, selectedEvent + 1));
			selectEvent(selectedEvent);
			refreshEventList();
		}

		super.update(elapsed);
	}

	function setStatus(msg:String)
	{
		if (statusText != null) statusText.text = msg;
	}
}
