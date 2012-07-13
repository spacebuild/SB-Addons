/ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
		This function will damagethe armor of a certain prop(due to piercing damage for exemple )
ent = the entity to damage
armordamage = the amount of damage that needs to be done to the armor
tracehitnormal = used for the Piercing effect on the place where the entity got hit(not required)
inflictor = the one who is causing the damage(most of the time players)
justarmor = boolean(true / false) value.Used to determan if you just want to damage a
the armor of the prop(true) or also want to deal damage to the healt of the prop
based on how much the piercing and the armor is .heat = This is something used for the CDS Heat system incase the damage system is disabled(true / false) without this heat damage wouldn 't be done anymore even when active.

Possible function calls:1)cds_damageentarmor(ent, armordamage)
Will damage only the armor for the specific ammount of damage when
armor is greater or the same as the piercing.Otherwise it will damage
the health of the entity to.cds_damageentarmor(ent, armordamage, tracehitnormal)
same as before, but with the pierce effect
cds_damageentarmor (ent, armordamage, tracehitnormal, inflictor )
same as before , only with the inflictor added(incase the entity (player / npc)
dies because of the damage done.cds_damageentarmor(ent, armordamage, nil, inflictor)
same as before, but without the effect

2 ) cds_damageentarmor(...., justarmor(true) )
same as the previous ones, but this won't damage the health of the entity
Inflictor can be give, but won't mather much in this case.
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * /


		function cds_damageentarmor(ent, armordamage, tracehitnormal, inflictor, justarmor, heat, gcombat)
		if not server_settings.Bool("CDS_Enabled") or (not server_settings.Bool("CDS_Damage_Enabled") and not heat) or CDS_InValid(ent) then return end
		armordamage = math.Round(armordamage)
		if ent.Shield then
			ent.Shield:ShieldDamage(armordamage)
			CDS_ShieldImpact(ent:GetPos())
			return
		end
		if justarmor then
			ent.armor = ent.armor - armordamage
		else
			if ent.armor >= armordamage then
				ent.armor = ent.armor - armordamage
			else
				if gcombat then
					cds_damageent(ent, (armordamage - ent.armor) * 5, nil, inflictor, nil, true) --nevermind
				else
					cds_damageent(ent, (armordamage - ent.armor) * 5, nil, inflictor)
				end
				ent.armor = 0
			end
			if tracehitnormal then
				local Effect = EffectData()
				Effect:SetScale(10)
				Effect:SetOrigin(ent:GetPos())
				Effect:SetNormal(tracehitnormal)
				util.Effect("cds_pierce", Effect, true, true)
			end
		end
		if ent.armor < 0 then
			ent.armor = 0
		end
		end
