AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
if not (WireAddon == nil) then
	ENT.WireDebugName = "sensor_armor"
end
util.PrecacheSound( "Buttons.snd17" )

include('shared.lua')

local Ground = 1 + 0 + 2 + 8 + 32
local Energy_Increment = 4
local BeepCount = 3
local running = 0

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	self.entArmor = 0
	RD_AddResource(self, "energy", 0)
	if not (WireAddon == nil) then
		self.Inputs = Wire_CreateInputs(self, { "On" })
		self.Outputs = Wire_CreateOutputs(self, { "Armor",  "On" })
	end
	self.CDSIgnoreHeatDamage = true
end

function ENT:TurnOn()
	self:EmitSound( "Buttons.snd17" )
	self.Active = 1
	self:SetOOO(1)
	self:Sense()
	self:ShowOutput()
	if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", 1) end
end

function ENT:TurnOff(warn)
	if (!warn) then self:EmitSound( "Buttons.snd17" ) end
	self.Active = 0
	self:SetOOO(0)
	self:ShowOutput()
	if not (WireAddon == nil) then
		Wire_TriggerOutput(self, "On", 0)
		Wire_TriggerOutput(self, "Armor", 0)
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive( value )
	end
end

function ENT:Damage()
	if (self.damaged == 0) then self.damaged = 1 end
end

function ENT:Repair()
	self:SetColor(Color(255, 255, 255, 255))
	self.health = self.maxhealth
	self.damaged = 0
end

function ENT:Sense()
	if (RD_GetResourceAmount(self, "energy") <= 0) then
		self:EmitSound( "common/warning.wav" )
		self:TurnOff(true)
		return
	else
		if (BeepCount > 0) then
			BeepCount = BeepCount - 1
		else
			self:EmitSound( "Buttons.snd17" )
			BeepCount = 20 --30 was a little long, 3 times a minute is ok
		end
	end
	local trace = {}
	local pos = self:GetPos()
	trace.start = pos
	trace.endpos = pos + (self:GetUp() * -20)
	trace.filter = self
	local tr = util.TraceLine( trace ) 
	local CAVec = tr.HitPos
	local TAng = pos - CAVec
	if tr.Entity and tr.Entity:IsValid() and tr.Entity.armor then
		self.entArmor = tr.Entity.armor
	else
		if not CDS_LastCheck(tr.Entity)then
			self.entArmor = tr.Entity.armor
		else
			self.entArmor = -1
		end
	end
	if not (WireAddon == nil) then
		Wire_TriggerOutput(self, "Armor", self.entArmor)
	end
	RD_ConsumeResource(self, "energy", Energy_Increment)
end

function ENT:ShowOutput()
	self:SetNetworkedInt( 1, self.entArmor )
end

function ENT:Think()
	self.BaseClass.Think(self)
	if (self.Active == 1) then
		self:Sense()
		self:ShowOutput()
	end
	self:NextThink(CurTime() + 0.5)
	return true
end

