


function player_died(event)
  game.speed = 1
  player = event.player_index
  if game.players[player].name ~= nil then
    print("[PUPDATE] | "..game.players[player].name.." | died |"..game.players[player].force.name)
  end
end

function player_joined(event)
  game.speed = 1
  player = event.player_index
  if game.players[player].name ~= nil then
    print("[PUPDATE] | "..game.players[player].name.." | join")
  end
end


function player_left(event)
  player = event.player_index
  if game.players[player].name ~= nil then
    print("[PUPDATE] | "..game.players[player].name.." | leave")
  end
end

Event.register(defines.events.on_player_joined_game, on_player_died)
Event.register(defines.events.on_player_joined_game, player_joined)
Event.register(defines.events.on_player_left_game, player_left)
