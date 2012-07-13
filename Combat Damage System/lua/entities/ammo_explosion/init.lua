AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.AmmoType = "ammo_explosion"

function ENT:Initialize()
	self:SetColor(Color(0, 0, 0, 255))
	self.BaseClass.Initialize(self, false)
	self.BaseClass.SetUpCrate(self)
end

function ENT:Think()
	self.BaseClass.CrateThink(self)
	self:NextThink(CurTime() + 1)
	return true
end
