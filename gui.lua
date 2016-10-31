--Gui elements
Event.register(defines.events.on_gui_click, function(event)
	local s = game.surfaces.nauvis
	local player = game.players[event.player_index]
	local index = event.player_index
	local element = event.element.name
		
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
		end
	end
	if player.gui.left.choose_team ~= nil then
		if (event.element.name == "troy") then
			if global.troy_count > global.sparta_count then player.print("Too many Players in Troy, try Sparta") return end
			join_a_team(event, "Troy", "Sparta")
		end
	end
	if player.gui.left.choose_team ~= nil then
		if (event.element.name == "spectator") then
			force_spectators(index)
			player.gui.left.choose_team.spectator.destroy()
		end
	end	
	if player.gui.left.spectate ~= nil then
		if element ~= nil then
			if element == "spectate" then
				if player.admin then
					force_spectators(index)
				else
					player.print("You are no longer an admin")
					player.gui.left.spectate.destroy()
				end
			end
		end
	end
end)

function make_team_option(player)
	if player.gui.left.choose_team == nil then
		local frame = player.gui.left.add{name = "choose_team", type = "frame", direction = "vertical", caption="Choose your Team"}
		frame.add{type = "button", caption = "Join Spectators", name = "spectator"}.style.font_color = {r= 0/256, g=  255/256, b=  255/256}
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
	if player.admin == true then
		if (not player.gui.left["spectate"]) then
			player.gui.left.add{name = "spectate", type = "button", direction = "horizontal", caption = "Spectate"}
		end
	end
end	