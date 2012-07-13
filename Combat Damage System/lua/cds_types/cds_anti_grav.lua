/ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
		This function will makean entity loose gravity for a short amount of time.After that time the ents gravity will return to normal.You shouldn 't call this directly from a weapon, but use the appropriate attack.
Attacks hower are allowed to use this however they won't.

Function to call :cds_antigrav(entity, time, grav)
time = the amount of time the entity should be in anti - gravity mode
gravity = the amount of gravity the entity should have(mostly used in case of player entities
		* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * /
local function cds_gravback(ent)
	if not ent:IsValid() then return end
	if InSpace == 1 then
		ent.planet = nil
		ent.reset = true
	else
		local phys = ent:GetPhysicsObject()
		if not phys:IsValid() then return end
		phys:Wake()
		phys:EnableGravity(true)
		ent:SetGravity(1)
	end
end

function cds_antigrav(ent, time, grav)
	if not server_settings.Bool("CDS_Enabled") or CDS_InValid(ent) then return end
	if InSpace == 1 and not ent.planet then
		ent:SetGravity(grav)
		ent:SetVelocity(Vector(0.01, 0.01, 0.01))
	else
		local phys = ent:GetPhysicsObject()
		if not phys:IsValid() then return end
		phys:Wake()
		phys:EnableGravity(false)
		ent:SetGravity(grav)
		if InSpace == 1 then
			ent.gravity = grav
		end
	end
	timer.Simple(time, cds_gravback, ent)
end
