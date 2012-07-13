-- Combat Damage Systems: Conflict
-- By: Solthar
-- 
-- Base Missile

AddCSLuaFile( "shared.lua" )
include('shared.lua')

local sMissileSmall = "models/weapons/W_missile_launch.mdl"
local sMissileLarge = "models/weapons/W_missile_closed.mdl"

function ENT:Initialize()   
	self:DefaultSetup()
end

-- Missile Ran out of fuel
function ENT:OnSelfDetonate()
	self:OnExplode()
end

-- Missile hit something
function ENT:OnExplode()
	--cds_explosion(self:GetPos(),150,50,20,false,nil)
	CDS.Explosion(self, 300, 75, 45, self.OwnedByENT, false, 1.5)
	--CDS.Explosion(self, 128, 200, 20, ply, true)
	local Effect = EffectData()
	Effect:SetOrigin(self:GetPos())
	Effect:SetStart( Vector(0,0,0) ) --Needed for cinematic explosion
	Effect:SetScale(300/(4/1.5)) --Will make the explosion look bigger/smaller too in the effects!
	Effect:SetMagnitude(math.random(1, 2))
	util.Effect("cds_explode", Effect, true, true)
end

-- Missile Hit something
function ENT:PhysicsCollide( data, physobj )
	self:OnExplode()
	self.Entity:Remove()
end

-- A default missile setup function, for lazy people
function ENT:DefaultSetup()
	self:SetupMissile()
	self:SetupVelocity (350, 500, 3)
	self:IsMirv(false)
	self:IsTracking(false)
	self:LaunchMissile()
end

-- Every argument in this function is optional
-- But the function itself isn't :-P
-- Setup the look of the missile
function ENT:SetupMissile (sMissileName,fExplodeDistance,bGravity,iMass)
	-- Allow people to define the look of the missile
	if (sMissileName == nil) then
		self.model = sMissileSmall
	else
		self.model = sMissileName
	end
	
	if (fExplodeDistance == nil) then
		self.TriggerDist = 100
	else
		self.TriggerDist = fExplodeDistance
	end
	
	self.Entity:SetModel( self.model ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   	
	self.Entity:SetSolid( SOLID_VPHYSICS )        	
	self.Entity:SetNotSolid(true)
	self.Entity:GetPhysicsObject():EnableDrag( false)
	
	if not (iMass == nil) then
		self.Entity:GetPhysicsObject():SetMass(iMass)
	end
	
	
	
	--local effectdata = EffectData()  
	--effectdata:SetEntity( self )			--Entity to smoketrail
	--effectdata:SetOrigin( self:GetPos() )	--Position of the emitter
	--effectdata:SetScale( 5 )				--Size of the particles
	--effectdata:SetMagnitude( 0.25 )			--Lifespan
	---effectdata:SetStart(Vector(255,205,215))--Color
	--util.Effect( "cds_smoke_trail", effectdata ) 
	
	if (bGravity == nil) then
		self.Entity:GetPhysicsObject():EnableGravity( false ) 
	else
		self.Entity:GetPhysicsObject():EnableGravity( bGravity ) 
	end
end
function ENT:AddTrail(R,G,B,A)
	self.Entity.Trail = util.SpriteTrail(self.Entity, 0, Color(R,G,B,A), false, 10, 0, 1, 0.125, "trails/laser.vmt")
end
function ENT:SetupVelocity(fInitialVelocity, fAcceleration, fLifeSpan)
	self.InitialVelocity	=	fInitialVelocity		-- Velocity the missile starts out at
	self.Velocity			=	self.InitialVelocity	-- Velocity always starts out at initial velocity
	self.Acceleration		= 	fAcceleration			-- Acceleration per second
	self.LifeSpan			=   fLifeSpan + math.Rand(fLifeSpan/10*-1,fLifeSpan/10)			-- How long does the missile last for until self detonating (in seconds)
																							-- add some randomness so mirvs don't detonate at the same time
end

function ENT:IsMirv( bMirv, fMirvTime, iMirvNumSpawn, fMirvAngleOffset,sMirvEntName)
	if (bMirv == false) then
		self.MIRV			= 	false				-- this is NOT a mirv!
	else
		self.MIRV			=	true				-- this IS a mirv!
		self.MIRV_Time 		= 	fMirvTime			-- Time, in seconds, until the missile seperates.
		self.MIRV_Count 	=	math.Max(iMirvNumSpawn or 0,2)		-- How many missiles to spawn?
		self.MIRV_Offset	=	fMirvAngleOffset	-- deviation from current flightpath, in degrees
		self.MIRV_EntName	=	sMirvEntName		-- entity name of the missile to spawn
		
	end
end

function ENT:IsTracking(bTracking, fTrackSpeed)
	if (bTracking == true) then
		self.Tracking 		= 	true				-- the missile tracks 
		self.Target			=	nil					-- The target the missile tracks
		self.TrackingSpeed	=	fTrackSpeed			-- how fast the missile turns toward it's target
	else
		self.Tracking 		= 	false				-- the missile is a dumbfire Rocket 
		self.Target			=	nil					-- The target the missile tracks
		self.TrackingSpeed	=	25					-- how fast the missile turns toward it's target
	end
end

function ENT:SetTrackingTarget(eEntity)
	self.Target				= 	eEntity				-- Sets the target the missile is tracking.
end

function ENT:LaunchMissile()
	if (self.Velocity > 0 ) then
		self.Entity:GetPhysicsObject():SetVelocity(self.Entity:GetForward() * self.Velocity) -- Set the velocity to the current velocity
	end
	
	self.LaunchedAt	= CurTime()
	self.DieAt		= CurTime() + self.LifeSpan
	if self.MIRV then
		self.MIRVat	= CurTime() + self.MIRV_Time
	end
	if (self.LaunchAngle == nil ) then
		self.LaunchAngle = self.Entity:GetAngles()
	end
	self.IsOnline = true	-- Start Thinking!
end

-- Orients the missile towards the supplied angle
function ENT:OrientTowardsTarget(vTargetAngle)
	local angEnt = self.Entity:GetAngles()
	
	angEnt.p = math.ApproachAngle(angEnt.p, vTargetAngle.p,self.TrackingSpeed * self.ThinkTime)
	angEnt.y = math.ApproachAngle(angEnt.y, vTargetAngle.y,self.TrackingSpeed * self.ThinkTime)
	angEnt.r = math.ApproachAngle(angEnt.r, vTargetAngle.r,self.TrackingSpeed * self.ThinkTime)
	
	self.Entity:SetAngles(angEnt)
end

function ENT:InitializeMIRV()
	local x = 0
	local y = 0
	local AngMod = 360 / self.MIRV_Count
	local aTempAng
	local lList = {}
	local RandAng = math.random(360)
	
	for i=1,self.MIRV_Count do
		aTempAng = self.Entity:GetAngles()
		aTempAng.p = aTempAng.p + math.sin( math.rad(i*AngMod+RandAng) )  * self.MIRV_Offset
		aTempAng.y = aTempAng.y + math.cos( math.rad(i*AngMod+RandAng) )  * self.MIRV_Offset
		aTempAng.r = aTempAng.r
		
		lList[i] = ents.Create(self.MIRV_EntName)
		lList[i]:SetPos( self.Entity:GetPos() )
		lList[i]:SetAngles			(aTempAng)
		lList[i]:Spawn()
		lList[i]:Activate	()
		lList[i]:SetTrackingTarget(self.Target)
		lList[i].LaunchAngle = self.Entity:GetAngles()
	end
	
	self.Entity:Remove()
end

function ENT:Think()
	if (self.ThinkTime == nil) then 
		self.ThinkTime = 0.1 
	end
	
	if not (self.IsOnline == nil) then
		if (CurTime() > (self.LaunchedAt +0.25)) then
			self.Entity:SetNotSolid(false)
		end
	
		--only do stuff if it's been setup
		if self.Tracking then
			if ValidEntity(self.Target) then
				self:OrientTowardsTarget((self.Target:GetPos() - self.Entity:GetPos()):Normalize():Angle())					-- Point at the target if we're tracking a valid entity
			else
				self:OrientTowardsTarget(self.LaunchAngle)	
			end
		else
			self:OrientTowardsTarget(self.LaunchAngle)	
		end
		-- Accelerate the missile!
		self.Velocity = self.Velocity +  self.Acceleration * self.ThinkTime
		self.Entity:GetPhysicsObject():SetVelocity(self.Entity:GetForward() * self.Velocity)
		
		-- Death / MIRV Checks
		if (CurTime() > self.DieAt) then		-- If the missile runs out of fuel
			self:OnExplode()
			self.Entity:Remove()
		elseif (self.MIRV) then					-- If the missile is set to MIRV
			if (CurTime() > self.MIRVat) then
				self:InitializeMIRV()
			end
		elseif ValidEntity(self.Target) then	-- If the missile is within exploding distance of the target
			if (( self.Entity:GetPos():Distance( self.Target:GetPos() ) ) < self.TriggerDist ) then
				self:OnExplode()
				self.Entity:Remove()
			end
		end
	end
	
	self.Entity:NextThink( CurTime() + self.ThinkTime)
	return true
end
 