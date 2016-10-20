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
			player.character_running_speed_modifier = -0.5
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
				join_sparta(event)
		end
	end
	if player.gui.left.choose_team ~= nil then
		if (event.element.name == "troy") then
			if global.troy_count > global.sparta_count then player.print("Too many Players in Troy, try Sparta") return end
				join_troy(event)
		end
	end
    if player.gui.left.spectate ~= nil then
        if element ~= nil then
            if element == "spectate" then
                force_spectators(index)
            end
        end
    end
end)

function make_team_option(player)
	if player.gui.left.choose_team == nil then
		local frame = player.gui.left.add{name = "choose_team", type = "frame", direction = "vertical", caption="Choose your Team"}
		frame.add{type = "button", caption = "Join Sparta", name = "sparta"}.style.font_color = global.sparta_color
       	frame.add{type = "button", caption = "Join Troy", name = "troy"}.style.font_color = global.troy_color
	end
end


--using this to order the gui'
function create_buttons(event)
	local player = game.players[event.player_index]
    if (not player.gui.top["flashlight_button"]) then
		player.gui.left.add{type="button", name="flashlight_button", caption="flashlight"}
	end

	if player.gui.left.crouch == nil then
		local frame = player.gui.left.add{name = "crouch_button", type = "button", direction = "horizontal", caption = "crouch"}
	end
	if player.admin == true then
        if player.gui.left.spectate == nil then
            local adminframe = player.gui.left.add{name = "spectate", type = "button", direction = "horizontal", caption = "spectate"}
        end
	end
end	