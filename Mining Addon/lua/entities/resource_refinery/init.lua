AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local ConversionRatio = 0.4 --Ratio of intake to outtake. 0.4 will intake 40 and output 40% of 40.
local ConversionsPerThink = 5 --Self Explanitory.
local EnergyPerConversion = 20

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	self.ConversionSpeed = ConversionsPerThink
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On" })
		self.Outputs = Wire_CreateOutputs(self, {"On" })
	end
end

function ENT:TurnOn()
		self.Active = 1
		if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", self.Active) end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		self:StopSound( "Airboat_engine_idle" )
		self:EmitSound( "Airboat_engine_stop" )
		self:StopSound( "apc_engine_start" )
		self.Active = 0
	end
end

function ENT:SetActive( value )
	if not (value == nil) then
		if (value ~= 0 and self.Active == 0 ) then
			self:TurnOn()
		elseif (value == 0 and self.Active == 1 ) then
			self:TurnOff()
		end
	else
		if ( self.Active == 0 ) then
			self.lastused = CurTime()
			self:TurnOn()
		else
			self:TurnOff()
		end
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive(value)
	end
end

function ENT:Damage()
	if (self.damaged == 0) then self.damaged = 1 end
	if ((self.Active == 1) and (math.random(1, 10) <= 4)) then
		self:TurnOff()
	end
end

function ENT:Repair()
	self:SetColor(Color(255, 255, 255, 255))
	self:SetHealth( self:GetMaxHealth( ))
	self.damaged = 0
end

function ENT:Destruct()
	if CAF and CAF.GetAddon("Mining Addon") then
		CAF.GetAddon("Mining Addon").Destruct( self, true )
	end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	self:StopSound( "Airboat_engine_idle" )
end

function ENT:Refine()
	local ent = self
	local RD = CAF.GetAddon("Resource Distribution")
	self.energy =  RD.GetResourceAmount(self, "energy")
	self.titanium = RD.GetResourceAmount(self, "titanium")
	self.naquadah = RD.GetResourceAmount(self, "naquadah")
	local energyRequired = self.ConversionSpeed*EnergyPerConversion+math.random(-5,5)
	if self.naquadah >= self.ConversionSpeed*10 and (self.energy >= energyRequired) then
		RD.ConsumeResource(self, "naquadah", self.ConversionSpeed*10)
		RD.SupplyResource(self, "refined naquadah", self.ConversionSpeed*10*ConversionRatio)
		RD.ConsumeResource(self, "energy", energyRequired)
		if self.titanium >= self.ConversionSpeed*10 and (self.energy >= energyRequired) then
			RD.ConsumeResource(self, "titanium", self.ConversionSpeed*10)
			RD.SupplyResource(self, "refined titanium", self.ConversionSpeed*10*ConversionRatio)
			RD.ConsumeResource(self, "energy", energyRequired)
		end
		
	else
		self:TurnOff()
	end
end

function ENT:SetConversionSpeed(num)
	self.ConversionSpeed = num
end

function ENT:Think()
	self.BaseClass.Think(self)
	if ( self.Active == 1 ) then
			self:Refine()
	end
	self:NextThink( CurTime() + 1 )
	return true
end
