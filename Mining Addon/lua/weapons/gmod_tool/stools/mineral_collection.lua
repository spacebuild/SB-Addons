
TOOL.Category = '(Asteroid Mining)'
TOOL.Name = '#Mineral Collection'
TOOL.Command = nil
TOOL.ConfigName = ''
if (CLIENT and LocalPlayer():GetInfo("RD_UseLSTab") == "1") then TOOL.Tab = "Life Support" end

TOOL.ClientConVar['type'] = 'mining_laser'
TOOL.ClientConVar['model'] = 'models/props_trainstation/TrackLight01.mdl'

cleanup.Register('mineralcollectors')

if ( CLIENT ) then
	language.Add( 'Tool_mineral_collection_name', 'Mineral Collection Device Spawner' )
	language.Add( 'Tool_mineral_collection_desc', 'Create Mineral Collection Devices attached to any surface.' )
	language.Add( 'Tool_mineral_collection_0', 'Click somewhere to attach a Mineral Collection Device.' )

	language.Add( 'Undone_mineral_collection', 'Mineral Collection Device Undone' )
	language.Add( 'Cleanup_mineral_collection', 'Mineral Collection Device' )
	language.Add( 'Cleaned_mineral_collection', 'Cleaned up all Mineral Collection Devices' )
	language.Add( 'SBoxLimit_mineraldevices', 'Maximum Mineral Collection Devices Reached' )
end

if not ( RES_DISTRIB == 2 ) then Error("Please Install Resource Distribution 2 Addon.'" ) return end

local mineraldevice_models = {
	{ 'Mining Laser', 'models/props_trainstation/TrackLight01.mdl', 'mining_laser' },
	{ 'Mineral Scanner', 'models/props_rooftop/Roof_Dish001.mdl', 'mineral_scanner' },
	{ 'Ore Collector', 'models/props_c17/light_industrialbell02_on.mdl', 'ore_collector' },
	{ 'Mineral Storage', 'models/props_c17/substation_transformer01b.mdl', 'mineral_storage' }
}

RD2_ToolRegister( TOOL, mineraldevice_models, nil, "mineral_collection", 5 )
