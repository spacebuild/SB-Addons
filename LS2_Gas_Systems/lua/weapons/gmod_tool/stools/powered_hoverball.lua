TOOL.Category   = "Gas Systems"  
TOOL.Name     = "Hoverball (Powered)"  
TOOL.Command    = nil  
TOOL.ConfigName   = "" 
if (CLIENT and GetConVarNumber("RD_UseLSTab") == 1) then TOOL.Tab = "Life Support" end

TOOL.ClientConVar["type"] = "energy_hoverball"
TOOL.ClientConVar["model"] = "models/dav0r/hoverball.mdl"

if ( CLIENT ) then
	language.Add( "Tool_powered_hoverball_name", "Powered Hoverballs" )
	language.Add( "Tool_powered_hoverball_desc", "Spawns A Resource Consuming Hoverball." )
	language.Add( "Tool_powered_hoverball_0", "Left Click: Spawn Hoverball. Right Click: Repair Hoverball" )
	
	language.Add( "Undone_powered_hoverball", "Powered Hoverball Undone" )
	language.Add( "Cleanup_powered_hoverball", "Powered Hoverball" )
	language.Add( "Cleaned_powered_hoverball", "Cleaned up all Powered Hoverballs" )
	language.Add( "SBoxLimit_powered_hoverball", "Maximum Powered Hoverballs Reached" )
end

if not ( RES_DISTRIB == 2 ) then Error("Please Install Resource Distribution 2 Addon." ) return end

if( SERVER ) then
	CreateConVar("sbox_maxpowered_hoverball", 20)
	
	function Makepowered_hoverball( ply, ang, pos, hovtype, model, frozen )
		if ( !ply:CheckLimit( "powered_hoverball" ) ) then return nil end
		
		--Create generator
		local ent = ents.Create( hovtype )
		
		-- Set
		ent:SetPos( pos )
		ent:SetAngles( ang )
		
		ent:Spawn()
		ent:Activate()
		
		ent:SetVar("Owner", ply)
		ent:SetPlayer(ply)
		
		--for duplication, call it Class to fake it for old dupe saves but 
		ent.Class = hovtype
		
		if (frozen) then
			local phys = ent:GetPhysicsObject()
			if (phys:IsValid()) then
				phys:EnableMotion( false ) 
				ply:AddFrozenPhysicsObject( ent, phys )
			end
		end
		
		ply:AddCount("powered_hoverball", ent)
		
		return ent
	end
	
	duplicator.RegisterEntityClass("Energy Hoverball", Makepowered_hoverball, "Ang", "Pos", "Class", "model", "frozen")
end

local pow_hov_models = {
		{ "Energy Hoverball", "models/props_wasteland/laundry_washer001a.mdl", "energy_hoverball" },
		{ "Propane Hoverball", "models/props_wasteland/laundry_washer001a.mdl", "propane_hoverball" },
		{ "Methane Hoverball", "models/props_wasteland/laundry_washer001a.mdl", "methane_hoverball" },
		{ "Nitrous Oxide Hoverball", "models/props_wasteland/laundry_washer001a.mdl", "nitrous_hoverball" },
}

RD2_ToolRegister( TOOL, pow_hov_models, Makepowered_hoverball, "powered_hoverball" )
