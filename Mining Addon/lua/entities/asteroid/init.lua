AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')


local function physgunPickup( userid, Ent )  	
	if Ent:GetClass() == "asteroid" then  		
		return false
	end  
end     
hook.Add( "PhysgunPickup", "MA_Asteroid_PhysGun_ARMEGGADONNNNN", physgunPickup ) --Don't think THAT name's gunna be repeated any time soon :ninja:

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetHealth(1000) --Default health
	self.health = 1000
	self.resources = {}
	self.ready = false
	if self:GetModel() == nil then self:Remove() ErrorNoHalt("Model for asteroid was not set.") end
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
			CAF.GetAddon("Mining Addon").Destruct( self:GetClass(),self.id,self:GetPos(),self.type,1,self.volname) --Impulseive destruct
		end
		self.removed = true
		self:Remove()
	end
end

function ENT:OnRemove()
	if not self.removed and CAF and CAF.GetAddon("Mining Addon") then
		CAF.GetAddon("Mining Addon").Destruct( self:GetClass(),self.id,self:GetPos(),self.type,1,self.volname) --Impulsive desctruct
	end
end

function ENT:Think()
	if self.ready then
		local total = 0
		if table.Count(self.resources) > 0 then
			for k,v in pairs(self.resources) do
				total = total + v
			end
		end
		if total <= 0 then
			CAF.GetAddon("Mining Addon").Destruct( self:GetClass(),self.id,self:GetPos(),self.type,2,self.volname) --Mined out of resources
			self.removed = true
			self:Remove()
		end
	end
	self.health = self:GetHealth()
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
