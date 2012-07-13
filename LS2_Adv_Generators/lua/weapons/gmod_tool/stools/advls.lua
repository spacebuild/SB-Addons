
TOOL.Category = 'Advanced Life Support'
TOOL.Name = '#Advanced Generators'
TOOL.Command = nil
TOOL.ConfigName = ''
if (CLIENT and GetConVarNumber("RD_UseLSTab") == 1) then TOOL.Tab = "Life Support" end

TOOL.ClientConVar['type'] = 'air_to_steam'
TOOL.ClientConVar['model'] = 'models/props_c17/substation_transformer01b.mdl'

cleanup.Register('advls')

if ( CLIENT ) then
	language.Add( 'Tool_advls_name', 'Advanced Life Support Generators' )
	language.Add( 'Tool_advls_desc', 'Create Generators attached to any surface.' )
	language.Add( 'Tool_advls_0', 'Left-Click: Spawn a Device.  Right-Click: Repair Device.' )

	language.Add( 'Undone_advls', 'Generator Undone' )
	language.Add( 'Cleanup_advls', 'ADVLS: Generators' )
	language.Add( 'Cleaned_advls', 'Cleaned up all Advanced Life Support Generators' )
	language.Add( 'SBoxLimit_advls', 'Maximum Advanced Life Support Generators Reached' )
end

if not ( RES_DISTRIB == 2 ) then Error("Please Install Resource Distribution 2 Addon.'" ) return end

local advls = {}
if (SERVER) then
    advls.air_to_steam = function( ply, ent, system_type, system_class, model )
		local maxhealth = 1000
		local mass = 5600
		RD_AddResource(ent, "energy", 0)
		RD_AddResource(ent, "steam", 0)
		RD_AddResource(ent, "air", 0)
		LS_RegisterEnt(ent, "Generator")
		return {}, maxhealth, mass
    end

    advls.steam_to_water = function( ply, ent, system_type, system_class, model )
        local maxhealth = 1500
        local mass = 5600
        RD_AddResource(ent, "energy", 0)
        RD_AddResource(ent, "steam", 0)
        RD_AddResource(ent, "water", 0)
        LS_RegisterEnt(ent, "Generator")
        return {}, maxhealth, mass
    end

    advls.air_to_coolant = function( ply, ent, system_type, system_class, model )
        local maxhealth = 1500
        local mass = 5600
        RD_AddResource(ent, "energy", 0)
        RD_AddResource(ent, "air", 0)
        RD_AddResource(ent, "coolant", 0)
        LS_RegisterEnt(ent, "Generator")
        return {}, maxhealth, mass
    end
        
    advls.adv_hvywater_electrolyzer = function( ply, ent, system_type, system_class, model )
        local maxhealth = 1500
        local mass = 5600
        RD_AddResource(ent, "energy", 0)
        RD_AddResource(ent, "air", 0)
        RD_AddResource(ent, "heavy water", 0)
        RD_AddResource(ent, "water", 0)
        LS_RegisterEnt(ent, "Generator")
        return {}, maxhealth, mass
    end

    advls.adv_terrajuice_gen = function( ply, ent, system_type, system_class, model )
		local maxhealth = 800
		local mass = 5500
		RD_AddResource(ent, "terrajuice", 0)
		RD_AddResource(ent, "energy", 0)
		RD_AddResource(ent, "water", 0)
		RD_AddResource(ent, "coolant", 0)
        RD_AddResource(ent, "air", 0)
		LS_RegisterEnt(ent, "Generator")
		return {}, maxhealth, mass
	end

    advls.hydro_powerstation = function( ply, ent, system_type, system_class, model )
        local maxhealth = 1500
        local mass = 5500
        RD_AddResource(ent, "water", 0)
        RD_AddResource(ent, "energy", 0)
        LS_RegisterEnt(ent, "Generator")
        return {}, maxhealth, mass
    end  
end

local advls_models = {
    { 'Air-To-Steam Generator', 'models/props_c17/substation_transformer01b.mdl', 'air_to_steam' },
    { 'Steam-To-Water Generator', 'models/props_c17/substation_transformer01c.mdl', 'steam_to_water' },
    { 'Air-To-Coolant Generator', 'models/props_c17/substation_transformer01a.mdl', 'air_to_coolant' },
    { 'Adv. Heavy Water Electrolyzer', 'models/props_c17/factorymachine01.mdl', 'adv_hvywater_electrolyzer' },
    { 'Adv. Terra Juice Generator', 'models/props/de_prodigy/transformer.mdl', 'adv_terrajuice_gen' },
    { 'Hydro Power Station', 'models/props_buildings/watertower_001c.mdl', 'hydro_powerstation' }
}

RD2_ToolRegister( TOOL, advls_models, nil, "advls", 30, advls )
