package objects;

import funkin.vis.dsp.SpectralAnalyzer;
import funkin.vis.dsp.Bar;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import openfl.geom.Rectangle;

class AudioVisualizer extends FlxSprite
{
	public var barCount:Int = 64;
	public var barSpacing:Float = 2;
	public var sensitivity:Float = 1.0;
	public var smoothingFactor:Float = 0.3;
	public var peakFallSpeed:Float = 3.0;

	var analyzer:SpectralAnalyzer;
	var levels:Array<Bar>;
	var barHeights:Array<Float>;
	var targetHeights:Array<Float>;
	var peakHeights:Array<Float>;

	var _rect:Rectangle;

	public function new(x:Float, y:Float, w:Float, h:Float, barCount:Int = 64)
	{
		super(x, y);
		this.barCount = barCount;
		makeGraphic(Std.int(w), Std.int(h), FlxColor.TRANSPARENT, true);
		scrollFactor.set();

		_rect = new Rectangle();
		levels = [];
		barHeights = [for (i in 0...barCount) 0.0];
		targetHeights = [for (i in 0...barCount) 0.0];
		peakHeights = [for (i in 0...barCount) 0.0];

		initAnalyzer();
	}

	public function reinit()
	{
		analyzer = null;
		initAnalyzer();
	}

	function initAnalyzer()
	{
		try
		{
			@:privateAccess
			var source = FlxG.sound.music._channel.source;
			if (source != null)
			{
				analyzer = new SpectralAnalyzer(source, barCount, 0.8, 30);
				analyzer.minDb = -70;
				analyzer.maxDb = -20;
				analyzer.minFreq = 50;
				analyzer.maxFreq = 18000;
			}
		}
		catch (e:Dynamic)
		{
			analyzer = null;
		}
	}

	function getBarWidth():Float
	{
		return (width - barSpacing * (barCount - 1)) / barCount;
	}

	override function update(elapsed:Float)
	{
		if (!visible || !exists) return;
		super.update(elapsed);

		if (analyzer == null)
		{
			initAnalyzer();
			if (analyzer == null) return;
		}

		if (FlxG.sound.music != null && FlxG.sound.music.playing)
		{
			try
			{
				levels = analyzer.getLevels(levels);
			}
			catch (e:Dynamic)
			{
				return;
			}

			var h = height;
			for (i in 0...barCount)
			{
				if (i < levels.length)
				{
					targetHeights[i] = levels[i].value * h * sensitivity;
					barHeights[i] = FlxMath.lerp(barHeights[i], targetHeights[i], smoothingFactor);

					var peakTarget = levels[i].peak * h * sensitivity;
					if (peakHeights[i] < peakTarget)
						peakHeights[i] = peakTarget;
					else
						peakHeights[i] -= peakFallSpeed * elapsed * h;
				}
			}
		}
		else
		{
			for (i in 0...barCount)
			{
				barHeights[i] *= 0.9;
				peakHeights[i] = 0;
			}
		}

		drawBars();
	}

	function drawBars()
	{
		var pixel = pixels;
		if (pixel == null) return;

		var w = Std.int(width);
		var h = Std.int(height);
		var barW = Std.int(getBarWidth());
		var spacing = Std.int(barSpacing);

		_rect.setTo(0, 0, width, height);
		pixel.fillRect(_rect, FlxColor.TRANSPARENT);

		for (i in 0...barCount)
		{
			var barH = Std.int(FlxMath.bound(barHeights[i], 0, h));
			if (barH <= 0) continue;

			var barX = i * (barW + spacing);
			var barY = h - barH;

			_rect.setTo(barX, barY, barW, barH);
			pixel.fillRect(_rect, getBarColor(i, barH / h));

			var peakY = h - Std.int(FlxMath.bound(peakHeights[i], 0, h));
			_rect.setTo(barX, peakY - 2, barW, 2);
			pixel.fillRect(_rect, FlxColor.WHITE);
		}
	}

	function getBarColor(index:Int, value:Float):FlxColor
	{
		if (value < 0.5)
			return FlxColor.lerp(0xFF00FF00, 0xFFFFFF00, value * 2);
		else
			return FlxColor.lerp(0xFFFFFF00, 0xFFFF0000, (value - 0.5) * 2);
	}
}
