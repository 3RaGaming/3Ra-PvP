-- for non admins spectating without a character
function join_spectators(index)
	local player = game.players[index]
    if player.admin == true then
        local the_force = "AdminSpectators"
        if not game.forces["AdminSpectators"] then game.create_force("AdminSpectators") end
    else
        local the_force = "Spectators"
        if not game.forces["Spectators"] then game.create_force("Spectators") end
    end
    global.player_spectator_state = global.player_spectator_state or {}
    global.player_spectator_character = global.player_spectator_character or {}
    global.player_spectator_force = global.player_spectator_force or {}
    if global.player_spectator_state[index] then
        --put player in spectator mode
        if player.surface.name == "Lobby" then
            player.teleport(game.forces[the_force].get_spawn_position(game.surfaces.nauvis), game.surfaces.nauvis)
        end
        if player.character then
            player.walking_state = {walking = false, direction = defines.direction.north}
            global.player_spectator_character[index] = player.character
            global.player_spectator_force[index] = player.force
            if player.admin then
                player.character.destructible=false
                player.set_controller{type = defines.controllers.god}
            else
                player.character.destroy()
                player.set_controller{type = defines.controllers.ghost}
            end
        end
        player.force = game.forces[the_force]
        global.player_spectator_state[index] = true
        player.print("You are now a spectator")
        player.force.chart_all()
        if player.gui.left.spectate ~= nil then
            player.gui.left.spectate.caption = "Return "
        end
    end
end

function force_spectators(index, disableadmin)
    local player = game.players[index]
    global.player_spectator_state = global.player_spectator_state or {}
    global.player_spectator_character = global.player_spectator_character or {}
    global.player_spectator_force = global.player_spectator_force or {}
    if global.player_spectator_state[index] then
        --remove spectator mode
        if player.character == nil and global.player_spectator_character[index] then
            local pos = player.position
            if global.player_spectator_character[index].valid then
                player.set_controller{type=defines.controllers.character, character=global.player_spectator_character[index], force = global.player_spectator_force[index]}
            else
                player.set_controller{type=defines.controllers.character, character=player.surface.create_entity{name="player", position = {0,0}, force = global.player_spectator_force[index]}}
            end
            player.teleport(pos)
		end
        global.player_spectator_state[index] = false
        player.force = game.forces[global.player_spectator_force[index].name]
        player.character.destructible=true
        player.print("Summoning your character")
        player.gui.left.spectate.caption = "Spectate"
    else
        --put player in spectator mode
        if player.character then
            global.player_spectator_force[index] = player.force
            player.walking_state = {walking = false, direction = defines.direction.north}
            global.player_spectator_character[index] = player.character
            player.character.destructible=false
            if player.surface.name == "Lobby" then
                player.teleport(game.forces["AdminSpectators"].get_spawn_position(game.surfaces.nauvis), game.surfaces.nauvis)
            end
    		player.set_controller{type = defines.controllers.god}
        end
		player.force = game.forces["AdminSpectators"]
        player.force.chart_all()
        global.player_spectator_state[index] = true
		player.print("Admin spectate enabled")
        player.gui.left.spectate.caption = "Return "
    end
end
