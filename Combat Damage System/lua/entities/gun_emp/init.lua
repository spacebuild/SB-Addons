AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self:SetColor(Color(0, 0, 255, 255))
	self:SetMaterial("models/shiny")

	self.Cooldown = 20
	
	self.EnergyUse = 250
	self.CoolantUse = 250
	
	self.BaseClass.SetUpWireSupport(self)
end

function ENT:Use(activator, caller)
	if(!self.BaseClass.CanUse(self, activator)) then return end
	self:Shoot()
end

function ENT:Shoot()
	if(!self.BaseClass.Shoot(self)) then return end
	self.BaseClass.CreateBeam(self)
	local Trace = self.BaseClass.Trace(self, self:GetUp())
	cds_empblast(Trace, 5, 10)
end
