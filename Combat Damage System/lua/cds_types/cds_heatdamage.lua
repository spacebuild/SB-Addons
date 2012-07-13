/*******************************************************************************************************
	This function will heat up a certain entity.
	
		ent = the entity to perform the action on
		heat = the amount of heat done to the target
*******************************************************************************************************/


function cds_heatent(ent, heat)
	if not server_settings.Bool( "CDS_Enabled" ) or CDS_InValid(ent) or not server_settings.Bool( "CDS_Damage_Enabled" ) then return end
	if ent.CDSIgnoreHeatDamage then return end
	heat = math.Round(heat)
	if ent.Shield and not ent.Shield.CDS_Allow_Heat then
		ent.Shield:ShieldDamage(math.abs(heat)/10)
		--FUCKEN ANNOYING!
		--CDS_ShieldImpact(ent:GetPos())
		return
	end
	ent.heat = ent.heat + heat
	if ent:IsPlayer() or ent.MeltEffect then return end
	local Effect = EffectData()
	local mag = math.random(4, 6)
	Effect:SetEntity(ent)
	Effect:SetMagnitude(mag)
	util.Effect("cds_melt", Effect, true, true)
	ent.MeltEffect = true
	timer.Simple(mag, CDS_ResetHeatEff, ent)
end
