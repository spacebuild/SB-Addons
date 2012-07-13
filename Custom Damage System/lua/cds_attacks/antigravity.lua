
local function gravback(ent)
	if not ent:IsValid() then return end
	if ent.environment then
		ent.environment:UpdateGravity(ent)
	else
		local phys = ent:GetPhysicsObject()
		if not phys:IsValid() then return end
		phys:Wake()
		phys:EnableGravity( true )
		ent:SetGravity(1)	
	end
end

function CDSAttacks.AntiGravity(ent, params)
	if not ent or not params or not params["time"] or not params["grav"] then return false, "Missing Arguments" end
	if params["grav"] < 0 then params["grav"] = 0 end
	if ent.environment and ent.environment:IsSpace() then
		if params["grav"] ~= 0 then
			local phys = ent:GetPhysicsObject()
			if not phys:IsValid() then return end
			phys:Wake()
			phys:EnableGravity( true )
			ent:SetGravity(params["grav"])
			ent:SetVelocity(Vector(0.01, 0.01, 0.01))
		end
	else
		local phys = ent:GetPhysicsObject()
		if not phys:IsValid() then return end
		phys:Wake()
		phys:EnableGravity( false )
		ent:SetGravity(params["grav"])
	end
	timer.Simple(params["time"], gravback, ent)
end
