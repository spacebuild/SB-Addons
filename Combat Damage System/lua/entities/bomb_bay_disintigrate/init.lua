AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self:SetColor(Color(255, 140, 0, 255))
	self:SetMaterial("models/shiny")

	self.Cooldown = 15
	
	self.EnergyUse = 15000
	self.CoolantUse = 15000
	self.RequireCoolant = 1
	
	self.BaseClass.SetUpWireSupport(self)
end

function ENT:Use(activator, caller)
	if(!self.BaseClass.CanUse(self, activator)) then return end
	self:Shoot()
end

function ENT:Shoot()
	if(!self.BaseClass.Shoot(self)) then return end
	self.BaseClass.CreateBomb(self, "bomb_disintigrate")
end
