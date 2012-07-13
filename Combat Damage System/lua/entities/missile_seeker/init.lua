AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')
   
function ENT:Initialize()
	self:SetModel("models/props_c17/canister01a.mdl")
	self.BaseClass.Initialize(self, false, true)
	self:SetColor(Color(255, 255, 255, 255))
	self.BaseClass.Trail(self, Vector(255, 255, 255))
	self.Target = false
end

function ENT:PhysicsUpdate(PhysObj)
	if(!self.Fuel or !self.FuelUse or self.Fuel == 0) then
		self.BaseClass.MissileNoFuel(self)
		self.BaseClass.CheckTrailEnt(self)
		return
	elseif(self.Target ~= false and self.Target:IsValid()) then
		local Target_Angle = (self.Target:GetPos() - self:GetPos()):Angle()
		Target_Angle.pitch = Target_Angle.pitch + 90
		
		--ocal Self_Angle = PhysObj:GetAngles()
		--Self_Angle.pitch = math.Clamp(Target_Angle.pitch, -10, 10)
		--SelfAngle.roll = math.Clamp(Angle.roll, 0, 1)
		--SelfAngle.yaw =	math.Clamp(Angle.yaw, 0, 1)
		
		PhysObj:SetAngle(Target_Angle)
	else
		local Trace = self.BaseClass.Trace(self, self:GetUp(), false, true)
		if(Trace:IsValid()) then
			self.Target = Trace
		end
	end
	PhysObj:ApplyForceCenter(self:GetUp() * 5000000)
	self.BaseClass.UseFuel(self)
end

function ENT:PhysicsCollide(data, physobj)
	self.BaseClass.BFPhysicsCollide(self, data, physobj)
end

function ENT:DoHit()
	cds_explosion(self:GetPos(), 150, 80, 45, nil, self.Activator)
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
