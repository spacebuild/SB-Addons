-- Author: Solthar
-- Thanks to: Sassafrass
-- Entity: Packaging Factory Crate
-- Purpose: holds resources and storage
-- Uses: Resource Distribution 2, Life Support 2


AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.PrecacheSound( "AlyxEMP.Discharge" )

local CDSFudgeFix 	= 100000	-- A huge number so that CDS won't destroy the prop.
local _Threshold	= 1250		-- if greater than this velocity, the packet becomes highly unstable
								-- if it touches anything other than the reciever it goes BOOM!
local _PacketSpeed  = 10000
local _BoostTime	= 1.25		-- Time, in seconds, that the packet is 'boosted'
function ENT:Initialize()   
	self.model = "models/props_c17/woodbarrel001.mdl"

	self:SetModel( self.model ) 	
	self:PhysicsInit( SOLID_VPHYSICS )      	
	self:SetMoveType( MOVETYPE_VPHYSICS )   	
	self:SetSolid( SOLID_VPHYSICS )        	
end   

function ENT:TransferResources(resid,resamount,restype)
	self.ResAmount 	= resamount
	self.ResName 	= restype
	self.ResID 		= resid
	self.Velocity 	= 0
	self.SpawnTime  = CurTime()
	
	--Set up this device as a storage device
	RD_AddResource   (self,restype,resamount)
	RD_SupplyResource(self,restype,resamount)

	self:SetMaterial("models/props_vents/borealis_vent001c")
	rts_ResourceSetup(self,self.ResName)

    -- The more explosive the loads, the more reinforced the crates are, naturally
    self:SetHealth(self.ResAmount * (self.damagemultiplier / 5))
    self.health = self.ResAmount * (self.damagemultiplier / 5) + CDSFudgeFix
    self.maxhealth = self.ResAmount * (self.damagemultiplier / 5) + CDSFudgeFix
	
	--larger loads are heavier
	--set the velocity
	local phys = self:GetPhysicsObject()
	if ( phys:IsValid() ) then 
		phys:SetMass((self.ResAmount * self.damagemultiplier)/10)	
		phys:EnableDrag( false)
		phys:Wake()
	end
	
	self:NextThink( CurTime() + 1)
 	self:SetNetworkedString("DisplayText1", self.ResName)
 	self:SetNetworkedString("DisplayText2", self.ResAmount.." Units")

end

function ENT:OnTakeDamage( dmginfo )
--	self:TakePhysicsDamage( dmginfo )

	-- Volatility System, Rather like d20. 
	-- if it rolls less than the volatility, double damage.
	-- if it rolls less than twice, ten times.
	-- if it rolls less than thrice, one hundred times, and double the explosion (aka; ressonant cascade failure :-P).
	-- Should make transporting dangerous goods more exciting.
	
	-- maybe add sounds to each event?
	local DamageMod = 1
	local ExplodeMod = 1
	if (math.Rand(0,100) <= self.volatility) then
		DamageMod = 2
		if (math.Rand(0,100) <= self.volatility) then
			DamageMod = 10
			ExplodeMod = 1.15
			if (math.Rand(0,100) <= self.volatility) then
				DamageMod = 100
				ExplodeMod = 5
			end

		end
	end
	
	self.health = self.health - dmginfo:GetDamage() * DamageMod
	self:HealthCheck(ExplodeMod)
end

function ENT:HealthCheck(ExplodeMod)
	if self.health <= CDSFudgeFix then
		-- EXPLODE! KABLOOIE!
		--rts_Explosion(damage, piercing, area, position, killcredit)
		rts_Explosion( self.ResAmount * self.damagemultiplier / 20 * ExplodeMod,2 + self.damagemultiplier + (ExplodeMod * 10) , self.ResAmount * self.damagemultiplier / 10 * ExplodeMod,self:GetPos()+  self:GetUp() * 25,self.Activator)
		self:Remove()
	end
end

function ENT:PhysicsCollide(data, physobj )
	local hitent = data.HitEntity
	local class = hitent:GetClass()
	if class and class == "rts_massdriver" then
		RD_SupplyResource(data.HitEntity, self.resourcetype, self.ResAmount)
		self:EmitSound( "AlyxEMP.Discharge", 100, 100)
		self:Remove()
	else
		if ( self.Velocity > _Threshold) then
			--rts_Explosion	(damage												, piercing						, area												, position											, killcredit	)
			rts_Explosion	( self.ResAmount * self.damagemultiplier / 4	,(5 + self.damagemultiplier/10) , self.ResAmount * self.damagemultiplier / 2	, self:GetPos()+  self:GetUp() * 25	, self.Activator)
			self:Remove()
		end
	end
end

function ENT:Think()
	
	--Checks the health to make sure we're all right
	self:HealthCheck(1)
	
	local physx = self:GetPhysicsObject()  	
	if (physx:IsValid()) then  		
		local v = physx:GetVelocity()
		self.Velocity = math.abs(v.x) + math.abs(v.y) + math.abs(v.z)
		physx:EnableDrag( false)
		if (self.Velocity >  _Threshold) then
			physx:EnableGravity( false ) 
			physx:Wake()
		elseif (CurTime() > (self.SpawnTime + _BoostTime) ) then
			physx:EnableGravity( true ) 
			physx:Wake()
		end
		
		if (CurTime() < (self.SpawnTime + _BoostTime) ) then
			physx:ApplyForceCenter( self:GetUp() * _PacketSpeed)
			--physx:SetVelocity( self:GetUp() * _PacketSpeed)
		end
	end 
	
	self:NextThink( CurTime() + 0.1)
	return true
 end
 
