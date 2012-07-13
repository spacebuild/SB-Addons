/ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
		This function performs damageon a certain entity or all entities in a certain radius .pos = Position(incase of radius ) , Entity in case of only 1
damage = damage done
pierce = piercing damage
radius = a radius incase of multiple entities , nil incase of only 1 entity
inflictor = who is damaging (optional)
Exemple function calls
1 ) All ents in a certain radius
cds_damagepos(self:GetPos(), damage, pierce, radius, inflictor(not needed, can be nil ) )
= > A radius is given so pos needs to be a position
2 ) only the ent that has been hit
cds_damagepos(trace.Entity, damage, pierce, nil, inflictor(not needed can be nil to) )
= > no radius is given, so pos needs to be an entity
		* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * /


		function cds_damagepos(pos, damage, pierce, radius, inflictor)
		if not server_settings.Bool("CDS_Damage_Enabled") then return false end
		if not radius then
			if pos:IsValid() and  not  CDS_IsWorldEnt(pos) then
			cds_damageent(pos, damage, pierce, inflictor)
			end
		else
			local stuff = ents.FindInSphere(pos, radius)
			for _, ent in pairs(stuff) do
				if ent:IsValid() and  not  CDS_IsWorldEnt(ent) then
				cds_damageent(ent, damage, pierce, inflictor)
				end
			end
		end
		end
