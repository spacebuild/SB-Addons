/*******************************************************************************************************
	This code is part of the CDS core and shouldn't be removed!
	In here everything related to Heat is calculated and checked.
*******************************************************************************************************/

/*******************************************************************************************************
	DON'T EDIT FROM HERE
*******************************************************************************************************/

function CDS_HeatEffect(ent, divide)
	if(!ent:IsValid()) or ent.MeltEffect then return end
	if not divide then divide = 1 end
	local Effect = EffectData()
	local mag = (math.random(4, 6))/divide
	Effect:SetEntity(ent)
	Effect:SetMagnitude(mag)
	util.Effect("cds_melt", Effect, true, true)
	ent.MeltEffect = true
	timer.Simple(mag, CDS_ResetHeatEff, ent)
end

function CDS_ColdEffect(ent, divide)
	if(!ent:IsValid()) or ent.ColdEffect then return end
	if not divide then divide = 1 end
	local Effect = EffectData()
	local mag = (math.random(4, 6))/divide
	Effect:SetEntity(ent)
	Effect:SetMagnitude(mag)
	util.Effect("cds_freeze", Effect, true, true)
	ent.ColdEffect = true
	timer.Simple(mag, CDS_ResetColdEff, ent)
end

function CDS_ResetHeatEff(ent)
	if not ent:IsValid() then return end
	ent.MeltEffect = false
end

function CDS_ResetColdEff(ent)
	if not ent:IsValid() then return end
	ent.ColdEffect = false
end

function CDS_Adaptive_Heat(ent)
	if not server_settings.Bool( "CDS_SB_Adaptive_Temp" ) then return end
	if not ent.Shield then
		if ent.environment and ent.environment.temperature then
			if ent.environment.temperature - 273 > ent.heat then
				ent.heat = ent.heat + math.abs((ent.environment.temperature - 273) / 35)
			elseif ent.environment.temperature - 273 < ent.heat then
				ent.heat = ent.heat - math.abs((ent.environment.temperature - 273) / 35)
			end
		end
		if ent.suit and ent.suit.temperature then
			if ent.suit.temperature - 273 > ent.heat then
				ent.heat = ent.heat + math.abs((ent.suit.temperature - 273) / 35)
			elseif ent.suit.temperature - 273 < ent.heat then
				ent.heat = ent.heat - math.abs((ent.suit.temperature - 273) / 35)
			end
		end
	else
		local heat
		if ent.environment then
			heat = ent.environment.temperature - 273	
		elseif ent.suit then
			heat = ent.suit.temperature - 273
		end
		if heat > 250 then
			heat = heat - 250 --Basic shield : 250 cold or heat
		elseif heat < -250 then
			heat = math.abs(heat + 250) --Basic shield : 250 cold or heat
		end
		if heat > 0 then
			ent.Shield:ShieldDamage(heat / 250, true)
		end
	end
end

function CDS_Cooldown(ent)
	local inwater = 0
	if (ent:IsPlayer() and ent:WaterLevel() > 2) or (not ent:IsPlayer() and ent:WaterLevel() == 1) then
		inwater = 10
	end
	if ent:IsPlayer() and ent.suit and ent.suit.temperature and not ent.Shield and server_settings.Bool( "CDS_SB_Adaptive_Temp" ) then
		if ent.heat > 0 and ent.suit.coolant > 0 then
			local dec = math.ceil(5 * (math.abs(ent.heat - 70)/70))
			if ent.heat > 26 + inwater then
				ent.heat = ent.heat - (26 + inwater) 
			else
				ent.heat = 0
			end
			if dec >= ent.suit.coolant then 
				ent.suit.coolant = 0 
			else
				ent.suit.coolant = ent.suit.coolant - dec
			end
		elseif ent.heat < 0 and ent.suit.energy > 0 then
			local dec = math.ceil(5 * (math.abs(math.abs(ent.heat) - 50)/50))
			if ent.heat < - (26 + inwater) then
				ent.heat = ent.heat + 26 + inwater
			else
				ent.heat = 0
			end
				if dec >= ent.suit.energy then 
				ent.suit.energy = 0 
			else
				ent.suit.energy = ent.suit.energy - dec
			end
		elseif ent.heat > ent.suit.temperature - 273  then
			if ent.heat > ent.suit.temperature - 273 + 5 + inwater then
				ent.heat = ent.heat - (5 + inwater)
			else
				ent.heat = ent.suit.temperature - 273
			end
		elseif ent.heat < ent.suit.temperature - 273 then
			if ent.heat < ent.suit.temperature - 273 - (5 + inwater) then
				ent.heat = ent.heat + 5 + inwater
			else
				ent.heat = ent.suit.temperature - 273
			end
		end
	elseif ent.environment and ent.environment.temperature and not ent.Shield and server_settings.Bool( "CDS_SB_Adaptive_Temp" ) then
		if ent.heat > ent.environment.temperature - 273 then
			if ent.heat > ent.environment.temperature - 273 + 5 + inwater then
				ent.heat = ent.heat - (5 + inwater)
			else
				ent.heat = ent.environment.temperature - 273
			end
		elseif ent.heat < ent.environment.temperature - 273 then
			if ent.heat < ent.environment.temperature -273 - (5 + inwater) then
				ent.heat = ent.heat + 5 + inwater
			else
				ent.heat = ent.environment.temperature - 273
			end
		end
	else
		if ent.heat > 0 then
			if ent.heat > (5 + inwater) then
				ent.heat = ent.heat - (5 + inwater)
			else
				ent.heat = 0
			end
		elseif ent.heat < 0 then
			if ent.heat < -(5 + inwater) then
				ent.heat = ent.heat + (5 + inwater)
			else
				ent.heat = 0
			end
		end
	end
end

function CDS_HeatColor(ent)
	if ent.CDSIgnoreHeatDamage then return end
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() and not (ent:IsPlayer() or ent:IsNPC()) then
		if ent.heat < 0 then
			if ent.heat <= -(120 + ent.maxarmor * 3 ) then
				CDS_ColdEffect(ent)
			elseif ent.heat <= -((120 + ent.maxarmor * 3)/1.2) then
				CDS_ColdEffect(ent, 2)
			end
		elseif ent.heat > 0 then
			if ent.heat >= (250 + ent.maxarmor * 6) then
				CDS_HeatEffect(ent)
			elseif ent.heat >= (250 + ent.maxarmor * 6 )/1.2 then
				CDS_HeatEffect(ent, 2)
			end
		end
	end
end



function CDS_HeatDamage(ent)
	if ent.CDSIgnoreHeatDamage then return end
	local phys = ent:GetPhysicsObject()
	if not ent:IsPlayer() and not ent:IsNPC() and phys:IsValid() and  ((ent.heat >= 250 + (ent.maxarmor * 6)) or (ent.heat <= -(120 + (ent.maxarmor * 3.5)))) then
		if ent.armor > 0 then
			cds_damageentarmor(ent, 1, nil, nil, nil, true)
		else
			if ent.heat > 250 + (ent.maxarmor * 6) then
				cds_damageent(ent, 5 * (ent.heat -((250 + (ent.maxarmor * 6))/(250 + (ent.maxarmor * 6)))), nil,nil, true)
			elseif ent.heat < -(120 + (ent.maxarmor * 3)) then
				cds_damageent(ent, 5 * (math.abs(ent.heat) -((120 + (ent.maxarmor * 3))/(120 + (ent.maxarmor * 3)))), nil,nil, true)
			end
		end
	elseif (ent:IsPlayer() or ent:IsNPC()) and (ent.heat > 70 or ent.heat < -50) then
		if ent.armor > 0 then
			cds_damageentarmor(ent, 1, nil, nil, nil, true)
		else
			if ent.heat > 70 then
				cds_damageent(ent, 5 * ((ent.heat-70)/70), nil, nil, true)
			elseif ent.heat < -50 then
				cds_damageent(ent, 5 * ((math.abs(ent.heat)-50)/50), nil, nil, true)
			end
		end
	end
end
