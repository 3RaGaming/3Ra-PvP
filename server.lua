function player_died(event)
	local player = event.player_index
	if game.players[player].name ~= nil then
		print("[PUPDATE] | "..game.players[player].name.." | died | "..game.players[player].force.name)
	end
end

function player_respawned(event)
	local player = event.player_index
	if game.players[player].name ~= nil then
		print("[PUPDATE]| "..game.players[player].name.." | respawn | "..game.players[player].force.name)
	end
end

function player_joined(event)
	local player = event.player_index
	if game.players[player].name ~= nil then
		print("[PUPDATE]| "..game.players[player].name.." | join | "..game.players[player].force.name) -- Print for human readability
		print("PLAYER$join," .. player .. "," .. game.players[player].name .. "," .. game.players[player].force.name) -- Print for computer parsing
	end
end

function player_left(event)
	local player = event.player_index
	if game.players[player].name ~= nil then
		print("[PUPDATE]| "..game.players[player].name.." | leave | "..game.players[player].force.name) -- Print for human readability
		print("PLAYER$leave," .. player .. "," .. game.players[player].name .. "," .. game.players[player].force.name) -- Print for computer parsing
	end
end

Event.register(defines.events.on_player_died, player_died)
Event.register(defines.events.on_player_respawned, player_respawned)
Event.register(defines.events.on_player_joined_game, player_joined)
Event.register(defines.events.on_player_left_game, player_left)