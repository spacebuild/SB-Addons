-- Workaround for Tad2020's lack of 
-- Global resource allocation.

RESOURCETRANSITSYSTEMS = 1	-- Who knows? Someone might want to know if this is running
local ResTypesByID = {}		-- Var to hold all the resource types for easy access.
local rtsPollTime = 15		-- How often it polls for new resources, keep high for lower network traffic
local rtsMaxDamage = 5000	-- Maximum amount of damage per explosion
local rtsMaxRadius = 50000  -- Maximum explosion radius
local rtsUseBlastWave = 1   -- Use the particle effect Blastwave? 0 - off, 1 - on
Msg("Resource Transit Systems Enabled.\n")


function _BoolToInt(bVal)	--Converts a boolean to an integer
	if bVal then 
		return 1
	else
		return 0
	end
end

function rts_UpdateResources()		--updates the local table with the resid and resname every rtsPollTime seconds
	local tTemp = BeamNetVars.GetResourceNames()
	local tSize = table.getn(tTemp)
	local y

	--Error("\nUpdating "..table.getn(ResTypesByID).."/"..table.getn(tTemp).." Resources\n")
	if (table.getn(ResTypesByID) < tSize) then
		for x = (table.getn(ResTypesByID)+1),tSize do
			y = tTemp[x]
			ResTypesByID[x] = y["name"]
			--Error("ResTypeByID["..x.."] = "..ResTypesByID[x].."\n")
		end
	end	
end
timer.Create("rtsUpdateResources",rtsPollTime,0,rts_UpdateResources)

-- number of resources. simple.
function rts_NumberOfResources() 
	return table.getn(ResTypesByID)
end

-- returns the name of the resource
function rts_ResourceName(varID)
	return ResTypesByID[varID]
end

-- an ent requested an update ahead of schedule
function rts_UpdateRequest()
	rts_UpdateResources()
end


-- All in one function to handle the big bangs. also lets the admins cap the damage / area / effects
function rts_Explosion(damage, piercing, area, position, killcredit)
		
		--always make default explosion.
		local effectdata = EffectData()
		effectdata:SetOrigin( position )
		util.Effect( "Explosion", effectdata, true, true )
		
		--Check to see if the inputs are over the max amounts
		damage = math.Min(damage,rtsMaxDamage)
		area   = math.Min(area  ,rtsMaxRadius  )
		
		--Only use a blastwave if the server wants to, and the area is over 15 units
		if ((rtsUseBlastWave == 1) and (area > 15))then
			effectdata = EffectData()
				effectdata:SetStart	(position)
				effectdata:SetScale(area)
				effectdata:SetMagnitude(0.15)											
			util.Effect( "rts_explode", effectdata )
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

--Resource Transit System Console Commands
function rts_ConCommand( player, cmd, args )
	local iTableSize = table.getn( args )
	if ((player:IsAdmin()) or (player:IsSuperAdmin())) then
		if (cmd == "cvar_rts_polltime") then
			if (iTableSize < 1) then 
				Msg("Sets the resource check polltime in seconds. (15 - 240)\n     cvar_rts_polltime = "..rtsPollTime.."\n") 
			else 
				if (args[1] < 15) then rtsPollTime = 15
				elseif (args[1] > 240) then rtsPollTime = 240
				else rtsPollTime = args[1]
				end
			end
		elseif (cmd == "cvar_rts_maxdamage") then
			if (iTableSize < 1) then 
				Msg("Sets the maximum Resource Transit Systems damage.\n     cvar_rts_maxdamage = "..rtsMaxDamage.."\n") 
			else 
				rtsMaxDamage = 0.0 + args[1]
			end
		elseif (cmd == "cvar_rts_maxradius") then
			if (iTableSize < 1) then 
				Msg("Sets the maximum Resource Transit Systems damage.\n     cvar_rts_maxradius = "..rtsMaxRadius.."\n") 
			else 
				rtsMaxRadius = 0.0 + args[1]
			end
		elseif (cmd == "cvar_rts_useblastwave") then
			if (iTableSize < 1) then 
				Msg("Enable or Disable the particle blastwave.\n     cvar_rts_useblastwave = "..rtsUseBlastWave.."\n") 
			else 
				if (args[1] == 1) then
					rtsUseBlastWave = 1
				else
					rtsUseBlastWave = 0
				end
			end
		end
	end
end

function getAutoCompleteOptions(commandName,args)
	if (cmd == "cvar_rts_polltime") then
		return {15,60,120,240}
	elseif (cmd == "cvar_rts_maxdamage") then
		return {0,1000,10000,999999}
	elseif (cmd == "cvar_rts_maxradius") then
		return {0,1000,10000,999999}
	elseif (cmd == "cvar_rts_useblastwave") then
		return {0,1}
	end
end 


function rts_ResourceSetup(tEntity, restype)
	if (restype == "air") then 								--air
		tEntity.Entity:SetColor(Color(0,165,255,255))
    	tEntity.damagemultiplier = 0.5
    	tEntity.volatility = 0
    elseif (restype == "coolant") then 						--coolant
		tEntity.Entity:SetColor(Color(1,255,107,255))
    	tEntity.damagemultiplier = 1
    	tEntity.volatility = 5
    elseif (restype == "water") then 						--water
		tEntity.Entity:SetColor(Color(0,0,255,255))
    	tEntity.damagemultiplier = 2
    	tEntity.volatility = 0
    elseif (restype == "heavy water") then 					--heavy water
		tEntity.Entity:SetColor(Color(101,34,44,255))
    	tEntity.damagemultiplier = 4
    	tEntity.volatility = 5
    elseif (restype == "redterracrystal") then 				--Red Terra Crystal
		tEntity.Entity:SetColor(Color(255,0,0,255))
    	tEntity.damagemultiplier = 5
    	tEntity.volatility = 10
    elseif (restype == "oil") then 							--Red Terra Crystal
		tEntity.Entity:SetColor(Color(255,0,0,255))
    	tEntity.damagemultiplier = 5
    	tEntity.volatility = 10
    elseif (restype == "greenterracrystal") then 			--Green Terra Crystal
		tEntity.Entity:SetColor(Color(0,255,0,255))
    	tEntity.damagemultiplier = 7
    	tEntity.volatility = 15
    elseif (restype == "terrajuice") then 					--Terrajuice
		tEntity.Entity:SetColor(Color(0,0,0,255))
    	tEntity.damagemultiplier = 12
    	tEntity.volatility = 25
    elseif (restype == "darkmatter") then 					--The unseen stuff of the universe
		tEntity.Entity:SetMaterial("models/dog/eyeglass")
    	tEntity.damagemultiplier = 25
    	tEntity.volatility = 75
    elseif (restype == "ammo_basic") then 					--CDS Ammo
		tEntity.Entity:SetColor(Color(125,255,55,255))
    	tEntity.damagemultiplier = 5
    	tEntity.volatility = 25
    elseif (restype == "ammo_explosion") then 				--CDS Ammo
		tEntity.Entity:SetColor(Color(125,255,55,255))
    	tEntity.damagemultiplier = 10
    	tEntity.volatility = 45
    elseif (restype == "ammo_fuel") then 					--CDS Ammo
		tEntity.Entity:SetColor(Color(125,255,55,255))
    	tEntity.damagemultiplier = 8
    	tEntity.volatility = 35
    elseif (restype == "ammo_pierce") then 					--CDS Ammo
		tEntity.Entity:SetColor(Color(125,255,55,255))
    	tEntity.damagemultiplier = 6
    	tEntity.volatility = 15
    else 													--energy and unknown types
		tEntity.Entity:SetColor(Color(255,255,255,255))
    	tEntity.damagemultiplier = 0.5
    	tEntity.volatility = 10
    end
end


-- Easy-on-the-eyes style resource loading.
-- check sv_resources.lua for the list of resources.
function rts_resource( sName, bIsTexture)
	if bIsTexture then
		resource.AddFile("materials/"..sName..".vtf")
		resource.AddFile("materials/"..sName..".vmt")
		Msg("RTS Texture Loaded: "..sName.."\n")
	else
		resource.AddFile("models/"..sName..".mdl")
		resource.AddFile("models/"..sName..".xbox.vtx")  
		resource.AddFile("models/"..sName..".dx80.vtx")
		resource.AddFile("models/"..sName..".dx90.vtx")
		resource.AddFile("models/"..sName..".phy")
		resource.AddFile("models/"..sName..".sw.vtx")
		resource.AddFile("models/"..sName..".vvd")
		util.PrecacheModel("models/"..sName..".mdl" )
		Msg("RTS Model Loaded: "..sName.."\n")
	end
end

--Add the Console Commands
concommand.Add( "cvar_rts_polltime", rts_ConCommand,rts_AutoComplete )  
concommand.Add( "cvar_rts_maxdamage", rts_ConCommand,rts_AutoComplete )  
concommand.Add( "cvar_rts_maxradius", rts_ConCommand,rts_AutoComplete )  
concommand.Add( "cvar_rts_useblastwave", rts_ConCommand,rts_AutoComplete )  


