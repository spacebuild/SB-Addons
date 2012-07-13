AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize( )
	self:SetModel( "models/weapons/w_bugbait.mdl" )
 	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetColor(Color( 255, 255, 000, 200 ))
	self:GetPhysicsObject( ):SetMass( 1 )
	self:GetPhysicsObject( ):Wake( )
	self.owner = 0
	self.hit = false
	self.force = 0
end

function ENT:SetOwner(owner)
	self.owner = owner
end

function ENT:SetForce(amount)
	if not amount or type(amount) ~= "number" then return false end
	self.force = amount
end

function ENT:PhysicsCollide( data, physobj )
	if data.HitEntity and not self.hit then
		self.hit = true
		local effect, snd
		local range = 50;
		local forcemult = 1;
		local usedefaulteffect = false;
		local target = nil;
		local weapon = self;
		local attacker = self.owner
		local customAttack = CustomAttack.Create(target, weapon, attacker);
		customAttack:setPiercing(1)
		--{"Shock", "Kinetic", "Energy"}
		customAttack:AddAttack("Shock", 150)
		customAttack:AddAttack("Kinetic", 100)
		customAttack:AddAttack("Energy", 50)
		
		CDSAttacks.Explosion(customAttack, range, forcemult, usedefaulteffect)
		--local ok, err, err2 = CAF.GetAddon("Custom Damage System").Attack(self, "Explosion", { range = 50, damage = 30, armordamage = 50, inflictor = self.owner, ignore = { self }})
		--if err then Msg("error: "..tostring(err).."\n") end
		--if err2 then Msg("error: "..tostring(err2).."\n") end
		local obj = data.HitEntity:GetPhysicsObject() 
		if obj:IsValid() then
			obj:ApplyForceOffset( self:GetForward() * -self.force, self:GetForward() ) 
		end
		effect = EffectData( )
			effect:SetScale( 10 )
			effect:SetMagnitude( 10 )
			effect:SetOrigin( self:GetPos( ) )
		util.Effect( "cds_plasma_distruption", effect )
		snd = math.random( 9 )
		while snd == 4 do
			snd = math.random( 9 )
		end
		WorldSound( Sound( "ambient/energy/zap" .. snd .. ".wav" ), self:GetPos( ), 100, 100 )
	end
end

function ENT:Think()
	
end

function ENT:PhysicsUpdate(PhysObj)
	PhysObj:ApplyForceCenter(self:GetForward() * -(self.force * 1000))
	if self.hit then
		self:Remove()
	end
end
