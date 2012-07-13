AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "Airboat_engine_idle" )
util.PrecacheSound( "Airboat_engine_stop" )
util.PrecacheSound( "apc_engine_start" )
util.PrecacheSound( "common/warning.wav" )

include('shared.lua')

if not (WireAddon == nil) then
    ENT.WireDebugName = "Nitrogen Inverter"
end

function ENT:Initialize()
	self:SetModel("models/props_c17/FurnitureBoiler001a.mdl")
    self.BaseClass.Initialize(self)
    self:SetColor(Color(0, 13, 110, 255))

    local phys = self:GetPhysicsObject()
	self.damaged = 0
	self.overdrive = 0
	self.overdrivefactor = 0
	self.Active = 0
    self.maxhealth = 200
    self.health = self.maxhealth
	self.disuse = 0
	self.energy = 0
	self.air = 0
	self.nitro = 0
    
    -- resource attributes
    self.energycon = 15 --Energy consumption
    self.nitrocon = 20 -- Nitrogen consumption
    self.airprod = 130 -- Air production
    
    self.maxoverdrive = 4 -- maximum overdrive value allowed via wire input. Anything over this value may severely damage or destroy the device.
    
    LS_RegisterEnt(self, "Generator")
    RD_AddResource(self, "nitrogen", 0)
    RD_AddResource(self, "energy",0)
    RD_AddResource(self, "air",0)

	if not (WireAddon == nil) then self.Inputs = Wire_CreateInputs(self, { "On", "Overdrive", "Disable Use" }) end
	if not (WireAddon == nil) then self.Outputs = Wire_CreateOutputs(self, { "On", "Overdrive", "Energy Consumption", "Nitrogen Consumption", "Air Production"}) end
	
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(500)
	end
end

function ENT:Setup()
	self:TriggerInput("On", 0)
	self:TriggerInput("Overdrive", 0)
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		if (value ~= 0) then
			if ( self.Active == 0 ) then
                self:TurnOn()
                if (self.overdrive == 1) then
                    self:OverdriveOn()
                end
			end
		else
			if ( self.Active == 1 ) then
                self:TurnOff()
			end
		end
	elseif (iname == "Overdrive") then
        if (self.Active == 1) then
            if (value > 0) then
                self:OverdriveOn()
                self.overdrivefactor = value
            else
                self:OverdriveOff()
            end
            if not (WireAddon == nil) then Wire_TriggerOutput(self, "Overdrive", self.overdrive) end
        end
	elseif (iname == "Disable Use") then
		if (value >= 1) then
			self.disuse = 1
		else
			self.disuse = 0
		end
	end
end


function ENT:OnRemove()
    self.BaseClass.OnRemove(self)
    self:StopSound( "Airboat_engine_idle" )
    self:StopSound( "common/warning.wav" )
    self:StopSound( "apc_engine_start" )
end

function ENT:Damage()
	if (self.damaged == 0) then
		self.damaged = 1
	end
	if ((self.Active == 1) and (math.random(1, 10) <= self.maxoverdrive)) then
		self:TurnOff()
	end
end

function ENT:Repair()
	self:SetColor(Color(0, 13, 110, 255))
	self.health = self.maxhealth
	self.damaged = 0
end

function ENT:TurnOn()
    self.Active = 1
    self:SetOOO(1)
    if not (WireAddon == nil) then 
        Wire_TriggerOutput(self, "On", 1)
    end
    self:EmitSound( "Airboat_engine_idle")
end

function ENT:TurnOff()
    self.Active = 0
    self:SetOOO(0)
    if not (WireAddon == nil) then
        Wire_TriggerOutput(self, "On", 0)
    end
    self:StopSound( "Airboat_engine_idle" )
    self:EmitSound( "Airboat_engine_stop" )
end

function ENT:OverdriveOn()
    self.overdrive = 1
    self:SetOOO(2)
    
    self:StopSound( "Airboat_engine_idle" )
    self:EmitSound( "apc_engine_stop" )
    self:EmitSound( "Airboat_engine_idle" )
    self:EmitSound( "apc_engine_start" )
end

function ENT:OverdriveOff()
    self.overdrive = 0
    self:SetOOO(1)
    
    self:StopSound( "Airboat_engine_idle" )
    self:EmitSound( "Airboat_engine_stop" )
    self:StopSound( "apc_engine_start" )
end

function ENT:Destruct()
    LS_Destruct(self)
end

function ENT:Output()
	return 1
end

function ENT:LiquidateNitro()
	if ( self.overdrive == 1 ) then
        self.energy = math.ceil(self.energycon  * self.overdrivefactor)
        self.nitro = math.ceil(self.nitrocon * self.overdrivefactor) + math.random(1,10)
        self.air = math.ceil(self.airprod * self.overdrivefactor) + math.random(1,10)
        
        if self.overdrivefactor > self.maxoverdrive then
            self:Destruct()
        else
            DamageLS(self, math.ceil(self.overdrivefactor*5))
        end
        
    else
        self.energy = self.energycon
        self.nitro = self.nitrocon + math.random(1,10)
        self.air = self.airprod + math.random(1,10)
    end
    
    if not (WireAddon == nil) then
        Wire_TriggerOutput(self, "Energy Consumption", self.energy)
        Wire_TriggerOutput(self, "Nitrogen Consumption", self.nitro)
        Wire_TriggerOutput(self, "Air Production", self.air)
    end
    
	if ( self:CanRun() ) then
        RD_ConsumeResource(self, "nitrogen", self.nitro)
        RD_ConsumeResource(self, "energy", self.energy)
        
        RD_SupplyResource(self, "air",self.air)

        if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", 1) end
	else
		self:EmitSound( "common/warning.wav" )
		if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", 0) end
	end
		
	return
end

function ENT:CanRun()
    local energy = RD_GetResourceAmount(self, "energy")
    local nitro = RD_GetResourceAmount(self, "nitrogen")
    if (energy >= self.energycon and nitro >= self.nitrocon) then
        return true
    else
        return false
    end
end

function ENT:Think()
    self.BaseClass.Think(self)
    
	if ( self.Active == 1 ) then
		self:LiquidateNitro()
	end
    
	self:NextThink( CurTime() + 1 )
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
