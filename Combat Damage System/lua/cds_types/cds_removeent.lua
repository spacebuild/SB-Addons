/*******************************************************************************************************
	This function will remove the entity with the default effect.

		cds_removeent(entity)
*******************************************************************************************************/


function cds_remove(ent)
	if ent:IsValid() then
		ent:Remove()
	end
end

local function Explode1( ent )
	if ent:IsValid() then
		local Low, High = ent:WorldSpaceAABB()
		local vPos = Vector(math.random(Low.x,High.x), math.random(Low.y,High.y), math.random(Low.z,High.z))
		local Effect = EffectData()
			Effect:SetOrigin(vPos)
			Effect:SetScale(1)
			Effect:SetMagnitude(25)
		util.Effect("Explosion", Effect, true, true)
	end
end

local function Explode2( ent )
	if ent:IsValid() then
		local Low, High = ent:WorldSpaceAABB()
		local vPos = Vector(math.random(Low.x,High.x), math.random(Low.y,High.y), math.random(Low.z,High.z))
		local Effect = EffectData()
			Effect:SetOrigin(vPos)
			Effect:SetScale(3)
			Effect:SetMagnitude(100)
		util.Effect("Explosion", Effect, true, true)
		cds_remove( ent )
	end
end

function cds_removeent(ent)
	if(!ent.IsGettingRemoved) then ent.IsGettingRemoved = false end
	if(ent.IsGettingRemoved == true or !ent:IsValid() or ent:IsWorld() or ent:IsPlayer() or ent:IsNPC()) then return end
	ent.IsGettingRemoved = true
	timer.Simple(math.random(.1, .9), Explode1, ent)
	timer.Simple(math.random(.1, .9), Explode1, ent)
	timer.Simple(math.random(.1, .9), Explode1, ent)
	timer.Simple(math.random(1,1.3), Explode2, ent)
end
