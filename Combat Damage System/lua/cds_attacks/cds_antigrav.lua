/ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
		This function perform anti - gravity on a certain entity or all entities in a certain radius .pos = Position(incase of radius ) , Entity in case of only 1
resettime = the time before the anti - gravity needs to be reset
grav = the amount of gravity
radius = a radius incase of multiple entities , nil incase of only 1 entity

Exemple function calls
1 ) All ents in a certain radius
cds_antigravityblast(self:GetPos(), 2, 0, 100)
= > A radius is given so pos needs to be a position
2 ) only the ent that has been hit
cds_antigravityblast(trace.Entity, 2, 0)
= > no radius is given, so pos needs to be an entity
		* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * /

		function cds_antigravityblast(pos, resettime, grav, radius)
		if not server_settings.Bool("CDS_Damage_Enabled") then return false end
		if not radius then -- pos = ent
		if pos:IsValid() and  not  CDS_IsWorldEnt(pos) then
		cds_antigrav(pos, resettime, grav)
		end
		else
			local stuff = ents.FindInSphere(pos, radius)
			for _, ent in pairs(stuff) do
				if ent:IsValid() and  not  CDS_IsWorldEnt(ent) then
				cds_antigrav(ent, resettime, grav)
				end
			end
		end
		end
