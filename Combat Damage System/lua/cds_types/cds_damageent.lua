/ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
		This function will damagea certain entity.This according to damage and / or piercing.This function can becalled in different ways , each with other results.ent = the entity to damage
damage = the damage done by the attack
pierce = the amount of pierce done by the attack
inflictor = the'player' who attacked .heat = This is something used for the CDS Heat system incase the damage system is disabled(true / false)
without this heat damage wouldn 't be done anymore even when active.

1 ) cds_damageent(ent, damage)
		or
		cds_damageent(ent, damage, nil, inflictor)
This will damage a certain entity for the amount specified no mather what armor it has .2 ) cds_damageent(ent, damage, pierce)
		or
		cds_damageent(ent, damage, pierce, inflictor)
This will make damage be based on piercing (armor) and damage done.With this it can be that certain entities take less(or no damage) and other take more damage(depending on their armor )
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * /
local function CDS_Damage_Player(ent, damage, inflictor)
	ent:TakeDamage(damage, inflictor)
	ent.health = ent:Health()
	if ent:Health() <= 0 then
		ent.armor = 0
		ent.heat = 0
	end
end


function cds_damageent(ent, damage, pierce, inflictor, heat, gcombat)
	if not server_settings.Bool("CDS_Enabled") or (not server_settings.Bool("CDS_Damage_Enabled") and not heat) or CDS_InValid(ent) then return end
	if ent:GetClass() == "prop_ragdoll" then return end
	damage = math.Round(damage)
	if pierce then
		pierce = math.Round(pierce)
	end
	-- Msg("Damaged: ", ent, "\n Health: " .. tostring(ent.health) .. "\nArmor: " .. tostring(ent.armor) .. "\nDamage: " .. tostring(damage) .. "\nPierce: " .. tostring(pierce) .. "\n")
	if ent.Shield then
		if pierce then
			ent.Shield:ShieldDamage((pierce / 10) * damage)
		else
			ent.Shield:ShieldDamage(damage)
		end
		CDS_ShieldImpact(ent:GetPos())
		return
	end
	if pierce then
		if pierce > ent.armor then
			damage = math.ceil(math.abs(damage * ((pierce - ent.armor) / 4)))
			if ent:IsPlayer() or ent:IsNPC() then
				CDS_Damage_Player(ent, damage, inflictor)
			else
				ent.health = ent.health - damage
				Msg(ent.health, " ", ent.health - damage, "\n")
			end
			cds_damageentarmor(ent, (pierce - ent.armor) / 2, nil, inflictor, true)
		elseif pierce == ent.armor then
			if ent:IsPlayer() or ent:IsNPC() then
				CDS_Damage_Player(ent, damage, inflictor)
			else
				ent.health = ent.health - damage
			end
			cds_damageentarmor(ent, 1, nil, inflictor, true)
		elseif pierce * 1.5 > ent.armor then
			damage = math.ceil(math.abs(damage * ((ent.armor - pierce) / 25)))
			if ent:IsPlayer() or ent:IsNPC() then
				CDS_Damage_Player(ent, damage, inflictor)
			else
				ent.health = ent.health - damage
			end
			cds_damageentarmor(ent, ((pierce * 1.5) - ent.armor) / 5, nil, inflictor, true)
		else --at least 2 damage
			if ent:IsPlayer() or ent:IsNPC() then
				CDS_Damage_Player(ent, (damage * (pierce / ent.armor)), inflictor)
			else
				ent.health = ent.health - (damage * (pierce / ent.armor))
			end
		end
	else
		ent.health = ent.health - damage
		if ent:IsPlayer() or ent:IsNPC() then
			CDS_Damage_Player(ent, damage, inflictor)
		end
	end
	if ent.damaged and ent.damaged == 0 then
		ent.damaged = 1
	end
	if not ent:IsPlayer() and not ent:IsNPC() and ent.health <= 0 then
		if gcombat then
			cds_gcombat_removeent(ent)
		else
			cds_removeent(ent)
		end
	end
end
