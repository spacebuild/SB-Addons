function CDSDamageTypes.Explosion(ent, customAttack, range, forcemult)
	if not ent or not ValidEntity(ent) or not customAttack or not range then return false, "Missing Parameters" end
	if not forcemult or forcemult <= 0 then forcemult = 1 end
	if CAF.GetAddon("Custom Damage System").HasLOS(customAttack:GetWeaponEntity(), ent) then
		local distance = customAttack:GetWeaponEntity():GetPos():Distance(ent:GetPos())
		local radius = range
		local types = {"Shock", "Kinetic", "Energy"}
		local attack = CustomAttack.Create(nil, customAttack:GetWeaponEntity(), customAttack:GetAttacker())
		local maxdamage = 0;
		for k,v in pairs(types) do
			if distance > radius then
				attack:AddAttack(v, customAttack:GetAttack(v) * ((radius/10)/distance))
				attack:setPiercing(customAttack:GetPiercing() * ((radius/10)/distance))
				if(customAttack:GetAttack(v) * ((radius/10)/distance) > maxdamage) then
					maxdamage = customAttack:GetAttack(v) * ((radius/10)/distance);
				end
			elseif distance > radius/2 then
				attack:AddAttack(v, customAttack:GetAttack(v) * ((radius/5)/distance))
				attack:setPiercing(customAttack:GetPiercing() * ((radius/5)/distance))
				if(customAttack:GetAttack(v) * ((radius/5)/distance) > maxdamage) then
					maxdamage = customAttack:GetAttack(v) * ((radius/5)/distance);
				end
			elseif distance > radius/4 then
				attack:AddAttack(v, customAttack:GetAttack(v) * ((radius/2)/distance))
				attack:setPiercing(customAttack:GetPiercing() * ((radius/2)/distance))
				if(customAttack:GetAttack(v) * ((radius/2)/distance) > maxdamage) then
					maxdamage = customAttack:GetAttack(v) * ((radius/2)/distance);
				end
			else
				attack:AddAttack(v, customAttack:GetAttack(v))
				attack:setPiercing(customAttack:GetPiercing())
				if(customAttack:GetAttack(v) > maxdamage) then
					maxdamage = customAttack:GetAttack(v);
				end
			end
		end
		CAF.GetAddon("Custom Damage System").Attack(ent, attack)
		local entpos = ent:LocalToWorld(ent:OBBCenter())
		local angle = entpos - customAttack:GetWeaponEntity():GetPos()
		angle:Normalize()
		local physobj = ent:GetPhysicsObject()
		if physobj and physobj:IsValid() and not ent:IsPlayer() and not ent:IsNPC() then
			local tmp3 = 1
			if radius > 512 then
				tmp3 = (radius/5)/distance
			elseif radius > 256 then
				tmp3 = (radius/2)/distance
			end
			physobj:ApplyForceOffset(angle * tmp3 * 100 * (distance/range) * maxdamage * forcemult, ent:GetPos() + Vector(math.random(-20,20),math.random(-20,20),math.random(20,40)))
		else
			ent:SetVelocity(angle* ((radius/5)/distance) * 100 * (distance/range) * damage * forcemult )
		end
	end
end