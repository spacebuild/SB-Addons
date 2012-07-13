/*******************************************************************************************************
	This code will provide all heat calculations
	If you don't want to use this you can disable this by setting active to false.
	Note: Disabling this will make Adaptive Heating not work either (or any of the heat weapons)!
*******************************************************************************************************/

local active = true

/*******************************************************************************************************
	DON'T EDIT FROM HERE
*******************************************************************************************************/

if not active then return end

function cds_heat_calc(ent)
	if not ent then
		Msg("No ent given: ent_check\n")
		return
	end
	if not ent.heat then return end
	CDS_Cooldown(ent)
	CDS_HeatColor(ent)
	CDS_HeatDamage(ent)
end
CDS_Add_Hook(cds_heat_calc)