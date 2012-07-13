/*******************************************************************************************************
	This is the Damage Hook handling code. 
	This makes it so that default damage get's converted to CDS damage.
	If you don't want to use this just change the server var "CDS_NormalDamage"
*******************************************************************************************************/

/*******************************************************************************************************
	DON'T EDIT FROM HERE
*******************************************************************************************************/

function CDS_NormalDamage(ent, inflictor, attacker, amount, dmginfo)
	local ENT_CLASS = ent:GetClass()
	local ENT_PLAYERNPC = tobool((ent:IsPlayer() or ent:IsNPC()))
	if (ENT_CLASS == "prop_ragdoll") or (server_settings.Bool("CDS_Disable_TurretLaser_Damage") and (ENT_CLASS == "gmod_turret" or ENT_CLASS == "env_laser" or ENT_CLASS == "gmod_wire_turret")) then return end
	
	if server_settings.Bool( "CDS_Enabled" ) and (server_settings.Bool( "CDS_NormalDamage") or inflictor.Is_A_CDS_Device) and ent:IsValid() then
		if not (attacker == GetWorldEntity()) then
			if ENT_PLAYERNPC then
				if (ent.cds_underattack) then
					ent.cds_underattack = false
					return 
				else
					ent.cds_underattack = true
				end	
			end

			if dmginfo:IsBulletDamage() then
				local force = math.Round(dmginfo:GetDamageForce():Length()/668)
				force = math.Clamp(force, 0, 15)
				if ENT_PLAYERNPC then
					amount = dmginfo:GetDamage()
				end
				cds_damageent(ent, amount, force, attacker)
			elseif dmginfo:IsExplosionDamage() then
				cds_damageent(ent, amount, 15, attacker) --default armor = 25
			elseif dmginfo:IsFallDamage() then
				if ent:IsPlayer() then
					local dam = amount
					cds_damageent(ent, dam, nil, attacker)
				else
					cds_damageent(ent, amount , 5, attacker)
				end
			else
				cds_damageent(ent, amount, nil , attacker)
			end
			
			if ENT_PLAYERNPC or (ent:Health() == 0 and ent:GetMaxHealth() == 1) then
				dmginfo:ScaleDamage( 0 ) --overrides the default damage system!
				return false
			end
		end
	end
end
hook.Add( "EntityTakeDamage", "CDS_normal_damage", CDS_NormalDamage )