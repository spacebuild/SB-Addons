/*******************************************************************************************************
	This code is part of the CDS core and shouldn't be removed!
	In here things like armor calculation, spawn cecking and other important function are done.
	Below you can modify the armor multipliers based on there material.
*******************************************************************************************************/

local CDS_CONCRETE 		= 1.8
local CDS_METAL 		= 2 
local CDS_DIRT 			= 0.4
local CDS_VENT 			= 1.5
local CDS_GRATE 		= 1.2
local CDS_TILE 			= 1
local CDS_SLOSH 		= 0.3
local CDS_WOOD 			= 0.7
local CDS_COMPUTER 		= 0.6
local CDS_GLASS 		= 0.1
local CDS_FLESH 		= 0
local CDS_BLOODYFLESH 		= 0
local CDS_CLIP 			= 0
local CDS_ANTLION 		= 0.1
local CDS_ALIENFLESH 		= 0
local CDS_FOLIAGE 		= 0.1
local CDS_SAND 			= 0.3
local CDS_PLASTIC 		= 0.9

/*Info for developers
	Functions that can be called in here:
		CDS_AddResource(resoure_name) This function will add the specific resource to the Resource list(Used for the resource Syncer)	
		CDS_AddIgnored(class_name) This function will add a specific Sent class to the CDS ignored list
		CDS_GetResources() This function will return a copy of the Resource Table.
		CDS_GetMatType(entity) This function will return null or the specific MatType value(check the Garrysmod Wiki or this code for the details)
		CDS_IsWorldEnt(entity) This function will return if the Entity specified is a world entity or not.
*/

/*******************************************************************************************************
	DON'T EDIT FROM HERE
*******************************************************************************************************/
local cds_worldents = {}
local ignored = {} 
local Resources = {}

function CDS_AddResource( name)
	if not table.HasValue(Resources, name) then
		table.insert(Resources, name)
	end
end

function CDS_AddIgnored(class) 
	if not table.HasValue(ignored, class) then
		table.insert(ignored, class)
	end
end	

function CDS_GetResources()
	return table.Copy(Resources)
end

function CDS_GetMatType(ent)
	local tr = {}
	local min,max = ent:WorldSpaceAABB() 
	tr.start = min
	tr.endpos = max
	tr = util.TraceLine( tr )
	return tr.MatType
end

function CDS_InValid(ent)
	if (not ent.health or not ent.armor or not ent.heat or not HasValueAff(ent)) and not CDS_LastCheck(ent) then 
		return true 
	end
	return false
end

function CDS_LastCheck(ent)
	if not ent or not (ent:IsValid()) then return false end
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() and not ent.CDSIgnore then
		local ply = false
		if ent:IsPlayer() or ent:IsNPC() then 
			ply = true
		end
		return CDS_Spawned( ent, ply )
	end
	return false
end

function CDS_IsWorldEnt(ent)
	if(table.HasValue(cds_worldents, ent)) then 
		return true 
	end
	return false
end

function CDS_Ignore(ent)
	local str = ent:GetClass() 
	if (table.HasValue(ignored, str)) then 
		return true
	end
	return false
end

function CDS_PHXMatCheck(ent)
	local multi = 0.5
	local name = ent:GetModel()
	if string.find(name, "phx") then
		multi = 1
	end
	if string.find(name, "metal") then
		multi = CDS_METAL
	elseif string.find(name, "wood") then
		multi = CDS_WOOD
	elseif string.find(name, "glass") or string.find(name, "windows") then
		multi = CDS_GLASS
	elseif string.find(name, "plastic") then
		multi = CDS_PLASTIC
	end
	return multi
end

function CDS_GetHAFromMatType(mattype, ent, health)
	local phys = ent:GetPhysicsObject()
	local mass = phys:GetMass()
	local multi = 1 --Default multiplier
	if not mattype then
		multi = CDS_PHXMatCheck(ent)
	elseif mattype == MAT_CONCRETE then
		multi = CDS_CONCRETE
	elseif mattype == MAT_METAL then
		multi = CDS_METAL
	elseif mattype == MAT_DIRT then
		multi = CDS_DIRT
	elseif mattype == MAT_VENT then
		multi = CDS_VENT
	elseif mattype == MAT_GRATE then
		multi = CDS_GRATE
	elseif mattype == MAT_TILE  then
		multi = CDS_TILE
	elseif mattype == MAT_SLOSH then
		multi = CDS_SLOSH
	elseif mattype == MAT_WOOD then
		multi = CDS_WOOD
	elseif mattype == MAT_COMPUTER then
		multi = CDS_COMPUTER
	elseif mattype == MAT_GLASS then
		multi = CDS_GLASS
	elseif mattype == MAT_FLESH  then
		multi = CDS_FLESH
	elseif mattype == MAT_BLOODYFLESH then
		multi = CDS_BLOODYFLESH
	elseif mattype == MAT_CLIP then
		multi = CDS_CLIP
	elseif mattype == MAT_ANTLION then
		multi = CDS_ANTLION
	elseif mattype == MAT_ALIENFLESH then
		multi = CDS_ALIENFLESH
	elseif mattype == MAT_FOLIAGE then
		multi = CDS_FOLIAGE
	elseif mattype == MAT_SAND  then
		multi = CDS_SAND
	elseif mattype == MAT_PLASTIC then
		multi = CDS_PLASTIC
	end
	if health then
		return math.ceil(mass * (0.5 + multi) * 4)
	end
	return math.ceil(multi * 25)		
end

function CDS_HealthCheck(ent)
	if ent:IsValid() and not ent:IsPlayer() and not ent:IsNPC() then
		if ent.health < ent.maxhealth/(math.random(15,50)) then
			constraint.RemoveAll( ent )
		end
	end
end

function CDS_ShieldImpact(pos)
	local Effect = EffectData()
	Effect:SetOrigin(pos)
	util.Effect("cds_shield_impact", Effect, true, true)
end

function CDS_WorldOwner()
	local WorldEnts = 0
	for k, ent in pairs(ents.FindByClass("*")) do
		if not ent:IsPlayer() and not ent:IsNPC() then
			table.insert(cds_worldents, ent)
			WorldEnts = WorldEnts + 1
		end
	end
	Msg("=====================================================\n")
	Msg("Combat Damage System: "..tostring(WorldEnts).." props belong to world\n")
	Msg("=====================================================\n")
end
hook.Add( "InitPostEntity", "CDS_init_world", CDS_WorldOwner )
