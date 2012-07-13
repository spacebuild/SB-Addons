TOOL.Category   = "Gas Systems"  
TOOL.Name     = "#Environmental Control"  
TOOL.Command    = nil  
TOOL.ConfigName   = "" 
if (CLIENT and GetConVarNumber("RD_UseLSTab") == 1) then TOOL.Tab = "Life Support" end

TOOL.ClientConVar["type"] = "healing_station"
TOOL.ClientConVar["model"] = "models/Items/HealthKit.mdl"

if ( CLIENT ) then
	language.Add( "Tool_gas_envcontrol_name", "Gas Environmental Device" )
	language.Add( "Tool_gas_envcontrol_desc", "Spawns Gas powered devices that aid your survival." )
	language.Add( "Tool_gas_envcontrol_0", "Left Click: Spawn A Device. Right Click: Repair A Device" )
	
	language.Add( "Undone_gas_envcontrol", "Gas Environmental Device Undone" )
	language.Add( "Cleanup_gas_envcontrol", "Gas Environmental Device" )
	language.Add( "Cleaned_gas_envcontrol", "Cleaned up all Gas Environmental Devices" )
	language.Add( "SBoxLimit_gas_envcontrol", "Maximum Gas Environmental Devices Reached" )
end

if not ( RES_DISTRIB == 2 ) then Error("Please Install Resource Distribution 2 Addon." ) return end

if( SERVER ) then
	CreateConVar("sbox_maxgas_envcontrol", 12)
	
	function Makegas_envcontrol( ply, ang, pos, gentype, model, frozen )
		if ( !ply:CheckLimit( "gas_envcontrol" ) ) then return nil end
		
		--Create generator
		local ent = ents.Create( gentype )
		
		-- Set
		if(gentype == "healing_station") then
			ent:SetModel( "models/Items/HealthKit.mdl" )
		end
		ent:SetPos( pos )
		ent:SetAngles( ang )
		
		ent:Spawn()
		ent:Activate()
		
		ent:SetVar("Owner", ply)
		ent:SetPlayer(ply)
		
		ent.Class = gentype
		
		if (frozen) then
			local phys = ent:GetPhysicsObject()
			if (phys:IsValid()) then
				phys:EnableMotion( false ) 
				ply:AddFrozenPhysicsObject( ent, phys )
			end
		end
		
		ply:AddCount("gas_envcontrol", ent)
		
		return ent
	end
	
	duplicator.RegisterEntityClass("Health Dispenser", Makegas_envcontrol, "Ang", "Pos", "Class", "model", "frozen")
end

local gas_env_models = {
		{ "Health Dispenser", "models/Items/HealthKit.mdl", "healing_station" }
}

RD2_ToolRegister( TOOL, gas_env_models, Makegas_envcontrol, "gas_envcontrol" )
