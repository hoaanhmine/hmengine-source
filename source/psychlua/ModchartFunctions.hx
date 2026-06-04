package psychlua;

#if MODCHARTS_ALLOWED
import modchart.Manager;
import modchart.events.Event;
#end

class ModchartFunctions
{
	public static function implement(funk:FunkinLua)
	{
		#if MODCHARTS_ALLOWED
		var lua = funk.lua;

		Lua_helper.add_callback(lua, "modchartSet", function(mod:String, beat:Float, value:Float, ?player:Int = -1, ?field:Int = -1)
		{
			if (Manager.instance != null)
				Manager.instance.set(mod, beat, value, player, field);
		});

		Lua_helper.add_callback(lua, "modchartEase", function(mod:String, beat:Float, length:Float, value:Float, ?ease:String = "linear", ?player:Int = -1, ?field:Int = -1)
		{
			if (Manager.instance != null)
				Manager.instance.ease(mod, beat, length, value, LuaUtils.getTweenEaseByString(ease), player, field);
		});

		Lua_helper.add_callback(lua, "modchartAdd", function(mod:String, beat:Float, length:Float, value:Float, ?ease:String = "linear", ?player:Int = -1, ?field:Int = -1)
		{
			if (Manager.instance != null)
				Manager.instance.add(mod, beat, length, value, LuaUtils.getTweenEaseByString(ease), player, field);
		});

		Lua_helper.add_callback(lua, "modchartSetAdd", function(mod:String, beat:Float, value:Float, ?player:Int = -1, ?field:Int = -1)
		{
			if (Manager.instance != null)
				Manager.instance.setAdd(mod, beat, value, player, field);
		});

		Lua_helper.add_callback(lua, "modchartSetPercent", function(mod:String, value:Float, ?player:Int = -1, ?field:Int = -1)
		{
			if (Manager.instance != null)
				Manager.instance.setPercent(mod, value, player, field);
		});

		Lua_helper.add_callback(lua, "modchartGetPercent", function(mod:String, ?player:Int = 0, ?field:Int = 0)
		{
			if (Manager.instance != null)
				return Manager.instance.getPercent(mod, player, field);
			return 0.0;
		});

		Lua_helper.add_callback(lua, "modchartAddModifier", function(mod:String, ?field:Int = -1)
		{
			if (Manager.instance != null)
				Manager.instance.addModifier(mod, field);
		});

		Lua_helper.add_callback(lua, "modchartAddPlayfield", function()
		{
			if (Manager.instance != null)
				Manager.instance.addPlayfield();
		});

		Lua_helper.add_callback(lua, "modchartCallback", function(beat:Float, luaFuncName:String, ?field:Int = -1)
		{
			if (Manager.instance != null)
			{
				Manager.instance.callback(beat, function(event:Event)
				{
					funk.call(luaFuncName, [event]);
				}, field);
			}
		});

		Lua_helper.add_callback(lua, "modchartRepeater", function(beat:Float, length:Float, luaFuncName:String, ?field:Int = -1)
		{
			if (Manager.instance != null)
			{
				Manager.instance.repeater(beat, length, function(event:Event)
				{
					funk.call(luaFuncName, [event]);
				}, field);
			}
		});

		#end
	}
}
