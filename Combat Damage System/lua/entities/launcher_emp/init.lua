AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self, true, false, true)
	RD_AddResource(self, "ammo_fuel", 0)
	
	self:SetColor(Color(0, 0, 255, 255))
	self:SetMaterial("models/shiny")

	self.Cooldown = 20
	
	self.EnergyUse = 600
	self.CoolantUse = 600
	
	self.FuelUse = 250
	
	self.BaseClass.SetUpWireSupport(self)
end

function ENT:Use(activator, caller)
	if(!self.BaseClass.CanUse(self, activator)) then return end
	self:Shoot()
end

function ENT:Shoot()
	if(!self.BaseClass.Shoot(self)) then return end
	self.BaseClass.CreateMissile(self, "missile_emp")
end
