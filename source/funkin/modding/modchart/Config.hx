package funkin.modding.modchart;

class Config {
	public static var CAMERA3D_ENABLED:Bool = false;
	public static var ROTATION_ORDER:RotationOrder = Z_Y_X;
	public static var OPTIMIZE_HOLDS:Bool = false;
	public static var Z_SCALE:Float = 1;
	public static var RENDER_ARROW_PATHS:Bool = false;
	public static var ARROW_PATHS_CONFIG:ArrowPathConfig = {
		APPLY_COLOR: false,
		APPLY_ALPHA: false,
		APPLY_DEPTH: true,
		APPLY_SCALE: false,
		RESOLUTION: 1.0,
		BASE_DIVISIONS: 60,
		LENGTH: 500
	};
	public static var HOLD_END_SCALE:Float = 0.7;
	public static var COLUMN_SPECIFIC_MODIFIERS:Bool = true;
	public static var HOLDS_BEHIND_STRUM:Bool = false;
}

typedef ArrowPathConfig = {
	APPLY_COLOR:Bool,
	APPLY_ALPHA:Bool,
	APPLY_DEPTH:Bool,
	APPLY_SCALE:Bool,
	RESOLUTION:Float,
	BASE_DIVISIONS:Int,
	LENGTH:Int
}
