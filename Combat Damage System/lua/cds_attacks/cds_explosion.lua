/ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
		This function performs explosiondamage on a certain entity or all entities in a certain radius .pos = Position
damage = damage done
pierce = pierce damage
defeffect = use the default effect(true / false)
radius = a radius incase of multiple entities , nil incase of only 1 entity
inflictor = who is damaging (optional)
		* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * /

		function cds_explosion(pos, radius, damage, pierce, defeffect, inflictor) -- explosion damage(large area)
		if not server_settings.Bool("CDS_Damage_Enabled") then return false end
		local stuff = ents.FindInSphere(pos, radius)
		for _, ent in pairs(stuff) do
			if ent:IsValid() and  not  CDS_IsWorldEnt(ent) then
			local dam = math.ceil(math.abs(damage * (1.1 - (radius / (pos:Distance(ent:GetPos()) + 0.01)))))
			local pier = math.ceil(math.abs(pierce * (1.1 - (radius / (pos:Distance(ent:GetPos()) + 0.01)))))
			if dam > damage then dam = damage end
			if pier > pierce then pier = pierce end
			cds_damageent(ent, dam, pier, inflictor)
			end
		end
		if not defeffect then
			local Effect = EffectData()
			Effect:SetOrigin(pos)
			Effect:SetScale(radius / 2)
			Effect:SetMagnitude(math.random(1, 2))
			util.Effect("cds_explode", Effect, true, true)
		end
		end
