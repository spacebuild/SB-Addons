AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Speed = 100
ENT.Pierce = 50

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	RD_AddResource(self, "ammo_pierce", 0)
	
	self:SetColor(Color(0, 255, 0, 255))
	self:SetMaterial("models/shiny")
	
	self.Cooldown = 8
	
	self.EnergyUse = 100
	self.CoolantUse = 100
	
	self.PierceUse = 250
	
	self.BaseClass.SetUpWireSupport(self)
end

function ENT:Use(activator, caller)
	if(!self.BaseClass.CanUse(self, activator)) then return end
	self:Shoot()
end

function ENT:Shoot()
	if(!self.BaseClass.Shoot(self)) then return end
	self.BaseClass.CreateBeam(self)
	local TraceSoFar = {}
	local TraceHitNormal = self.BaseClass.TraceHitNormal(self, self:GetUp())
	
	local Trace1 = self.BaseClass.Trace(self, self:GetUp(), false, true)
	if(Trace1:IsValid()) then
		cds_pierce(Trace1, self.Speed, self.Pierce, nil, TraceHitNormal, self.Activator)
		table.insert(TraceSoFar, Trace1)
	end
	
	local Trace2 = self.BaseClass.Trace(self, self:GetUp(), TraceSoFar, true)
	if(Trace2:IsValid()) then
		cds_pierce(Trace2, self.Speed/2, self.Pierce/2, nil, TraceHitNormal, self.Activator)
		table.insert(TraceSoFar, Trace2)
	end

	local Trace3 = self.BaseClass.Trace(self, self:GetUp(), TraceSoFar, true)
	if(Trace3:IsValid()) then
		cds_pierce(Trace3, self.Speed/4, self.Pierce/4, nil, TraceHitNormal, self.Activator)
	end
end
