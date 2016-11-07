
function troy_destroy_o()
	surface = game.surfaces["nauvis"]
	global.kill_count_troy = global.kill_count_troy + 40
	show_update_score()
	
	for k, p in pairs (game.players) do
		p.print("Spartas Roboport has been destroyed")
		p.print("Troy was Awarded 40 Points")	
	end
	Event.register(defines.events.on_tick, kill_sparta)
	global.ending_tick = game.tick + 300
end

function sparta_destroy_p()
	surface = game.surfaces["nauvis"]
	global.kill_count_sparta = global.kill_count_sparta + 40
	show_update_score()
	
	for k, p in pairs (game.players) do
		p.print("Troys Roboport has been destroyed")
		p.print("Sparta was Awarded 40 Points")
	end

	Event.register(defines.events.on_tick, kill_troy)
	global.ending_tick = game.tick + 300
end

-- if the Sparta roboport is destroyed, spawn a series of explosions.
function kill_sparta()
	local s = game.surfaces["nauvis"]
	local drx = global.drbp.x
	local dry = global.drbp.y
	if game.tick < global.ending_tick and game.tick % 20 == 0 then
		s.create_entity{position = {drx + math.random(-2,2),dry + math.random(-2,2)}, name = "medium-explosion"}    
	end
	if game.tick == global.ending_tick then 
		s.create_entity{position = {drx,dry}, name = "big-explosion"}
		Event.remove(defines.events.on_tick, kill_sparta)
	end
end

-- if the Troy roboport is destroyed, spawn a series of explosions.
function kill_troy()
	local s = game.surfaces["nauvis"]
	local drx = global.drbp.x
	local dry = global.drbp.y
	if game.tick < global.ending_tick and game.tick % 20 == 0 then
		s.create_entity{position = {drx + math.random(-2,2),dry + math.random(-2,2)}, name = "medium-explosion"}    
	end
	if game.tick == global.ending_tick then 
		s.create_entity{position = {drx,dry}, name = "big-explosion"}
		Event.remove(defines.events.on_tick, kill_troy)
	end
end

--check on tick, to see if anyone has won.
function win()
    if global.kill_count_troy >= 100 then
		for _, p in pairs (game.connected_players) do p.surface.create_entity{position=p.position, name="big-explosion"} end
        global.end_screen = game.tick + 180
        Event.register(defines.events.on_tick, troy_win)
    end
    if global.kill_count_sparta >= 100 then
		for _, p in pairs (game.connected_players) do p.surface.create_entity{position=p.position, name="big-explosion"} end
        global.end_screen = game.tick + 180
        Event.register(defines.events.on_tick, sparta_win)
    end
end

function sparta_win()
	if game.tick == global.end_screen then 
		for k, player in pairs (game.connected_players) do
			if player.force.name == "Sparta" then
				showdialog(player, "You win :D", "Sparta has defeated Troy. Well done!")
			end
			if player.force.name == "Troy" then
				showdialog(player, "You lost :(", "Troy was defeated by Sparta. Better luck next time.")
			end
		end
	end
    return
end

function troy_win()
	if game.tick == global.end_screen then
		for k, player in pairs (game.connected_players) do
			if player.force.name == "Troy" then
				showdialog(player, "You win :D", "Troy has defeated Sparta. Well done!")
			end
			if player.force.name == "Sparta" then
				showdialog(player, "You lost :(", "Sparta was defeated by Troy. Better luck next time.")
			end
		end
	end
    return
end

--gui with a message, event on win.
function showdialog(player, title, message)
	if player.gui.center.end_message == nil then
		local frame = player.gui.center.add{type="frame", name="end_message", caption=title, direction="vertical"}
		frame.add{type="label", caption=message}
		frame.add{type="button", name="end_message_button", caption="Close this message"}
	end
end
