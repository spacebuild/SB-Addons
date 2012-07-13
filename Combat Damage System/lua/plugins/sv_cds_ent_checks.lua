/*******************************************************************************************************
	This code will provide some basic Anti-Cheat protection.
	If you don't want to use this (to reduce a bit of CPU usage for exemple) you can disable
	this by setting active to false.
*******************************************************************************************************/

local active = true

/*******************************************************************************************************
	DON'T EDIT FROM HERE
*******************************************************************************************************/

if not active then return end

function cds_ent_check(ent)
	if not ent then
		Msg("No ent given: ent_check\n")
		return
	end
	if ent:IsPlayer() or ent:IsNPC() then
		ent.health = ent:Health()
	end
	if ent.health > ent.maxhealth and ent.maxhealth ~= 0 then
		ent.health = ent.maxhealth
		if ent:IsPlayer() or ent:IsNPC() then
			ent:SetHealth(ent.health)
		end
	end
	if ent.maxarmor > CDS_MaxArmor() then
		ent.maxarmor = CDS_MaxArmor()
	elseif ent.maxarmor < 0 then
		ent.maxarmor = 0
	end
	if ent.armor > ent.maxarmor then
		ent.armor = ent.maxarmor
	elseif ent.armor < 0 then
		ent.armor = 0
	end
	if ent.maxhealth > CDS_MaxHealth() then
		ent.maxhealth = CDS_MaxHealth()
	end
end
CDS_Add_Hook(cds_ent_check)