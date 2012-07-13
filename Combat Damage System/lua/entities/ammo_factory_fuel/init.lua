AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:SetColor(Color(140, 125, 100, 255))
	
	self.Active = 0
	self.GenResource = "ammo_fuel"
	
	self.BaseClass.SetupFactory(self)
end

function ENT:Use(activator, caller)
	self.BaseClass.OnOffUse(self, activator)
end

function ENT:TurnOn()
	self.BaseClass.FactoryTurnOn(self)
end

function ENT:TurnOff()
	self.BaseClass.FactoryTurnOff(self)
end

function ENT:Think()
	self.BaseClass.FactoryThink(self)
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:TriggerInput(iname, value)
	if(iname == "On") then
		if(value == 1) then
			self:TurnOn()
		else
			self:TurnOff()
		end
	end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self, true)
end
