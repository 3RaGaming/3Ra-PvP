--Gui elements
Event.register(defines.events.on_gui_click, function(event)
	local s = global.surface
	local gui = event.element
	local player = game.players[event.player_index]
	local index = event.player_index
	
	if not event.element.valid then return end
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

	elseif (event.element.name == "crouch_button") then
		if global.setup_finished and not global.teams_currently_preparing then
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

	elseif (event.element.name == "score_button") then
		if player.gui.left.score_board then
			player.gui.left.score_board.destroy()
		else
			local frame = player.gui.left.add{name = "score_board", type = "frame", direction = "vertical", caption = "Player Count"}
			local score_board_table = frame.add{type = "table", name = "score_board_table", colspan = 4}
			score_board_table.add{type = "label", name = "score_board_table_force_name", caption = {"team-name"}}
			score_board_table.add{type = "label", name = "score_board_table_player_count", caption = "Players Joined"}
			score_board_table.add{type = "label", name = "score_board_table_players_online", caption = "Players Online"}
			score_board_table.add{type = "label", name = "score_board_kill_counter", caption = "Kill Count"}
			for k = 1, global.config.number_of_teams do
				local team = global.force_list[k]
				local force = game.forces[team.name]
				if force ~= nil then
					local c = team.color
					local color = {r = 1 - (1 - c[1]) * 0.5, g = 1 - (1 - c[2]) * 0.5, b = 1 - (1 - c[3]) * 0.5, a = 1}
					local name = score_board_table.add{type = "label", name = force.name.."_label", caption = force.name}
					name.style.font_color = color
					score_board_table.add{type = "label", name = force.name.."_count", caption = #force.players}
					score_board_table.add{type = "label", name = force.name.."_online", caption = #force.connected_players}
					score_board_table.add{type = "label", name = force.name.."_kill_count", caption = global.kill_counts[force.name] or 0}
				end
			end
		end

		--Brings up vote-to-surrender dialog
	elseif (event.element.name == "surrender_button") then
		if player.gui.left.surrender_dialog then
			player.gui.left.surrender_dialog.destroy()
		else
			open_surrender_window(player)
		end

	elseif (event.element.name == "surrender_vote_yes") then
		log("start surrender_vote_yes button handling")
		local votes = global.surrender_votes[player.force.name]
		
		local vote_initiated = false
		if not votes.in_progress then
			if is_too_soon_to_surrender(player.force) then return end
			vote_initiated = true
			votes.voted_at_least_once = true
			votes.vote_start_time = game.tick
			player.force.print(player.name .. " initiated a surrender vote.")
			votes.yes_votes_count = 0
			votes.no_votes_count = 0
			votes.not_yet_voted_count = #player.force.connected_players
			votes.in_progress = true
			votes.vote_record = {}
			for i,p in pairs(player.force.players) do
				votes.vote_record[p.index] = "not voted"
				p.gui.top.surrender_button.style.font_color = colors.green
				--open_surrender_window(p)
			end
		else
			local player_record = votes.vote_record[player.index]
			local surrender_error_message = ""
			if not player_record then
				surrender_error_message = "You joined after the vote started and therefore can not vote."
			elseif player_record == "voted Yes" or player_record == "voted No" then
				surrender_error_message = "You already " .. player_record .. "."
			end
			if surrender_error_message ~= "" then
				local surrender_table = player.gui.left.surrender_dialog.surrender_table
				if surrender_table.surrender_error_label then surrender_table.surrender_error_label.destroy() end
				local surrender_error_label = surrender_table.add{type = "label", name = surrender_error_label, caption = surrender_error_message}
				return
			end
		end

		votes.yes_votes_count = votes.yes_votes_count + 1
		--votes.not_yet_voted_count = votes.not_yet_voted_count - 1
		votes.vote_record[player.index] = "voted Yes"
		player.gui.top.surrender_button.style.font_color = colors.yellow
		update_surrender_tally(player, vote_initiated)
	
		log("end surrender_vote_yes button handling")

	elseif (event.element.name == "surrender_vote_no") then
		log("start surrender_vote_no button handling")
		local votes = global.surrender_votes[player.force.name]
		if not votes.in_progress then
			if is_too_soon_to_surrender(player.force) then return end
			local surrender_error_message = "A surrender vote is not in progress."
			open_surrender_window(player)
			local label = add_surrender_label(player, surrender_error_message)
			label.style.font_color = colors.red
		else
			local player_record = votes.vote_record[player.index]
			local surrender_error_message = ""
			if not player_record then
				surrender_error_message = "You joined after the vote started and therefore can not vote."
			end
			if player_record == "voted Yes" or player_record == "voted No" then
				surrender_error_message = "You already " .. player_record .. "."
			end
			if surrender_error_message ~= "" then
				local surrender_table = player.gui.left.surrender_dialog.surrender_table
				if surrender_table.surrender_error_label then surrender_table.surrender_error_label.destroy() end
				local surrender_error_label = surrender_table.add{type = "label", name = surrender_error_label, caption = surrender_error_message}
			else
				votes.no_votes_count = votes.no_votes_count + 1
				--votes.not_yet_voted_count = votes.not_yet_voted_count - 1
				votes.vote_record[player.index] = "voted No"
				player.gui.top.surrender_button.style.font_color = colors.yellow
				update_surrender_tally(player, false)
			end
		end
		log("end surrender_vote_no button handling")

	elseif gui.name == "balance_options_confirm" then
		set_balance_settings(gui.parent.balance_options_scrollpane)
		gui.parent.destroy()
		return

	elseif gui.name == "balance_options_cancel" then
		gui.parent.destroy()
		return

	elseif gui.name == "balance_options" then
		create_balance_option(player.gui.left)
		return

	elseif gui.name == "config_confirm" then
		config_confirm(gui)
		return

	elseif gui.name == "close_config" then
		destroy_config_for_all(gui.parent.name)
		return

	elseif gui.name == "random_join_button" then
		gui.parent.destroy()
		random_join(player)
		return

	elseif gui.name == "auto_assign_button" then
		gui.parent.destroy()
		auto_assign(player)
		return

	elseif gui.name == "player_pick_confirm" then
		for k = 1, global.config.number_of_teams do
			local team = global.force_list[k]
			local force = game.forces[team.name]
			if force then
				local check = gui.parent.pick_join_table[force.name]
				if check.state then 
					local c = team.color
					local color = {r = fpn(c[1]), g = fpn(c[2]), b = fpn(c[3]), a = fpn(c[4])}
					gui.parent.destroy()
					set_player(player,force,color)
					for k, player in pairs (game.players) do
						update_players_on_team_count(player)
					end
					break
				end
			end
		end
	end
	
end)

function add_surrender_label(player, message)
	local surrender_table = player.gui.left.surrender_dialog.surrender_table
	--if surrender_table.surrender_error_label then surrender_table.surrender_error_label.destroy() end
	local surrender_error_label = surrender_table.add{type = "label", name = surrender_error_label, caption = message}
	return surrender_error_label
end
	
function open_surrender_window(player)
	if player.gui.left.surrender_dialog then player.gui.left.surrender_dialog.destroy() end

	local frame = player.gui.left.add{name = "surrender_dialog", type = "frame", direction = "vertical", caption = "Vote: Do you wish to surrender?"}
	--the following line was the only way I could figure out how to cause elements to appear vertically instead of horizontally, there has got to be a better way
	local surrender_table = frame.add{type = "table", name = "surrender_table", colspan = 1}
	local debug_force_label = surrender_table.add{type = "label", name = debug_force_label, caption = "player.force.name = " .. player.force.name}
	local button_table = surrender_table.add{type = "table", name = "button_table", colspan = 2}
	local surrender_vote_yes = button_table.add{type = "button", name = "surrender_vote_yes", caption = "Yes"}
	local surrender_vote_no = button_table.add{type = "button", name = "surrender_vote_no", caption = "No"}
	
	if not global.surrender_votes then global.surrender_votes = {} end  --this contains the surrender vote information for all teams
	local votes
	if not global.surrender_votes[player.force.name] then 
		surrender_table.add{type = "label", caption = "not global-surrender_votes[player.force.name]"}
		global.surrender_votes[player.force.name] = {}
		votes = global.surrender_votes[player.force.name]		
		votes.in_progress = false
		votes.voted_at_least_once = false
	else
		votes = global.surrender_votes[player.force.name]
	end
	if votes.in_progress or votes.already_surrendered then add_surrender_vote_tally_table(player) end
	local surrender_info_label = surrender_table.add{type = "label", name = surrender_info_label, caption = "70% Yes vote required for surrender."}
	local contact_author_label = surrender_table.add{type = "label", name = contact_author_label, caption = "Please contact JuicyJuuce regarding surrender bugs!"}
	
	local surrender_error_message = nil
	if player.force.name == "player" then
		surrender_error_message = "You must be on a team to surrender."
	else
		surrender_error_message = is_too_soon_to_surrender(player.force)
	end
	if surrender_error_message then
		surrender_vote_yes.style.font_color = colors.grey
		surrender_vote_no.style.font_color = colors.grey
		local label = add_surrender_label(player, surrender_error_message)
		label.style.font_color = colors.red
	end
end

--[[
function is_too_early_in_match_to_surrender()
	return game.tick < global.match_start_time + global.time_before_first_surrender_available * 3600
end

function is_too_soon_since_last_surrender_vote(force)
	local votes = global.surrender_votes[force.name]
	return votes.voted_at_least_once and game.tick < votes.vote_start_time + global.surrender_vote_cooldown_period * 3600
end
--]]
function is_too_soon_to_surrender(force)
	local votes = global.surrender_votes[force.name]
	if votes.already_surrendered then
		return "Your team has surrendered!"
	elseif votes.voted_at_least_once and game.tick < votes.vote_start_time + global.surrender_vote_cooldown_period * 3600 then
		return "You can not surrender until " .. global.surrender_vote_cooldown_period .. " minutes have passed since the last vote."
	elseif game.tick < global.match_start_time + global.time_before_first_surrender_available * 3600 then
		return "You can not surrender during the first " .. global.time_before_first_surrender_available .. " minutes of a match."
	else
		return nil
	end
end

function add_surrender_vote_tally_table(player)
	local votes = global.surrender_votes[player.force.name]

	local surrender_tally_table = player.gui.left.surrender_dialog.surrender_table.add{type = "table", name = "surrender_tally_table", colspan = 3}
	surrender_tally_table.add{type = "label", name = "surrender_tally_table_yes_votes", caption = "Yes votes"}
	surrender_tally_table.add{type = "label", caption = "      "}  --adds whitespace between the two actual columns... there has got to be a better way to do this...
	surrender_tally_table.add{type = "label", name = "surrender_tally_table_yes_votes_count", caption = votes.yes_votes_count}
	surrender_tally_table.add{type = "label", name = "surrender_tally_table_no_votes", caption = "No votes"}
	surrender_tally_table.add{type = "label", caption = "      "}
	surrender_tally_table.add{type = "label", name = "surrender_tally_table_no_votes_count", caption = votes.no_votes_count}
	surrender_tally_table.add{type = "label", name = "surrender_tally_table_not_yet_voted", caption = "Not yet voted"}
	surrender_tally_table.add{type = "label", caption = "      "}
	surrender_tally_table.add{type = "label", name = "surrender_tally_table_not_yet_voted_count", caption = votes.not_yet_voted_count}
end

function update_surrender_tally(player, vote_initiated)
	log("Entering update_surrender_tally")
	local votes = global.surrender_votes[player.force.name]
	for i,p in pairs(player.force.players) do
		if not votes.vote_record[p.index] then
			log(p.name .. " has false vote_record.")
		else
			log(p.name .. "'s vote record is: " .. votes.vote_record[p.index])
		end
	end
	votes.not_yet_voted_count = 0
	for i,p in pairs(player.force.connected_players) do
		if votes.vote_record[p.index] == "not voted" then
			votes.not_yet_voted_count = votes.not_yet_voted_count + 1
		end
	end
	--current_possible_total_votes = votes.not_yet_voted_count + players (online and offline) that have voted
	votes.current_possible_total_votes = votes.not_yet_voted_count
	for i,p in pairs(player.force.players) do
		if votes.vote_record[p.index] == "voted Yes" or votes.vote_record[p.index] == "voted No" then
			votes.current_possible_total_votes = votes.current_possible_total_votes + 1
		end
	end

	--check_surrender_vote_complete(player.force)
	log("yes_votes_count for " .. player.force.name .. " = " .. votes.yes_votes_count)
	log("no_votes_count for " .. player.force.name .. " = " .. votes.no_votes_count)
	log("current_possible_total_votes for " .. player.force.name .. " = " .. votes.current_possible_total_votes)
	log("global.percentage_needed_to_surrender = " .. global.percentage_needed_to_surrender)
	local surrendered_successfully = false
	if votes.yes_votes_count / votes.current_possible_total_votes >= global.percentage_needed_to_surrender / 100 then
		game.print(player.force.name .. " team has voted to surrender!")
		votes.in_progress = false
		votes.already_surrendered = true
		for i,p in pairs(player.force.players) do
			p.gui.top.surrender_button.style.font_color = colors.white
		end
		surrendered_successfully = true
	elseif votes.no_votes_count / votes.current_possible_total_votes > 1 - global.percentage_needed_to_surrender / 100 then
		player.force.print("Surrender vote has failed.")
		for i,p in pairs(player.force.players) do
			p.gui.top.surrender_button.style.font_color = colors.red
		end
		votes.in_progress = false			
	elseif game.tick > global.surrender_votes[player.force.name].vote_start_time + global.surrender_voting_period / 3600 then
		player.force.print("Surrender voting period ended without enough Yes votes.")
		for i,p in pairs(player.force.players) do
			p.gui.top.surrender_button.style.font_color = colors.red
		end
		votes.in_progress = false			
	end
	for i,p in pairs(player.force.players) do
		if vote_initiated or p.gui.left.surrender_dialog then open_surrender_window(p) end
	end
	if surrendered_successfully then
		kill_force(player.force)
	end
end
--[[
function check_surrender_vote_complete(force)
	local votes = global.surrender_votes[force.name]
	log("yes_votes_count for " .. force.name .. " = " .. votes.yes_votes_count)
	log("no_votes_count for " .. force.name .. " = " .. votes.no_votes_count)
	log("current_possible_total_votes for " .. force.name .. " = " .. votes.current_possible_total_votes)
	log("global.percentage_needed_to_surrender = " .. global.percentage_needed_to_surrender)
	if votes.yes_votes_count / votes.current_possible_total_votes >= global.percentage_needed_to_surrender / 100 then
		game.print(force.name .. " team has voted to surrender!")
		votes.in_progress = false
		votes.already_surrendered = true
		for i,p in pairs(force.players) do
			p.gui.top.surrender_button.style.font_color = colors.white
		end
		kill_force(force)
	elseif votes.no_votes_count / votes.current_possible_total_votes > 1 - global.percentage_needed_to_surrender / 100 then
		force.print("Surrender vote has failed.")
		for i,p in pairs(force.players) do
			p.gui.top.surrender_button.style.font_color = colors.red
		end
		votes.in_progress = false			
	elseif game.tick > global.surrender_votes[force.name].vote_start_time + global.surrender_voting_period / 3600 then
		force.print("Surrender voting period ended without enough Yes votes.")
		for i,p in pairs(force.players) do
			p.gui.top.surrender_button.style.font_color = colors.red
		end
		votes.in_progress = false			
	end
end
--]]
function kill_force(force)
	global.silos[force.name].damage(10000, force)
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
	
	if (not player.gui.top["score_button"]) then
		player.gui.top.add{type="button", name="score_button", caption="Score"}
	end
	if (not player.gui.top["surrender_button"]) then
		player.gui.top.add{type="button", name="surrender_button", caption="Surrender Menu"}
	end
end	

function welcome_window(player)
	local center = player.gui.center
	if center.welcome_frame then center.welcome_frame.destroy() end
	local welcome_frame = center.add{type = "frame", name = "welcome_frame", caption = {"",{"welcome-message"},""}}
	welcome_frame.add{type = "label", name = "welcome_label", caption = {"",{"welcome-label"},""}}
end

function destroy_welcome_window(player)
	local center = player.gui.center
	if center.welcome_frame then center.welcome_frame.destroy() end
end

function choose_joining_gui(player)
	destroy_welcome_window(player)
	
--[[	if not global.force_list then error("No force list defined") return end
	local list = global.force_list
	local n = global.config.number_of_teams
	if n <= 0 then error ("Number of team to setup must be greater than 0")return end
	if n > #list then error("Not enough forces defined for number of teams. Max teams is "..#list) return end
	for k = 1, n do
		if not list[k] then	break end
		local name = list[k].name
		if name then
			local new_force
			if not game.forces[name] then
				new_force = game.create_force(name)
			else
				new_force = game.forces[name]
			end
			set_spawn_position(k, n, new_force, global.surface)
		end
	end
--]]
	if not game.forces["Lobby"] then
		game.create_force("Lobby")
	end

	player.force = game.forces["Lobby"]
	print("PLAYER$update," .. player.index .. "," .. player.name .. ",Lobby")
	check_player_color(false)

	if global.team_joining == "random" then
		create_random_join_gui(player.gui.center)
		return
	end

	if global.team_joining == "player_pick" then
		create_pick_join_gui(player.gui.center)
		return
	end
	
	if global.team_joining == "auto_assign" then
		create_auto_assign_gui(player.gui.center)
		return
	end
	
end

function destroy_joining_guis(gui)
	if gui.random_join_frame then
		gui.random_join_frame.destroy()
	end
	if gui.pick_join_frame then
		gui.pick_join_frame.destroy()
	end
	if gui.auto_assign_frame then
		gui.auto_assign_frame.destroy()
	end
end

function create_random_join_gui(gui)
	if gui.random_join_frame then
		gui.random_join_frame.destroy()
	end
	local frame = gui.add{type = "frame", name = "random_join_frame", caption = {"",{"random-join"},""}}
	local button = frame.add{type = "button", name = "random_join_button", caption = {"",{"random-join-button"},""}}
end

function create_auto_assign_gui(gui)
	local name = "auto_assign"
	if gui[name.."_frame"] then
		gui[name.."_frame"].destroy()
	end
	local frame = gui.add{type = "frame", name = name.."_frame", caption = {name.."_frame"}}
	local button = frame.add{type = "button", name = name.."_button", caption = {name.."_button"}}
end

function create_pick_join_gui(gui)
	if gui.pick_join_frame then
		gui.pick_join_frame.destroy()
	end
	local frame = gui.add{type = "frame", name = "pick_join_frame", caption = {"",{"pick-join"},""}, direction = "vertical"}
	local pick_join_table = frame.add{type = "table", name = "pick_join_table", colspan = 3}
	pick_join_table.add{type = "label", name = "pick_join_table_force_name", caption = {"team-name"}}
	pick_join_table.add{type = "label", name = "pick_join_table_player_count", caption = {"players-on-team"}}
	pick_join_table.add{type = "label", name = "pick_join_table_pad", caption = {"join"}}
	for k = 1, global.config.number_of_teams do
		local team = global.force_list[k]
		local force = game.forces[team.name]
		if force ~= nil then
			local c = team.color
			local color = {r = 1 - (1 - c[1]) * 0.5, g = 1 - (1 - c[2]) * 0.5, b = 1 - (1 - c[3]) * 0.5, a = 1}
			local name = pick_join_table.add{type = "label", name = force.name.."_label", caption = force.name}
			name.style.font_color = color
			pick_join_table.add{type = "label", name = force.name.."_count", caption = #force.connected_players}
			pick_join_table.add{type = "checkbox", name = force.name,state = false}
		end
	end
	local button = frame.add{type = "button", name = "player_pick_confirm", caption = {"confirm"}}
	button.style.font = "default"
end

function create_config_gui(player)
	local gui = player.gui.left
	if gui.config_gui then
		gui.config_gui.destroy()
	end
	local frame = gui.add{type = "frame", name = "config_gui", caption = {"config-gui"}, direction = "vertical"}
	local config_table = frame.add{type = "table", name = "config_table", colspan = 2}
	for k, name in pairs (global.config) do
		if tonumber(name) then
			config_table.add{type = "label", name = k, caption = {k}}
			local input = config_table.add{type = "textfield", name = k.."box"}
			input.text = name
		elseif tostring(type(name)) == "boolean" then
			config_table.add{type = "label", name = k, caption = {k}}
			config_table.add{type = "checkbox", name = k.."_"..tostring(type(name)), caption= {"",{tostring(type(name))},""}, state = name}
		else
			config_table.add{type = "label", name = k, caption = {k}}
			local option_table = config_table.add{type = "table", name = k.."_option_table", colspan = #name}
			for j, option in pairs (name) do
				local check = option_table.add{type = "checkbox", name = option, caption= {"",{option},""}, state = false}
				if global[k] == option then check.state = true end
				if global.research_ingredient_list[check.name] then check.state = global.research_ingredient_list[check.name] end
			end
		end
	end
	frame.add{type = "button", name = "config_confirm", caption = {"config-confirm"}}.style.font = "default"
	frame.add{type = "button", name = "balance_options", caption = {"balance-options"}}.style.font = "default"
	frame.add{type = "button", name = "close_config", caption = "Close"}.style.font = "default"
end


function create_balance_option(gui)

	if gui.balance_options_frame then
		gui.balance_options_frame.destroy()
	end
	local frame = gui.add{name = "balance_options_frame", type = "frame", direction = "vertical", caption = {"balance-options"}}
	local scrollpane = frame.add{name = "balance_options_scrollpane", type = "scroll-pane"}
	scrollpane.style.maximal_height = 500
	for modifier_name, array in pairs (global.modifier_list) do
		scrollpane.add{name = modifier_name.."label", type = "label", caption = {modifier_name} }
		local table = scrollpane.add{name = modifier_name.."table", type = "table", colspan = 2}
		for name, modifier in pairs (array) do
			if modifier_name == "ammo_damage_modifier" then
				local string = "ammo-category-name."..name
				table.add{name = name.."label", type = "label", caption = {string}}
			elseif modifier_name == "gun_speed_modifier" then
				local string = "ammo-category-name."..name
				table.add{name = name.."label", type = "label", caption = {string}}
			elseif modifier_name == "turret_attack_modifier" then
				local string = "entity-name."..name
				table.add{name = name.."label", type = "label", caption = {string}}
			else
				table.add{name = name.."label", type = "label", caption = {name}}
			end
			

			local input = table.add{name = name.."text", type = "textfield"}
			input.text = modifier
		end
	end
	frame.add{type = "button", name = "balance_options_confirm", caption = {"config-confirm"}}.style.font = "default"
	frame.add{type = "button", name = "balance_options_cancel", caption = {"cancel"}}.style.font = "default"
	
end

function set_balance_settings(gui)
	for modifier_name, array in pairs (global.modifier_list) do
		local modifier_table = gui[modifier_name.."table"]
		if modifier_table then
			for name, modifier in pairs (array) do
				local text = modifier_table[name.."text"].text
				if text then
					local n = tonumber(text)
					if n == nil then 
						game.players[gui.player_index].print({"must-be-number",name})
						return
					end
					global.modifier_list[modifier_name][name] = n
				end
			end
		end
	end
end

function config_confirm(gui)

	local parent = gui.parent
	local config = parent.config_table
	for name, value in pairs (global.config) do
		if config[name.."box"] then
			local text = config[name.."box"].text
			local n = tonumber(text)
			if n ~= nil then
				global.config[name] = n
			else
				game.players[gui.player_index].print({"must-be-number",name})
				return
			end
		end
		if type(value) == "boolean" then
			if config[name] then
				global.config[name] = config[name.."_boolean"].state
			end
		end
	end
	if global.config.number_of_teams <= 1 then
		player.print({"more-than-1-team"})
		return
	end
	if global.config.number_of_teams > 9 then 
		player.print({"less-than-9-teams"})
		return
	end
	prepare_next_round()

end

function destroy_config_for_all()
	for k, player in pairs (game.players) do
		if player.gui.left.config_gui then
			player.gui.left.config_gui.destroy()
		end	
		if player.gui.left.balance_options_frame then
			player.gui.left.balance_options_frame.destroy()
		end
	end
end

--Kill Counts
Event.register(-1, function()
	global.kill_counts = {}
end)

Event.register(defines.events.on_entity_died, function(event)
	local entity = event.entity
	local force = event.force
	if entity and entity.valid and entity.type == "player" and force and force.name ~= entity.force.name and force.name ~= "enemy" then
		if not global.kill_counts[force.name] then global.kill_counts[force.name] = 1
		else global.kill_counts[force.name] = global.kill_counts[force.name] + 1 end
		update_scoreboard_kills(force)
	end
end)

function update_scoreboard_kills(force)
	for _,player in pairs(game.players) do
		if player.gui.left.score_board then
			local force_kill_counter = force.name .. "_kill_count"
			if not player.gui.left.score_board.score_board_table[force_kill_counter] then return end
			player.gui.left.score_board.score_board_table[force_kill_counter].caption = global.kill_counts[force.name]
			player.gui.left.score_board.score_board_table[force.name.."_count"].caption = #force.connected_players
		end
	end
end

function update_scoreboard()
	for _,player in pairs(game.players) do
		if player.gui.left.score_board and player.gui.left.score_board_table then
			for _,force in pairs(game.forces) do
				if player.gui.left.score_board.score_board_table[force.name .. "_count"] and player.gui.left.score_board.score_board_table[force.name .. "_online"] then
					player.gui.left.score_board.score_board_table[force.name .. "_online"].caption = #force.connected_players
					player.gui.left.score_board.score_board_table[force.name .. "_count"].caption = #force.players
				end
			end
		end
	end
end
