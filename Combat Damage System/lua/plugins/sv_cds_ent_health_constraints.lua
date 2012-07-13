/*******************************************************************************************************
	This code will make the entity hava a small random chance of having it's constraints breaking
	when it's health is getting to low. 
	You can disactivate this from loading by putting Active to false.
*******************************************************************************************************/

local active = true

/*******************************************************************************************************
	DON'T EDIT FROM HERE
*******************************************************************************************************/

if not active then return end

function cds_ent_hp_constraints(ent)
	if not ent then
		Msg("No ent given: ent_health_constraints\n")
		return
	end
	CDS_HealthCheck(ent)
end
CDS_Add_Hook(cds_ent_hp_constraints)