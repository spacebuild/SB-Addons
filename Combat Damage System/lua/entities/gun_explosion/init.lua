AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	RD_AddResource(self, "ammo_explosion", 0)
	
	self:SetColor(Color(0, 0, 0, 255))
	self:SetMaterial("models/shiny")
	
	self.Cooldown = 10
	
	self.EnergyUse = 250
	self.CoolantUse = 250
	self.ExplosionUse = 250
	
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
	cds_explosion(Trace, 100, 100, 25, nil, self.Activator)
end
