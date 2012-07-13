/*******************************************************************************************************
	This is the CDS Damage code. 
	In here you can easily disable the default damage system from loading. If you disable this
	weapons damage won't be done!.
*******************************************************************************************************/

local active = true

/*******************************************************************************************************
	DON'T EDIT FROM HERE
*******************************************************************************************************/

if not active then return end

local function registerPF()
	if SVX_PF then
		PF_RegisterConVar("Combat Damage System", "CDS_Damage_Enabled", "1", "Weapons Damage")
	else
		CreateConVar("CDS_Damage_Enabled", "1")
	end
end
timer.Simple(6, registerPF)--Needed to make sure the Plugin Framework gets loaded first + the main CDS core get's registered


