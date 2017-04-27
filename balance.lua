local combat_technologies = 
  {
    "follower-robot-count",
    "combat-robot-damage",
    "laser-turret-damage",
    "laser-turret-speed",
    "bullet-damage",
    "bullet-speed",
    "shotgun-shell-damage",
    "shotgun-shell-speed",
    "gun-turret-damage",
    "rocket-damage",
    "rocket-speed",
    "grenade-damage",
    "flamethrower-damage",
    "cannon-shell-damage",
    "cannon-shell-speed"
  }

function disable_combat_technologies(force)
  if global.team_config.unlock_combat_research then return end --If true, then we want them to stay unlocked
  local tech = force.technologies
  for k, name in pairs (combat_technologies) do
    for i = 1, 20 do
      local full_name = name.."-"..i
      if tech[full_name] then
        tech[full_name].researched = false
      end
    end
  end
end

function apply_character_modifiers(force)
  for name, modifier in pairs (global.modifier_list.character_modifiers) do
    force[name] = force[name] + modifier
  end
end

global.modifier_list = 
  { 
    ["character_modifiers"] = 
      {
        ["character_running_speed_modifier"] = 0.3,
        ["character_health_bonus"] = 0
      },
    ["turret_attack_modifier"] = 
      {
        ["laser-turret"] = 0,
        ["gun-turret"] = 0,
        ["flamethrower-turret"] = 0
      },
    ["ammo_damage_modifier"] = 
      {
        ["bullet"] = 0,
        ["shotgun-shell"] =  0,
        ["cannon-shell"] =  0,
        ["rocket"] =  0,
        ["flamethrower"] =  0,
        ["grenade"] =  0,
        ["combat-robot-beam"] =  0,
        ["combat-robot-laser"] =  0,
        ["laser-turret"] =  0
      },
    ["gun_speed_modifier"] = 
      {
        ["bullet"] =  0,
        ["shotgun-shell"] =  0,
        ["cannon-shell"] =  0,
        ["rocket"] =  0,
        ["flamethrower"] =  0,
        ["laser-turret"] =  0
      }
  }

function apply_combat_modifiers(force)

  for name, modifier in pairs (global.modifier_list.turret_attack_modifier) do
    force.set_turret_attack_modifier(name, force.get_turret_attack_modifier(name) + modifier)
  end
  
  for name, modifier in pairs (global.modifier_list.ammo_damage_modifier) do
    force.set_ammo_damage_modifier(name, force.get_ammo_damage_modifier(name) + modifier)
  end
  
  for name, modifier in pairs (global.modifier_list.gun_speed_modifier) do
    force.set_gun_speed_modifier(name, force.get_gun_speed_modifier(name) + modifier)
  end

end

function apply_balance(force)
  apply_character_modifiers(force)
  apply_combat_modifiers(force)
end
