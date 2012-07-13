TOOL.Category   = "Gas Systems"  
TOOL.Name     = "#Generators"  
TOOL.Command    = nil  
TOOL.ConfigName   = "" 
if (CLIENT and GetConVarNumber("RD_UseLSTab") == 1) then TOOL.Tab = "Life Support" end

TOOL.ClientConVar["type"] = "gas_extractor"
TOOL.ClientConVar["model"] = "models/props/cs_assault/firehydrant.mdl"

if ( CLIENT ) then
	language.Add( "Tool_gas_generator_name", "Gas Devices" )
	language.Add( "Tool_gas_generator_desc", "Spawns A Device for use with Gas Systems." )
	language.Add( "Tool_gas_generator_0", "Left Click: Spawn A Device. Right Click: Repair A Device" )
	
	language.Add( "Undone_gas_generator", "Gas Device Undone" )
	language.Add( "Cleanup_gas_generator", "Gas Device" )
	language.Add( "Cleaned_gas_generator", "Cleaned up all Gas Devices" )
	language.Add( "SBoxLimit_gas_generator", "Maximum Gas Devices Reached" )
end

if not ( RES_DISTRIB == 2 ) then Error("Please Install Resource Distribution 2 Addon." ) return end

if( SERVER ) then
	CreateConVar("sbox_maxgas_generator", 20)
	
	function Makegas_generator( ply, ang, pos, gentype, model, frozen )
		if ( !ply:CheckLimit( "gas_generator" ) ) then return nil end
		
		--Create generator
		local ent = ents.Create( gentype )
		
		-- Set
		ent:SetPos( pos )
		ent:SetAngles( ang )
		
		ent:Spawn()
		ent:Activate()
		
		ent:SetVar("Owner", ply)
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
		
		ply:AddCount("gas_generator", ent)
		
		return ent
	end
	
	duplicator.RegisterEntityClass("Natural Gas Extractor", Makegas_generator, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("Natural Gas (Oil) Extractor", Makegas_generator, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("Natural Gas Processor", Makegas_generator, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("Nitrogen Oxidizer", Makegas_generator, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("Nitrogen Liquidizer", Makegas_generator, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("Nitrogen Inverter", Makegas_generator, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("Large Gas Reactor", Makegas_generator, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("Micro Gas Reactor", Makegas_generator, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("Methane Collector", Makegas_generator, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("Propane Collector", Makegas_generator, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("Nitrogen Collector", Makegas_generator, "Ang", "Pos", "Class", "model", "frozen")
end

local gas_gen_models = {
		{"Natural Gas Extractor", "models/props/cs_assault/firehydrant.mdl", "gas_extractor"},
		{"Natural Gas (Oil) Extractor", "models/props_wasteland/gaspump001a.mdl", "gas_oil_extractor"},
        {"Natural Gas Processor", "models/props_industrial/oil_storage.mdl", "gas_processor"},
        {"Nitrogen Oxidizer", "models/props/de_nuke/equipment2.mdl", "gas_nitrooxidizer"},
        {"Nitrogen Liquidizer", "models/Gibs/airboat_broken_engine.mdl", "gas_nitroliq"},
		{"Nitrogen Inverter", "models/props_c17/FurnitureBoiler001a.mdl", "gas_inverter"},
        {"Large Methane & Propane Reactor", "models/props_citizen_tech/steamengine001a.mdl", "gas_reactor"},
		{"Large Nitrous Oxide Reactor", "models/props_c17/factorymachine01.mdl", "gas_nitrousreactor"},
		{"Micro Methane Reactor", "models/props_combine/headcrabcannister01a.mdl", "gas_microreactor"},
		{"Micro Propane Reactor", "models/props_combine/headcrabcannister01a.mdl", "gas_micropropreactor"},
		{"Micro Nitrous Oxide Reactor", "models/props_combine/headcrabcannister01a.mdl", "gas_micronitrousreactor"},
		{"Methane Collector", "models/props_c17/light_decklight01_off.mdl", "methane_collector"},
		{"Propane Collector", "models/props_c17/light_decklight01_off.mdl", "propane_collector"},
		{"Nitrogen Collector", "models/props_c17/light_decklight01_off.mdl", "nitrogen_collector"}
}

RD2_ToolRegister( TOOL, gas_gen_models, Makegas_generator, "gas_generator" )
