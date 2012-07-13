local RD = {}

local status = false

--The Class
--[[
	The Constructor for this Custom Addon Class
]]
function RD.__Construct()
	return false , "No Implementation yet"
end

--[[
	The Destructor for this Custom Addon Class
]]
function RD.__Destruct()
	return false , "No Implementation yet"
end

--[[
	Get the required Addons for this Addon Class
]]
function RD.GetRequiredAddons()
	return {}
end

--[[
	Get the Boolean Status from this Addon Class
]]
function RD.GetStatus()
	return status
end

--[[
	Get the Version of this Custom Addon Class
]]
function RD.GetVersion()
	return 3.01, "Alpha"
end

--[[
	Get any custom options this Custom Addon Class might have
]]
function RD.GetExtraOptions()
	return {}
end

--[[
	Gets a menu from this Custom Addon Class
]]
function RD.GetMenu(menutype, menuname) --Name is nil for main menu, String for others
	local data = {}
	return data
end

--[[
	Get the Custom String Status from this Addon Class
]]
function RD.GetCustomStatus()
	return "Not Implemented Yet"
end

--[[
	Returns a table containing the Description of this addon
]]
function RD.GetDescription()
	return {
				"Mining Addon",
				"",
				""
			}
end

CAF.RegisterAddon("Mining Addon", RD, "2")


