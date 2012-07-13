AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "airboat_engine_idle" )
util.PrecacheSound( "airboat_engine_stop" )

include('shared.lua')

local Pressure_Increment = 800

function ENT:Initialize()
	self:SetModel( "models/props_vehicles/generatortrailer01.mdl" )
	self.BaseClass.Initialize(self)
	
	-- use stuff
	self.toggle = false -- On or off
	self.togglebouncekil = 3 -- You can only toggle when this is zero!
	
	-- Create a wire input to turn it on!
	if not (WireAddon == nil) then self.Inputs = Wire_CreateInputs(self, { "On" }) end
	
	-- The resources Get defined
	RD_AddResource(self, "coolant", 0)
	RD_AddResource(self, "12V Energy", 0)
	RD_AddResource(self, "Oil", 0)
	RD_AddResource(self, "Petrol", 0)
end


-- Wiremod function!
function ENT:TriggerInput(iname, value)
	if(iname == "On") then
		if(value == 1) then
			self.toggle = true
			self:SetOOO(1)
			self:EmitSound( "airboat_engine_idle" )
		else
			self.toggle = false
			self:SetOOO(0)
			self:StopSound( "airboat_engine_idle" )
			self:EmitSound( "airboat_engine_stop" )
		end	
	end
end

function ENT:Use()
    -- This stops "Bouncing" Where it toggles off and on really fast
	-- Every think togglebouncekil is decremented till it is 0
	-- at wich point you can toggle
	-- Each time you toggle it's set back to 3, Therefore disallowing control
	-- For a period of time!
	if(self.togglebouncekil == 0) then
		if(self.toggle == false) then
			self.toggle = true
			self:SetOOO(1)
			self.togglebouncekil = 3
			self:EmitSound( "airboat_engine_idle" )
			return
		end
		if(self.toggle == true) then
			self.toggle = false
			self:SetOOO(0)
			self.togglebouncekil = 3
			self:EmitSound( "airboat_engine_stop" )
			return
		end
	end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	self:StopSound( "airboat_engine_idle" )
	self:StopSound( "airboat_engine_stop" )
end

function ENT:Think()
	self.BaseClass.Think(self)
	
	-- Use key bounce removal variable
	-- It is set to 3 when entity is used, then counts down to zero, 
	-- you can only use entity WHEN it is zero
	if(self.togglebouncekil > 0) then
		self.togglebouncekil = self.togglebouncekil -1
	end
	
	-- We can only work if we are switched on -_-
	if (self.toggle == true) then
		self.energy = RD_GetResourceAmount(self, "12V Energy")
		self.oil = RD_GetResourceAmount(self, "Oil")
		self.petrol = RD_GetResourceAmount(self, "Petrol")
	-- 4 = pertol. 3 = Oil,  2 = 12v
		if(self.petrol > 50 and self.oil > 30 and self.energy > 2) then
			-- Code when on
			RD_ConsumeResource(self, "12V Energy", 2)
			RD_ConsumeResource(self, "Oil", 30)
			RD_ConsumeResource(self, "Petrol", 50)
			-- Supply the coolant
			RD_SupplyResource(self, "coolant", Pressure_Increment)
			self.togglestring = "On"
		else
			-- We dont have enough coolant, so we turn off... 
			self.toggle = false
			self.togglestring = "Off"
			self:SetOOO(0)
			self:StopSound( "airboat_engine_idle" )
		end
	else
		self:StopSound( "airboat_engine_idle" )
	end
	
	self:NextThink( CurTime() + 1 )
	return true
end
