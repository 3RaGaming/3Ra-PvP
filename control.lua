--Team PVP [Based on Roboport_PvP_Slow by Klonan]
--A 3Ra Gaming revision
if not scenario then scenario = {} end
if not scenario.config then scenario.config = {} end
--config and event must be called first.
--require "config"
require "locale/utils/event"
require "locale/utils/admin"
require "locale/utils/undecorator"
require "server"
require "technologies"
require "win"

--Starting Variables
global.kill_count_troy = 0
global.kill_count_sparta = 0

global.sparta_count = 0
global.troy_count = 0

-- make sure base is at least 1000x1000
global.base_min_separation = 700
global.base_max_separation = 800

global.base_separation = 0
global.base_rotation = 0

global.spawn_size = 90

-- controls how much slower you run as you lose health
global.crippling_factor = 1

--area found for destoying biters around team spawn
d = 32*3
bd = d*3

--global team colors
global.sparta_color = {b = 0, r= 0.9, g = 0.4, a = 0.8}
global.troy_color = {r = 0.1,b = 0.4,g = 1}


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
  -- randomly rotate bases to make it more interesting
  global.base_separation = math.random(global.base_min_separation,global.base_max_separation)/2
  global.base_rotation = math.random(0,math.pi*2)
  
  global.troy_team_x = global.base_separation*math.cos(global.base_rotation)
  global.troy_team_y = global.base_separation*math.sin(global.base_rotation)
  global.troy_team_position ={ global.troy_team_x, global.troy_team_y}
  global.troy_team_area = {{ global.troy_team_x - d,  global.troy_team_y - d},{ global.troy_team_x + d,  global.troy_team_y + d}}
  
  global.sparta_team_x = global.base_separation*math.cos(math.pi + global.base_rotation)
  global.sparta_team_y = global.base_separation*math.sin(math.pi + global.base_rotation)
  global.sparta_team_position = { global.sparta_team_x, global.sparta_team_y}
  global.sparta_team_area = {{ global.sparta_team_x - d,  global.sparta_team_y - d},{ global.sparta_team_x + d,  global.sparta_team_y + d}}
  
	init_attack_data()
	make_forces()
	make_lobby()
end)

--global variables for the message desplay
global.timer_value = 0
global.timer_wait = 600
global.timer_display = 1

script.on_event(defines.events.on_tick, function(event)
  if game.tick % 20 == 0 then
		show_health()
  end
	if game.tick == 50 * 60 then  ----------*************^^^^these have to match**********----------
		set_spawns()
		set_starting_areas()
		research_technology()
		for k, p in pairs (game.players) do
			make_team_option(p)
		end
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
	if global.sparta_count == nil then
		global.sparta_count = 0
	end
	if global.troy_count == nil then
		global.troy_count = 0
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
		if (event.element.name == "sparta") then
			if global.sparta_count > global.troy_count then player.print("Too many Players in Sparta, try Troy") return end
				join_sparta(event)
		end
	end
	if player.gui.left.choose_team ~= nil then
		if (event.element.name == "troy") then
			if global.troy_count > global.sparta_count then player.print("Too many Players in Troy, try Sparta") return end
				join_troy(event)
		end
	end
	if player.gui.left.choose_team ~= nil then
		if (event.element.name == "spectator") then
			join_spectators()
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
	if player.force == game.forces["Sparta"] then
		global.sparta_count = global.sparta_count + 1
	end
	if player.force == game.forces["Troy"] then
		global.troy_count = global.troy_count + 1
	end
	show_update_score()
	update_count()
 end)

script.on_event(defines.events.on_player_left_game, function(event)
	player = game.players[event.player_index]
	if player.force == game.forces["Sparta"] then
		global.sparta_count = global.sparta_count - 1
	end
	if player.force == game.forces["Troy"] then
		global.troy_count = global.troy_count - 1
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

-- on death (player) spawn a "grave" at their location holding thier loot.
script.on_event(defines.events.on_entity_died, function(event)
	local entity = event.entity

	if entity == global.p_roboport then
		global.drbp = entity.position sparta_destroy_p()
	end
	if entity == global.o_roboport then
		global.drbp = entity.position troy_destroy_o()
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
	if global.kill_count_troy == nil then global.kill_count_troy = 0 end
	if global.kill_count_sparta == nil then global.kill_count_sparta = 0 end
	local player = game.players[event.player_index]
	if player.force.name == "Sparta" then
		global.kill_count_troy = global.kill_count_troy + 1  
	end	
	if player.force.name == "Troy" then
		global.kill_count_sparta = global.kill_count_sparta + 1
	end
	show_update_score()
end)

function make_forces()
	local s = game.surfaces["nauvis"]
	--chart the area so the game can coppy the recourses 
	game.forces["player"].chart(s,{{ global.troy_team_x - bd,  global.troy_team_y -bd}, { global.troy_team_x + bd,  global.troy_team_y + bd}} )
	game.forces["player"].chart(s,{{ global.sparta_team_x - bd,  global.sparta_team_y -bd}, { global.sparta_team_x + bd,  global.sparta_team_y + bd}} )
	game.create_force("Troy")
	game.create_force("Sparta")
	game.create_force("Spectators")
end

function set_spawns()
	s = game.surfaces["nauvis"]
	troy = game.forces["Troy"]
	sparta = game.forces["Sparta"]
	ppnc = s.find_non_colliding_position("player",  global.troy_team_position, 32,2)
	opnc = s.find_non_colliding_position("player",  global.sparta_team_position, 32,2)

	if ppnc ~= nil and opnc ~= nil then
		troy.set_spawn_position({ppnc.x,ppnc.y}, s)
		for k, object in pairs (s.find_entities{{ppnc.x-global.spawn_size/2,ppnc.y-global.spawn_size/2},{ppnc.x+global.spawn_size/2,ppnc.y+global.spawn_size/2}}) do object.destroy() end
		global.p_roboport = s.create_entity{name = "roboport", position = {ppnc.x,ppnc.y-40}, force = troy}
		global.p_roboport.minable = false
		global.p_roboport.insert{name = "construction-robot", count = 10}
		global.p_roboport.insert{name = "repair-pack", count = 20}
		global.p_roboport.backer_name = "Troy"
		p_turret = s.create_entity{name = "gun-turret", position = {ppnc.x,ppnc.y-5}, force = troy}
		p_turret.minable = false
		p_turret.destructible = false
		p_turret.insert{name = "piercing-rounds-magazine", count = 50}
    
		sparta.set_spawn_position({opnc.x,opnc.y}, s)
		for k, object in pairs (s.find_entities{{opnc.x-global.spawn_size/2,opnc.y-global.spawn_size/2},{opnc.x+global.spawn_size/2,opnc.y+global.spawn_size/2}}) do object.destroy() end
		global.o_roboport = s.create_entity{name = "roboport", position = {opnc.x,opnc.y-40}, force = sparta}
		global.o_roboport.minable = false
		global.o_roboport.insert{name = "construction-robot", count = 10}
		global.o_roboport.insert{name = "repair-pack", count = 20}
		global.o_roboport.backer_name = "Sparta"
		o_turret = s.create_entity{name = "gun-turret", position = {opnc.x,opnc.y-5}, force = sparta}
		o_turret.minable = false
		o_turret.destructible = false
		o_turret.insert{name = "piercing-rounds-magazine", count = 50}
		
		
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
  
  for x=-global.spawn_size,global.spawn_size,1 do
    for y=-global.spawn_size,global.spawn_size,1 do
      local tile = s.get_tile(global.troy_team_x+x,global.troy_team_y+y)
      if (tile.name == "water" or tile.name == "deepwater") then
        s.set_tiles{{name = "grass", position = { global.troy_team_x+x,global.troy_team_y+y}}}  
      end
      tile = s.get_tile(global.sparta_team_x+x,global.sparta_team_y+y)
      if (tile.name == "water" or tile.name == "deepwater") then
        s.set_tiles{{name = "grass", position = { global.sparta_team_x+x,global.sparta_team_y+y}}} 
      end
    end
  end
  
	s.set_tiles{
    		{name = "water", position ={ global.troy_team_x + 16,  global.troy_team_y +16}},
    		{name = "water", position ={ global.troy_team_x + 17,  global.troy_team_y +16}},
    		{name = "water", position ={ global.troy_team_x + 16,  global.troy_team_y +17}},
    		{name = "water", position ={ global.troy_team_x + 17,  global.troy_team_y +17}}
	}
        
	s.set_tiles{
    		{name = "water", position = { global.sparta_team_x + 16, global.sparta_team_y +16}},
    		{name = "water", position = { global.sparta_team_x + 17, global.sparta_team_y +16}},
    		{name = "water", position = { global.sparta_team_x + 16, global.sparta_team_y +17}},
    		{name = "water", position = { global.sparta_team_x + 17, global.sparta_team_y +17}}
	}

	for k, pr in pairs (s.find_entities_filtered{area = {{ global.troy_team_x-global.spawn_size,  global.troy_team_y-global.spawn_size},{ global.troy_team_x+global.spawn_size,  global.troy_team_y+global.spawn_size}}, type= "resource"}) do
		pr.destroy()
	end
  
	for k, orr in pairs (s.find_entities_filtered{area = {{ global.sparta_team_x-global.spawn_size, global.sparta_team_y-global.spawn_size}, { global.sparta_team_x+global.spawn_size, global.sparta_team_y+global.spawn_size}}, type= "resource"}) do
		orr.destroy()
	end
  
	for k, r in pairs (s.find_entities_filtered{area = {{-global.spawn_size, -global.spawn_size}, {global.spawn_size, global.spawn_size}}, type= "resource"}) do
		local prx = r.position.x
		local pry = r.position.y
		local prx = prx +  global.troy_team_x
		local pry = pry +  global.troy_team_y
		local tile = s.get_tile(prx,pry).name
    
		if tile ~= "water" and tile ~= "deepwater" then
			s.create_entity{name = r.name, position = {prx,pry},force = r.force, amount = r.amount}
		end
      
		local nrx = r.position.x
		local nry = r.position.y
		local nrx = nrx +  global.sparta_team_x
		local nry = nry +  global.sparta_team_y
		local tile = s.get_tile(nrx,nry).name
      
		if tile ~= "water" and tile ~= "deepwater" then 
			s.create_entity{name = r.name, position = {nrx,nry}, force = r.force, amount = r.amount}
		end
	end
end

function make_team_option(player)
	if player.gui.left.choose_team == nil then
		local frame = player.gui.left.add{name = "choose_team", type = "frame", direction = "vertical", caption="Choose your Team"}
		frame.add{type = "button", caption = "Join Sparta", name = "sparta"}.style.font_color = global.sparta_color
        	frame.add{type = "button", caption = "Join Troy", name = "troy"}.style.font_color = global.troy_color
			frame.add{type = "button", caption = "Join Spectators", name = "spectator"}.style.font_color = {b = 0.91, r = 0.55, g = 0.26, a = 1}
		end
	end
end

-- when a player clicks the gui button to join sparta.
function join_sparta(event)
	local s = game.surfaces.nauvis
	local player = game.players[event.player_index]
   	local index = event.player_index
	if player.character == nil then
        	if player.connected then
            	local character = player.surface.create_entity{name = "player", position = player.surface.find_non_colliding_position("player", player.force.get_spawn_position(player.surface), 10, 2), force = force}
            	player.set_controller{type = defines.controllers.character, character = character}
        	end
    	end
	global.sparta_count = global.sparta_count + 1
	player.teleport(game.forces["Sparta"].get_spawn_position(s), game.surfaces.nauvis)
	player.color = global.sparta_color
	player.force = game.forces["Sparta"]
	player.gui.left.choose_team.destroy()
	starting_inventory(event)
	update_count()
	player.print("Destroy the Troy Roboport for 40 extra points")      
	for k, p in pairs (game.players) do
		p.print(player.name.." of Sparta has entered the arena")
	end
end

--when a player clicks the gui button to join Troy.
function join_troy(event)
	local s = game.surfaces.nauvis
	local player = game.players[event.player_index]
    	local index = event.player_index
	if player.character == nil then
        	if player.connected then
            		local character = player.surface.create_entity{name = "player", position = player.surface.find_non_colliding_position("player", player.force.get_spawn_position(player.surface), 10, 2), force = force}
            		player.set_controller{type = defines.controllers.character, character = character}
        	end
    	end
	global.troy_count = global.troy_count + 1
	player.teleport(game.forces["Troy"].get_spawn_position(s), game.surfaces.nauvis)
	player.color = global.troy_color
	player.force = game.forces["Troy"]
	player.gui.left.choose_team.destroy()
	starting_inventory(event)
	update_count()
	player.print("Destroy the Spartan Roboport for 40 extra points")
	for k, p in pairs (game.players) do
		p.print(player.name.." of Troy has entered the arena")
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
	player.insert{name="raw-fish", count = 10}
end

	-- shows player health as a text float.
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
					-- slows the player just slightly if not at full health
					player.character_running_speed_modifier = -.1*(100-health)*global.crippling_factor/100
					-- prints player health when < 80%
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

-- for non admins spectating without a character
function join_spectators()
	local player = game.players[index]
	if global.player_spectator_state == nil then global.player_spectator_state = {} end
	if global.player_spectator_character == nil then global.player_spectator_character = {}  end
	if global.player_spectator_force == nil then global.player_spectator_force = {} end
	if global.player_spectator_state[index] then
		--put player in spectator mode
		if player.surface.name == "Lobby" then
			player.teleport(game.forces["Spectators"].get_spawn_position(game.surfaces.nauvis), game.surfaces.nauvis)
		end
		if player.character then
			player.character.destroy()
			global.player_spectator_force[index] = player.force
			player.set_controller{type = defines.controllers.ghost}
		end
		player.force = game.forces["Spectators"]
		global.player_spectator_state[index] = true
		player.print("You are now a spectator")
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
			player.set_controller{type = defines.controllers.ghost}
		end
		player.force = game.forces["Spectators"]
		global.player_spectator_state[index] = true
		player.print("You are now a spectator")
	end
end

-- before a player dies clears cursor so can be added to their grave.
script.on_event(defines.events.on_pre_player_died, function(event)
	local player = game.players[event.player_index]
	player.clean_cursor()
end)

-- updates the player count gui for total players joined each force, and players online for each force.
function update_count()
  local sparta_status = "Sparta("..global.sparta_count..")"
  local troy_status = "Troy("..global.troy_count..")"
  for k,p in pairs(game.players) do
    if p.gui.left.persons == nil then
		local frame = p.gui.left.add{name="persons",type="frame",direction="horizontal",caption="Players"}
		frame.add{type="label",name="sparta",caption=sparta_status}.style.font_color = global.sparta_color
		frame.add{type="label", name="Vs", caption= "VS", style="caption_label_style"}
		frame.add{type="label",name="troy",caption=troy_status,}.style.font_color = global.troy_color
    else
		p.gui.left.persons.sparta.caption = sparta_status
		p.gui.left.persons.troy.caption = troy_status
    end
  end
end

--Special command for communicating through our custom web-gui
function server_message(user, message)
    print("[WEB] "..user..": "..message)
    game.print("[WEB] "..user..": "..message)
end

function show_update_score()
	if global.kill_count_troy == nil then global.kill_count_troy = 0 end
	if global.kill_count_sparta == nil then global.kill_count_sparta = 0 end
	if global.kill_count_sparta > 0 or global.kill_count_troy > 0 then
		for index, player in pairs(game.players) do
			if player.gui.left.kill_score == nil then
				local frame = player.gui.left.add{name = "kill_score", type = "frame", direction = "horizontal", caption="Kill score"}
				frame.add{type = "label", caption = global.kill_count_sparta, name = "kill_count_sparta"}.style.font_color = global.sparta_color
				frame.add{type = "label", caption = global.kill_count_troy, name = "kill_count_troy"}.style.font_color = global.troy_color
			else
				player.gui.left.kill_score.kill_count_troy.caption = tostring(global.kill_count_troy)
				player.gui.left.kill_score.kill_count_sparta.caption = tostring(global.kill_count_sparta)
			end
		end
	end
	win()
end
