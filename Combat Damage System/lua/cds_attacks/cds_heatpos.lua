/ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
		This function disintigrates acertain entity or all entities in a certain radius .pos = Position(incase of radius ) , Entity in case of only 1
radius = a radius incase of multiple entities , nil incase of only 1 entity
heat = amount of heat to be done
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * /

		function cds_heatpos(pos, heat, radius, attacking_ent)
		if not server_settings.Bool("CDS_Damage_Enabled") then return false end
		if not radius then
			if pos:IsValid() and  not  CDS_IsWorldEnt(pos) then
			local stuff = ents.FindInSphere(pos:GetPos(), pos:BoundingRadius() + 50)
			for _, ent in pairs(stuff) do
				if ent:IsValid() then
					local ht = math.ceil(math.abs(heat * (1.1 - (radius / (pos:GetPos():Distance(ent:GetPos()) + 0.01)))))
					if ht > heat then ht = heat end
					cds_heatent(ent, ht)
				end
			end
			end
		else
			local stuff = ents.FindInSphere(pos, radius)
			for _, ent in pairs(stuff) do
				if ent:IsValid() and  not  CDS_IsWorldEnt(ent) then
				local ht = math.ceil(math.abs(heat * (1.1 - (radius / (pos:Distance(ent:GetPos()) + 0.01)))))
				if ht > heat then ht = heat end
				cds_heatent(ent, ht)
				end
			end
		end
		end
