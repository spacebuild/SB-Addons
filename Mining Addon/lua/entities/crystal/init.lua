
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local function physgunPickup( userid, Ent )  	
	if Ent:GetClass() == "crystal" then  		
		return false
	end  
end     
hook.Add( "PhysgunPickup", "MA_Crystal_PhysGun", physgunPickup );  

function ENT:Initialize()
	--self.BaseClass.Initialize(self) --use this in all ents
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self.resource = ""
	self.amount = 0
	if self:GetModel() == nil then self:Remove() ErrorNoHalt("Model for asteroid was not set.") end
end


function ENT:OnTakeDamage(DmgInfo)
	if self.amount > 0 then
		self.amount = self.amount - math.Round(math.random(1, DmgInfo:GetDamage( )))
		if self.amount <= 0 then
			self.amount = 0
			self:Remove()
		end
	end
end

function ENT:SetResource(resource)
	if not resource then return end
	self.resource = tostring(resource)
end

function ENT:SetAmount(amount)
	if not amount or not type(amount) == "number" then return end
	self.amount = amount
end

function ENT:Think()
	if self.amount <= 0 then
		self.amount = 0
		self:Remove()
	end
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:OnRemove()

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
