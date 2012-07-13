AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "items/suitchargeok1.wav" )
util.PrecacheSound( "items/suitchargeno1.wav" )
util.PrecacheSound( "items/medshotno1.wav" )

include('shared.lua')

local Ground = 0 + 0 + 0 + 0 + -32

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.damaged = 0
	
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
	end
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass( 20 )
	end

	
	RD_AddResource(self, "air", 0)
	RD_AddResource(self, "energy", 0)
	RD_AddResource(self, "coolant", 0)
	
	--amount of resources required per 1 HP of healing
	self.energyreq = 17
	self.airreq = 11
	self.coolantreq = 13
	
	self.maxhealth = 120
	self.health = self.maxhealth
end

function ENT:Damage()
	if (self.damaged == 0) then self.damaged = 1 end
end

function ENT:Repair()
	self:SetColor(Color(255, 255, 255, 255))
	self.health = self.max_health
	self.damaged = 0
end

function ENT:Destruct()
	LS_Destruct( self, true )
end

function ENT:SetActive( value, caller )
	self.air = RD_GetResourceAmount(self, "air")
	self.energy = RD_GetResourceAmount(self, "energy")
	self.coolant = RD_GetResourceAmount(self, "coolant")
	
	local userHP = caller:Health()
	
	if (userHP < 100) then
		--total required resources for this heal
		local totalheal = 100 - userHP
		local totalair = self.airreq * totalheal
		local totalenergy = self.energyreq * totalheal
		local totalcoolant = self.coolantreq * totalheal
		
		--heal user if theres enough
		if(self.air > totalair and self.energy > totalenergy and self.coolant > totalcoolant) then
			RD_ConsumeResource(self, "energy", totalenergy)
			RD_ConsumeResource(self, "coolant", totalcoolant)
			RD_ConsumeResource(self, "air", totalair)
			
			
			caller:SetHealth(100)
			caller.Entity:EmitSound( "items/suitchargeok1.wav" )
		else
			caller.Entity:EmitSound( "items/suitchargeno1.wav" )
		end
		
	else
		caller.Entity:EmitSound( "items/medshotno1.wav" )
	end
end

