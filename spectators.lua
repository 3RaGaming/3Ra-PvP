-- for non admins spectating without a character
function join_spectators(index)
	local player = game.players[index]
	if global.player_spectator_state == nil then global.player_spectator_state = {} end
	if global.player_spectator_character == nil then global.player_spectator_character = {}  end
	if global.player_spectator_force == nil then global.player_spectator_force = {} end
	if global.player_spectator_state[index] then
		--put player in spectator mode
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
