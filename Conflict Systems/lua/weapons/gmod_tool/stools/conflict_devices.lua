if not ( RES_DISTRIB == 2 ) then Error("Please Install Resource Distribution 2 Addon.'" ) return end

TOOL.Category = 'Conflict Systems'
TOOL.Name = '#Conflict Devices'
TOOL.Command = nil
TOOL.ConfigName = ''
if (CLIENT and GetConVarNumber("RD_UseLSTab") == 1) then TOOL.Tab = "Life Support" end

TOOL.ClientConVar['type'] = 'conflict_target_select'
TOOL.ClientConVar['model'] = 'models/props_c17/clock01.mdl'

cleanup.Register('conflictdevice')

if ( CLIENT ) then
	language.Add( 'Tool_conflict_devices_name', 'Life Support Resource modules' )
	language.Add( 'Tool_conflict_devices_desc', 'Create Conflict devices attached to any surface.' )
	language.Add( 'Tool_conflict_devices_0', 'Left-Click: Spawn a Device.  Right-Click: Repair Device.' )

	language.Add( 'Undone_conflict_devices', 'Conflict Device Undone' )
	language.Add( 'Cleanup_conflict_devices', 'Conflict Devices' )
	language.Add( 'Cleaned_conflict_devices', 'Cleaned up all Conflict Devices' )
	language.Add( 'SBoxLimit_conflict_devices', 'Maximum Conflict Devices Reached' )
end

local conflict_devices = {}
if (SERVER) then
	conflict_devices.conflict_target_select = function( ply, ent, system_type, system_class, model )
		local maxhealth = 100
		local mass = 10
		ent.OwnedByENT = ply
		return {}, maxhealth, mass
	end
	conflict_devices.conflict_status_indicator = function( ply, ent, system_type, system_class, model )
		local maxhealth = 100
		local mass = 10
		ent.OwnedByENT = ply
		return {}, maxhealth, mass
	end
end

local weaponmodels = {}
table.insert(weaponmodels, {'Weapon Indicator'  , 'models/props_c17/clock01.mdl'              , 'conflict_status_indicator' })
table.insert(weaponmodels, {'Targeting Computer', 'models/props_c17/clock01.mdl', 'conflict_target_select'    })

RD2_ToolRegister( TOOL, weaponmodels, nil, "conflict_devices", 10,conflict_devices )
