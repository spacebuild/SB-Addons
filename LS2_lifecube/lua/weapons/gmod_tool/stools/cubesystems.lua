if not ( RES_DISTRIB == 2 ) then Error("Please Install Resource Distribution 2 Addon.'" ) return end

TOOL.Category = '(Cube System)'
TOOL.Name = '#Accumulators'
TOOL.Command = nil
TOOL.ConfigName = ''
if (CLIENT and GetConVarNumber("RD_UseLSTab") == 1) then TOOL.Tab = "Life Support" end

TOOL.ClientConVar['type'] = 'air_compressor'
TOOL.ClientConVar['model'] = 'models/props_junk/popcan01a.mdl'

cleanup.Register('cubesystems')

if ( CLIENT ) then
	language.Add( 'Tool_cubesystems_name', 'Life Support Life Cubes' )
	language.Add( 'Tool_cubesystems_desc', 'Create Life Cube attached to any surface.' )
	language.Add( 'Tool_cubesystems_0', 'Left-Click: Spawn a Device.  Right-Click: Repair Device.' )

	language.Add( 'Undone_cubesystems', 'Life Cube Undone' )
	language.Add( 'Cleanup_cubesystems', 'LS: Life Cube' )
	language.Add( 'Cleaned_cubesystems', 'Cleaned up all Life Cube Generators' )
	language.Add( 'SBoxLimit_cubesystems', 'Maximum Life Support Life Cube(s) Reached' )
end

local cubesystems = {}
if (SERVER) then
    cubesystems.lifecube_gen = function( ply, ent, system_type, system_class, model )
		local maxhealth = 1200
		local mass = 50
		RD_AddResource(ent, "energy", 0)
        RD_AddResource(ent, "air", 0)
        RD_AddResource(ent, "coolant", 0)
        RD_AddResource(ent, "heavy water", 0)
        RD_AddResource(ent, "water", 0)
        RD_AddResource(ent, "steam", 0)
        RD_AddResource(ent, "ZPE", 0)
		LS_RegisterEnt(ent, "Generator")
		return {}, maxhealth, mass
	end
    --Gas generator
    cubesystems.lifecube_gasgen = function( ply, ent, system_type, system_class, model )
		local maxhealth = 1200
		local mass = 50
		RD_AddResource(ent, "methane", 0)
        RD_AddResource(ent, "nitrous", 0)
        RD_AddResource(ent, "nitrogen", 0)
        RD_AddResource(ent, "naturalgas", 0)
        RD_AddResource(ent, "propane", 0)
		LS_RegisterEnt(ent, "Generator")
		return {}, maxhealth, mass
	end
    cubesystems.lifecube_storage = function( ply, ent, system_type, system_class, model )
		local rtable, maxhealth, mass = {}, 0, 0
        local maxofall = 100000000
			maxhealth = 1200
			mass = 50
			RD_AddResource(ent, "energy", maxofall)
            RD_AddResource(ent, "air", maxofall)
            RD_AddResource(ent, "coolant", maxofall)
            RD_AddResource(ent, "heavy water", maxofall)
            RD_AddResource(ent, "water", maxofall)
            RD_AddResource(ent, "steam", maxofall)
            RD_AddResource(ent, "ZPE", maxofall)
            RD_AddResource(ent, "methane", maxofall)
            RD_AddResource(ent, "nitrous", maxofall)
            RD_AddResource(ent, "nitrogen", maxofall)
            RD_AddResource(ent, "naturalgas", maxofall)
            RD_AddResource(ent, "propane", maxofall)
		LS_RegisterEnt(ent, "Storage")
		return rtable, maxhealth, mass
	end

end

local cubesystems_models = {
    { 'Life Cube Generator', 'models/props_junk/popcan01a.mdl', 'lifecube_gen' },
    { 'Life Cube Storage', 'models/props_junk/popcan01a.mdl', 'lifecube_storage' },
    { 'Life Cube Gas Generator', 'models/props_junk/popcan01a.mdl', 'lifecube_gasgen' }
    
}

RD2_ToolRegister( TOOL, cubesystems_models, nil, "cubesystems", 30, cubesystems )
