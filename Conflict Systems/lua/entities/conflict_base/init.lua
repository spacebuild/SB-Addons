-- Combat Damage Systems: Conflict
-- By: Solthar
-- 
-- Base Weapon Pylon

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
include('cl_init.lua')

conflict.resource( "conflict_pylon_small", false)
conflict.resource( "conflict_small_laser", false)
conflict.resource( "conflict_default", true)

function ENT:Initialize()   
	self.ReloadTime	   	= 2.5			-- Time, in seconds, between shots fired
	self.ClipSize		= 3 			-- how many shots per clip?
	self.ClipReload     = 12            -- Time, in seconds, it takes to reload the primary clip
	self.TargetLockTime	= 5.5			-- Time it takes, in seconds, for the turret to aquire a new target
	self.Accuracy	   	= 0.5 			-- Accuracy of turret, maximum degree of deviation before it will autofire.  Usually want to keep this low.
	self.TrackingSpeed 	= 35			-- Tracking speed in degrees per second
	self.OptimumRange	= 300			-- Distance where the turret is most accurate
	self.FalloffRange	= 300			-- OptimumRange +/- FalloffRange = 50% added inaccuracy
	
	self:AddResource("energy",1)		-- use this amount of the defined resource per shot.
	--self:AddResource("coolant",10)		-- can be used multiple times to define multiple resources
	
	self:SetDisplayName ("Generic Weapon")	-- Display Name of the Weapon
	self:SetFlavourText ("Someone forgot to setup this ", "weapon properly. Default State.")
	
	--self:FireSound("Weapon_RPG.Single")


	--Setup the base class
	self:Setup()
	
	--Always add the turret AFTER the setup, only one per base.
	--Calling this function twice will overwrite the first call.
	--            (         Model Name               ,    Texture        ,Size)
	self:AddTurret( "models/conflict_small_laser.mdl", "conflict_default", 23 )
end

function ENT:FireSound(sSound)
	self.FireSound = sSound
end

function ENT:Setup()   
	self.model = "models/conflict_pylon_small.mdl" 
	self.Entity:SetMaterial("conflict_default")
	
	self.Entity:SetModel( self.model ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   	
	self.Entity:SetSolid( SOLID_VPHYSICS )        	

	-- The resources Get defined
	--RD_AddResource(self.Entity, "energy", 0)
	
	-- Variables
	self.Turret = nil
	
	self.Target			= nil			-- What entity is it tracking?
	self.TargetPlayer	= nil			-- What Player's ents does it want to shoot?
	
	self.IsConflictTurret = 1			--boolean, is this entity conflict linkage compatable?
	
	self.Active			= false			-- is it active? Does it have power?
	self.AttackMode		= false			-- does it have an order to attack the target?
	
	if (self.MaxFalloffDeviation == nil) then
		self.MaxFalloffDeviation = 25		-- maximum deviation from falloff, in degrees
	end

	self.NextAttack		= 0				-- When does the next attack become available?
	self.PauseUntil		= 0				-- how long to pause movement?
	self.PauseStart		= 0
	self.Deviation		= 360			-- Current Deviation of the turret
	self._deviation		= 0				-- falloff deviation of the turret
	
	self.OffsetX		= 0
	self.OffsetX_Ang	= 0
	self.OffsetX_Rad	= 0
	self.OffsetY		= 0
	self.OffsetY_Ang	= 0
	self.OffsetY_Rad	= 0
	self.Interval		= 0
	self._dist			= 0
	

	
	--self.ClipSize		= 10			-- how many shots per clip?
	self.CurrentClipSize = self.ClipSize
	--self.ClipReload     = self.ReloadTime * 3 --How long to change clips?
	
	if (self.DisplayName == nil) then
		self:SetDisplayName("Generic Weapon")
	end
	self.Entity:SetNetworkedInt("Range",( self.OptimumRange or 0))
	self.Entity:SetNetworkedInt("Falloff",( self.FalloffRange or 0))
	self.Entity:SetNetworkedInt("Tracking",( self.TrackingSpeed or 0))
	
	self.FirstTick = true
	
	
	
	self._Counter 		= 0

	-- Create a wire input to turn it on!
	if not (WireAddon == nil) then 
		self.WireDebugName = self.PrintName
		--self.Inputs = Wire_CreateInputs(self.Entity, { "Resource ID" })
		--self.Outputs = Wire_CreateOutputs( self.Entity, { "Resource ID" ,"Current", "Max","Percent"})	
	 end


	self:Startup()
	
	self.CurrentClipSize = self.ClipSize
	self.UseWait = 0
	self.UseOverlay = 0
	self.Entity:SetNetworkedInt("UseOverlay",self.UseOverlay)
end 
--Toggle the optimum range indicator on use
function ENT:Use( activator, caller )     
	if (self.UseWait <= CurTime()) then
	if (conflict.EntOwnedBy(self.Entity) == activator) then
		self.UseWait = CurTime() + 1.0	-- only allow one use per second
		if (self.UseOverlay == 0) then
			self.UseOverlay = 1
		--elseif (self.UseOverlay == 1) then
			--self.UseOverlay = 2
		else
			self.UseOverlay = 0
		end
		self.Entity:SetNetworkedInt("UseOverlay",self.UseOverlay)
	end
	MsgN("Tracking: ",self.Active,"\n")
	MsgN("Attacking: ",self.AttackMode,"\n")
	MsgN("TargetID: ",self.Target:EntIndex(),"\n")
	end
end    
function ENT:SetupOwnerID()
	self.OwnedByENT = conflict.EntOwnedBy(self.Entity)		-- different case for each, for now, so i know what the heck is going on
	if (self.OwnedByENT == nil) then
		self.Entity:SetNetworkedString("OwnedBy","Nil")
	elseif self.OwnedByENT:IsPlayer() then
		self.Entity:SetNetworkedString("OwnedBy",self.OwnedByENT:Nick())
	else
		self.Entity:SetNetworkedString("OwnedBy","Mingebag")
	end
end

--Sets the flavour text
function ENT:SetFlavourText(sLine1,sLine2)
	if not (sLine1 == nil) then self.Entity:SetNetworkedString("sFlavour1",sLine1) end
	if not (sLine2 == nil) then self.Entity:SetNetworkedString("sFlavour2",sLine2) end
end

function ENT:SetDisplayName(sName)
	if (sName == nil) then sName = "Generic Weapon" end
	self.DisplayName = sName
	self.Entity:SetNetworkedString("DisplayName",sName)
end

-- add a resource to the list
function ENT:AddResource(sName,iUsePerShot)
	if (self.ResourceList == nil) then
		self.ResourceList = {}
	end
	self.ResourceList[sName] = iUsePerShot
	RD_AddResource(self.Entity, sName, 0)
	
	local n = 0
	for k, v in pairs(self.ResourceList) do
		n = n + 1
		self.Entity:SetNetworkedString("ResourceName"..n,k)
		self.Entity:SetNetworkedString("ResourceValue"..n,v)
	end
	self.Entity:SetNetworkedInt("NumRes",table.Count(self.ResourceList))
end

--hook into the init function for children
function ENT:Startup()
end

-- called when the turret reloads
function ENT:OnReload()
end

--called when the turret attacks
function ENT:OnAttack()
	self:LaunchMissile("conflict_missile_dumbfire")
	--default action here. easily overridden
end

function ENT:CalcFalloff( fDistance)
	return conflict.falloff(fDistance,self.OptimumRange,self.FalloffRange)
end

--	
--																				Note to self: check to see if the target is visible! 
--
function ENT:FindTargetOwnedBy( ply)
	local EntList = ply:GetOwnedProps()

	local fDesirability
	local fDist = 0
	local fCurrent = 99999
	local eTarget  = nil
	for _, Ent in pairs(EntList) do
		if ValidEntity(Ent) then
			--local trace = {}  	  	
			--trace.start = self:GetPos()  	
			--trace.endpos = Ent:GetPos()
			--trace.filter = self.Turret
			--t = util.TraceLine( trace )
			fDist = self.Turret.Entity:GetPos():Distance(Ent:GetPos())
			if (math.abs(fDist-self.OptimumRange) < self.FalloffRange )	then-- only target things within the falloff range
				t = util.QuickTrace(self.Turret:GetPos(), (Ent:GetPos()-self.Turret:GetPos()):Normalize() * Ent:GetPos():Distance(self.Turret:GetPos())*1.25,  {self.Turret, self})
				if t.Entity == Ent then												-- if we have clear line of sight to the target
					fDesirability  =  self:CalcFalloff(fDist)
					if (fDesirability < fCurrent) then
						fCurrent = fDesirability
						eTarget = Ent
					end
				end
			end
		end
	end
	
	if (ValidEntity(eTarget)) then
		if not (self.Target == eTarget) then
--	 		self.PauseStart = CurTime()
--	 		self.PauseUntil = CurTime() + self.TargetLockTime
--	 		self.NextAttack = CurTime() + self.TargetLockTime
			self.Target = eTarget
			--MsgN("May the lamentations of your foes women and children woo you to sleep this night; target locked.")			-- yay for debugging text!
		end
	else
		--MsgN("Great sadness and woe: no targets found.\n")
		--no target found, so let's reload and try again
 		self.PauseStart = CurTime()
 		self.PauseUntil = CurTime() + self.TargetLockTime
 		self.NextAttack = CurTime() + self.TargetLockTime
	end
end

function ENT:LaunchMissile(sEntName)
		local Temp = ents.Create(sEntName)
		Temp:SetPos( self.Turret.Entity:GetPos() +self.Turret.Entity:GetForward()*20 )
		Temp:SetAngles			(self.Turret.Entity:GetAngles())
		Temp:Spawn()
		Temp:SetTrackingTarget(self.Target)
		Temp.OwnedByENT = self.OwnedByENT
		Temp:Activate	()
end


function ENT:TrackTarget( entTarget )
	self.Target = entTarget
end

function ENT:AddTurret( sModelName, sMaterial, fOffset )
	self.Turret = ents.Create("prop_physics")
	self.Turret.model = sModelName
	self.Turret:SetModel( sModelName )
	self.Turret:SetPos				( self.Entity:GetPos() +  self.Entity:GetUp() * fOffset	)
	self.Turret:SetAngles			( self.Entity:GetAngles() 							)
	self.Turret:Spawn				()
	self.Turret:GetPhysicsObject	():EnableGravity( false ) 
	self.Turret:SetParent			(self.Entity)
	self.Turret:SetMaterial(sMaterial)
	self.Turret:DrawShadow( false)
	self.Turret:SetNotSolid(true)
	self.Turret:Activate			()
	
	self.Entity:SetNetworkedInt("TurretID",self.Turret:EntIndex())	--setup the turrets id so we can actively track it clientside
end


--An easy to use trace from the weapon
function ENT:TargetTrace()
	return self.targetTrace 
end


--Checks to see if the target is valid (can see it, and it still exists)
function ENT:CheckTarget()
	if not (ValidEntity(self.Target)) then						-- if the target is not valid
		if (self.TargetPlayer:IsPlayer()) then					-- If the targetplayer IS a player :-P
			self:FindTargetOwnedBy(self.TargetPlayer)			-- find a new target owned by them
		else
			self.TargetPlayer = nil
			self.Target = nil
			self.Active = false
			self.AttackMode = false
		end
	else
		-- Default the bGood Value to true
		local bGood = true

		if self.targetTrace.HitWorld then														-- if it hit the world its most likely blocked
			self:FindTargetOwnedBy(self.TargetPlayer)											-- so find a new one
		elseif ValidEntity(self.targetTrace.Entity) then 										-- if the trace hit a valid entity...
			
			if (conflict.EntOwnedBy(self.targetTrace.Entity) == conflict.EntOwnedBy(self)) then	-- compare the turrets owner and the traces entity's owner.
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
				-- and set bGood to false if they match						----- Debug: Disabled so i can target my own props!								-----
				--bGood = false												----- Uncomment this line to set to normal behavior.							-----
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
			elseif not (conflict.EntOwnedBy(self.targetTrace.Entity) == self.TargetPlayer) then	-- if the weapon is pointing at someones prop that isn't targetted
																								-- find a new target
				self:FindTargetOwnedBy(self.TargetPlayer)			-- find a new target owned by the target
			end
		end
		
		if not bGood then
			self:FindTargetOwnedBy(self.TargetPlayer)
		end
	end
end

function ENT:Think()
	if (self.FirstTick) then
		self.FistTick = false
		self:SetupOwnerID()
	end

	-- if the device is active
	if ((self.Active) and not (self.Turret == nil)) then
		if not (self.Target == nil) then
			--self:FindTargetOwnedBy( self.TargetPlayer)
			if (ValidEntity(self.Target)) then
				local angEnt = self.Turret.Entity:GetAngles()
				local angTarget = (self.Target:GetPos() - self.Turret.Entity:GetPos()):Normalize():Angle()
				
				if ((!self.AttackMode) or (self.PauseUntil < CurTime())) then
					angEnt.p = math.ApproachAngle(angEnt.p, angTarget.p,self.TrackingSpeed * 0.05)
					angEnt.y = math.ApproachAngle(angEnt.y, angTarget.y,self.TrackingSpeed * 0.05)
					angEnt.r = math.ApproachAngle(angEnt.r, self.Entity:GetAngles().r,self.TrackingSpeed * 0.05)
					
					self.Turret.Entity:SetAngles(angEnt)
				end
			
				-- If we're attacking
				if (self.AttackMode) then
					if (self.NextAttack < CurTime()) then
					
						self.Deviation = math.abs(math.AngleDifference(self.Turret.Entity:GetAngles().p,angTarget.p)) + math.abs(math.AngleDifference(self.Turret.Entity:GetAngles().y,angTarget.y))
						if (self.Deviation <= (self.Accuracy + self._deviation)) then
							
							self.targetTrace = util.QuickTrace( self.Turret:GetPos() + self.Turret.Entity:GetForward() * 10 , self.Turret.Entity:GetPos() + self.Turret.Entity:GetForward() * 30000, self.Turret) 
							self:CheckTarget()		-- Check to make sure we have a valid target!
	
							math.randomseed(CurTime())  --Getting tired of the random repeating, so lets generate a new seed every time we fire
							self._dist = self.Turret.Entity:GetPos():Distance(self.Target:GetPos())
							local lFalloffDeviation = self:CalcFalloff(self._dist) * self.MaxFalloffDeviation
							local lOldAngle = self.Turret.Entity:GetAngles()
							local lOne = math.Rand(lFalloffDeviation/-2,lFalloffDeviation/2)
							local lTwo = math.Rand(lFalloffDeviation/-2,lFalloffDeviation/2)
							
							
							self.Turret:SetAngles(Angle(lOldAngle.p+lOne,lOldAngle.y+lTwo,lOldAngle.r))
							
							self.targetTrace = util.QuickTrace( self.Turret:GetPos() + self.Turret.Entity:GetForward() * 20 , self.Turret.Entity:GetPos()  + self.Turret.Entity:GetForward() * 20020, self.Turret) 
							-- This is the user defined attack function
							if not (self.FireSound == nil) then
								--WorldSound( self.FireSound, self:GetPos())
								self.Entity:EmitSound( self.FireSound ) 
							end
							self:OnAttack()	
							
							self.Turret:SetAngles(lOldAngle)
							
							
							-- We fired, so remove one round from the clip
							self.CurrentClipSize = self.CurrentClipSize - 1
							
							if (self.CurrentClipSize <= 0) then 
								--We ran out of ammo in our clip, so use that to calculate inactive time
								self.CurrentClipSize = self.ClipSize
								self.NextAttack = CurTime() + self.ClipReload  
								self.PauseUntil = CurTime() + self.ClipReload * 0.75
								self.PauseStart = CurTime()
								self:OnReload()
								if (self.TargetPlayer:IsPlayer()) then
									self:FindTargetOwnedBy(self.TargetPlayer)
								else
									self.TargetPlayer = nil
									self.Target = nil
									self.Active = false
								end
							else
								--We're loading the next round from the clip...
								self.NextAttack = CurTime() + self.ReloadTime
								self.PauseUntil = CurTime() + self.ReloadTime / 3
								self.PauseStart = CurTime()
								
								
							end
						end
					end
				end
			end
		end
	end
 	
	
	--run at 20fps 
	--if anyone has a better idea how to make it move smoothly without the high thinktime, i'm open to ideas
	--just msg me on steam (Solthar) :-)
	self.Entity:NextThink( CurTime() + 0.05)
	return true
 end
 