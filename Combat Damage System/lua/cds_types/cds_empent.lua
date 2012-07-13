/ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
		This function will performan emp type attack on an entity .This will disable Vehicles, wheels, thrusters, hoverballs, RD compatible devices and will make
storage devices loose energy .ent = the entity to perform the action on
time = the amount of time before the entitie restores itself automaticaly
		* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * /

local function resetempforce(ent, power)
	if  not  ent:IsValid() then return end
	ent:SetForce(power)
end

local function resetempspeed(ent, speed)
	if  not  ent:IsValid() then return end
	ent:SetSpeed(speed)
end

local function resetemptorq(ent, torq, torq2)
	if ! ent:IsValid() then return end
	ent:SetBaseTorque(torq)
	ent:SetTorque(torq2)
end

local function resetRDDevice(ent)
	if not ent:IsValid() then return end
	if ent.Active == 0 then
		if ent.TurnOn then
			ent:TurnOn()
		else
			ent.Active = 1
		end
	end
end

function cds_empent(ent, time)
	if not server_settings.Bool("CDS_Enabled") then return end
	if ent:IsPlayer() or ent:IsNPC() then return end
	local EMPed = false
	if ent:GetClass() == "prop_vehicle_jeep" or ent:GetClass() == "prop_vehicle_airboat" then
		ent:Fire("TurnOff", "", 0)
		ent:Fire("TurnOn", "", time)
		ent:Fire("HandBrakeOn", "", 0)
		ent:Fire("HandBrakeOff", "", time)
		EMPed = true
	elseif ent:GetClass() == "prop_vehicle_prisoner_pod" then
		ent:Fire("Lock", "", 0)
		ent:Fire("Unlock", "", time)
		EMPed = true
	elseif ent:GetClass() == "gmod_wheel" then
		local torq = ent.BaseTorque
		local torq2 = ent.BaseTorque * ent.TorqueScale
		if torq2 ~= 0 then
		timer.Simple(time, resetemptorq, ent, torq, torq2)
		ent:SetBaseTorque(1)
		ent:SetTorque(0)
		end
		EMPed = true
	elseif ent:GetClass() == "gmod_thruster" then
		local power = ent.force
		if power ~= 0 then
		timer.Simple(time, resetempforce, ent, power)
		ent:SetForce(0)
		end
		EMPed = true
	elseif ent:GetClass() == "gmod_hoverball" then
		local speed = ent:GetSpeed()
		if speed ~= 0 then
		ent:SetSpeed(0)
		timer.Simple(time, resetempspeed, ent, speed)
		end
		EMPed = true
	elseif ent.environment and ent.environment.type and ent.environment.type == "Storage" then
		local energy = RD_GetResourceAmount(ent, "energy")
		if energy > 0 then
			RD_ConsumeResource(ent, "energy", energy / math.random(1, 4))
			EMPed = true
		end
	elseif ent.Active and ent.Active == 1 and not ent.CDSEmp_Ignore then
		if ent.TurnOff then
			ent:TurnOff()
		else
			ent.Active = 0
		end
		timer.Simple(time, resetRDDevice, ent)
		EMPed = true
	end
	if (EMPed) then
		local Effect = EffectData()
		Effect:SetOrigin(ent:GetPos())
		Effect:SetMagnitude(0.6)
		util.Effect("cds_emp_wave", Effect, true, true)
	end
end

