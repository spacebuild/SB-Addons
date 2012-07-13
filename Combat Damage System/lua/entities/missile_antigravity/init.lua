AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/props_c17/canister01a.mdl")
	self.BaseClass.Initialize(self, false, true)
	self:SetColor(Color(140, 125, 100, 255))
	self.BaseClass.Trail(self, Vector(140, 125, 100))
end

function ENT:PhysicsUpdate(PhysObj)
	self.BaseClass.MissilePhysicsUpdate(self, PhysObj)
end

function ENT:PhysicsCollide(data, physobj)
	self.BaseClass.BFPhysicsCollide(self, data, physobj)
end

function ENT:DoHit()
	local Number
	local RanNumber = math.Round(math.random(1, 3))
	if(RanNumber == 1) then
		Number = 0.00001
	elseif(RanNumber == 2) then
		Number = 5
	else
		Number = -1
	end
	cds_antigravityblast(self:GetPos(), 6, Number, 500)
	self:Remove()
end

function ENT:CanTool()
	return false
end

function ENT:GravGunPunt()
	return false
end

function ENT:GravGunPickupAllowed()
	return false
end
