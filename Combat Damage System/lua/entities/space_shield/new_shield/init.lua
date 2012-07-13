AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Radius = 512
ENT.DefaultRadius = 512
ENT.Strength = 0
ENT.MaxStrength = 3000
ENT.TimeStrengthFix = 3
ENT.DestoryEnts1 = {"missile_", "bomb_", "staff_pulse", "drone"}
ENT.DestoryEnts2 = {100, 100, 200, 100}

ENT.DeflectEnts1 = {"npc_grenade_frag", "prop_combine_ball"}
ENT.DeflectEnts2 = {100, 100}

ENT.ShieldedEnts = {} --LEAVE BLANK
ENT.IgnoreEnts1 = {} --LEAVE BLANK

function ENT:Initialize()
	self:SetModel("models/roller.mdl")
	self:SetColor(Color(255, 0, 0, 255))
	self.BaseClass.Initialize(self, false)
	
	RD_AddResource(self, "energy", 0)
	RD_AddResource(self, "coolant", 0)
	
	self.Active = 0
	self.LastSound = CurTime()
	self.LastUSUpdate = CurTime()
	self.CDS_Allow_Heat = false
	
	if(WireAddon ~= nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, {"On", "Disable Use", "Radius"})
		self.Outputs = Wire_CreateOutputs(self, {"On", "Disable Use", "Radius", "Coolant", "Energy", "Strength", "Max Strength"})
		Wire_TriggerOutput(self, "Radius", self.Radius)
		Wire_TriggerOutput(self, "Max Strength", self.MaxStrength)
	end
end

function ENT:Use(activator, caller)
	self.BaseClass.OnOffUse(self, activator)
end

function ENT:TurnOn()
	if(self.Active == 1) then return end
	self.Active = 1
	self:SetColor(Color(128, 255, 255, 255))
	self:SetModel("models/roller_spikes.mdl")
	self:SetNetworkedString("OnOff", "On")
	
	self.BaseClass.UpdateActive(self)
	
	if ValidEntity(self.Shield) then
		self.Shield:Remove()
	end
	
	self.Shield = ents.Create("cds_shield")
	self.Shield:SetPos(self:GetPos())
	self.Shield:SetAngles(self:GetAngles())
	self.Shield:Spawn()
	
	self.Shield:Setup(self)
	
	self:SetNWInt("Radius", self.Radius)
end

function ENT:TurnOff()
	if(self.Active == 0) then return end
	self.Active = 0
	self:SetColor(Color(255, 0, 0, 255))
	self:SetModel("models/roller.mdl")
	self:SetNetworkedString("OnOff", "Off")
	
	self.BaseClass.UpdateActive(self)
	
	if ValidEntity(self.Shield) then
		self.Shield:Remove()
	end
end

function ENT:ChangeRadius(NewRadius)
	self.Radius = NewRadius
	if(self.EmitEnt and self.EmitEnt:IsValid()) then
		self.EmitEnt:SetNetworkedInt("Radius", self.Radius)
	end
	if(WireAddon ~= nil) then
		Wire_TriggerOutput(self, "Radius", self.Radius)
	end
end

function ENT:RequestShieldRegeneration()
	self:TurnOff()
	self:TurnOn()
end

function ENT:StrengthTimerCheck()
	if(self.LastUSUpdate + self.TimeStrengthFix <= CurTime()) then
		return true
	end
	return false
end

function ENT:UpdateStrength()
	self.Strength = math.Round(self.Strength)
	self:SetNetworkedBeamInt("str", self.Strength)	
	if(WireAddon ~= nil) then
		Wire_TriggerOutput(self, "Strength", self.Strength)
	end
end

function ENT:UseStrength(Amount)
	if(0 > self.Strength - Amount) then
		self.Strength = 0
	else
		self.Strength = self.Strength - Amount
	end
	self:UpdateStrength()
	--self.BaseClass.UseResource(self, "coolant", math.random(4, 8))
end

function ENT:EventShieldDamage(Amount)
	Amount = math.Round(Amount/2)
	self:UseStrength(Amount)
end

function ENT:SetShieldedEnts(tbl)
	self.ShieldedEnts = tbl
end

function ENT:Think()
	if(self.Active == 0 or !self:StrengthTimerCheck()) then
		for k, v in pairs(self.ShieldedEnts) do
			v.Shield = nil
		end
		self.ShieldedEnts = {}
	else
		for k1, v1 in pairs(self.ShieldedEnts) do
			local FoundEnt = false
			for k2, v2 in pairs(Sphere) do
				if(v1 == v2) then
					FoundEnt = true
				end
			end
			if(FoundEnt == false) then
				if(v1:IsValid()) then
					v1.Shield = nil
				end
				self:TableRemoveEnt(v1)
			end
		end
	end
	
	local Energy = RD_GetResourceAmount(self, "energy")
	local Coolant = RD_GetResourceAmount(self, "coolant")
	
	
	if(self.Active == 1) then
		if(self.Strength < self.MaxStrength) then
			if(self.Strength <= 0) then
				self.BaseClass.Warning(self)
				if(self.LastUSUpdate + (self.TimeStrengthFix + 0.5) <= CurTime()) then
					self.LastUSUpdate = CurTime()
				end
			else
				self:UseStrength(5)
				self:UpdateStrength()
				self.BaseClass.UseResource(self, "coolant", math.random(4, 6) * (self.Radius / self.DefaultRadius))
			end
			
			if(Energy > 0 and self:StrengthTimerCheck()) then
				local RanNumber = math.random(4, 8) --Before (8, 12)
				if(self.Strength + RanNumber > self.MaxStrength) then
					self.Strength = self.MaxStrength
				else
					self.Strength = self.Strength + RanNumber
				end
				self:UpdateStrength()
				self.BaseClass.UseResource(self, "energy", math.random(10, 20) * (self.Radius / self.DefaultRadius))
			else
				self.BaseClass.Warning(self)
			end
			
			if(Coolant <= 0) then
				if(self.CDS_Allow_Heat == false) then
					self.CDS_Allow_Heat = true
				end
				if(Energy > 0) then
					cds_heatpos(self:GetPos(), 3, 250)
				end
				self.BaseClass.Warning(self)
			elseif(self.CDS_Allow_Heat == true) then
				self.CDS_Allow_Heat = false
			end
		end
	end
	
	if(WireAddon ~= nil) then
		Wire_TriggerOutput(self, "Coolant", Coolant)
		Wire_TriggerOutput(self, "Energy", Energy)
	end
end

function ENT:TableRemoveEnt(ent)
	for k, v in pairs(self.ShieldedEnts) do
		if(v == ent) then
			table.remove(self.ShieldedEnts, k)
			return
		end
	end
end

function ENT:TriggerInput(iname, value)
	if(iname == "On") then
		if(value == 1) then
			self:TurnOn()
		else
			self:TurnOff()
		end
	end
	if(iname == "Disable Use") then
		if(value == 1) then
			self.DisableUse = true
			Wire_TriggerOutput(self, "Disable Use", 1)
		else
			self.DisableUse = false
			Wire_TriggerOutput(self, "Disable Use", 0)
		end
	end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	for k, v in pairs(self.ShieldedEnts) do
		v.Shield = nil
	end
	if(self.EmitEnt and self.EmitEnt:IsValid()) then
		self.EmitEnt:Remove()
	end	
end
