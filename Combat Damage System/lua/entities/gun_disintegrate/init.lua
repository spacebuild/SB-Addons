AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self:SetColor(Color(255, 140, 0, 255))
	self:SetMaterial("models/shiny")
	
	self.Cooldown = 30
	
	self.EnergyUse = 10000
	self.CoolantUse = 10000
	self.RequireCoolant = 1
	
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
	for X=0, 99999999 do
		local Trace = self.BaseClass.Trace(self, self:GetUp(), TraceSoFar, true)
		if(Trace:IsValid()) then
			cds_disintigratepos(Trace, nil, self.Activator)
			table.insert(TraceSoFar, Trace)
		else
			break
		end
	end
end
