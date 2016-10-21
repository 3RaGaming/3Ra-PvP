-- Spectates for admins and regular players
function force_spectators(index)
    local player = game.players[index]
    global.player_spectator_state = global.player_spectator_state or {}
    global.player_spectator_character = global.player_spectator_character or {}
    global.player_spectator_force = global.player_spectator_force or {}
    if global.player_spectator_state[index] then
        --remove spectator mode
        local pos = player.position
        if global.player_spectator_character[index] then
            if global.player_spectator_character[index].valid then
                player.set_controller{type=defines.controllers.character, character=global.player_spectator_character[index]}
            else
                player.set_controller{type=defines.controllers.character, character=player.surface.create_entity{name="player", position = pos, force = global.player_spectator_force[index]}}
            end
        else
            player.set_controller{type=defines.controllers.character, character=player.surface.create_entity{name="player", position = pos, force = global.player_spectator_force[index]}}
		end
        player.character.destructible = true
        player.teleport(pos)
        global.player_spectator_state[index] = false
        player.force = game.forces[global.player_spectator_force[index].name]
        player.gui.left.spectate.caption = "Spectate"
    else
        --put player in spectator mode
        if player.surface.name == "Lobby" then
            player.teleport(game.forces["Spectators"].get_spawn_position(game.surfaces.nauvis), game.surfaces.nauvis)
            player.character.destroy()
        end
        --only an admin will have a character later
        if player.character then
            player.character.destructible = false
            player.walking_state = {walking = false, direction = defines.direction.north}
            global.player_spectator_character[index] = player.character
        end
        if player.admin then
            player.set_controller{type = defines.controllers.god}
            global.player_spectator_force[index] = player.force
            global.player_spectator_state[index] = true
        else
            player.set_controller{type = defines.controllers.ghost}
            player.print("You are now a spectator")
        end
        if not game.forces["Spectators"] then game.create_force("Spectators") end
		player.force = game.forces["Spectators"]
        if player.gui.left.spectate ~= nil then
            player.gui.left.spectate.caption = "Return  "
        end
        player.force.chart_all()
    end
end
