/*******************************************************************************************************
	This code is part of the CDS core and shouldn't be removed!
	In here an entity or player or ... will be registered with CDS when spawned(doesn't work on sents
	spawned with an stool(check info for developers for a way around this).
	The 2 variables under here are the time in seconds a player or ent has Spawn Protection(if active)
	
	New System uses a different hook.
*******************************************************************************************************/
local prot_player = 15 --Spawn Protection Time in Seconds for players
local prot_ent = 90 --Spawn protection Time in Seconds for Entities
/*Info for developers
	Functions that can be called in here:
		CDS_Spawned( entity, isplayer ) This function will register an entity for use with CDS
						(can be used for sent that are spawned with an stool
						already included in the RD2 Base Stool code).
						Entity: the entity you would like to register
						isplayer: false(or nil) or true
						For a sent this would be enough: CDS_Spawned(self)
						 for exemple
	THIS IS NOW UNNESSESARY! I think....

*/
/*******************************************************************************************************
	DON'T EDIT FROM HERE
*******************************************************************************************************/
function CDS_Spawned(ent)
	if ent.CDS_SpawnedReged then return end
	return CDS_Spawned(ent, ent:IsPlayer() or ent:IsNPC())
	--Msg("Entity: ",ent," created.\n")
end
hook.Add( "OnEntityCreated", "CDS_Spawn", CDS_Spawned)
hook.Add( "PlayerSpawnedNPC", "CDS_NPCSpawn", CDS_SpawnedSENT )
hook.Add( "PlayerSpawnedSENT", "CDS_SENTSpawn", CDS_SpawnedSENT )
hook.Add( "PlayerSpawnedProp", "CDS_PropSpawn", CDS_SpawnedSENT )

function CDS_SpawnedSENT(ply, ent)
	if ent.CDS_SpawnedReged then return end
	return CDS_Spawned(ent, ply)
	--Msg("Entity: ",ent," created by STool/Menu spawn.\n")
end

function setEntActive(ent)
	if ent:IsValid() then
		ent.CDSIgnore = false
	end
end 

function CDS_Spawned( ent, ply ) --ply = bool (player or npc)
	--not server_settings.Bool( "CDS_Enabled" )
	--Entitys are still regeistered even if the damage system is disabled so it'll use them when they'll be enabled
	if not (ent and ent.IsValid and ent:IsValid()) or CDS_IsWorldEnt(ent) or ent.CDSIgnore or CDS_Ignore(ent) then return false end
	if not ent:GetModel() then return false end
	if (not ply or not ply == true) then ply = false end --physbox check will be later.
	if (not ent.CDSIgnore and server_settings.Bool( "CDS_SpawnProtect" )) then
		if ply then
			timer.Simple(prot_player,setEntActive,ent)
		else	
			timer.Simple(prot_ent,setEntActive,ent)
		end
		ent.CDSIgnore = true
	end
	local maxarmor  = CDS_MaxArmor()
	local maxhealth = CDS_MaxHealth()
	local minhealth = CDS_MinHealth()
	if ply then
		maxarmor  = 15
		maxhealth = 0
	end
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() or ply then --player and npc check is used incase phys would return false
		ent.CDS_SpawnedReged = true --so it won't be registerd twice for some reason
		local Mat = CDS_GetMatType(ent)
		if not ent.maxhealth then
			if ply then
				ent.maxhealth = 0
			else
				if not ent.health then
					ent.maxhealth = CDS_GetHAFromMatType(Mat, ent, true)
				else
					ent.maxhealth = ent.health
				end
			end
		end
		if ent.maxhealth > maxhealth then
			ent.maxhealth = maxhealth
		end
		if not ply and ent.maxhealth < minhealth then
			ent.maxhealth = minhealth
		elseif ply and ent.maxhealth ~= 0 then
			ent.maxhealth = 0 --Edit: Spacetech
		end
		if not ent.health then
			ent.health = ent.maxhealth
		end
		if ent.health > ent.maxhealth then
			ent.health = ent.maxhealth
		end
		if not ent.maxarmor then
			if ply then
				ent.maxarmor = 0
			else
				if not ent.armor then
					ent.maxarmor = CDS_GetHAFromMatType(Mat, ent)
				else
					ent.maxarmor = ent.armor
				end
			end
		end
		if ent.maxarmor > maxarmor then
			ent.maxarmor = maxarmor
		end
		if not ent.armor or ent.armor > ent.maxarmor then
			ent.armor = ent.maxarmor
		end
		--add heat
		if not ent.heat then
			ent.heat = 0
		end
		if GAMEMODE.IsSpaceBuildDerived then
			if ply then
				if not ent.suit then
					ent.suit = {}
					ent.suit.atmosphere = 0
					ent.suit.habitat = 0
					ent.suit.temperature = 273
				end
			elseif not ent.environment then
				ent.environment = {}
				ent.environment.atmosphere = 0
				ent.environment.habitat = 0
				ent.environment.temperature = 273
				phys:Wake()
			end
		end
		InsertIntoAff(ent)
		return true
	end
	return false
end
