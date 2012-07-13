AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
if not (WireAddon == nil) then
	ENT.WireDebugName = "temperaturecontrol"
end
util.PrecacheSound( "Buttons.snd17" )

include('shared.lua')

local Ground = 1 + 0 + 2 + 8 + 32
local Energy_Increment = 10
local running = 0

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	self.UseRad = true
	self.NT = 0
	self.BaseTable = {}
	RD_AddResource(self, "energy", 0)
	RD_AddResource(self, "coolant", 0)
	if not (WireAddon == nil) then
		self.Inputs = Wire_CreateInputs(self, { "On", "ProtectVessel"})
		self.Outputs = Wire_CreateOutputs(self, { "On", "ProtectVessel" })
	end
end

function ENT:TurnOn()
	self:EmitSound( "Buttons.snd17" )
	self.Active = 1
	self:SetOOO(1)
	self:Sense()
	if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", 1) end
end

function ENT:TurnOff(warn)
	if (!warn) then self:EmitSound( "Buttons.snd17" ) end
	self.Active = 0
	self:SetOOO(0)
	if not (WireAddon == nil) then
		Wire_TriggerOutput(self, "On", 0)
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") and value == 1 then
		if self.Active then
			self:TurnOn()
		else
			self:TurnOff()
		end
	elseif iname == "ProtectVessel" then
		Msg("treiggerd Protect vessel with "..value.."\n")
		if value == 1 then
			self.UseRad = false
			Wire_TriggerOutput(self, "ProtectVessel", value);
			Msg("Use rad set to 1.\n")
		elseif value == 0 then
			self.UseRad = true
			Wire_TriggerOutput(self, "ProtectVessel", value);
			Msg("Use rad set to 0.\n")
		end
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
	local energy = RD_GetResourceAmount(self, "energy")
	local coolant = RD_GetResourceAmount(self, "coolant")
	if (energy <= 0) then
		self:EmitSound( "common/warning.wav" )
		self:TurnOff(true)
		return
	end
	if self.UseRad then
		self.BaseTable = ents.FindInSphere(self:GetPos(), 512)
	else
		if (not self.BaseTable) or (self.NT < CurTime()) then
			self:GetShipParts()
			self.NT = CurTime()+3 --delay it
		end
	end
	self.BaseTable = self.BaseTable or {}
	for _, ent in pairs(self.BaseTable) do
		if ent:IsValid() and ent.heat then
			local div = 1
			local dist = self:GetPos():Distance(ent:GetPos())
			if dist > 512  then
				div = 8
			elseif dist > 256  then
				div = 4
			elseif dist > 128 then
				div = 2
			end
			if ent.heat < 0 then
				if energy > 0 then
					RD_ConsumeResource(self, "energy", (math.abs(ent.heat)/5))
					energy = energy - (math.abs(ent.heat)/10)
					ent.heat = ent.heat - ent.heat/div
					if ent.suit and ent.suit.energy < 100 then
						ent.suit.energy = 100
					end
				end
			elseif ent.heat > 0 then
				if coolant > 0 then
					RD_ConsumeResource(self, "coolant", (math.abs(ent.heat)/5))
					coolant = coolant - (math.abs(ent.heat)/10)
					ent.heat = ent.heat - ent.heat/div
					if ent.suit and ent.suit.coolant < 100 then
						ent.suit.coolant = 100
					end
				end
			end
		end
	end
	RD_ConsumeResource(self, "energy", Energy_Increment)
end

function ENT:Think()
	self.BaseClass.Think(self)
	if (self.Active == 1) then
		self:Sense()
	end
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:GetShipParts()
	local entities = {}
	local consts = {}
	entities, consts = self:GetNextPart(self, entities, consts)
	self.BaseTable = entities
end

function ENT:GetNextPart(ent,EntTable,ConstraintTable)
    if ( !ent:IsValid() ) then return end
	EntTable[ ent:EntIndex() ] = ent
    if ( !constraint.HasConstraints( ent ) ) then return end
    for key, ConstraintEntity in pairs( ent.Constraints ) do
        if ( !ConstraintTable[ ConstraintEntity ] ) then
            ConstraintTable[ ConstraintEntity ] = true
            if ( ConstraintEntity[ "Ent" ] and ConstraintEntity[ "Ent" ]:IsValid() ) then
                self:GetNextPart( ConstraintEntity[ "Ent" ].Entity, EntTable, ConstraintTable)
            else
                for i=1, 6 do
                    if ( ConstraintEntity[ "Ent"..i ] and ConstraintEntity[ "Ent"..i ]:IsValid() ) then
                        self:GetNextPart( ConstraintEntity[ "Ent"..i ].Entity, EntTable, ConstraintTable)
                    end
                end
            end
		end
    end    
	return EntTable, ConstraintTable
end