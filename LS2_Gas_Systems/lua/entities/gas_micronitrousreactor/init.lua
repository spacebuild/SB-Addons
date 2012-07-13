AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "k_lab.ambient_powergenerators" )
util.PrecacheSound( "ambient/machines/thumper_startup1.wav" )
util.PrecacheSound( "common/warning.wav" )

include('shared.lua')

if not (WireAddon == nil) then
    ENT.WireDebugName = "Micro Nitrous Oxide Reactor"
end

function ENT:Initialize()
	self:SetModel( "models//props_combine/headcrabcannister01a.mdl" )
    self.BaseClass.Initialize(self)
    self:SetColor(Color(0, 38, 123, 255))

    local phys = self:GetPhysicsObject()
	self.damaged = 0
	self.overdrive = 0
	self.overdrivefactor = 0
	self.Active = 0
    self.maxhealth = 250
    self.health = self.maxhealth
	self.disuse = 0 --use disabled via wire input
	self.energy = 0
	self.nitrous = 0
    self.nitrous = 0
	
    -- resource attributes
    self.energyprod = 500 --Energy production
    self.nitrouscon = 40 -- nitrous consumption
    
    self.maxoverdrive = 4 -- maximum overdrive value allowed via wire input. Anything over this value may severely damage or destroy the device.
    
    LS_RegisterEnt(self, "Generator")
    RD_AddResource(self, "energy",0)
    RD_AddResource(self, "nitrous",0)

	if not (WireAddon == nil) then self.Inputs = Wire_CreateInputs(self, { "On", "Overdrive", "Disable Use" }) end
	if not (WireAddon == nil) then self.Outputs = Wire_CreateOutputs(self, { "On", "Overdrive", "Nitrous Oxide Consumption", "Energy Production"}) end
	
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(300)
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
    self:StopSound( "k_lab.ambient_powergenerators" )
    self:StopSound( "common/warning.wav" )
    self:StopSound( "ambient/machines/thumper_startup1.wav" )
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
	self:SetColor(Color(0, 38, 123, 255))
	self.health = self.maxhealth
	self.damaged = 0
end

function ENT:TurnOn()
    self.Active = 1
    self:SetOOO(1)
    if not (WireAddon == nil) then 
        Wire_TriggerOutput(self, "On", 1)
    end
    self:EmitSound( "ambient/machines/thumper_startup1.wav" )
    self:EmitSound( "k_lab.ambient_powergenerators" )
end

function ENT:TurnOff()
    self.Active = 0
    self:SetOOO(0)
    if not (WireAddon == nil) then
        Wire_TriggerOutput(self, "On", 0)
    end
    self:StopSound( "ambient/machines/thumper_startup1.wav" )
	self:StopSound( "k_lab.ambient_powergenerators" )
end

function ENT:OverdriveOn()
    self.overdrive = 1
    self:SetOOO(2)
    
    self:StopSound( "ambient/machines/thumper_startup1.wav" )
	self:StopSound( "k_lab.ambient_powergenerators" )
    self:EmitSound( "ambient/machines/thumper_startup1.wav" )
    self:EmitSound( "k_lab.ambient_powergenerators" )
end

function ENT:OverdriveOff()
    self.overdrive = 0
    self:SetOOO(1)
    
    self:StopSound( "ambient/machines/thumper_startup1.wav" )
	self:StopSound( "k_lab.ambient_powergenerators" )
    self:EmitSound( "ambient/machines/thumper_startup1.wav" )
    self:EmitSound( "k_lab.ambient_powergenerators" )
end

function ENT:Destruct()
    LS_Destruct(self)
end

function ENT:Output()
	return 1
end

function ENT:GenerateEnergy()
	if ( self.overdrive == 1 ) then
        self.energy = math.ceil((self.energyprod + math.random(5,15)) * self.overdrivefactor)
        self.nitrous = math.ceil(self.nitrouscon * self.overdrivefactor)
        self.nitrous = math.ceil(self.nitrouscon * self.overdrivefactor)
        
        if self.overdrivefactor > self.maxoverdrive then
            self:Destruct()
        else
            DamageLS(self, math.ceil(self.overdrivefactor*5))
        end
        
    else
        self.energy = (self.energyprod + math.random(5,15))
        self.nitrous = self.nitrouscon
    end
    
	if ( self:CanRun() ) then
        RD_ConsumeResource(self, "nitrous", self.nitrous)
        
        RD_SupplyResource(self, "energy",self.energy)

        if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", 1) end
	else
		self.energy = 10
		RD_SupplyResource(self, "energy",self.energy)
		self:EmitSound( "common/warning.wav" )
		DamageLS(self, 20)
		if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", 0) end
	end
	
	if not (WireAddon == nil) then
        Wire_TriggerOutput(self, "Energy Production", self.energy)
        Wire_TriggerOutput(self, "Nitrous Oxide Consumption", self.nitrous)
    end
		
	return
end

function ENT:CanRun()
    local nitrous = RD_GetResourceAmount(self, "nitrous")
    if (nitrous >= self.nitrouscon) then
        return true
    else
        return false
    end
end

function ENT:Think()
    self.BaseClass.Think(self)
    
	if ( self.Active == 1 ) then
		self:GenerateEnergy()
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
