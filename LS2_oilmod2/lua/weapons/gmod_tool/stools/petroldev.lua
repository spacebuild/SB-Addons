TOOL.Category   = "Petrol"  
TOOL.Name     = "Devices"  
TOOL.Command    = nil  
TOOL.ConfigName   = "" 
if (CLIENT and GetConVarNumber("RD_UseLSTab") == 1) then TOOL.Tab = "Life Support" end

TOOL.ClientConVar['type'] = 'batterycharger'
TOOL.ClientConVar['model'] = 'models/props_c17/consolebox05a.mdl'

if ( CLIENT ) then
	language.Add( "Tool_petroldev_name", "Petrol Devices" )
	language.Add( "Tool_petroldev_desc", "Spawns Devices For Petrol Mod" )
	language.Add( "Tool_petroldev_0", "Left click: Spawn and weld. Right click: Spawn And don't Weld" )
	
	language.Add( 'Undone_petroldev', 'Life Petrol Device Undone' )
	language.Add( 'Cleanup_petroldev', 'LS: Petrol Device' )
	language.Add( 'Cleaned_petroldev', 'Cleaned up all Petrol Devices' )
	language.Add( 'SBoxLimit_petroldev', 'Maximum Environmental Petrol Devices Reached' )
end

if not ( RES_DISTRIB == 2 ) then Error("Please Install Resource Distribution 2 Addon.'" ) return end

if( SERVER ) then
	CreateConVar('sbox_maxpetroldev', 10)
	
	function MakePetrolDevice( ply, ang, pos, gentype, model, frozen )
		if ( !ply:CheckLimit( "petroldev" ) ) then return nil end
		
		--Create generator
		local ent = ents.Create( gentype )
		
		-- Reset for odly shaped models.
		if (gentype == "plight") then
			ang.pitch = ang.pitch + 180
		end
		
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
		
		ply:AddCount('petroldev', ent)
		
		return ent
	end
	
	duplicator.RegisterEntityClass("batterycharger", MakePetrolDevice, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("batteryinverter", MakePetrolDevice, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("crackingtower", MakePetrolDevice, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("munitiongen", MakePetrolDevice, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("oildistil", MakePetrolDevice, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("plight", MakePetrolDevice, "Ang", "Pos", "Class", "model", "frozen")
end

local receptacle_models = {
	{"Battery Charger", "models/props_c17/consolebox05a.mdl", "batterycharger" },
	{"Battery Inverter", "models/props_c17/consolebox03a.mdl", "batteryinverter" },
	{"Cracking Tower", "models/props_canal/bridge_pillar02.mdl", "crackingtower" },
	--{"Munitions Generator", "models/props_wasteland/kitchen_stove002a.mdl", "munitiongen" }, -- dISABLED tILL FIXED
	{"Oil Distiller", "models/props_c17/furnitureboiler001a.mdl", "oildistil" },
	{"Powered Light", "models/props_wasteland/prison_lamp001c.mdl", "plight" },
}

RD2_ToolRegister( TOOL, receptacle_models, MakePetrolDevice, "petroldev" )
