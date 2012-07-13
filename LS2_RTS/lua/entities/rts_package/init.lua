-- Author: Solthar
-- Thanks to: Sassafrass
-- Entity: Packaging Factory Crate
-- Purpose: holds resources and storage
-- Uses: Resource Distribution 2, Life Support 2


AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

util.PrecacheSound( "AlyxEMP.Discharge" )
local CDSFudgeFix = 100000	-- A huge number so that CDS won't destroy the prop.

function ENT:Initialize()   
	self.model = "models/props_c17/woodbarrel001.mdl"

	self:SetModel( self.model ) 	
	self:PhysicsInit( SOLID_VPHYSICS )      	
	self:SetMoveType( MOVETYPE_VPHYSICS )   	
	self:SetSolid( SOLID_VPHYSICS )        	
end   

function ENT:SetWeight(restype,resamount)
	self.resourceamount =  resamount
	self.resourcetype = restype
	self:SetMaterial("models/props_vents/borealis_vent001c")
	RD_AddResource   (self,restype,resamount)
	RD_SupplyResource(self,restype,resamount)


	if (restype == "air") then --air
		self:SetColor(Color(0,165,255,255))
    	self.damagemultiplier = 0.5
    	self.volatility = 0
    elseif (restype == "coolant") then --coolant
		self:SetColor(Color(1,255,107,255))
    	self.damagemultiplier = 1
    	self.volatility = 5
    elseif (restype == "water") then --water
		self:SetColor(Color(0,0,255,255))
    	self.damagemultiplier = 2
    	self.volatility = 0
    elseif (restype == "heavy water") then --heavy water
		self:SetColor(Color(101,34,44,255))
    	self.damagemultiplier = 4
    	self.volatility = 5
    elseif (restype == "redterracrystal") then --Red Terra Crystal
		self:SetColor(Color(255,0,0,255))
    	self.damagemultiplier = 5
    	self.volatility = 10
    elseif (restype == "oil") then --Red Terra Crystal
		self:SetColor(Color(255,0,0,255))
    	self.damagemultiplier = 5
    	self.volatility = 10
    elseif (restype == "greenterracrystal") then --Green Terra Crystal
		self:SetColor(Color(0,255,0,255))
    	self.damagemultiplier = 7
    	self.volatility = 15
    elseif (restype == "terrajuice") then --Terrajuice
		self:SetColor(Color(0,0,0,255))
    	self.damagemultiplier = 12
    	self.volatility = 25
    elseif (restype == "darkmatter") then --The unseen stuff of the universe
		self:SetMaterial("models/dog/eyeglass")
    	self.damagemultiplier = 25
    	self.volatility = 75
    elseif (restype == "ammo_basic") then --CDS Ammo
		self:SetColor(Color(125,255,55,255))
    	self.damagemultiplier = 5
    	self.volatility = 25
    elseif (restype == "ammo_explosion") then --CDS Ammo
		self:SetColor(Color(125,255,55,255))
    	self.damagemultiplier = 10
    	self.volatility = 45
    elseif (restype == "ammo_fuel") then --CDS Ammo
		self:SetColor(Color(125,255,55,255))
    	self.damagemultiplier = 8
    	self.volatility = 35
    elseif (restype == "ammo_pierce") then --CDS Ammo
		self:SetColor(Color(125,255,55,255))
    	self.damagemultiplier = 6
    	self.volatility = 15
    else --energy and unknown types
		self:SetColor(Color(255,255,255,255))
    	self.damagemultiplier = 0.5
    	self.volatility = 10
    end
    
    -- The more explosive the loads, the more reinforced the crates are, naturally
    self:SetHealth(self.resourceamount * (self.damagemultiplier / 5))
    self.health = self.resourceamount * (self.damagemultiplier / 5) + CDSFudgeFix
    self.maxhealth = self.resourceamount * (self.damagemultiplier / 5) + CDSFudgeFix
	
	--larger loads are heavier
	local phys = self:GetPhysicsObject()
	if ( phys:IsValid() ) then 
		phys:SetMass((resamount * self.damagemultiplier)/10)
		phys:Wake()
	end
	
	self:NextThink( CurTime() + 1)
 	self:SetNetworkedString("DisplayText1", self.resourcetype)
 	self:SetNetworkedString("DisplayText2", self.resourceamount.." Units")

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
		local effectdata = EffectData()
			effectdata:SetStart	(self:GetPos())
			effectdata:SetOrigin(dmginfo:GetAttacker():GetPos()+   Vector(math.Rand(-50,50),math.Rand(-50,50),0))
			effectdata:SetEntity(self)
			effectdata:SetAttachment( 1 )
		util.Effect	( "rts_zap", effectdata ) 
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
	
	--Error((self.health-CDSFudgeFix)..", damage: "..dmginfo:GetDamage()..", mod:"..DamageMod.."\n")
	self:HealthCheck(ExplodeMod)

end

function ENT:HealthCheck(ExplodeMod)
	if self.health <= CDSFudgeFix then
		-- EXPLODE! KABLOOIE!
		--rts_Explosion(damage, piercing, area, position, killcredit)
		rts_Explosion( self.resourceamount * self.damagemultiplier / 20 * ExplodeMod,2 + self.damagemultiplier + (ExplodeMod * 10) , self.resourceamount * self.damagemultiplier / 10 * ExplodeMod,self:GetPos()+  self:GetUp() * 25,self.Activator)
		self:Remove()
	end
end


function ENT:Think()
	self:HealthCheck(1)
 	
	self:NextThink( CurTime() + 1)
	return true
 end
 
 
function Sol_Fade_Percent(starttime,endtime, currenttime)
	local temp = 0
	temp = (currenttime - starttime) / (endtime - starttime)
	return temp
end