--Written by Lifecell a.k.a Hein
--Thanks to Lifesupport 2 team for few part of their code.

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

util.PrecacheSound( "lifecube/poweron.wav" )

include('shared.lua')

local Ground = 1 + 0 + 2 + 8 + 32
--Generate by default
local Pressure_Increment = 50
local Energy_Increment = 50
local Coolant_Increment = 50
local Heavy_water_Increment = 10
local water_Increment = 50
local steam_Increment = 50
local ZPE_Increment = 50

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
    
    self.aEnergy = Energy_Increment
    self.aAir = Pressure_Increment
    self.aCoolant = Coolant_Increment
    self.aHeavy_water = Heavy_water_Increment
    self.aWater = water_Increment
    self.aSteam = steam_Increment
    self.aZPE = ZPE_Increment
    
	self.time = 0
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On", "Need Energy", "Need Air", "Need Coolant", "Need Heavy water", "Need water", "Need steam", "Need ZPE" })
		self.Outputs = Wire_CreateOutputs(self, { "On", "Energy Output", "Air Output", "Coolant Output", "Heavy water Output", "water Output", "steam Output", "ZPE Output" })
	end
	self:SetColor(Color( 10, 96, 255, 255 ))
end

function ENT:TurnOn()
	if (self.Active == 0) then
		self.Active = 1
		--self:EmitSound( "lifecube/poweron.wav" )
		if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", 1) end
		self:SetOOO(1)
        self:SetColor(Color( 255, 50, 0, 255 ))
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		self.Active = 0
		--self:StopSound( "lifecube/poweron.wav" )
		if not (WireAddon == nil) then 
			Wire_TriggerOutput(self, "On", 0)
			Wire_TriggerOutput(self, "Energy Output", 0)
            Wire_TriggerOutput(self, "Air Output", 0)
            Wire_TriggerOutput(self, "Coolant Output", 0)
            Wire_TriggerOutput(self, "Heavy water Output", 0)
            Wire_TriggerOutput(self, "water Output", 0)
            Wire_TriggerOutput(self, "steam Output", 0)
            Wire_TriggerOutput(self, "ZPE Output", 0)
		end
		self:SetOOO(0)
        self:SetColor(Color( 10, 96, 255, 255 ))
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive(value)
    
    elseif (iname == "Need Energy") then
        if (value > -1) then
		    self.aEnergy = value
        end
	
    elseif (iname == "Need Air") then
        if (value > -1) then
		    self.aAir = value
        end
	
    elseif (iname == "Need Coolant") then
        if (value > -1) then
		    self.aCoolant = value
        end
	
    elseif (iname == "Need Heavy water") then
        if (value > -1) then
		    self.aHeavy_water = value
        end
	
    elseif (iname == "Need water") then
        if (value > -1) then
		    self.aWater = value
        end
	
    elseif (iname == "Need steam") then
        if (value > -1) then
		    self.aSteam = value
        end
    elseif (iname == "Need ZPE") then
        if (value > -1) then
		    self.aZPE = value
        end
	end

end


function ENT:Damage()

end

function ENT:Repair()
	self:SetColor(Color( 10, 96, 0, 255 ))
	self.health = self.maxhealth
end

function ENT:Destruct()
	--self:StopSound( "lifecube/poweron.wav" )
		LS_Destruct( self )
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	--self:StopSound( "lifecube/poweron.wav" )
end

function ENT:Extract_Energy()

    if (self.aEnergy > 0) then RD_SupplyResource(self, "energy", self.aEnergy) end
    if (self.aAir > 0) then RD_SupplyResource(self, "air", self.aAir) end
    if (self.aCoolant > 0) then RD_SupplyResource(self, "coolant", self.aCoolant) end
    if (self.aHeavy_water > 0) then RD_SupplyResource(self, "heavy water", self.aHeavy_water) end
    if (self.aWater > 0) then RD_SupplyResource(self, "water", self.aWater) end
    if (self.aSteam > 0) then RD_SupplyResource(self, "steam", self.aSteam) end
    if (self.aZPE > 0) then RD_SupplyResource(self, "ZPE", self.aZPE) end
    
	if not (WireAddon == nil) then 
        Wire_TriggerOutput(self, "Energy Output", self.aEnergy)
        Wire_TriggerOutput(self, "Air Output", self.aAir)
        Wire_TriggerOutput(self, "Coolant Output", self.aCoolant)
        Wire_TriggerOutput(self, "Heavy water Output", self.aHeavy_water)
        Wire_TriggerOutput(self, "water Output", self.aWater )
        Wire_TriggerOutput(self, "steam Output", self.aSteam)
        Wire_TriggerOutput(self, "ZPE Output", self.aZPE)
    end

      

end

function ENT:Leak() 

end

function ENT:Think()
	self.BaseClass.Think(self)
	
	if (self.Active == 1) then
		self:Extract_Energy()
	end

	
	self:NextThink(CurTime() + 2)
	return true
end

