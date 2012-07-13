TOOL.Category   = "Petrol"  
TOOL.Name     = "Storage Devices"  
TOOL.Command    = nil  
TOOL.ConfigName   = "" 
if (CLIENT and GetConVarNumber("RD_UseLSTab") == 1) then TOOL.Tab = "Life Support" end

TOOL.ClientConVar['type'] = 'bigenergygen'
TOOL.ClientConVar['model'] = 'models/props_vehicles/generatortrailer01.mdl'

if ( CLIENT ) then
	language.Add( "Tool_petrolstor_name", "Petrol Generators" )
	language.Add( "Tool_petrolstor_desc", "Spawns Generators For Petrol Mod" )
	language.Add( "Tool_petrolstor_0", "Left click: Spawn" )

	language.Add( 'Undone_petrolstor', 'LS: Petrol Generator Undone' )
	language.Add( 'Cleanup_petrolstor', 'LS: Petrol Generator' )
	language.Add( 'Cleaned_petrolstor', 'Cleaned up all Petrol Generators' )
	language.Add( 'SBoxLimit_petrolstor', 'Maximum Petrol Generators Reached' )
end

if not ( RES_DISTRIB == 2 ) then Error("Please Install Resource Distribution 2 Addon.'" ) return end

if( SERVER ) then
	CreateConVar('sbox_maxpetrolstor', 25)
	
	function Makepetrolstor( ply, ang, pos, gentype, model, frozen )
		if ( !ply:CheckLimit( "petrolstor" ) ) then return nil end
		
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
		
		ply:AddCount('petrolstor', ent)
		
		return ent
	end
	
	duplicator.RegisterEntityClass("batterycharger", Makepetrolstor, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("batteryinverter", Makepetrolstor, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("crackingtower", Makepetrolstor, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("munitiongen", Makepetrolstor, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("oildistil", Makepetrolstor, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("plight", Makepetrolstor, "Ang", "Pos", "Class", "model", "frozen")
end

local receptacle_models = {
	{"Battery", "models/items/car_battery01.mdl", "battery" },
	{"Crude Oil Barrel", "models/props_c17/oildrum001.mdl", "crudebarrel" },
	{"Crude Oil Tank", "models/props_wasteland/coolingtank01.mdl", "crudetank" },
	{"Oil Barrel", "models/props_c17/oildrum001.mdl", "oilbarrel" },
	{"Oil Tank", "models/props_wasteland/horizontalcoolingtank04.mdl", "oiltank" },
	{"Oil Can", "models/props_junk/gascan001a.mdl", "oilcan" },
	{"Petrol Barrel", "models/props_c17/oildrum001_explosive.mdl", "petrolbarrel" },
	{"Petrol Tank", "models/props_wasteland/horizontalcoolingtank04.mdl", "petroltank" },
	{"Petrol Can", "models/props_junk/metalgascan.mdl", "petrolcan" },
	{"The Everything Cache", "models/props_wasteland/kitchen_fridge001a.mdl", "thecache" },
}

RD2_ToolRegister( TOOL, receptacle_models, Makepetrolstor, "petrolstor" )
