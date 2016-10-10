--Team PVP [Based on Roboport_PvP_Slow by Klonan]
--A 3Ra Gaming revision
--Starting Variables
global.orange_count_total = 0
global.purple_count_total = 0

global.kill_count_purple = 0
global.kill_count_orange = 0

global.orange_count = 0
global.purple_count = 0

d = 32*3
bd = d*3
global.orange_color = {b = 0, r= 0.8, g = 0.4, a = 0.8}
global.purple_color = {b = 0.8, r= 0.4, g = 0, a = 0.8}

normal_attack_sent_event = script.generate_event_name()
landing_attack_sent_event = script.generate_event_name()

remote.add_interface("freeplay",
{
	set_attack_data = function(data)
		global.attack_data = data
	end,
	get_attack_data = function()
		return global.attack_data
	end,
	get_normal_attack_sent_event = function()
		return normal_attack_sent_event
	end,
})

init_attack_data = function()
	global.attack_data = {
		-- whether all attacks are enabled
		enabled = true,
		-- this script is allowed to change the attack values attack_count and until_next_attack
		change_values = true,
		-- what distracts the creepers during the attack
		distraction = defines.distraction.byenemy,
		-- number of units in the next attack
		attack_count = 5,
		-- time to the next attack
		until_next_attack = 60 * 60 * 60,
	}
end

	
script.on_init(function()
	global.purple_team_x = math.random(370,380) -- distance between bases
	global.purple_team_y = math.random(0,0)
	global.purple_team_position ={ global.purple_team_x, global.purple_team_y}
	global.purple_team_area = {{ global.purple_team_x - d,  global.purple_team_y - d},{ global.purple_team_x + d,  global.purple_team_y + d}}
	global.orange_team_x = 0 - math.random(370,380) -- distance between bases
	global.orange_team_y = 0 - math.random(0,0)
	global.orange_team_position = { global.orange_team_x, global.orange_team_y}
	global.orange_team_area = {{ global.orange_team_x - d,  global.orange_team_y - d},{ global.orange_team_x + d,  global.orange_team_y + d}}
  
	init_attack_data()
	make_forces()  
	make_lobby()
end)

	--global variables for the message desplay
global.timer_value = 0
global.timer_wait = 600
global.timer_display = 1

script.on_event(defines.events.on_tick, function(event)
	show_health()
  if game.tick % 20 == 0 then
		color()
  end
	if game.tick == 50 * 60 then  ----------*************^^^^these have to match**********----------
		set_spawns()
		for k, p in pairs (game.players) do
			make_team_option(p)
		end
		set_starting_areas()
	end
	local current_time = game.tick / 60 - global.timer_value
	local message_display = "test"
	if current_time >= global.timer_wait then
		if global.timer_display == 1 then
			message_display = {"msg-announce1"}
			global.timer_display = 2
		else
			message_display = {"msg-announce2"}
			global.timer_display = 1
		end
		for k, player in pairs(game.players) do
			player.print(message_display)
		end
		global.timer_value = game.tick / 60
	end
end)

script.on_event(defines.events.on_player_created, function(event)
	if global.orange_count == nil then
		global.orange_count = 0
	end
	if global.purple_count == nil then
		global.purple_count = 0
	end
	local player = game.players[event.player_index]
	player.teleport({0,8},game.surfaces["Lobby"])
	player.print({"msg-intro1"})
	player.print({"msg-intro2"})
 
	if game.tick > 50*60 then    ------------*************vvvvvvthese have to match**********----------
		make_team_option(player)
	else 
		player.print({"msg-intro3"})
	end
end)

script.on_event(defines.events.on_gui_click, function(event)
	local s = game.surfaces.nauvis
	local player = game.players[event.player_index]
    local index = event.player_index
    local element = event.element.name
		
	if player.gui.top.flashlight == nil then
        if element ~= nil then
            if element == "flashlight" then
                if player.character == nil then return end
                if global.player_flashlight_state == nil then
                    global.player_flashlight_state = {}
                end
                
                if global.player_flashlight_state[event.player_index] == nil then
                    global.player_flashlight_state[event.player_index] = true
                end
    
                if global.player_flashlight_state[event.player_index] then
                    global.player_flashlight_state[event.player_index] = false
                    player.character.disable_flashlight()
                else
                    global.player_flashlight_state[event.player_index] = true
                    player.character.enable_flashlight()
                end
            end
        end
	end	
	if player.gui.center.end_message ~= nil then
		if (event.element.name == "end_message_button") then
			player.gui.center.end_message.destroy()
		end
    end
	if player.gui.left.choose_team ~= nil then
		if (event.element.name == "orange") then
			if global.orange_count > global.purple_count then player.print("Too many Players on that team") return end
				join_orange(event)
		end
	end
	if player.gui.left.choose_team ~= nil then
		if (event.element.name == "purple") then
			if global.purple_count > global.orange_count then player.print("Too many Players on that team") return end
				join_purple(event)
		end
	end
	if player.gui.left.choose_team ~= nil then
		if (event.element.name == "spectator") then
			force_spectators(index)
		end
		--destroy.character
		--make controller ghost
	end
    if player.gui.left.spectate ~= nil then
        if element ~= nil then
            if element == "spectate" then
                force_spectators(index)
            end
        end
    end
end)

script.on_event(defines.events.on_player_joined_game, function(event)
	local player = game.players[event.player_index]
    if player.gui.left.flashlight == nil then
        local frame = player.gui.left.add{name = "flashlight", type = "button", direction = "horizontal", caption = "flashlight"}
    end
	
	if player.admin == true then
        if player.gui.left.spectate == nil then
            local adminframe = player.gui.left.add{name = "spectate", type = "button", direction = "horizontal", caption = "spectate"}
        end
		if game.tick > 60 then
			for k, p in pairs (game.players) do
				p.print("All Hail Admin "..player.name)
			end
		end
	end
	show_update_score()
	update_count()
 end)

script.on_event(defines.events.on_player_left_game, function(event)
	if game.player.force == game.forces["Orange"] then
		online_count = orange_online - 1
	end
	if game.player.force == game.forces["Purple"] then
		online_count = purple_online - 1
	end
	update_count()
end)
 
script.on_event(defines.events.on_player_respawned, function(event)
	local player = game.players[event.player_index]
	player.insert{name="submachine-gun", count=1}
	player.insert{name="firearm-magazine", count=10}
end)

-- for backwards compatibility
script.on_configuration_changed(function(data)
	if global.attack_data == nil then
		init_attack_data()
		if global.attack_count ~= nil then
			global.attack_data.attack_count = global.attack_count
		end
		if global.until_next_attacknormal ~= nil then
			global.attack_data.until_next_attack = global.until_next_attacknormal
		end
	end
	if global.attack_data.distraction == nil then
		global.attack_data.distraction = defines.distraction.byenemy
	end
end)

	-- not working, not breaking. supposed to clear the players cursor_stack before they die so it ends up with their loot.
script.on_event(defines.events.on_pre_player_died, function(event)
	local player = game.players[event.player_index]
	player.cursor_stack.clear()
end)

	-- on death (player) spawn a "grave" at their location holding thier loot.
script.on_event(defines.events.on_entity_died, function(event)
	local entity = event.entity

	if entity == global.p_roboport then
		global.drbp = entity.position orange_destroy_p()
	end
	if entity == global.o_roboport then
		global.drbp = entity.position purple_destroy_o()
	end
	if entity.type == "player" then
		local pos = entity.surface.find_non_colliding_position("steel-chest", entity.position, 8, 1)
		if not pos then return end
		local grave = entity.surface.create_entity{name="steel-chest", position=pos, force="neutral"}
		if protective_mode then
			grave.destructible = false
		end
			local grave_inv = grave.get_inventory(defines.inventory.chest)
			local count = 0
		for i, id in ipairs{
			defines.inventory.player_guns,
			defines.inventory.player_tools,
			defines.inventory.player_ammo,
			defines.inventory.player_quickbar,
			defines.inventory.player_armor,
			defines.inventory.player_main,
			defines.inventory.player_trash} do
			local inv = entity.get_inventory(id)
			for j = 1, #inv do
				if inv[j].valid_for_read then
					count = count + 1
					if count > #grave_inv then return end
					grave_inv[count].set_stack(inv[j])	
				end
			end
		end	
	end	
end)
	
script.on_event(defines.events.on_player_died, function(event)
	if global.kill_count_purple == nil then global.kill_count_purple = 0 end
	if global.kill_count_orange == nil then global.kill_count_orange = 0 end
	local player = game.players[event.player_index]
	if player.force.name == "Orange" then
		global.kill_count_purple = global.kill_count_purple + 1  
	end	
	if player.force.name == "Purple" then
		global.kill_count_orange = global.kill_count_orange + 1
	end
	show_update_score()
end)

function make_forces()
	local s = game.surfaces["nauvis"]
	game.forces["player"].chart(s,{{ global.purple_team_x - bd,  global.purple_team_y -bd}, { global.purple_team_x + bd,  global.purple_team_y + bd}} )
	game.forces["player"].chart(s,{{ global.orange_team_x - bd,  global.orange_team_y -bd}, { global.orange_team_x + bd,  global.orange_team_y + bd}} )
	game.create_force("Purple")
	game.create_force("Orange")
	game.create_force("Spectators")
end

function set_spawns()
	s = game.surfaces["nauvis"]
	purple = game.forces["Purple"]
	orange = game.forces["Orange"]
	ppnc = s.find_non_colliding_position("player",  global.purple_team_position, 32,2)
	opnc = s.find_non_colliding_position("player",  global.orange_team_position, 32,2)

	if ppnc ~= nil and opnc ~= nil then
		purple.set_spawn_position({ppnc.x,ppnc.y}, s)
		for k, object in pairs (s.find_entities{{ppnc.x-5,ppnc.y-45},{ppnc.x+5,ppnc.y+5}}) do object.destroy() end
		global.p_roboport = s.create_entity{name = "roboport", position = {ppnc.x,ppnc.y-40}, force = purple}
		global.p_roboport.minable = false
		global.p_roboport.insert{name = "construction-robot", count = 10}
		global.p_roboport.insert{name = "repair-pack", count = 20}
		global.p_roboport.backer_name = "Purple"
		p_turret = s.create_entity{name = "gun-turret", position = {ppnc.x,ppnc.y-5}, force = purple}
		p_turret.insert{name = "piercing-rounds-magazine", count = 50}
		orange.chart(s, {{ppnc.x-32,ppnc.y-42},{ppnc.x+32,ppnc.y+22}})
		orange.set_spawn_position({opnc.x,opnc.y}, s)
		for k, object in pairs (s.find_entities{{opnc.x-5,opnc.y-45},{opnc.x+5,opnc.y+5}}) do object.destroy() end
		global.o_roboport = s.create_entity{name = "roboport", position = {opnc.x,opnc.y-40}, force = orange}
		global.o_roboport.minable = false
		global.o_roboport.insert{name = "construction-robot", count = 10}
		global.o_roboport.insert{name = "repair-pack", count = 20}
		global.o_roboport.backer_name = "Orange"
		o_turret = s.create_entity{name = "gun-turret", position = {opnc.x,opnc.y-5}, force = orange}
		o_turret.insert{name = "piercing-rounds-magazine", count = 50}
		purple.chart(s, {{opnc.x-32,opnc.y-42},{opnc.x+32,opnc.y+22}})
		for k, p in pairs (game.players) do
			p.print("Teams are now unlocked")
		end
		for k, entity in pairs(s.find_entities_filtered({area={{ppnc.x - bd, ppnc.y -bd}, {ppnc.x + bd, ppnc.y + bd}}, force= "enemy"})) do
			entity.destroy()
		end
		for k, entity in pairs(s.find_entities_filtered({area={{opnc.x - bd, opnc.y -bd}, {opnc.x + bd, opnc.y + bd}}, force= "enemy"})) do
			entity.destroy()
		end
    else
		for k, p in pairs (game.players) do 
			p.print("Map unsutitable, please restart")
		end
	end
end

function make_lobby()
	game.print("lobby")
	game.create_surface("Lobby", {width = 96, height = 32, starting_area = "big", water = "none"}) 
end

function set_starting_areas()
	local s = game.surfaces.nauvis
	s.set_tiles{
    		{name = "water", position ={ global.purple_team_x + 16,  global.purple_team_y +16}},
    		{name = "water", position ={ global.purple_team_x + 17,  global.purple_team_y +16}},
    		{name = "water", position ={ global.purple_team_x + 16,  global.purple_team_y +17}},
    		{name = "water", position ={ global.purple_team_x + 17,  global.purple_team_y +17}}
	}
        
	s.set_tiles{
    		{name = "water", position = { global.orange_team_x + 16, global.orange_team_y +16}},
    		{name = "water", position = { global.orange_team_x + 17, global.orange_team_y +16}},
    		{name = "water", position = { global.orange_team_x + 16, global.orange_team_y +17}},
    		{name = "water", position = { global.orange_team_x + 17, global.orange_team_y +17}}
	}

	for k, pr in pairs (s.find_entities_filtered{area = {{ global.purple_team_x-128,  global.purple_team_y-128},{ global.purple_team_x+128,  global.purple_team_y+128}}, type= "resource"}) do
		pr.destroy()
	end
  
	for k, orr in pairs (s.find_entities_filtered{area = {{ global.orange_team_x-128, global.orange_team_y-128}, { global.orange_team_x+128, global.orange_team_y+128}}, type= "resource"}) do
		orr.destroy()
	end
  
	for k, r in pairs (s.find_entities_filtered{area = {{-128, -128}, {128, 128}}, type= "resource"}) do
		local prx = r.position.x
		local pry = r.position.y
		local prx = prx +  global.purple_team_x
		local pry = pry +  global.purple_team_y
		local tile = s.get_tile(prx,pry).name
    
		if tile ~= "water" and tile ~= "deepwater" then
			s.create_entity{name = r.name, position = {prx,pry},force = r.force, amount = r.amount}
		end
      
		local nrx = r.position.x
		local nry = r.position.y
		local nrx = nrx +  global.orange_team_x
		local nry = nry +  global.orange_team_y
		local tile = s.get_tile(nrx,nry).name
      
		if tile ~= "water" and tile ~= "deepwater" then 
			s.create_entity{name = r.name, position = {nrx,nry}, force = r.force, amount = r.amount}
		end
	end
end

function make_team_option(player)
	if player.gui.left.choose_team == nil then
		local frame = player.gui.left.add{name = "choose_team", type = "frame", direction = "vertical", caption="Choose your Team"}
		frame.add{type = "button", caption = "Join Orange Team", name = "orange"}.style.font_color = global.orange_color
        	frame.add{type = "button", caption = "Join Purple Team", name = "purple"}.style.font_color = {r = 0.5,b = 1, g = 0.1}
		if player.admin == true then
			frame.add{type = "button", caption = "Join Spectators", name = "spectator"}.style.font_color = {r = 0.1,b = 0.4,g = 1}
		end
	end
end

function purple_destroy_o()
	surface = game.surfaces["nauvis"]
	global.kill_count_purple = global.kill_count_purple + 40
	show_update_score()
	
	for k, p in pairs (game.players) do
		--if p.force == game.forces["Purple"] then
		p.print("Orange teams Roboport has been destroyed")
		p.print("Purple was Awarded 40 Points")
		--end	
	end
	script.on_event(defines.events.on_tick, kill_orange)
	global.ending_tick = game.tick + 300
end

function orange_destroy_p()
	surface = game.surfaces["nauvis"]
	global.kill_count_orange = global.kill_count_orange + 40
	show_update_score()
	
	for k, p in pairs (game.players) do
		--if p.force == game.forces["Purple"] then
			p.print("Purple teams Roboport has been destroyed")
			p.print("Orange was Awarded 40 Points")
		--end	
	end

	script.on_event(defines.events.on_tick, kill_purple)
	global.ending_tick = game.tick + 300
end
	
	-- if the Orange roboport is destroyed, spawn a series of explosions.
function kill_orange()
	local s = game.surfaces["nauvis"]
	local drx = global.drbp.x
	local dry = global.drbp.y
	if game.tick < global.ending_tick and game.tick % 20 == 0 then
		s.create_entity{position = {drx + math.random(-2,2),dry + math.random(-2,2)}, name = "medium-explosion"}    
	end
	if game.tick == global.ending_tick then 
		s.create_entity{position = {drx,dry}, name = "big-explosion"} 
	end
end

	-- if the Purple roboport is destroyed, spawn a series of explosions.
function kill_purple()
	local s = game.surfaces["nauvis"]
	local drx = global.drbp.x
	local dry = global.drbp.y
	if game.tick < global.ending_tick and game.tick % 20 == 0 then
		s.create_entity{position = {drx + math.random(-2,2),dry + math.random(-2,2)}, name = "medium-explosion"}    
	end
	if game.tick == global.ending_tick then 
		s.create_entity{position = {drx,dry}, name = "big-explosion"} 
	end
end

	--check on tick, to see if anyone has won.
function win()
	if global.kill_count_purple >= 100 then
		global.end_screen = game.tick + 180
		script.on_event(defines.events.on_tick, purple_win) 
	end
	if global.kill_count_orange >= 100 then
		global.end_screen = game.tick + 180
		script.on_event(defines.events.on_tick, orange_win) 
	end
end

function orange_win()
	if game.tick == global.end_screen then 
		for k, player in pairs (game.players) do
			if player.force.name == "Orange" then
				showdialog("You win :D", "Orange team has beaten the Purple team. Well done!")
			end
			if player.force.name == "Purple" then
				showdialog("You lost :(", "Purple team was beaten by the Orange team. Better luck next time.")
			end
		end	
	end	
end

function purple_win()
	if game.tick == global.end_screen then
		for k, player in pairs (game.players) do
			if player.force.name == "Purple" then
				showdialog("You win :D", "Purple team has beaten the Orange team. Well done!")
			end
			if player.force.name == "Orange" then
				showdialog("You lost :(", "Orange team was beaten by the Purple team. Better luck next time.")
			end
		end	
	end	
end

	--gui with a message, event on win.
function showdialog(title, message)
	if game.tick == global.end_screen then
		for i, player in pairs(game.players) do
			if player.gui.center.end_message == nil then
				local frame = player.gui.center.add{type="frame", name="end_message", caption=title, direction="vertical"}
				frame.add{type="label", caption=message}
				frame.add{type="button", name="end_message_button", caption="Close this message"}
			end
		end
	end
end

	-- when a player clicks the gui button to join orange.
function join_orange(event)
	local s = game.surfaces.nauvis
	local player = game.players[event.player_index]
   	local index = event.player_index
	if player.character == nil then
        	if player.connected then
            	local character = player.surface.create_entity{name = "player", position = player.surface.find_non_colliding_position("player", player.force.get_spawn_position(player.surface), 10, 2), force = force}
            	player.set_controller{type = defines.controllers.character, character = character}
        	end
    	end
	global.orange_count_total = global.orange_count_total + 1
	player.teleport(game.forces["Orange"].get_spawn_position(s), game.surfaces.nauvis)
	player.color = global.orange_color
	player.force = game.forces["Orange"]
	player.gui.left.choose_team.destroy()
	starting_inventory(event)
	update_count()
	player.print("Destroy the Purple Roboport for 40 extra points")      
	for k, p in pairs (game.players) do
		p.print(player.name.." has joined team Orange")
	end
end

--when a player clicks the gui button to join purple.
function join_purple(event)
	local s = game.surfaces.nauvis
	local player = game.players[event.player_index]
    	local index = event.player_index
	if player.character == nil then
        	if player.connected then
            		local character = player.surface.create_entity{name = "player", position = player.surface.find_non_colliding_position("player", player.force.get_spawn_position(player.surface), 10, 2), force = force}
            		player.set_controller{type = defines.controllers.character, character = character}
        	end
    	end
	global.purple_count_total = global.purple_count_total + 1
	player.teleport(game.forces["Purple"].get_spawn_position(s), game.surfaces.nauvis)
	player.color = global.purple_color
	player.force = game.forces["Purple"]
	player.gui.left.choose_team.destroy()
	starting_inventory(event)
	update_count()
	player.print("Destroy the Orange Roboport for 40 extra points")
	for k, p in pairs (game.players) do
		p.print(player.name.." has joined team Purple")
	end
end

function starting_inventory(event)
	local player = game.players[event.player_index]
    	local index = event.player_index
	player.insert{name="iron-plate", count=8}
	player.insert{name="submachine-gun", count=1}
	player.insert{name="piercing-rounds-magazine", count=100}
	player.insert{name="burner-mining-drill", count = 5}
	player.insert{name="stone-furnace", count = 10}
end

-- distance between bases
script.on_init(function()
	global.purple_team_x = math.random(370,380)
	global.purple_team_y = math.random(0,0)
	global.purple_team_position ={ global.purple_team_x, global.purple_team_y}
	global.purple_team_area = {{ global.purple_team_x - d,  global.purple_team_y - d},{ global.purple_team_x + d,  global.purple_team_y + d}}
	global.orange_team_x = 0 - math.random(370,380)
	global.orange_team_y = 0 - math.random(0,0)
	global.orange_team_position = { global.orange_team_x, global.orange_team_y}
	global.orange_team_area = {{ global.orange_team_x - d,  global.orange_team_y - d},{ global.orange_team_x + d,  global.orange_team_y + d}}
  
	init_attack_data()
	make_forces()  
	make_lobby()
end)

script.on_event(defines.events.on_player_created, function(event)
	if global.orange_count == nil then
		global.orange_count = 0
	end
	if global.purple_count == nil then
		global.purple_count = 0
	end
	local player = game.players[event.player_index]
	player.teleport({0,8},game.surfaces["Lobby"])
	player.print({"msg-intro1"})
	player.print({"msg-intro2"})
 
	if game.tick > 50*60 then    ------------*************vvvvvvthese have to match**********----------
		make_team_option(player)
	else 
		player.print({"msg-intro3"})
	end
end)

script.on_event(defines.events.on_tick, function(event)
	show_health()
	win()
  	if game.tick % 20 == 0 then
		color()
  	end
	if game.tick == 50 * 60 then  ----------*************^^^^these have to match**********----------
		set_spawns()
		for k, p in pairs (game.players) do
			make_team_option(p)
		end
		set_starting_areas()
	end
		
	--global variables for the message desplay
	if global.timer_value == nil then global.timer_value = 0 end
	if global.timer_wait == nil then global.timer_wait = 595 end
	if global.timer_display == nil then global.timer_display = 1 end
	
	local current_time = game.tick / 60 - global.timer_value
	local message_display = "test"
	if current_time >= global.timer_wait then
		if global.timer_display == 1 then
			message_display = {"msg-announce1"}
			global.timer_display = 2
		else
			message_display = {"msg-announce2"}
			global.timer_display = 1
		end
		for k, player in pairs(game.players) do
			player.print(message_display)
		end
		global.timer_value = game.tick / 60
	end
end)

script.on_event(defines.events.on_gui_click, function(event)
	local s = game.surfaces.nauvis
	local player = game.players[event.player_index]
    	local index = event.player_index
    	local element = event.element.name
		
	if player.gui.top.flashlight == nil then
        	if element ~= nil then
            	if element == "flashlight" then
                	if player.character == nil then return end
                	if global.player_flashlight_state == nil then global.player_flashlight_state = {} end
                	if global.player_flashlight_state[event.player_index] == nil then global.player_flashlight_state[event.player_index] = true end
    
                	if global.player_flashlight_state[event.player_index] then
                   		global.player_flashlight_state[event.player_index] = false
                    		player.character.disable_flashlight()
                	else
                    		global.player_flashlight_state[event.player_index] = true
                    		player.character.enable_flashlight()
                	end
            	end
        end
	end	
	if player.gui.center.end_message ~= nil then
		if (event.element.name == "end_message_button") then
			player.gui.center.end_message.destroy()
		end
    	end
	if player.gui.left.choose_team ~= nil then
		if (event.element.name == "orange") then
			if global.orange_count > global.purple_count then player.print("Too many Players on that team") return end
				join_orange(event)
		end
	end
	if player.gui.left.choose_team ~= nil then
		if (event.element.name == "purple") then
			if global.purple_count > global.orange_count then player.print("Too many Players on that team") return end
				join_purple(event)
		end
	end
	if player.gui.left.choose_team ~= nil then
		if (event.element.name == "spectator") then
			force_spectators(index)
		end
		--destroy.character
		--make controller ghost
	end
    	if player.gui.left.spectate ~= nil then
        	if element ~= nil then
            		if element == "spectate" then
              			force_spectators(index)
            		end
        	end
    	end
end)

function show_health()
    	for k, player in pairs(game.players) do
		if player.connected then
			if player.character then
				if player.character.health == nil then return end
				local index = player.index
				local health = math.ceil(player.character.health)
				if global.player_health == nil then global.player_health = {} end
				if global.player_health[index] == nil then global.player_health[index] = health end
				if global.player_health[index] ~= health then
					global.player_health[index] = health
					if health < 80 then
						if health > 50 then
							player.surface.create_entity{name="flying-text", color={b = 0.2, r= 0.1, g = 1, a = 0.8}, text=(health), position= {player.position.x, player.position.y-2}}
						elseif health > 29 then
							player.surface.create_entity{name="flying-text", color={r = 1, g = 1, b = 0}, text=(health), position= {player.position.x, player.position.y-2}}
						else
							player.surface.create_entity{name="flying-text", color={b = 0.1, r= 1, g = 0, a = 0.8}, text=(health), position= {player.position.x, player.position.y-2}}
						end
					end
				end
            		end
        	end
    	end 
end	

function force_spectators(index)
    	local player = game.players[index]
    	if global.player_spectator_state == nil then global.player_spectator_state = {} end
    	if global.player_spectator_character == nil then global.player_spectator_character = {}  end
    	if global.player_spectator_force == nil then global.player_spectator_force = {} end
    	if global.player_spectator_state[index] then
        	--remove spectator mode
        	if player.character == nil and global.player_spectator_character[index] ~= nil then
            		local pos = player.position
			player.set_controller{type=defines.controllers.character, character=global.player_spectator_character[index]}
            		player.teleport(pos)
		end
        global.player_spectator_state[index] = false
        player.force = game.forces[global.player_spectator_force[index].name]
        player.print("Summoning your character")
    else
        --put player in spectator mode
        if player.surface.name == "Lobby" then
            player.teleport(game.forces["Spectators"].get_spawn_position(game.surfaces.nauvis), game.surfaces.nauvis)
        end
        if player.character then
            global.player_spectator_character[index] = player.character
            global.player_spectator_force[index] = player.force
    		--if player.character then
            --    player.character.destroy()
            --end
    		player.set_controller{type = defines.controllers.ghost}
        end
        player.force = game.forces["Spectators"]
        global.player_spectator_state[index] = true
		player.print("You are now a spectator")
    	end
end

-- updates the player count gui for total players joined each force, and players online for each force.
function update_count()
  local orange_total = global.orange_count_total
  local purple_total = global.purple_count_total
  local orange_online = global.orange_count
  local purple_online = global.purple_count
  for k, p in pairs (game.players) do
	if p.force == game.forces.Orange then
		if p.connected then
			orange_online = orange_online + 1
		end
	end	
  end
  for k,p in pairs(game.players) do
	if p.force == game.forces.Purple then
		if p.connected then
			purple_online = purple_online + 1
		end
	end	
  end
  local orange_status = "orange("..orange_online.."/"..global.orange_count_total..")"
  local purple_status = "purple("..purple_online.."/"..global.purple_count_total..")"
  for k,p in pairs(game.players) do
    if p.gui.left.persons == nil then
		local frame = p.gui.left.add{name="persons",type="frame",direction="horizontal",caption="Players"}
		frame.add{type="label",name="orange",caption=orange_status}.style.font_color = global.orange_color
		frame.add{type="label", name="Vs", caption= "VS", style="caption_label_style"}
		frame.add{type="label",name="purple",caption=purple_status,}.style.font_color = {r = 0.5,b = 1, g = 0.1}
    else
		p.gui.left.persons.orange.caption = orange_status
		p.gui.left.persons.purple.caption = purple_status
    end
  end
end

	--this is for a server to monotor chat and print chat in game from a web page.(@StudMuffin/Discord)
function server_message(user, message)
    	print("[WEB] ", user, ": ", message)
    	for _, p in pairs (game.connected_players) do
        	p.print("[WEB] ", user, ": ", message)
    	end
end

function show_update_score()
	if global.kill_count_purple == nil then global.kill_count_purple = 0 end
	if global.kill_count_orange == nil then global.kill_count_orange = 0 end
	if global.kill_count_orange > 0 or global.kill_count_purple > 0 then
		for index, player in pairs(game.players) do
			if player.gui.left.kill_score == nil then
				local frame = player.gui.left.add{name = "kill_score", type = "frame", direction = "horizontal", caption="Kill score"}
				frame.add{type = "label", caption = global.kill_count_orange, name = "kill_count_orange"}.style.font_color = global.orange_color
				frame.add{type = "label", caption = global.kill_count_purple, name = "kill_count_purple"}.style.font_color = {r = 0.5,b = 1, g = 0.1}
			else
				player.gui.left.kill_score.kill_count_purple.caption = tostring(global.kill_count_purple)
				player.gui.left.kill_score.kill_count_orange.caption = tostring(global.kill_count_orange)
			end
		end
	end
	win()
end

function color()
	for _, player in pairs (game.connected_players) do
    		local temp_r = tonumber(string.format("%." .. (1 or 0) .. "f", player.color.r))
    		local temp_b = tonumber(string.format("%." .. (1 or 0) .. "f", player.color.b))
    		local temp_g = tonumber(string.format("%." .. (1 or 0) .. "f", player.color.g))
    		local temp_a = tonumber(string.format("%." .. (1 or 0) .. "f", player.color.a))
		if player.force == game.forces["Orange"] then
			--compare orange color
			if temp_r ~= global.orange_color.r
        		or temp_b ~= global.orange_color.b
       			or temp_g ~= global.orange_color.g
        		then
				player.color = global.orange_color
				player.print("Not allowed to change your color.")
			end
		end    
		if player.force == game.forces["Purple"] then
			---compare purple color
			if temp_r ~= global.purple_color.r
        		or temp_b ~= global.purple_color.b
        		or temp_g ~= global.purple_color.g
        		then
				player.color = global.purple_color
				player.print("Not allowed to change your color.")
			end
		end
	end
end	
