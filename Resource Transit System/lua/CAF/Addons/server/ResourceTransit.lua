--[[ Serverside Custom Addon file Base ]]--
local RTS = {}

local status = false
local rtsPollTime = 15		-- How often it polls for new resources, keep high for lower network traffic
local rtsMaxDamage = 5000	-- Maximum amount of damage per explosion
local rtsMaxRadius = 50000  -- Maximum explosion radius
local rtsUseBlastWave = 1   -- Use the particle effect Blastwave? 0 - off, 1 - on

--[[
	The Constructor for this Custom Addon Class
	Required
	Return True if succesfully able to start up this addon
	Return false, the reason of why it wasn't able to start
]]
function RTS.__Construct()
	return false , "No Implementation yet"
end

--[[
	The Destructor for this Custom Addon Class
	Required
	Return true if disabled correctly
	Return false + the reason if disabling failed
]]
function RTS.__Destruct()
	return false , "No Implementation yet"
end

--[[
	Get the required Addons for this Addon Class
	Optional
	Put the string names of the Addons in here in table format
	The CAF startup system will use this to decide if the Addon can be Started up or not. If a required addon isn't installed then Construct will not be called
	Example: return {"Resource Distribution", "Life Support"}
	
	Works together with the startup Level number at the bottom of this file
]]
function RTS.GetRequiredAddons()
	return {"Resource Distribution", "Life Support"}
end

--[[
	Get the Boolean Status from this Addon Class
	Required, used to know if this addon is active or not
]]
function RTS.GetStatus()
	return status
end

--[[
	Get the Version of this Custom Addon Class
	Optional (but should be put it in most cases!)
]]
function RTS.GetVersion()
	return 2.5, "Alpha"
end

--[[
	Get any custom options this Custom Addon Class might have
	Not implemented yet
]]
function RTS.GetExtraOptions()
	return {}
end

--[[
	Get the Custom String Status from this Addon Class
	Optional, returns a custom String status, could be used if your addon has more then 1 status based on the options activated?
]]
function RTS.GetCustomStatus()
	return "Not Implemented Yet"
end

--[[
	You can send all the files from here that you want to add to send to the client
	Optional
]]
function RTS.AddResourcesToSend()
	
end
CAF.RegisterAddon("Resource Transit System",  RTS, "3") 

-- Extra functions

function RTS._BoolToInt(bVal)	--Converts a boolean to an integer
	if bVal then 
		return 1
	else
		return 0
	end
end

-- All in one function to handle the big bangs. also lets the admins cap the damage / area / effects
function RTS.Explosion(damage, piercing, area, position, killcredit)
		
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

function RTS.ResourceSetup(tEntity, restype)
	if (restype == "oxyen") then 								--air
		tEntity.Entity:SetColor(Color(0,165,255,255))
    	tEntity.damagemultiplier = 0.5
    	tEntity.volatility = 0
    elseif (restype == "nitrogen") then 						--coolant
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
    elseif (restype == "oil") then 							--Red Terra Crystal
		tEntity.Entity:SetColor(Color(255,0,0,255))
    	tEntity.damagemultiplier = 5
    	tEntity.volatility = 10
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



--Local functions

local function ConCommand( player, cmd, args )
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

local function getAutoCompleteOptions(commandName,args)
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

local function rts_resource( sName, bIsTexture)
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

rts_resource( "rts_massdriver", false)
rts_resource( "rts_massdriver", true)

--Add the Console Commands
concommand.Add( "cvar_rts_polltime", rts_ConCommand,rts_AutoComplete )  
concommand.Add( "cvar_rts_maxdamage", rts_ConCommand,rts_AutoComplete )  
concommand.Add( "cvar_rts_maxradius", rts_ConCommand,rts_AutoComplete )  
concommand.Add( "cvar_rts_useblastwave", rts_ConCommand,rts_AutoComplete )  
