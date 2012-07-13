TOOL.Category   = "Petrol"  
TOOL.Name     = "Generators"  
TOOL.Command    = nil  
TOOL.ConfigName   = "" 
if (CLIENT and GetConVarNumber("RD_UseLSTab") == 1) then TOOL.Tab = "Life Support" end

TOOL.ClientConVar['type'] = 'bigenergygen'
TOOL.ClientConVar['model'] = 'models/props_vehicles/generatortrailer01.mdl'

if ( CLIENT ) then
	language.Add( "Tool_petrolgen_name", "Petrol Generators" )
	language.Add( "Tool_petrolgen_desc", "Spawns Generators For Petrol Mod" )
	language.Add( "Tool_petrolgen_0", "Left click: Spawn" )
	
	language.Add( 'Undone_petrolgen', 'LS: Petrol Generator Undone' )
	language.Add( 'Cleanup_petrolgen', 'LS: Petrol Generator' )
	language.Add( 'Cleaned_petrolgen', 'Cleaned up all Petrol Generators' )
	language.Add( 'SBoxLimit_petrolgen', 'Maximum Petrol Generators Reached' )
end

if not ( RES_DISTRIB == 2 ) then Error("Please Install Resource Distribution 2 Addon.'" ) return end

if( SERVER ) then
	CreateConVar('sbox_maxpetrolgen', 10)
	
	function Makepetrolgen( ply, ang, pos, gentype, model, frozen )
		if ( !ply:CheckLimit( "petrolgen" ) ) then return nil end
		
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
		
		ply:AddCount('petrolgen', ent)
		
		return ent
	end
	
	duplicator.RegisterEntityClass("batterycharger", Makepetrolgen, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("batteryinverter", Makepetrolgen, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("crackingtower", Makepetrolgen, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("munitiongen", Makepetrolgen, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("oildistil", Makepetrolgen, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("plight", Makepetrolgen, "Ang", "Pos", "Class", "model", "frozen")
end

local receptacle_models = {
	{"Energy Generator", "models/props_vehicles/generatortrailer01.mdl", "bigenergygen" },
	{"Coolant Generator", "models/props_vehicles/generatortrailer01.mdl", "bigcoolantgen" },
	{"Hydrogen Generator", "models/props_vehicles/generatortrailer01.mdl", "bighydrogen" },
	{"Air Generator", "models/props_vehicles/generatortrailer01.mdl", "bigairgen" }, -- dISABLED tILL FIXED
}

RD2_ToolRegister( TOOL, receptacle_models, Makepetrolgen, "petrolgen" )
