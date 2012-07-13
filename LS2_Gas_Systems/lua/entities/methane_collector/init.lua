AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "common/warning.wav" )
util.PrecacheSound( "Buttons.snd17" )

include('shared.lua')

if not (WireAddon == nil) then
    ENT.WireDebugName = "Methane Collector"
end

local Ground = 1 + 0 + 2 + 8 + 32
local Pressure_Increment = 3
local Energy_Increment = 5

function ENT:Initialize()
	self:SetModel("models/props_c17/light_decklight01_off.mdl")
	self.BaseClass.Initialize(self)
	self:SetColor(Color(89, 45, 0, 255))
	
	self.Active = 0
	self.disuse = 0
	self.damaged = 0
	self.Active = 0
	self.maxhealth = 250
    self.health = self.maxhealth
	
	LS_RegisterEnt(self, "Generator")
	RD_AddResource(self, "methane", 0)
    RD_AddResource(self, "energy",0)
	self.energy = 0
	
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On", "Disable Use" })
		self.Outputs = Wire_CreateOutputs(self, { "Out" })
	end
end

function ENT:TurnOn()
	self:EmitSound( "Buttons.snd17" )
	self.Active = 1
	self:SetOOO(1)
	if not (WireAddon == nil) then Wire_TriggerOutput(self, "Out", self.Active) end
end

function ENT:TurnOff()
	self:EmitSound( "Buttons.snd17" )
	self.Active = 0
	self:SetOOO(0)
	if not (WireAddon == nil) then Wire_TriggerOutput(self, "Out", self.Active) end
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive(value)
	elseif (iname == "Disable Use") then
		if (value >= 1) then
			self.disuse = 1
		else
			self.disuse = 0
		end
	end
end

function ENT:Damage()
	if (self.damaged == 0) then
		self.damaged = 1
	end
end

function ENT:Repair()
	self:SetColor(Color(89, 45, 0, 255))
	self.health = self.maxhealth
	self.damaged = 0
end

function ENT:Destruct()
	LS_Destruct( self, true )
end

function ENT:Pump_Methane()
	self.energy = RD_GetResourceAmount(self, "energy")
	if (self.energy >= Energy_Increment) then
		local inc = 8 + math.random(1,17)
		RD_SupplyResource(self, "methane", inc)
		RD_ConsumeResource(self, "energy", Energy_Increment)
		if not (WireAddon == nil) then Wire_TriggerOutput(self, "Out", inc) end
	else
		self:EmitSound( "common/warning.wav" )
		if not (WireAddon == nil) then Wire_TriggerOutput(self, "Out", 0) end
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	if ( self.Active == 1 ) then 
		self:Pump_Methane() 
	end
	
	self:NextThink( CurTime() +  1)
	return true
end

function ENT:AcceptInput(name,activator,caller)
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false and self.disuse == 0 then
		if ( self.Active == 0 ) then
			self:TurnOn()
		else
            self:TurnOff()
		end
	end
end

function ENT:PreEntityCopy()
    self.BaseClass.PreEntityCopy(self)
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
    self.BaseClass.PostEntityPaste(self, Player, Ent, CreatedEntities )
end
