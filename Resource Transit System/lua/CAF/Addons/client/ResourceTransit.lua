local RTS = {}

local status = true

--The Class
--[[
	The Constructor for this Custom Addon Class
]]
function RTS.__Construct()
	return true , "No Implementation yet"
end

function RD.CanChangeStatus()
	return false;
end

--[[
	The Destructor for this Custom Addon Class
]]
function RTS.__Destruct()
	return false , "Can't Disable"
end

--[[
	Get the required Addons for this Addon Class
]]
function RTS.GetRequiredAddons()
	return {"Resource Distribution", "Life Support"}
end

--[[
	Get the Boolean Status from this Addon Class
]]
function RTS.GetStatus()
	if CAF and CAF.GetAddon("Resource Distribution") then
		return CAF.GetAddon("Resource Distribution").GetStatus()
	end
	return false
end

--[[
	Get the Version of this Custom Addon Class
]]
function RTS.GetVersion()
	return 2.5, "Alpha"
end

--[[
	Get any custom options this Custom Addon Class might have
]]
function RTS.GetExtraOptions()
	return {}
end

--[[
	Gets a menu from this Custom Addon Class
]]
function RTS.GetMenu(menutype, menuname) --Name is nil for main menu, String for others
	local data = {}
	return data
end

--[[
	Get the Custom String Status from this Addon Class
]]
function RTS.GetCustomStatus()
	return "Not Implemented Yet"
end

--[[
	Returns a table containing the Description of this addon
]]
function RTS.GetDescription()
	return {
				"Resource Transit System",
				"",
				"Quick port from RD2 to RD3",
				"Nothing new got added"
			}
end

CAF.RegisterAddon("Resource Transit System",  RTS, "3") 


