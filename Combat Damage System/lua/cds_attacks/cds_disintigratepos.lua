/ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
		This function disintigrates acertain entity or all entities in a certain radius .pos = Position(incase of radius ) , Entity in case of only 1
radius = a radius incase of multiple entities , nil incase of only 1 entity
inflictor = who is damaging (optional)
		* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * /

		function cds_disintigratepos(pos, radius, inflictor)
		if not server_settings.Bool("CDS_Damage_Enabled") then return false end
		if not radius then
			if pos:IsValid() and  not  CDS_IsWorldEnt(pos) then
			cds_disintigrateent(pos, inflictor)
			end
		else
			local stuff = ents.FindInSphere(pos, radius)
			for _, ent in pairs(stuff) do
				if ent:IsValid() and  not  CDS_IsWorldEnt(ent) and not CDS_Ignore(ent) then
				cds_disintigrateent(ent, inflictor)
				end
			end
		end
		end
