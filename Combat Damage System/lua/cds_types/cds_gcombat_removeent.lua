/*******************************************************************************************************
	This function will remove the entity with the gcombat effect.

		cds_gcombat_removeent(entity)
*******************************************************************************************************/

local function Explode1( ent )
	if ent:IsValid() then
		local Low, High = ent:WorldSpaceAABB()
		local Center = High - (( High - Low ) * 0.5)
		local vPos = Vector( math.Rand(Low.x,High.x), math.Rand(Low.y,High.y), math.Rand(Low.z,High.z) )
		if (ent.deathtype == 0) then
			local effectdata = EffectData()
			effectdata:SetOrigin(vPos)
			effectdata:SetStart(vPos)
			effectdata:SetScale( 10 )
			effectdata:SetRadius( 100 )
			util.Effect( "spark_death", effectdata )
		elseif (ent.deathtype == 1) then
			local effectdata = EffectData()
			effectdata:SetEntity( self )
			if not ent.deadeffect then
				util.Effect( "ener_death", effectdata )
			else
				ent.deadeffect = true
			end
		end
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

function cds_gcombat_removeent(ent)
	if(!ent.IsGettingRemoved) then ent.IsGettingRemoved = false end
	if(ent.IsGettingRemoved == true or !ent:IsValid() or ent:IsWorld() or ent:IsPlayer() or ent:IsNPC() or CDS_IsWorldEntity(ent)) then return end
	ent.IsGettingRemoved = true
	timer.Simple(math.random(.1, .9), Explode1, ent)
	timer.Simple(math.random(.1, .9), Explode1, ent)
	timer.Simple(math.random(.5, 1), Explode1, ent)
	timer.Simple(math.random(1.5,2.1), Explode2, ent)
end
