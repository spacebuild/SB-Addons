function EFFECT:Init(data)
	local ori = data:GetOrigin()
	local size = data:GetScale()
	local nrm = data:GetNormal()
	local emitter = ParticleEmitter(ori)	
	local max = math.random(20,30)
	for k=1,max do
		local particle = emitter:Add("particles/flamelet"..math.random(1,5), ori)
		particle:SetVelocity(nrm*10*k+(VectorRand()*35))
		particle:SetDieTime(size/10)
		particle:SetEndAlpha(0)
		particle:SetStartAlpha(math.random(230, 250))
		particle:SetStartSize(size-(k-max))
		particle:SetEndSize(size-(k-max))
		particle:SetRoll(math.random(40, 160))
		particle:SetRollDelta(math.random(-1, 1))
		particle:SetColor(255,20*k, 100)
	end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
