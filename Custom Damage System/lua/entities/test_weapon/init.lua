AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "ambient.steam01" )

include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.damaged = 0
	self.lastfire = 0
	self.delay = 0.5
	self.force = 5000
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
	end
end

function ENT:FireRail(ply)
	local ent = ents.Create( "test_projectile" )
	--local ent = ents.Create( "cds_physical_bullet" )
			ent:SetPos( self:GetPos() + (self:GetForward() * -80))
			ent:SetAngles( self:GetAngles( ) )
			ent:SetOwner( ply )
		ent:Spawn( )
		ent:SetForce(self.force)
		local obj = self:GetPhysicsObject() 
		if obj:IsValid() then
			obj:ApplyForceCenter( self:GetForward() * self.force ) 
		end
		constraint.NoCollide(self, ent, 0, 0)
		self.lastfire = CurTime()
end

function ENT:Damage()
	if (self.damaged == 0) then
		self.damaged = 1
	end
end

function ENT:Repair()
	self:SetColor(Color(255, 255, 255, 255))
	self.health = self.maxhealth
	self.damaged = 0
end

function ENT:Destruct()
end

function ENT:Use( pl)
	if(CurTime() > self.lastfire + self.delay) then
		self:FireRail(pl)
	end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
end

function ENT:Think()
	self.BaseClass.Think(self)
	self:NextThink(CurTime() + 1)
	return true
end
