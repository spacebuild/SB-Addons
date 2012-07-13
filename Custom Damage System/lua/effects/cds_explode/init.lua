function EFFECT:Init(data)
	local ori = data:GetOrigin()
	local size = data:GetScale()
	for k=1,data:GetMagnitude() do
		local e = EffectData()
		e:SetScale(size)
		e:SetOrigin(ori)
		e:SetNormal(VectorRand())
		util.Effect("cds_explode_normalized",e)
	end
	local emitter = ParticleEmitter(ori)
	for i=0,300 do
		local pPos = VectorRand()*20
		local vel = pPos * math.Rand(8,40)
		local particle = emitter:Add("cds/shard",ori + pPos)
		if particle then
			particle:SetVelocity(vel)
			particle:SetLifeTime(0)
			particle:SetDieTime(2)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(6)
			particle:SetEndSize(1)
			particle:SetCollide(true)
			particle:SetBounce(0.7)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-40,40))
			particle:SetColor(255,math.random(0,255),0)
		end
	end

end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
