/ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
		This function disintigrates acertain entity or all entities in a certain radius .pos = Position(incase of radius ) , Entity in case of only 1
speed = the velocity the piercing'bullet' enters, multiplies the pierce value 100 speed = full piercing damage
pierce = the amount of piercing damage
radius = a radius incase of multiple entities , nil incase of only 1 entity
tracenormal = (optional) if it's given the an effect will be shown there
	inflictor = who is damaging (optional)
			* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * /

			function cds_pierce(pos, speed, pierce, radius, tracenormal, inflictor, gcombat) -- pierce damage, reduces armor first(small area)
			if not server_settings.Bool("CDS_Damage_Enabled") then return false end
			if not radius then -- pos = ent
			if not tracenormal then tracenormal = false end
			if pos:IsValid() and  not  CDS_IsWorldEnt(pos) then
			if pos.armor then
				pierce = pierce * (speed / 100)
				if pos.armor < pierce then
					cds_damageentarmor(pos, (pierce - pos.armor) / 2, tracenormal, inflictor, nil, gcombat)
				elseif pos.armor < pierce * 1.5 then
					cds_damageentarmor(pos, (pos.armor - pierce) / 5, tracenormal, inflictor, nil, gcombat)
				elseif pos.armor == pierce then
					cds_damageentarmor(pos, 0.5, tracenormal, inflictor, nil, gcombat)
				end
			end
			end
			else
				if not tracenormal then tracenormal = false end
				local stuff = ents.FindInSphere(pos, radius)
				for _, ent in pairs(stuff) do
					if ent:IsValid() and  not  CDS_IsWorldEnt(ent) then
					if ent.armor then
						pierce = pierce * (speed / 100)
						if ent.armor < pierce then
							cds_damageentarmor(ent, (pierce - ent.armor) / 2, tracenormal, inflictor, nil, gcombat)
						elseif ent.armor < pierce * 1.5 then
							cds_damageentarmor(ent, (ent.armor - pierce) / 5, tracenormal, inflictor, nil, gcombat)
						elseif ent.armor == pierce then
							cds_damageentarmor(ent, 0.5, tracenormal, inflictor, nil, gcombat)
						end
					end
					end
				end
			end
			end
