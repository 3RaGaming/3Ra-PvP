--Gui elements
script.on_event(defines.events.on_gui_click, function(event)
	local s = game.surfaces.nauvis
	local player = game.players[event.player_index]
    local index = event.player_index
    local element = event.element.name
		
	-- Turns on/off Flashlight

	if (event.element.name == "flashlight_button") then
		if player.character == nil then return end
			if global.player_flashlight_state == nil then
				global.player_flashlight_state = {}
			end
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
		if global.player_crouch_state == nil then
			global.player_crouch_state = {}
		end
		if global.player_crouch_state == true then
			player.character_running_speed_modifier = 0
			if player.force == "Troy" then
				player.color = global.troy_color
			end
			if player.force == "Sparta" then
				player.color = global.sparta_color
			end
			global.player_crouch_state = false
		else 
			global.player_crouch_state = true
			player.character_running_speed_modifier = -0.6
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
	end
end

-- updates the player count gui for total players joined each force, and players online for each force.
function update_count(p)
	local sparta_status = "Sparta("..global.sparta_count..")"
	local troy_status = "Troy("..global.troy_count..")"
    if p ~= nil then
        if p.force.name == "Troy" then
            global.troy_count = global.troy_count + 1
        end
        if p.force.name == "Sparta" then
            global.sparta_count = global.sparta_count + 1
        end
    end
	for k,p in pairs(game.connected_players) do
		if p.gui.top.persons == nil then
			local frame = p.gui.top.add{name="persons",type="flow",direction="horizontal"}
			frame.add{type="flow",name="space",direction="horizontal"}.style.minimal_width = 800
			frame.add{type="label",name="sparta",caption=sparta_status, style = "caption_label_style"}.style.font_color = global.sparta_color
			frame.add{type="label", name="Vs", caption= "VS", style="caption_label_style"}
			frame.add{type="label",name="troy",caption=troy_status, style = "caption_label_style"}.style.font_color = global.troy_color
		else
			p.gui.top.persons.sparta.caption = sparta_status
			p.gui.top.persons.troy.caption = troy_status
		end
	end
end

function show_update_score()
	if global.kill_count_troy == nil then global.kill_count_troy = 0 end
	if global.kill_count_sparta == nil then global.kill_count_sparta = 0 end
	if global.kill_count_sparta > 0 or global.kill_count_troy > 0 then
		for index, player in pairs(game.players) do
			if player.gui.left.kill_score == nil then
				local frame = player.gui.left.add{name = "kill_score", type = "flow", direction = "horizontal", caption="Kill score"}
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

--using this to order the gui'
function create_buttons(event)
	local player = game.players[event.player_index]
    if (not player.gui.left["flashlight_button"]) then
		player.gui.left.add{type="button", name="flashlight_button", caption="flashlight"}
	end

	if (not player.gui.left["crouch_button"]) then
		local frame = player.gui.left.add{name = "crouch_button", type = "button", direction = "horizontal", caption = "crouch"}
	end
	if player.admin == true then
        if (not player.gui.left["spectate"]) then
            local adminframe = player.gui.left.add{name = "spectate", type = "button", direction = "horizontal", caption = "spectate"}
        end
	end
end	