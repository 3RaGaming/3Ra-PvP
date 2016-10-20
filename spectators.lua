-- for non admins spectating without a character
function join_spectators(index)
	local player = game.players[index]
	global.player_spectator_state = global.player_spectator_state or {}
    global.player_spectator_character = global.player_spectator_character or {}
    global.player_spectator_force = global.player_spectator_force or {}
	--put player in spectator mode
	if player.surface.name == "Lobby" then
		player.teleport(game.forces["Spectators"].get_spawn_position(game.surfaces.nauvis), game.surfaces.nauvis)
	end
	if player.character then
		player.walking_state = {walking = false, direction = defines.direction.north}
        global.player_spectator_character[index] = player.character
        global.player_spectator_force[index] = player.force
		player.character.destroy()
		player.set_controller{type = defines.controllers.ghost}
	end
	if not game.forces["Spectators"] then game.create_force("Spectators") end
	player.force = game.forces["Spectators"]
	global.player_spectator_state[index] = true
	player.print("You are now a spectator")
	player.gui.left.spectate.caption = "Return"
	player.force.chart_all()
end

function force_spectators(index)
    local player = game.players[index]
    global.player_spectator_state = global.player_spectator_state or {}
    global.player_spectator_character = global.player_spectator_character or {}
    global.player_spectator_force = global.player_spectator_force or {}
    if global.player_spectator_state[index] then
        --remove spectator mode
        if player.character == nil and global.player_spectator_character[index] then
            local pos = player.position
            if global.player_spectator_character[index].valid then
                player.set_controller{type=defines.controllers.character, character=global.player_spectator_character[index]}
            else
                player.set_controller{type=defines.controllers.character, character=player.surface.create_entity{name="player", position = {0,0}, force = global.player_spectator_force[index]}}
            end
            player.teleport(pos)
		end
        global.player_spectator_state[index] = false
        player.force = game.forces[global.player_spectator_force[index].name]
        player.print("Summoning your character")
        player.gui.left.spectate.caption = "Spectate"
    else
        --put player in spectator mode
        if player.character then
            player.walking_state = {walking = false, direction = defines.direction.north}
            global.player_spectator_character[index] = player.character
            global.player_spectator_force[index] = player.force
    		player.set_controller{type = defines.controllers.god}
        end
        if not game.forces["Spectators"] then game.create_force("Spectators") end
		player.force = game.forces["Spectators"]
        global.player_spectator_state[index] = true
		player.print("You are now a spectator")
        player.gui.left.spectate.caption = "Return"
    end
end
