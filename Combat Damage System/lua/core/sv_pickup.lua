/*******************************************************************************************************
	This code is part of the CDS core and shouldn't be removed!
	This will prevent players from being able to PhysGun certain weapons (missiles, bombs, ...)
*******************************************************************************************************/


/*******************************************************************************************************
	DON'T EDIT FROM HERE
*******************************************************************************************************/
function CDS_PhysGravGunPickup(ply, ent)
	if(!ent:IsValid()) then return end
	if((string.find(string.lower(ent:GetClass()), "bomb_") == 1 or string.find(string.lower(ent:GetClass()), "missile_") == 1) and string.find(string.lower(ent:GetClass()), "bomb_bay_") == 0) then
		return false
	end
	return
end
hook.Add("GravGunPunt", "CDS_GravGunPunt", CDS_PhysGravGunPickup)
hook.Add("GravGunPickupAllowed", "CDS_GravGunPickupAllowed", CDS_PhysGravGunPickup)
hook.Add("PhysgunPickup", "CDS_PhysgunPickup", CDS_PhysGravGunPickup)
