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
import flixel.sound.FlxSound;

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
	public static var openFromSong:String = '';
	var songName:String = 'test';
	var songPath:String = '';
	var bpm:Float = 100;
	var songNotes:Array<{beat:Float, lane:Int, susLength:Float}> = [];
	var vocals:FlxSound;

	// UI
	var topBar:FlxSprite;
	var topText:FlxText;
	var statusText:FlxText;
	var beatText:FlxText;
	var eventCountText:FlxText;
	var codeText:FlxText;
	var codeBg:FlxSprite;

	// Grid (note preview)
	var gridBg:FlxSprite;
	var gridNotes:FlxTypedGroup<FlxSprite>;
	var gridStrum:FlxTypedGroup<FlxSprite>;
	var gridPlayhead:FlxSprite;
	var gridX:Float = 0;
	var gridY:Float = 95;
	var gridH:Float;
	var laneW:Int = 32;
	var laneGap:Int = 4;
	var gridScrollY:Float = 0;

	// Timeline
	var timelineBg:FlxSprite;
	var timelineBeatWidth:Float = 60;
	var timelineOffset:Float = 0;
	var timelineMarkers:FlxTypedGroup<FlxSprite>;
	var timelineLabels:FlxTypedGroup<FlxText>;
	var timelineEvents:FlxTypedGroup<FlxSprite>;
	var timelineCursor:FlxSprite;
	var playheadArrow:FlxSprite;

	// Playback
	var playing:Bool = false;
	var currentBeat:Float = 0;
	var cursorX:Float = 10;
	var songLength:Float = 0;

	// Events
	var events:Array<ModchartEventData> = [];
	var selectedEvent:Int = -1;
	var eventListTexts:FlxTypedGroup<FlxText>;
	var eventListBg:FlxSprite;
	var scrollOffset:Int = 0;
	var maxVisibleEvents:Int = 10;
	var dragging:Bool = false;
	var eventListView:FlxSpriteGroup;

	// Form
	var formType:Int = 0;
	var formModifier:Int = 0;
	var formBeat:Float = 0;
	var formLength:Float = 4;
	var formValue:Float = 1;
	var formEase:Int = 0;
	var formPlayer:Int = -1;
	var typeDropdown:PsychUIDropDownMenu;
	var modifierDropdown:PsychUIDropDownMenu;
	var easeDropdown:PsychUIDropDownMenu;
	var playerDropdown:PsychUIDropDownMenu;
	var beatInput:PsychUINumericStepper;
	var lengthInput:PsychUINumericStepper;
	var valueInput:PsychUINumericStepper;

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

		if (openFromSong.length > 0)
		{
			songName = openFromSong;
			openFromSong = '';
		}
		loadSong(songName);
		createUI();
		loadSongNotes();
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
		// Top bar
		topBar = new FlxSprite(0, 0).makeGraphic(FlxG.width, 40, 0xFF16213e);
		topBar.scrollFactor.set();
		add(topBar);

		topText = new FlxText(10, 8, 0, 'Modchart Editor - $songName', 16);
		topText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE);
		topText.scrollFactor.set();
		add(topText);

		beatText = new FlxText(FlxG.width - 260, 8, 120, 'Beat: 0', 16);
		beatText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.CYAN, RIGHT);
		beatText.scrollFactor.set();
		add(beatText);

		// Timeline
		timelineBg = new FlxSprite(0, 40).makeGraphic(FlxG.width, 50, 0xFF0f3460);
		timelineBg.scrollFactor.set();
		add(timelineBg);

		timelineMarkers = new FlxTypedGroup<FlxSprite>();
		add(timelineMarkers);
		timelineLabels = new FlxTypedGroup<FlxText>();
		add(timelineLabels);
		timelineEvents = new FlxTypedGroup<FlxSprite>();
		add(timelineEvents);
		timelineCursor = new FlxSprite(10, 40).makeGraphic(4, 50, 0xFFFF4444);
		timelineCursor.scrollFactor.set();
		add(timelineCursor);
		playheadArrow = new FlxSprite(10, 36).makeGraphic(10, 8, 0xFFFF4444);
		playheadArrow.scrollFactor.set();
		add(playheadArrow);

		// Grid (note preview) - left side
		gridH = FlxG.height - 95 - 150;
		gridBg = new FlxSprite(0, gridY).makeGraphic(Std.int(FlxG.width * 0.45), Std.int(gridH), 0xFF0a0a1a);
		gridBg.scrollFactor.set();
		add(gridBg);
		gridX = gridBg.x;

		gridStrum = new FlxTypedGroup<FlxSprite>();
		add(gridStrum);
		for (i in 0...4)
		{
			var sx = Std.int(gridX + 10 + i * (laneW + laneGap));
			var s = new FlxSprite(sx, Std.int(gridY + gridH * 0.5) - 2).makeGraphic(laneW, 4, getLaneColor(i));
			s.scrollFactor.set();
			gridStrum.add(s);
		}

		gridPlayhead = new FlxSprite(gridX, Std.int(gridY + gridH * 0.5)).makeGraphic(Std.int(FlxG.width * 0.45), 2, 0xFFFFFFFF);
		gridPlayhead.scrollFactor.set();
		gridPlayhead.alpha = 0.7;
		add(gridPlayhead);

		gridNotes = new FlxTypedGroup<FlxSprite>();
		add(gridNotes);

		// Event list - under grid
		var listX = 0;
		var listY = Std.int(gridY + gridH);
		var listH = 150;
		eventListBg = new FlxSprite(listX, listY).makeGraphic(Std.int(FlxG.width * 0.45), listH, 0xFF16213e);
		eventListBg.scrollFactor.set();
		add(eventListBg);

		var headerText = new FlxText(5, listY + 2, Std.int(eventListBg.width), '# Type       Modifier        Beat', 11);
		headerText.setFormat(Paths.font("vcr.ttf"), 11, FlxColor.YELLOW);
		headerText.scrollFactor.set();
		add(headerText);

		eventListTexts = new FlxTypedGroup<FlxText>();
		add(eventListTexts);
		for (i in 0...maxVisibleEvents)
		{
			var et = new FlxText(5, listY + 16 + i * 13, Std.int(eventListBg.width), '', 11);
			et.setFormat(Paths.font("vcr.ttf"), 11, FlxColor.WHITE);
			et.scrollFactor.set();
			eventListTexts.add(et);
		}

		// Right panel - form
		var formX = Std.int(FlxG.width * 0.45);
		var divider = new FlxSprite(formX, gridY).makeGraphic(2, Std.int(gridH + 150), 0xFF0f3460);
		divider.scrollFactor.set();
		add(divider);
		createForm(formX + 10, Std.int(gridY) + 5);

		// Code preview at bottom
		var codeY = FlxG.height - 150;
		codeBg = new FlxSprite(0, codeY).makeGraphic(FlxG.width, 150, 0xFF16213e);
		codeBg.scrollFactor.set();
		add(codeBg);

		codeText = new FlxText(10, codeY + 2, FlxG.width - 20, '', 10);
		codeText.setFormat(Paths.font("vcr.ttf"), 11, 0xFF88FF88);
		codeText.scrollFactor.set();
		add(codeText);

		createBottomButtons(codeY);
	}

	function createForm(x:Int, y:Int)
	{
		var stepY = 26;
		var lblW = 70;

		var lbl1 = new FlxText(x, y, lblW, 'Type:', 12);
		lbl1.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.ORANGE);
		lbl1.scrollFactor.set(); add(lbl1);
		typeDropdown = new PsychUIDropDownMenu(x + lblW, y - 2, typeList, function(id, l) { formType = id; }, 130);
		typeDropdown.scrollFactor.set(); add(typeDropdown);

		var lbl2 = new FlxText(x, y + stepY, lblW, 'Modifier:', 12);
		lbl2.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.ORANGE);
		lbl2.scrollFactor.set(); add(lbl2);
		modifierDropdown = new PsychUIDropDownMenu(x + lblW, y + stepY - 2, modifierList, function(id, l) { formModifier = id; }, 160);
		modifierDropdown.scrollFactor.set(); add(modifierDropdown);

		var lbl3 = new FlxText(x, y + stepY * 2, lblW, 'Beat:', 12);
		lbl3.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.ORANGE);
		lbl3.scrollFactor.set(); add(lbl3);
		beatInput = new PsychUINumericStepper(x + lblW, y + stepY * 2, 1, 0, 0, 9999, 1, 80);
		beatInput.scrollFactor.set();
		beatInput.onValueChange = function() { formBeat = beatInput.value; };
		add(beatInput);

		var lbl4 = new FlxText(x, y + stepY * 3, lblW, 'Len:', 12);
		lbl4.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.ORANGE);
		lbl4.scrollFactor.set(); add(lbl4);
		lengthInput = new PsychUINumericStepper(x + lblW, y + stepY * 3, 1, 4, 0, 999, 1, 80);
		lengthInput.scrollFactor.set();
		lengthInput.onValueChange = function() { formLength = lengthInput.value; };
		add(lengthInput);

		var lbl5 = new FlxText(x, y + stepY * 4, lblW, 'Val:', 12);
		lbl5.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.ORANGE);
		lbl5.scrollFactor.set(); add(lbl5);
		valueInput = new PsychUINumericStepper(x + lblW, y + stepY * 4, 0.1, 1, -999, 999, 2, 80);
		valueInput.scrollFactor.set();
		valueInput.onValueChange = function() { formValue = valueInput.value; };
		add(valueInput);

		var lbl6 = new FlxText(x, y + stepY * 5, lblW, 'Ease:', 12);
		lbl6.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.ORANGE);
		lbl6.scrollFactor.set(); add(lbl6);
		easeDropdown = new PsychUIDropDownMenu(x + lblW, y + stepY * 5 - 2, easeList, function(id, l) { formEase = id; }, 140);
		easeDropdown.scrollFactor.set(); add(easeDropdown);

		var lbl7 = new FlxText(x, y + stepY * 6, lblW, 'Player:', 12);
		lbl7.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.ORANGE);
		lbl7.scrollFactor.set(); add(lbl7);
		playerDropdown = new PsychUIDropDownMenu(x + lblW, y + stepY * 6 - 2, ['Both (-1)', 'Player 0', 'Player 1'], function(id, l) {
			formPlayer = id == 0 ? -1 : id - 1;
		}, 100);
		playerDropdown.scrollFactor.set(); add(playerDropdown);

		var btnY = y + stepY * 7 + 6;
		addFormButton(x, btnY, 'Add Event');
		addFormButton(x + 100, btnY, 'Update', true);
		addFormButton(x + 200, btnY, 'Delete', true);
		addFormButton(x + 300, btnY, 'Clear', true);
	}

	function addFormButton(x:Int, y:Int, label:String, ?altColor:Bool = false)
	{
		var btn = new PsychUIButton(x, y, label, null, Std.int(85), 22);
		if (altColor) { btn.normalStyle.bgColor = 0xFF533483; btn.normalStyle.textColor = FlxColor.WHITE; }
		btn.scrollFactor.set(); add(btn);
		switch (label) {
			case 'Add Event': btn.onClick = onAddEvent;
			case 'Update': btn.onClick = onUpdateEvent;
			case 'Delete': btn.onClick = onDeleteEvent;
			case 'Clear': btn.onClick = onClearEvents;
		}
	}

	function createBottomButtons(codeY:Int)
	{
		var btnY = codeY + 125;
		var saveBtn = new PsychUIButton(10, btnY, 'Save Script', onSave, 110, 20);
		saveBtn.scrollFactor.set(); add(saveBtn);
		var loadBtn = new PsychUIButton(130, btnY, 'Load Script', onLoad, 110, 20);
		loadBtn.scrollFactor.set(); add(loadBtn);
		var playBtn = new PsychUIButton(250, btnY, 'Play', onTogglePlay, 80, 20);
		playBtn.normalStyle.bgColor = 0xFF1b813e; playBtn.normalStyle.textColor = FlxColor.WHITE;
		playBtn.scrollFactor.set(); add(playBtn);
		var backBtn = new PsychUIButton(FlxG.width - 90, btnY, 'Back', onBack, 80, 20);
		backBtn.normalStyle.bgColor = 0xFF8b0000; backBtn.normalStyle.textColor = FlxColor.WHITE;
		backBtn.scrollFactor.set(); add(backBtn);
		statusText = new FlxText(340, btnY + 2, 300, 'Ready', 11);
		statusText.setFormat(Paths.font("vcr.ttf"), 11, 0xFF88FF88);
		statusText.scrollFactor.set(); add(statusText);
		eventCountText = new FlxText(FlxG.width - 180, btnY + 2, 170, 'Events: 0', 11);
		eventCountText.setFormat(Paths.font("vcr.ttf"), 11, FlxColor.YELLOW, RIGHT);
		eventCountText.scrollFactor.set(); add(eventCountText);
	}

	function getLaneColor(lane:Int):FlxColor
	{
		return switch (lane) { case 0: 0xFFFF0000; case 1: 0xFF0000FF; case 2: 0xFF00FF00; default: 0xFFFFFF00; }
	}

	function loadSongNotes()
	{
		songNotes = [];
		gridNotes.clear();

		var formatted = Paths.formatToSongPath(songName);
		var path = Paths.json('songs/$formatted/$formatted');
		if (!Assets.exists(path, TEXT)) return;

		var rawJson = Assets.getText(path);
		var songData = Song.parseJSON(rawJson, formatted, 'psych_v1');
		if (songData == null || songData.notes == null) return;

		for (section in songData.notes)
		{
			for (note in section.sectionNotes)
			{
				var strumTime:Float = note[0];
				var noteData:Int = Std.int(note[1]) % 4;
				var sus:Float = (note[2] != null && Std.isOfType(note[2], Float)) ? note[2] : 0;
				var beat = strumTime / 1000 * (bpm / 60);
				songNotes.push({beat: beat, lane: noteData, susLength: sus});
			}
		}
	}

	function updateGrid(elapsed:Float)
	{
		if (gridNotes == null) return;

		var centerY = Std.int(gridY + gridH * 0.5);
		var beatRange = 8;
		var pxPerBeat = gridH / beatRange;
		gridNotes.clear();

		for (nd in songNotes)
		{
			var diff = nd.beat - currentBeat;
			if (diff < -beatRange * 0.5 || diff > beatRange * 0.5) continue;

			var noteY = centerY + diff * pxPerBeat;
			if (noteY < gridY - 20 || noteY > gridY + gridH + 20) continue;

			var sx = Std.int(gridX + 10 + nd.lane * (laneW + laneGap));
			var noteSpr = new FlxSprite(sx, Std.int(noteY) - 4).makeGraphic(laneW - 2, 8, getLaneColor(nd.lane));
			noteSpr.scrollFactor.set();
			noteSpr.alpha = 1 - Math.abs(diff) / beatRange;
			gridNotes.add(noteSpr);
		}
	}

	// --- Event operations ---
	function onAddEvent()
	{
		var evt:ModchartEventData = {
			type: typeList[formType], modifier: modifierList[formModifier],
			beat: beatInput.value, length: lengthInput.value,
			value: valueInput.value, ease: easeList[formEase], player: formPlayer
		};
		events.push(evt);
		events.sort(function(a, b) return Std.int(a.beat - b.beat));
		refreshEventList(); updateCodePreview();
		setStatus('Event added');
	}

	function onUpdateEvent()
	{
		if (selectedEvent < 0 || selectedEvent >= events.length) return;
		var evt = events[selectedEvent];
		evt.type = typeList[formType]; evt.modifier = modifierList[formModifier];
		evt.beat = beatInput.value; evt.length = lengthInput.value;
		evt.value = valueInput.value; evt.ease = easeList[formEase]; evt.player = formPlayer;
		events.sort(function(a, b) return Std.int(a.beat - b.beat));
		refreshEventList(); updateCodePreview();
		setStatus('Event updated');
	}

	function onDeleteEvent()
	{
		if (selectedEvent < 0 || selectedEvent >= events.length) return;
		events.splice(selectedEvent, 1);
		selectedEvent = -1;
		refreshEventList(); updateCodePreview();
		setStatus('Event deleted');
	}

	function onClearEvents()
	{
		if (events.length == 0) return;
		events = []; selectedEvent = -1;
		refreshEventList(); updateCodePreview();
		setStatus('All events cleared');
	}

	function selectEvent(index:Int)
	{
		selectedEvent = index;
		if (index >= 0 && index < events.length)
		{
			var evt = events[index];
			var tid = typeList.indexOf(evt.type); if (tid >= 0) { typeDropdown.selectedIndex = tid; formType = tid; }
			var mid = modifierList.indexOf(evt.modifier); if (mid >= 0) { modifierDropdown.selectedIndex = mid; formModifier = mid; }
			beatInput.value = evt.beat; formBeat = evt.beat;
			lengthInput.value = evt.length; formLength = evt.length;
			valueInput.value = evt.value; formValue = evt.value;
			var eid = easeList.indexOf(evt.ease); if (eid >= 0) { easeDropdown.selectedIndex = eid; formEase = eid; }
			playerDropdown.selectedIndex = evt.player == -1 ? 0 : evt.player + 1;
			formPlayer = evt.player;
		}
	}

	function refreshEventList()
	{
		eventCountText.text = 'Events: ${events.length}';
		for (i in 0...maxVisibleEvents)
		{
			var idx = i + scrollOffset;
			var txt = eventListTexts.members[i];
			if (txt == null) continue;
			if (idx < events.length)
			{
				var evt = events[idx];
				txt.text = ((idx == selectedEvent) ? '>' : ' ') + '$idx ${evt.type} ${evt.modifier} ${evt.beat}';
				txt.color = (idx == selectedEvent) ? FlxColor.CYAN : FlxColor.WHITE;
			}
			else txt.text = '';
		}
		updateTimeline();
	}

	function updateTimeline()
	{
		timelineMarkers.clear(); timelineLabels.clear(); timelineEvents.clear();
		if (events.length == 0) return;

		var maxBeat = 0;
		for (evt in events) { var end = evt.beat + evt.length; if (end > maxBeat) maxBeat = Std.int(end) + 4; }
		maxBeat = Std.int(Math.max(maxBeat, 32));

		var startX = 10; var y = timelineBg.y; var h = timelineBg.height;
		for (b in 0...Std.int(maxBeat))
		{
			var x = startX + b * timelineBeatWidth - timelineOffset;
			if (x < -timelineBeatWidth || x > FlxG.width + timelineBeatWidth) continue;
			var marker = new FlxSprite(x, y).makeGraphic(1, Std.int(h), 0x33FFFFFF);
			marker.scrollFactor.set(); timelineMarkers.add(marker);
			if (b % 4 == 0) {
				var label = new FlxText(x + 2, y + h - 14, 40, Std.string(b), 10);
				label.setFormat(Paths.font("vcr.ttf"), 10, 0x88FFFFFF);
				label.scrollFactor.set(); timelineLabels.add(label);
			}
		}

		for (i in 0...events.length)
		{
			var evt = events[i];
			var x = startX + evt.beat * timelineBeatWidth - timelineOffset;
			if (x < -10 || x > FlxG.width + 10) continue;
			var isSelected = (i == selectedEvent);
			var color = getEventColor(evt.type);
			var marker = new FlxSprite(x, y + 5).makeGraphic(isSelected ? 12 : 8, Std.int(h) - 10, color);
			marker.scrollFactor.set(); timelineEvents.add(marker);
			if (isSelected) {
				var border = new FlxSprite(x - 2, y + 3).makeGraphic(16, Std.int(h) - 6, 0xFFFFFFFF);
				border.alpha = 0.4; border.scrollFactor.set(); timelineEvents.add(border);
			}
			if (evt.length > 0 && (evt.type == 'ease' || evt.type == 'add')) {
				var endX = startX + (evt.beat + evt.length) * timelineBeatWidth - timelineOffset;
				var bar = new FlxSprite(x, y + Std.int(h / 2) - 2).makeGraphic(Std.int(Math.max(endX - x, 4)), 4, color);
				bar.alpha = isSelected ? 0.8 : 0.5; bar.scrollFactor.set(); timelineEvents.add(bar);
			}
		}
	}

	function getEventColor(type:String):FlxColor
	{
		return switch (type) {
			case 'set': 0xFF00FF00; case 'ease': 0xFF00AAFF; case 'add': 0xFFFFAA00;
			case 'setAdd': 0xFFFF00FF; case 'callback': 0xFFFFFFFF; case 'repeater': 0xFFFF6666;
			default: 0xFFCCCCCC;
		}
	}

	function updateCodePreview()
	{
		var code = '-- HMEngine Modchart\nfunction onCreatePost()\n';
		var usedMods:Map<String, Bool> = [];
		for (evt in events) {
			if (!usedMods.exists(evt.modifier)) { usedMods.set(evt.modifier, true); code += '  addModifier("${evt.modifier}")\n'; }
		}
		code += '\n';
		for (evt in events) {
			var p = evt.player == -1 ? '' : ', ${evt.player}';
			switch (evt.type) {
				case 'set', 'setAdd': code += '  ${evt.type}("${evt.modifier}", ${evt.beat}, ${evt.value}$p)\n';
				case 'ease', 'add': code += '  ${evt.type}("${evt.modifier}", ${evt.beat}, ${evt.length}, ${evt.value}, "${evt.ease}"$p)\n';
				case 'callback': code += '  callback(${evt.beat}, "cb_${evt.modifier}"$p)\n';
				case 'repeater': code += '  repeater(${evt.beat}, ${evt.length}, "rep_${evt.modifier}"$p)\n';
			}
		}
		code += 'end\n';
		codeText.text = code;
	}

	public function setSong(name:String) { songName = name; loadSong(name); }

	function onSave()
	{
		#if sys
		var savePath = CoolUtil.getSavePath() + '/modcharts/';
		if (!FileSystem.exists(savePath)) FileSystem.createDirectory(savePath);
		File.saveContent(savePath + songName + '.lua', codeText.text);
		setStatus('Saved');
		#else
		setStatus('Save unsupported');
		#end
	}

	function onLoad()
	{
		#if sys
		var loadPath = CoolUtil.getSavePath() + '/modcharts/' + songName + '.lua';
		if (FileSystem.exists(loadPath)) {
			codeText.text = File.getContent(loadPath);
			parseLuaToEvents(codeText.text);
			setStatus('Loaded');
		} else setStatus('No saved modchart');
		#else
		setStatus('Load unsupported');
		#end
	}

	function parseLuaToEvents(luaCode:String)
	{
		events = []; selectedEvent = -1;
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
				for (c in argsStr.split('')) {
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
					type: type, modifier: mod.length > 0 ? mod : 'confusion',
					beat: beat, length: 0, value: 1, ease: 'linear', player: -1
				};
				if (type == 'set' || type == 'setAdd') {
					if (parts.length > 2) { evt.value = Std.parseFloat(parts[2]); if (Math.isNaN(evt.value)) evt.value = 1; }
					if (parts.length > 3) { var p:Null<Int> = Std.parseInt(parts[3]); evt.player = (p != null) ? p : -1; }
				} else if (type == 'ease' || type == 'add') {
					if (parts.length > 2) { evt.length = Std.parseFloat(parts[2]); if (Math.isNaN(evt.length)) evt.length = 4; }
					if (parts.length > 3) { evt.value = Std.parseFloat(parts[3]); if (Math.isNaN(evt.value)) evt.value = 1; }
					if (parts.length > 4) evt.ease = parts[4];
					if (parts.length > 5) { var p:Null<Int> = Std.parseInt(parts[5]); evt.player = (p != null) ? p : -1; }
				}
				events.push(evt);
				break;
			}
		}
		events.sort(function(a, b) return Std.int(a.beat - b.beat));
		refreshEventList(); updateCodePreview();
	}

	// Playback
	function onTogglePlay()
	{
		if (playing)
		{
			playing = false;
			if (FlxG.sound.music != null) FlxG.sound.music.pause();
			if (vocals != null) vocals.pause();
			setStatus('Paused');
		}
		else
		{
			if (FlxG.sound.music == null || !FlxG.sound.music.playing) startPreviewSong();
			playing = true;
			if (FlxG.sound.music != null) FlxG.sound.music.play();
			if (vocals != null) { vocals.play(); vocals.time = FlxG.sound.music.time; }
			setStatus('Playing');
		}
	}

	function startPreviewSong()
	{
		var formatted = Paths.formatToSongPath(songName);
		FlxG.sound.playMusic(Paths.inst(formatted), 1, false);
		songLength = FlxG.sound.music.length;

		if (vocals != null) { vocals.stop(); vocals.destroy(); }
		try
		{
			var voicePath = Paths.voices(formatted);
			vocals = new FlxSound().loadEmbedded(voicePath, false, true);
			FlxG.sound.list.add(vocals);
		}
		catch (e:Dynamic)
		{
			vocals = null;
		}
	}

	function onBack()
	{
		if (playing) { if (FlxG.sound.music != null) FlxG.sound.music.stop(); if (vocals != null) vocals.stop(); }
		if (vocals != null) { vocals.stop(); vocals.destroy(); }
		MusicBeatState.switchState(new MasterEditorMenu());
	}

	override function update(elapsed:Float)
	{
		if (playing && FlxG.sound.music != null && FlxG.sound.music.playing)
		{
			currentBeat = (FlxG.sound.music.time / 1000) * (bpm / 60);
			if (vocals != null && vocals.playing) vocals.time = FlxG.sound.music.time;
		}

		cursorX = 10 + currentBeat * timelineBeatWidth - timelineOffset;
		timelineCursor.x = cursorX; timelineCursor.y = 40;
		playheadArrow.x = cursorX - 3; playheadArrow.y = 36;
		beatText.text = 'Beat: ${Math.floor(currentBeat * 10) / 10}';
		updateGrid(elapsed);

		if (FlxG.keys.justPressed.SPACE) onTogglePlay();
		if (FlxG.keys.justPressed.ESCAPE) onBack();
		if (FlxG.keys.justPressed.DELETE || FlxG.keys.justPressed.BACKSPACE) onDeleteEvent();
		if (FlxG.keys.justPressed.PAGEUP) { scrollOffset = Std.int(Math.max(0, scrollOffset - maxVisibleEvents)); refreshEventList(); }
		if (FlxG.keys.justPressed.PAGEDOWN) { scrollOffset += maxVisibleEvents; refreshEventList(); }
		if (FlxG.keys.pressed.LEFT) { timelineOffset = Math.max(0, timelineOffset - elapsed * 200); updateTimeline(); }
		if (FlxG.keys.pressed.RIGHT) { timelineOffset += elapsed * 200; updateTimeline(); }

		// Click on timeline
		if (FlxG.mouse.justPressed && FlxG.mouse.y >= timelineBg.y && FlxG.mouse.y < timelineBg.y + timelineBg.height)
		{
			var clickBeat = (FlxG.mouse.x + timelineOffset - 10) / timelineBeatWidth;
			currentBeat = Math.max(0, clickBeat);
			if (playing && FlxG.sound.music != null) FlxG.sound.music.time = (currentBeat * 60 / bpm) * 1000;
			var hitIdx = -1;
			for (i in 0...events.length) {
				var ex = 10 + events[i].beat * timelineBeatWidth - timelineOffset;
				if (FlxG.mouse.x >= ex - 6 && FlxG.mouse.x <= ex + 6) { hitIdx = i; break; }
			}
			if (hitIdx >= 0) { selectEvent(hitIdx); refreshEventList(); dragging = true; }
			else { beatInput.value = clickBeat; formBeat = clickBeat; onAddEvent(); }
		}

		// Click on event list
		if (FlxG.mouse.justPressed && FlxG.mouse.x < eventListBg.width && FlxG.mouse.y >= eventListBg.y + 16)
		{
			var idx = Std.int((FlxG.mouse.y - eventListBg.y - 16) / 13) + scrollOffset;
			if (idx >= 0 && idx < events.length) { selectEvent(idx); refreshEventList(); }
		}

		// Drag events
		if (FlxG.mouse.pressed && selectedEvent >= 0 && selectedEvent < events.length && dragging)
		{
			events[selectedEvent].beat = Math.max(0, (FlxG.mouse.x + timelineOffset - 10) / timelineBeatWidth);
			refreshEventList(); updateCodePreview();
		}
		if (FlxG.mouse.justReleased) dragging = false;

		// Number keys
		var numKey:Int = -1;
		if (FlxG.keys.justPressed.ONE) numKey = 0; else if (FlxG.keys.justPressed.TWO) numKey = 1;
		else if (FlxG.keys.justPressed.THREE) numKey = 2; else if (FlxG.keys.justPressed.FOUR) numKey = 3;
		else if (FlxG.keys.justPressed.FIVE) numKey = 4; else if (FlxG.keys.justPressed.SIX) numKey = 5;
		else if (FlxG.keys.justPressed.SEVEN) numKey = 6; else if (FlxG.keys.justPressed.EIGHT) numKey = 7;
		else if (FlxG.keys.justPressed.NINE) numKey = 8; else if (FlxG.keys.justPressed.ZERO) numKey = 9;
		if (numKey >= 0) { var idx = numKey + scrollOffset; if (idx >= 0 && idx < events.length) { selectEvent(idx); refreshEventList(); } }

		if (FlxG.keys.justPressed.UP) { selectedEvent = Std.int(Math.max(0, selectedEvent - 1)); selectEvent(selectedEvent); refreshEventList(); }
		if (FlxG.keys.justPressed.DOWN) { selectedEvent = Std.int(Math.min(events.length - 1, selectedEvent + 1)); selectEvent(selectedEvent); refreshEventList(); }

		super.update(elapsed);
	}

	function setStatus(msg:String) { if (statusText != null) statusText.text = msg; }
}
