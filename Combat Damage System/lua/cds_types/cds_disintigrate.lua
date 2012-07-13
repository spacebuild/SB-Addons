/ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
		This function will makean entity disintigrate.cds_disintigrateent(ent, inflictor)
ent = entity
inflictor = the one doing the damage(optional)
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * /

local function Disintigrate2(ent, inflictor)
	if (  not  ent:IsValid() ) then return end
	if not inflictor then inflictor = 0 end
	if ent:IsPlayer() or ent:IsNPC() then
		ent:TakeDamage(200, inflictor)
		if ent:Health() <= 0 then
			ent.armor = 0
			ent.heat = 0
		end
	else
		cds_remove(ent)
	end
end

local function Disintigrate(ent)
	if (  not  ent:IsValid() ) then return end
	local Effect = EffectData()
	Effect:SetEntity(ent)
	Effect:SetScale(math.random(0.8, 1.2))
	Effect:SetMagnitude(ent:BoundingRadius())
	util.Effect("cds_disintergrate", Effect, true, true)
end

function cds_disintigrateent(ent, inflictor)
	if not server_settings.Bool("CDS_Enabled") or not server_settings.Bool("CDS_Damage_Enabled") or not ent:IsValid() or ent:IsWorld() then return end
	if not inflictor then inflictor = 0 end
	if ent.Shield then
		ent.Shield:ShieldDamage(math.random(100, 1000))
		CDS_ShieldImpact(ent:GetPos())
		return
	end
	timer.Simple(1, Disintigrate, ent)
	timer.Simple(2, Disintigrate2, ent, inflictor)
end

