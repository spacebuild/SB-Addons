function EFFECT:Init(data)
	self.ori = data:GetOrigin()
	self.emitter = ParticleEmitter(self.ori)
	local particle = self.emitter:Add("sprites/strider_blackball", self.ori)
	particle:SetVelocity(Vector(0,0,0))
	particle:SetDieTime(.75)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(0)
	particle:SetEndSize(150)
	particle:SetRoll(180)
	particle:SetRollDelta(15)
	local particle = self.emitter:Add("sprites/orangecore2", self.ori)
	particle:SetVelocity(Vector(0,0,0))
	particle:SetDieTime(1)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(0)
	particle:SetEndSize(150)
	particle:SetRoll(180)
	particle:SetRollDelta(-15)
	local particle = self.emitter:Add("sprites/orangeflare1", self.ori)
	particle:SetVelocity(Vector(0,0,0))
	particle:SetDieTime(1)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(0)
	particle:SetEndSize(150)
	particle:SetRoll(180)
	particle:SetRollDelta(15)
	self.init = CurTime()+.75
end

function EFFECT:Think()
	if self.init > CurTime() then
		for i=1,7 do		
			local v = VectorRand()
			local particle = self.emitter:Add("effects/tool_tracer", self.ori)
			particle:SetDieTime(.3)
			particle:SetStartLength(0)
			particle:SetEndLength(100)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(35)
			particle:SetEndSize(0)
			particle:SetGravity(v)
		end
		for i=1,3 do		
			local v = VectorRand()
			local particle = self.emitter:Add("effects/blueflare1", self.ori)
			particle:SetDieTime(.3)
			particle:SetStartLength(0)
			particle:SetEndLength(100)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(35)
			particle:SetEndSize(0)
			particle:SetGravity(v)
		end
		return true
	end
	self.emitter:Finish()
	return false
end

function EFFECT:Render()
	--?
end