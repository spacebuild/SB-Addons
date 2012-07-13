
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

if not (WireMod == nil) then
	ENT.WireDebugName = "Methane Thruster"
end

local Thruster_Sound 	= Sound( "PhysicsCannister.ThrusterLoop" )

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self:DrawShadow( false )
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	--Resource settings
	self.methanecon = 0
	self.methanediv = 170
	self.thrustmult = 10
	
	RD_AddResource(self, "methane", 0)
	
	local max = self:OBBMaxs()
	local min = self:OBBMins()
	
	self.ThrustOffset 	= Vector( 0, 0, max.z )
	self.ThrustOffsetR 	= Vector( 0, 0, min.z )
	self.ForceAngle		= self.ThrustOffset:GetNormalized() * -1
	
	self:SetForce( 2000 )
	
	self.OWEffect = "fire"
	self.UWEffect = "same"
	
	self:SetOffset( self.ThrustOffset )
	self:StartMotionController()
	self.outputon = 0
	
	self:Switch( false )

	self.Inputs = Wire_CreateInputs(self, { "On" })
	self.Outputs = Wire_CreateOutputs(self, { "On", "Methane Consumption" })
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	
    if (self.EnableSound) then
		self:StopSound(Thruster_Sound)
	end
end

function ENT:SetForce( force, mul )
	if (force) then
		self.force = force
		self:NetSetForce( force )
	end
	mul = mul or 1
	
	local phys = self:GetPhysicsObject()
	if (!phys:IsValid()) then
		Msg("Warning: [methane_thruster] Physics object isn't valid!\n")
		return
	end

	--Get the data in worldspace
	local ThrusterWorldPos = phys:LocalToWorld( self.ThrustOffset )
	local ThrusterWorldForce = phys:LocalToWorldVector( self.ThrustOffset * -1 )

	-- Calculate the velocity
	ThrusterWorldForce = ThrusterWorldForce * self.force * mul * 10
	self.ForceLinear, self.ForceAngle = phys:CalculateVelocityOffset( ThrusterWorldForce, ThrusterWorldPos );
	self.ForceLinear = phys:WorldToLocalVector( self.ForceLinear )
	
	if ( mul > 0 ) then
		self:SetOffset( self.ThrustOffset )
	else
		self:SetOffset( self.ThrustOffsetR )
	end
end

function ENT:Setup(force, force_min, force_max, oweffect, uweffect, owater, uwater, bidir, sound)
	self:SetForce(force)
	
	self.OWEffect = oweffect
	self.UWEffect = uweffect
	self.ForceMin = force_min
	self.ForceMax = force_max
	self.BiDir = bidir
	self.EnableSound = sound
	self.OWater = owater
	self.UWater = uwater
	
	self:SetEffect( self.OWEffect ) 
	
	if (not sound) then
		self:StopSound(Thruster_Sound)
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		if ( (self.BiDir) and (math.abs(value) > 0.01) and (math.abs(value) > self.ForceMin) ) or ( (value > 0.01) and (value > self.ForceMin) ) then
			self:Switch(true, math.min(value, self.ForceMax))
		else
			self:Switch(false, 0)
		end
	end
end

function ENT:PhysicsSimulate( phys, deltatime )
	if (!self:IsOn()) then return SIM_NOTHING end
	
	if (!self:CanRun()) then
		self:Switch( false )
	end
	
	if (self:WaterLevel() > 0) then
	    if (not self.UWater) then
	    	self:SetEffect("none")
			return SIM_NOTHING
		end
		
		if (self.UWEffect == "same") then
	    	self:SetEffect(self.OWEffect)
		else
	    	self:SetEffect(self.UWEffect)
		end
	else
	    if (not self.OWater) then
	    	self:SetEffect("none")
			return SIM_NOTHING
		end
		
	    self:SetEffect(self.OWEffect)
	end
	
	local ForceAngle, ForceLinear = self.ForceAngle, self.ForceLinear
	
	return ForceAngle, ForceLinear, SIM_LOCAL_ACCELERATION
end

function ENT:Switch( on, mul )
	if (!self:IsValid()) then return false end
	
	local changed = (self:IsOn() ~= on)
	self:SetOn( on )
	
	
	if (on) then 
	    if (changed) and (self.EnableSound) then
			self:StopSound( Thruster_Sound )
			self:EmitSound( Thruster_Sound )
		end
		
		self:NetSetMul( mul )
		
		self:SetForce( nil, mul )
	else
	    if (self.EnableSound) then
			self:StopSound( Thruster_Sound )
		end
	end
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	return true
end

function ENT:CanRun()
	local methane = RD_GetResourceAmount(self, "methane")	
	
	if (methane >= self.methanecon) then
		return true
	else
		return false
	end
end

 function ENT:Think()
	self.BaseClass.Think(self)
	self.methanecon = math.abs(math.ceil(self.force/self.methanediv))

	if (self:IsOn() and self:CanRun()) then
		RD_ConsumeResource(self, "methane", self.methanecon)
		self.outputon = 1
	else
		self:Switch( false )
		self.outputon = 0
	end
	
	if not (WireAddon == nil) then
		Wire_TriggerOutput(self, "Methane Consumption", self.methanecon)
		Wire_TriggerOutput(self, "On", self.outputon )
	end
	
	self:UpdateTextOutput()

	self:NextThink(CurTime() + 1)
	return true
end

function ENT:UpdateTextOutput()
	local methane = RD_GetResourceAmount(self, "methane")
	
	self:SetNetworkedInt( 8, methane)
end

function ENT:OnRestore()
	local phys = self:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	local max = self:OBBMaxs()
	local min = self:OBBMins()
	
	self.ThrustOffset 	= Vector( 0, 0, max.z )
	self.ThrustOffsetR 	= Vector( 0, 0, min.z )
	self.ForceAngle		= self.ThrustOffset:GetNormalized() * -1
	
	self:SetOffset( self.ThrustOffset )
	self:StartMotionController()
	
	if (self.PrevOutput) then
		self:Switch(true, self.PrevOutput)
	else
		self:Switch(false)
	end
	
    self.BaseClass.OnRestore(self)
end

--Duplicator stuff 
function ENT:PreEntityCopy()
    self.BaseClass.PreEntityCopy(self)
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
    self.BaseClass.PostEntityPaste(self, Player, Ent, CreatedEntities )
end
