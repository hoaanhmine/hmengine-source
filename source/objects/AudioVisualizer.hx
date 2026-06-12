package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import openfl.geom.Rectangle;

class AudioVisualizer extends FlxSprite
{
	public var barCount:Int = 64;
	public var barSpacing:Float = 2;
	public var sensitivity:Float = 1.5;
	public var smoothingFactor:Float = 0.25;
	public var peakFallSpeed:Float = 2.0;

	var barHeights:Array<Float>;
	var targetHeights:Array<Float>;
	var peakHeights:Array<Float>;
	var barPhases:Array<Float>;

	var _visRect:Rectangle;

	public function new(x:Float, y:Float, w:Float, h:Float, barCount:Int = 64)
	{
		super(x, y);
		this.barCount = barCount;
		makeGraphic(Std.int(w), Std.int(h), FlxColor.TRANSPARENT, true);
		scrollFactor.set();

		_visRect = new Rectangle();
		barHeights = [for (i in 0...barCount) 0.0];
		targetHeights = [for (i in 0...barCount) 0.0];
		peakHeights = [for (i in 0...barCount) 0.0];
		barPhases = [for (i in 0...barCount) (i / barCount) * Math.PI * 2];
	}

	public function reinit()
	{
		// Nothing to re-init in amplitude mode
	}

	function getBarWidth():Float
	{
		return (width - barSpacing * (barCount - 1)) / barCount;
	}

	override function update(elapsed:Float)
	{
		if (!visible || !exists) return;
		super.update(elapsed);

		var amplitude:Float = 0;
		if (FlxG.sound.music != null)
		{
			amplitude = FlxG.sound.music.amplitude * sensitivity;
			if (amplitude < 0.01) amplitude = 0;
		}

		var h = height;
		var time = (FlxG.sound.music != null) ? FlxG.sound.music.time / 1000 : 0;

		for (i in 0...barCount)
		{
			var phase = barPhases[i];
			var freqMod = 0.5 + 0.5 * (i / barCount);
			var wave = 0.5 + 0.5 * Math.sin(time * (4 + i * 2) + phase);
			var spread = (barCount - i) / barCount * 0.4 + 0.1;

			targetHeights[i] = amplitude * h * (spread + wave * freqMod * 0.6);
			targetHeights[i] = FlxMath.bound(targetHeights[i], 0, h);

			barHeights[i] = FlxMath.lerp(barHeights[i], targetHeights[i], smoothingFactor + amplitude * 0.3);

			var peakTarget = targetHeights[i];
			if (peakHeights[i] < peakTarget)
				peakHeights[i] = peakTarget;
			else
				peakHeights[i] -= peakFallSpeed * elapsed * h;
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

		_visRect.setTo(0, 0, width, height);
		pixel.fillRect(_visRect, FlxColor.TRANSPARENT);

		for (i in 0...barCount)
		{
			var barH = Std.int(FlxMath.bound(barHeights[i], 0, h));
			if (barH <= 0) continue;

			var barX = i * (barW + spacing);
			var barY = h - barH;

			_visRect.setTo(barX, barY, barW, barH);
			pixel.fillRect(_visRect, getBarColor(i, barH / h));

			var peakY = h - Std.int(FlxMath.bound(peakHeights[i], 0, h));
			_visRect.setTo(barX, peakY - 2, barW, 2);
			pixel.fillRect(_visRect, FlxColor.WHITE);
		}
	}

	function getBarColor(index:Int, value:Float):FlxColor
	{
		var r:Int, g:Int, b:Int;
		if (value < 0.5)
		{
			var t = value * 2;
			r = Std.int(FlxMath.lerp(0, 255, t));
			g = Std.int(FlxMath.lerp(255, 255, t));
			b = Std.int(FlxMath.lerp(0, 0, t));
		}
		else
		{
			var t = (value - 0.5) * 2;
			r = Std.int(FlxMath.lerp(255, 255, t));
			g = Std.int(FlxMath.lerp(255, 0, t));
			b = Std.int(FlxMath.lerp(0, 0, t));
		}
		return 0xFF000000 | (r << 16) | (g << 8) | b;
	}
}
