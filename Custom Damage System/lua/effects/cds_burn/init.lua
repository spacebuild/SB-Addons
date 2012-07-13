local matHeatWave		= Material("sprites/heatwave")

function EFFECT:Init(data)
	self.ori = data:GetOrigin()
	self.rad = data:GetScale()
	self.ent = data:GetEntity()
	local ma = data:GetMagnitude()
	self.alpha = 1
	self.emitter = ParticleEmitter(self.ori)
	for i=1,10 do		
		local vecang = VectorRand()/2
		local spawnpos = self.ori+256*vecang	
		for k=5,26 do
			local particle = self.emitter:Add("particles/flamelet"..math.random(1,5), spawnpos)
			particle:SetVelocity((vecang*9*k)*-.5)
			particle:SetDieTime(ma)
			particle:SetEndAlpha(0)
			particle:SetStartAlpha(math.random(230, 250))
			particle:SetStartSize((k/6)*self.rad)
			particle:SetEndSize((k/6)*(self.rad+6))
			particle:SetRoll(math.random(40, 160))
			particle:SetRollDelta(math.random(-2, 2))
			particle:SetColor(math.random(150,255), math.random(100,150), 100)
			particle:SetCollide(true)
			particle:VelocityDecay(true)
			if math.random(1,2) == 1 then
				render.UpdateRefractTexture()
				particle = self.emitter:Add("sprites/heatwave", spawnpos)
				particle:SetVelocity((vecang*9*k)/-1)
				particle:SetDieTime(ma)
				particle:SetEndAlpha(0)
				particle:SetStartAlpha(math.random(230, 250))
				particle:SetStartSize((k/6)*self.rad+4)
				particle:SetEndSize((k/6)*(self.rad+6)+4)
				particle:SetRoll(math.random(40, 160))
				particle:SetRollDelta(math.random(-2, 2))
				particle:SetColor(math.random(150,255), math.random(100,150), 100)
				particle:VelocityDecay(true)
			end
		end
	end
	self.emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	--?
end
