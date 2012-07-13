local RD = {}

local status = false

local function cds_HUDPaint()
	if GetConVarString('cl_hudversion') == "" then
		local ply = LocalPlayer()
		if not ply or not ply:Alive() or (ply:GetActiveWeapon() and ply:GetActiveWeapon() == "Camera") then return end
		--draw.RoundedBox( Number Bordersize, Number X, Number Y, Number Width, Number Height, Table Colour )
		--draw.SimpleText( String Text, String Font, Number X, Number Y, Table Colour, Number Xalign, Number Yalign )
		
		--First draw health, armor and energy
		local maxhealth = ply:GetNetworkedInt("maxhealth")
		local health = ply:Health()
		local maxarmor = ply:GetNetworkedInt("maxarmor")
		local armor = ply:GetNetworkedInt("armor")
		local energy = ply:GetNetworkedInt("energy")
		local maxenergy = ply:GetNetworkedInt("maxenergy")
		
		--Armor, Health and Energy
		local armorpercentage = 0
		if maxarmor > 0 then
			armorpercentage = (armor/maxarmor) * 100
		else
			maxarmor = 100
		end
		local healthpercentage = 0
		if (maxhealth > 0) then
			healthpercentage = (health/maxhealth) * 100
		else
			healthpercentage = health
			maxhealth = 100
		end
		local energypercentage = 0
		if (maxenergy > 0) then
			energypercentage = (energy/maxenergy) * 100
		else
			energypercentage = energy
			maxenergy = 100
		end
		
		local healthcolor = Color(0, 210, 0, 255)
		if health <= maxhealth/5 then
			healthcolor = Color(255,0,0,255)
		elseif health <= maxhealth /2.5 then
			healthcolor = Color(255,165,0,255)
		end
		
		local height = ScrH();
		local width = ScrW();
		
		local tenth =math.Round(width * 0.1);
		local tenth20half = (tenth + 20)/2
		
		draw.RoundedBox( 8, 20, ScrH() - 25, tenth, 20, Color(200, 0, 0, 100) )
		if energy > 0 then
			draw.RoundedBox( 8, 20, ScrH() - 23, math.Round((energy/maxenergy) * tenth), 18, Color(255, 0, 0, 255) )
		end
		draw.SimpleText("Energy: "..tostring(energypercentage), "ScoreboardText", tenth20half, height - 15, Color(255, 255, 255,255), 1, 1)
		
		draw.RoundedBox( 8, 20, ScrH() - 45, tenth, 20, Color(0, 0, 200, 100) )
		if armor > 0 then
			draw.RoundedBox( 8, 20, ScrH() - 43, math.Round((armor/maxarmor) * tenth), 18, Color(0, 0, 210, 255) )
		end
		draw.SimpleText("Armor: "..tostring(armorpercentage).."%", "ScoreboardText", tenth20half, height - 35, Color(255, 255, 255,255), 1, 1)
		
		draw.RoundedBox( 8, 20, ScrH() - 65, tenth, 20, Color(0, 200, 0, 100) )
		if health > 0 then
			draw.RoundedBox( 8, 20, ScrH() - 63, math.Round((health/maxhealth) * tenth), 18, healthcolor )
		end
		draw.SimpleText("Health: "..tostring(healthpercentage).."%", "ScoreboardText", tenth20half, height - 55, Color(255, 255, 255,255), 1, 1)
		
		-- Now draw primary and secondary ammo
		if ply:GetActiveWeapon() and ply:GetActiveWeapon() ~= NULL then
			local maxpammo = ply:GetActiveWeapon():Clip1()
			local pammo = ply:GetAmmoCount(ply:GetActiveWeapon():GetPrimaryAmmoType()) 
			local maxsammo = ply:GetActiveWeapon():Clip2() 
			local sammo = ply:GetAmmoCount(ply:GetActiveWeapon():GetSecondaryAmmoType())
			if maxpammo > -1 then
				draw.RoundedBox( 8, ScrW() - 100, ScrH() - (35 + (maxpammo * 2)), 50 , maxpammo * 2, Color(255, 220, 0, 200) )
				draw.SimpleText("P", "ScoreboardText", ScrW() - 95, ScrH() - (45 + (maxpammo * 2)), Color(255, 255, 255,255), 1, 1)
				draw.SimpleText(tostring(maxpammo).."/"..tostring(pammo), "ScoreboardText", ScrW() - 70, ScrH() - 20, Color(255, 255, 255,255), 1, 1)
			elseif pammo > 0 then
				draw.RoundedBox( 8, ScrW() - 100, ScrH() - (35 + (pammo * 2)), 50 , pammo * 2, Color(255, 220, 0, 200) )
				draw.SimpleText("P", "ScoreboardText", ScrW() - 95, ScrH() - (45 + (pammo * 2)), Color(255, 255, 255,255), 1, 1)
				draw.SimpleText(tostring(pammo), "ScoreboardText", ScrW() - 70, ScrH() - 20, Color(255, 255, 255,255), 1, 1)
			end
			if sammo > 0 then
				draw.RoundedBox( 8, ScrW() - 50, ScrH() - (35 + (sammo * 2)), 50, sammo * 2, Color(255, 220, 0, 200) )
				draw.SimpleText("S", "ScoreboardText", ScrW() - 45, ScrH() - (45 + (sammo * 2)), Color(255, 255, 255,255), 1, 1)
				draw.SimpleText(tostring(sammo), "ScoreboardText", ScrW() - 30, ScrH() - 20, Color(255, 255, 255,255), 1, 1)
			end
			--draw.SimpleText( math.floor(1/RealFrameTime()) .. " fps" , "ScoreboardText", ScrW()/2+350, 12, drool_textcolor, 2, 1 )
			--draw.SimpleText(client:Ping() .. " ms", "ScoreboardText", ScrW()/2+300, 12, drool_textcolor, 2, 1)
		end
	end
end

--[[
local mag_left = client:GetActiveWeapon():Clip1() -- How much ammunition you have inside the current magazine
local mag_extra = client:GetAmmoCount(client:GetActiveWeapon():GetPrimaryAmmoType()) -- How much ammunition you have outside the current magazine
 local secondary_ammo = client:GetAmmoCount(client:GetActiveWeapon():GetSecondaryAmmoType())-- How much ammunition you have for your secondary fire, such as the MP7's grenade launcher
[edit] Ending the function 



]]

local function hidehud(name)
	local hide = {"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo"}
	if table.HasValue(hide, name) then return false end
	return true
end  

--The Class
--[[
	The Constructor for this Custom Addon Class
]]
function RD.__Construct()
	hook.Add("HUDPaint", "CDS_Core_HUDPaint", cds_HUDPaint)
	hook.Add("HUDShouldDraw", "cds_hidehud", hidehud) 
	status = true
	return true
end

--[[
	The Destructor for this Custom Addon Class
]]
function RD.__Destruct()
	hook.Remove("HUDPaint", "CDS_Core_HUDPaint")
	hook.Remove("HUDShouldDraw", "cds_hidehud")
	status = false
	return true
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
	return 0.1, "Alpha"
end

--[[
	Get any custom options this Custom Addon Class might have
]]
function RD.GetExtraOptions()
	return {}
end

--[[
	Returns a table containing the Description of this addon
]]
function RD.GetDescription()
	return {
				"Custom Damage System",
				"",
				""
			}
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

CAF.RegisterAddon("Custom Damage System", RD, "3")


