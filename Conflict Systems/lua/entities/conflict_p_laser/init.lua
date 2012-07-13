include("shared.lua");
AddCSLuaFile("shared.lua");

-- ----- --- ----- -- ----- --- ----- -- ----- --- ----- -- ----- --- ----- -- ----- --- ----- -- ----- --- ----- --
-- Turret's Initialization Function: Define common variables here.                                                --
-- ----- --- ----- -- ----- --- ----- -- ----- --- ----- -- ----- --- ----- -- ----- --- ----- -- ----- --- ----- --
function ENT:Initialize()   

	self:SetDisplayName ("Small Pulse Laser")	-- Display Name of the Weapon
	self:SetFlavourText ("Low power requirements have made ", "this a standard weapon in most ships.")
	self:FireSound("sound\weapons\stunstick\spark1.wav")
	
	self.ReloadTime	   	= 1.2			-- Time, in seconds, between shots fired
	self.ClipSize		= 10			-- how many shots per clip?
	self.ClipReload     = 5             -- Time, in seconds, it takes to reload the primary clip
	self.TargetLockTime	= 5.5			-- Time it takes, in seconds, for the turret to aquire a new target
	self.Accuracy	   	= 0.5 			-- Accuracy of turret, maximum degree of deviation before it will autofire.  Usually want to keep this low.
	self.TrackingSpeed 	= 35			-- Tracking speed in degrees per second
	self.OptimumRange	= 3000			-- Distance where the turret is most accurate
	self.FalloffRange	= 3000			-- OptimumRange +/- FalloffRange = 50% added inaccuracy
	
	self:AddResource("energy",50)		-- use this amount of the defined resource per shot.
	--self:AddResource("coolant",10)	-- can be used multiple times to define multiple resources

	--Setup the base class
	self:Setup()
	
	--Always add the turret AFTER the setup, only one per base.
	--Calling this function twice will overwrite the first call.
	--            (         Model Name               ,    Texture        ,Size)
	self:AddTurret( "models/conflict_small_laser.mdl", "conflict_default", 23 )
--	self:AddTurret( "models/props_wasteland/laundry_washer003.mdl", "conflict_default", 43 )
end

-- ----- --- ----- -- ----- --- ----- -- ----- --- ----- -- ----- --- ----- -- ----- --- ----- -- ----- --- ----- --
-- OnAttack(): Called every time the weapon fires.                                                                --
-- ----- --- ----- -- ----- --- ----- -- ----- --- ----- -- ----- --- ----- -- ----- --- ----- -- ----- --- ----- --
function ENT:OnAttack()
	--Draw a line from the weapon to wherever we hit
	local traceRes = self:TargetTrace()
	local target = self.Turret.Entity:GetPos() + self.Turret.Entity:GetForward() * 30000
	if traceRes.Hit then target = traceRes.HitPos end
	
	--Included easily configurable laser effect
	local effectdata = EffectData()
	effectdata:SetStart( self.Turret.Entity:GetPos() + self.Turret.Entity:GetForward() * 25 +self.Turret.Entity:GetRight()*-0.7)		--Source
	effectdata:SetOrigin( target)																										--Target
	effectdata:SetMagnitude(1.1)																										--How long the beam lasts (conflict_laser only)
	effectdata:SetScale(35)																												--How thick the beam is
	effectdata:SetAngle(Angle(80, 150, 3))																								--Color of the beam (R, G, B)
	util.Effect( "conflict_laser", effectdata )																							--Pulse laser (starwarsy laser effect)
	--util.Effect( "conflict_pulse", effectdata )																							--Pulse laser (starwarsy laser effect)
	

end

-- ----- --- ----- -- ----- --- ----- -- ----- --- ----- -- ----- --- ----- -- ----- --- ----- -- ----- --- ----- --
-- OnReload(): Called every time the weapon reloads it's clip                                                     --
-- ----- --- ----- -- ----- --- ----- -- ----- --- ----- -- ----- --- ----- -- ----- --- ----- -- ----- --- ----- --
function ENT:OnReload()
end
