
function research_technology()
	for k, force in pairs (game.forces) do
	  for k, technology in pairs (force.technologies) do 
		technology.researched = true
			if technology.upgrade then
			technology.researched = false
			end
		end
		force.recipes["energy-shield-mk2-equipment"].enabled=false
		force.recipes["laser-turret"].enabled=false
		force.recipes["destroyer-capsule"].enabled=false
		force.recipes["personal-laser-defense-equipment"].enabled=false
	end	
end
