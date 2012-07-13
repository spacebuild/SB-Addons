AddCSLuaFile("autorun/sh_cds_resnames.lua")

--Give the resources proper names

timer.Simple(.1, function()
	RD2_SetResourcePrintName("ammo_basic", "Basic: ")
	RD2_SetResourcePrintName("ammo_explosion", "Explosion: ")
	RD2_SetResourcePrintName("ammo_fuel", "Fuel: ")
	RD2_SetResourcePrintName("ammo_pierce", "Pierce: ")
end)
