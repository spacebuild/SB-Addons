AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetHealth(100) --Default health
	self.ready = false
	self:SetModel("models/metal/ore.mdl")
	self.level = 2
	self.mine_amount = math.random(150,400)
end

function ENT:TriggerInput(iname, value)

end

function ENT:Damage()
	if (self.damaged == 0) then
		self.damaged = 1
		
	end
end


function ENT:OnTakeDamage(dmg)
	self:SetHealth(self:Health() - dmg:GetAmmount())
	--Msg(self.health)
	if self.health < 1 then
		self.removed = true
		self:Remove()
	end
end

function ENT:OnRemove()

end

function ENT:Think()
	if self.ready then
		if self.mine_amount <= 0 then
			self.removed = true
			self:Remove()
		end
	end
end

function ENT:CanTool()
	return false
end

function ENT:GravGunPunt()
	return true
end

function ENT:GravGunPickupAllowed()
	return true
end
