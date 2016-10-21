
function troy_destroy_o()
	surface = game.surfaces["nauvis"]
	global.kill_count_troy = global.kill_count_troy + 40
	show_update_score()
	
	for k, p in pairs (game.players) do
		p.print("Spartas Roboport has been destroyed")
		p.print("Troy was Awarded 40 Points")	
	end
	script.on_event(defines.events.on_tick, kill_sparta)
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

	script.on_event(defines.events.on_tick, kill_troy)
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
	end
end

--check on tick, to see if anyone has won.
function win()
    --keep win_complete a lua global, so new players joining will see the message on join... maybe
    if not win_complete then
        if global.kill_count_troy >= 100 then
            global.end_screen = game.tick + 180
            Event.register(defines.events.on_tick, troy_win)
            win_complete = true
        end
        if global.kill_count_sparta >= 100 then
            global.end_screen = game.tick + 180
            Event.register(defines.events.on_tick, sparta_win)
            win_complete = true
        end
    end
end

function sparta_win()
	if game.tick == global.end_screen then 
		for k, player in pairs (game.connected_players) do
			if player.force.name == "Sparta" then
				showdialog("You win :D", "Sparta has defeated the Troy. Well done!")
			end
			if player.force.name == "Troy" then
				showdialog("You lost :(", "Troy was defeated by the Sparta. Better luck next time.")
			end
		end
	end	
end

function troy_win()
	if game.tick == global.end_screen then
		for k, player in pairs (game.players) do
			if player.force.name == "Troy" then
				showdialog("You win :D", "Troy has defeated the Sparta. Well done!")
			end
			if player.force.name == "Sparta" then
				showdialog("You lost :(", "Sparta was defeated by the Troy. Better luck next time.")
			end
		end
	end	
end

--gui with a message, event on win.
function showdialog(title, message)
	if game.tick == global.end_screen then
		for i, player in pairs(game.players) do
			if player.gui.center.end_message == nil then
				local frame = player.gui.center.add{type="frame", name="end_message", caption=title, direction="vertical"}
				frame.add{type="label", caption=message}
				frame.add{type="button", name="end_message_button", caption="Close this message"}
			end
		end
	end
end
