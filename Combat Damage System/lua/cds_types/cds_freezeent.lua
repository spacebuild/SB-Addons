/ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
		This function will freezea certain entity for the specified time .cds_freezeent(entity, time)

ent = the entity to perform the action on
time = the amount of time before the entitie get's unfrozen automatically
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * /

local function cds_unfreezeent(ent)
	if ( ! ent:IsValid() ) then return end
	if (ent:IsPlayer()) then
		ent:Freeze(false)
	else
		local phys = ent:GetPhysicsObject()
		if (phys:IsValid()) then
			if ( ! phys:IsMoveable() ) then
			phys:Wake()
			phys:EnableMotion(true)
			end
		end
	end
end

function cds_freezeent(ent, time)
	if not server_settings.Bool("CDS_Enabled") or not server_settings.Bool("CDS_Damage_Enabled") or CDS_InValid(ent) then return end
	time = math.Clamp(time, 0, 60)
	if ent.Shield then
		ent.Shield:ShieldDamage(5 * (time + 1))
		CDS_ShieldImpact(ent:GetPos())
		return
	end
	if (ent:IsPlayer()) then
		ent:Freeze(true)
		timer.Simple(time, cds_unfreezeent, ent)
	else
		local phys = ent:GetPhysicsObject()
		if (phys:IsValid()) then
			if (phys:IsMoveable()) then
				phys:Wake()
				phys:EnableMotion(false)
				timer.Simple(time, cds_unfreezeent, ent)
			end
		end
		if ent.ColdEffect then return end
		local Effect = EffectData()
		Effect:SetEntity(ent)
		Effect:SetMagnitude(time)
		util.Effect("cds_freeze", Effect, true, true)
		ent.ColdEffect = true
		timer.Simple(time, CDS_ResetColdEff, ent)
	end
end
