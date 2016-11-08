--Gui elements
Event.register(defines.events.on_gui_click, function(event)
	local s = game.surfaces.nauvis
	local player = game.players[event.player_index]
    local index = event.player_index
	
	if not event.element.valid then
		return
	end
	-- Turns on/off Flashlight
	if (event.element.name == "flashlight_button") then
		if player.character == nil then return end
			global.player_flashlight_state = global.player_flashlight_state or {}
			if global.player_flashlight_state == true then
				player.character.enable_flashlight()
				global.player_flashlight_state = false
			else
				player.character.disable_flashlight()
				global.player_flashlight_state = true
			end
			return
	end
	if (event.element.name == "crouch_button") then
		if player.character == nil then return end
		global.player_crouch_state = global.player_crouch_state or {}
        global.player_crouch_color = global.player_crouch_color or {}
		if global.player_crouch_state == true then
			global.player_crouch_state = false
			player.character_running_speed_modifier = 0
			player.color = global.player_crouch_color
		else 
			global.player_crouch_state = true
			player.character_running_speed_modifier = -0.6
            global.player_crouch_color = player.color
			player.color = black				
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
			join_a_team(event, "Sparta", "Troy")
		elseif (event.element.name == "troy") then
			if global.troy_count > global.sparta_count then player.print("Too many Players in Troy, try Sparta") return end
			join_a_team(event, "Troy", "Sparta")
		elseif (event.element.name == "spectator") then
			player.teleport(game.forces["Spectators"].get_spawn_position(game.surfaces.nauvis), game.surfaces.nauvis)
			if player.character then player.character.destroy() end
			if player.admin then
			global.player_spectator_character = global.player_spectator_character or {}
				if (global.player_spectator_character[index] and global.player_spectator_character[index].valid) then global.player_spectator_character[index].destroy() end
				-- Creating an Admins force so that it the admin.lua code from util's has a force to send the admin back to
				if not game.forces["Admins"] then
					game.create_force("Admins")
					for k, f in pairs(game.forces) do
						f.set_cease_fire(game.forces["Admins"], true)
					end
				end
				global.player_spectator_force = global.player_spectator_force or {}
				global.player_spectator_force[index] = game.forces["Admins"]
				force_spectators(index, nil)
			else
				player.set_controller{type = defines.controllers.ghost}
				player.print("You are now a spectator. You are unable to interact with the game until you join a team.")
			end
			player.gui.left.choose_team.spectator.destroy()
		end
	end	
end)

function make_team_option(player)
	if player.gui.left.choose_team == nil then
		local frame = player.gui.left.add{name = "choose_team", type = "frame", direction = "vertical", caption="Choose your Team"}
			if player.admin then
				frame.add{type = "button", caption = "Join Spectators", name = "spectator"}.style.font_color = {r= 0/256, g=  255/256, b=  255/256}
			end
		if player.admin then frame.spectator.caption = "Join Admins" end
		frame.add{type = "button", caption = "Join Sparta", name = "sparta"}.style.font_color = global.sparta_color
       	frame.add{type = "button", caption = "Join Troy", name = "troy"}.style.font_color = global.troy_color
        player.print("Teams are now unlocked")
	end
end

-- updates the player count gui for total players joined each force, and players online for each force.
function update_count()
	local sparta_status = "Sparta("..#game.forces["Sparta"].connected_players..")"
    local troy_status = "Troy("..#game.forces["Troy"].connected_players..")"
	for _, p in pairs(game.connected_players) do
		if p.gui.top.persons == nil then
			local frame = p.gui.top.add{name = "persons", type = "frame", direction = "horizontal", caption="Players Online"}
			frame.add{type = "label", caption = sparta_status, name = "sparta"}.style.font_color = global.sparta_color
			frame.add{type = "label", caption = troy_status, name = "troy"}.style.font_color = global.troy_color
		else
			p.gui.top.persons.sparta.caption = sparta_status
			p.gui.top.persons.troy.caption = troy_status
		end
	end
end

function show_update_score()
	local sparta_status = "Sparta("..global.kill_count_sparta..")"
	local troy_status = "Troy("..global.kill_count_troy..")"
	if global.kill_count_troy == nil then global.kill_count_troy = 0 end
	if global.kill_count_sparta == nil then global.kill_count_sparta = 0 end
		for index, p in pairs(game.players) do
			if p.gui.top.kill_score == nil then
				local frame = p.gui.top.add{name="kill_score",type="flow",direction="horizontal"}
				frame.add{type="flow",name="space",direction="horizontal"}.style.minimal_width = 550
				frame.add{type="label",name="kill_count_sparta",caption=sparta_status, style = "caption_label_style"}.style.font_color = global.sparta_color
				frame.add{type="label", name="Vs", caption= "VS", style="caption_label_style"}
				frame.add{type="label",name="kill_count_troy",caption=troy_status, style = "caption_label_style"}.style.font_color = global.troy_color
				p.gui.top.kill_score.kill_count_sparta.caption = sparta_status
				p.gui.top.kill_score.kill_count_troy.caption = troy_status
			else
				p.gui.top.kill_score.kill_count_troy.caption = tostring(troy_status)
				p.gui.top.kill_score.kill_count_sparta.caption = tostring(sparta_status)
			end
		end
	win()
end

--using this to order the gui'
function create_buttons(event)
	local player = game.players[event.player_index]
    if (not player.gui.top["flashlight_button"]) then
		player.gui.top.add{type="button", name="flashlight_button", caption="Flashlight"}
	end

	if (not player.gui.top["crouch_button"]) then
		local frame = player.gui.top.add{name = "crouch_button", type = "button", direction = "horizontal", caption = "Crouch"}
	end
end	