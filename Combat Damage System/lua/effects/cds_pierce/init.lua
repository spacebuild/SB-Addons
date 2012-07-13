
function EFFECT:Init(data)
	self.ori = data:GetOrigin()
	self.Ang = data:GetAngle()
	self.emitter = ParticleEmitter(self.ori)
	self.init = CurTime()+.5
end

function EFFECT:Think()
	if self.init > CurTime() then
		for i=1,7 do		
			local particle = self.emitter:Add("effects/tool_tracer", self.ori)
			particle:SetDieTime(.3)
			particle:SetStartLength(0)
			particle:SetEndLength(100)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(35)
			particle:SetEndSize(0)
			particle:SetGravity(self:CalculateHorizion())
		end
		for i=1,3 do		
			local particle = self.emitter:Add("effects/blueflare1", self.ori)
			particle:SetDieTime(.3)
			particle:SetStartLength(0)
			particle:SetEndLength(100)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(35)
			particle:SetEndSize(0)
			particle:SetGravity(self:CalculateHorizion())
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
	return offset/-.5
end

function EFFECT:Render()
end