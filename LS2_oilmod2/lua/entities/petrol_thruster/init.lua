AddCSLuaFile( "cl_init.lua" ) 
 AddCSLuaFile( "shared.lua" ) 
   
 include('shared.lua') 
   
 CreateConVar( "sv_petrolthrustermult", "1000" ) 
 
 local Thruster_Sound 	= Sound( "PhysicsCannister.ThrusterLoop" ) 
   
   
 /*--------------------------------------------------------- 
    Name: Initialize 
 ---------------------------------------------------------*/ 
 function ENT:Initialize() 
 
 	self:PhysicsInit( SOLID_VPHYSICS ) 
 	self:SetMoveType( MOVETYPE_VPHYSICS ) 
 	self:SetSolid( SOLID_VPHYSICS ) 
 	 
 	local phys = self:GetPhysicsObject() 
 	if (phys:IsValid()) then 
 		phys:Wake() 
 	end 
	
	RD_AddResource(self, "Petrol", 0)
	RD_AddResource(self, "12V Energy", 0)
	if not (WireAddon == nil) then 
		self.Outputs = Wire_CreateOutputs(self, { "Consume rate" })
		self.Inputs = Wire_CreateInputs(self, { "On" })
	end
	self.petrolpertick = 0
 	 
 	local max = self:OBBMaxs() 
 	local min = self:OBBMins() 
	
	self:NextThink( CurTime() ) 
 	 
 	self.ThrustOffset 	= Vector( 0, 0, max.z ) 
 	self.ThrustOffsetR 	= Vector( 0, 0, min.z ) 
 	self.ForceAngle		= self.ThrustOffset:GetNormalized() * -1 
 	 
 	self:SetForce( 2000 ) 
 	self:SetEffect( "Fire" ) 
   
 	self:SetOffset( self.ThrustOffset ) 
 	self:StartMotionController() 
 	 
 	self:Switch( false ) 
 	self.ActivateOnDamage = true 
 	 
 end 
   
   
 /*--------------------------------------------------------- 
    Name: OnRemove 
 ---------------------------------------------------------*/ 
 function ENT:OnRemove() 
   
 	if (self.Sound) then 
 		self.Sound:Stop() 
 	end 
   
   Dev_Unlink_All(self)
   
 end 
   
   
 /*--------------------------------------------------------- 
    Name: SetForce 
 ---------------------------------------------------------*/ 
 function ENT:SetForce( force, mul ) 
   
 	if (force) then	self.force = force end 
 	mul = mul or 1 
 	 
 	local phys = self:GetPhysicsObject() 
 	if (!phys:IsValid()) then  
 		Msg("Warning: [petrol_thruster] Physics object isn't valid!\n") 
 		return  
 	end 
 	 
 	-- Get the data in worldspace
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
 	 
 	self:SetNetworkedVector( 1, self.ForceAngle ) 
 	self:SetNetworkedVector( 2, self.ForceLinear ) 
 	 
 	self:SetOverlayText( "Force: " .. math.floor( self.force ) ) 
 	 
 end 
 
  /*--------------------------------------------------------- 
    Handle Wire inputs
 ---------------------------------------------------------*/ 
 function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		if (value > 0 or value < 0) then
			self.tempforce = self.force
			local mul = 1
			if (value < 0) then mul = -1 end
			self:SetForce(math.abs(value*self.tempforce), mul)
			self:Switch(true)
		else
			if (!self.tempforce) then self.tempforce = self.force end
			self:SetForce(self.tempforce)
			self:Switch(false)
		end
	end
end
   
   
 /*--------------------------------------------------------- 
    Called when keypad key is pressed 
 ---------------------------------------------------------*/ 
 function ENT:AddMul( mul, bDown ) 
   
 	if ( self:GetToggle() ) then  
 	 
 		if ( !bDown ) then return end 
 		 
 		if ( self.Multiply == mul ) then  
 			self.Multiply = 0 
 		else  
 			self.Multiply = mul  
 		end 
 		 
 	else 
 	 
 		self.Multiply = self.Multiply or 0 
 		self.Multiply = self.Multiply + mul	 
 	 
 	end 
 	 
 	self:SetForce( nil, self.Multiply ) 
 	self:Switch( self.Multiply ~= 0 )
 	 
 end 
   
 /*--------------------------------------------------------- 
    Name: OnTakeDamage 
 ---------------------------------------------------------*/ 
 function ENT:OnTakeDamage( dmginfo ) 
   
 	self:TakePhysicsDamage( dmginfo ) 
   
 	if (!self.ActivateOnDamage) then return end 
   
 	self:Switch( true, 1 ) 
 	timer.Create( self, 5, 1, function(...) self:Switch(...) end, false, 1 ) 
   
 end 
   
   
 /*--------------------------------------------------------- 
    Name: Use 
 ---------------------------------------------------------*/ 
 function ENT:Use( activator, caller ) 
 end 
   
 /*--------------------------------------------------------- 
    Name: Simulate 
 ---------------------------------------------------------*/ 
 function ENT:PhysicsSimulate( phys, deltatime ) 
   
 	if (!self:IsOn()) then return SIM_NOTHING end
	if (!self:CanRun()) then return SIM_NOTHING end
 	 
 	local ForceAngle, ForceLinear = self.ForceAngle, self.ForceLinear 
   
 	return ForceAngle, ForceLinear, SIM_LOCAL_ACCELERATION 
 	 
 end 
 
 /*--------------------------------------------------------- 
    Name: Think 
 ---------------------------------------------------------*/ 
 function ENT:Think()
 
	self.petrolpertick = math.ceil(self.force/GetConVarNumber( "sv_petrolthrustermult" ))

	if (self:IsOn() and self:CanRun()) then
		RD_ConsumeResource(self, "Petrol", self.petrolpertick)
		RD_SupplyResource(self, "12V Energy", 1)
	else
		self:StopThrustSound()
		self.Multiply = 0
		self:Switch( false )
	end
	
	if not (WireAddon == nil) then
		Wire_TriggerOutput(self, "Consume rate", self.petrolpertick)
	end

	self:NextThink( CurTime() + 1 ) 

end
 
 /*--------------------------------------------------------- 
    Name: CanRun
 ---------------------------------------------------------*/ 
 function ENT:CanRun()
 
	local petrol = RD_GetResourceAmount(self, "Petrol")	
	return (petrol >= self.petrolpertick)
	
 end
   
 /*--------------------------------------------------------- 
    Switch thruster on or off 
 ---------------------------------------------------------*/ 
 function ENT:Switch( on ) 
 	 
 	if (!self:IsValid()) then return false end 
 	 
	if (!self:CanRun()) then on = false end
	
	self:SetOn( on )
 	 
 	if (on) then  
	
 		self:StartThrustSound() 
 		 
 	else 
 		 
 		self:StopThrustSound() 
 		 
 	end 
 	 
 	local phys = self:GetPhysicsObject() 
 	if (phys:IsValid()) then 
 		phys:Wake() 
 	end 
 	 
 	return true 
 	 
 end 
   
 /*--------------------------------------------------------- 
    Sets whether this is a toggle thruster or not 
 ---------------------------------------------------------*/ 
 function ENT:StartThrustSound() 
   
 	if (!self:GetSound()) then return end 
	
	if (!self:CanRun()) then return end
   
 	if (!self.Sound) then 
 		self.Sound = CreateSound( self, Thruster_Sound ) 
 	end 
 	 
 	self.Sound:Play() 
   
 end 
   
 /*--------------------------------------------------------- 
    Sets whether this is a toggle thruster or not 
 ---------------------------------------------------------*/ 
 function ENT:StopThrustSound() 
   
 	if (!self:GetSound()) then return end 
   
 	if (self.Sound) then 
 		self.Sound:Stop() 
 	end 
   
 end 
   
 /*--------------------------------------------------------- 
    Sets whether this is a toggle thruster or not 
 ---------------------------------------------------------*/ 
 function ENT:SetToggle(tog) 
 	self.Toggle = tog 
 end 
   
 /*--------------------------------------------------------- 
    Returns true if this is a toggle thruster 
 ---------------------------------------------------------*/ 
 function ENT:GetToggle() 
 	return self.Toggle 
 end 
   
   
 /*--------------------------------------------------------- 
    Numpad control functions 
    These are layed out like this so it'll all get saved properly 
 ---------------------------------------------------------*/ 
 local function On( pl, ent, mul ) 
 	if (!ent:IsValid()) then return false end 
 	ent:AddMul( mul, true ) 
 	return true 
 end 
   
 local function Off( pl, ent, mul ) 
 	if (!ent:IsValid()) then return false end 
 	ent:AddMul( mul * -1, false ) 
 	return true 
 end 
   
 -- register numpad functions
 numpad.Register( "petrolThruster_On", On )
 numpad.Register( "petrolThruster_Off", Off )



--Duplicator support (TAD2020)
function ENT:PreEntityCopy()
	RD_BuildDupeInfo(self)
	if (WireAddon == 1) then
		local DupeInfo = Wire_BuildDupeInfo(self)
		if DupeInfo then
			duplicator.StoreEntityModifier( self, "WireDupeInfo", DupeInfo )
		end
	end
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	RD_ApplyDupeInfo(Ent, CreatedEntities)
	if (WireAddon == 1) then
		if (Ent.EntityMods) and (Ent.EntityMods.WireDupeInfo) then
			Wire_ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
		end
	end
end
