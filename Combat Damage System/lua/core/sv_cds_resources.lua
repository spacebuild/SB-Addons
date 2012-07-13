/*******************************************************************************************************
	This code is part of the CDS core and shouldn't be removed!
	This will register all basic resources for use with the Resource Syncer.
*******************************************************************************************************/
	local cds_resources_to_add = {"coolant", "energy", "air", "water", "steam", "heavy water", "ammo_basic", "ammo_explosion", "ammo_fuel", "ammo_pierce"}

/*******************************************************************************************************
	DON'T EDIT FROM HERE
*******************************************************************************************************/

if CombatDamageSystem then
	for k, v in pairs(cds_resources_to_add) do
		CDS_AddResource( v )
	end
end
