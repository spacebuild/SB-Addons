TOOL.Category   = "Gas Systems"  
TOOL.Name     = "#Storage"  
TOOL.Command    = nil  
TOOL.ConfigName   = "" 
if (CLIENT and GetConVarNumber("RD_UseLSTab") == 1) then TOOL.Tab = "Life Support" end

TOOL.ClientConVar["type"] = "gas_extractor"
TOOL.ClientConVar["model"] = "models/props/cs_assault/firehydrant.mdl"

if ( CLIENT ) then
	language.Add( "Tool_gas_storage_name", "Gas Storages" )
	language.Add( "Tool_gas_storage_desc", "Spawns A Storage for use with Gas Systems." )
	language.Add( "Tool_gas_storage_0", "Left Click: Spawn A Storage. Right Click: Repair A Storage" )
	
	language.Add( "Undone_gas_storage", "Gas Storage Undone" )
	language.Add( "Cleanup_gas_storage", "Gas Storage" )
	language.Add( "Cleaned_gas_storage", "Cleaned up all Gas Storages" )
	language.Add( "SBoxLimit_gas_storage", "Maximum Gas Storages Reached" )
end

if not ( RES_DISTRIB == 2 ) then Error("Please Install Resource Distribution 2 Addon." ) return end

if( SERVER ) then
	CreateConVar("sbox_maxgas_storage", 20)
	
	function Makegas_storage( ply, ang, pos, gentype, model, frozen )
		if ( !ply:CheckLimit( "gas_storage" ) ) then return nil end
		
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
		
		ply:AddCount("gas_storage", ent)
		
		return ent
	end
	
	duplicator.RegisterEntityClass("Large Natural Gas Tank", Makegas_storage, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("Small Natural Gas Tank", Makegas_storage, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("Large Processed Gas Tank", Makegas_storage, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("Small Processed Gas Tank", Makegas_storage, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("Large Nitrous Oxide Tank", Makegas_storage, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("Small Nitrous Oxide Tank", Makegas_storage, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("Large Methane Storage", Makegas_storage, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("Small Methane Tank", Makegas_storage, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("Large Propane Tank", Makegas_storage, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("Small Propane Tank", Makegas_storage, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("Large Nitrogen Tank", Makegas_storage, "Ang", "Pos", "Class", "model", "frozen")
	duplicator.RegisterEntityClass("Small Nitrogen Tank", Makegas_storage, "Ang", "Pos", "Class", "model", "frozen")
end

local gas_stor_models = {
		{ "Huge Natural Gas Tank", "models/props_wasteland/coolingtank02.mdl", "gas_hstore" },
		{ "Large Natural Gas Tank", "models/props_wasteland/laundry_washer001a.mdl", "gas_lstore" },
		{ "Small Natural Gas Tank", "models/props_c17/oildrum001.mdl", "gas_sstore" },
		{ "Huge Processed Gas Tank", "models/props_buildings/watertower_001c.mdl", "gas_phstore" },
        { "Large Processed Gas Tank", "models/props_wasteland/horizontalcoolingtank04.mdl", "gas_plstore" },
		{ "Small Processed Gas Tank", "models/props_junk/propane_tank001a.mdl", "gas_psstore" },
		{ "Huge Nitrous Oxide Tank", "models/props/de_nuke/fuel_cask.mdl", "gas_hnitrostore"},
        { "Large Nitrous Oxide Tank", "models/props_borealis/bluebarrel001.mdl", "gas_lnitrostore"},
		{ "Small Nitrous Oxide Tank", "models/props_junk/PropaneCanister001a.mdl", "gas_snitrostore"},
		{ "Huge Methane Storage", "models/props/de_nuke/fuel_cask.mdl", "gas_hmethstore" },
		{ "Large Methane Storage", "models/props_junk/trashdumpster01a.mdl", "gas_methstore" },
		{ "Small Methane Tank", "models/props_junk/metalgascan.mdl", "gas_smethstore" },
		{ "Huge Propane Tank", "models/props/de_nuke/fuel_cask.mdl", "gas_hproptank" },
		{ "Large Propane Tank", "models/props_c17/canister_propane01a.mdl", "gas_lproptank" },
		{ "Small Propane Tank", "models/props_junk/propane_tank001a.mdl", "gas_proptank" },
		{ "Huge Nitrogen Tank", "models/props/de_nuke/fuel_cask.mdl", "gas_hnitstore" },
		{ "Large Nitrogen Tank", "models/props_borealis/bluebarrel001.mdl", "gas_lnitstore" },
		{ "Small Nitrogen Tank", "models/props_c17/canister01a.mdl", "gas_snitstore" }
}

RD2_ToolRegister( TOOL, gas_stor_models, Makegas_storage, "gas_storage" )
