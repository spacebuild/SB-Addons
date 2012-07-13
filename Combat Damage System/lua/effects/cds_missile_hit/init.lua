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
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end