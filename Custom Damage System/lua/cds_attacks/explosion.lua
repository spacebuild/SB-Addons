function CDSAttacks.Explosion(customAttack, range, forcemult, usedefaulteffect)
	if not customAttack or not range then return false, "Missing Parameters" end
	if not forcemult then forcemult = 1 end
	local entsdamaged = {}
	local pos = customAttack:GetWeaponEntity():GetPos()
	for k , ent in pairs(ents.FindInSphere(pos, range/2 )) do --First check the closest entities
		if ent ~= customAttack:GetWeaponEntity() then
			CDSDamageTypes.Explosion(ent, customAttack, range, forcemult)
		end
		table.insert(entsdamaged, ent) 
	end
	for k, ent in pairs(ents.FindInSphere(pos, range)) do --then check the rest
		if not table.HasValue(entsdamaged, ent) then
			CDSDamageTypes.Explosion(ent, customAttack, range, forcemult)
		end
	end
	if usedefaulteffect then
		local Effect = EffectData()
		Effect:SetOrigin(pos)
		Effect:SetStart( Vector(0,0,0) ) --Needed for cinematic explosion
		Effect:SetScale((range/2) * forcemult)
		Effect:SetMagnitude(math.random(1, 2))
		--util.Effect("cds_explode", Effect, true, true)
		--util.Effect("cds_cinematicexplosion", Effect, true, true)
		util.Effect("gmdm_gmdm_explosion", Effect, true, true)
	end
end

