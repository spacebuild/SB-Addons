if not ( RES_DISTRIB == 2 ) then Error("Please Install Resource Distribution 2 Addon.'" ) return end

TOOL.Category = 'Conflict Systems'
TOOL.Name = '#Short Range Turrets'
TOOL.Command = nil
TOOL.ConfigName = ''
if (CLIENT and GetConVarNumber("RD_UseLSTab") == 1) then TOOL.Tab = "Life Support" end

TOOL.ClientConVar['type'] = 'conflict_s_rocketsalvo'
TOOL.ClientConVar['model'] = 'models/conflict_pylon_small.mdl'

cleanup.Register('conflictTurret')

if ( CLIENT ) then
	language.Add( 'Tool_conflict_weapon_short_name', 'Conflict Systems Turret (Short Range)' )
	language.Add( 'Tool_conflict_weapon_short_desc', 'Create Conflict Systems Turret attatched to any surface' )
	language.Add( 'Tool_conflict_weapon_short_0', 'Left-Click: Spawn a Turret.  Right-Click: Repair Turret.' )

	language.Add( 'Undone_conflict_weapon_short', 'Conflict Turret Undone' )
	language.Add( 'Cleanup_conflict_weapon_short', 'Conflict Turrets' )
	language.Add( 'Cleaned_conflict_weapon_short', 'Cleaned up all Conflict Turrets' )
	language.Add( 'SBoxLimit_conflict_weapon_short', 'Maximum Conflict Turrets Reached' )
end

local conflict_weapon_short = {}
if (SERVER) then
	conflict_weapon_short.conflict_s_rocketsalvo = function( ply, ent, system_type, system_class, model )
		local maxhealth = 100
		local mass = 50
		ent.OwnedByENT = ply
		return {}, maxhealth, mass
	end
	conflict_weapon_short.conflict_p_laser = function( ply, ent, system_type, system_class, model )
		local maxhealth = 100
		local mass = 50
		ent.OwnedByENT = ply
		return {}, maxhealth, mass
	end
	conflict_weapon_short.conflict_l_cruise = function( ply, ent, system_type, system_class, model )
		local maxhealth = 100
		local mass = 50
		ent.OwnedByENT = ply
		return {}, maxhealth, mass
	end
end

local weaponmodels = {}
table.insert(weaponmodels,{ 'Rocket Salvo Launcher', 'models/conflict_pylon_small.mdl', 'conflict_s_rocketsalvo' })
table.insert(weaponmodels, {'Pulse Laser', 'models/conflict_pylon_small.mdl', 'conflict_p_laser' })
table.insert(weaponmodels, {'S.W.A.R.M. Launcher', 'models/conflict_pylon_small.mdl', 'conflict_l_cruise' })

RD2_ToolRegister( TOOL, weaponmodels, nil, "conflict_weapon_short", 20, conflict_weapon_short)
