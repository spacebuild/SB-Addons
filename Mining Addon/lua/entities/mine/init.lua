AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')


local function physgunPickup( userid, Ent )  	
	if Ent:GetClass() == "mine" then  		
		return false
	end  
end     
hook.Add( "PhysgunPickup", "MA_Mine_PhysGun_ARMEGGADONNNNN", physgunPickup ) --Don't think THAT name's gunna be repeated any time soon :ninja:

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetHealth(1000) --Default health
	self.ready = true
	self:SetModel("models/metal/largeoredeposit.mdl")
	self.level = 2
	self:Spawn()
	self.OriginalVolume = math.Round(self:GetPhysicsObject():GetVolume())
	self.mine_amount = 0
end

function ENT:TriggerInput(iname, value)

end

function ENT:Damage()
	if (self.damaged == 0) then
		self.damaged = 1
		
	end
end


function ENT:OnTakeDamage(dmg)
	self:SetHealth(self:Health() - dmg:GetDamage())
	--Msg(self.health)
	if self.health < 1 then
		if CAF and CAF.GetAddon("Mining Addon") then
			CAF.GetAddon("Mining Addon").Destruct( self:GetClass(),self.id,self:GetPos(),self.type,1) --Impulseive destruct
		end
		self.removed = true
		self:Remove()
	end
end

function ENT:OnRemove()
	if not self.removed and CAF and CAF.GetAddon("Mining Addon") then
		CAF.GetAddon("Mining Addon").Destruct( self:GetClass(),self.id,self:GetPos(),self.type,1) --Impulsive desctruct
	end
end

function ENT:Think()
	if self.ready then
		if self.mine_amount <= 0 then
			CAF.GetAddon("Mining Addon").Destruct( self:GetClass(),self.id,self:GetPos(),self.type,2) --Mined out of resources
			self.removed = true
			timer.Simple(2.5,self:Remove())
		end
		if self.mine_amount <= (self.OriginalVolume/3) * (self.level+1) then
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetStart(self:GetPos())
			effectdata:SetMagnitude(self.level)
			effectdata:SetScale(20)
			--effectdata:SetRadius(500)
			util.Effect("ImpactRagdoll",effectdata)
			self.level = self.level - 1
		end
		if self.level == 2 then 
			self:SetModel("models/metal/largeoredeposit.mdl")
		elseif self.level == 1 then
			self:SetModel("models/metal/mediumoredeposit.mdl")
		elseif self.level == 0 then
			self:SetModel("models/metal/smalloredeposit.mdl")
		end
	end
end

function ENT:CanTool()
	return false
end

function ENT:GravGunPunt()
	return false
end

function ENT:GravGunPickupAllowed()
	return false
end

