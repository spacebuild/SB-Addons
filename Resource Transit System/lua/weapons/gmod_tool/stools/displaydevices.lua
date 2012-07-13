TOOL.Category = '(Resource Transit)'
TOOL.Name = '#Resource Display Systems'
TOOL.Command = nil
TOOL.ConfigName = ''
if (CLIENT and GetConVarNumber("CAF_UseTab") == 1) then TOOL.Tab = "Custom Addon Framework" end

TOOL.ClientConVar['type'] = 'air_tank'
TOOL.ClientConVar['model'] = 'models/props_vehicles/generatortrailer01.mdl'

if ( CLIENT ) then
	language.Add( 'Tool_displaydevices_name', 'Resource Display Devices' )
	language.Add( 'Tool_displaydevices_desc', 'Create Display Devices attached to any surface.' )
	language.Add( 'Tool_displaydevices_0', 'Left-Click: Spawn a Device.  Right-Click: Repair Device.' )

	language.Add( 'Undone_displaydevices', 'Display Device Undone' )
	language.Add( 'Cleanup_displaydevices', 'LS: Display Device' )
	language.Add( 'Cleaned_displaydevices', 'Cleaned up all Display Devices' )
	language.Add( 'SBoxLimit_displaydevices', 'Maximum Display Devices Reached' )end

if not CAF or not CAF.GetAddon("Resource Distribution") then Error("Please Install Resource Distribution Addon.'" ) return end

if( SERVER ) then
	CreateConVar('sbox_maxdisplaydevices', 10)
	
	function Makedisplaydevices( ply, ang, pos, gentype, model, frozen )
		if ( not ply:CheckLimit( "displaydevices" ) ) then return nil end
		
		--Create generator
		local ent = ents.Create( gentype )
		
		
		
		-- Set
		ent:SetPos( pos )
		ent:SetAngles( ang )
		
		ent:Spawn()
		ent:Activate()
		
		ent:SetVar('Owner', ply)
		ent:SetPlayer(ply)
		
		--for duplication, call it Class to fake it for old dupe saves but 
		ent.Class = gentype
		
		if (frozen) then
			local phys = ent:GetPhysicsObject()
			if (phys:IsValid()) then
				phys:EnableMotion( false ) 
				ply:AddFrozenPhysicsObject( ent, phys )
			end
		end
		
		ply:AddCount('displaydevices', ent)
		
		return ent
	end
	
end

local receptacle_models = {
	{"Hologauge", "models/Gibs/HGIBS_spine.mdl", "rts_hologauge" },
}

CAF_ToolRegister( TOOL, receptacle_models, Makedisplaydevices, "displaydevices" )