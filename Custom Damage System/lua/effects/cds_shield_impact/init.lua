function EFFECT:Init(data)
	self.ori = data:GetOrigin()
	self.emitter = ParticleEmitter(self.ori)
	for i=1,60 do		
		local v = VectorRand()*75
		local particle = self.emitter:Add("effects/gunshiptracer", self.ori)
		particle:SetVelocity(v)
		particle:SetDieTime(3)
		particle:SetStartLength(10)
		particle:SetEndLength(10)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(5)
		particle:SetEndSize(0)
		particle:SetGravity(v*4)
	end
	local particle = self.emitter:Add("sprites/strider_blackball", self.ori)
	particle:SetVelocity(Vector(0,0,0))
	particle:SetDieTime(.5)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(0)
	particle:SetEndSize(150)
	particle:SetRoll(180)
	particle:SetRollDelta(15)
	local particle = self.emitter:Add("sprites/animglow02", self.ori)
	particle:SetVelocity(Vector(0,0,0))
	particle:SetDieTime(.5)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(0)
	particle:SetEndSize(150)
	particle:SetRoll(180)
	particle:SetRollDelta(-15)
	self.emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	--?
end