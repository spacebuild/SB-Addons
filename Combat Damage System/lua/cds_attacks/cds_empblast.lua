/ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
		This function disintigrates acertain entity or all entities in a certain radius .pos = Position(incase of radius ) , Entity in case of only 1
radius = a radius incase of multiple entities , nil incase of only 1 entity
resettime = the time before the entities get reset to previous values
		* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * /

		function cds_empblast(pos, resettime, radius) -- EMP function , radiusis optional
			if not server_settings.Bool("CDS_Damage_Enabled") then return false end
			if not resettime then resettime = 1 end
			resettime = math.Clamp(resettime, 1, 300)
			if not radius then
				if pos:IsValid() and  not  CDS_IsWorldEnt(pos) then
				cds_empent(pos, resettime)
				end
			else
				local stuff = ents.FindInSphere(pos, radius)
				for _, ent in pairs(stuff) do
					if ent:IsValid() and  not  CDS_IsWorldEnt(ent) then
					cds_empent(ent, resettime)
					end
				end
			end
		end
