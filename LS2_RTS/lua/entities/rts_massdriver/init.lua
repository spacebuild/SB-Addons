-- Author: Solthar
-- Thanks to: Sassafrass
-- Entity: Mass Driver
-- Purpose: transports goods over large distances
-- and provides a nice gcombat weapon :-P
-- Uses: Resource Distribution 2, Life Support 2, GCombat, Wire
--
-- NEW IN RTS:Piracy
-- * if the packets can be slowed they become semi-stable again
-- * It loads, then waits for user input before firing the packet
-- * a MODEL!

-- Includes
AddCSLuaFile ("shared.lua")
include      ("shared.lua")

-- Precaching
util.PrecacheSound( "NPC_Strider.Shoot" )

resource.AddFile("models/rts_massdriver.mdl")
resource.AddFile("models/rts_massdriver.xbox.vtx")
resource.AddFile("models/rts_massdriver.dx80.vtx")
resource.AddFile("models/rts_massdriver.dx90.vtx")
resource.AddFile("models/rts_massdriver.phy")
resource.AddFile("models/rts_massdriver.sw.vtx")
resource.AddFile("models/rts_massdriver.vvd")
util.PrecacheModel("models/rts_massdriver.mdl" )

resource.AddFile("materials/rts_massdriver.vtf")
resource.AddFile("materials/rts_massdriver.vmt")


-- Default Variables
local _ReloadInterval = 15			-- Minimum time between mass driver shots
local _DefaultPacketSize = 1000		-- 
local _DefaultChargeRate = 10		-- How many units per tenth of a second does the Mass Driver load?
local _InternalCheckInterval = 2.5  -- Time, in seconds, between polls for new resources

function ENT:Initialize()										-- Initialization ------------------------------------------------------------------
	--self:SetModel( "models/props_lab/teleportframe.mdl" )
	self:SetModel( "models/rts_massdriver.mdl" )
	self:SetMaterial("rts_massdriver")
	self.BaseClass.Initialize(self)
	
	-- Setup the Mass Driver
	self.TargetPacketSize 	= _DefaultPacketSize
	self.CurrentPacketSize 	= 0
	self.ResourceID			= 1
	self.TimeToReload 		= 0 
	self.ChargingPacket		= false
	self.WaitingForRelease 	= false
	self.Capacitor			= 0
	
	self._count				= 0
	
	self.Multiplier			= 1
	self.ResourceWaste		= 0
	-- Energy use grows exponentially with packet size.
	self.EnergyToLaunch 	= math.Round(((self.CurrentPacketSize+1)/40)^ 2) + 50
		
	-- Add the default resources
	RD_AddResource(self, "air", 0)
	RD_AddResource(self, "coolant", 0)
	RD_AddResource(self, "energy", 0)
	RD_AddResource(self, "water", 0)
	RD_AddResource(self, "heavy water", 0)
	
	-- Tell the server that it needs to check for new resources
	-- and register them with the entity.
	self.ResTable = {}
	self.NextCheckTime = CurTime() + _InternalCheckInterval
	rts_UpdateRequest()
	self:ReadyResources()
	
	-- Set the Clientside info
	self:SetNetworkedString("Resource",self.ResTable[self.ResourceID] or 0)
	self:SetNetworkedString("Energy",self.Capacitor.." / "..self.EnergyToLaunch)
	self:SetNetworkedString("Packet",self.CurrentPacketSize.." / "..self.TargetPacketSize)
	self:SetNetworkedString("Status","Idle")
	if self.Multiplier == 1 then
		self:SetNetworkedString("OverDrive", "Disabled")
	else
		self:SetNetworkedString("OverDrive", math.Round(self.Multiplier*100).."%  -  Waste: ".. math.Round(self.ResourceWaste/10*100).."%")
	end

	
	-- Setup the Entity's Wire Inputs and Outputs
	if not (WireAddon == nil) then 
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, {"Load Packet","Launch","Cancel","Resource ID","Packet Size","Overdrive Multiplier"})
		self.Outputs = Wire_CreateOutputs( self, {"Packet Ready","Loading Packet","Current Size","Maximum Size","Capacitor Charge", "Energy To Launch" })	
		Wire_TriggerOutput(self, "Energy To Launch"	, self.EnergyToLaunch					)
	 end

end

function ENT:TriggerInput(inputName, value)					-- Wire Mod Inputs ---------------------------------------------------------------------
	self:ReadyResources()
	if 		((inputName == "Load Packet"	) and (math.Round(value) == 1)) then
		self.ChargingPacket = true
		self:SetNetworkedString("Status","Charging")
	elseif 	((inputName == "Launch"		) and (math.Round(value) == 1)) then
		if self.WaitingForRelease then 
			self:LaunchMassDriverPacket() 
		end
	elseif 	((inputName == "Cancel"		) and (math.Round(value) == 1)) then
		self:CancelPacket()
	elseif 	(inputName == "Resource ID"	) then
		self:CancelPacket()
		self.ResourceID = math.Round(math.Max(1,value))
		self:SetNetworkedString("Resource",self.ResTable[self.ResourceID] or 0)
	elseif 	(inputName == "Packet Size"	) then
		self:CancelPacket()
		self.TargetPacketSize = math.Max(value,100)
		self:SetNetworkedString("Packet",self.CurrentPacketSize.." / "..self.TargetPacketSize)
	elseif 	(inputName == "Overdrive Multiplier"	) then
		self.Multiplier = math.Max(1,value)
		if (self.Multiplier > 1) then
			self.ResourceWaste = ((self.Multiplier - 1)/4) * _DefaultChargeRate
		else
			self.ResourceWaste = 0
		end
		if self.Multiplier == 1 then
			self:SetNetworkedString("OverDrive", "Disabled")
		else
			self:SetNetworkedString("OverDrive", math.Round(self.Multiplier*100).."%  -  Waste: ".. math.Round(self.ResourceWaste/10*100).."%")
		end

	end
	
end

function ENT:CancelPacket()									-- Cancel (Refund) Loaded Packet -------------------------------------------------------
	self.CurrentPacketSize	= 0
	self.ChargingPacket 	= false
	self.WaitingForRelease 	= false
	self.EnergyToLaunch 	= math.Round(((self.CurrentPacketSize+1)/40)^ 2) + 50
	--RD_SupplyResource(self, self.ResTable[self.ResourceID], self.CurrentPacketSize)
	RD_SupplyResource(self, self.ResTable[self.ResourceID], self.CurrentPacketSize)
	self:SetNetworkedString("Status","Idle")
end

function ENT:ReadyResources()								-- Dynamic Resource Allocation Solution! -----------------------------------------------
	local iCount = rts_NumberOfResources()
	if (table.getn(self.ResTable) < iCount) then
		for x = (table.getn(self.ResTable)+1),iCount do
			self.ResTable[x] = rts_ResourceName(x)
			RD_AddResource(self, self.ResTable[x], 0)
		end
	end
end  
function ENT:Use()
	if self.WaitingForRelease then 
		self:LaunchMassDriverPacket() 
	end
end

function ENT:LaunchMassDriverPacket()									-- Launch the prepared packet if required energy is present ----------------------------
	
	--local _Energy = RD_GetResourceAmount(self, "energy")
	
	--if ((_Energy >= self.EnergyToLaunch ) and (self.TimeToReload < CurTime())) then
	if ((self.Capacitor >= self.EnergyToLaunch ) and (self.TimeToReload < CurTime())) then
		self.Capacitor = math.Min(0,self.Capacitor - self.EnergyToLaunch)
		--RD_ConsumeResource(self, "energy", self.EnergyToLaunch)
		local MDPacket = ents.Create( "rts_massdriverpacket" 							)
		MDPacket:SetPos				( self:GetPos() +  self:GetUp() * 40	)
		MDPacket:SetAngles			( self:GetAngles() 							)
		MDPacket:TransferResources	(self.ResourceID,self.CurrentPacketSize,self.ResTable[self.ResourceID])
		MDPacket:Spawn				()
		MDPacket:GetPhysicsObject	():EnableGravity( false ) 
		
		-- make sure the packet doesn't collide with the launcher.
		local constraint = constraint.NoCollide(self, MDPacket, 0, 0)
		
		MDPacket:Activate			()
	
		self.TimeToReload 		= CurTime() + _ReloadInterval
		self:EmitSound("NPC_Strider.Shoot", 100, 100)
		-- Reset the mass driver
		self:CancelPacket()
	end
end

function ENT:Think()										-- Entity Think Function ----------------------------------------------------------------
	self.BaseClass.Think(self)
	
	local _Time 		= CurTime()
	local _ResName 		= self.ResTable[self.ResourceID]
	local _ResAmount 	= RD_GetResourceAmount(self, _ResName)

	self._count = self._count + 1
	if (self._count >= 10) then
		self._count = 0
		self:SetNetworkedString("Energy",self.Capacitor.." / "..self.EnergyToLaunch)
		self:SetNetworkedString("Packet",self.CurrentPacketSize.." / "..self.TargetPacketSize)
	end
		
	-- Check for resource updates
	if (self.NextCheckTime > _Time) then
		self.NextCheckTime = CurTime() + _InternalCheckInterval
		self:ReadyResources()
	end
	
	-- The capacitor charges faster than the packet
	if (self.Capacitor < self.EnergyToLaunch) then
		local _ConsumeCapAmount 	= math.Clamp( RD_GetResourceAmount(self, "energy"), 0, math.Min(_DefaultChargeRate*5,self.EnergyToLaunch - self.Capacitor) )
		self.Capacitor 	= self.Capacitor + _ConsumeCapAmount
		RD_ConsumeResource(self, "energy", _ConsumeCapAmount)
	end
	
	-- If we are compressing a packet
	if self.ChargingPacket then 
		--self.Capacitor

		-- RESOURCE TYPE: Consume whatever we can, up to the max. DON'T consume negative resources
		local _ConsumeAmount 	= math.Clamp( _ResAmount, 0, math.Min(_DefaultChargeRate * self.Multiplier + self.ResourceWaste , self.TargetPacketSize - self.CurrentPacketSize) )
		self.CurrentPacketSize 	= self.CurrentPacketSize + _ConsumeAmount * self.Multiplier
		
		self.EnergyToLaunch 	= math.Round(((self.CurrentPacketSize+1)/40)^ 2) + 50
		
		
		RD_ConsumeResource(self, self.ResTable[self.ResourceID], _ConsumeAmount)
		
		--RD_ConsumeResource(self, _ResName, _ConsumeAmount)
		--RD_ConsumeResource(self, self.ResTable[self.ResourceID], _ConsumeAmount)
		--Error("["..self.ResTable[self.ResourceID].."] :: ".._ConsumeAmount.."\n")
	
		-- Tesla FX
		local effectdata = EffectData()
			effectdata:SetStart	(self:GetPos()+  self:GetUp() * math.Rand(10, 200) +  self:GetRight() * 50 + self:GetForward() * math.Rand(-30,30))
			effectdata:SetOrigin(self:GetPos()+  self:GetUp() * 30)
			effectdata:SetEntity(self)
			effectdata:SetAttachment( 1 )
		util.Effect( "rts_zap", effectdata ) 
			effectdata:SetStart	(self:GetPos()+  self:GetUp() * math.Rand(10, 200) +  self:GetRight() * -50 + self:GetForward() * math.Rand(-30,30))
		util.Effect( "rts_zap", effectdata ) 
	
		-- Check to see if it's ready
		if (self.CurrentPacketSize >= self.TargetPacketSize) then
			self:SetNetworkedString("Status","Ready for launch")
			self.ChargingPacket 	= false
			self.WaitingForRelease 	= true
		end
	end
	
	
	-- Wiremod Outputs
	if not (WireAddon == nil) then 
		Wire_TriggerOutput(self, "Packet Ready"		, _BoolToInt(self.WaitingForRelease)	)
		Wire_TriggerOutput(self, "Loading Packet"	, _BoolToInt(self.ChargingPacket)		)
		Wire_TriggerOutput(self, "Current Size"		, self.CurrentPacketSize				)
		Wire_TriggerOutput(self, "Maximum Size"		, self.TargetPacketSize					)
		Wire_TriggerOutput(self, "Energy To Launch"	, self.EnergyToLaunch					)
		Wire_TriggerOutput(self, "Capacitor Charge"	, self.Capacitor						)
		
	end	
	
	self:NextThink( CurTime() + 0.1 )
end

--_BoolToInt(X)