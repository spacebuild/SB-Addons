AddCSLuaFile("autorun/server/sv_conflict.lua")
CONFLICTSYSTEMS = 1	-- Who knows? Someone might want to know if this is running

local CONFLICT_UseBlastWave = 1
local CONFLICT_MaxDamage	= 5000
local CONFLICT_MaxRadius	= 5000
conflict = {}

MsgN("\n- Conflict Systems: Online -\n")

-- Add some usefull functions to the player's ent.
local Meta = FindMetaTable("Player")
function Meta:GetOwnedProps() 
   	local key = self:UniqueID()						-- the player's key
   	local tab = {}
   	if not (g_SBoxObjects == nil) then
	   	for k, v in pairs(g_SBoxObjects[ key ]) do     
	   		table.Merge(tab,v)							-- make sure to return ALL the players props
	   	end
	end
	return tab		--returns a blank table if no props.
end 
function Meta:GetOwnedPropsByType(sType) 
	local tab = {}   	
   	if not (g_SBoxObjects == nil) then
		if not (g_SBoxObjects[ key ] == nil) then
			if not (g_SBoxObjects[ key ][sType] == nil) then
				tab = g_SBoxObjects[ key ][sType]		-- the requested entity type
			end
		end
	end
	return tab		--returns a blank table if no props.
end
  
-- All in one function to handle the big bangs. also lets the admins cap the damage / area / effects
function conflict.explode(damage, piercing, area, position, killcredit,useeffect)

		if not ValidEntity(killcredit) then
			killcredit = player.GetAll()[1]		-- if it's a bad killcredit, give it to player1, 
		end
		
		-- if we use the build in explode effect
		if (useeffect == nil) then 
			useeffect = true 
		end
		
		
		--always make default explosion.
		local effectdata = EffectData()
		effectdata:SetOrigin( position )
		util.Effect( "Explosion", effectdata, true, true )
		
		--Check to see if the inputs are over the max amounts
		damage = math.Min(damage,CONFLICT_MaxDamage)
		area   = math.Min(area  ,CONFLICT_MaxRadius  )
		
		--Only use a blastwave if the server wants to, and the area is over 15 units
		if ((CONFLICT_UseBlastWave == 1) and (area > 15))then
			effectdata = EffectData()
				effectdata:SetStart	(position)
				effectdata:SetScale(area)
				effectdata:SetMagnitude(0.15)											
			util.Effect( "conflict_explode", effectdata )
		end
		
		--Only worth calling the damage functions if we're doing damage :-)
		if (damage > 0) then
			--Use the appropriate DamageSystem
			if not (CombatDamageSystem == nil) then
				cds_explosion(position, damage, area, piercing * 10, nil, killcredit)
			elseif not (COMBATDAMAGEENGINE == nil) then
				local explosion = cbt_hcgexplode(position, damage, area, piercing)
			else
		 		util.BlastDamage( killcredit, killcredit, position, damage, area)
	 		end
	 	end
end

--Conflict System Console Commands
function conflict.concommand( player, cmd, args )
	local iTableSize = table.getn( args )
	if ((player:IsAdmin()) or (player:IsSuperAdmin())) then
		if (cmd == "cvar_CONFLICT_MaxDamage") then
			if (iTableSize < 1) then 
				Msg("Sets the maximum Conflict Systems damage.\n     cvar_CONFLICT_MaxDamage = "..CONFLICT_MaxDamage.."\n") 
			else 
				rtsMaxDamage = 0.0 + args[1]
			end
		elseif (cmd == "cvar_CONFLICT_MaxRadius") then
			if (iTableSize < 1) then 
				Msg("Sets the maximum Conflict Systems damage.\n     cvar_CONFLICT_MaxRadius = "..CONFLICT_MaxRadius.."\n") 
			else 
				rtsMaxRadius = 0.0 + args[1]
			end
		elseif (cmd == "cvar_CONFLICT_UseBlastWave") then
			if (iTableSize < 1) then 
				Msg("Enable or Disable the particle blastwave.\n     cvar_CONFLICT_UseBlastWave = "..CONFLICT_UseBlastWave.."\n") 
			else 
				if (args[1] == 1) then
					CONFLICT_UseBlastWave = 1
				else
					CONFLICT_UseBlastWave = 0
				end
			end
		end
	end
end

function getAutoCompleteOptions(commandName,args)
	if (cmd == "cvar_rts_polltime") then
		return {15,60,120,240}
	elseif (cmd == "cvar_CONFLICT_MaxDamage") then
		return {0,1000,10000,999999}
	elseif (cmd == "cvar_CONFLICT_MaxRadius") then
		return {0,1000,10000,999999}
	elseif (cmd == "cvar_CONFLICT_UseBlastWave") then
		return {0,1}
	end
end 





-- Easy-on-the-eyes style resource loading.
function conflict.resource( sName, bIsTexture)
	if bIsTexture then
		resource.AddFile("materials/"..sName..".vtf")
		resource.AddFile("materials/"..sName..".vmt")
	else
		resource.AddFile("models/"..sName..".mdl")
		resource.AddFile("models/"..sName..".xbox.vtx")  
		resource.AddFile("models/"..sName..".dx80.vtx")
		resource.AddFile("models/"..sName..".dx90.vtx")
		resource.AddFile("models/"..sName..".phy")
		resource.AddFile("models/"..sName..".sw.vtx")
		resource.AddFile("models/"..sName..".vvd")
		util.PrecacheModel("models/"..sName..".mdl" )
	end
	MsgN("Conflict Systems Resource Loaded: "..sName.."\n")
end

-- Returns the props owner if it is already assigned
-- else, assigns its owner and returns said owner
function conflict.EntOwnedBy(entItem)
	-- if there's no valid entity, why bother trying to find its owner?
	
	if not ValidEntity(entItem) then
		return nil
	end

	-- if it already has a defined owner id
	if not (entItem.OwnedByENT == nil) then								
		-- return the player's ent
		return entItem.OwnedByENT 
	end
	
	local tempList
	for k, v in pairs(player.GetAll()) do     
		tempList = v:GetOwnedProps()
		for _, Ent in pairs(tempList) do
			if (entItem == Ent) then	
				Ent.OwnedByENT = v
				return(v)
			elseif (Ent.OwnedByENT == nil) then	
				Ent.OwnedByENT = v
			end
		end
	end  	
	
	-- return nil if no matching players found
	return nil
end

-- Calculates the falloff of a turret
-- Returns a value 0..1, depending on amount of accuracy lost
-- mainly used to find the optimum target to attack
function conflict.falloff( fDistance, fOptimumRange, fFalloffRange)
	local lDistanceFromOptimum = math.abs( fOptimumRange - fDistance )
	return ((math.Min(lDistanceFromOptimum,fFalloffRange*2) / (fFalloffRange*2)))
end


--Add the Console Commands
concommand.Add( "cvar_CONFLICT_MaxDamage", conflict.concommand )  
concommand.Add( "cvar_CONFLICT_MaxRadius",conflict.concommand )  
concommand.Add( "cvar_CONFLICT_UseBlastWave", conflict.concommand )  


