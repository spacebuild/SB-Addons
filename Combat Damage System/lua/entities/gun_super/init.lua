AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	RD_AddResource(self, "ammo_explosion", 0)
	RD_AddResource(self, "ammo_pierce", 0)
	
	self:SetColor(Color(255, 255, 255, 255))
	self:SetMaterial("models/shiny")
	
	self.Cooldown = 30
	
	self.EnergyUse = 1000
	self.CoolantUse = 1000
	
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
	cds_explosion(Trace, 200, 50, 50, nil, self.Activator)
	cds_pierce(Trace, 80, 50, 100, self.Activator)
	cds_heatpos(Trace, 30, 250)
	cds_empblast(Trace, 5, 250)
end
