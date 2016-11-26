-- utils.lua by binbinhfr, v1.0.16
-- A 3Ra Gaming revision
-- define debug_status to 1 or nil in the control.lua, before statement require("utils")
-- define also debug_file and debug_mod_name

colors = {
	white = { r = 1, g = 1, b = 1 },
	black = { r = 0, g = 0, b = 0 },
	darkgrey = { r = 0.25, g = 0.25, b = 0.25 },
	grey = { r = 0.5, g = 0.5, b = 0.5 },
	lightgrey = { r = 0.75, g = 0.75, b = 0.75 },
	red = { r = 1, g = 0, b = 0 },
	darkred = { r = 0.5, g = 0, b = 0 },
	lightred = { r = 1, g = 0.5, b = 0.5 },
	green = { r = 0, g = 1, b = 0 },
	darkgreen = { r = 0, g = 0.5, b = 0 },
	lightgreen = { r = 0.5, g = 1, b = 0.5 },
	blue = { r = 0, g = 0, b = 1 },
	darkblue = { r = 0, g = 0, b = 0.5 },
	lightblue = { r = 0.5, g = 0.5, b = 1 },
	orange = { r = 1, g = 0.55, b = 0.1 },
	yellow = { r = 1, g = 1, b = 0 },
	pink = { r = 1, g = 0, b = 1 },
	purple = { r = 0.6, g = 0.1, b = 0.6 },
	brown = { r = 0.6, g = 0.4, b = 0.1 },
}

anticolors = {
	white = colors.black,
	black = colors.white,
	darkgrey = colors.white,
	grey = colors.black,
	lightgrey = colors.black,
	red = colors.white,
	darkred = colors.white,
	lightred = colors.black,
	green = colors.black,
	darkgreen = colors.white,
	lightgreen = colors.black,
	blue = colors.white,
	darkblue = colors.white,
	lightblue = colors.black,
	orange = colors.black,
	yellow = colors.black,
	pink = colors.white,
	purple = colors.white,
	brown = colors.white,
}

lightcolors = {
	white = colors.lightgrey,
	grey = colors.darkgrey,
	lightgrey = colors.grey,
	red = colors.lightred,
	green = colors.lightgreen,
	blue = colors.lightblue,
	yellow = colors.orange,
	pink = colors.purple,
}

local author_name1 = "BinbinHfr"
local author_name2 = "binbin"

--------------------------------------------------------------------------------------
function read_version(v)
	local v1, v2, v3 = string.match(v, "(%d+).(%d+).(%d+)")
	debug_print("version cut = ", v1, v2, v3)
end

--------------------------------------------------------------------------------------
function compare_versions(v1, v2)
	local v1a, v1b, v1c = string.match(v1, "(%d+).(%d+).(%d+)")
	local v2a, v2b, v2c = string.match(v2, "(%d+).(%d+).(%d+)")

	v1a = tonumber(v1a)
	v1b = tonumber(v1b)
	v1c = tonumber(v1c)
	v2a = tonumber(v2a)
	v2b = tonumber(v2b)
	v2c = tonumber(v2c)

	if v1a > v2a then
		return 1
	elseif v1a < v2a then
		return -1
	elseif v1b > v2b then
		return 1
	elseif v1b < v2b then
		return -1
	elseif v1c > v2c then
		return 1
	elseif v1c < v2c then
		return -1
	else
		return 0
	end
end

--------------------------------------------------------------------------------------
function older_version(v1, v2)
	local v1a, v1b, v1c = string.match(v1, "(%d+).(%d+).(%d+)")
	local v2a, v2b, v2c = string.match(v2, "(%d+).(%d+).(%d+)")
	local ret

	v1a = tonumber(v1a)
	v1b = tonumber(v1b)
	v1c = tonumber(v1c)
	v2a = tonumber(v2a)
	v2b = tonumber(v2b)
	v2c = tonumber(v2c)

	if v1a > v2a then
		ret = false
	elseif v1a < v2a then
		ret = true
	elseif v1b > v2b then
		ret = false
	elseif v1b < v2b then
		ret = true
	elseif v1c < v2c then
		ret = true
	else
		ret = false
	end

	debug_print("older_version ", v1, "<", v2, "=", ret)

	return (ret)
end

--------------------------------------------------------------------------------------
function debug_active(...)
	-- can be called everywhere, except in on_load where game is not existing
	local s = ""

	for i, v in ipairs({ ... }) do
		s = s .. tostring(v)
	end

	if s == "RAZ" or debug_do_raz == true then
		game.remove_path(debug_file)
		debug_do_raz = false
	elseif s == "CLEAR" then
		for _, player in pairs(game.players) do
			if player.connected then player.clear_console() end
		end
	end

	s = debug_mod_name .. "(" .. game.tick .. "): " .. s
	game.write_file(debug_file, s .. "\n", true)

	for _, player in pairs(game.players) do
		if player.connected then player.print(s) end
	end
end

if debug_status == 1 then debug_print = debug_active else debug_print = function() end end

--------------------------------------------------------------------------------------
function message_all(s)
	for _, player in pairs(game.players) do
		if player.connected then
			player.print(s)
		end
	end
end

--------------------------------------------------------------------------------------
function message_force(force, s)
	for _, player in pairs(force.players) do
		if player.connected then
			player.print(s)
		end
	end
end

--------------------------------------------------------------------------------------
function square_area(origin, radius)
	return {
		{ x = origin.x - radius, y = origin.y - radius },
		{ x = origin.x + radius, y = origin.y + radius }
	}
end

--------------------------------------------------------------------------------------
function distance(pos1, pos2)
	local dx = pos2.x - pos1.x
	local dy = pos2.y - pos1.y
	return (math.sqrt(dx * dx + dy * dy))
end

--------------------------------------------------------------------------------------
function distance_square(pos1, pos2)
	return (math.max(math.abs(pos2.x - pos1.x), math.abs(pos2.y - pos1.y)))
end

--------------------------------------------------------------------------------------
function pos_offset(pos, offset)
	return { x = pos.x + offset.x, y = pos.y + offset.y }
end

--------------------------------------------------------------------------------------
function surface_area(surf)
	local x1, y1, x2, y2 = 0, 0, 0, 0

	for chunk in surf.get_chunks() do
		if chunk.x < x1 then
			x1 = chunk.x
		elseif chunk.x > x2 then
			x2 = chunk.x
		end
		if chunk.y < y1 then
			y1 = chunk.y
		elseif chunk.y > y2 then
			y2 = chunk.y
		end
	end

	return ({ { x1 * 32 - 8, y1 * 32 - 8 }, { x2 * 32 + 40, y2 * 32 + 40 } })
end

--------------------------------------------------------------------------------------
function iif(cond, val1, val2)
	if cond then
		return val1
	else
		return val2
	end
end

--------------------------------------------------------------------------------------
function add_list(list, obj)
	-- to avoid duplicates...
	for i, obj2 in pairs(list) do
		if obj2 == obj then
			return (false)
		end
	end
	table.insert(list, obj)
	return (true)
end

--------------------------------------------------------------------------------------
function del_list(list, obj)
	for i, obj2 in pairs(list) do
		if obj2 == obj then
			table.remove(list, i)
			return (true)
		end
	end
	return (false)
end

--------------------------------------------------------------------------------------
function in_list(list, obj)
	for k, obj2 in pairs(list) do
		if obj2 == obj then
			return (k)
		end
	end
	return (nil)
end

--------------------------------------------------------------------------------------
function size_list(list)
	local n = 0
	for i in pairs(list) do
		n = n + 1
	end
	return (n)
end

--------------------------------------------------------------------------------------
function concat_lists(list1, list2)
	-- add list2 into list1 , do not avoid duplicates...
	for i, obj in pairs(list2) do
		table.insert(list1, obj)
	end
end

------------------------------------------------------------------------------------
function is_dev(player)
	return (player.name == author_name1 or player.name == author_name2)
end

--------------------------------------------------------------------------------------
function dupli_proto(type, name1, name2)
	if data.raw[type][name1] then
		local proto = table.deepcopy(data.raw[type][name1])
		proto.name = name2
		if proto.minable and proto.minable.result then proto.minable.result = name2 end
		if proto.place_result then proto.place_result = name2 end
		if proto.take_result then proto.take_result = name2 end
		if proto.result then proto.result = name2 end
		return (proto)
	else
		error("prototype unknown " .. name1)
		return (nil)
	end
end

--------------------------------------------------------------------------------------
function debug_guis(guip, indent)
	if guip == nil then return end
	debug_print(indent .. string.rep("....", indent) .. " " .. guip.name)
	indent = indent + 1
	for k, gui in pairs(guip.children_names) do
		debug_guis(guip[gui], indent)
	end
end

--------------------------------------------------------------------------------------
function extract_monolith(filename, x, y, w, h)
	return {
		type = "monolith",
		top_monolith_border = 0,
		right_monolith_border = 0,
		bottom_monolith_border = 0,
		left_monolith_border = 0,
		monolith_image = {
			filename = filename,
			priority = "extra-high-no-scale",
			width = w,
			height = h,
			x = x,
			y = y,
		},
	}
end

--------------------------------------------------------------------------------------
-- rounds number (num) to certain number of decimal places (idp)
function round(num, idp)
	local mult = 10 ^ (idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

-- cleans up the color values, gets rid of floating point innacuracy
function clean_color(input_color)
	local temp_r = round(input_color.r, 6)
	local temp_g = round(input_color.g, 6)
	local temp_b = round(input_color.b, 6)
	local temp_a = round(input_color.a, 6)
	return { r = temp_r, g = temp_g, b = temp_b, a = temp_a }
end

--------------------------------------------------------------------------------------
-- returns true if colors are the same, false if different
function compare_colors(color1, color2)
	local clean_color1 = clean_color(color1)
	local clean_color2 = clean_color(color2)
	if clean_color1.r ~= clean_color2.r then
		return false
	end
	if clean_color1.g ~= clean_color2.g then
		return false
	end
	if clean_color1.b ~= clean_color2.b then
		return false
	end
	if clean_color1.a ~= clean_color2.a then
		return false
	end
	return true
end

--------------------------------------------------------------------------------------
-- Provide a player's name to put their inventory into a chest somewhere near spawn.
function return_inventory(player_name)
	local stolen_inventories = {
		main = game.players[player_name].get_inventory(defines.inventory.player_main),
		quickbar = game.players[player_name].get_inventory(defines.inventory.player_quickbar),
		guns = game.players[player_name].get_inventory(defines.inventory.player_guns),
		ammo = game.players[player_name].get_inventory(defines.inventory.player_ammo),
		armor = game.players[player_name].get_inventory(defines.inventory.player_armor),
		tools = game.players[player_name].get_inventory(defines.inventory.player_tools),
		vehicle = game.players[player_name].get_inventory(defines.inventory.player_vehicle),
		trash = game.players[player_name].get_inventory(defines.inventory.player_trash)
	}
	local chest_location = game.surfaces.nauvis.find_non_colliding_position("steel-chest", game.forces.player.get_spawn_position(game.surfaces.nauvis), 0, 1)
	local return_chest = game.surfaces.nauvis.create_entity{name = "steel-chest", position = chest_location, force = game.forces.player}
	local chest_inventory = return_chest.get_inventory(defines.inventory.chest)
	for _,inventory in pairs(stolen_inventories) do
		for name,count in pairs(inventory.get_contents()) do
			local inserted = chest_inventory.insert{name = name, count = count}
			inventory.remove{name = name, count = inserted}
			if inserted < count then
				chest_location = game.surfaces.nauvis.find_non_colliding_position("steel-chest", chest_location, 0, 1)
				chest_inventory = game.surfaces.nauvis.create_entity{name = "steel-chest", position = chest_location, force = game.forces.player}
				inserted = chest_inventory.insert{name = name, count = (count - inserted)}
				inventory.remove{name = name, count = inserted}
			end
		end
	end
	game.print("The now banned griefer " .. player_name .. "'s inventory has been returned somewhere near the spawn. Look for one or more steel chests.")
end
--------------------------------------------------------------------------------------
-- Currently console only, as print() is used to print the results
function show_inventory(player_name)
	local player = game.players[player_name]
	local inventories = {
		main = game.players[player_name].get_inventory(defines.inventory.player_main),
		quickbar = game.players[player_name].get_inventory(defines.inventory.player_quickbar),
		guns = game.players[player_name].get_inventory(defines.inventory.player_guns),
		ammo = game.players[player_name].get_inventory(defines.inventory.player_ammo),
		armor = game.players[player_name].get_inventory(defines.inventory.player_armor),
		tools = game.players[player_name].get_inventory(defines.inventory.player_tools),
		vehicle = game.players[player_name].get_inventory(defines.inventory.player_vehicle),
		trash = game.players[player_name].get_inventory(defines.inventory.player_trash)
	}
	for invname,inventory in pairs(inventories) do
		if not inventory.is_empty() then print("Items in " .. invname .. " inventory:") end
		for name,count in pairs(inventory.get_contents()) do
			print("   " .. name .. " - " .. count)
		end
	end
end
--------------------------------------------------------------------------------------
--This command simply deletes the inventory of the listed player
function delete_inventory(player_name)
	local stolen_inventories = {
		main = game.players[player_name].get_inventory(defines.inventory.player_main),
		quickbar = game.players[player_name].get_inventory(defines.inventory.player_quickbar),
		guns = game.players[player_name].get_inventory(defines.inventory.player_guns),
		ammo = game.players[player_name].get_inventory(defines.inventory.player_ammo),
		armor = game.players[player_name].get_inventory(defines.inventory.player_armor),
		tools = game.players[player_name].get_inventory(defines.inventory.player_tools),
		vehicle = game.players[player_name].get_inventory(defines.inventory.player_vehicle),
		trash = game.players[player_name].get_inventory(defines.inventory.player_trash)
	}
	for _,inventory in pairs(stolen_inventories) do
		for name,count in pairs(inventory.get_contents()) do
			inventory.remove{name = name, count = count}
		end
	end
end