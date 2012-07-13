function EFFECT:Init(data)
	self.ori = data:GetOrigin()
	self.Ang = data:GetAngle()
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
	local particle = self.emitter:Add("effects/rollerglow", self.ori)
	particle:SetDieTime(4)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(0)
	particle:SetEndSize(150)
	particle:SetRoll(180)
	particle:SetRollDelta(15)
	local particle = self.emitter:Add("sprites/yellowflare", self.ori)
	particle:SetDieTime(4)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(0)
	particle:SetEndSize(50)
	particle:SetRoll(180)
	particle:SetRollDelta(-15)
	self.emitter:Finish()
	self.init = CurTime()+4
end

function EFFECT:Think()
	if self.init > CurTime() then
		for i=1,4 do		
			local particle = self.emitter:Add("effects/tool_tracer", self.ori)
			particle:SetDieTime(.3)
			particle:SetStartLength(0)
			particle:SetEndLength(100)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(35)
			particle:SetEndSize(0)
			particle:SetGravity(self:CalculateHorizion()*3)
		end
		for i=1,2 do		
			local particle = self.emitter:Add("effects/blueflare1", self.ori)
			particle:SetDieTime(.3)
			particle:SetStartLength(0)
			particle:SetEndLength(100)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(35)
			particle:SetEndSize(0)
			particle:SetGravity(self:CalculateHorizion()*3)
		end
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

function EFFECT:CalculateHorizion()
	local X = self.Ang:Right()
	local Y = self.Ang:Up()
	local Z = self.Ang:Forward()
	local ang = math.random()*math.pi*2
	local offset = (math.cos(ang)*X*a)+(math.sin(ang)*Y*a)+100*Z
	return offset
end

function EFFECT:Render()
end
