/ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
		This function disintigrates acertain entity or all entities in a certain radius .pos = Position(incase of radius ) , Entity in case of only 1
radius = a radius incase of multiple entities , nil incase of only 1 entity
time = amount of time the entity remains frozen
		* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * /

		function cds_freezepos(pos, time, radius)
		if not server_settings.Bool("CDS_Damage_Enabled") then return false end
		if not time then time = 1 end
		if not radius then
			if pos:IsValid() and  not  CDS_IsWorldEnt(pos) then
			cds_freezeent(pos, time)
			end
		else
			local stuff = ents.FindInSphere(pos, radius)
			for _, ent in pairs(stuff) do
				if ent:IsValid() and  not  CDS_IsWorldEnt(ent) then
				cds_freezeent(ent, time)
				end
			end
		end
		end
