
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

if not (WireMod == nil) then
	ENT.WireDebugName = "Powered Thruster"
end

local Thruster_Sound 	= Sound( "PhysicsCannister.ThrusterLoop" )

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self:DrawShadow( false )
	
	self.phys = self:GetPhysicsObject()
	if (self.phys:IsValid()) then
		self.phys:Wake()
	end
	
	--Entity Settings
	self.Effect = "fire"
	self.resource = "energy"
	self.consumption = 0
	self.active = 0
	self.massed = true
	self.force = 0
	self.multiplier = 0
	self.toggle = 0
	self.togon = false
	
	local max = self:OBBMaxs()
	local min = self:OBBMins()
	
	self.ThrustOffset 	= Vector( 0, 0, max.z )
	self.ThrustOffsetR 	= Vector( 0, 0, min.z )
	self.ForceAngle		= self.ThrustOffset:GetNormalized() * -1
	
	self:SetForce( 2000 )
	self:SetOffset( self.ThrustOffset )
	self:StartMotionController()
	self.outputon = 0
	
	self:Switch( false )

	self.Inputs = Wire_CreateInputs(self, { "On" })
	self.Outputs = Wire_CreateOutputs(self, { "On", "Consumption" })
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	
    if (self.EnableSound) then
		self:StopSound(Thruster_Sound)
	end
end

function ENT:SetForce( force, mul )
	if (force) then
		self:NetSetForce( force )
	end
	mul = mul or 1
	self.consumption = math.abs(((force/100)*mul+5)*(self.multiplier))
	
	local phys = self:GetPhysicsObject()
	if (!phys:IsValid()) then
		Msg("Warning: [gas_thruster] Physics object isn't valid!\n")
		return
	end

	--Get the data in worldspace
	local ThrusterWorldPos = phys:LocalToWorld( self.ThrustOffset )
	local ThrusterWorldForce = phys:LocalToWorldVector( self.ThrustOffset * -1 )

	-- Calculate the velocity
	ThrusterWorldForce = ThrusterWorldForce * force * mul * (self.multiplier + 25)
	self.ForceLinear, self.ForceAngle = phys:CalculateVelocityOffset( ThrusterWorldForce, ThrusterWorldPos );
	self.ForceLinear = phys:WorldToLocalVector( self.ForceLinear )
	
	if ( mul > 0 ) then
		self:SetOffset( self.ThrustOffset )
	else
		self:SetOffset( self.ThrustOffsetR )
	end
end

function ENT:Setup(force, multiplier, force_min, force_max, effect, bidir, sound, massless, resource, key, key_bk, pl, toggle)
	self.force = force
	self.toggle = toggle
	self.multiplier = multiplier
	self:SetForce(force)
	self.resource = resource
	RD_AddResource(self,self.resource,0)
	
	self.Effect = effect
	self.ForceMin = force_min
	self.ForceMax = force_max
	self.BiDir = bidir
	self.EnableSound = sound
	
	self:SetEffect( self.Effect ) 
	
	if (not sound) then
		self:StopSound(Thruster_Sound)
	end
	if (massless) then
		if self.phys:IsValid() then
			self.phys:EnableGravity(false)
			self.phys:EnableDrag(false)
			self.phys:Wake()
			self.massed = false
		end
	else
		if self.phys:IsValid() then
			self.phys:EnableGravity(true)
			self.phys:EnableDrag(false)
			self.phys:Wake()
			self.massed = true
		end
	end
	
	numpad.OnDown(pl, key, "gas_thruster_on", self, 1)
	numpad.OnUp(pl, key, "gas_thruster_off", self, 1)

	numpad.OnDown(pl, key_bk, "gas_thruster_on", self, -1)
	numpad.OnUp(pl, key_bk, "gas_thruster_off", self, -1)
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		if ( (self.BiDir) and (math.abs(value) > 0.01) and (math.abs(value) > self.ForceMin) ) or ( (value > 0.01) and (value > self.ForceMin) ) then
			self:Switch(true, value)
		else
			self:Switch(false, 0)
		end
	end
end

function ENT:PhysicsSimulate( phys, deltatime )
	if (!self:IsOn()) then return SIM_NOTHING end

	self:SetEffect(self.Effect)
	
	if(self.massed == true) then
			self.phys:EnableGravity(false)
			self.phys:EnableDrag(false)
	end
	
	local ForceAngle, ForceLinear = self.ForceAngle, self.ForceLinear
	return ForceAngle, ForceLinear, SIM_LOCAL_ACCELERATION
end

function ENT:Switch( on, mul )
	if (!self:IsValid()) then return false end
	local changed = (self:IsOn() ~= on)
	local togchange = (self.togon ~= on)
	if (self.toggle==1) then
		if (togchange) and (on) then
			on = false
		end
	end
		
	if (on) then
		if (self:CanRun()) then
			self:SetOn( true )
			self:SetOOO(1)
		   if (changed) and (self.EnableSound) then
				self:StopSound( Thruster_Sound )
				self:EmitSound( Thruster_Sound )
			end
			
			self:NetSetMul( mul )
			
			self:SetForce( self.force, mul )
		else
			self:SetOn( false )
		end
	else
		self:SetOn(false)
		self:SetOOO(0)
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
	local resource = RD_GetResourceAmount(self, self.resource)	
	if (resource >= self.consumption) then
		return true
	else
		return false
	end
end

function ENT:Think()
	self.BaseClass.Think(self)

	if (self:IsOn() and self:CanRun()) then
		RD_ConsumeResource(self, self.resource, self.consumption)
		self.outputon = 1
	else
		self:Switch( false )
		self.outputon = 0
	end
	
	if not (WireAddon == nil) then
		Wire_TriggerOutput(self, "Consumption", self.consumption)
		Wire_TriggerOutput(self, "On", self.outputon )
	end
	
	self:ShowOutput()

	self:NextThink(CurTime() + 1)
	return true
end

function ENT:ShowOutput()
	self:SetNetworkedInt( 1, self.consumption or 0)
	self:SetNetworkedString( 2, self.resource or "energy" )
	self:SetNetworkedInt( 3, self.force or 0 )
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

numpad.Register("gas_thruster_on", function(pl, ent, mul)
	if not ent:IsValid() then return false end
	ent:Switch(true, mul)
	return true
end)

numpad.Register("gas_thruster_off", function(pl, ent, mul)
	if not ent:IsValid() then return false end
		if (ent.toggle==1) then
			self.togon=false
		else
			ent:Switch(false, mul)
		end
	return true
end)
