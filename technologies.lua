
function research_technology()
	for k, force in pairs (game.forces) do
	  for k, technology in pairs (force.technologies) do 
		technology.researched = true
			if technology.upgrade then
			technology.researched = false
			end
		end
	end	
end
