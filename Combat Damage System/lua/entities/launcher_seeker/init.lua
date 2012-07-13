AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self, true, false, true)
	RD_AddResource(self, "ammo_explosion", 0)
	RD_AddResource(self, "ammo_fuel", 0)
	
	self:SetColor(Color(255, 255, 255, 255))
	self:SetMaterial("models/shiny")
	
	self.Cooldown = 5
	
	self.EnergyUse = 1000
	self.CoolantUse = 1000
	
	self.FuelUse = 500
	self.FuelMissleUse = 1
	self.ExplosionUse = 500
	
	self.BaseClass.SetUpWireSupport(self)
end

function ENT:Use(activator, caller)
	if(!self.BaseClass.CanUse(self, activator)) then return end
	self:Shoot()
end

function ENT:Shoot()
	if(!self.BaseClass.Shoot(self)) then return end
	self.BaseClass.CreateMissile(self, "missile_seeker")
end
