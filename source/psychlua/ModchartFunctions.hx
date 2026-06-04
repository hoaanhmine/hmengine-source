package psychlua;

#if MODCHARTS_ALLOWED
import funkin.modding.modchart.Manager;
import funkin.modding.modchart.backend.standalone.Adapter;
import backend.Conductor;
#end

class ModchartFunctions
{
	public static function implement(funk:FunkinLua)
	{
		#if MODCHARTS_ALLOWED
		var lua = funk.lua;

		Lua_helper.add_callback(lua, "addModifier", function(name:String, ?field:Int = -1)
		{
			if (Manager.instance != null)
				Manager.instance.addModifier(name, field);
		});

		Lua_helper.add_callback(lua, "setPercent", function(name:String, value:Float, ?player:Int = -1, ?field:Int = -1)
		{
			if (Manager.instance != null)
				Manager.instance.setPercent(name, value, player, field);
		});

		Lua_helper.add_callback(lua, "getPercent", function(name:String, ?player:Int = 0, ?field:Int = 0):Float
		{
			if (Manager.instance != null)
				return Manager.instance.getPercent(name, player, field);
			return 0.0;
		});

		Lua_helper.add_callback(lua, "setRawValue", function(name:String, value:Float, ?player:Int = -1, ?field:Int = -1)
		{
			if (Manager.instance != null)
				Manager.instance.setRawValue(name, value, player, field);
		});

		Lua_helper.add_callback(lua, "getRawValue", function(name:String, ?player:Int = 0, ?field:Int = 0):Float
		{
			if (Manager.instance != null)
				return Manager.instance.getRawValue(name, player, field);
			return 0.0;
		});

		Lua_helper.add_callback(lua, "set", function(nameOrMods:Dynamic, beat:Float, ?value:Dynamic, ?player:Int = -1, ?field:Int = -1)
		{
			if (Manager.instance == null) return;

			if (Std.isOfType(nameOrMods, String))
				Manager.instance.set(cast nameOrMods, beat, cast value, player, field);
			else
			{
				var actualPlayer:Int = (value != null) ? cast value : -1;
				var actualField:Int = player;
				for (modName in Reflect.fields(nameOrMods))
					Manager.instance.set(modName, beat, Reflect.field(nameOrMods, modName), actualPlayer, actualField);
			}
		});

		Lua_helper.add_callback(lua, "ease", function(nameOrMods:Dynamic, beat:Float, length:Float, ?value:Dynamic, ?easeName:String = "linear", ?player:Int = -1, ?field:Int = -1)
		{
			if (Manager.instance == null) return;

			if (Std.isOfType(nameOrMods, String))
				Manager.instance.ease(cast nameOrMods, beat, length, cast value, LuaUtils.getTweenEaseByString(easeName), player, field);
			else
			{
				var actualEaseName:String = (value != null) ? cast value : "linear";
				var actualPlayer:Int = (easeName != null) ? Std.parseInt(easeName) : -1;
				var actualField:Int = player;
				var easeFunc = LuaUtils.getTweenEaseByString(actualEaseName);
				for (modName in Reflect.fields(nameOrMods))
					Manager.instance.ease(modName, beat, length, Reflect.field(nameOrMods, modName), easeFunc, actualPlayer, actualField);
			}
		});

		Lua_helper.add_callback(lua, "add", function(nameOrMods:Dynamic, beat:Float, length:Float, ?value:Dynamic, ?easeName:String = "linear", ?player:Int = -1, ?field:Int = -1)
		{
			if (Manager.instance == null) return;

			if (Std.isOfType(nameOrMods, String))
				Manager.instance.add(cast nameOrMods, beat, length, cast value, LuaUtils.getTweenEaseByString(easeName), player, field);
			else
			{
				var actualEaseName:String = (value != null) ? cast value : "linear";
				var actualPlayer:Int = (easeName != null) ? Std.parseInt(easeName) : -1;
				var actualField:Int = player;
				var easeFunc = LuaUtils.getTweenEaseByString(actualEaseName);
				for (modName in Reflect.fields(nameOrMods))
					Manager.instance.add(modName, beat, length, Reflect.field(nameOrMods, modName), easeFunc, actualPlayer, actualField);
			}
		});

		Lua_helper.add_callback(lua, "setAdd", function(nameOrMods:Dynamic, beat:Float, ?value:Dynamic, ?player:Int = -1, ?field:Int = -1)
		{
			if (Manager.instance == null) return;

			if (Std.isOfType(nameOrMods, String))
				Manager.instance.setAdd(cast nameOrMods, beat, cast value, player, field);
			else
			{
				var actualPlayer:Int = (value != null) ? cast value : -1;
				var actualField:Int = player;
				for (modName in Reflect.fields(nameOrMods))
					Manager.instance.setAdd(modName, beat, Reflect.field(nameOrMods, modName), actualPlayer, actualField);
			}
		});

		Lua_helper.add_callback(lua, "addPlayfield", function()
		{
			if (Manager.instance != null)
				Manager.instance.addPlayfield();
		});

		Lua_helper.add_callback(lua, "alias", function(name:String, aliasName:String, field:Int)
		{
			if (Manager.instance != null)
				Manager.instance.alias(name, aliasName, field);
		});

		Lua_helper.add_callback(lua, "getHoldSize", function():Float return Manager.HOLD_SIZE);
		Lua_helper.add_callback(lua, "getHoldSizeDiv2", function():Float return Manager.HOLD_SIZEDIV2);
		Lua_helper.add_callback(lua, "getArrowSize", function():Float return Manager.ARROW_SIZE);
		Lua_helper.add_callback(lua, "getArrowSizeDiv2", function():Float return Manager.ARROW_SIZEDIV2);

		Lua_helper.add_callback(lua, "callback", function(beat:Float, funcName:String, ?field:Int = -1)
		{
			if (Manager.instance != null)
				Manager.instance.callback(beat, function(event) funk.call(funcName, []), field);
		});

		Lua_helper.add_callback(lua, "scheduleCallback", function(beat:Float, funcName:String, ?field:Int = -1)
		{
			if (Manager.instance != null)
				Manager.instance.callback(beat, function(event) funk.call(funcName, []), field);
		});

		Lua_helper.add_callback(lua, "repeater", function(beat:Float, length:Float, funcName:String, ?field:Int = -1)
		{
			if (Manager.instance != null)
				Manager.instance.repeater(beat, length, function(event) funk.call(funcName, []), field);
		});

		Lua_helper.add_callback(lua, "setNow", function(nameOrMods:Dynamic, ?value:Dynamic, ?player:Int = -1, ?field:Int = -1)
		{
			if (Manager.instance == null) return;
			var curBeat:Float = Conductor.songPosition / Conductor.crochet;

			if (Std.isOfType(nameOrMods, String))
				Manager.instance.set(cast nameOrMods, curBeat, cast value, player, field);
			else
			{
				var actualPlayer:Int = (value != null) ? cast value : -1;
				var actualField:Int = player;
				for (modName in Reflect.fields(nameOrMods))
					Manager.instance.set(modName, curBeat, Reflect.field(nameOrMods, modName), actualPlayer, actualField);
			}
		});

		Lua_helper.add_callback(lua, "easeNow", function(nameOrMods:Dynamic, length:Float, ?value:Dynamic, ?easeName:String = "linear", ?player:Int = -1, ?field:Int = -1)
		{
			if (Manager.instance == null) return;
			var curBeat:Float = Conductor.songPosition / Conductor.crochet;

			if (Std.isOfType(nameOrMods, String))
				Manager.instance.ease(cast nameOrMods, curBeat, length, cast value, LuaUtils.getTweenEaseByString(easeName), player, field);
			else
			{
				var actualEaseName:String = (value != null) ? cast value : "linear";
				var actualPlayer:Int = (easeName != null) ? Std.parseInt(easeName) : -1;
				var actualField:Int = player;
				var easeFunc = LuaUtils.getTweenEaseByString(actualEaseName);
				for (modName in Reflect.fields(nameOrMods))
					Manager.instance.ease(modName, curBeat, length, Reflect.field(nameOrMods, modName), easeFunc, actualPlayer, actualField);
			}
		});

		Lua_helper.add_callback(lua, "addNow", function(nameOrMods:Dynamic, length:Float, ?value:Dynamic, ?easeName:String = "linear", ?player:Int = -1, ?field:Int = -1)
		{
			if (Manager.instance == null) return;
			var curBeat:Float = Conductor.songPosition / Conductor.crochet;

			if (Std.isOfType(nameOrMods, String))
				Manager.instance.add(cast nameOrMods, curBeat, length, cast value, LuaUtils.getTweenEaseByString(easeName), player, field);
			else
			{
				var actualEaseName:String = (value != null) ? cast value : "linear";
				var actualPlayer:Int = (easeName != null) ? Std.parseInt(easeName) : -1;
				var actualField:Int = player;
				var easeFunc = LuaUtils.getTweenEaseByString(actualEaseName);
				for (modName in Reflect.fields(nameOrMods))
					Manager.instance.add(modName, curBeat, length, Reflect.field(nameOrMods, modName), easeFunc, actualPlayer, actualField);
			}
		});

		Lua_helper.add_callback(lua, "setAddNow", function(nameOrMods:Dynamic, ?value:Dynamic, ?player:Int = -1, ?field:Int = -1)
		{
			if (Manager.instance == null) return;
			var curBeat:Float = Conductor.songPosition / Conductor.crochet;

			if (Std.isOfType(nameOrMods, String))
				Manager.instance.setAdd(cast nameOrMods, curBeat, cast value, player, field);
			else
			{
				var actualPlayer:Int = (value != null) ? cast value : -1;
				var actualField:Int = player;
				for (modName in Reflect.fields(nameOrMods))
					Manager.instance.setAdd(modName, curBeat, Reflect.field(nameOrMods, modName), actualPlayer, actualField);
			}
		});

		Lua_helper.add_callback(lua, "getCurrentBeat", function():Float
		{
			return Conductor.songPosition / Conductor.crochet;
		});

		Lua_helper.add_callback(lua, "getCurrentStep", function():Float
		{
			return Conductor.songPosition / Conductor.stepCrochet;
		});

		Lua_helper.add_callback(lua, "getSongPosition", function():Float
		{
			return Conductor.songPosition;
		});

		Lua_helper.add_callback(lua, "getBPM", function():Float
		{
			return Conductor.bpm;
		});

		Lua_helper.add_callback(lua, "getPlayerCount", function():Int
		{
			if (Adapter.instance != null)
				return Adapter.instance.getPlayerCount();
			return 2;
		});

		Lua_helper.add_callback(lua, "getRenderedStrumPosition", function(strum:Dynamic, ?field:Int = -1):Dynamic
		{
			if (Manager.instance == null || Adapter.instance == null || strum == null) return null;
			var playfields = Manager.instance.playfields;
			if (playfields == null || playfields.length == 0) return null;

			var player = Adapter.instance.getPlayerFromArrow(strum);
			var targetField = (field < 0) ? (playfields.length > 1 ? Std.int(Math.min(player, playfields.length - 1)) : 0) : field;
			if (targetField < 0 || targetField >= playfields.length) return null;

			var playfield = playfields[targetField];
			if (playfield == null) return null;

			var lane = Adapter.instance.getLaneFromArrow(strum);

			var x = Adapter.instance.getDefaultReceptorX(lane, player) + Manager.ARROW_SIZEDIV2;
			var y = Adapter.instance.getDefaultReceptorY(lane, player) + Manager.ARROW_SIZEDIV2;

			return {x: x, y: y};
		});
		#end
	}
}
