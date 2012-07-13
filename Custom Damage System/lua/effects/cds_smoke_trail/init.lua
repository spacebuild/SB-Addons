function EFFECT:Init(data)
	self.entity = data:GetEntity()
	self.Entity:SetParent(self.entity)
	self.Entity:PhysicsInitSphere(4)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetPos(data:GetOrigin())
	self.emit = ParticleEmitter(data:GetOrigin())
	self.size = data:GetScale()
	local tmp = data:GetStart()
	self.die = data:GetMagnitude()
	self.color = {tmp.x,tmp.y,tmp.z}
end

function EFFECT:Think()
		if not self.entity:IsValid() then
		self.emit:Finish()
		return false
	end
	local particle = self.emit:Add("particle/smokestack", self.Entity:GetPos())
	particle:SetVelocity(Vector(0,0,0))
	particle:SetDieTime(self.die)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(self.size)
	particle:SetEndSize(0)
	particle:SetRoll(180)
	particle:SetRollDelta(math.random(-1,1))
	particle:SetColor(self.color[1],self.color[2],self.color[3])
	return true
end

function EFFECT:Render()
end
