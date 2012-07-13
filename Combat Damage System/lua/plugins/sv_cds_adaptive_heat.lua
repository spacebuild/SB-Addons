/*******************************************************************************************************
	This code will provide the Adaptive Heat for use with Spacebuild2.
	If you don't want to use this you can disable this by setting active to false.
*******************************************************************************************************/

local active = true

/*******************************************************************************************************
	DON'T EDIT FROM HERE
*******************************************************************************************************/

if not active then return end

LS_Override_Heat = 1
SB2_Override_HeatDestroy = 1

function cds_adaptive_heat_calc(ent)
	if not ent then
		Msg("No ent given: ent_check\n")
		return
	end
	if not ent.heat then return end
	if GAMEMODE.IsSpaceBuildDerived and InSpace == 1 then
		CDS_Adaptive_Heat(ent)		
	end
end
CDS_Add_Hook(cds_adaptive_heat_calc)